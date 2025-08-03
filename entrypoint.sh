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
#echo "from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.create_superuser('admin', 'admin@example.com', 'admin') if not User.objects.filter(username='admin').exists() else None" | python manage.py shell
echo "from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.create_superuser('admin', 'admin@example.com', 'admin') if not User.objects.filter(username='admin').exists() else None" | python manage.py shell

echo "Verificando creación de PEI inicial..."

python manage.py shell <<EOF
from django.utils import timezone
from api_estructuracion.models import Pei  

# Verificar si ya existe un PEI para no duplicar
if not Pei.objects.exists():
    Pei.objects.create(
        titulo="PEI Inicial",
        descripcion="Plan Estratégico Institucional inicial",
        fecha_inicio=timezone.now().date(),
        fecha_fin=timezone.now().date().replace(year=timezone.now().year + 4),  # 4 años después
        esta_vigente=True
    )
    print("✅ PEI inicial creado exitosamente.")
else:
    print("ℹ️ Ya existe un PEI en la base de datos. No se creó uno nuevo.")
EOF

# 4. Crear 'Fondos Propios' (¡Nuevo!)
python manage.py shell <<EOF
from api_estructuracion.models import ProcedenciaFondos  

if not ProcedenciaFondos.objects.filter(financiera="Fondos Propios").exists():
    ProcedenciaFondos.objects.create(
        sigla="FP",
        financiera="Fondos Propios"
    )
    print("✅ Registro 'Fondos Propios' creado.")
else:
    print("ℹ️ 'Fondos Propios' ya existe.")
EOF

echo "Verificando creación de Instancias Gestoras..."

python manage.py shell <<EOF
from api_estructuracion.models import InstanciaGestora  # Reemplaza 'tu_app' con el nombre real de tu aplicación Django

# Datos a cargar
INSTANCIAS_GESTORAS = [
    {"id": 1, "codigo": "UG", "clasificador": "", "instancia": "Unidad de Gestión"},
    {"id": 2, "codigo": "DIR EJEC", "clasificador": "A", "instancia": "Dirección Ejecutiva"},
    {"id": 3, "codigo": "COM", "clasificador": "B", "instancia": "Comunicación"},
    {"id": 4, "codigo": "PM&E", "clasificador": "C", "instancia": "Planificación, Monitoreo y Evaluación"},
    {"id": 5, "codigo": "REDES", "clasificador": "D", "instancia": "Desarrollo de Redes"},
    {"id": 6, "codigo": "URBANO", "clasificador": "E", "instancia": "Programa Urbano"},
    {"id": 7, "codigo": "NINA", "clasificador": "F", "instancia": "Programa Nina"},
    {"id": 8, "codigo": "DEFENSORES", "clasificador": "G", "instancia": "Programa Defensores"},
    {"id": 9, "codigo": "ADM", "clasificador": "H", "instancia": "Administración"},
]

# Crear instancias solo si no existen
if not InstanciaGestora.objects.exists():
    for instancia_data in INSTANCIAS_GESTORAS:
        InstanciaGestora.objects.create(
            codigo=instancia_data["codigo"],
            clasificador=instancia_data["clasificador"],
            instancia=instancia_data["instancia"]
        )
    print("✅ Instancias Gestoras creadas exitosamente.")
else:
    print("ℹ️ Ya existen registros en InstanciaGestora. No se crearon nuevos.")
EOF

# Recolectar archivos estáticos
python manage.py collectstatic --noinput --clear

# Permisos para archivos estáticos
chmod -R 755 /app/staticfiles

# Iniciar Gunicorn
exec gunicorn --bind 0.0.0.0:8000 spmbe_backend.wsgi:application