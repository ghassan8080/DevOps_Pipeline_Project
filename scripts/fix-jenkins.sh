#!/bin/bash

# scripts/fix-jenkins.sh
echo "🔧 إصلاح مشكلة تثبيت Jenkins..."

# تحديث init-system-holders
echo "📦 تحديث init-system-holders..."
sudo apt update
sudo apt install --only-upgrade init-system-helpers -y

# تثبيت Jenkins يدوياً
echo "👨‍💻 تثبيت Jenkins يدوياً..."
# إضافة مفتاح GPG الرسمي لـ Jenkins
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
sudo systemctl status jenkins

# عرض كلمة المرور الأولية
echo "🔑 كلمة مرور Jenkins الأولية:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
