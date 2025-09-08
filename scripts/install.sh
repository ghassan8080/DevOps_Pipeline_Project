#!/bin/bash

# scripts/install.sh (محسّن)
set -e

echo "🚀 بدء تثبيت أدوات DevOps..."

# تحديث النظام
echo "📦 تحديث حزم النظام..."
sudo apt update && sudo apt upgrade -y

# تثبيت الحزم الأساسية
echo "⚙️ تثبيت الحزم الأساسية..."
sudo apt install -y     openjdk-11-jdk     curl     wget     unzip     git     software-properties-common     apt-transport-https     ca-certificates     gnupg     lsb-release

# تثبيت Docker
echo "🐳 تثبيت Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# إضافة المستخدم إلى مجموعة docker
sudo usermod -aG docker $USER

# تشغيل Docker
sudo systemctl enable docker
sudo systemctl start docker

# تثبيت Docker Compose
echo "🔧 تثبيت Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# تثبيت Jenkins
echo "👨‍💻 تثبيت Jenkins..."
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt install -y jenkins

# تشغيل Jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins

# تثبيت AWS CLI
echo "☁️ تثبيت AWS CLI..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf aws awscliv2.zip

# تثبيت kubectl
echo "⎈ تثبيت kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin
rm kubectl

# تثبيت eksctl
echo "🔨 تثبيت eksctl..."
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

# تثبيت Ansible
echo "🎭 تثبيت Ansible..."
sudo apt install -y ansible

# تثبيت Terraform
echo "🏗️ تثبيت Terraform..."
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install -y terraform

echo "✅ تم تثبيت جميع الأدوات بنجاح!"
echo ""
echo "📋 معلومات مهمة:"
echo "1. قم بإعادة تسجيل الدخول لتفعيل Docker"
echo "2. كلمة مرور Jenkins الأولية:" sudo cat /var/lib/jenkins/secrets/initialAdminPassword 2>/dev/null || echo "Jenkins لم يتم تشغيله بعد"
echo "3. رابط Jenkins: http://$(curl -s ifconfig.me):8080"
echo ""
echo "🔧 للتحقق من الإصدارات:"
echo "java -version"
echo "docker --version"
echo "docker-compose --version"
echo "jenkins --version"
echo "aws --version"
echo "kubectl version --client"
echo "eksctl version"
echo "ansible --version"
echo "terraform --version"
java -version
docker --version
docker-compose --version
jenkins --version
aws --version
kubectl version --client
eksctl version
ansible --version
terraform --version