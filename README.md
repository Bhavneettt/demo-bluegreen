# Blue-Green Deployment Demo

This project demonstrates a complete blue-green deployment setup using Jenkins, Docker, and Kubernetes.

## Project Structure

```
demo-bluegreen/
├── app/
│   └── server.js          # Express.js application
├── k8s/
│   ├── ns.yaml           # Kubernetes namespace
│   ├── service.yaml      # Kubernetes service
│   ├── deploy-blue.yaml  # Blue deployment
│   └── deploy-green.yaml # Green deployment
├── Dockerfile            # Container image definition
├── Jenkinsfile          # CI/CD pipeline
└── package.json         # Node.js dependencies
```

## How It Works

1. **Application**: Simple Express.js server that displays its color (blue/green) and provides a health endpoint
2. **Blue-Green Strategy**: Two identical deployments (blue and green) where only one is active at a time
3. **Jenkins Pipeline**: Automatically determines which color to deploy to and switches traffic
4. **Zero Downtime**: New version is deployed to the idle environment before switching traffic

## Setup Instructions

### Prerequisites
- Jenkins with Docker and kubectl configured
- Kubernetes cluster access
- Docker Hub credentials stored in Jenkins as 'dockerhub'

### Initial Kubernetes Setup
```bash
kubectl apply -f k8s/ns.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/deploy-blue.yaml
kubectl apply -f k8s/deploy-green.yaml
```

### Jenkins Pipeline
1. Create a new Jenkins pipeline job
2. Point it to this repository
3. Ensure Jenkins has:
   - Docker Hub credentials (ID: 'dockerhub')
   - kubectl access to your cluster
   - Docker daemon access

## Pipeline Stages

1. **Checkout**: Get source code
2. **Build Image**: Build and push Docker image with color-specific tag
3. **Deploy idle color**: Deploy to the inactive environment
4. **Smoke Test**: Verify the new deployment is healthy
5. **Flip Service**: Switch traffic to the new deployment
6. **Scale down old color**: Scale down the previous deployment

## Testing

After deployment, you can test the application:
```bash
# Get the service endpoint
kubectl -n demo get svc demo

# Test the application
curl <service-ip>:3000
# Should return: "Hello from blue!" or "Hello from green!"
```

## Key Features

- **Automatic Color Detection**: Pipeline determines which color to deploy to
- **Health Checks**: Readiness probes ensure deployments are ready before traffic switch
- **Rollback Capability**: Can easily switch back by running the pipeline again
- **Resource Management**: Old deployments are scaled down to save resources
