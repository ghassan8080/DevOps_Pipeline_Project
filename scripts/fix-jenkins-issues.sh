#!/bin/bash

# scripts/fix-jenkins-issues.sh
echo "🔧 إصلاح مشاكل Jenkins..."

# تحديث init-system-helpers إلى أحدث إصدار
echo "📦 تحديث init-system-helpers..."
sudo apt update
sudo apt install --only-upgrade init-system-helpers -y

# التحقق من الإصدار الحالي
echo "🔍 التحقق من إصدار init-system-helpers..."
dpkg -l init-system-helpers

# إذا لم يكن الإصدار 1.54 أو أعلى، قم بإضافة مستودح PPA يحتوي على الإصدار الأحدث
INSTALLED_VERSION=$(dpkg -l init-system-helpers | grep ii | awk '{print $3}')
if [[ "$INSTALLED_VERSION" < "1.54" ]]; then
    echo "⚠️ الإصدار الحالي أقدم من المطلوب، سيتم إضافة مستودع PPA..."

    # إضافة مستودع PPA لـ init-system-helpers
    sudo add-apt-repository ppa:deadsnakes/ppa -y
    sudo apt update

    # محاولة تثبيت الإصدار الأحدث
    sudo apt install --only-upgrade init-system-helpers -y

    # التحقق من الإصدار الجديد
    echo "🔍 التحقق من الإصدار الجديد..."
    dpkg -l init-system-helpers
fi

# إضافة مفتاح GPG الرسمي لـ Jenkins
echo "🔑 إضافة مفتاح GPG لـ Jenkins..."
sudo apt-get install -y gnupg2
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -

# إضافة مستودع Jenkins
echo "📦 إضافة مستودع Jenkins..."
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'

# تحديث قائمة الحزم
sudo apt update

# تثبيت Jenkins
echo "👨‍💻 تثبيت Jenkins..."
sudo apt install -y jenkins

# التأكد من وجود مستخدم jenkins
echo "👤 التأكد من وجود مستخدم jenkins..."
if ! id "jenkins" &>/dev/null; then
    echo "إنشاء مستخدم jenkins..."
    sudo useradd -r -s /bin/false jenkins
else
    echo "مستخدم jenkins موجود بالفعل"
fi

# إنشاء ملف خدمة Jenkins يدوياً
echo "📝 إعداد خدمة Jenkins..."
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

# إعادة تشغيل systemd
echo "🔄 إعادة تشغيل systemd..."
sudo systemctl daemon-reload

# تعديل أذونات ملفات Jenkins
echo "🔐 تعديل أذونات ملفات Jenkins..."
sudo chown -R jenkins:jenkins /var/lib/jenkins
sudo chown -R jenkins:jenkins /var/cache/jenkins
sudo chown -R jenkins:jenkins /var/log/jenkins

# تشغيل Jenkins
echo "🚀 تشغيل Jenkins..."
sudo systemctl enable jenkins
sudo systemctl start jenkins

# التحقق من حالة Jenkins
echo "🔍 التحقق من حالة Jenkins..."
sudo systemctl status jenkins

# عرض كلمة المرور الأولية
echo ""
echo "📋 معلومات مهمة:"
echo "1. كلمة مرور Jenkins الأولية:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword 2>/dev/null || echo "Jenkins لم يتم تشغيله بعد"
echo "2. رابط Jenkins: http://$(curl -s ifconfig.me):8080"
