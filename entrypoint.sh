#!/bin/bash

# Esperar a que la base de datos esté lista
while ! nc -z db 3306; do
  echo "Esperando a que MySQL esté listo..."
  sleep 2
done

echo "MySQL está listo, ejecutando migraciones..."

# Ejecutar migraciones
python manage.py migrate --noinput
python manage.py makemigrations
python manage.py migrate 

# Crear superusuario (opcional, solo para desarrollo)
echo "from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.create_superuser('admin', 'admin@example.com', 'admin') if not User.objects.filter(username='admin').exists() else None" | python manage.py shell

# Recolectar archivos estáticos
python manage.py collectstatic --noinput --clear

# Permisos para archivos estáticos
chmod -R 755 /app/staticfiles

# Iniciar Gunicorn
exec gunicorn --bind 0.0.0.0:8000 spmbe_backend.wsgi:application