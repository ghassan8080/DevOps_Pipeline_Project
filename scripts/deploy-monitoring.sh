
#!/bin/bash

# تطبيق التغييرات على Kubernetes
echo "تطبيق التغييرات على Kubernetes..."

# تطبيق ConfigMap لتطبيق Node.js
kubectl apply -f kubernetes/node-app-configmap.yaml

# تطبيق تكوين Grafana
kubectl apply -f kubernetes/grafana-config.yaml

# تطبيق لوحة معلومات Grafana
kubectl apply -f kubernetes/grafana-dashboard-import.yaml

# تطبيق تحديثات Node App
kubectl apply -f kubernetes/node-app-deployment.yaml

# تطبيق تحديثات Grafana
kubectl apply -f kubernetes/grafana-deployment.yaml

# تطبيق تحديثات Prometheus
kubectl apply -f kubernetes/prometheus-deployment.yaml

# حذف القرون القديمة التي قد تواجه مشاكل
echo "حذف القرون القديمة التي قد تواجه مشاكل..."
kubectl delete pod -l app=node-app -n microservices --ignore-not-found=true
kubectl delete pod -l app=grafana -n microservices --ignore-not-found=true
kubectl delete pod -l app=prometheus -n microservices --ignore-not-found=true

# حذف أي Ingress قديم قد يسبب تعارض
echo "حذف أي Ingress قديم قد يسبب تعارض..."
kubectl delete ingress monitoring-ingress -n microservices --ignore-not-found=true
kubectl delete ingress node-app-root-ingress -n microservices --ignore-not-found=true

# تطبيق Ingress المحدث
echo "تطبيق Ingress المحدث..."
kubectl apply -f kubernetes/monitoring-ingress.yaml

# الانتظار حتى تصبح جميع القرون جاهزة
echo "الانتظار حتى تصبح جميع القرون جاهزة..."
kubectl wait --for=condition=ready pod -l app=node-app -n microservices --timeout=300s
kubectl wait --for=condition=ready pod -l app=grafana -n microservices --timeout=300s
kubectl wait --for=condition=ready pod -l app=prometheus -n microservices --timeout=300s

# عرض حالة الخدمات
echo "حالة الخدمات:"
kubectl get services -n microservices

# عرض حالة Ingress
echo "حالة Ingress:"
kubectl get ingress -n microservices

# عرض حالة القرون
echo "حالة القرون:"
kubectl get pods -n microservices

# عرض روابط الوصول إلى التطبيق وأدوات المراقبة
echo "روابط الوصول إلى التطبيق وأدوات المراقبة:"
INGRESS_URL=$(kubectl get ingress monitoring-ingress -n microservices -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}')
echo "Node.js Application: http://<ingress-controller-url>/"
echo "Application Metrics: http://<ingress-controller-url>/node-app/metrics"
echo "Prometheus: http://<ingress-controller-url>/prometheus"
echo "Grafana: http://<ingress-controller-url>/grafana (admin/admin123)"
echo "AlertManager: http://<ingress-controller-url>/alertmanager"

echo "تم تطبيق جميع التغييرات بنجاح!"
echo "لاستبدال <ingress-controller-url> بالعنوان الفعلي، قم بتشغيل:"
echo "kubectl get svc ingress-nginx-controller -n ingress-nginx"



