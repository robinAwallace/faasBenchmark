deploy_kubeless(){
    echo "=== Deploy Kubeless =="
    kubectl create ns kubeless
    kubectl create -f ./kubeless/kubeless-v1.0.8.yaml
    
    if [[ $CLUSTER == "gke" ]]; then
        helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
        helm repo update
        kubectl create namespace ingress-nginx
        helm install --namespace ingress-nginx ingress-nginx ingress-nginx/ingress-nginx
        external_ip=""
        while [ -z $external_ip ]; do
            echo "Waiting for end point..."
            external_ip=$(kubectl -n ingress-nginx get svc ingress-nginx-controller --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}")
            [ -z "$external_ip" ] && sleep 10
        done
        KUBELESSIP=$external_ip
    else
        KUBELESSIP=$CLUSTERIP
    fi

    echo "=== Wait until kubeless controller is up and running"
    while [[ $(kubectl get pods -n kubeless -l kubeless=controller -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do 
        echo "waiting for pod" && sleep 1; 
    done
}

getNamespaceForFuction_kubeless(){
    echo default
}

getUrlForFuction_kubeless(){
    functionName=$1
    echo http://$functionName.$KUBELESSIP.nip.io
}

deployfunction_kubeless(){
    functionName=$1
    minScale=$2
    maxScale=$3
    factor=$4
    scaleNr=$5
    echo "=== Deploying function: $functionName $minScale $maxScale $factor $scaleNr ==="

    kubeless function deploy $functionName --runtime nodejs10 \
                    --dependencies ./kubeless/$functionName/package.json \
                    --handler handler.$functionName \
                    --from-file ./kubeless/$functionName/$functionName.zip
                    
    kubeless trigger http create $functionName --function-name $functionName --hostname $functionName.$KUBELESSIP.nip.io

    #qps not working...
    scalefunction_kubeless $functionName $scaleNr $factor
    #kubeless autoscale create $functionName --metric cpu --min $minScale --max $maxScale --value $factor

       
    sleep 15
}

scalefunction_kubeless(){
    functionName=$1
    scaleNr=$2
    factor=$3
    echo "=== Scaling function: $functionName to $scaleNr ==="
    kubeless autoscale create $functionName --metric cpu --min $scaleNr --max $scaleNr --value $factor

    echo "=== Wait until function $functionName is up and running"
    #kubectl get deploy vector -o 'jsonpath={..status.updatedReplicas}'
    while [[ $(kubectl get deploy $functionName -o 'jsonpath={..status.readyReplicas}' ) != $scaleNr ]]; do 
        echo "waiting for function" && sleep 5; 
    done
}

removefunction_kubeless(){
    functionName=$1
    echo "=== Removing function: $functionName ==="
    kubeless function delete $functionName
}

scalegateway_kubeless(){
    scaleNr=$1
    echo "=== Scaling function: Gateway to $scaleNr ==="
    kubectl scale deployment -n ingress-nginx --replicas=$scaleNr ingress-nginx-controller

    echo "=== Wait until gateway  is up and running"
    #kubectl get deploy vector -o 'jsonpath={..status.updatedReplicas}'
    while [[ $(kubectl get deploy -n ingress-nginx ingress-nginx-controller -o 'jsonpath={..status.readyReplicas}' ) != $scaleNr ]]; do 
        echo "waiting for function" && sleep 5; 
    done
}

clean_kubeless(){
    echo "=== Clean up Kubeless =="

    kubectl delete -f ./kubeless/kubeless-v1.0.8.yaml

    helm delete --namespace ingress-nginx ingress-nginx ingress-nginx/ingress-nginx

    kubectl delete ns kubeless
    kubectl delete ns ingress-nginx
}