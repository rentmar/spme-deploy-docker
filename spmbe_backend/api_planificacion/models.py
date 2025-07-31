from django.db import models


#Proyecto de planificaciones
class ProyectoPlan(models.Model):
    table_config = models.JSONField(null=True, blank=True)
    rows_data = models.JSONField(null=True, blank=True)
    version = models.IntegerField(default=1)
    creado = models.DateTimeField(auto_now_add=True)
    actualizado = models.DateTimeField(auto_now=True)
    #Relacion
    proyecto = models.ForeignKey(
        'api_estructuracion.Proyecto',
        on_delete=models.SET_NULL,
        related_name='planificacion',
        null=True,
        blank=True,
    )

#Revision de plan
class PlanRevision(models.Model):
    cambios = models.JSONField(null=True, blank=True)
    razon = models.TextField(null=True, blank=True)
    #modified_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True)
    modificado_por = models.CharField(max_length=150, null=True, blank=True)
    modificado_el = models.DateTimeField(auto_now_add=True)
    version = models.IntegerField(null=True, blank=True)
    #Relacion
    plan = models.ForeignKey(
        ProyectoPlan,
        on_delete=models.SET_NULL,
        related_name='revisiones',
        null=True,
        blank=True,

    )
    class Meta:
        ordering = ['-modificado_el']

