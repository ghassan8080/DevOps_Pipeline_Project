#!/bin/bash

# scripts/fix-missing-packages.sh
echo "🔧 إصلاح وتثبيت الحزم المفقودة..."

# تحديث النظام
echo "📦 تحديث النظام..."
sudo apt update && sudo apt upgrade -y

# تثبيت Jenkins يدوياً
echo "👨‍💻 إصلاح وتثبيت Jenkins..."
# إضافة مفتاح GPG الرسمي لـ Jenkins
sudo apt-get install -y gnupg2
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -

# إضافة مستودع Jenkins
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'

# تحديث قائمة الحزم
sudo apt update

# تثبيت Jenkins
sudo apt install -y jenkins

# تشغيل Jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins

# التحقق من حالة Jenkins
echo "🔍 التحقق من حالة Jenkins..."
sudo systemctl status jenkins

# تثبيت AWS CLI
echo "☁️ تثبيت AWS CLI..."
sudo snap install aws-cli --classic

# تثبيت kubectl
echo "⎈ تثبيت kubectl..."
sudo snap install kubectl --classic

# تثبيت eksctl
echo "🔨 تثبيت eksctl..."
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

# تحديث Ansible إلى أحدث إصدار
echo "🎭 تحديث Ansible..."
sudo apt install --only-upgrade ansible -y
sudo apt install -y ansible

# تثبيت Terraform بأحدث إصدار
echo "🏗️ تثبيت Terraform بأحدث إصدار..."
sudo snap install terraform --classic --channel=latest/stable

# إضافة المستخدم إلى مجموعة docker
echo "🐳 إضافة المستخدم إلى مجموعة docker..."
sudo usermod -aG docker $USER
echo "⚠️  ملاحظة: قد تحتاج إلى تسجيل الخروج وإعادة الدخول لتفعيل عضوية مجموعة docker"

# عرض النتائج
echo ""
echo "✅ تم تثبيت جميع الحزم المفقودة بنجاح!"
echo ""
echo "📋 معلومات مهمة:"
echo "1. كلمة مرور Jenkins الأولية:" sudo cat /var/lib/jenkins/secrets/initialAdminPassword 2>/dev/null || echo "Jenkins لم يتم تشغيله بعد"
echo "2. رابط Jenkins: http://$(curl -s ifconfig.me):8080"
echo ""
echo "🔧 للتحقق من الإصدارات:"
echo "java -version"
echo "docker --version"
echo "docker-compose --version"
echo "sudo systemctl status jenkins"
echo "aws --version"
echo "kubectl version --client"
echo "eksctl version"
echo "ansible --version"
echo "terraform --version"

# إعادة تشغيل shell لتفعيل docker
echo "🔄 إعادة تشغيل shell لتفعيل docker..."
exec bash
