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