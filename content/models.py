from django.db import models
from mptt.models import MPTTModel, TreeForeignKey

class ContentCategory(MPTTModel):
    name = models.CharField(max_length=200)
    parent = TreeForeignKey('self', on_delete=models.CASCADE, null=True, blank=True, related_name='children')
    slug = models.SlugField(unique=True)
    icon = models.CharField(max_length=50, default='bi-folder', help_text="Bootstrap icon class (e.g., bi-book)")

    class MPTTMeta:
        order_insertion_by = ['name']

    def __str__(self):
        return self.name

class Audio(models.Model):
    title = models.CharField(max_length=500)
    file = models.FileField(upload_to='audio/')
    speaker = models.CharField(max_length=200)
    category = models.ForeignKey(ContentCategory, on_delete=models.CASCADE, related_name='audios')
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.title

class Book(models.Model):
    title = models.CharField(max_length=500)
    author = models.CharField(max_length=200)
    cover_image = models.ImageField(upload_to='books/covers/')
    pdf_file = models.FileField(upload_to='books/pdfs/')
    description = models.TextField(blank=True)
    category = models.ForeignKey(ContentCategory, on_delete=models.CASCADE, related_name='books')
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.title

class Video(models.Model):
    title = models.CharField(max_length=500)
    video_url = models.URLField(blank=True, help_text="Link to YouTube or Vimeo video")
    video_file = models.FileField(upload_to='videos/', blank=True, null=True)
    description = models.TextField(blank=True)
    category = models.ForeignKey(ContentCategory, on_delete=models.CASCADE, related_name='videos')
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.title

class Podcast(models.Model):
    title = models.CharField(max_length=500)
    description = models.TextField(blank=True)
    cover_image = models.ImageField(upload_to='podcasts/covers/')
    category = models.ForeignKey(ContentCategory, on_delete=models.CASCADE, related_name='podcasts')
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.title

class PodcastEpisode(models.Model):
    podcast = models.ForeignKey(Podcast, on_delete=models.CASCADE, related_name='episodes')
    title = models.CharField(max_length=500)
    audio_file = models.FileField(upload_to='podcasts/episodes/', blank=True, null=True)
    audio_url = models.URLField(blank=True, null=True)
    video_file = models.FileField(upload_to='podcasts/videos/', blank=True, null=True)
    video_url = models.URLField(blank=True, help_text="Link to YouTube or Vimeo video")
    description = models.TextField(blank=True)
    duration = models.CharField(max_length=100, blank=True, help_text="e.g. 45:20")
    episode_number = models.PositiveIntegerField(default=1)
    season_number = models.PositiveIntegerField(default=1)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.podcast.title} - {self.title}"

class Reel(models.Model):
    title = models.CharField(max_length=500)
    video_file = models.FileField(upload_to='reels/')
    thumbnail = models.ImageField(upload_to='reels/thumbnails/', blank=True, null=True)
    description = models.TextField(blank=True)
    category = models.ForeignKey(ContentCategory, on_delete=models.CASCADE, related_name='reels')
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.title

class QuranSurah(models.Model):
    surah_number = models.PositiveIntegerField()
    surah_name = models.CharField(max_length=200)
    surah_name_arabic = models.CharField(max_length=200, blank=True)
    juz_number = models.PositiveIntegerField()
    juz_name = models.CharField(max_length=200, blank=True, help_text="Optional name for the Juz (e.g. Amma)")
    audio_file = models.FileField(upload_to='quran/audio/', blank=True, null=True)
    pdf_file = models.FileField(upload_to='quran/pdfs/', blank=True, null=True)
    reciter = models.CharField(max_length=200, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = 'Quran Surah'
        verbose_name_plural = 'Quran Surahs'
        ordering = ['surah_number']

    def __str__(self):
        return f"{self.surah_number}. {self.surah_name}"

class Ayah(models.Model):
    surah = models.ForeignKey(QuranSurah, on_delete=models.CASCADE, related_name='ayahs', null=True, blank=True)
    surah_number = models.PositiveIntegerField(default=1)
    ayah_number = models.PositiveIntegerField(default=1)
    text = models.TextField()
    translation = models.TextField()
    reference = models.CharField(max_length=100, help_text="e.g. 3:8", blank=True)
    is_daily = models.BooleanField(default=False, help_text="Set as today's Ayah")
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name_plural = 'Ayahs'

    def __str__(self):
        return f"Ayah {self.reference}"

class VideoSeries(models.Model):
    title = models.CharField(max_length=500)
    description = models.TextField(blank=True)
    cover_image = models.ImageField(upload_to='series/covers/')
    category = models.ForeignKey(ContentCategory, on_delete=models.CASCADE, related_name='series')
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.title

class Clip(models.Model):
    title = models.CharField(max_length=500)
    video_file = models.FileField(upload_to='clips/')
    thumbnail = models.ImageField(upload_to='clips/thumbnails/', blank=True, null=True)
    description = models.TextField(blank=True)
    category = models.ForeignKey(ContentCategory, on_delete=models.CASCADE, related_name='clips')
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.title
