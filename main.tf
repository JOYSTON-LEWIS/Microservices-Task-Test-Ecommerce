provider "aws" {
  region     = "ap-south-1"
  access_key = "<YOUR_AWS_ACCESS_KEY>"
  secret_key = "<YOUR_AWS_SECRET_KEY>"
}

resource "aws_instance" "ecom_instance" {
  count                  = 2
  ami                    = "ami-0f918f7e67a3323f0"
  instance_type          = "t3.medium"
  subnet_id              = "subnet-07d68578b0b977526"
  vpc_security_group_ids = ["sg-0f9d12fe68be10711"]
  key_name               = "Joyston_Lewis_VM"

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
    while [ -z "$PUBLIC_IP" ]; do
      PUBLIC_IP=$(curl -s http://checkip.amazonaws.com)
      sleep 2
    done
    echo "✅ Public IP is: $PUBLIC_IP"

    echo "<YOUR_DOCKER_HUB_PAT_TOKEN>" | sudo docker login -u "devopspikachu" --password-stdin
    sudo docker pull devopspikachu/microservices-task-test-ecommerce:frontend
    sudo docker pull devopspikachu/microservices-task-test-ecommerce:user-service
    sudo docker pull devopspikachu/microservices-task-test-ecommerce:product-service
    sudo docker pull devopspikachu/microservices-task-test-ecommerce:cart-service
    sudo docker pull devopspikachu/microservices-task-test-ecommerce:order-service

    sudo docker run -d -p 3000:3000 -e PUBLIC_IP=$PUBLIC_IP devopspikachu/microservices-task-test-ecommerce:frontend sh -c 'echo -e "REACT_APP_USER_SERVICE_URL=http://\$PUBLIC_IP:3001\nREACT_APP_PRODUCT_SERVICE_URL=http://\$PUBLIC_IP:3002\nREACT_APP_CART_SERVICE_URL=http://\$PUBLIC_IP:3003\nREACT_APP_ORDER_SERVICE_URL=http://\$PUBLIC_IP:3004" > .env && npm start'

    sudo docker run -d -p 3001:3001 -e PUBLIC_IP=$PUBLIC_IP devopspikachu/microservices-task-test-ecommerce:user-service sh -c 'echo -e "PORT=3001\nMONGO_DB_ATLAS_URL=<YOUR_MONGODB_URI_WITHOUT_FORWARD_SLASH>\nDB_NAME=ecommerce_users\nJWT_SECRET=your-jwt-secret-key" > .env && node server.js'

    sudo docker run -d -p 3002:3002 -e PUBLIC_IP=$PUBLIC_IP devopspikachu/microservices-task-test-ecommerce:product-service sh -c 'echo -e "PORT=3002\nMONGO_DB_ATLAS_URL=<YOUR_MONGODB_URI_WITHOUT_FORWARD_SLASH>\nDB_NAME=ecommerce_products" > .env && node server.js'

    sudo docker run -d -p 3003:3003 -e PUBLIC_IP=$PUBLIC_IP devopspikachu/microservices-task-test-ecommerce:cart-service sh -c 'echo -e "PORT=3003\nMONGO_DB_ATLAS_URL=<YOUR_MONGODB_URI_WITHOUT_FORWARD_SLASH>\nDB_NAME=ecommerce_carts\nPRODUCT_SERVICE_URL=http://\$PUBLIC_IP:3002" > .env && node server.js'

    sudo docker run -d -p 3004:3004 -e PUBLIC_IP=$PUBLIC_IP devopspikachu/microservices-task-test-ecommerce:order-service sh -c 'echo -e "PORT=3004\nMONGO_DB_ATLAS_URL=<YOUR_MONGODB_URI_WITHOUT_FORWARD_SLASH>\nDB_NAME=ecommerce_orders\nCART_SERVICE_URL=http://\$PUBLIC_IP:3003\nPRODUCT_SERVICE_URL=http://\$PUBLIC_IP:3002\nUSER_SERVICE_URL=http://\$PUBLIC_IP:3001" > .env && node server.js'
  EOD

  tags = {
    Name = "ecom-instance-${count.index + 1}"
  }
}

output "ecom_instance_public_ips" {
  value = aws_instance.ecom_instance[*].public_ip
}