from django.db import models
from mptt.models import MPTTModel, TreeForeignKey
from ckeditor.fields import RichTextField

class ArticleCategory(MPTTModel):
    name = models.CharField(max_length=200)
    parent = TreeForeignKey('self', on_delete=models.CASCADE, null=True, blank=True, related_name='children')
    slug = models.SlugField(unique=True)

    class MPTTMeta:
        order_insertion_by = ['name']

    def __str__(self):
        return self.name

class Article(models.Model):
    title = models.CharField(max_length=500)
    content = RichTextField()
    main_image = models.ImageField(upload_to='articles/', null=True, blank=True)
    category = models.ForeignKey(ArticleCategory, on_delete=models.CASCADE, related_name='articles')
    author = models.CharField(max_length=200, blank=True)
    view_count = models.PositiveIntegerField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.title
