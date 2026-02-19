from django.db import models
from django.utils.text import slugify

class HadithEdition(models.Model):
    name = models.CharField(max_length=255)
    name_native = models.CharField(max_length=255, blank=True)
    language = models.CharField(max_length=100)
    edition_key = models.CharField(max_length=100, unique=True) # e.g., 'eng-bukhari'
    
    class Meta:
        verbose_name = "Hadith Edition"
        verbose_name_plural = "Hadith Editions"

    def __str__(self):
        return f"{self.name} ({self.language})"

class Hadith(models.Model):
    edition = models.ForeignKey(HadithEdition, related_name='hadiths', on_delete=models.CASCADE)
    hadith_number = models.CharField(max_length=20)
    arabic_number = models.CharField(max_length=20, blank=True)
    text = models.TextField()
    section = models.CharField(max_length=255, blank=True)
    grades = models.JSONField(default=list, blank=True)
    
    class Meta:
        verbose_name = "Hadith"
        verbose_name_plural = "Hadiths"
        indexes = [
            models.Index(fields=['hadith_number']),
            models.Index(fields=['edition']),
        ]

    def __str__(self):
        return f"{self.edition.name} - Hadith {self.hadith_number}"
