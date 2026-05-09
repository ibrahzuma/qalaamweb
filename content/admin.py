from django.contrib import admin
from mptt.admin import DraggableMPTTAdmin
from .models import (
    ContentCategory, Audio, Book, Video, VideoSeries, Clip,
    Podcast, PodcastEpisode, Reel, QuranSurah, Ayah,
)


@admin.register(ContentCategory)
class ContentCategoryAdmin(DraggableMPTTAdmin):
    prepopulated_fields = {'slug': ('name',)}


@admin.register(Audio)
class AudioAdmin(admin.ModelAdmin):
    list_display = ('title', 'speaker', 'category', 'created_at')
    list_filter = ('category',)
    search_fields = ('title', 'speaker')


@admin.register(Book)
class BookAdmin(admin.ModelAdmin):
    list_display = ('title', 'author', 'category', 'created_at')
    list_filter = ('category',)
    search_fields = ('title', 'author')


@admin.register(Video)
class VideoAdmin(admin.ModelAdmin):
    list_display = ('title', 'category', 'created_at')
    list_filter = ('category',)
    search_fields = ('title', 'description')


@admin.register(VideoSeries)
class VideoSeriesAdmin(admin.ModelAdmin):
    list_display = ('title', 'category', 'created_at')
    list_filter = ('category',)
    search_fields = ('title', 'description')


@admin.register(Clip)
class ClipAdmin(admin.ModelAdmin):
    list_display = ('title', 'category', 'created_at')
    list_filter = ('category',)
    search_fields = ('title', 'description')


class PodcastEpisodeInline(admin.TabularInline):
    model = PodcastEpisode
    extra = 1
    fields = ('title', 'episode_number', 'season_number', 'audio_url', 'duration')


@admin.register(Podcast)
class PodcastAdmin(admin.ModelAdmin):
    list_display = ('title', 'category', 'episode_count', 'created_at')
    list_filter = ('category',)
    search_fields = ('title', 'description')
    inlines = [PodcastEpisodeInline]

    def episode_count(self, obj):
        return obj.episodes.count()
    episode_count.short_description = 'Episodes'


@admin.register(PodcastEpisode)
class PodcastEpisodeAdmin(admin.ModelAdmin):
    list_display = ('title', 'podcast', 'episode_number', 'season_number', 'created_at')
    list_filter = ('podcast',)
    search_fields = ('title', 'description')


@admin.register(Reel)
class ReelAdmin(admin.ModelAdmin):
    list_display = ('title', 'category', 'created_at')
    list_filter = ('category',)
    search_fields = ('title', 'description')


@admin.register(QuranSurah)
class QuranSurahAdmin(admin.ModelAdmin):
    list_display = ('surah_number', 'surah_name', 'juz_number', 'ayah_count', 'reciter', 'created_at')
    search_fields = ('surah_name', 'reciter')
    list_filter = ('reciter',)
    ordering = ('surah_number',)

    def ayah_count(self, obj):
        return obj.ayahs.count()
    ayah_count.short_description = 'Ayahs'


@admin.register(Ayah)
class AyahAdmin(admin.ModelAdmin):
    list_display = ('reference', 'short_text', 'is_daily', 'created_at')
    list_editable = ('is_daily',)
    list_filter = ('is_daily', 'surah_number')
    search_fields = ('text', 'translation', 'reference')
    ordering = ('surah_number', 'ayah_number')

    def short_text(self, obj):
        return (obj.translation or obj.text or '')[:80]
    short_text.short_description = 'Preview'
