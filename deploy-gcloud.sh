#!/bin/bash

# Poker Application - Google Cloud Deployment Script
# This script will deploy the Poker application to Google Kubernetes Engine (GKE)

set -e  # Exit on error

echo "╔════════════════════════════════════════════════════════════════════════════╗"
echo "║           🃏 Poker Application - Google Cloud Deployment                   ║"
echo "╚════════════════════════════════════════════════════════════════════════════╝"
echo ""

# Configuration
REGION="us-central1"
ZONE="us-central1-a"
CLUSTER_NAME="poker-cluster"
MACHINE_TYPE="e2-medium"

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo "❌ Google Cloud SDK not found!"
    echo "Installing Google Cloud SDK..."
    curl https://sdk.cloud.google.com | bash -s -- --disable-prompts
    exec -l $SHELL
fi

# Get or set project ID
if [ -z "$PROJECT_ID" ]; then
    echo ""
    echo "📋 Available Google Cloud Projects:"
    gcloud projects list --format="table(projectId,name)"
    echo ""
    read -p "Enter your GCP Project ID: " PROJECT_ID
fi

echo ""
echo "🔧 Setting up Google Cloud project: $PROJECT_ID"
gcloud config set project $PROJECT_ID

# Enable required APIs
echo ""
echo "🔌 Enabling required Google Cloud APIs..."
gcloud services enable container.googleapis.com
gcloud services enable containerregistry.googleapis.com
gcloud services enable cloudbuild.googleapis.com

# Build and push Docker images using Cloud Build
echo ""
echo "🐳 Building Docker images with Cloud Build..."

echo "  📦 Building backend..."
gcloud builds submit --tag gcr.io/$PROJECT_ID/poker-backend:latest \
    --dockerfile=Dockerfile.backend .

echo "  📦 Building proxy..."
gcloud builds submit --tag gcr.io/$PROJECT_ID/poker-proxy:latest \
    --dockerfile=Dockerfile.proxy .

echo "  📦 Building frontend..."
gcloud builds submit --tag gcr.io/$PROJECT_ID/poker-frontend:latest \
    --dockerfile=Dockerfile.frontend .

# Check if cluster exists
if gcloud container clusters describe $CLUSTER_NAME --zone=$ZONE &>/dev/null; then
    echo ""
    echo "♻️  Cluster '$CLUSTER_NAME' already exists. Using existing cluster."
else
    echo ""
    echo "🚀 Creating GKE cluster: $CLUSTER_NAME"
    gcloud container clusters create $CLUSTER_NAME \
        --zone=$ZONE \
        --machine-type=$MACHINE_TYPE \
        --num-nodes=2 \
        --enable-autoscaling \
        --min-nodes=2 \
        --max-nodes=4
fi

# Get cluster credentials
echo ""
echo "🔑 Getting cluster credentials..."
gcloud container clusters get-credentials $CLUSTER_NAME --zone=$ZONE

# Update k8s deployment with project ID
echo ""
echo "📝 Updating Kubernetes deployment files..."
sed "s/PROJECT_ID/$PROJECT_ID/g" k8s-deployment.yaml > k8s-deployment-${PROJECT_ID}.yaml

# Deploy to Kubernetes
echo ""
echo "🚢 Deploying to Kubernetes..."
kubectl apply -f k8s-deployment-${PROJECT_ID}.yaml

# Wait for deployments
echo ""
echo "⏳ Waiting for deployments to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/poker-backend
kubectl wait --for=condition=available --timeout=300s deployment/poker-proxy
kubectl wait --for=condition=available --timeout=300s deployment/poker-frontend

# Get external IP
echo ""
echo "🌐 Getting external IP address..."
echo "   (This may take a few minutes...)"

EXTERNAL_IP=""
while [ -z $EXTERNAL_IP ]; do
    EXTERNAL_IP=$(kubectl get svc poker-frontend-svc -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
    if [ -z $EXTERNAL_IP ]; then
        echo "   Waiting for external IP..."
        sleep 10
    fi
done

echo ""
echo "╔════════════════════════════════════════════════════════════════════════════╗"
echo "║                    ✅ DEPLOYMENT SUCCESSFUL!                                ║"
echo "╚════════════════════════════════════════════════════════════════════════════╝"
echo ""
echo "🌐 Application URL: http://$EXTERNAL_IP"
echo ""
echo "📊 Deployment Details:"
echo "   Project:  $PROJECT_ID"
echo "   Region:   $REGION"
echo "   Cluster:  $CLUSTER_NAME"
echo "   IP:       $EXTERNAL_IP"
echo ""
echo "🔍 Useful Commands:"
echo "   View pods:     kubectl get pods"
echo "   View services: kubectl get svc"
echo "   View logs:     kubectl logs -l app=poker-backend"
echo "   Scale up:      kubectl scale deployment poker-backend --replicas=3"
echo ""
echo "🗑️  To delete the cluster later:"
echo "   gcloud container clusters delete $CLUSTER_NAME --zone=$ZONE"
echo ""
