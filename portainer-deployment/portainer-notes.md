# Install Portainer in EKS cluster

We will use the Portainer Community Edition leveraging helm charts.

[REFERENCE]
https://docs.portainer.io/start/install-ce/server/kubernetes/baremetal

1. Install the portainer repository
```
helm repo add portainer https://portainer.github.io/k8s/
```

2. Update Helm repo

```
helm repo update
```

3. You have three options when installing portainer, NodePort, Cloud Provider Loadbalancer and ClusterIP with an ingress.

For this deployment we will leverage a loadbalancer to connect to portainer versus using a ingress service.

[NOTE] Portainer requires persistent storage which by default may not be set in EKS. To ensure you have storage the default values.yaml file that was published with helm was downloaded and modified.

4.  Download the helm repo

 Instead of installing the helm chart, pull the Tape Archive (tar) file and untar it into a local folder.

```
helm pull --untar portainer/portainer
```
5. Move into the extracted archive  folder 

```
cd portainer
```

[NOTE] You should see a README and other files. The one we need is the values.yaml file.

6. Edit the values.yaml file and put it in a directory where helm can find it.


[CAUTION] Portainer has a security feature where when it is first deployed you must connect to its login page within 5 minutes. If you do not access the login page, you will have to uninstall and re-install portainer.

x Access the portainer webpage at the DNS name by running the commands below:

```
export SERVICE_IP=$(kubectl get svc --namespace portainer portainer --template "{{ range (index .status.loadBalancer.ingress 0) }}{{.}}{{ end }}")
```

```
echo https://$SERVICE_IP:9443
```

Portainer by default uses a self-signed certificate and leverages SSL. So you will have to accept the "known" error when attempting to connect to portainer.

7. Once you access the web page you will need to input a password for the default admin account. The minimum number of characters for the password will be on the dashboard.

[REFERENCE] https://docs.portainer.io/start/install-ce/server/setup

8. Portainer detects that it is in a Kubernetes cluster running on a node. To actually use Portainer reference the user guide at 

# Uninstall Portainer from EKS cluster

To delete the portainer installation from the cluster be sure to backup your data before deleting portainer.

1. Backup data from portainer (if required)
Reference portainer documentation to properly backup your data.

2. Delete Portainer from cluster

```
helm uninstall portainer -n portainer
```

3. Delete portainer loadbalancer

```
kubectl delete svc portainer -n portainer
```

4. Delete portainer namespace

```
kubectl delete namespace portainer
```