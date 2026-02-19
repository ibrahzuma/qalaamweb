from django.contrib import admin
from .models import HadithCollection, Hadith

@admin.register(HadithCollection)
class HadithCollectionAdmin(admin.ModelAdmin):
    list_display = ('name', 'slug')
    prepopulated_fields = {'slug': ('name',)}

@admin.register(Hadith)
class HadithAdmin(admin.ModelAdmin):
    list_display = ('hadith_number', 'collection', 'has_arabic', 'has_english', 'has_swahili')
    list_filter = ('collection',)
    search_fields = ('hadith_number', 'text_arabic', 'text_english', 'text_swahili')
    
    def has_arabic(self, obj):
        return bool(obj.text_arabic)
    has_arabic.boolean = True
    
    def has_english(self, obj):
        return bool(obj.text_english)
    has_english.boolean = True
    
    def has_swahili(self, obj):
        return bool(obj.text_swahili)
    has_swahili.boolean = True
