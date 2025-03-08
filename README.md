# Dog Gif App  

## Overview  ******************
This project presents a **flask-based dockerized web-app** integrated in **GitHub Actions** Flow for CI/CD automation. The app dynamically serves a random dog GIF from a **dockerized MySQL database** every time the page is refreshed. It also keeps track of visitor count by another **MySQL** table. The GitHub Actions flow ensures every code update is **built and pushed** to Docker Hub, then **tested** with docker compose and is **deployed to a K8S cluster**. To manage the infrastructure efficiently, **Terraform** is used to provision the **Google Kubernetes Engine (GKE) cluster** as part of IaC implementation. Additionally, **Helm** is used for managing Kubernetes deployments, making it easier to deploy, update, and maintain the applications in this project, adding **Prometheus, Grafana and Loki** as monitoring & logging tools. Recently integrated **ArgoCD**.

### Features
- **Flask Web Application**: lightweight python web-app.
- **GitHub Actions CI/CD**: automated build-test-deploy.
- **MySQL DB:** storing and managing data efficiently. 
- **Docker Support** containerized deployment.
- **Cloud Integration**: deployment to GCP.
- **Infrastructure as Code**: terraform for cloud provisioning - a GKE cluster.
-  **Kubernetes Deployment:** containerized apps orchestration tool with automated scaling and high availability.
- **Monitoring & Logging**: integrated Prometheus, Grafana, and Loki for observability.

---
## Project Flow Chart
![Flask](images/flask.drawio.png)

### **CI/CD Flow Breakdown**  *********************

Below is a high-level overview of how the flask app functions from development to deployment:

1. **Code Push & CI/CD Pipeline Trigger**  
   When new code is pushed to the app/ path in the repository, GitHub Actions automatically detects the change and triggers the CI/CD pipeline. This ensures that every update follows a structured, automated deployment process.  

2. **Building the Docker Image**  
   The pipeline starts by building a new Docker image of the flask application. This image encapsulates all necessary dependencies and configurations, along with the updated code, ensuring a consistent runtime environment across deployments. The Dockerfile is used as a "recipe" to pack the flask app as a working docker- image.    

3. **Pushing the Image to Docker Hub**  
   Once the Docker image is successfully built, it is pushed to Docker Hub, a public cloud container registry. Storing the image in Docker Hub will allow pulling it later on. Each flow run has a different github run-number used to tag the image that is pushed on every run. This way its easy to pull the image later by specifying its version, enabling stable version - management. 

4. **Testing with Docker Compose**  
   Before deploying to the production environment, a local test is executed using Docker Compose. This ensures that the containerized application runs as expected with no critical errors - before being deployed to the Kubernetes cluster. The test includes a curl to the flask app in order to verify the application is running correctly, sending a HTTP request to the app exposed port, 5000. to verify that the updated code doesn’t break the application's functionality.

5. **Updating the Helm Chart**  
   After passing the test phase, the pipeline then uses Helm, a package manager for Kubernetes. Helm defines the application's infrastructure and configuration settings that will be deployed to the cluster as kubernetes manifests. Before packing, the github run-number, that is the same number in which the updated docker image is tagged - is inserted to the chart to ensure that later this image will be used to install/upgrade the helm release. The updated chart is packed and pushed to github pages helm repository. This step ensures that the latest updated chart is always available to install for deployment.

6. **Infrastructure Provisioning with Terraform**  
   Terraform manages the Kubernetes infrastructure by provisioning and maintaining the GKE (Google Kubernetes Engine) cluster, ensuring scalability and consistency. The tfstate file, which tracks resource states, is stored remotely in an S3 backend for centralized state management. To prevent conflicts in concurrent deployments, Terraform uses DynamoDB for state locking, ensuring only one operation modifies the infrastructure at a time.

7. **Deploy to Kubernetes**
   Once the infrastructure is set up, Helm deploys or upgrades a release in the Kubernetes cluster using the latest Helm chart version, which includes the newly built image. Since the Chart.yaml version is incremented and the updated image tag is pushed to values.yaml on every run, helm upgrade ensures that the new release is fully applied, replacing outdated resources with the latest configuration and container image.  When new code is pushed, the CI/CD pipeline rebuilds the Docker image and updates the deployment via Helm. If issues occur, previous versions can be rolled back using Helm.  

8. **Exposing Metrics with Prometheus & Grafana**  
   Prometheus and Grafana are installed using Helm. Once deployed, the application not only serves random dog GIFs but also exposes Prometheus-compatible metrics. These metrics include visitor counts and other key performance indicators, allowing real-time monitoring of the application's usage, health and stats. Prometheus continuously scrapes the application's exposed metrics, providing real-time insights into its behavior. These insights are visualized using monitoring tool Grafana, which is allowing a graphical user-friendly performance analysis.  

9. **Continuous Logging and Issue Detection with Loki**
Loki, a log aggregation system designed for Kubernetes, is deployed using Helm to enhance observability.
Once deployed, Loki collects logs from the running application and other Kubernetes components, allowing for centralized log storage and easy retrieval. These logs are then accessible through Grafana, enabling real-time log analysis, troubleshooting, and debugging. This way, the system ensures that any errors, anomalies, or unexpected behaviors in the application can be quickly identified and addressed, improving reliability and maintainability.  

* **If new code is pushed to charts directory where the flask app helm chart is, the CI skips the docker app build and does only Helm CI, then CD.**

**This pipeline ensures that every code change is built, tested, validated, and deployed automatically while maintaining observability and infrastructure consistency. This flow ensures a fully automated, scalable, and monitored deployment of the flask app in the Kubernetes cluster on GCP.**

---

## 📦 Setup Instructions 

To use this project, you need to **configure all required secrets and variables** in your GitHub repository's **Actions > Secrets > Repository secrets / variables** section.  
Go to **GitHub Actions → Secrets** and add the following secrets.

### 🔑 Required Secrets  

#### GitHub Secrets:
- `dockeruser`: Docker username for login.
- `dockertoken`: Docker token (password) for login.
- `MYSQL_PASSWORD`: MySQL password for authentication.
- `MYSQL_ROOT_PASSWORD`: MySQL root password.
- `HELM_REPO_PAT`: Personal Access Token for Helm repository access.
- `AWS_ACCESS_KEY_ID`: AWS credentials for accessing S3 and other AWS services.
- `AWS_SECRET_ACCESS_KEY`: AWS secret key for S3 and other AWS services.
- `GCP_SA_KEY`: Google Cloud Service Account Key for GCP access.
- `GCP_PROJECT_ID`: Google Cloud Project ID.
- `GCP_CLUSTER_NAME`: Google Cloud Kubernetes cluster name.
- `GCP_ZONE`: Google Cloud zone for the Kubernetes cluster.

#### GitHub Variables:
- `FLASK_ENV`: Environment for Flask (e.g., development or production).
- `MYSQL_HOST`: Host for the MySQL database.
- `MYSQL_USER`: MySQL user.
- `MYSQL_DATABASE`: The MySQL database name.
- `PORT`: Port for Flask to run on.
- `IMAGE_TAG`: Docker image tag, generated dynamically based on the GitHub run number.
- `IMAGE_NAME`: Docker image name (`crazyguy888/catexer-actions`). 

After configuring these secrets and variables, the GitHub Actions pipeline will be able to **build, test, push, and deploy** the application automatically.  

---

## 🐳 Docker  

The app is **containerized** using Docker, allowing it to be easily deployed in any environment.  

### 🔹 Dockerfile  

The **Dockerfile** defines how the Flask app is packaged:  
- Installs dependencies and Flask runtime.  
- Copies the application files into the container.   
- Configures the web server to serve the app.  

### 🔹 Docker Compose  

A **docker-compose.yml** file is included to facilitate **local testing** before deployment. It allows running the app along with its database locally.  
To test locally:  

```sh
docker compose up --build
```

After startup, you can verify the app is running using curl. Don't forget to include .env.

---

## 🌍 Infrastructure as Code (Terraform)  

Terraform is used to **provision and manage** the Kubernetes infrastructure on **GCP**.  

- **Google Kubernetes Engine (GKE)** is created using Terraform.  
- **AWS S3 is used as the Terraform backend** to store the infrastructure state remotely.  
- **DynamoDB is configured** to enable state locking and prevent conflicts.  

To deploy the infrastructure:  

```sh
terraform init
terraform apply
```

---

## ☸️ Kubernetes & Helm  ***************

In this project, Kubernetes (k8s) is used for orchestrating the deployment and management of the flask app. It helps ensure scalability, load balancing, and fault tolerance by running the application in containers across multiple nodes. Kubernetes manages the deployment lifecycle, automates rollouts and rollbacks, and integrates with monitoring tools like Prometheus and Grafana for observability. The application is deployed in **Kubernetes (K8s) using Helm**, which simplifies and standardizes the deployment process. **Helm** acts as a package manager for Kubernetes, allowing for easy installation, upgrades, and rollbacks of the application. Kubernetes ensures high availability and manages scaling.  The application is deployed and managed in a Kubernetes cluster, ensuring high availability & scalability for a seamless production environment. Helm is used for the Kubernetes deployments. Runs and manages the flask app in a scalable and automated way. helm Simplifies Kubernetes deployments by packaging configurations and managing updates efficiently.

### 🔹 How Helm is Used in This Project  

- **Application Deployment**: Helm templates are used to define Kubernetes manifests for the Flask app, ensuring consistent deployment across environments.  
- **Environment Configuration**: Helm values allow customization of deployment settings, such as resource limits, replica counts, and environment variables.
- **Service Exposure**: A Kubernetes **Service** is defined to expose the application and allow external access.   
- **Automated Updates**: The CI/CD pipeline uses Helm to automatically deploy the latest version of the app whenever a new image is built and pushed to Docker Hub.  

### 🔹 Deploying with Helm  

Helm is used to deploy the Flask application to Kubernetes. The repository includes a Helm chart to manage application deployment.
To install the application using Helm:  

```sh
helm repo add catexer-repo <your-helm-repo-url>
helm install $HELM_RELEASE_NAME catexer-repo/helm-flask
```

To uninstall the application:  

```sh
helm uninstall $HELM_RELEASE_NAME -n $NAMESPACE
```

---

## Monitoring and Logging: Prometheus, Grafana & Loki **************

To ensure application performance monitoring and effective debugging, Those tools are integrated: Prometheus for metrics collection, Grafana for visualization, and Loki for log aggregation.
- **Prometheus**: Collects application and infrastructure metrics.
  - **Grafana**: Visualizes data through dashboards.
  - **Loki**: Collects and stores logs for easy querying and analysis.

### Prometheus
Prometheus collects metrics from the Flask application and provides insights into request durations, error rates, and system performance. Ensure that the application exposes an endpoint (e.g., `/metrics`) for Prometheus to scrape data.

### Grafana
Grafana connects to Prometheus as a data source, providing real-time dashboards for monitoring key metrics.

### Loki
Loki centralizes logs from the Flask application, making it easier to query and analyze application behavior.
Loki collects and aggregates logs, offering seamless log monitoring.   

---

## 🧹 Cleanup  

To keep the environment clean and avoid unnecessary storage costs, two cleanup scripts are included in the project:

### 🗑️ Docker Hub Tag Cleanup  
Over time, Docker tags can accumulate in Docker Hub, leading to clutter and storage issues. The `docker-clean.sh` script removes outdated tags to keep the repository clean. The script Fetches current tags from Docker Hub using the Docker API, then Compares tag creation dates and deletes tags older than **7 days**. You can adjust the time threshold to delete tags based on your current preferences.

**How to use:**  
```bash  
bash cleanups/docker-clean.sh  
```  
> **Note:** Ensure that `DOCKER_USER`, `DOCKER_REPO`, and `DOCKERTOKEN` are set as environment variables for authentication.

### 🗑️ Helm Chart Cleanup  
Helm charts used for deployments can accumulate over time in the helm-repo. The `helm-clean.sh` script removes older chart versions from a Helm repository hosted on GitHub Pages. The script clones the helm-repo and restores original file modification times, then lists `.tgz` files and deletes older versions, keeping only the latest **3** files. Finally, it rebuilds the `index.yaml` and pushes changes to the helm-repo.  

**How to use:**  
```bash  
bash cleanups/helm-clean.sh  
```  
> **Note:** Ensure `HELM_REPO_PAT` is set as an environment variable for GitHub authentication, using PAT to clone the repo inside runner.

---

## Security Considerations

Ensuring security best practices is crucial to protect the application from vulnerabilities.
In this project a couple of security measures are used to ensure that:

- **GitHub Secrets:** Used for CI/CD pipeline credentials such as Docker and GitHub tokens, ensuring sensitive information isn't exposed.
- **Kubernetes Secrets:** Database credentials are stored securely in base64-encoded Kubernetes secrets.
- **Git and Docker Ignorance:** .gitignore and .dockerignore files prevent sensitive or unnecessary files from being tracked or added to Docker images.

**( In early stages of this project an .env file was used to run docker compose locally & for testing )**

---
## Future Improvements

- **SSL ( HTTPS ):** SSL encryption, securing data transmission & ensuring that all communications are encrypted.
- **Vault:** managing secrets and particularly db passwords in whole project.
---
