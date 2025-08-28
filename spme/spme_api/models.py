from django.db import models

# Create your models here.
class Libro(models.Model):
    codigo = models.IntegerField(max_length=255,null=True, blank=True)
    titulo = models.CharField(null=True, blank=True)
    disponible = models.BooleanField(default=True)

    def __str__(self):
        return self.titulo
