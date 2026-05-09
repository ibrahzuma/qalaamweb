from django.contrib import admin
from .models import HadithCollection, HadithBook, Hadith


@admin.register(HadithCollection)
class HadithCollectionAdmin(admin.ModelAdmin):
    list_display = ('name', 'slug', 'book_count', 'hadith_count')
    prepopulated_fields = {'slug': ('name',)}
    search_fields = ('name', 'slug')

    def book_count(self, obj):
        return obj.books.count()
    book_count.short_description = 'Books'

    def hadith_count(self, obj):
        return obj.hadiths.count()
    hadith_count.short_description = 'Hadiths'


@admin.register(HadithBook)
class HadithBookAdmin(admin.ModelAdmin):
    list_display = ('collection', 'book_number', 'name', 'hadith_count')
    list_filter = ('collection',)
    search_fields = ('name',)
    ordering = ('collection', 'book_number')

    def hadith_count(self, obj):
        return obj.hadiths.count()
    hadith_count.short_description = 'Hadiths'


@admin.register(Hadith)
class HadithAdmin(admin.ModelAdmin):
    list_display = ('hadith_number', 'collection', 'book', 'has_arabic', 'has_english', 'has_swahili')
    list_filter = ('collection', 'book')
    search_fields = ('hadith_number', 'text_arabic', 'text_english', 'text_swahili')
    raw_id_fields = ('book',)

    def has_arabic(self, obj):
        return bool(obj.text_arabic)
    has_arabic.boolean = True

    def has_english(self, obj):
        return bool(obj.text_english)
    has_english.boolean = True

    def has_swahili(self, obj):
        return bool(obj.text_swahili)
    has_swahili.boolean = True
