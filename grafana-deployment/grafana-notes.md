# Grafana Installation with Helm

To install Grafana we have two options, either as a standalone service or with Prometheus.

In this guide I will provide basic instructions for deploying grafana as a standalone application via command line and automatically leveraging terraform.

[REFERENCE(s)]

Grafana on AWS EKS
https://grafana.com/docs/grafana-cloud/monitor-infrastructure/kubernetes-monitoring/configuration/config-other-methods/config-aws-eks/

Grafana GitHub

https://github.com/grafana/grafana

Grafana Learning

https://learn.grafana.com/page/course-catalog

Grafana Best Practice Guides

https://learn.grafana.com/path/best-practice-guides

Grafana Technical Guide

https://grafana.com/docs/grafana/latest/?pg=oss-graf&plcmt=hero-btn-2


# Grafana (standalone)

1. Add Grafana Helm Repo
helm repo add grafana https://grafana.github.io/helm-charts

2. Update Helm Repo

helm repo update

3. Create namespace

kubectl create namespace monitoring

4. Install grafana

helm install grafana grafana/grafana --namespace monitoring

5. Verify kubernetes cluster pod with grafana is running

kubectl get pods -n monitoring

6. Port forward Grafana graphical user interface

kubectl port-forward -n monitoring deploy/grafana 80

7. Obtain Grafana password. The default user name is admin

kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

8. Access grafana page and input username: admin and the password.

# Grafana Teardown
1. Uninstall grafana
helm uninstall grafana -n monitoring

2. Delete the namespace
kubectl delete namespace monitoring

