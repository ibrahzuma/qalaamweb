from django.urls import path
from . import views

app_name = 'content'

urlpatterns = [
    path('audio/', views.AudioListView.as_view(), name='audio_list'),
    path('books/', views.BookListView.as_view(), name='book_list'),
    path('quran/', views.QuranListView.as_view(), name='quran_list'),
    path('kids/', views.KidsListView.as_view(), name='kids_list'),
    path('book/<int:pk>/read/', views.BookReaderView.as_view(), name='book_reader'),
    path('teachings/', views.TeachingListView.as_view(), name='teaching_list'),
    path('videos/', views.VideoListView.as_view(), name='video_list'),
    path('podcasts/', views.PodcastListView.as_view(), name='podcast_list'),
    path('podcast/<int:pk>/', views.PodcastDetailView.as_view(), name='podcast_detail'),
]
