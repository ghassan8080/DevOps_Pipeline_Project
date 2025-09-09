# Node.js Monitoring App

تطبيق Node.js مصمم للمراقبة باستخدام Prometheus و Grafana.

## المميزات

- تتبع عدد الزيارات
- مراقبة استخدام الذاكرة ووحدة المعالجة المركزية
- تتبع الاتصالات النشطة
- مراقبة وقت تشغيل التطبيق
- واجهة ويب لعرض المقاييس

## نقاط النهاية

- `/` - الصفحة الرئيسية
- `/metrics` - نقطة نهاية Prometheus للمقاييس
- `/health` - فحص صحة التطبيق
- `/system` - معلومات النظام

## التثبيت والتشغيل

### باستخدام Docker

1. بناء الصورة:
   ```bash
   docker build -t node-monitoring-app .
   ```

2. تشغيل الحاوية:
   ```bash
   docker run -p 3000:3000 node-monitoring-app
   ```

### باستخدام Kubernetes

1. تطبيق ملفات Kubernetes:
   ```bash
   kubectl apply -f ../kubernetes/node-app-deployment.yaml
   ```

2. التحقق من حالة التطبيق:
   ```bash
   kubectl get pods -n microservices
   ```

## المراقبة

### Prometheus

سيتم جمع المقاييس تلقائيًا من التطبيق باستخدام Prometheus.

### Grafana

يمكن استيراد لوحة التحكم من ملف `node-app-grafana-dashboard.json` لعرض المقاييس.

## المتطلبات

- Node.js 18+
- Docker (للبناء والتشغيل في حاوية)
- Kubernetes (للنشر في مجموعة)
