# Prometheus Installation in EKS Cluster

We have options for installing Prometheus in the EKS cluster. 

[REFEFERENCE(S)] 
Prometheus initial configuration: https://prometheus.io/docs/introduction/first_steps/

Prometheus basics: https://prometheus.io/docs/tutorials/getting_started/

Prometheus installation guide: https://prometheus.io/docs/prometheus/latest/installation/

Prometheus installation varies depending on if you are running a container or software that will run on a system outside of the cluster. In this demo I only cover running prometheus as a service inside the EKS cluster.

We can install prometheus as either a standalone manually or using terraform and automatically install prometheus.

# Prometheus Installation (standalone)
Prerequisites: 
    - Helm needs to be installed on the management system that has cluster admin privileges.
    - kubeconfig configured for cluster administration priviliges.

1. Add prometheus helm charts to your local helm repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

2. Update the helm repository
helm repo update

3. Create a namespace in the EKS cluster for prometheus.
kubectl create namespace prometheus

[NOTE] 
You have the option to instead of running the kubectl command line to leverage a kubernetes manifest YAML file.

In your selected editor (e.g. VS Code, vim) create a file named prometheus-ns.yaml and input the content below:
 
apiVersion: v1
kind: Namespace
metadata:
  name: prometheus
  labels:
    name: prometheus

Save the file and install it by running the command:
kubectl apply -f prometheus-ns.yaml

4. Create a persistent storage volume for the prometheus software to store data.

Create a file named prometheus-storage-values.yaml and input the content below:
server:
  persistentVolume:
    storageClass: gp2
    size: 10Gi

alertmanager:
  persistence:
    storageClass: gp2


5. Install the prometheus service in the previously created "prometheus" namespace.
helm install prometheus prometheus-community/prometheus -n prometheus -f prometheus-storage-values.yaml

[NOTE] In this step we are pulling a prometheus container image from a public repository, creating a persistent storage claim (PVC) under the prometheus namespace.

6. Enable access to the Prometheus web portal.
Forward the port that prometheus is listening on:

kubectl port-forward -n monitoring deploy/prometheus-server 9090

# Prometheus Automated Installation
1. Uninstall any previous installations of prometheus
helm uninstall prometheus -n prometheus

2. Destroy existing namespace
kubectl delete namespace monitoring

3. Review the prometheus-values.yaml file under the folder /values for any settings you want to change.

4. Uncomment the prometheus.tf file

5. Task terraform to deploy the prometheus helm-chart
terraform validate
terraform plan
terraform apply -auto-approve

6. Verify the pods deploy successfully to the EKS cluster.
kubectl get pods -n prometheus

7. Access prometheus web interface.
