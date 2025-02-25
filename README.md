# 🐶 Dog Gif App  

This project is a **Flask-based dockerized web-app** that dynamically serves a **random dog GIF** from a **dockerized MySQL database** every time the page is refreshed. It also keeps track of visitor count and exposes it, along with many other performance metrics, as Prometheus-compatible metrics for monitoring. The python application is designed for **containerized deployment** and runs on a **Kubernetes cluster** in **Google Cloud**. The entire deployment process is automated through a **CI/CD pipeline using GitHub Actions**, ensuring that every code update is **built and pushed to Docker Hub**, then tested locally using docker compose and is deployed to the Kubernetes cluster. To manage the infrastructure efficiently, **Terraform** is used to provision the **Google Kubernetes Engine (GKE) cluster**, while **AWS S3 and DynamoDB** are leveraged for Backend-Terraform state management. Additionally, **Helm** is used widely for managing Kubernetes deployments, making it easier to deploy, update, and maintain the applications in this project, including monitoring and logging helm charts as well. 

---
## Project Flow Chart
![Flask](Images/flask.png)
### Breakdown:

when a

---

## 📦 Getting Started  

To use this project, you need to **configure all required secrets and variables** in your GitHub repository's **Actions > Secrets > Repository secrets / variables** section.  

### 🔑 Required Secrets  

Go to **GitHub Actions → Secrets** and add the following secrets:  

- `DOCKER_USERNAME` – Your Docker Hub username.  
- `DOCKER_PASSWORD` – Your Docker Hub password or access token.  
- `GCP_CREDENTIALS` – A **Google Cloud service account key** in JSON format for authentication.  
- `AWS_ACCESS_KEY_ID` – AWS access key for Terraform backend.  
- `AWS_SECRET_ACCESS_KEY` – AWS secret key for Terraform backend.  

### ⚙️ Required Variables  

In **GitHub Actions → Variables**, add the following variables:  

- `DOCKER_REPO` – The name of your **Docker Hub repository** where images will be pushed.  
- `GKE_CLUSTER_NAME` – The **name of your Kubernetes cluster** in GCP.  
- `PROJECT_ID` – Your **Google Cloud project ID**.  
- `REGION` – The **GCP region** where the cluster is deployed.  
- `HELM_RELEASE_NAME` – The **name of the Helm release** used for deployment.  
- `PROMETHEUS_NAMESPACE` – The **Kubernetes namespace** for Prometheus monitoring.  

After configuring these secrets and variables, the GitHub Actions pipeline will be able to **build, test, push, and deploy** the application automatically.  

---

## 🐳 Docker  

The app is **containerized** using Docker, allowing it to be easily deployed in any environment.  

### 🔹 Dockerfile  

The **Dockerfile** defines how the Flask app is packaged:  
- Installs dependencies and Flask runtime.  
- Copies the application files into the container.  
- Sets up the necessary environment variables.  
- Configures the web server to serve the app.  

### 🔹 Docker Compose  

A **docker-compose.yml** file is included to facilitate **local testing** before deployment. It allows running the app along with its database locally.  

To test locally:  

```sh
docker compose up --build
```

After startup, you can verify the app is running using:  

```sh
curl http://localhost:5000
```

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

The application is deployed in **Kubernetes (K8s) using Helm**, which simplifies and standardizes the deployment process. **Helm** acts as a package manager for Kubernetes, allowing for easy installation, upgrades, and rollbacks of the application.  

### 🔹 How Helm is Used in This Project  

- **Application Deployment**: Helm templates are used to define Kubernetes manifests for the Flask app, ensuring consistent deployment across environments.  
- **Service Exposure**: A Kubernetes **Service** is defined to expose the application and allow external access.  
- **Environment Configuration**: Helm values allow customization of deployment settings, such as resource limits, replica counts, and environment variables.  
- **Prometheus Integration**: The deployment includes configuration for exposing metrics, which are scraped by **Prometheus** for monitoring.  
- **Automated Updates**: The CI/CD pipeline uses Helm to automatically deploy the latest version of the app whenever a new image is built and pushed to Docker Hub.  

### 🔹 Deploying with Helm  

To install the application using Helm:  

```sh
helm install $HELM_RELEASE_NAME ./helm-chart --namespace $PROMETHEUS_NAMESPACE
```

To upgrade the application after making changes:  

```sh
helm upgrade $HELM_RELEASE_NAME ./helm-chart
```

To uninstall the application:  

```sh
helm uninstall $HELM_RELEASE_NAME --namespace $PROMETHEUS_NAMESPACE
```

---

## 🔄 Application Flow  

Below is a high-level overview of how the Flask Catexer app functions from development to deployment:  

1. **Development**: Developers work on the Flask application locally and test it using Docker Compose.  
2. **CI/CD Pipeline**:  
   - Code is pushed to GitHub.  
   - GitHub Actions trigger a build process.  
   - The Flask application is built as a Docker image and pushed to Docker Hub.  
3. **Kubernetes Deployment**:  
   - The latest Docker image is pulled from Docker Hub.  
   - Helm deploys the application to the GKE cluster.  
   - Kubernetes ensures high availability and manages scaling.  
4. **Monitoring**:  
   - The application exposes **Prometheus-compatible metrics**.  
   - Prometheus scrapes the metrics, providing real-time insights.  
5. **Automatic Updates & Rollbacks**:  
   - When new code is pushed, the CI/CD pipeline rebuilds the Docker image and updates the deployment via Helm.  
   - If issues occur, previous versions can be rolled back using Helm.  

This flow ensures a **fully automated, scalable, and monitored deployment** of the Flask Catexer app in a **Kubernetes cluster on Google Cloud**.  

---

## 🧹 Cleanup  

To keep the environment clean and avoid unnecessary storage costs, several cleanup processes are included in the project:  

### 🗑️ Docker Hub Image Cleanup  

Over time, multiple Docker images can accumulate in **Docker Hub**, leading to unnecessary storage usage. To manage this, a **Docker Hub tags cleanup script** is included in the `cleanups/` directory. This script helps **remove outdated or untagged images** to keep your repository organized.  

To execute the cleanup script:  

```sh
bash cleanups/docker-hub-cleanup.sh
```

Ensure you have **Docker Hub credentials** set up to authenticate with the Docker API before running the script.  

### 🗑️ Helm Chart Cleanup in GitHub Pages Helm Repo  

Helm charts used for deploying the application are stored in a **Helm repository hosted on GitHub Pages**. Over time, as updates are made, older chart versions can accumulate, leading to clutter and unnecessary storage usage.  

To clean up old Helm chart versions, a **bash script is provided in the `cleanups/` directory**. This script:  

- Fetches a list of all Helm chart versions stored in the GitHub Pages repo.  
- Identifies older versions based on a retention policy (e.g., keep only the latest N versions).  
- Removes outdated charts to free up space while ensuring recent versions remain available for deployments.  

To execute the Helm chart cleanup script:  

```sh
bash cleanups/helm-repo-cleanup.sh
```

This helps maintain a **lean and organized Helm repository** while ensuring that deployments always use the most recent stable versions of the charts.  

---
