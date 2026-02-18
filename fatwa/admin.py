from django.contrib import admin
from mptt.admin import DraggableMPTTAdmin
from .models import FatwaCategory, Fatwa

@admin.register(FatwaCategory)
class FatwaCategoryAdmin(DraggableMPTTAdmin):
    prepopulated_fields = {'slug': ('name',)}

@admin.register(Fatwa)
class FatwaAdmin(admin.ModelAdmin):
    list_display = ('title', 'category', 'status', 'created_at')
    list_filter = ('status', 'category')
    search_fields = ('title', 'question', 'answer')
