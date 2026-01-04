# Envoy Proxy Installation
In this guide we will deploy the Envoy Gateway Proxy and a sample installation following the developers instructions.

Then we will delete and redeploy the Envoy Gateway leveraging Terraform and Helm.


[REFERENCE(s)]
https://www.envoyproxy.io/docs/envoy/latest/start/install

https://gateway.envoyproxy.io/docs/


# Envoy proxy manual installation in Kubernetes
Envoy will run as a Kubernetes Gateway when deployed in a kubernetes cluster.

1. Install gateway API CRD;s and Envoy Gateway

- The timeout of 5 minutes is to allow time for the Envoy gateway to become available.
- Helm will leverage docker to pull the container image docker.io/envoyproxy/gateway-helm:v0.0.0-latest and 
deploy a container in your EKS cluster.


helm install eg oci://docker.io/envoyproxy/gateway-helm --version v0.0.0-latest -n envoy-gateway-system --create-namespace
kubectl wait --timeout=5m -n envoy-gateway-system deployment/envoy-gateway --for=condition=Available

# Example output
helm install eg oci://docker.io/envoyproxy/gateway-helm --version v0.0.0-latest -n envoy-gateway-system --create-namespace
Pulled: docker.io/envoyproxy/gateway-helm:v0.0.0-latest
Digest: sha256:99ef4be65dea3231d3967a59846b595d4ff9b4599aa9f6bb84321d9520fba34b
NAME: eg
LAST DEPLOYED: Sat Aug 30 14:03:29 2025
NAMESPACE: envoy-gateway-system
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
**************************************************************************
*** PLEASE BE PATIENT: Envoy Gateway may take a few minutes to install ***
**************************************************************************

Envoy Gateway is an open source project for managing Envoy Proxy as a standalone or Kubernetes-based application gateway.

Thank you for installing Envoy Gateway! 🎉

Your release is named: eg. 🎉

Your release is in namespace: envoy-gateway-system. 🎉

To learn more about the release, try:

  $ helm status eg -n envoy-gateway-system
  $ helm get all eg -n envoy-gateway-system

To have a quickstart of Envoy Gateway, please refer to https://gateway.envoyproxy.io/latest/tasks/quickstart.

To get more details, please visit https://gateway.envoyproxy.io and https://github.com/envoyproxy/gateway

# Example output
kubectl wait --timeout=5m -n envoy-gateway-system deployment/envoy-gateway --for=condition=Available
deployment.apps/envoy-gateway condition met

2. Install the GatewayClass, Gateway, HTTPRoute and a sample application to get familiar with envoy.
kubectl apply -f https://github.com/envoyproxy/gateway/releases/download/latest/quickstart.yaml -n default

# Example output
gatewayclass.gateway.networking.k8s.io/eg created
gateway.gateway.networking.k8s.io/eg created
serviceaccount/backend created
service/backend created
deployment.apps/backend created
httproute.gateway.networking.k8s.io/backend created

3. Verify envoy is installed
kubectl get pods -n envoy-gateway-system

NAME                                      READY   STATUS    RESTARTS   AGE
envoy-default-eg-e41e7b31-c46b577-28cds   2/2     Running   0          4m59s
envoy-gateway-6dd8f9b8f-48m5t             1/1     Running   0          5m19s

4. Teardown envoy installation
helm uninstall eg -n envoy-gateway-system

kubectl delete namespace envoy-gateway-system
