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
    audio_file = models.FileField(upload_to='podcasts/episodes/')
    description = models.TextField(blank=True)
    duration = models.CharField(max_length=100, blank=True, help_text="e.g. 45:20")
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.podcast.title} - {self.title}"
