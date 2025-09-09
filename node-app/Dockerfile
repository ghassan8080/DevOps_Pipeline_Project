FROM node:18-alpine

# إنشاء دليل العمل
WORKDIR /app

# نسخ ملفات الحزمة
COPY package*.json ./

# تثبيت الاعتماديات
RUN npm install

# نسخ باقي الملفات
COPY . .

# كشف المنفذ
EXPOSE 3000

# بدء تشغيل التطبيق
CMD ["npm", "start"]
