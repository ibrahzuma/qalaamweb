from django.db import models
from mptt.models import MPTTModel, TreeForeignKey
from ckeditor.fields import RichTextField

class FatwaCategory(MPTTModel):
    name = models.CharField(max_length=200)
    parent = TreeForeignKey('self', on_delete=models.CASCADE, null=True, blank=True, related_name='children')
    slug = models.SlugField(unique=True)

    class MPTTMeta:
        order_insertion_by = ['name']

    def __str__(self):
        return self.name

class Fatwa(models.Model):
    STATUS_CHOICES = (
        ('pending', 'Pending'),
        ('answered', 'Answered'),
    )
    title = models.CharField(max_length=500)
    question = models.TextField()
    answer = RichTextField()
    category = models.ForeignKey(FatwaCategory, on_delete=models.CASCADE, related_name='fatawa')
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='answered')
    view_count = models.PositiveIntegerField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.title
