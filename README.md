# Gorgias Challenge

## Requirements

- `gcloud` command line logged into Google account. Tested with `Google Cloud SDK 311.0.0`
- `kubectl` - tested with `Client Version: version.Info{Major:"1", Minor:"19", GitVersion:"v1.19.2", GitCommit:"f5743093fd1c663cb0cbc89748f730662345d44d", GitTreeState:"clean", BuildDate:"2020-09-16T21:51:49Z", GoVersion:"go1.15.2", Compiler:"gc", Platform:"darwin/amd64"}`

## Install

Execute the following:

```bash
start.sh
```

Can also be deployed locally with Docker Desktop Kuberentes or minikube. `kubectl apply -R -f kube` to deploy once the local context is set. The external load balancer won't work locally, so `kubectl port-forward svc/flask 5000:http` will start the network connection, then browse to `http://localhost:5000`.

## Todo app

Modified guides from [https://github.com/cockroachdb/examples-python](https://github.com/cockroachdb/examples-python) and [https://realpython.com/flask-by-example-part-2-postgres-sqlalchemy-and-alembic/](https://realpython.com/flask-by-example-part-2-postgres-sqlalchemy-and-alembic/)

Application is built and pushed with `docker-compose` to Docker Hub. Can be built and executed locally with `docker-compose up`.

## Architecture

`start.sh` script creates a 4-node cluster across `us-central1-a` and `us-central1-b` regions in GCP. Deploys kubernetes objects, waits until they're available, then launches a browser to the load-balancer for accessing the application.

## Value added

Some improvements were made above the original specifications:

- Postgres statefulset runs in HA with repmgr managing database cluster, replication, and monitoring a hot-standby
- PgPool is used to proxy connections to the Postgres database and load-balance queries. Write queries will go to primary node, while read queries go to the standby
- Used a Kubernetes job to perform database migration. At first considered using an init-container in the deployment, but a Job is easier to monitor and a better pattern for production deployments
- Pod anti-affinity rules are used to distribute pods across multiple hosts for increased resilience of workloads

## Improvements to Implement

Postgres database and Flask app are applied to the `default` namespace in Kubernetes. This could be deployed to a different namespace with `kustomize` overrides or Helm chart templating. Helm would needed to automate config file changes to Postgres cluster in scaling up or down the statefulset.

Pod disruption budget could be added to deployments and/or statefulsets in order to improve cluster administration. Nodes can be maintenanced and taken out of service without impacting application and service availability.
