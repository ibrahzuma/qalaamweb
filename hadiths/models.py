from django.db import models
from django.utils.text import slugify

class HadithCollection(models.Model):
    name = models.CharField(max_length=255)
    slug = models.SlugField(unique=True)
    description = models.TextField(blank=True)

    class Meta:
        verbose_name = "Hadith Collection"
        verbose_name_plural = "Hadith Collections"

    def __str__(self):
        return self.name

class Hadith(models.Model):
    collection = models.ForeignKey(HadithCollection, related_name='hadiths', on_delete=models.CASCADE)
    hadith_number = models.CharField(max_length=20)
    arabic_number = models.CharField(max_length=20, blank=True)
    text_arabic = models.TextField(blank=True)
    text_english = models.TextField(blank=True)
    text_swahili = models.TextField(blank=True)
    section = models.CharField(max_length=255, blank=True)
    grades = models.JSONField(default=list, blank=True)
    
    class Meta:
        verbose_name = "Hadith"
        verbose_name_plural = "Hadiths"
        unique_together = ('collection', 'hadith_number')
        indexes = [
            models.Index(fields=['hadith_number']),
            models.Index(fields=['collection']),
        ]

    def __str__(self):
        return f"{self.collection.name} - Hadith {self.hadith_number}"
