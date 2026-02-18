from django.db import models
from mptt.models import MPTTModel, TreeForeignKey
from django.utils.text import slugify

class DuaCategory(MPTTModel):
    name = models.CharField(max_length=200)
    slug = models.SlugField(max_length=255, unique=True, blank=True)
    parent = TreeForeignKey('self', on_delete=models.CASCADE, null=True, blank=True, related_name='children')

    class MPTTMeta:
        order_insertion_by = ['name']

    def save(self, *args, **kwargs):
        if not self.slug:
            self.slug = slugify(self.name)
        super().save(*args, **kwargs)

    def __str__(self):
        return self.name

    class Meta:
        verbose_name_plural = "Dua Categories"

class Dua(models.Model):
    title = models.CharField(max_length=300)
    slug = models.SlugField(max_length=255, unique=True, blank=True)
    category = models.ForeignKey(DuaCategory, on_delete=models.CASCADE, related_name='duas')
    arabic_text = models.TextField()
    translation = models.TextField()
    transliteration = models.TextField(blank=True)
    reference = models.CharField(max_length=500, blank=True)
    audio_url = models.URLField(max_length=500, null=True, blank=True)
    audio_file = models.FileField(upload_to='duas/audio/', null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def save(self, *args, **kwargs):
        if not self.slug:
            self.slug = slugify(self.title)
        super().save(*args, **kwargs)

    def __str__(self):
        return self.title
