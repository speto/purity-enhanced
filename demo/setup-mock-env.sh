#!/usr/bin/env zsh

# Mock Environment Setup for Purity Enhanced Demo
# Creates realistic development environments for testing all theme features

set -e

MOCK_ROOT="${1:-/tmp/purity-mock-env}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m' 
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
NC='\033[0m'

echo_step() {
    echo "${CYAN}▶ $1${NC}"
}

echo_success() {
    echo "${GREEN}✅ $1${NC}"
}

# Initialize mock environment root
init_environment() {
    echo_step "Initializing mock environment at $MOCK_ROOT"
    
    rm -rf "$MOCK_ROOT" 2>/dev/null || true
    mkdir -p "$MOCK_ROOT"
    cd "$MOCK_ROOT"
    
    # Configure git for all repositories
    git config --global user.email "demo@purity-enhanced.dev"
    git config --global user.name "Demo User" 
    git config --global init.defaultBranch main
    
    echo_success "Environment initialized"
}

# Create Python project with virtual environment
setup_python_project() {
    echo_step "Setting up Python project"
    
    local dir="python-ml-project"
    mkdir -p "$dir" && cd "$dir"
    
    # Python project files
    cat > pyproject.toml << 'EOF'
[build-system]
requires = ["setuptools>=61.0", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "ml-model"
version = "0.1.0"
description = "Machine Learning Model Training"
dependencies = [
    "numpy>=1.21.0",
    "pandas>=1.3.0", 
    "scikit-learn>=1.0.0",
    "matplotlib>=3.5.0"
]

[project.optional-dependencies]
dev = [
    "pytest>=6.0",
    "black>=22.0",
    "flake8>=4.0"
]
EOF

    cat > requirements.txt << 'EOF'
numpy==1.24.3
pandas==2.0.2
scikit-learn==1.3.0
matplotlib==3.7.1
jupyter==1.0.0
EOF

    cat > setup.py << 'EOF'
from setuptools import setup, find_packages

setup(
    name="ml-model",
    version="0.1.0",
    packages=find_packages(),
    install_requires=[
        "numpy>=1.21.0",
        "pandas>=1.3.0",
        "scikit-learn>=1.0.0"
    ]
)
EOF

    # Create source files
    mkdir -p src/ml_model
    cat > src/ml_model/__init__.py << 'EOF'
"""Machine Learning Model Package"""
__version__ = "0.1.0"
EOF

    cat > src/ml_model/train.py << 'EOF'
import numpy as np
from sklearn.ensemble import RandomForestClassifier

def train_model(X, y):
    """Train a random forest model"""
    model = RandomForestClassifier(n_estimators=100)
    model.fit(X, y)
    return model
EOF

    # Initialize git repository with various states
    git init
    git add pyproject.toml requirements.txt setup.py src/
    git commit -m "Initial Python ML project setup"
    
    # Create different git states
    echo "# ML Model Training" > README.md
    echo "Updated training algorithm" >> src/ml_model/train.py
    echo "experimental_feature = True" > src/ml_model/config.py
    
    git add README.md src/ml_model/train.py
    # Leave config.py untracked and train.py unstaged
    
    echo_success "Python project created with mixed git state"
    cd "$MOCK_ROOT"
}

# Create Node.js full-stack project
setup_nodejs_project() {
    echo_step "Setting up Node.js project"
    
    local dir="webapp-fullstack"
    mkdir -p "$dir" && cd "$dir"
    
    # Package.json with modern stack
    cat > package.json << 'EOF'
{
  "name": "webapp-fullstack", 
  "version": "2.1.0",
  "description": "Full-stack web application",
  "main": "server.js",
  "scripts": {
    "dev": "nodemon server.js",
    "build": "webpack --mode=production",
    "test": "jest",
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "react": "^18.2.0",
    "react-dom": "^18.2.0", 
    "mongoose": "^7.3.0",
    "jsonwebtoken": "^9.0.1",
    "bcryptjs": "^2.4.3"
  },
  "devDependencies": {
    "nodemon": "^2.0.22",
    "webpack": "^5.88.0",
    "babel-loader": "^9.1.0",
    "jest": "^29.5.0"
  },
  "engines": {
    "node": ">=18.0.0"
  }
}
EOF

    # Create source structure
    mkdir -p src/components src/pages server/routes server/models
    
    cat > server.js << 'EOF'
const express = require('express');
const mongoose = require('mongoose');
const app = express();

// Middleware
app.use(express.json());

// Routes
app.use('/api/users', require('./server/routes/users'));
app.use('/api/auth', require('./server/routes/auth'));

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
EOF

    cat > .env << 'EOF'
NODE_ENV=development
PORT=3000
DATABASE_URL=mongodb://localhost:27017/webapp
JWT_SECRET=your-secret-key
EOF

    # Webpack config
    cat > webpack.config.js << 'EOF'
const path = require('path');

module.exports = {
  entry: './src/index.js',
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'bundle.js'
  },
  module: {
    rules: [
      {
        test: /\.jsx?$/,
        exclude: /node_modules/,
        use: 'babel-loader'
      }
    ]
  }
};
EOF

    # Git setup with remote simulation
    git init
    git add package.json server.js webpack.config.js .env
    git commit -m "Initial Node.js application setup"
    
    # Simulate remote repository
    git remote add origin https://github.com/demo/webapp-fullstack.git
    
    # Create ahead state
    echo "// New API endpoint" >> server.js
    git add server.js
    git commit -m "Add new API endpoint"
    
    # Create behind state simulation (would need actual remote)
    echo "const newFeature = true;" > src/feature.js
    # Leave untracked
    
    echo_success "Node.js project created with remote tracking"
    cd "$MOCK_ROOT"
}

# Create Go microservices project
setup_go_project() {
    echo_step "Setting up Go project"
    
    local dir="api-microservice" 
    mkdir -p "$dir" && cd "$dir"
    
    # Go module
    cat > go.mod << 'EOF'
module github.com/demo/api-microservice

go 1.21

require (
    github.com/gin-gonic/gin v1.9.1
    github.com/golang-jwt/jwt/v5 v5.0.0
    github.com/lib/pq v1.10.9
    go.mongodb.org/mongo-driver v1.12.0
)

require (
    github.com/bytedance/sonic v1.9.1 // indirect
    github.com/chenzhuoyu/base64x v0.0.0-20221115062448-fe3a3abad311 // indirect
    github.com/gabriel-vasile/mimetype v1.4.2 // indirect
    github.com/gin-contrib/sse v0.1.0 // indirect
    github.com/go-playground/locales v0.14.1 // indirect
    github.com/go-playground/universal-translator v0.18.1 // indirect
    github.com/go-playground/validator/v10 v10.14.0 // indirect
    github.com/goccy/go-json v0.10.2 // indirect
    github.com/json-iterator/go v1.1.12 // indirect
    github.com/klauspost/cpuid/v2 v2.2.4 // indirect
    github.com/leodido/go-urn v1.2.4 // indirect
    github.com/mattn/go-isatty v0.0.19 // indirect
    github.com/modern-go/concurrent v0.0.0-20180306012644-bacd9c7ef1dd // indirect
    github.com/modern-go/reflect2 v1.0.2 // indirect
    github.com/pelletier/go-toml/v2 v2.0.8 // indirect
    github.com/twitchyliquid64/golang-asm v0.15.1 // indirect
    github.com/ugorji/go/codec v1.2.11 // indirect
    golang.org/x/arch v0.3.0 // indirect
    golang.org/x/crypto v0.9.0 // indirect
    golang.org/x/net v0.10.0 // indirect
    golang.org/x/sys v0.8.0 // indirect
    golang.org/x/text v0.9.0 // indirect
    google.golang.org/protobuf v1.30.0 // indirect
    gopkg.in/yaml.v3 v3.0.1 // indirect
)
EOF

    # Main application
    cat > main.go << 'EOF'
package main

import (
    "log"
    "net/http"
    
    "github.com/gin-gonic/gin"
)

func main() {
    r := gin.Default()
    
    // Health check
    r.GET("/health", func(c *gin.Context) {
        c.JSON(http.StatusOK, gin.H{
            "status": "healthy",
        })
    })
    
    // API routes
    api := r.Group("/api/v1")
    {
        api.GET("/users", getUsers)
        api.POST("/users", createUser)
    }
    
    log.Println("Server starting on :8080")
    r.Run(":8080")
}

func getUsers(c *gin.Context) {
    c.JSON(http.StatusOK, []string{"user1", "user2"})
}

func createUser(c *gin.Context) {
    c.JSON(http.StatusCreated, gin.H{"message": "User created"})
}
EOF

    # Docker files
    cat > Dockerfile << 'EOF'
FROM golang:1.21-alpine AS builder

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN go build -o main .

FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /app/main .
CMD ["./main"]
EOF

    cat > .dockerignore << 'EOF'
.git
.gitignore
README.md
Dockerfile
.dockerignore
EOF

    # Initialize git with stash scenario
    git init
    git add go.mod main.go Dockerfile .dockerignore
    git commit -m "Initial Go microservice"
    
    # Create stash scenario
    echo "// TODO: Add authentication middleware" >> main.go
    echo "package config\n\nconst Version = \"1.0.0\"" > config.go
    git add main.go
    git stash push -m "WIP: Authentication middleware"
    
    echo_success "Go project created with stash"
    cd "$MOCK_ROOT"
}

# Create Docker Compose multi-service project
setup_docker_project() {
    echo_step "Setting up Docker Compose project"
    
    local dir="infrastructure"
    mkdir -p "$dir" && cd "$dir"
    
    # Main docker-compose file
    cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  web:
    image: nginx:1.21-alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./certs:/etc/nginx/certs:ro
    depends_on:
      - api
    networks:
      - frontend
      - backend

  api:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://user:pass@db:5432/app
      - REDIS_URL=redis://cache:6379
    depends_on:
      - db
      - cache
    networks:
      - backend
    volumes:
      - ./logs:/app/logs

  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: app
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql:ro
    networks:
      - backend
    ports:
      - "5432:5432"

  cache:
    image: redis:7-alpine
    networks:
      - backend
    volumes:
      - redis_data:/data

  worker:
    build: .
    command: npm run worker
    environment:
      - NODE_ENV=production
      - REDIS_URL=redis://cache:6379
    depends_on:
      - cache
    networks:
      - backend
    scale: 2

volumes:
  postgres_data:
  redis_data:

networks:
  frontend:
  backend:
EOF

    # Development override
    cat > docker-compose.dev.yml << 'EOF'
version: '3.8'

services:
  web:
    ports:
      - "8080:80"
  
  api:
    environment:
      - NODE_ENV=development
    volumes:
      - .:/app
      - /app/node_modules
    command: npm run dev

  db:
    ports:
      - "5433:5432"
EOF

    # Production override
    cat > docker-compose.prod.yml << 'EOF'
version: '3.8'

services:
  web:
    restart: unless-stopped
    
  api:
    restart: unless-stopped
    
  db:
    restart: unless-stopped
    
  cache:
    restart: unless-stopped
    
  worker:
    restart: unless-stopped
EOF

    # Kubernetes manifests
    mkdir -p k8s
    cat > k8s/namespace.yaml << 'EOF'
apiVersion: v1
kind: Namespace
metadata:
  name: demo-app
EOF

    cat > k8s/deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
  namespace: demo-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: api
  template:
    metadata:
      labels:
        app: api
    spec:
      containers:
      - name: api
        image: demo/api:latest
        ports:
        - containerPort: 3000
EOF

    # Makefile for management
    cat > Makefile << 'EOF'
.PHONY: dev prod test clean logs

dev:
	docker-compose -f docker-compose.yml -f docker-compose.dev.yml up --build

prod:
	docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d

test:
	docker-compose run --rm api npm test

clean:
	docker-compose down -v
	docker system prune -f

logs:
	docker-compose logs -f
EOF

    # Git setup
    git init
    git add docker-compose* k8s/ Makefile
    git commit -m "Initial Docker infrastructure setup"
    
    # Create modified state
    echo "  monitoring:" >> docker-compose.yml
    echo "    image: prometheus/prometheus:latest" >> docker-compose.yml
    
    echo_success "Docker Compose project created"
    cd "$MOCK_ROOT"
}

# Create project with git rebase in progress
setup_git_rebase_project() {
    echo_step "Setting up git rebase scenario"
    
    local dir="git-rebase-demo"
    mkdir -p "$dir" && cd "$dir"
    
    git init
    
    # Create main branch history
    echo "Initial content" > file.txt
    git add file.txt
    git commit -m "Initial commit"
    
    echo "Main branch change" >> file.txt
    git add file.txt
    git commit -m "Main branch update"
    
    # Create feature branch
    git checkout -b feature/new-feature
    echo "Feature change" >> file.txt
    git add file.txt  
    git commit -m "Add new feature"
    
    # Go back to main and create conflict
    git checkout main
    echo "Conflicting change" >> file.txt
    git add file.txt
    git commit -m "Conflicting update"
    
    # Start rebase (will conflict)
    git checkout feature/new-feature
    git rebase main || true  # Allow failure
    
    echo_success "Git rebase scenario created"
    cd "$MOCK_ROOT"
}

# Create comprehensive demo environment
create_demo_environments() {
    echo_step "Creating comprehensive demo environments"
    
    # Language projects
    setup_python_project
    setup_nodejs_project  
    setup_go_project
    setup_docker_project
    setup_git_rebase_project
    
    # Create additional contexts
    create_rust_project
    create_java_project
    create_terraform_project
    create_kubernetes_contexts
    
    echo_success "All demo environments created"
}

# Create Rust project
create_rust_project() {
    local dir="rust-cli-tool" 
    mkdir -p "$dir" && cd "$dir"
    
    cat > Cargo.toml << 'EOF'
[package]
name = "cli-tool"
version = "0.1.0"
edition = "2021"

[dependencies]
clap = "4.0"
serde = { version = "1.0", features = ["derive"] }
tokio = { version = "1.0", features = ["full"] }
EOF

    mkdir -p src
    echo 'fn main() { println!("Hello, world!"); }' > src/main.rs
    
    git init
    git add Cargo.toml src/
    git commit -m "Initial Rust CLI tool"
    
    cd "$MOCK_ROOT"
}

# Create Java project
create_java_project() {
    local dir="java-spring-api"
    mkdir -p "$dir" && cd "$dir"
    
    cat > pom.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0">
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.demo</groupId>
    <artifactId>spring-api</artifactId>
    <version>1.0.0</version>
    <packaging>jar</packaging>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.1.0</version>
    </parent>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
    </dependencies>
</project>
EOF

    mkdir -p src/main/java/com/demo
    echo 'package com.demo; public class Application {}' > src/main/java/com/demo/Application.java
    
    git init
    git add pom.xml src/
    git commit -m "Initial Spring Boot API"
    
    cd "$MOCK_ROOT"
}

# Create Terraform project
create_terraform_project() {
    local dir="terraform-aws-infra"
    mkdir -p "$dir" && cd "$dir"
    
    cat > main.tf << 'EOF'
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "main-vpc"
  }
}
EOF

    cat > variables.tf << 'EOF'
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}
EOF

    git init  
    git add *.tf
    git commit -m "Initial Terraform AWS infrastructure"
    
    cd "$MOCK_ROOT"
}

# Create Kubernetes contexts
create_kubernetes_contexts() {
    # This would normally require actual kubectl contexts
    # For demo purposes, we'll create mock config files
    
    local dir="k8s-manifests"
    mkdir -p "$dir" && cd "$dir"
    
    mkdir -p apps/frontend apps/backend infra
    
    cat > apps/frontend/deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: frontend
        image: nginx:alpine
EOF

    git init
    git add apps/
    git commit -m "Initial Kubernetes manifests"
    
    cd "$MOCK_ROOT"
}

# Display environment summary
show_summary() {
    echo
    echo "${YELLOW}╔════════════════════════════════════════╗${NC}"
    echo "${YELLOW}║        Mock Environment Summary         ║${NC}"
    echo "${YELLOW}╚════════════════════════════════════════╝${NC}"
    echo
    
    echo_step "Created environments in: $MOCK_ROOT"
    echo
    
    for dir in */; do
        if [[ -d "$dir" ]]; then
            echo "  📁 ${BLUE}$dir${NC}"
            
            # Show git status for each directory
            cd "$dir"
            if [[ -d .git ]]; then
                local status=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
                local branch=$(git branch --show-current 2>/dev/null)
                echo "     🌿 Branch: $branch"
                if [[ $status -gt 0 ]]; then
                    echo "     📝 $status changes"
                fi
                
                # Check for rebase/merge states
                if [[ -d .git/rebase-merge || -d .git/rebase-apply ]]; then
                    echo "     🔄 Rebase in progress"
                fi
                if [[ -f .git/MERGE_HEAD ]]; then
                    echo "     🔀 Merge in progress"
                fi
            fi
            
            # Show project type
            if [[ -f pyproject.toml || -f requirements.txt ]]; then
                echo "     🐍 Python project"
            fi
            if [[ -f package.json ]]; then
                echo "     ⬢ Node.js project"
            fi
            if [[ -f go.mod ]]; then
                echo "     🐹 Go project"
            fi
            if [[ -f Cargo.toml ]]; then
                echo "     🦀 Rust project"
            fi
            if [[ -f pom.xml || -f build.gradle ]]; then
                echo "     ☕ Java project"
            fi
            if [[ -f docker-compose.yml ]]; then
                echo "     🐳 Docker Compose"
            fi
            if [[ -f *.tf ]]; then
                echo "     🏗️ Terraform"
            fi
            
            echo
            cd "$MOCK_ROOT"
        fi
    done
    
    echo_success "Mock environment setup complete!"
    echo
    echo "Usage:"
    echo "  cd $MOCK_ROOT/<project-name>"
    echo "  # Test the theme in different contexts"
}

# Main execution
main() {
    init_environment
    create_demo_environments
    show_summary
}

# Execute if run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi