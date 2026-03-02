# Task 2 — CI/CD Pipeline: AWS CodePipeline + EKS

A complete CI/CD pipeline that builds, tests, and deploys a Node.js app to Kubernetes on AWS EKS, with automatic rollback on failure.

---

## Architecture

```
GitHub Push
    │
    ▼
┌─────────────────────────────────────────────────┐
│              AWS CodePipeline                   │
│                                                 │
│  Stage 1        Stage 2       Stage 3           │
│  ┌────────┐    ┌────────┐    ┌────────────┐     │
│  │ Source │───▶│  Test  │───▶│   Build    │     │
│  │GitHub  │    │npm test│    │Docker+ECR  │     │
│  └────────┘    └────────┘    └─────┬──────┘     │
│                                    │            │
│                             Stage 4│            │
│                          ┌─────────▼──────┐    │
│                          │    Deploy      │    │
│                          │  EKS + kubectl │    │
│                          │  + Rollback    │    │
│                          └────────────────┘    │
└─────────────────────────────────────────────────┘
```

---

## Repository Layout

```
.
├── app/
│   ├── index.js              # Node.js Express app
│   ├── index.test.js         # Jest tests
│   ├── package.json
│   └── Dockerfile            # Multi-stage Docker build
├── k8s/
│   ├── deployment.yaml       # K8s Deployment (RollingUpdate)
│   └── service.yaml          # K8s LoadBalancer Service
├── buildspec/
│   ├── buildspec-test.yml    # Stage 2: npm install & test
│   ├── buildspec-build.yml   # Stage 3: Docker build & ECR push
│   └── buildspec-deploy.yml  # Stage 4: kubectl apply + rollback
└── terraform/
    ├── main.tf               # All AWS infrastructure
    ├── variables.tf
    ├── outputs.tf
    └── terraform.tfvars      # ← update github_repo here
```

---

## Prerequisites

- AWS CLI configured (`aws configure`)
- Terraform ≥ 1.3
- A GitHub repository with this code pushed to it

---

## Step-by-Step Setup

### Step 1 — Push code to GitHub

Create a GitHub repo and push all files:

```bash
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
git push -u origin main
```

### Step 2 — Update tfvars

Edit `terraform/terraform.tfvars` and set your GitHub repo:

```hcl
github_repo = "your-username/your-repo-name"
```

### Step 3 — Deploy infrastructure

```bash
cd terraform
terraform init
terraform apply
```

This provisions: ECR, EKS cluster + node group, CodeBuild projects, CodePipeline, S3, IAM roles.

> ⚠️ EKS takes ~15 minutes to provision.

### Step 4 — Activate the GitHub Connection

After apply, go to:
**AWS Console → CodePipeline → Settings → Connections**

Find `webapp-github` → click **Update pending connection** → authorize GitHub.

This is a one-time manual step required by AWS.

### Step 5 — Trigger the pipeline

Push any change to your `main` branch:

```bash
git commit --allow-empty -m "Trigger pipeline"
git push
```

Watch it run in: **AWS Console → CodePipeline → webapp-pipeline**

### Step 6 — Get your app URL

After deploy succeeds:

```bash
aws eks update-kubeconfig --region us-east-1 --name webapp-cluster
kubectl get service webapp-service
```

Copy the `EXTERNAL-IP` and open it in your browser.

---

## Rollback Behaviour

The deploy buildspec automatically rolls back if `kubectl rollout status` fails within 180 seconds:

```bash
if ! kubectl rollout status deployment/webapp --timeout=180s; then
  kubectl rollout undo deployment/webapp   # ← instant rollback
  exit 1                                   # ← fails the pipeline stage
fi
```

This means:
- Bad deploy → auto rollback to last good version → pipeline marked as failed
- You can also manually rollback anytime: `kubectl rollout undo deployment/webapp`

---

## Destroy Everything

```bash
cd terraform
terraform destroy
```

---

## Pipeline Stages Summary

| Stage | Tool | What it does |
|---|---|---|
| Source | CodeStar + GitHub | Pulls code on every push to `main` |
| Test | CodeBuild | `npm ci` + `npm test` (Jest) |
| Build | CodeBuild | `docker build` + push to ECR |
| Deploy | CodeBuild | `kubectl apply` + rollback on failure |
