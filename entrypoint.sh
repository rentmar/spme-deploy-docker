#!/bin/sh

echo "Waiting for database..."
while ! nc -z db 3306; do
  sleep 1
done

echo "Database started"

echo "Applying migrations..."
python manage.py migrate --noinput

echo "Collecting static files..."
python manage.py collectstatic --noinput

echo "Starting Gunicorn..."
gunicorn spme.wsgi:application --bind 0.0.0.0:8000 --workers 3