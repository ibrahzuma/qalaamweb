from django.contrib import admin
from mptt.admin import DraggableMPTTAdmin
from .models import ContentCategory, Audio, Book, Video, Podcast, PodcastEpisode

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

@admin.register(Video)
class VideoAdmin(admin.ModelAdmin):
    list_display = ('title', 'category', 'created_at')
    list_filter = ('category',)
    search_fields = ('title', 'description')

class PodcastEpisodeInline(admin.TabularInline):
    model = PodcastEpisode
    extra = 1

@admin.register(Podcast)
class PodcastAdmin(admin.ModelAdmin):
    list_display = ('title', 'category', 'created_at')
    list_filter = ('category',)
    search_fields = ('title', 'description')
    inlines = [PodcastEpisodeInline]

@admin.register(PodcastEpisode)
class PodcastEpisodeAdmin(admin.ModelAdmin):
    list_display = ('title', 'podcast', 'created_at')
    list_filter = ('podcast',)
    search_fields = ('title', 'description')
