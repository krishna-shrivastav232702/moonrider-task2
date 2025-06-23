# Product Catalogue Microservice

A scalable Spring Boot microservice for product catalogue management with containerization, version control, and Kubernetes deployment capabilities.

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Local Development Setup](#local-development-setup)
- [Containerization](#containerization)
- [Kubernetes Deployment](#kubernetes-deployment)
- [CI/CD Pipeline](#cicd-pipeline)
- [API Documentation](#api-documentation)
- [Monitoring and Logging](#monitoring-and-logging)
- [Security](#security)
- [Troubleshooting](#troubleshooting)

## 🎯 Overview

This microservice provides REST API endpoints for managing a product catalogue with the following capabilities:
- Product CRUD operations
- Advanced search functionality with pagination
- Health monitoring
- Multi-version deployment support
- Scalable Kubernetes deployment

## ✨ Features

### Version History
- **v1.0.0**: Base version with `/health` and `/products` endpoints
- **v1.1.0**: Added `/products/search` endpoint for keyword searching
- **v2.0.0**: Enhanced search with pagination, sorting, and error handling

### Key Capabilities
- RESTful API design
- MySQL database integration
- Docker containerization
- Kubernetes-native deployment
- Horizontal Pod Autoscaling (HPA)
- Network policies and RBAC
- Multi-environment support

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Ingress       │    │   Services      │    │   Deployments   │
│   Controller    │───▶│   (ClusterIP)   │───▶│   (Spring Boot) │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                                       │
                                                       ▼
                                              ┌─────────────────┐
                                              │   MySQL         │
                                              │   Database      │
                                              └─────────────────┘
```

## 📋 Prerequisites

### Software Requirements
- Java 17+
- Maven 3.6+
- Docker 20.10+
- Kubernetes cluster (Minikube/Kind/Cloud)
- kubectl CLI
- Git

### Hardware Requirements
- 4GB RAM minimum
- 2 CPU cores
- 10GB available disk space

## 🚀 Local Development Setup

### 1. Clone Repository
```bash
git clone <repository-url>
cd product-catalogue-microservice
```

### 2. Environment Configuration
```bash
cp .env.example .env
# Edit .env with your database credentials
```

### 3. Run with Docker Compose
```bash
# Start MySQL and Application
docker-compose up -d

# Check logs
docker-compose logs -f app
```

### 4. Run Locally (Development)
```bash
# Start MySQL container
docker run -d --name mysql-dev \
  -e MYSQL_ROOT_PASSWORD=password \
  -e MYSQL_DATABASE=javatechie \
  -p 3306:3306 mysql:8.0

# Set environment variables
export SPRING_DATASOURCE_URL=jdbc:mysql://localhost:3306/javatechie
export SPRING_DATASOURCE_USERNAME=root
export SPRING_DATASOURCE_PASSWORD=password

# Run application
mvn spring-boot:run
```

### 5. Verify Local Setup
```bash
# Health check
curl http://localhost:9191/health

# Get products
curl http://localhost:9191/products
```

## 🐳 Containerization

### Build Docker Image
```bash
# Build image
docker build -t product-catalogue:latest .

# Run container
docker run -d \
  --name product-catalogue \
  -p 9191:9191 \
  -e SPRING_DATASOURCE_URL=jdbc:mysql://host.docker.internal:3306/javatechie \
  -e SPRING_DATASOURCE_USERNAME=root \
  -e SPRING_DATASOURCE_PASSWORD=password \
  product-catalogue:latest
```

### Docker Image Features
- Multi-stage build for optimized size
- Alpine-based runtime (minimal footprint)
- Non-root user execution
- Health checks included
- Environment variable configuration

## ☸️ Kubernetes Deployment

### 1. Prerequisites Setup
```bash
# Start Minikube (if using)
minikube start --memory=4096 --cpus=2

# Enable required addons
minikube addons enable ingress
minikube addons enable metrics-server

# For Kind cluster
kind create cluster --name prod
```

### 2. Deploy to Kubernetes
```bash
# Apply all manifests
kubectl apply -f k8s/

# Check deployment status
kubectl get pods --all-namespaces
kubectl get services --all-namespaces
kubectl get ingress --all-namespaces
```

### 3. Version-Specific Deployments

#### Deploy v1.0 (Base Version)
```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/secrets.yaml
kubectl apply -f k8s/mysql-deployment.yaml
kubectl apply -f k8s/deploy-v1.yaml
```

#### Deploy All Versions
```bash
kubectl apply -f k8s/deployments.yaml  # v1.1 and v2.0
kubectl apply -f k8s/horizontalPodAutoscaler.yaml
kubectl apply -f k8s/ingress.yaml
```

### 4. Access Applications
```bash
# Get Minikube IP
minikube ip

# Add to /etc/hosts
echo "$(minikube ip) product-catalogue.local" | sudo tee -a /etc/hosts

# Access different versions
curl http://product-catalogue.local/v1/health
curl http://product-catalogue.local/v1.1/products/search?keyword=laptop
curl http://product-catalogue.local/v2/products/search?keyword=phone&page=0&size=5
```

### 5. Scaling Operations
```bash
# Manual scaling
kubectl scale deployment product-catalogue-v1 --replicas=3 -n product-catalogue-v1

# Check HPA status
kubectl get hpa --all-namespaces

# View HPA details
kubectl describe hpa product-catalogue-hpa-v1 -n product-catalogue-v1
```

## 🔄 CI/CD Pipeline

### GitHub Actions Workflow

The pipeline automatically:
1. **Build Phase**: Compiles and packages the application
2. **Containerize**: Builds and pushes Docker image to registry
3. **Deploy**: Deploys to Kubernetes cluster
4. **Verify**: Checks deployment health

### Setup Instructions

#### 1. Configure Secrets
In GitHub repository settings, add these secrets:
```
DOCKERHUB_USERNAME=your-dockerhub-username
DOCKERHUB_TOKEN=your-dockerhub-token
```

#### 2. Self-Hosted Runner Setup
```bash
# Install Docker and Kind on runner
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER

# Install Kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Create Kind cluster
kind create cluster --name prod
```

#### 3. Pipeline Triggers
- **Automatic**: Push to `main` branch
- **Manual**: GitHub Actions UI

#### 4. Pipeline Monitoring
```bash
# Check workflow status
gh workflow list
gh run list

# View logs
gh run view <run-id> --log
```

## 📚 API Documentation

### Base Endpoints

#### Health Check
```http
GET /health
Response: {"status":"UP","version":"1.0.0","timestamp":1640995200000}
```

#### Product Management
```http
# Get all products
GET /products

# Get product by ID
GET /productById/{id}

# Get product by name
GET /product/{name}

# Add single product
POST /addProduct
Content-Type: application/json
{
  "name": "Laptop",
  "quantity": 10,
  "price": 999.99
}

# Add multiple products
POST /addProducts
Content-Type: application/json
[
  {"name": "Phone", "quantity": 20, "price": 599.99},
  {"name": "Tablet", "quantity": 15, "price": 399.99}
]

# Update product
PUT /update
Content-Type: application/json
{
  "id": 1,
  "name": "Updated Laptop",
  "quantity": 5,
  "price": 1199.99
}

# Delete product
DELETE /delete/{id}
```

### Enhanced Search (v1.1+)
```http
# Basic search (v1.1)
GET /products/search?keyword=laptop

# Advanced search (v2.0)
GET /products/search?keyword=phone&page=0&size=10&sortBy=price
Response: {
  "products": [...],
  "totalResults": 25,
  "page": 0,
  "size": 10
}
```

### Version Access Patterns
```http
# v1.0 endpoints
http://product-catalogue.local/v1/health
http://product-catalogue.local/v1/products

# v1.1 endpoints
http://product-catalogue.local/v1.1/products/search?keyword=test

# v2.0 endpoints (default)
http://product-catalogue.local/v2/products/search?keyword=test&page=0&size=5
http://product-catalogue.local/products/search?keyword=test&page=0&size=5
```

## 📊 Monitoring and Logging

### Health Monitoring
```bash
# Application health
kubectl get pods --all-namespaces
kubectl describe pod <pod-name> -n <namespace>

# Check application logs
kubectl logs <pod-name> -n <namespace> -f

# Health endpoint monitoring
curl http://product-catalogue.local/v1/health
```

### Database Monitoring
```bash
# MySQL pod logs
kubectl logs mysql-<pod-id> -n product-catalogue-v1

# Connect to MySQL
kubectl exec -it mysql-<pod-id> -n product-catalogue-v1 -- mysql -u root -p
```

### Resource Monitoring
```bash
# Resource usage
kubectl top pods --all-namespaces
kubectl top nodes

# HPA metrics
kubectl get hpa --all-namespaces -w
```

### Application Metrics
The application exposes Spring Boot Actuator endpoints:
```http
GET /actuator/health
GET /actuator/health/db
GET /actuator/metrics
```

### Logging Best Practices
- Application logs are written to stdout/stderr
- Use `kubectl logs` for real-time monitoring
- Consider implementing structured logging for production
- Set up log aggregation (ELK stack) for cluster-wide visibility

## 🔐 Security

### Implemented Security Features

#### RBAC (Role-Based Access Control)
```yaml
# Service accounts with minimal permissions
# Role-based access to specific resources
# Namespace isolation
```

#### Network Policies
```bash
# Check network policies
kubectl get networkpolicies --all-namespaces

# Verify policy enforcement
kubectl describe networkpolicy mysql-netpol -n product-catalogue-v1
```

#### Container Security
- Non-root user execution
- Minimal base images (Alpine)
- Resource limits and requests
- Health checks and probes

#### Secret Management
```bash
# View secrets (base64 encoded)
kubectl get secrets mysql-secret -n product-catalogue-v1 -o yaml

# Decode secret
kubectl get secret mysql-secret -n product-catalogue-v1 -o jsonpath='{.data.DB_PASSWORD}' | base64 -d
```

### Security Best Practices
- Regularly update base images
- Scan images for vulnerabilities
- Use secrets for sensitive data
- Implement network segmentation
- Monitor and audit access

## 🐛 Troubleshooting

### Common Issues

#### Pod Startup Issues
```bash
# Check pod status
kubectl get pods -n product-catalogue-v1

# Describe pod for events
kubectl describe pod <pod-name> -n product-catalogue-v1

# Check logs
kubectl logs <pod-name> -n product-catalogue-v1 --previous
```

#### Database Connection Issues
```bash
# Test MySQL connectivity
kubectl exec -it <app-pod> -n product-catalogue-v1 -- nc -zv mysql-service 3306

# Check MySQL logs
kubectl logs <mysql-pod> -n product-catalogue-v1

# Verify secret values
kubectl get secret mysql-secret -n product-catalogue-v1 -o yaml
```

#### Ingress Issues
```bash
# Check ingress status
kubectl get ingress --all-namespaces

# Describe ingress
kubectl describe ingress product-catalogue-ingress

# Check ingress controller
kubectl get pods -n ingress-nginx
```

#### HPA Not Scaling
```bash
# Check metrics server
kubectl get apiservice v1beta1.metrics.k8s.io

# Check HPA status
kubectl describe hpa product-catalogue-hpa-v1 -n product-catalogue-v1

# Generate load for testing
kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh
# while sleep 0.01; do wget -q -O- http://product-catalogue-v1-service/health; done
```

### Debug Commands
```bash
# Get all resources
kubectl get all --all-namespaces

# Check node resources
kubectl describe nodes

# Check events
kubectl get events --all-namespaces --sort-by='.lastTimestamp'

# Port forward for local access
kubectl port-forward svc/product-catalogue-v1-service 8080:80 -n product-catalogue-v1
```

### Performance Optimization
- Adjust resource limits based on usage
- Tune JVM parameters for containerized environment
- Implement connection pooling
- Use persistent volumes for database
- Configure appropriate HPA thresholds

## 📝 Development Notes

### Code Structure
```
src/
├── main/java/com/javatechie/crud/example/
│   ├── controller/          # REST controllers
│   ├── entity/             # JPA entities
│   ├── repository/         # Data repositories
│   ├── service/           # Business logic
│   └── SpringBootCrudExample2Application.java
├── main/resources/
│   ├── application.properties
│   └── application.yml
└── test/                  # Unit tests
```

### Environment Variables
```bash
SPRING_DATASOURCE_URL=jdbc:mysql://mysql-service:3306/javatechie
SPRING_DATASOURCE_USERNAME=root
SPRING_DATASOURCE_PASSWORD=password
SERVER_PORT=9191
SPRING_PROFILES_ACTIVE=prod
```

### Database Schema
```sql
CREATE TABLE PRODUCT_TBL (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255),
    quantity INT,
    price DOUBLE
);
```

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Support

For issues and questions:
- Create GitHub issue
- Check troubleshooting section
- Review system design documentation

---

**Last Updated**: June 2025
**Version**: 2.0.0