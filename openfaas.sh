deploy_openfaas(){
    echo "=== Deploy OpenFaas =="
    echo "=== Applying namespaces ==="
    kubectl apply -f OpenFaaS/namespaces.yml

    echo "=== Adding openfass repo ==="
    helm repo add openfaas https://openfaas.github.io/faas-netes/

    echo "=== HELM installing openfass ==="
    if [[ $CLUSTER == "gke" ]]; then
        helm upgrade openfaas --install openfaas/openfaas \
        --namespace openfaas  \
        --set functionNamespace=openfaas-fn \
        --set generateBasicAuth=true \
        --set openfaasPRO=false \
        --set serviceType=LoadBalancer

        external_ip=""
        while [ -z $external_ip ]; do
            echo "Waiting for end point..."
            external_ip=$(kubectl -n openfaas get svc gateway-external --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}")
            [ -z "$external_ip" ] && sleep 10
        done
        export OPENFAAS_URL=$external_ip:8080
    else
        helm upgrade openfaas --install openfaas/openfaas \
        --namespace openfaas  \
        --set functionNamespace=openfaas-fn \
        --set generateBasicAuth=true \
        --set openfaasPRO=false

        export OPENFAAS_URL=$CLUSTERIP:31112
    fi
    
    echo "=== Wait until openFaaS gateway is up and running"
    while [[ $(kubectl get pods -n openfaas -l app=gateway -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do 
        echo "waiting for pod" && sleep 1; 
    done

    echo "=== OpenFaaS Password ==="
    PASSWORD=""
    while [ "$PASSWORD" == "" ]
    do
        PASSWORD=$(kubectl -n openfaas get secret basic-auth -o jsonpath="{.data.basic-auth-password}" | base64 --decode) && \
        
        echo "waiting for pod" && sleep 1;
    done

    until faas-cli login -g $OPENFAAS_URL -u admin -p $PASSWORD 
    do
        echo "waiting..." && sleep 1;
    done    

    echo "=== OpenFaaS Prometheus"
    while [[ $(kubectl get pods -n openfaas -l app=prometheus -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do 
        echo "waiting for prometheus" && sleep 1; 
    done

    if [[ $CLUSTER == "gke" ]]; then
        kubectl expose service -n openfaas prometheus --type=LoadBalancer --target-port=9090 --name=prometheus-openfaas-server-np
        external_ip=""
        while [ -z $external_ip ]; do
            echo "Waiting for end point..."
            external_ip=$(kubectl -n openfaas get svc prometheus-openfaas-server-np --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}")
            [ -z "$external_ip" ] && sleep 10
        done
        PROMOPENFAASIP=$external_ip:$(kubectl -n openfaas get svc prometheus-openfaas-server-np -o jsonpath='{...nodePort}')
    else
        kubectl expose service -n openfaas prometheus --type=NodePort --target-port=9090 --name=prometheus-openfaas-server-np
        PROMOPENFAASIP=$CLUSTERIP:$(kubectl -n openfaas get svc prometheus-openfaas-server-np -o jsonpath='{...nodePort}')
    fi
}

deployfunction_openfaas(){
    functionName=$1
    minScale=$2
    maxScale=$3
    factor=$4
    scaleNr=$5
    echo "=== Deploying function: $functionName $minScale $maxScale $factor $scaleNr ==="

    until faas-cli deploy --gateway $OPENFAAS_URL --filter $functionName --label com.openfaas.scale.min=$minScale \
    --label com.openfaas.scale.max=$maxScale --label com.openfaas.scale.factor=$factor \
    -f openFaaSFunctions.yml
    do
        echo "waiting..." && sleep 5;
    done   
        
    echo "=== Wait until function $functionName is up and running"
    
    scalefunction_openfaas $functionName $scaleNr
}

getNamespaceForFuction_openfaas(){
    echo openfaas-fn
}

getUrlForFuction_openfaas(){
    functionName=$1
    echo http://$OPENFAAS_URL/function/$functionName
}

scalefunction_openfaas(){
    functionName=$1
    scaleNr=$2
    echo "=== Scaling function: $functionName to $scaleNr ==="
    kubectl scale deployment -n openfaas-fn --replicas=$scaleNr $functionName
    
    #kubectl get deploy -n openfaas-fn vector -o 'jsonpath={..status.updatedReplicas}'
    #kubectl get pods -n openfaas-fn -l faas_function=$functionName -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}' | grep -o True | wc -l

    if [[ $scaleNr == 0 ]]; then
        while [[ ! -z $(kubectl get deploy -n openfaas-fn $functionName -o 'jsonpath={..status.updatedReplicas}' ) ]]; do 
            echo "waiting for function" && sleep 5; 
        done
    else
        while [[ $(kubectl get deploy -n openfaas-fn $functionName -o 'jsonpath={..status.updatedReplicas}' ) != $scaleNr ]]; do 
            echo "waiting for function" && sleep 5; 
        done
    fi

    
}

removefunction_openfaas(){
    functionName=$1
    echo "=== Removing function: $functionName ==="
    faas-cli remove --gateway $OPENFAAS_URL --filter $functionName -f openFaaSFunctions.yml
}

scalegateway_openfaas(){
    scaleNr=$1
    echo "=== Scaling gateway to $scaleNr ==="
    kubectl scale deployment -n openfaas --replicas=$scaleNr gateway
    
    #kubectl get deploy -n openfaas-fn vector -o 'jsonpath={..status.updatedReplicas}'
    #kubectl get pods -n openfaas-fn -l faas_function=$functionName -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}' | grep -o True | wc -l

    while [[ $(kubectl get deploy -n openfaas gateway -o 'jsonpath={..status.readyReplicas}' ) != $scaleNr ]]; do 
        echo "waiting for gateway" && sleep 5; 
    done
}


clean_openfaas(){
    echo "=== Clean up OpenFaas =="
    echo "=== HELM uninstall openfaas ==="
    helm uninstall openfaas --namespace openfaas

    echo "=== Removing openfass namespaces ==="
    kubectl delete -f OpenFaaS/namespaces.yml
}