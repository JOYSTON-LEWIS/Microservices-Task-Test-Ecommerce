# E-Commerce Microservices Application Deployment and Scalability with Docker and Terraform

Description:
- This Project is a full-stack MERN e-commerce application built with microservices architecture,
  featuring 4 separate Node.js backend services and a React frontend.
- It consists of 4 backend microservices (`user`, `product`, `cart`, `order`) and 1 frontend,
  all containerized and deployed via Docker on EC2 instances.
- This project provisions AWS infrastructure and deploys a multi-service Node.js e-commerce
  application using Terraform and Docker. 


## 📁 Project Structure

```
ecommerce-microservices/
├── backend/
│   ├── user-service/
│   │   ├── models/
│   │   ├── routes/
│   │   ├── middleware/
│   │   ├── server.js
│   │   └── package.json
│   │   └── DockerFile
│   ├── product-service/
│   │   ├── models/
│   │   ├── routes/
│   │   ├── server.js
│   │   └── package.json
│   │   └── DockerFile
│   ├── cart-service/
│   │   ├── models/
│   │   ├── routes/
│   │   ├── server.js
│   │   └── package.json
│   │   └── DockerFile
│   └── order-service/
│       ├── models/
│       ├── routes/
│       ├── server.js
│       └── package.json
│       └── DockerFile
├── frontend/
│   ├── public/
│   ├── src/
│   │   ├── components/
│   │   ├── contexts/
│   │   ├── pages/
│   │   ├── services/
│   │   ├── App.js
│   │   └── index.js
│   └── package.json
│   └── DockerFile
├── package.json
└── README.md
└── initial-setup.sh
└── second-step.sh
└── third-step.sh
└── main.tf
``` 

## 🏗️ Application Configuration

This application demonstrates modern microservices architecture with the following components:

```
Frontend (React) → API Gateway → Microservices
                                    ├── User Service (3001)
                                    ├── Product Service (3002)
                                    ├── Cart Service (3003)
                                    └── Order Service (3004)
```

Create `.env` files in each service directory:

💡 Note: Remove the trailing slash `/` at the end of the MongoDB URI if present.

**backend/user-service/.env:**
```env
PORT=3001
MONGO_DB_ATLAS_URL=<YOUR_MONGODB_URI_WITHOUT_FORWARD_SLASH>
DB_NAME=ecommerce_users
JWT_SECRET=your-jwt-secret-key
```

**backend/product-service/.env:**
```env
PORT=3002
MONGO_DB_ATLAS_URL=<YOUR_MONGODB_URI_WITHOUT_FORWARD_SLASH>
DB_NAME=ecommerce_products
```

**backend/cart-service/.env:**
```env
PORT=3003
MONGO_DB_ATLAS_URL=<YOUR_MONGODB_URI_WITHOUT_FORWARD_SLASH>
DB_NAME=ecommerce_carts
PRODUCT_SERVICE_URL=http://localhost:3002
```

**backend/order-service/.env:**
```env
PORT=3004
MONGO_DB_ATLAS_URL=<YOUR_MONGODB_URI_WITHOUT_FORWARD_SLASH>
DB_NAME=ecommerce_orders
CART_SERVICE_URL=http://localhost:3003
PRODUCT_SERVICE_URL=http://localhost:3002
USER_SERVICE_URL=http://localhost:3001
```

**frontend/.env:**
```env
REACT_APP_USER_SERVICE_URL=http://localhost:3001
REACT_APP_PRODUCT_SERVICE_URL=http://localhost:3002
REACT_APP_CART_SERVICE_URL=http://localhost:3003
REACT_APP_ORDER_SERVICE_URL=http://localhost:3004
```

### Running the Application


** Run services individually**

Terminal 1 - User Service:
```bash
cd backend/user-service && npm install && node server.js
```

Terminal 2 - Product Service:
```bash
cd backend/product-service && npm install && node server.js
```

Terminal 3 - Cart Service:
```bash
cd backend/cart-service && npm install && node server.js
```

Terminal 4 - Order Service:
```bash
cd backend/order-service && npm install && node server.js
```

Terminal 5 - Frontend:
```bash
cd frontend && npm install && npm start
```

The application will be available at:
- Frontend: http://localhost:3000
- User Service: http://localhost:3001
- Product Service: http://localhost:3002
- Cart Service: http://localhost:3003
- Order Service: http://localhost:3004

## 🔧 API Testing

You can test the APIs using tools like Postman or curl:

```bash
# Health check for all services
curl http://localhost:3001/health
curl http://localhost:3002/health
curl http://localhost:3003/health
curl http://localhost:3004/health

# Register a new user
curl -X POST http://localhost:3001/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"firstName":"John","lastName":"Doe","email":"john@example.com","password":"password123"}'

# Get products
curl http://localhost:3002/api/products

# Get categories
curl http://localhost:3002/api/categories
```

## 🚀 Deployment

## ✅ Prerequisites: Input Variables

| Variable Name            | Description                                 | Example Value                                |
|--------------------------|---------------------------------------------|----------------------------------------------|
| `DOCKER_USERNAME`        | DockerHub username                          | `your-docker-user`                           |
| `DOCKER_PAT`             | DockerHub personal access token             | `ghp_abcd1234...`                            |
| `DOCKER_REPO_BASE`       | DockerHub repo base                         | `your-docker-user/microservices-task`        |
| `DB_NAME_USER`           | MongoDB database name for user service      | `user_db`                                    |
| `DB_NAME_PRODUCT`        | MongoDB database name for product service   | `product_db`                                 |
| `DB_NAME_CART`           | MongoDB database name for cart service      | `cart_db`                                    |
| `DB_NAME_ORDER`          | MongoDB database name for order service     | `order_db`                                   |
| `MONGO_DB_ATLAS_URL`     | MongoDB Atlas connection string             | `mongodb+srv://...`                          |
| `AWS_ACCESS_ID`          | AWS Access Key ID                           | `AKIA...`                                    |
| `AWS_ACCESS_KEY`         | AWS Secret Access Key                       | `wJalrXUtnFEMI/K7MDENG/bPxRfiCY...`          |
| `AWS_REGION_ID`          | AWS region                                  | `ap-south-1`                                 |
| `AWS_SSH_KEY_NAME`       | AWS EC2 key-pair name                       | `my-ec2-key`                                 |
| `AWS_INSTANCE_TYPE`      | EC2 instance type                           | `t3.medium`                                  |
| `AWS_AMI_ID`             | Ubuntu AMI ID                               | `ami-0f918f7e67a3323f0`                      |
| `AWS_VPC_ID`             | AWS VPC ID                                  | `vpc-0ab12345`                               |
| `AWS_SUBNET_ID`          | AWS Subnet ID                               | `subnet-0abc1234`                            |
| `AWS_SECURITY_GROUP_ID`  | AWS Security Group ID                       | `sg-0123abc456de`                            |
| `FRONTEND_PORT`          | Frontend port                               | `3000`                                       |
| `BACKEND_PORT_USER`      | User service port                           | `3001`                                       |
| `BACKEND_PORT_PRODUCT`   | Product service port                        | `3002`                                       |
| `BACKEND_PORT_CART`      | Cart service port                           | `3003`                                       |
| `BACKEND_PORT_ORDER`     | Order service port                          | `3004`                                       |
| `FRONTEND_DOMAIN_URL`    | Frontend domain or IP                       | `http://ec2-xx-xxx.compute.amazonaws.com`    |
| `BACKEND_DOMAIN_URL`     | Backend base domain or IP                   | `http://ec2-xx-xxx.compute.amazonaws.com`    |
|--------------------------|---------------------------------------------|----------------------------------------------|

---

## 📜 Script Execution Flow

This project uses **3 main scripts** to automate the full lifecycle:

### 🔹 1. `initial-setup.sh`

- Run manually **inside your EC2 instance (Ubuntu 22.04)**
- Sets up required packages and permissions
- Installs Docker, configures system

```bash
nano initial-setup.sh
```

```bash
#!/bin/bash

echo "Executing initial-step.sh"

# Fail on error
set -e

echo "🔧 Updating system packages..."
sudo apt update -y && sudo apt upgrade -y

echo "🐳 Installing Docker..."
sudo apt install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER

echo "🔁 Installing Git, curl, unzip..."
sudo apt install -y git curl unzip

echo "📦 Installing AWS CLI v2.15.0..."
cd /tmp
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-2.15.0.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
sudo ./aws/install --update
echo "Cleaning up temp files"
rm -rf /tmp/awscliv2.zip /tmp/aws
cd ~
echo "Verifing AWS installation"
aws --version

echo "📦 Installing Terraform..."
TERRAFORM_VERSION="1.7.5"
curl -fsSL "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -o terraform.zip
unzip terraform.zip
sudo mv terraform /usr/local/bin/
terraform -v
cd ~
echo "Cleaning up Terraform Installation"
rm -f terraform.zip

echo "✅ Terraform Installed"

echo "Creating Empty Executable Scripts for Further Steps"
for script in second-step.sh third-step.sh; do
  if [ ! -f "$script" ]; then
    echo "📝 Creating $script..."
    echo -e "#!/bin/bash\n" > "$script"
    chmod +x "$script"
  else
    echo "ℹ️ $script already exists. Skipping creation."
  fi
done

echo "🔐 Added $USER to docker group (for non-sudo Docker use)"
echo "🚪 Please log out and log back in for Docker group changes to apply."

echo "initial-step.sh Completed Successfully"

```

```bash
chmod +x initial-setup.sh
```
```bash
./initial-setup.sh
```


🔹 2. second-step.sh
- Creates Dockerfiles for all 5 services
- Builds Docker images locally
- Pushes images to DockerHub using credentials
- Pulls them back on the EC2 instance and runs the containers
- Each service returns "Service Running" response
- MongoDB connection and environment variables are injected

```bash
nano second-step.sh
```

```bash
#!/bin/bash

echo "Executing second-step.sh"


# Step 0: Accept input parameters
DOCKER_USERNAME="$1"
DOCKER_PAT="$2"
DOCKER_REPO_BASE="$3"

DB_NAME_3001="$4"
DB_NAME_3002="$5"
DB_NAME_3003="$6"
DB_NAME_3004="$7"

MONGO_DB_ATLAS_URL="$8"


if [[ -z "$DOCKER_USERNAME" || -z "$DOCKER_PAT" || -z "$DOCKER_REPO_BASE" ]]; then
  echo "❌ Usage: $0 <docker-username> <docker-pat> <docker-repo-base>"
  exit 1
fi

if [[ -z "$DB_NAME_3001" || -z "$DB_NAME_3002" || -z "$DB_NAME_3003" || -z "$DB_NAME_3004" ]]; then
  echo "❌ Missing DB names for services on ports 3001–3004."
  echo "❌ Usage: $0 <docker-username> <docker-pat> <docker-repo-base> <db1> <db2> <db3> <db4>"
  exit 1
fi

if [[ -z "$MONGO_DB_ATLAS_URL" ]]; then
  echo "❌ Missing Mongo DB URI"
  exit 1
fi

echo "✅ Using DockerHub Username: $DOCKER_USERNAME"
echo "✅ Using Repo Base Name: $DOCKER_REPO_BASE"

# Login to DockerHub
echo "$DOCKER_PAT" | docker login -u "$DOCKER_USERNAME" --password-stdin

if [[ $? -ne 0 ]]; then
  echo "❌ Docker login failed. Check credentials."
  exit 1
fi

echo "🧹 Checking for existing project folder..."
if [ -d "Microservices-Task-Test-Ecommerce" ]; then
  echo "🧹 Removing existing Microservices-Task-Test-Ecommerce directory..."
  rm -rf Microservices-Task-Test-Ecommerce
fi

echo "📦 Cloning project repo..."
git clone https://github.com/JOYSTON-LEWIS/Microservices-Task-Test-Ecommerce.git
cd Microservices-Task-Test-Ecommerce

echo "📁 Generating Dockerfiles for all microservices..."

# Common Alpine-based Node 20 Dockerfile content for backend
read -r -d '' BACKEND_DOCKERFILE << 'EOF'
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE ${PORT}
CMD ["node", "server.js"]
EOF

# Frontend Dockerfile with runtime env support
read -r -d '' FRONTEND_DOCKERFILE << 'EOF'
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
EOF

# Paths to backend services
BACKEND_SERVICES=("user-service" "product-service" "cart-service" "order-service")
for SERVICE in "${BACKEND_SERVICES[@]}"; do
  TARGET="./backend/${SERVICE}/Dockerfile"
  echo "$BACKEND_DOCKERFILE" > "$TARGET"
  echo "✅ Created Dockerfile for $SERVICE"
done

# Frontend Dockerfile
echo "$FRONTEND_DOCKERFILE" > ./frontend/Dockerfile
echo "✅ Created Dockerfile for frontend"

# Make Dockerfiles executable if needed (not required usually)
chmod +x ./backend/*/Dockerfile ./frontend/Dockerfile || true

echo "🚀 Dockerfiles created for all services successfully."

# Step 4: Remove old Docker images
echo "🗑️ Removing previous local Docker images..."
docker image prune -af || true

# Step 6: Build and push images to a single Docker repo with service-name tags
echo "🏗️ Building and pushing Docker images into a single repo..."

# Backend services
for SERVICE in "${BACKEND_SERVICES[@]}"; do
  TAG_NAME="${SERVICE}"  # e.g., user-service
  IMAGE_NAME="${DOCKER_USERNAME}/${DOCKER_REPO_BASE}:${TAG_NAME}"
  SERVICE_PATH="./backend/${SERVICE}"
  
  echo "🐳 Building $SERVICE as $IMAGE_NAME..."
  docker build -t "$IMAGE_NAME" "$SERVICE_PATH"

  echo "🚀 Pushing $IMAGE_NAME to Docker Hub..."
  docker push "$IMAGE_NAME"
done

# Frontend
FRONTEND_TAG="frontend"
FRONTEND_IMAGE="${DOCKER_USERNAME}/${DOCKER_REPO_BASE}:${FRONTEND_TAG}"

echo "🐳 Building frontend as $FRONTEND_IMAGE..."
docker build -t "$FRONTEND_IMAGE" ./frontend

echo "🚀 Pushing $FRONTEND_IMAGE to Docker Hub..."
docker push "$FRONTEND_IMAGE"

echo "✅ All Docker images built and pushed successfully!"

echo "🔪 Killing any processes using ports 3000 to 3004..."

for port in {3000..3004}; do
  pid=$(lsof -ti tcp:$port)
  if [[ -n "$pid" ]]; then
    echo "⚠️  Port $port is in use by PID $pid. Killing..."
    kill -9 $pid
  else
    echo "✅ Port $port is free."
  fi
done

echo "🔍 Starting container tests..."

# Create .env files with configuration, run the docker images and test them out

echo "🌐 Fetching EC2 Public IP..."
EC2_IP=$(curl -s http://checkip.amazonaws.com)
echo "✅ EC2 Public IP: $EC2_IP"

docker stop $(docker ps -aq)
docker rm $(docker ps -aq)

echo "🔍 Starting container tests..."

# 🧪 USER SERVICE
echo "🧪 Running user-service on port 3001 with DB $DB_NAME_3001..."
USER_IMAGE="${DOCKER_USERNAME}/${DOCKER_REPO_BASE}:user-service"
docker run -d \
  -p 3001:3001 \
  --name user-service-test \
  -e PORT=3001 \
  -e MONGO_DB_ATLAS_URL="${MONGO_DB_ATLAS_URL}" \
  -e DB_NAME="${DB_NAME_3001}" \
  -e JWT_SECRET="your-jwt-secret-key" \
  "$USER_IMAGE" \
  sh -c 'echo -e "PORT=$PORT\nMONGO_DB_ATLAS_URL=$MONGO_DB_ATLAS_URL\nDB_NAME=$DB_NAME\nJWT_SECRET=$JWT_SECRET" > .env && node server.js'

# 🧪 PRODUCT SERVICE
echo "🧪 Running product-service on port 3002 with DB $DB_NAME_3002..."
PRODUCT_IMAGE="${DOCKER_USERNAME}/${DOCKER_REPO_BASE}:product-service"
docker run -d \
  -p 3002:3002 \
  --name product-service-test \
  -e PORT=3002 \
  -e MONGO_DB_ATLAS_URL="${MONGO_DB_ATLAS_URL}" \
  -e DB_NAME="${DB_NAME_3002}" \
   "$PRODUCT_IMAGE" \
  sh -c 'echo -e "PORT=$PORT\nMONGO_DB_ATLAS_URL=$MONGO_DB_ATLAS_URL\nDB_NAME=$DB_NAME" > .env && node server.js'

# 🧪 CART SERVICE
echo "🧪 Running cart-service on port 3003 with DB $DB_NAME_3003..."
CART_IMAGE="${DOCKER_USERNAME}/${DOCKER_REPO_BASE}:cart-service"
docker run -d \
  -p 3003:3003 \
  --name cart-service-test \
  -e PORT=3003 \
  -e MONGO_DB_ATLAS_URL="${MONGO_DB_ATLAS_URL}" \
  -e DB_NAME="${DB_NAME_3003}" \
  -e PRODUCT_SERVICE_URL="http://${EC2_IP}:3002" \
  "$CART_IMAGE" \
  sh -c 'echo -e "PORT=$PORT\nMONGO_DB_ATLAS_URL=$MONGO_DB_ATLAS_URL\nDB_NAME=$DB_NAME\nPRODUCT_SERVICE_URL=$PRODUCT_SERVICE_URL" > .env && node server.js'

# 🧪 ORDER SERVICE
echo "🧪 Running order-service on port 3004 with DB $DB_NAME_3004..."
ORDER_IMAGE="${DOCKER_USERNAME}/${DOCKER_REPO_BASE}:order-service"
docker run -d \
  -p 3004:3004 \
  --name order-service-test \
  -e PORT=3004 \
  -e MONGO_DB_ATLAS_URL="${MONGO_DB_ATLAS_URL}" \
  -e DB_NAME="${DB_NAME_3004}" \
  -e CART_SERVICE_URL="http://${EC2_IP}:3003" \
  -e PRODUCT_SERVICE_URL="http://${EC2_IP}:3002" \
  -e USER_SERVICE_URL="http://${EC2_IP}:3001" \
  "$ORDER_IMAGE" \
  sh -c 'echo -e "PORT=$PORT\nMONGO_DB_ATLAS_URL=$MONGO_DB_ATLAS_URL\nDB_NAME=$DB_NAME\nCART_SERVICE_URL=$CART_SERVICE_URL\nPRODUCT_SERVICE_URL=$PRODUCT_SERVICE_URL\nUSER_SERVICE_URL=$USER_SERVICE_URL" > .env && node server.js'

# Wait for services to start
sleep 7

docker logs -f user-service-test > user-service.log 2>&1 &
docker logs -f product-service-test > product-service.log 2>&1 &
docker logs -f cart-service-test > cart-service.log 2>&1 &
docker logs -f order-service-test > order-service.log 2>&1 &

# 🧪 FRONTEND
echo "🧪 Running frontend container on port 3000..."
FRONTEND_IMAGE="${DOCKER_USERNAME}/${DOCKER_REPO_BASE}:frontend"
docker run -d \
  -p 3000:3000 \
  --name frontend-test \
  -e REACT_APP_USER_SERVICE_URL=http://${EC2_IP}:3001 \
  -e REACT_APP_PRODUCT_SERVICE_URL=http://${EC2_IP}:3002 \
  -e REACT_APP_CART_SERVICE_URL=http://${EC2_IP}:3003 \
  -e REACT_APP_ORDER_SERVICE_URL=http://${EC2_IP}:3004 \
  "$FRONTEND_IMAGE" \
  sh -c 'echo -e "REACT_APP_USER_SERVICE_URL=$REACT_APP_USER_SERVICE_URL\nREACT_APP_PRODUCT_SERVICE_URL=$REACT_APP_PRODUCT_SERVICE_URL\nREACT_APP_CART_SERVICE_URL=$REACT_APP_CART_SERVICE_URL\nREACT_APP_ORDER_SERVICE_URL=$REACT_APP_ORDER_SERVICE_URL" > .env && npm start'

sleep 5

echo "✅ All services launched:"
echo "- Frontend:           http://${EC2_IP}:3000"
echo "- User Service:       http://${EC2_IP}:3001"
echo "- Product Service:    http://${EC2_IP}:3002"
echo "- Cart Service:       http://${EC2_IP}:3003"
echo "- Order Service:      http://${EC2_IP}:3004"

# Health checks
echo "🔍 Testing health endpoint at http://${EC2_IP}:3001/health"
curl --fail --silent http://${EC2_IP}:3001/health || echo "❌ Health check failed for user-service"

echo "🔍 Testing health endpoint at http://${EC2_IP}:3002/health"
curl --fail --silent http://${EC2_IP}:3002/health || echo "❌ Health check failed for product-service"

echo "🔍 Testing health endpoint at http://${EC2_IP}:3003/health"
curl --fail --silent http://${EC2_IP}:3003/health || echo "❌ Health check failed for cart-service"

echo "🔍 Testing health endpoint at http://${EC2_IP}:3004/health"
curl --fail --silent http://${EC2_IP}:3004/health || echo "❌ Health check failed for order-service"

echo "🔍 Testing frontend endpoint at http://${EC2_IP}:3000"
curl --fail --silent http://${EC2_IP}:3000 || echo "❌ Frontend test failed"

echo "✅ All image verifications completed."

echo "second-step.sh Completed Successfully"
```

```bash
./second-step.sh \
  DOCKER_USERNAME="your-docker-username" \
  DOCKER_PAT="your-docker-pat" \
  DOCKER_REPO_BASE="your-dockerhub-repo-base" \
  DB_NAME_3001="user_db" \
  DB_NAME_3002="product_db" \
  DB_NAME_3003="cart_db" \
  DB_NAME_3004="order_db" \
  MONGO_DB_ATLAS_URL="your-mongodb-atlas-url"
```

🔹 3. third-step.sh
- Provisions infrastructure using Terraform:
- Security Groups with HTTP + Internal Access
- Installs Docker via user-data or remote-exec
- Pulls Docker images and runs services
- Outputs the public IP/DNS for the frontend
- EC2 (Ubuntu, t3.medium, 30GB)
- VPC + Public Subnet

```bash
nano third-step.sh
```
```bash
#!/bin/bash

set -e

echo "🚀 Starting third-step.sh (Simplified Terraform Deployment)"

if [ "$#" -ne 24 ]; then
  echo "❌ Error: 24 parameters required."
  echo "Usage: $0 DOCKER_USERNAME DOCKER_PAT DOCKER_REPO_BASE DB_NAME_USER DB_NAME_PRODUCT DB_NAME_CART DB_NAME_ORDER MONGO_DB_ATLAS_URL AWS_ACCESS_ID AWS_ACCESS_KEY AWS_REGION_ID AWS_SSH_KEY_NAME AWS_INSTANCE_TYPE AWS_AMI_ID AWS_VPC_ID AWS_SUBNET_ID AWS_SECURITY_GROUP_ID FRONTEND_PORT BACKEND_PORT_USER BACKEND_PORT_PRODUCT BACKEND_PORT_CART BACKEND_PORT_ORDER FRONTEND_DOMAIN_URL BACKEND_DOMAIN_URL"
  exit 1
fi

# Assign inputs
DOCKER_USERNAME="${1}"
DOCKER_PAT="${2}"
DOCKER_REPO_BASE="${3}"
DB_NAME_USER="${4}"
DB_NAME_PRODUCT="${5}"
DB_NAME_CART="${6}"
DB_NAME_ORDER="${7}"
MONGO_DB_ATLAS_URL="${8}"
AWS_ACCESS_ID="${9}"
AWS_ACCESS_KEY="${10}"
AWS_REGION_ID="${11}"
AWS_SSH_KEY_NAME="${12}"
AWS_INSTANCE_TYPE="${13}"
AWS_AMI_ID="${14}"
AWS_VPC_ID="${15}"
AWS_SUBNET_ID="${16}"
AWS_SECURITY_GROUP_ID="${17}"
FRONTEND_PORT=${18}
BACKEND_PORT_USER=${19}
BACKEND_PORT_PRODUCT=${20}
BACKEND_PORT_CART=${21}
BACKEND_PORT_ORDER=${22}
FRONTEND_DOMAIN_URL="${23}"
BACKEND_DOMAIN_URL="${24}"

AWS_OUTPUT_FORMAT="json"
TERRAFORM_DIR="terraform-basic-deployment"
JWT_SECRET="your-jwt-secret-key"

echo "🔄 Configuring AWS CLI..."
aws configure set aws_access_key_id "${AWS_ACCESS_ID}"
aws configure set aws_secret_access_key "${AWS_ACCESS_KEY}"
aws configure set region "${AWS_REGION_ID}"
aws configure set output "${AWS_OUTPUT_FORMAT}"

echo "🔄 Preparing Terraform directory..."
rm -rf "$TERRAFORM_DIR"
mkdir -p "$TERRAFORM_DIR" && cd "$TERRAFORM_DIR" || exit 1

echo "🧾 Writing Terraform config..."

cat > main.tf <<EOF
provider "aws" {
  region     = "${AWS_REGION_ID}"
  access_key = "${AWS_ACCESS_ID}"
  secret_key = "${AWS_ACCESS_KEY}"
}

resource "aws_instance" "ecom_instance" {
  count                  = 2
  ami                    = "${AWS_AMI_ID}"
  instance_type          = "${AWS_INSTANCE_TYPE}"
  subnet_id              = "${AWS_SUBNET_ID}"
  vpc_security_group_ids = ["${AWS_SECURITY_GROUP_ID}"]
  key_name               = "${AWS_SSH_KEY_NAME}"

  user_data = <<-EOD
    #!/bin/bash
    apt update -y && apt install -y docker.io curl jq

    echo "🔍 Waiting for Docker to be installed and running..."
    until command -v docker >/dev/null 2>&1 && sudo docker version >/dev/null 2>&1; do
      echo "⏳ Docker not ready yet, retrying in 5 seconds..."
      sleep 5
    done
    echo "✅ Docker is ready."

    echo "🔍 Waiting for public IP..."
    PUBLIC_IP=""
    while [ -z "\$PUBLIC_IP" ]; do
      PUBLIC_IP=\$(curl -s http://checkip.amazonaws.com)
      sleep 2
    done
    echo "✅ Public IP is: \$PUBLIC_IP"

    echo "${DOCKER_PAT}" | sudo docker login -u "${DOCKER_USERNAME}" --password-stdin
    sudo docker pull ${DOCKER_USERNAME}/${DOCKER_REPO_BASE}:frontend
    sudo docker pull ${DOCKER_USERNAME}/${DOCKER_REPO_BASE}:user-service
    sudo docker pull ${DOCKER_USERNAME}/${DOCKER_REPO_BASE}:product-service
    sudo docker pull ${DOCKER_USERNAME}/${DOCKER_REPO_BASE}:cart-service
    sudo docker pull ${DOCKER_USERNAME}/${DOCKER_REPO_BASE}:order-service

    sudo docker run -d -p ${FRONTEND_PORT}:3000 -e PUBLIC_IP=\$PUBLIC_IP ${DOCKER_USERNAME}/${DOCKER_REPO_BASE}:frontend sh -c 'echo -e "REACT_APP_USER_SERVICE_URL=http://\\\$PUBLIC_IP:${BACKEND_PORT_USER}\\nREACT_APP_PRODUCT_SERVICE_URL=http://\\\$PUBLIC_IP:${BACKEND_PORT_PRODUCT}\\nREACT_APP_CART_SERVICE_URL=http://\\\$PUBLIC_IP:${BACKEND_PORT_CART}\\nREACT_APP_ORDER_SERVICE_URL=http://\\\$PUBLIC_IP:${BACKEND_PORT_ORDER}" > .env && npm start'

    sudo docker run -d -p ${BACKEND_PORT_USER}:3001 -e PUBLIC_IP=\$PUBLIC_IP ${DOCKER_USERNAME}/${DOCKER_REPO_BASE}:user-service sh -c 'echo -e "PORT=${BACKEND_PORT_USER}\\nMONGO_DB_ATLAS_URL=${MONGO_DB_ATLAS_URL}\\nDB_NAME=${DB_NAME_USER}\\nJWT_SECRET=${JWT_SECRET}" > .env && node server.js'

    sudo docker run -d -p ${BACKEND_PORT_PRODUCT}:3002 -e PUBLIC_IP=\$PUBLIC_IP ${DOCKER_USERNAME}/${DOCKER_REPO_BASE}:product-service sh -c 'echo -e "PORT=${BACKEND_PORT_PRODUCT}\\nMONGO_DB_ATLAS_URL=${MONGO_DB_ATLAS_URL}\\nDB_NAME=${DB_NAME_PRODUCT}" > .env && node server.js'

    sudo docker run -d -p ${BACKEND_PORT_CART}:3003 -e PUBLIC_IP=\$PUBLIC_IP ${DOCKER_USERNAME}/${DOCKER_REPO_BASE}:cart-service sh -c 'echo -e "PORT=${BACKEND_PORT_CART}\\nMONGO_DB_ATLAS_URL=${MONGO_DB_ATLAS_URL}\\nDB_NAME=${DB_NAME_CART}\\nPRODUCT_SERVICE_URL=http://\\\$PUBLIC_IP:${BACKEND_PORT_PRODUCT}" > .env && node server.js'

    sudo docker run -d -p ${BACKEND_PORT_ORDER}:3004 -e PUBLIC_IP=\$PUBLIC_IP ${DOCKER_USERNAME}/${DOCKER_REPO_BASE}:order-service sh -c 'echo -e "PORT=${BACKEND_PORT_ORDER}\\nMONGO_DB_ATLAS_URL=${MONGO_DB_ATLAS_URL}\\nDB_NAME=${DB_NAME_ORDER}\\nCART_SERVICE_URL=http://\\\$PUBLIC_IP:${BACKEND_PORT_CART}\\nPRODUCT_SERVICE_URL=http://\\\$PUBLIC_IP:${BACKEND_PORT_PRODUCT}\\nUSER_SERVICE_URL=http://\\\$PUBLIC_IP:${BACKEND_PORT_USER}" > .env && node server.js'
  EOD

  tags = {
    Name = "ecom-instance-\${count.index + 1}"
  }
}

output "ecom_instance_public_ips" {
  value = aws_instance.ecom_instance[*].public_ip
}
EOF

echo "🚀 Running Terraform..."
terraform init -input=false
terraform apply -auto-approve -input=false

INSTANCE_IPS=$(terraform output -json ecom_instance_public_ips | jq -r '.[]')

echo "⏳ Waiting for EC2 instances to become reachable and services to start..."

for ip in $INSTANCE_IPS; do
  echo "🔍 Waiting for $ip (SSH)..."
  while ! nc -z -w5 "$ip" 22; do
    echo "⏳ $ip not reachable via SSH yet..."
    sleep 5
  done
  echo "✅ $ip is up and reachable via SSH."

  echo "🌐 Waiting for frontend on $ip:$FRONTEND_PORT..."
  until curl -s --max-time 60 "http://$ip:$FRONTEND_PORT" > /dev/null; do
    echo "⏳ Still waiting for frontend on $ip..."
    sleep 5
  done
  echo "✅ Frontend is up on $ip:$FRONTEND_PORT"

  echo "🧪 Checking backend services..."
  for port in $BACKEND_PORT_USER $BACKEND_PORT_PRODUCT $BACKEND_PORT_CART $BACKEND_PORT_ORDER; do
    echo "   - Checking http://$ip:$port/health"
    until curl -s --max-time 60 "http://$ip:$port/health" > /dev/null; do
      echo "     ⏳ Still waiting on port $port..."
      sleep 5
    done
    echo "   ✅ Service up on port $port"
  done

  echo ""
done


echo "🌐 Fetching EC2 instance public IPs..."

echo "✅ EC2 Instances Deployed at:"
for ip in $INSTANCE_IPS; do
  echo " - http://$ip:${FRONTEND_PORT} (Frontend)"
  echo " - http://$ip:${BACKEND_PORT_USER} (User Service)"
  echo " - http://$ip:${BACKEND_PORT_PRODUCT} (Product Service)"
  echo " - http://$ip:${BACKEND_PORT_CART} (Cart Service)"
  echo " - http://$ip:${BACKEND_PORT_ORDER} (Order Service)"
  echo ""

  echo "Running Tests"
  echo "🌐 Frontend Homepage:"
  curl -s "http://$ip:$FRONTEND_PORT"
  echo "✅ Frontend responded correctly."

  echo "🧪 User Service:"
  curl -s "http://$ip:$BACKEND_PORT_USER/health" 
  echo "✅ User service is running."

  echo "🧪 Product Service:"
  curl -s "http://$ip:$BACKEND_PORT_PRODUCT/health"
  echo "✅ Product service is running."

  echo "🧪 Cart Service:"
  curl -s "http://$ip:$BACKEND_PORT_CART/health"
  echo "✅ Cart service is running."

  echo "🧪 Order Service:"
  curl -s "http://$ip:$BACKEND_PORT_ORDER/health"
  echo "✅ Order service is running."

  echo ""

done

echo "✅ Deployment complete!"
```

```bash
./third-step.sh
DOCKER_USERNAME="${1}"
DOCKER_PAT="${2}"
DOCKER_REPO_BASE="${3}"
DB_NAME_USER="${4}"
DB_NAME_PRODUCT="${5}"
DB_NAME_CART="${6}"
DB_NAME_ORDER="${7}"
MONGO_DB_ATLAS_URL="${8}"
AWS_ACCESS_ID="${9}"
AWS_ACCESS_KEY="${10}"
AWS_REGION_ID="${11}"
AWS_SSH_KEY_NAME="${12}"
AWS_INSTANCE_TYPE="${13}"
AWS_AMI_ID="${14}"
AWS_VPC_ID="${15}"
AWS_SUBNET_ID="${16}"
AWS_SECURITY_GROUP_ID="${17}"
FRONTEND_PORT=${18}
BACKEND_PORT_USER=${19}
BACKEND_PORT_PRODUCT=${20}
BACKEND_PORT_CART=${21}
BACKEND_PORT_ORDER=${22}
FRONTEND_DOMAIN_URL="${23}"
BACKEND_DOMAIN_URL="${24}"

```

💡 Note: Validation Steps are included within scripts. Screenshots also include validating the Deployment

### 📸 Screenshots:

![Img_01](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Skill_Test_Three_Output_Screenshots/Img_01.png)
![Img_02](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Skill_Test_Three_Output_Screenshots/Img_02.png)
![Img_03](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Skill_Test_Three_Output_Screenshots/Img_03.png)
![Img_04](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Skill_Test_Three_Output_Screenshots/Img_04.png)
![Img_05](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Skill_Test_Three_Output_Screenshots/Img_05.png)
![Img_06](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Skill_Test_Three_Output_Screenshots/Img_06.png)
![Img_07](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Skill_Test_Three_Output_Screenshots/Img_07.png)
![Img_08](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Skill_Test_Three_Output_Screenshots/Img_08.png)
![Img_09](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Skill_Test_Three_Output_Screenshots/Img_09.png)
![Img_10](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Skill_Test_Three_Output_Screenshots/Img_10.png)
![Img_11](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Skill_Test_Three_Output_Screenshots/Img_11.png)
![Img_12](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Skill_Test_Three_Output_Screenshots/Img_12.png)
![Img_13](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Skill_Test_Three_Output_Screenshots/Img_13.png)
![Img_14](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Skill_Test_Three_Output_Screenshots/Img_14.png)
![Img_15](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Skill_Test_Three_Output_Screenshots/Img_15.png)
![Img_16](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Skill_Test_Three_Output_Screenshots/Img_16.png)
![Img_17](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Skill_Test_Three_Output_Screenshots/Img_17.png)
![Img_18](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Skill_Test_Three_Output_Screenshots/Img_18.png)
![Img_19](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Skill_Test_Three_Output_Screenshots/Img_19.png)
![Img_20](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Skill_Test_Three_Output_Screenshots/Img_20.png)
![Img_21](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Skill_Test_Three_Output_Screenshots/Img_21.png)
![Img_22](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Skill_Test_Three_Output_Screenshots/Img_22.png)
![Img_23](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Skill_Test_Three_Output_Screenshots/Img_23.png)
![Img_24](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Skill_Test_Three_Output_Screenshots/Img_24.png)
![Img_25](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Skill_Test_Three_Output_Screenshots/Img_25.png)
![Img_26](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Skill_Test_Three_Output_Screenshots/Img_26.png)
![Img_27](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Skill_Test_Three_Output_Screenshots/Img_27.png)
![Img_28](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Skill_Test_Three_Output_Screenshots/Img_28.png)
![Img_29](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Skill_Test_Three_Output_Screenshots/Img_29.png)
![Img_30](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Skill_Test_Three_Output_Screenshots/Img_30.png)
![Img_31](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Skill_Test_Three_Output_Screenshots/Img_31.png)
![Img_32](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Skill_Test_Three_Output_Screenshots/Img_32.png)
![Img_33](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Skill_Test_Three_Output_Screenshots/Img_33.png)
![Img_34](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Skill_Test_Three_Output_Screenshots/Img_34.png)
![Img_35](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Skill_Test_Three_Output_Screenshots/Img_35.png)
![Img_36](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Skill_Test_Three_Output_Screenshots/Img_36.png)
![Img_37](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Skill_Test_Three_Output_Screenshots/Img_37.png)


## 🔮 Future Enhancements

- Terraform Variables and tfvars implementation
- Implementation of deployment via https, loadbalancer

## 📜 License
This project is licensed under the MIT License.

## 🤝 Contributing
Feel free to fork and improve the scripts! ⭐ If you find this project useful, please consider starring the repo—it really helps and supports my work! 😊

## 📧 Contact
For any queries, reach out via GitHub Issues.

---

🎯 **Thank you for reviewing this project! 🚀**
