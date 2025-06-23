# System Design Documentation

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture Principles](#architecture-principles)
- [System Architecture](#system-architecture)
- [Component Design](#component-design)
- [Data Architecture](#data-architecture)
- [Deployment Architecture](#deployment-architecture)
- [Security Architecture](#security-architecture)
- [Scalability Design](#scalability-design)
- [Monitoring and Observability](#monitoring-and-observability)

## 🎯 Overview

This document outlines the system design and architectural decisions for the Product Catalogue Microservice. The system is designed to be scalable, maintainable, and cloud-native, following modern DevOps practices and microservices architecture patterns.

### Design Goals
- **Scalability**: Handle varying loads with horizontal scaling
- **Reliability**: Ensure high availability and fault tolerance
- **Maintainability**: Support multiple versions and easy updates
- **Security**: Implement defense-in-depth security measures
- **Observability**: Provide comprehensive monitoring and logging

## 🏗️ Architecture Principles

### 1. Cloud-Native Design
- **Containerization**: All components run in containers
- **Orchestration**: Kubernetes for container management
- **Service Discovery**: Built-in Kubernetes service discovery
- **Configuration Management**: ConfigMaps and Secrets

### 2. Microservices Architecture
- **Single Responsibility**: Each service has a focused purpose
- **Loose Coupling**: Services communicate via well-defined APIs
- **High Cohesion**: Related functionality grouped together
- **Independent Deployment**: Services can be deployed independently

### 3. 12-Factor App Compliance
- **Codebase**: One codebase tracked in revision control
- **Dependencies**: Explicitly declare and isolate dependencies
- **Config**: Store config in the environment
- **Backing Services**: Treat backing services as attached resources
- **Build, Release, Run**: Strictly separate build and run stages

## 🏛️ System Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Internet / Users                          │
└─────────────────────────┬───────────────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────────────┐
│                    Load Balancer                                │
└─────────────────────────┬───────────────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────────────┐
│                 Kubernetes Cluster                              │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  │
│  │   Ingress       │  │   Ingress       │  │   Ingress       │  │
│  │   Controller    │  │   Controller    │  │   Controller    │  │
│  │   (NGINX)       │  │   (NGINX)       │  │   (NGINX)       │  │
│  └─────────┬───────┘  └─────────┬───────┘  └─────────┬───────┘  │
│            │                    │                    │          │
│  ┌─────────▼───────┐  ┌─────────▼───────┐  ┌─────────▼───────┐  │
│  │   Product       │  │   Product       │  │   Product       │  │
│  │   Catalogue     │  │   Catalogue     │  │   Catalogue     │  │
│  │   v1.0          │  │   v1.1          │  │   v2.0          │  │
│  └─────────┬───────┘  └─────────┬───────┘  └─────────┬───────┘  │
│            │                    │                    │          │
│  ┌─────────▼───────┐  ┌─────────▼───────┐  ┌─────────▼───────┐  │
│  │   MySQL         │  │   MySQL         │  │   MySQL         │  │
│  │   Database      │  │   Database      │  │   Database      │  │
│  │   v1.0          │  │   v1.1          │  │   v2.0          │  │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### Network Flow

```
External Request → Ingress Controller → Service → Pod → Database
     │                    │              │        │        │
     │                    │              │        │        │
     ▼                    ▼              ▼        ▼        ▼
[User/API Client] → [NGINX Ingress] → [ClusterIP] → [Spring Boot] → [MySQL]
                         │                           │
                         │                           │
                    [Path-based]                [Connection Pool]
                    [Routing]                   [& Transaction Mgmt]
```

## 🔧 Component Design

### 1. Application Layer

#### Spring Boot Application
```java
@SpringBootApplication
public class SpringBootCrudExample2Application {
    // Auto-configuration
    // Component scanning
    // External configuration
}
```

**Key Components:**
- **Controllers**: Handle HTTP requests and responses
- **Services**: Business logic implementation
- **Repositories**: Data access layer
- **Entities**: Data model representation

#### Controller Design Pattern
```java
@RestController
public class ProductController {
    @Autowired
    private ProductService service;
    
    // RESTful endpoints
    // Error handling
    // Input validation
}
```

### 2. Data Layer

#### Repository Pattern
```java
public interface ProductRepository extends JpaRepository<Product,Integer> {
    // Spring Data JPA auto-implementation
    // Custom query methods
    // Pagination support
}
```

#### Entity Design
```java
@Entity
@Table(name = "PRODUCT_TBL")
public class Product {
    @Id
    @GeneratedValue
    private int id;
    // Other fields with appropriate annotations
}
```

### 3. Configuration Layer

#### Application Configuration
```properties
# Database configuration
spring.datasource.url=${SPRING_DATASOURCE_URL}
spring.datasource.username=${SPRING_DATASOURCE_USERNAME}
spring.datasource.password=${SPRING_DATASOURCE_PASSWORD}

# JPA configuration
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true

# Server configuration
server.port=9191

# Actuator configuration
management.endpoints.web.exposure.include=health
management.endpoint.health.show-details=always
```

## 💾 Data Architecture

### Database Design

#### Entity Relationship
```
PRODUCT_TBL
├── id (PK, AUTO_INCREMENT)
├── name (VARCHAR(255))
├── quantity (INT)
├── price (DOUBLE)
├── created_at (TIMESTAMP)
└── updated_at (TIMESTAMP)
```

#### Data Flow
```
API Request → Controller → Service → Repository → JPA → MySQL
     │            │          │          │         │       │
     │            │          │          │         │       │
     ▼            ▼          ▼          ▼         ▼       ▼
[JSON Data] → [Validation] → [Business Logic] → [Query] → [Persistence]
```

### Data Management Strategy

#### Connection Pool Configuration
```yaml
spring:
  datasource:
    hikari:
      maximum-pool-size: 20
      minimum-idle: 5
      connection-timeout: 30000
      idle-timeout: 600000
      max-lifetime: 1800000
```

#### Transaction Management
- **Declarative Transactions**: Using @Transactional
- **Isolation Levels**: Default READ_COMMITTED
- **Propagation**: REQUIRED for data modifications

### Search Functionality Evolution

#### v1.1 - Basic Search
```java
public List<Product> findByNameContainingIgnoreCase(String keyword);
```

#### v2.0 - Advanced Search
```java
public Page<Product> findByNameContainingIgnoreCase(String keyword, Pageable pageable);
```
- Pagination support
- Sorting capabilities
- Error handling

## 🚀 Deployment Architecture

### Containerization Strategy

#### Multi-Stage Docker Build
```dockerfile
# Build stage
FROM maven:3.9.9-eclipse-temurin-17-alpine AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -B
COPY src ./src
RUN mvn clean package -DskipTests

# Runtime stage
FROM eclipse-temurin:17-jdk-alpine
WORKDIR /app
RUN addgroup -g 1001 appgroup && \
    adduser -D -u 1001 -G appgroup appuser
COPY --from=build /app/target/*.jar app.jar
RUN chown -R appuser:appgroup /app
USER appuser
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
 CMD wget --no-verbose --tries=1 --spider http://localhost:9191/actuator/health || exit 1
EXPOSE 9191
ENTRYPOINT ["java","-jar","app.jar"]
```

**Design Decisions:**
- **Multi-stage builds**: Reduce final image size
- **Alpine base**: Minimal attack surface
- **Non-root user**: Security best practice
- **Health checks**: Container health monitoring

### Kubernetes Architecture

#### Namespace Isolation
```yaml
# Separate namespaces for each version
product-catalogue-v1
product-catalogue-v1-1
product-catalogue-v2
```

**Benefits:**
- Resource isolation
- RBAC granularity
- Network policy enforcement
- Independent scaling

#### Service Mesh Design
```
Pod ←→ Service ←→ Ingress ←→ External Traffic
 │       │          │
 │       │          │
 ▼       ▼          ▼
[App]  [ClusterIP] [NGINX]
```

### Resource Management

#### Resource Specifications
```yaml
resources:
  requests:
    memory: "768Mi"
    cpu: "500m"
  limits:
    memory: "1.5Gi"
    cpu: "1000m"
```

#### Horizontal Pod Autoscaler
```yaml
metrics:
- type: Resource
  resource:
    name: cpu
    target:
      type: Utilization
      averageUtilization: 70
- type: Resource
  resource:
    name: memory
    target:
      type: Utilization
      averageUtilization: 80
```

## 🔐 Security Architecture

### Defense in Depth

#### 1. Container Security
- **Non-root execution**
- **Minimal base images**
- **Read-only root filesystem**
- **Security contexts**

#### 2. Network Security
```yaml
# Network Policy Example
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: product-catalogue-netpol
spec:
  podSelector:
    matchLabels:
      app: product-catalogue
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: default
    ports:
    - protocol: TCP
      port: 9191
```

#### 3. RBAC Implementation
```yaml
# Service Account with limited permissions
apiVersion: v1
kind: ServiceAccount
metadata:
  name: product-catalogue-sa
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: product-catalogue-role
rules:
- apiGroups: [""]
  resources: ["pods", "services", "endpoints"]
  verbs: ["get", "list", "watch"]
```

#### 4. Secret Management
```yaml
# Base64 encoded secrets
apiVersion: v1
kind: Secret
metadata:
  name: mysql-secret
type: Opaque
data:
  DB_NAME: amF2YXRlY2hpZQ==
  DB_PASSWORD: UGFzc3dvcmQ=
```

### Security Best Practices Implemented

1. **Principle of Least Privilege**: Minimal RBAC permissions
2. **Network Segmentation**: Network policies for traffic control
3. **Secret Management**: Kubernetes secrets for sensitive data
4. **Container Security**: Non-root users and security contexts
5. **Image Security**: Minimal base images and regular updates

## 📈 Scalability Design

### Horizontal Scaling Strategy

#### Auto-scaling Configuration
```yaml
spec:
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 0
      policies:
      - type: Percent
        value: 100
        periodSeconds: 15
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 10
        periodSeconds: 60
```

#### Database Scaling Considerations
- **Read Replicas**: For read-heavy workloads
- **Connection Pooling**: Efficient connection management
- **Query Optimization**: Indexed searches
- **Caching Layer**: Redis for frequently accessed data (future)

### Performance Optimization

#### Application Level
- **Connection Pooling**: HikariCP configuration
- **JVM Tuning**: Container-optimized JVM settings
- **Pagination**: Implemented in v2.0 for large datasets
- **Query Optimization**: JPA query optimization

#### Infrastructure Level
- **Resource Requests/Limits**: Proper resource allocation
- **Node Affinity**: Optimal pod placement
- **Persistent Volumes**: SSD storage for databases
- **Network Optimization**: Service mesh considerations

## 📊 Monitoring and Observability

### Health Monitoring Architecture

```
Application → Actuator → Kubernetes → Monitoring Stack
     │           │            │            │
     │           │            │            │
     ▼           ▼            ▼            ▼
[Spring Boot] → [/health] → [Probes] → [Metrics Collection]
```

#### Health Check Implementation
```java
@GetMapping("/health")
public Map<String,Object> health(){
    Map<String,Object> response = new HashMap<>();
    response.put("status","UP");
    response.put("version","1.0.0");
    response.put("timestamp",System.currentTimeMillis());
    return response;
}
```

#### Kubernetes Probes
```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 9191
  initialDelaySeconds: 60
  periodSeconds: 10
readinessProbe:
  httpGet:
    path: /health
    port: 9191
  initialDelaySeconds: 30
  periodSeconds: 5
startupProbe:
  httpGet:
    path: /health
    port: 9191
  initialDelaySeconds: 10
  periodSeconds: 10
  failureThreshold: 30
```