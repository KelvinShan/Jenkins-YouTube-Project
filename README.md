# Build and Deploy a Modern YouTube Clone Application in React JS with Material UI 5

```sh
git clone 

terraform init
terraform plan
terraform apply -auto-approve

```
# Install necessary tools in jenkins
## Install AWS cli
```sh
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip
unzip awscliv2.zip
sudo ./aws/install
aws --version
```
## Install kubectl on jenkins
```sh
sudo apt update
sudo apt install curl -y
curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client
```
## Install eksctl on jenkins

```sh
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
cd /tmp
sudo mv /tmp/eksctl /bin
eksctl version
```
## Setup jenkins with terraform

```sh
cd terraform
terraform init
terraform plan 
terraform apply -auto-approve
```
## Install necessary tools and configure variable in Jenkins UI


## Setup kubernetes cluster with eksctl

```sh
eksctl create cluster --name youtube-cluster \
--region ap-southeast-1 \
--node-type t2.small \
--nodes 3

##update config
aws eks update-kubeconfig --name youtube-cluster --region ap-southeast-1

#Verify Cluster with below command
kubectl get nodes
kubectl get svc
```

# 🚀 CI/CD Pipeline with GitHub Actions

This repository uses **GitHub Actions** to implement a full CI/CD pipeline, including:

- ✅ Code checkout
- 📦 Dependency installation
- 🔎 SonarQube static code analysis
- 🔐 Trivy vulnerability scanning (filesystem & image)
- 🐳 Docker build & push to Docker Hub
- ☸️ Kubernetes deployment to EKS
- 📧 Email notifications on pipeline result (optional)

---

## 🔧 Prerequisites

### 1. 🔐 Set GitHub Secrets

Go to your repository → **Settings → Secrets → Actions**, and add the following secrets:

| Secret Name              | Description                                                  |
|--------------------------|--------------------------------------------------------------|
| `DOCKERHUB_USERNAME`     | Your Docker Hub username                                     |
| `DOCKERHUB_TOKEN`        | Your Docker Hub [access token](https://hub.docker.com/settings/security) |
| `SONAR_TOKEN`            | Your SonarQube user or project token                         |
| `SONAR_HOST_URL`         | URL to your SonarQube server (e.g., `https://sonarqube.my.com`) |
| `AWS_ACCESS_KEY_ID`      | AWS IAM Access Key (with EKS & ECR permissions)              |
| `AWS_SECRET_ACCESS_KEY`  | AWS IAM Secret Access Key                                    |
| `KUBECONFIG_BASE64`      | Base64 encoded kubeconfig for EKS cluster                    |
| `EMAIL_USER`             | Sender email address for notifications (optional)            |
| `EMAIL_PASS`             | Email SMTP password or app password (Gmail, etc.) (optional) |

### 🔑 How to Get `KUBECONFIG_BASE64`

```bash
cat ~/.kube/config | base64
```
