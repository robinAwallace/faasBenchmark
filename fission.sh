deploy_fission(){
    echo "=== Deploy Fission =="

    kubectl create namespace fission
    helm install --namespace fission --name-template fission \
        https://github.com/fission/fission/releases/download/1.12.0/fission-all-1.12.0.tgz
    
    echo "=== Wait until fission router is up and running"
    while [[ $(kubectl get pods -n fission -l application=fission-router -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do 
        echo "waiting for router" && sleep 1; 
    done

    if [[ $CLUSTER == "gke" ]]; then
        external_ip=""
        while [ -z $external_ip ]; do
            echo "Waiting for end point..."
            external_ip=$(kubectl -n fission get svc router --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}")
            [ -z "$external_ip" ] && sleep 10
        done
        export ROUTER_URL=$external_ip:$(kubectl -n fission get svc router -o jsonpath='{...port}')
    else 
        export ROUTER_URL=$CLUSTERIP:$(kubectl -n fission get svc router -o jsonpath='{...nodePort}')
    fi

    sleep 5
    fission environment create --name nodejs --graceperiod 1 --version 3 --poolsize 1 --image fission/node-env --builder fission/node-builder
    echo "=== Wait until nodejs builder is up and running"
    while [[ $(kubectl get pods -n fission-builder -l envName=nodejs -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do 
        echo "waiting for builder" && sleep 1; 
    done
    
    fission package create --src ./fission/sleep/sleep.zip --env nodejs --name sleep-zip
    fission package create --src ./fission/fibonacci/fibonacci.zip --env nodejs --name fibonacci-zip
    fission package create --src ./fission/vector/vector.zip --env nodejs --name vector-zip
    fission package create --src ./fission/matrix/matrix.zip --env nodejs --name matrix-zip

    until [[ $(fission package info --name sleep-zip | grep succeeded) ]]; do
    if [[ $(fission package info --name sleep-zip | grep failed) ]]; then
        echo "Build failed"
        exit 1
    fi
        echo "waiting for sleep function to build" && sleep 1; 
    done

    until [[ $(fission package info --name fibonacci-zip | grep succeeded) ]]; do
        if [[ $(fission package info --name fibonacci-zip | grep failed) ]]; then
            echo "Build failed"
            exit 1
        fi
        echo "waiting for fibonacci function to build" && sleep 1; 
    done
    sleep 240
}

getNamespaceForFuction_fission(){
    echo fission-function
}

getUrlForFuction_fission(){
    functionName=$1
    echo http://$ROUTER_URL/$functionName
}

deployfunction_fission(){
    functionName=$1
    minScale=$2
    maxScale=$3
    factor=$4
    scaleNr=$5
    echo "=== Deploying function: $functionName $minScale $maxScale $factor $scaleNr ==="

    if ! fission fn create --name $functionName --env nodejs --pkg $functionName-zip --executortype newdeploy \
                        --minscale $minScale --maxscale $maxScale --targetcpu 20 ; then 
        fission fn update --name $functionName --minscale $minScale --maxscale $maxScale --targetcpu 20
    else
        fission httptrigger create --url /$functionName --method GET --function $functionName --name $functionName
    fi

    #Requests:
    #  cpu:        10m
    #  memory:     16Mi
    
    echo "=== Wait until function is up and running"
    scalefunction_fission $functionName $scaleNr
}

scalefunction_fission(){
    functionName=$1
    scaleNr=$2
    echo "=== Scaling function: $functionName to $scaleNr ==="
    kubectl scale deployment -n fission-function -l functionName=$functionName --replicas=$scaleNr
    while [[ $(kubectl get pods -n fission-function -l functionName=$functionName -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}' | grep -o True | wc -l ) != $scaleNr ]]; do 
        echo "waiting for function" && sleep 5; 
    done
}

removefunction_fission(){
    functionName=$1
    echo "=== Removing function: $functionName ==="
    fission fn delete --name $functionName
}


clean_fission(){
    echo "=== Clean up Fission =="
    helm delete --namespace fission fission

    kubectl delete crd -n fisson --all

    kubectl delete namespace fission
}