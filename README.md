# faasBenchmark

This repository is part of a Master thesis at Umeå University for evaluating Function as a Service frameworks on Kubernetes.
There are multiple scripts that help to setup and perform tests on OpenFaaS, Fission and Kubeless.

The script Benchmark.sh inputs are the cluster type minikube or GKE and a test configuration file. This means that minikube must be installed or google cli must be set up before using the script. There are subscripts for each framework that Benchmark.sh uses.

All the garthed data is found in data and all matlab scripts used to visualize the data is found under matlab scripts. Matlab and Boxplot2 are required to run the matlabscritps.

The material embodied in this repository is provided to you "as-is" and without warranty of any kind, express, implied or otherwise, including without limitation, any warranty of fitness for a particular purpose.
