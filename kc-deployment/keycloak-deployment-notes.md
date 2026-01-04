
# Keycloak Deployment

We will use the development database configuration per the software developers basic deployment guide.

[REFERENCE]

https://www.keycloak.org/operator/basic-deployment


## Obtain official docker image of Keycloak and PostgreSQL

[REFERENCE]

https://www.keycloak.org/keycloak-benchmark/kubernetes-guide/latest/util/custom-image-for-keycloak

At this stage we will obtain docker container images from an official repository. You also have the option of building containers from scratch for keycloak at https://github.com/keycloak/keycloak/blob/main/docs/building.md.

To build a postgresql container from source can be found in references https://github.com/docker-library/postgres and https://github.com/docker-library/docs/tree/master/postgres. Your mileage may vary for postgresql as it is not a small project and the maintainers do a really good job at providing patched container images and hosting them on repositories like Docker hub.


1. Pull official docker image for Keycloak and PostgreSQL

2. Create folder for Keycloak and PostgreSQL on your local build system

3. In each folder create a docker file. In this repository there is an example Dockerfile *specifically* built to match this demonstration. I would recommend following known best practices for building container images that will be used in a kubernetes cluster.

## Create the customized Keycloak demonstration projects container images

Start Docker service

1. Login to private or public ECR repository following the repository instructions.
```
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin xxxxxxxxxxx.dkr.ecr.us-east-1.amazonaws.com
```

2. Build docker image for keycloak and postgresql.

```
docker build -t <image-name> .
```

[NOTE] On an ARM64 based system (e.g. MacOS) you will need to use buildx if using Docker.

```
docker buildx build . --platform=linux/amd64 -t  class06/postgresql-demo:latest --load
```

```
docker buildx build . --platform=linux/amd64 -t  class06/keycloak-demo --load
```


3. Tag the image so you can push the image to the repository. Replace the XXXX block with the information provided in the AWS ECR instructions.

```
docker tag class06/postgresql-demo:latest push XXXXXXXXXXXX.dkr.ecr.us-east-1.amazonaws.com/<repo-name>
```

4. Push the docker image to the AWS repository. Replace the XXXX block with the information provided in the AWS ECR instructions.

```
docker push XXXXXXXXXXXX.dkr.ecr.us-east-1.amazonaws.com/<repo-name>
```

## Deploy PostgreSQL database and Keycloak to EKS
For now we use manual method using kubectl to deploy the database and keycloak containers to the kubernetes cluster.

1. Create namespace 
In this demonstration we use the name that is also in all of the configurations which is keycloak-demo

```
kubectl create namespace keycloak-demo
```


2. Deploy PostgresQL

```
kubectl apply -f kc-deploymentdb/postgresql-pv.yaml
```
```
kubectl apply -f kc-deploymentdb/postgresql-pv-claim.yaml
```
```
kubectl apply -f kc-deploymentdb/postgresql-deployment.yaml
```
```
kubectl apply -f kc-deployment/db.postgresql-service.yaml
```

Verify postgresql is running and services are up

```
kubectl get deploy,svc,pod -n keycloak-demo
```

3. Deploy Keycloak

```
kubectl apply -f kc-deployment/keycloak/kc-deployment.yaml
```

```
kubectl apply -f kc-deployment/keycloak/keycloak-service.yaml
```


Verify keycloak is running and services are up.

```
kubectl get deploy,svc,pod -n keycloak-demo
```

If everything started successfully you should see in your console something similar to the below screenshot:

[NOTE] In this screenshot you should see all services, pods and deployments in the namespace keycloak-demo.

![kubectl info](/graphics/kubectl-get-svc-pod-deployments-pgsql.png)

## Access Keycloak page

This keycloak deployment uses a self-signed SSL certificate. So you will see an error when you first attempt to access the page as pictured below:

![keycloak ssl error](/graphics/keycloak-self-signed-cert-issue.png)

Until you provide your own legitimate SSL certificate the error will occur. Continue and allow connection and you should see the following login page:

![keycloak login](/graphics/keycloak-login-page.png)

1. Login to the keycloak administrator console with username admin and password admin.

2. Begin to configure keycloak by changing the administrator account. 

https://www.keycloak.org/server/configuration#_creating_the_initial_admin_user

[REFERENCE(s)] 

https://www.keycloak.org/guides#server

https://www.keycloak.org/securing-apps/overview

## Keycloak teardown

In this section we will tear down the demonstration keycloak and postgresql deployment. For all deployments using kubectl you will more than likely need to manually delete/uninstall the deployments.

[CAUTION] Back up any data you want to retain from your keycloak deployment as these instructions destroy the database and keycloak installations.

1. Delete keycloak deployment

```
kubectl delete -f kc-deployment/keycloak/kc-deployment.yaml
```

```
kubectl delete -f kc-deployment/keycloak/keycloak-service.yaml
```

2. Delete postgresql database and persistent storage.

```
kubectl delete -f kc-deployment/db/postgresql-deployment.yaml
```

```
kubectl delete -f kc-deployment/db/postgresql-service.yaml
```

```
kubectl delete -f kc-deployment/db/postgresql-pv-claim.yaml
```

```
kubectl delete -f kc-deployment/db/postgresql-pv.yaml
```

At this stage you can continue with other cluster maintenance actions (e.g. deployments, patching,teardown).