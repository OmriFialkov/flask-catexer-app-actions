# Dog Gif App  

## Overview
This project presents a **Flask-based web app** containerized with **Docker** which is deployed to a **GCP Kubernetes cluster**. It dynamically serves random dog GIFs and tracks visitor counts using **MySQL**. A complete CI/CD pipeline powered by **GitHub Actions** builds the app, tests it with **Docker Compose**, and deploys it via **Helm**, while **Terraform** provisions the GKE cluster. Integrated observability is achieved with **Prometheus**, **Grafana**, **Loki**. Recently added continuous delivery through **ArgoCD**.

### Key Components:
- **Flask Web Application**: lightweight python web-app.
- **MySQL DB:** Storing and managing data efficiently ( GIFS & Visitor Count )
- **GitHub Actions CI/CD**: Automates the build, test, and deployment process of the flask app.
- **Docker Support** Packages the app and its dependencies into a container.
- **Terraform**: Provisions cloud infrastructure, the GKE cluster.
- **K8S Deployment:** containerized apps orchestration tool with automated scaling and high availability.
- **Helm** – Manages Kubernetes deployments, simplifying upgrades and maintenance.
- **Prometheus** – Monitors application metrics.  
- **Grafana** – Provides visualization and dashboards for monitoring data.  
- **Loki** – Centralizes and stores application logs for easy analysis.  
- * **ArgoCD** – Provides GitOps-based CD to the K8S cluster.

This setup ensures the app is scalable, highly available, and easy to monitor.

---
## Project Flow Chart
![Flask](images/flask.drawio.png)

### **CI/CD Flow Breakdown**  

Below is a high-level overview of how the flask app functions from development to deployment:

1. **Code Push & CI/CD Pipeline Trigger**  
   When new code is pushed to the app/ path in the repository, GitHub Actions automatically detects the change and triggers the CI/CD pipeline. This ensures that every update follows a structured, automated deployment process.  

2. **Building the Docker Image**  
   The pipeline starts by building a new Docker image of the flask application. This image encapsulates all necessary dependencies and configurations, along with the updated code, ensuring a consistent runtime environment across deployments.     

3. **Pushing the Image to Docker Hub**  
   Once the Docker image is successfully built, it is pushed to Docker Hub, which will allow pulling it later on. Each flow run has a different github run-number used to tag the pushed image in each run. This way its easy to pull the image later by specifying its version, enabling stable version - management. 

4. **Testing with Docker Compose**  
   Before deploying to the production environment, a local test is executed using Docker Compose. The test includes a curl to the flask app in order to verify that the updated code doesn’t break the application's functionality, sending a HTTP request to the app exposed port, 5000. It ensures the app is stable before it is deployed to the Kubernetes cluster.

5. **Updating the Helm Chart**  
   The pipeline then uses helm to define the application's infrastructure and configuration settings that will be deployed to the cluster as kubernetes manifests. Before packing, the same run-number in which the updated docker image is tagged - is inserted to the chart's values.yaml. This ensures that later this image will be used to install/upgrade the helm release. The updated chart is then pushed to github-pages helm-repo. This way the latest updated chart is available to install for deployment.

6. **Infrastructure Provisioning with Terraform**  
   Terraform manages the Kubernetes infrastructure by provisioning and maintaining the GKE (Google Kubernetes Engine) cluster. The tfstate file, which tracks resource states, is stored remotely in an S3 backend for centralized state management. To prevent conflicts in concurrent deployments, Terraform uses DynamoDB for state locking, ensuring only one operation modifies the infrastructure at a time.

7. **Deploy to Kubernetes**
   After infrastructure is set up, helm deploys or upgrades a release in the Kubernetes cluster using the latest helm chart. Since the Chart.yaml version is incremented and the updated image tag is pushed to values.yaml on every run, helm upgrade ensures that the new release is fully applied, replacing outdated resources with the latest configuration and container image.    

8. **Exposing Metrics with Prometheus & Grafana**  
   Prometheus and Grafana are installed using Helm. Once deployed, the application not only serves random dog GIFs but also exposes Prometheus-compatible metrics. These metrics include visitor counts and other key performance indicators, allowing real-time monitoring of the application's usage & health. Prometheus continuously scrapes the application's exposed metrics, providing real-time insights which are visualized using Grafana, allowing a graphical analysis.    

9. **Continuous Logging and Issue Detection with Loki**
Loki is deployed using Helm to enhance observability. Once deployed, Loki collects logs from the running application and other Kubernetes components, allowing for centralized log storage and easy retrieval. These logs are then accessible through Grafana, enabling real-time log analysis. This way, the system ensures that any errors or anomalies can be quickly identified, improving reliability and maintainability.   

**This flow ensures that every code change is built, tested & deployed automatically while maintaining observability, scalability and infrastructure consistency.**  
( If new code is pushed to charts directory where the flask app helm chart is, the CI skips the docker app build and does only helm chart update, then CD )   

---

## 📦 Setup Instructions 

To use this project, you need to **configure all required secrets and variables** in your GitHub repository's **Actions > Secrets > Repository secrets / variables** section.  
Go to **GitHub Actions → Secrets** and add these -
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

The app is **containerized** using Docker, allowing it to be **easily deployed** in any environment.  

### 🔹 Dockerfile  

The **Dockerfile** defines how the Flask app is packaged:  
- Installs dependencies and Flask runtime.  
- Copies the application files into the container.   
- Configures the web server to serve the app.

In this project, the Dockerfile is used as a "recipe" to pack the flask app as a working docker-image.

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

## ☸️ Kubernetes & Helm  

Kubernetes is used for orchestrating the deployment and management of the flask app. The app is deployed and managed in a cluster, ensuring high availability & scalability for a seamless production environment. It helps ensure load balancing, and fault tolerance by running the application in containers across multiple nodes. Kubernetes manages the deployment lifecycle, automates rollouts and rollbacks, and integrates with monitoring tools like Prometheus and Grafana for observability.

The application is deployed in **Kubernetes (K8s) using Helm**, which simplifies and standardizes the deployment process. **Helm** acts as a package manager for Kubernetes, allowing installation, upgrades, and rollbacks of the application. It simplifies Kubernetes deployments by packaging configurations and managing updates efficiently.

### 🔹 How Helm is Used in This Project  

- **Application Deployment**: Helm templates are used to define Kubernetes manifests for the Flask app, ensuring consistent deployment across environments.  
- **Environment Configuration**: Helm values allow customization of deployment settings, such as resource limits, replica counts, and environment variables.
- **Service Exposure**: A Kubernetes **Service** is defined to expose the application and allow external access.   
- **Automated Updates**: The CI/CD pipeline uses Helm to automatically deploy the latest version of the app whenever a new image is built and pushed to Docker Hub.  

### 🔹 Deploying with Helm  

This repository includes a Helm chart to manage application deployment.
To install / uninstall the application using Helm:  

```sh
helm repo add catexer-repo <your-helm-repo-url>
helm install $HELM_RELEASE_NAME catexer-repo/helm-flask
```
```sh
helm uninstall $HELM_RELEASE_NAME -n $NAMESPACE
```
---

## Monitoring and Logging: Prometheus, Grafana & Loki  

To ensure application performance monitoring and effective debugging & observability, Those tools are integrated: Prometheus for metrics collection, Grafana for visualization, and Loki for log aggregation.  

### Prometheus
A pull-based monitor tool. Prometheus collects metrics from the Flask application and provides insights into request durations, error rates, and system performance. In this project, the application exposes an endpoint (/metrics) for Prometheus to scrape data.

### Grafana
Grafana connects to Prometheus as a data source, providing real-time dashboards for monitoring key metrics. It visualizes data through dashboards.

### Loki
Loki centralizes logs from the Flask application and the apps running on the cluster ( pull based ), making it easier to query and analyze application behavior. It stores logs, offering seamless log monitoring and easy access. 

---

## 🧹 Cleanup  

To keep the environment clean and avoid unnecessary storage costs, two cleanup scripts are included in the project:

### Docker-Hub Tag Cleanup  🗑️
Over time, Docker tags can accumulate in Docker Hub, leading to clutter and storage issues. The `docker-clean.sh` script removes outdated tags to keep the repository clean. The script Fetches current tags from Docker Hub using the Docker API, then Compares tag creation dates and deletes tags older than **7 days**. You can adjust the time threshold to delete tags based on your current preferences.

> **Note:** Ensure that `DOCKER_USER`, `DOCKER_REPO`, and `DOCKERTOKEN` are set as environment variables for authentication.

### Helm Chart Cleanup 🗑️ 
Helm charts used for deployments can accumulate over time in the helm-repo. The `helm-clean.sh` script removes older chart versions from a Helm repository hosted on GitHub Pages. The script clones the helm-repo and restores original file modification times, then lists `.tgz` files and deletes older versions, keeping only the latest **3** files. Finally, it rebuilds the `index.yaml` and pushes changes to the helm-repo.  

> **Note:** Ensure `HELM_REPO_PAT` is set as an environment variable for GitHub authentication, using PAT to clone the repo inside runner.

**How to Use:**  
```bash  
bash cleanups/docker-clean.sh / bash cleanups/helm-clean.sh
```
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
