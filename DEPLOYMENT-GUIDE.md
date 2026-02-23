# Google Cloud Deployment Guide - Poker Application

## Prerequisites
1. Google Cloud account with billing enabled
2. Google Cloud SDK installed
3. Docker installed

## Quick Start - Manual Deployment

### Step 1: Install Google Cloud SDK (if not installed)
```bash
# macOS
brew install google-cloud-sdk

# Or download from:
# https://cloud.google.com/sdk/docs/install
```

### Step 2: Initialize and Login
```bash
# Initialize gcloud
gcloud init

# Login to your Google account
gcloud auth login

# Set your project (create one if needed)
gcloud config set project YOUR_PROJECT_ID
```

### Step 3: Enable Required APIs
```bash
gcloud services enable container.googleapis.com
gcloud services enable containerregistry.googleapis.com
gcloud services enable cloudbuild.googleapis.com
```

### Step 4: Build and Push Docker Images
```bash
cd /Users/new/Desktop/Poker-dist-assignment

# Get your project ID
PROJECT_ID=$(gcloud config get-value project)

# Build and push backend
gcloud builds submit --tag gcr.io/$PROJECT_ID/poker-backend:latest \
    --dockerfile=Dockerfile.backend .

# Build and push proxy  
gcloud builds submit --tag gcr.io/$PROJECT_ID/poker-proxy:latest \
    --dockerfile=Dockerfile.proxy .

# Build and push frontend
gcloud builds submit --tag gcr.io/$PROJECT_ID/poker-frontend:latest \
    --dockerfile=Dockerfile.frontend .
```

### Step 5: Create GKE Cluster
```bash
gcloud container clusters create poker-cluster \
    --zone=us-central1-a \
    --machine-type=e2-medium \
    --num-nodes=2 \
    --enable-autoscaling \
    --min-nodes=2 \
    --max-nodes=4
```

### Step 6: Get Cluster Credentials
```bash
gcloud container clusters get-credentials poker-cluster --zone=us-central1-a
```

### Step 7: Update Kubernetes Deployment
```bash
# Replace PROJECT_ID in k8s-deployment.yaml
PROJECT_ID=$(gcloud config get-value project)
sed "s/PROJECT_ID/$PROJECT_ID/g" k8s-deployment.yaml > k8s-deployment-final.yaml
```

### Step 8: Deploy to Kubernetes
```bash
kubectl apply -f k8s-deployment-final.yaml
```

### Step 9: Wait for Deployments
```bash
kubectl wait --for=condition=available --timeout=300s deployment/poker-backend
kubectl wait --for=condition=available --timeout=300s deployment/poker-proxy
kubectl wait --for=condition=available --timeout=300s deployment/poker-frontend
```

### Step 10: Get External IP
```bash
# This may take a few minutes
kubectl get svc poker-frontend-svc

# Watch for EXTERNAL-IP
kubectl get svc poker-frontend-svc --watch
```

## Useful Commands

### Check Pod Status
```bash
kubectl get pods
kubectl describe pod POD_NAME
```

### View Logs
```bash
# Backend logs
kubectl logs -l app=poker-backend

# Proxy logs
kubectl logs -l app=poker-proxy

# Frontend logs
kubectl logs -l app=poker-frontend
```

### Scale Deployments
```bash
# Scale backend to 3 replicas
kubectl scale deployment poker-backend --replicas=3
```

### Update Deployment
```bash
# After building new images
kubectl rollout restart deployment/poker-backend
kubectl rollout restart deployment/poker-proxy
kubectl rollout restart deployment/poker-frontend
```

### Delete Everything
```bash
# Delete deployments
kubectl delete -f k8s-deployment-final.yaml

# Delete cluster
gcloud container clusters delete poker-cluster --zone=us-central1-a
```

## Troubleshooting

### Check if images exist
```bash
gcloud container images list --repository=gcr.io/$PROJECT_ID
```

### View build logs
```bash
gcloud builds list
gcloud builds log BUILD_ID
```

### Check cluster status
```bash
gcloud container clusters describe poker-cluster --zone=us-central1-a
```

### Port-forward for testing
```bash
# Forward frontend to localhost:8080
kubectl port-forward svc/poker-frontend-svc 8080:80

# Forward backend to localhost:50051
kubectl port-forward svc/poker-backend-svc 50051:50051
```

## Cost Optimization

### Stop cluster when not in use
```bash
# Resize to 0 nodes
gcloud container clusters resize poker-cluster --num-nodes=0 --zone=us-central1-a

# Resize back to 2 nodes
gcloud container clusters resize poker-cluster --num-nodes=2 --zone=us-central1-a
```

### Use smaller machine type
```bash
# Use e2-micro for development (not recommended for production)
gcloud container clusters create poker-cluster \
    --zone=us-central1-a \
    --machine-type=e2-micro \
    --num-nodes=1
```

## Final URLs
- Once deployed, your application will be available at: `http://EXTERNAL_IP`
- Backend API: Internal at `poker-backend-svc:50051`
- Proxy API: Internal at `poker-proxy-svc:8081`
- Frontend: External at `http://EXTERNAL_IP:80`
