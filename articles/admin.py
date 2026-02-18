from django.contrib import admin
from mptt.admin import DraggableMPTTAdmin
from .models import ArticleCategory, Article

@admin.register(ArticleCategory)
class ArticleCategoryAdmin(DraggableMPTTAdmin):
    prepopulated_fields = {'slug': ('name',)}

@admin.register(Article)
class ArticleAdmin(admin.ModelAdmin):
    list_display = ('title', 'category', 'author', 'created_at')
    list_filter = ('category',)
    search_fields = ('title', 'content')
