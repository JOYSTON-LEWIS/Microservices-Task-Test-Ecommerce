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

