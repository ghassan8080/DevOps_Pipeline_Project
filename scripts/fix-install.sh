#!/bin/bash

# scripts/fix-install.sh
echo "🔧 إصلاح مشكلة قفل dpkg..."

# إعادة تشغيل الخدمات المتعلقة بـ apt
sudo systemctl stop apt-daily.timer
sudo systemctl stop apt-daily.service
sudo systemctl stop apt-daily-upgrade.timer
sudo systemctl stop apt-daily-upgrade.service

# قفل قائمة الانتظار لمدة 30 ثانية
echo "⏱️ انتظار 30 ثانية لتحرير القفل..."
sleep 30

# محاولة تشغيل السكربت مرة أخرى
echo "🚀 إعادة تشغيل السكربت..."
sudo ./install.sh
