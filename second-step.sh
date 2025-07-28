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