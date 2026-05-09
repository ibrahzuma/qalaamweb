from django.contrib import admin
from mptt.admin import DraggableMPTTAdmin
from .models import DuaCategory, Dua, Dhikr


@admin.register(DuaCategory)
class DuaCategoryAdmin(DraggableMPTTAdmin):
    prepopulated_fields = {'slug': ('name',)}
    search_fields = ('name',)


@admin.register(Dua)
class DuaAdmin(admin.ModelAdmin):
    list_display = ('title', 'category', 'reference', 'created_at')
    list_filter = ('category',)
    search_fields = ('title', 'translation', 'arabic_text', 'reference')
    prepopulated_fields = {'slug': ('title',)}
    fieldsets = (
        (None, {'fields': ('title', 'slug', 'category', 'reference')}),
        ('Content', {'fields': ('arabic_text', 'translation', 'transliteration')}),
        ('Audio', {'fields': ('audio_url', 'audio_file')}),
    )


@admin.register(Dhikr)
class DhikrAdmin(admin.ModelAdmin):
    list_display = ('name', 'default_target', 'created_at')
    search_fields = ('name', 'translation', 'arabic_text')
    list_editable = ('default_target',)
