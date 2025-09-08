#!/bin/bash

# scripts/fix-final-issues.sh
echo "🔧 إصلاح المشاكل المتبقية..."

# تحديث النظام أولاً
echo "📦 تحديث النظام..."
sudo apt update && sudo apt upgrade -y

# إصلاح مشكلة Jenkins
echo "👨‍💻 إصلاح مشكلة Jenkins..."
# تحديث init-system-helpers أولاً
echo "تحديث init-system-helpers..."
sudo apt install --only-upgrade init-system-helpers -y

# إضافة مفتاح GPG الرسمي لـ Jenkins
echo "إضافة مفتاح GPG لـ Jenkins..."
sudo apt-get install -y gnupg2
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -

# إضافة مستودع Jenkins
echo "إضافة مستودع Jenkins..."
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'

# تحديث قائمة الحزم
sudo apt update

# تثبيت Jenkins
echo "تثبيت Jenkins..."
sudo apt install -y jenkins

# إنشاء ملف خدمة يدوياً إذا لم يكن موجودًا
if [ ! -f /lib/systemd/system/jenkins.service ]; then
    echo "إنشاء ملف خدمة Jenkins يدوياً..."
    sudo tee /lib/systemd/system/jenkins.service > /dev/null <<EOL
[Unit]
Description=Jenkins Continuous Integration Server
After=network.target

[Service]
User=jenkins
Group=jenkins
Environment="JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64"
ExecStart=/usr/bin/java -jar /usr/share/jenkins/jenkins.war
ExecReload=/bin/kill -HUP \$MAINPID
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOL
fi

# التأكد من وجود مستخدم jenkins
echo "التحقق من وجود مستخدم jenkins..."
if ! id "jenkins" &>/dev/null; then
    echo "إنشاء مستخدم jenkins..."
    sudo useradd -r -s /bin/false jenkins
else
    echo "مستخدم jenkins موجود بالفعل"
fi

# إعادة تشغيل systemd
sudo systemctl daemon-reload

# تشغيل Jenkins
echo "تشغيل Jenkins..."
sudo systemctl enable jenkins
sudo systemctl start jenkins

# التحقق من حالة Jenkins
echo "🔍 التحقق من حالة Jenkins..."
sudo systemctl status jenkins

# إصلاح مشكلة kubectl
echo "⎈ إصلاح مشكلة kubectl..."
# تحديث snapd أولاً
echo "تحديث snapd..."
sudo snap install snapd

# تثبيت kubectl
echo "تثبيت kubectl..."
sudo snap install kubectl --classic

# تحديث Ansible إلى أحدث إصدار
echo "🎭 تحديث Ansible إلى أحدث إصدار..."
# إضافة مستودع Ansible PPA
sudo apt-add-repository ppa:ansible/ansible -y
sudo apt update
sudo apt install -y ansible

# تحديث Terraform إلى أحدث إصدار
echo "🏗️ تحديث Terraform إلى أحدث إصدار..."
# إزالة الإصدار الحالي إذا كان مثبتًا عبر snap
sudo snap remove terraform
# تثبيت أحدث إصدار
sudo snap install terraform --classic --channel=latest/stable

# عرض النتائج النهائية
echo ""
echo "✅ تم إصلاح جميع المشاكل المتبقية بنجاح!"
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
