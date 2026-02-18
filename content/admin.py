from django.contrib import admin
from mptt.admin import DraggableMPTTAdmin
from .models import ContentCategory, Audio, Book

@admin.register(ContentCategory)
class ContentCategoryAdmin(DraggableMPTTAdmin):
    prepopulated_fields = {'slug': ('name',)}

@admin.register(Audio)
class AudioAdmin(admin.ModelAdmin):
    list_display = ('title', 'speaker', 'category')
    list_filter = ('category',)
    search_fields = ('title', 'speaker')

@admin.register(Book)
class BookAdmin(admin.ModelAdmin):
    list_display = ('title', 'author', 'category')
    list_filter = ('category',)
    search_fields = ('title', 'author')
