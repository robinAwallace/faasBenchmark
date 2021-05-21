#!/bin/bash

#load in framework specific functions
source $(dirname "$0")/openfaas.sh
#source $(dirname "$0")/openwhisk.sh
source $(dirname "$0")/fission.sh
source $(dirname "$0")/kubeless.sh
#. ./openfaas.sh

# Set a value:
declare "array_$index=$value"

# Get a value:
arrayGet() { 
    local array=$1 index=$2
    local i="${array}_$index"
    printf '%s' "${!i}"
}

start_minikube(){
    echo "=== Deploying Minikube ==="
    if ! minikube status > /dev/null; then
        if ! minikube start; then
            echo "Failed to deploy minikube"
            exit;
        fi
        minikube docker-env
        minikube addons enable ingress
        minikube addons enable metrics-server
    else
        echo "Minikube already deployed"
    fi
    CLUSTERIP=$(minikube ip)
}

stop_minikube()
{
    minikube stop
}

start_gke()
{
    startNode=$1
    echo "=== Creating GKE CLUSTER ==="
    if ! gcloud container clusters describe faas-cluster > /dev/null; then
        #--cluster-version 1.19.7-gke.2503
        if ! gcloud container clusters create faas-cluster --num-nodes=$startNode --machine-type e2-standard-2; then
            echo "Failed to deploy gke"
            exit;
        fi
    else 
        echo "GKE already deployed"
    fi   
    gcloud container clusters get-credentials faas-cluster
}

stop_gke(){
    echo "=== Deleting GKE CLUSTER ==="
    gcloud container clusters delete faas-cluster
}

setNodes(){
    node=$1
    if [[ $CLUSTER == "gke" ]]; then
        gcloud container clusters resize faas-cluster --num-nodes $node --quiet
    else
        echo "Setting node to: $node" 
    fi
}


deploy_prometheus() {
    #https://github.com/prometheus-operator/kube-prometheus
    echo "=== Installing Prometheus ==="
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update

    kubectl create namespace monitoring

    helm install prometheus --namespace monitoring prometheus-community/kube-prometheus-stack -f ./prometheus/values.yml # scrapeInterval: "2s"

    while [[ $(kubectl get pods -n monitoring -l app.kubernetes.io/name=grafana -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do 
        echo "waiting for grafana" && sleep 1; 
    done

    if [[ $CLUSTER == "gke" ]]; then
        kubectl expose service -n monitoring prometheus-kube-prometheus-prometheus --type=LoadBalancer --target-port=9090 --name=prometheus-server-np
        
        external_ip=""
        while [ -z $external_ip ]; do
            echo "Waiting for end point..."
            external_ip=$(kubectl -n monitoring get svc prometheus-server-np --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}")
            [ -z "$external_ip" ] && sleep 10
        done
        PROMIP=$external_ip:9090
        kubectl expose service -n monitoring prometheus-grafana --type=LoadBalancer --target-port=3000 --name=grafana-np #admin:prom-operator
    else
        kubectl expose service -n monitoring prometheus-kube-prometheus-prometheus --type=NodePort --target-port=9090 --name=prometheus-server-np
        kubectl expose service -n monitoring prometheus-grafana --type=NodePort --target-port=3000 --name=grafana-np
        PROMIP=$CLUSTERIP:$(kubectl -n monitoring get svc prometheus-server-np -o jsonpath='{...nodePort}')
    fi
}

remove_prometheus(){
    echo "=== Removing Prometheus ==="
    helm uninstall prometheus --namespace monitoring
}

handletest()
{
    frameworkName=$1
    test=$2
    name=$(echo $test | jq -r .name)
    type=$(echo $test | jq -r .type)
    frameworks=$(echo $test | jq -r .frameworks)
    functions=$(echo $test | jq .functions)
    iterations=$(echo $test | jq .iterations)
    clients=($(echo $test | jq -c -r .clients[]))
    nodes=($(echo $test | jq -c -r .nodes[])) 
    gateways=($(echo $test | jq -c -r .gateways[]))
    n=$(echo $test | jq .n)
    c=$(echo $test | jq .c)
    z=$(echo $test | jq -r .z)
    q=$(echo $test | jq -r .q)
    replications=($(echo $test | jq -c -r .replications[]))

    echo "=== TEST: $name ==="
    testfunction=$( arrayGet tests "$type" )
    if [[ $frameworks == *$frameworkName* ]]; then
        $testfunction $frameworkName "$functions" $iterations "$replications" "$clients" $n $c $z $q "$nodes" "$gateways"
    fi
}

coldstart(){
    echo "=== Coldstart test ==="

    frameworkName=$1
    functions=$2
    iterations=$3
    n=$6
    c=$7

    echo $functions |  jq -c -r '.[]' | while read f; do
        name=$(echo $f | jq -r .name)
        start=$(echo $f | jq -r .start)
        jump=$(echo $f | jq -r .jump)
        end=$(echo $f | jq -r .end)
        
        deployfunction_$frameworkName $name 0 1 20 1      

        for input in $(seq $start $jump $end)
        do
            for i in $(seq 1 $iterations)
            do
                scalefunction_$frameworkName $name 0

                url=$(getUrlForFuction_$frameworkName $name)

                echo "Wait until pod is scaled to 0"

                echo "load function at url: $url"

                fileName="${frameworkName}_${name}_${input}_${i}.csv"
                #mkdir -p data
                hey -c 1 -n 1 -q 1 -d $input -o csv $url > $fileName
                if [ $i -eq 1 ]
                then
                    mkdir -p ./$outputFolder/coldstart 
                    cat $fileName > "./$outputFolder/coldstart/${frameworkName}_${name}.csv"
                else
                    tail -n -1 $fileName >> "./$outputFolder/coldstart/${frameworkName}_${name}.csv"
                fi
                rm $fileName

                hey -c 1 -n 1 -q 1 -d $input -o csv $url > $fileName
                if [ $i -eq 1 ]
                then
                    mkdir -p ./$outputFolder/coldstart/reference 
                    cat $fileName > "./$outputFolder/coldstart/reference/${frameworkName}_${name}_reference.csv"
                else
                    tail -n -1 $fileName >> "./$outputFolder/coldstart/reference/${frameworkName}_${name}_reference.csv"
                fi
                rm $fileName

            done
        done

        #echo "save metrics"
        #Add get metrics from promethues?

        removefunction_$frameworkName $name
    done
}

coldstartload(){
    echo "=== Coldstartload test ==="

    frameworkName=$1
    functions=$2
    iterations=$3
    n=$5
    c=$6
    z=$7
    q=$8

    echo $functions |  jq -c -r '.[]' | while read f; do
        name=$(echo $f | jq -r .name)
        start=$(echo $f | jq -r .start)
        jump=$(echo $f | jq -r .jump)
        end=$(echo $f | jq -r .end)
        
        deployfunction_$frameworkName $name 1 20       

        for input in $(seq $start $jump $end)
        do
            for i in $(seq 1 $iterations)
            do
                starttime=$(date --iso-8601='seconds')
                scalefunction_$frameworkName $name 1
                url=$(getUrlForFuction_$frameworkName $name)

                echo "load function at url: $url"
                fileName="${frameworkName}_${name}_${input}_${i}.csv"
                #mkdir -p data
                hey -c $c -n $n -q $q -d $input -o csv $url > $fileName
                if [ $i -eq 1 ]
                then
                    mkdir -p ./$outputFolder/coldstartload 
                    cat $fileName > "./$outputFolder/coldstartload/${frameworkName}_${name}.csv"
                else
                    tail -n -1 $fileName >> "./$outputFolder/coldstartload/${frameworkName}_${name}.csv"
                fi
                rm $fileName
                namespace=$(getNamespaceForFuction_$frameworkName)
                filter="count(kube_pod_info{namespace=\"${namespace}\"}) by (namespace)"
                endtime=$(date --iso-8601='seconds')
                echo "Retriving metrics at url: http://$PROMIP $filter $starttime $endtime $namespace" 
                promql --host http://${PROMIP} "$(echo ${filter})" --output csv --start $starttime --end $endtime --step 1s > "./$outputFolder/coldstartload/${frameworkName}_${name}_count.csv" 

            done
        done

        #promql --host  http://192.168.49.2:32122 'count(kube_pod_info{namespace="openfaas-fn"}) by (namespace)' --output csv --start 2021-03-02T14:16:25+01:00 --end now --step 1s

        #echo "save metrics"
        #Add get metrics from promethues?

        removefunction_$frameworkName $name
    done
}

increasingClient(){
    echo "=== Increasing Load (Increasing Client) test ==="

    frameworkName=$1
    functions=$2
    iterations=$3
    replications=$4
    n=$5
    c=$6
    z=$7
    q=$8

    echo $functions |  jq -c -r '.[]' | while read f; do
        name=$(echo $f | jq -r .name)
        array=($(echo $f | jq -c -r .clients[]))
        d=$(echo $f | jq -r .d)
        
        for replication in ${replications[@]}
        do
            deployfunction_$frameworkName $name $replication $replication 20 $replication
            for input in ${array[@]}
            do
                echo "Replication: $replication | Clients: $input"
                starttime=$(date --iso-8601='seconds')
                echo "Start time: $starttime"
                echo "Wating 20s"
                sleep 20
                for i in $(seq 1 $iterations)
                do
                    url=$(getUrlForFuction_$frameworkName $name)
                    
                    #mkdir -p data
                    mkdir -p ./$outputFolder/increasingClient

                    echo "load function at url: $url -c $input -q $q -n $n -d $d"
                    fileName="./$outputFolder/increasingClient/${frameworkName}_${name}_${replication}_${input}_${i}.csv"
                    hey -c $input -q $q -n $n -m GET -d $d -o csv $url > $fileName
                done
                echo "Wating 90s"
                sleep 90
                endtime=$(date --iso-8601='seconds')
                echo "End time: $endtime"
                namespace=$(getNamespaceForFuction_$frameworkName)
                #cluster="$cluster", namespace="$namespace", container="fibonacci", image!=""
                filter="(sum(node_namespace_pod_container:container_cpu_usage_seconds_total:sum_rate{namespace=\"${namespace}\", container=\"${name}\"}) by (namespace))"
                echo "Retriving metrics at url: http://$PROMIP $filter $starttime $endtime"
                promql --host http://${PROMIP} "$(echo ${filter})" --output csv --start $starttime --end $endtime --step 1s > "./$outputFolder/increasingClient/${frameworkName}_${name}_cpu_${replication}_${input}_${i}.csv" 
                filter="sum(container_memory_working_set_bytes{namespace=\"${namespace}\", container=\"${name}\"}) by (namespace)"
                promql --host http://${PROMIP} "$(echo ${filter})" --output csv --start $starttime --end $endtime --step 1s > "./$outputFolder/increasingClient/${frameworkName}_${name}_memory_${replication}_${input}_${i}.csv" 
            done
        done       

        #echo "save metrics"
        #Add get metrics from promethues?

        removefunction_$frameworkName $name
    done
}

increasingNode(){
    echo "=== Increasing Load (Increasing Client ande Node Number) test ==="

    frameworkName=$1
    functions=$2
    iterations=$3
    replications=$4
    clients=$5
    n=$6
    c=$7
    z=$8
    q=$9
    nodes="${10}"

    folderName="node"

    for node in ${nodes[@]}
    do
        setNodes $node
        echo "$functions" |  jq -c -r '.[]' | while read f; do
            name=$(echo $f | jq -r .name)
            d=$(echo $f | jq -r .d)
            
            for replication in ${replications[@]}
            do
                deployfunction_$frameworkName $name $replication $replication 20 $replication
                for input in ${clients[@]}
                do
                    echo "Replication: $replication | Clients: $input"
                    starttime=$(date --iso-8601='seconds')
                    echo "Start time: $starttime"
                    echo "Wating 20s"
                    sleep 20
                    for i in $(seq 1 $iterations)
                    do
                        url=$(getUrlForFuction_$frameworkName $name)
                        
                        #mkdir -p data
                        mkdir -p ./$outputFolder/$folderName

                        echo "load function at url: $url -c $input -q $q -n $n -d $d"
                        fileName="./$outputFolder/$folderName/${frameworkName}_${name}_${node}_${replication}_${input}_${i}.csv"
                        hey -c $input -q $q -n $n -m GET -d $d -o csv $url > $fileName
                    done
                    echo "Wating 90s"
                    sleep 90
                    endtime=$(date --iso-8601='seconds')
                    echo "End time: $endtime"
                    namespace=$(getNamespaceForFuction_$frameworkName)
                    #cluster="$cluster", namespace="$namespace", container="fibonacci", image!=""
                    filter="(sum(node_namespace_pod_container:container_cpu_usage_seconds_total:sum_rate{namespace=\"${namespace}\", container=\"${name}\"}) by (namespace))"
                    echo "Retriving metrics at url: http://$PROMIP $filter $starttime $endtime"
                    promql --host http://${PROMIP} "$(echo ${filter})" --output csv --start $starttime --end $endtime --step 1s > "./$outputFolder/$folderName/${frameworkName}_${name}_cpu_${node}_${replication}_${input}_${i}.csv" 
                    filter="sum(container_memory_working_set_bytes{namespace=\"${namespace}\", container=\"${name}\"}) by (namespace)"
                    promql --host http://${PROMIP} "$(echo ${filter})" --output csv --start $starttime --end $endtime --step 1s > "./$outputFolder/$folderName/${frameworkName}_${name}_memory_${node}_${replication}_${input}_${i}.csv" 
                done
            done       

            #echo "save metrics"
            #Add get metrics from promethues?

            removefunction_$frameworkName $name
        done
    done

    
}


increasingWorkload(){
    echo "=== Increasing Load (Workload) test ==="

    frameworkName=$1
    functions=$2
    n=$5

    echo $functions |  jq -c -r '.[]' | while read f; do
        name=$(echo $f | jq -r .name)
        
        deployfunction_$frameworkName $name 1 1 20 1
        d=($(echo $f | jq -c -r .d[]))
        for input in ${d[@]}
        do
            starttime=$(date --iso-8601='seconds')
            echo "Start time: $starttime"
            echo "Wating 20s"
            sleep 20
            
            url=$(getUrlForFuction_$frameworkName $name)
            mkdir -p ./$outputFolder/increasingWorkload

            echo "load function at url: $url -c 1 -n $n -d $input"
            fileName="./$outputFolder/increasingWorkload/${frameworkName}_${name}_${input}.csv"
            hey -c 1 -n $n -m GET -d $input -o csv $url > $fileName

            echo "Wating 90s"
            sleep 90
            endtime=$(date --iso-8601='seconds')
            echo "End time: $endtime"
            namespace=$(getNamespaceForFuction_$frameworkName)

            filter="(sum(node_namespace_pod_container:container_cpu_usage_seconds_total:sum_rate{namespace=\"${namespace}\", container=\"${name}\"}) by (namespace))"
            echo "Retriving metrics at url: http://$PROMIP $filter $starttime $endtime"
            promql --host http://${PROMIP} "$(echo ${filter})" --output csv --start $starttime --end $endtime --step 1s > "./$outputFolder/increasingWorkload/${frameworkName}_${name}_cpu_${input}.csv" 
            filter="sum(container_memory_working_set_bytes{namespace=\"${namespace}\", container=\"${name}\"}) by (namespace)"
            promql --host http://${PROMIP} "$(echo ${filter})" --output csv --start $starttime --end $endtime --step 1s > "./$outputFolder/increasingWorkload/${frameworkName}_${name}_memory_${input}.csv" 
        done
        removefunction_$frameworkName $name
    done
}

increasingGateway(){
    echo "=== Increasing gateway test ==="

    frameworkName=$1
    functions=$2
    iterations=$3
    clients=$5
    n=$6
    c=$7
    z=$8
    q=$9
    gateways="${11}"

    folderName="gateway"
    echo $clients
    echo $gateways
    for gateway in ${gateways[@]}
    do
        echo $gateway
        scalegateway_$frameworkName $gateway
        echo "$functions" |  jq -c -r '.[]' | while read f; do
            name=$(echo $f | jq -r .name)
            d=$(echo $f | jq -r .d)

            deployfunction_$frameworkName $name 100 100 20 100
            for input in ${clients[@]}
            do
                echo "Gateways: $gateway | Clients: $input"
                starttime=$(date --iso-8601='seconds')
                echo "Start time: $starttime"
                echo "Wating 20s"
                sleep 20

                url=$(getUrlForFuction_$frameworkName $name)
                
                #mkdir -p data
                mkdir -p ./$outputFolder/$folderName

                echo "load function at url: $url -c $input -q $q -n $n -d $d"
                fileName="./$outputFolder/$folderName/${frameworkName}_${name}_${gateway}_${input}.csv"
                hey -c $input -q $q -n $n -m GET -d $d -o csv $url > $fileName
                
                echo "Wating 90s"
                sleep 90
                endtime=$(date --iso-8601='seconds')
                echo "End time: $endtime"
                namespace=$(getNamespaceForFuction_$frameworkName)
                #cluster="$cluster", namespace="$namespace", container="fibonacci", image!=""
                filter="(sum(node_namespace_pod_container:container_cpu_usage_seconds_total:sum_rate{namespace=\"${namespace}\", container=\"${name}\"}) by (namespace))"
                echo "Retriving metrics at url: http://$PROMIP $filter $starttime $endtime"
                promql --host http://${PROMIP} "$(echo ${filter})" --output csv --start $starttime --end $endtime --step 1s > "./$outputFolder/$folderName/${frameworkName}_${name}_cpu_${gateway}_${input}.csv" 
                filter="sum(container_memory_working_set_bytes{namespace=\"${namespace}\", container=\"${name}\"}) by (namespace)"
                promql --host http://${PROMIP} "$(echo ${filter})" --output csv --start $starttime --end $endtime --step 1s > "./$outputFolder/$folderName/${frameworkName}_${name}_memory_${gateway}_${input}.csv" 
            done
            
            #echo "save metrics"
            #Add get metrics from promethues?

            removefunction_$frameworkName $name
        done
    done

    
}

usage() { echo "Usage: $0 [--c <minikube/gke> ] [ --f <configuration.json> ]" 1>&2; exit 1;}

ARGUMENT_LIST=(
    "cluster"
    "file"
)

opts=$(getopt \
    --longoptions "$(printf "%s:," "${ARGUMENT_LIST[@]}")" \
    --name "$(basename "$0")" \
    --options "" \
    -- "$@"
)

eval set --$opts

if [ $# -eq 1 ]
  then
    usage
fi

while [[ $# -gt 1 ]]; do
    case "$1" in
        --cluster)
            CLUSTER=$2
            shift 2
            ;;
        --file)
            CONFIG=$2
            shift 2
            ;;
        *)
            usage
            ;;
    esac
done

if [[ $CLUSTER == "minikube" ]]; then
    start_minikube
elif [[ $CLUSTER == "gke" ]]; then    
    startNodes=$(jq '.startNodes' $CONFIG)
    start_gke $startNodes
fi
deploy_prometheus

type="coldstart"
function=coldstart
declare "tests_$type=$function"

type="coldstartload"
function=coldstartload
declare "tests_$type=$function"

type="increasingClient"
function=increasingClient
declare "tests_$type=$function"

type="increasingWorkload"
function=increasingWorkload
declare "tests_$type=$function"

type="increasingNode"
function=increasingNode
declare "tests_$type=$function"

type="increasingGateway"
function=increasingGateway
declare "tests_$type=$function"

#value=$( arrayGet frameworks "$type" )
#echo $value

outputFolder=$(date --iso-8601='date')

mkdir -p $outputFolder
ulimit -n 4096

jq -c -r '.frameworks[]' $CONFIG | while read i; do
    deploy_$i

    jq -c '.tests[]' $CONFIG | while read t; do
        handletest $i "$t"
    done
    
    clean_$i
    
    zip $outputFolder.zip -r $outputFolder
done

#if $MINIKUBE; then
#    stop_minikube
#fi
