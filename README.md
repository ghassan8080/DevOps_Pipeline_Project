# DevOps Pipeline Project

مشروع DevOps Pipeline متكامل لإنشاء وتشغيل بيئة تطوير متكاملة باستخدام أدوات DevOps الحديثة.

## هيكل المشروع

```
├── docker/
│   ├── Dockerfile
│   ├── docker-compose.yml
│   └── src/
│       └── index.php
├── ansible/
│   └── playbook.yml
├── kubernetes/
│   ├── namespace.yaml
│   ├── mysql-deployment.yaml
│   ├── php-apache-deployment.yaml
│   ├── phpmyadmin-deployment.yaml
│   ├── prometheus-deployment.yaml
│   ├── grafana-deployment.yaml
│   ├── node-app-deployment.yaml
│   ├── node-app-configmap.yaml
│   ├── simple-node-app-deployment.yaml
│   ├── simple-node-app-configmap.yaml
│   ├── node-exporter-deployment.yaml
│   ├── alertmanager-deployment.yaml
│   ├── grafana-config.yaml
│   ├── grafana-dashboard-import.yaml
│   └── monitoring-ingress.yaml
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── jenkins/
│   ├── Jenkins-EKS/Jenkinsfile
│   ├── Jenkins-Deploy/Jenkinsfile
│   ├── Jenkins-NodeApp/Jenkinsfile
│   └── Jenkins-RM-EKS/Jenkinsfile
├── node-app/
│   ├── Dockerfile
│   ├── README.md
│   ├── app.js
│   └── package.json
├── scripts/
│   ├── deploy-monitoring.sh
│   └── install.sh
└── README.md
```

## خطوات التشغيل

1. إعداد Terraform
```bash
cd terraform
# تعديل ملف terraform.tfvars حسب بيئتك
terraform init
terraform plan
terraform apply -auto-approve
```

2. الاتصال بـ EC2
```bash
ssh -i your-key.pem ubuntu@<public-ip>
```

3. تشغيل script التثبيت
```bash
chmod +x scripts/install.sh
./scripts/install.sh
```

4. إعداد Jenkins
- افتح http://<public-ip>:8080
- أدخل كلمة المرور الأولية
- ثبت الإضافات المطلوبة
- أضف Credentials للـ AWS, DockerHub, GitHub

5. إنشاء Jenkins Jobs
- قم بإنشاء 4 pipeline jobs:
  - Jenkins-EKS: لإنشاء EKS cluster
  - Jenkins-Deploy: لنشر التطبيقات
  - Jenkins-NodeApp: لنشر تطبيق Node.js
  - Jenkins-RM-EKS: لحذف الـ cluster

## الاختبارات المطلوبة

1. اختبار Docker محلياً
```bash
cd docker
docker-compose up -d
# تصفح http://localhost:8080
```

2. اختبار Kubernetes
```bash
kubectl apply -f kubernetes/
kubectl get all -n microservices
```

3. اختبار Jenkins Pipeline
- تشغيل Jenkins-EKS job
- تشغيل Jenkins-Deploy job
- تشغيل Jenkins-NodeApp job
- التحقق من النتائج

## مراقبة التطبيق

1. الوصول إلى Grafana
- افتح http://<grafana-url>
- سجل الدخول باستخدام admin/admin123
- استعرض لوحات المراقبة المتاحة

2. الوصول إلى Prometheus
- افتح http://<prometheus-url>
- استعرض المقاييس المتاحة

3. الوصول إلى التطبيق
- افتح http://<app-url>
- اختبر وظائف التطبيق المختلفة
