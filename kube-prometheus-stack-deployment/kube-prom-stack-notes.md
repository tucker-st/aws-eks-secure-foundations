# Prometheus, Grafana Stack Deployment Notes

In this project the default enabled deployment is to deploy Prometheus, Grafana and several other services in one single command to monitor the cluster.

[REFERENCE(s)] 

https://github.com/prometheus-community/helm-charts/

https://github.com/prometheus-operator/kube-prometheus

https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack

You have two options when installing the stack, manually or automatically leveraging terraform.

The default setup is to levarage terraform and automatically install the kube-prometheus-stack.

# Manual installation
1. Install Helm chart
helm repo 

2. Update Helm Repo

[NOTE] There are two sources for the kube-prometheus-stack either the OCI or github.io to obtain the required charts.

helm install [RELEASE_NAME] oci://ghcr.io/prometheus-community/charts/kube-prometheus-stack

OR helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

You will need to set the release version in [RELEASE_NAME]. You can identify the available versions by running the followiung command in helm

3. Get latest chart version so you can update the version in the prometheus-grafana-stack.tf file.

helm search repo kube-prometheus-stack

You should see an output similar to below: 

NAME                                             	CHART VERSION	APP VERSION	DESCRIPTION                                       
prometheus-community/kube-prometheus-stack       	77.1.0       	v0.85.0    	kube-prometheus-stack collects Kubernetes manif...



4. Install the stack in the EKS cluster.
helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace \
  -f values/kube-prom-values.yaml

5. Verify kubernetes cluster pod with kube-prom-stack is running

 kubectl get pods -n monitoring

NAME                                                        READY   STATUS    RESTARTS   AGE
alertmanager-kube-prometheus-stack-alertmanager-0           2/2     Running   0          85m
kube-prometheus-stack-grafana-6c54c4977b-l2nx2              3/3     Running   0          85m
kube-prometheus-stack-kube-state-metrics-85f6b56f69-mt6cs   1/1     Running   0          85m
kube-prometheus-stack-operator-654c48c757-k8vl5             1/1     Running   0          85m
kube-prometheus-stack-prometheus-node-exporter-2lt5h        1/1     Running   0          85m
kube-prometheus-stack-prometheus-node-exporter-7j7xf        1/1     Running   0          85m
kube-prometheus-stack-prometheus-node-exporter-zsv4m        1/1     Running   0          85m
prometheus-kube-prometheus-stack-prometheus-0               2/2     Running   0          85m

6. Identify services and ports for Grafana and Prometheus
 kubectl get svc -o wide -n monitoring

 NAME                                             TYPE           CLUSTER-IP       EXTERNAL-IP                                                                     PORT(S)                         AGE
alertmanager-operated                            ClusterIP      None             <none>                                                                          9093/TCP,9094/TCP,9094/UDP      87m
kube-prometheus-stack-alertmanager               ClusterIP      172.20.191.245   <none>                                                                          9093/TCP,8080/TCP               87m
kube-prometheus-stack-grafana                    LoadBalancer   172.20.239.93    k8s-monitori-kubeprom-42690d513e-ea376c7a206eed85.elb.us-east-1.amazonaws.com   80:31468/TCP                    87m
kube-prometheus-stack-kube-state-metrics         ClusterIP      172.20.213.34    <none>                                                                          8080/TCP                        87m
kube-prometheus-stack-operator                   ClusterIP      172.20.121.185   <none>                                                                          443/TCP                         87m
kube-prometheus-stack-prometheus                 LoadBalancer   172.20.155.57    k8s-monitori-kubeprom-9a99f72e9d-6b04627e991f1395.elb.us-east-1.amazonaws.com   9090:30385/TCP,8080:32610/TCP   87m
kube-prometheus-stack-prometheus-node-exporter   ClusterIP      172.20.103.142   <none>                                                                          9100/TCP                        87m
prometheus-operated                              ClusterIP      None             <none>                                                                          9090/TCP                        86m

7. Note the DNS names under EXTERNAL-IP as those are created when the service type is labeled as "LoadBalancer".


8. Obtain Grafana password. The default user name is admin

kubectl get secret --namespace monitoring kube-prometheus-stack-grafana  -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

You should see an output similar to below:

prom-operator

# Teardown

1. Uninstall the kube stack from the clusters namespace

    helm uninstall kube-prometheus-stack -n monitoring

2. Delete the namespace that was being used by the stack.

   kubectl delete namespace monitoring

# Automated installation
[NOTE] The default is for automated installation by terraform in this repository. The instructions below are in case earlier installations
were made using manual installations and the file was commened out.

1. Review the kube-prom-values.yaml file and make any revisions (if neccessary).

2. Uncomment the prometheus-grafana-stack.tf file (if neccessary) and update the version section (if required).

3. Task terraform to install the stack.
terraform validate
terraform plan
terraform apply -auto-approve

4. Verify kubernetes cluster pod with kube-prom-stack is running
 kubectl get pods -n monitoring

5. Identify DNS names for load balancers to access Grafana and Prometheus. You can also port forward either service to access them.

- Get the name of the Grafana and Prometheus services.

kubectl get svc -n monitoring | awk '{print $1}'

You should see an output similar to below:

NAME
alertmanager-operated
kube-prometheus-stack-alertmanager
kube-prometheus-stack-grafana
kube-prometheus-stack-kube-state-metrics
kube-prometheus-stack-operator
kube-prometheus-stack-prometheus
kube-prometheus-stack-prometheus-node-exporter
prometheus-operated

- Input the name of the service named kube-prometheus-stack-grafana and kube-prometheus-stack-prometheus as presented below:

echo "Grafana Dashboard: http://$(kubectl get svc kube-prometheus-stack-grafana -n monitoring -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'):80"


echo "Prometheus Server: http://$(kubectl get svc kube-prometheus-stack-prometheus -n monitoring -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'):9090"

6. Get the password for Grafana 
kubectl get secret --namespace monitoring kube-prometheus-stack-grafana  -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

7. Access the Grafana and Prometheus services via web browser.