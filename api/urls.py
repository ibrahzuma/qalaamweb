from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework.authtoken.views import obtain_auth_token
from .views import (
    RegisterAPIView, LoginAPIView, LogoutAPIView, UserAPIView,
    FatwaCategoryViewSet, FatwaViewSet, ArticleCategoryViewSet, ArticleViewSet,
    HadithCollectionViewSet, HadithBookViewSet, HadithViewSet,
    AudioViewSet, BookViewSet, VideoViewSet, ReelViewSet,
    PodcastViewSet, PodcastEpisodeViewSet, QuranSurahViewSet, AyahViewSet,
    DuaCategoryViewSet, DuaViewSet, MosqueViewSet, PrayerTimeAPIView,
    ContentCategoryViewSet, VideoSeriesViewSet, ClipViewSet, DhikrViewSet,
)

router = DefaultRouter()
# ... (existing router registrations)
router.register(r'fatwa-categories', FatwaCategoryViewSet)
router.register(r'fatwa', FatwaViewSet)
router.register(r'articles', ArticleViewSet)
router.register(r'hadiths/collections', HadithCollectionViewSet, basename='hadith-collections')
router.register(r'hadiths', HadithViewSet)
router.register(r'studio/series', VideoSeriesViewSet)
router.register(r'studio', VideoViewSet, basename='studio')
router.register(r'reels', ReelViewSet)
router.register(r'podcasts', PodcastViewSet)
router.register(r'podcast-episodes', PodcastEpisodeViewSet)
router.register(r'quran/surahs', QuranSurahViewSet)
router.register(r'quran/ayahs', AyahViewSet)
router.register(r'duas', DuaViewSet)
router.register(r'mosques', MosqueViewSet)
router.register(r'clips', ClipViewSet)
router.register(r'dhikrs', DhikrViewSet)
router.register(r'books', BookViewSet)
router.register(r'audios', AudioViewSet)

urlpatterns = [
    path('auth/register/', RegisterAPIView.as_view(), name='api_register'),
    path('auth/login/', LoginAPIView.as_view(), name='api_login'),
    path('auth/logout/', LogoutAPIView.as_view(), name='api_logout'),
    path('auth/profile/', UserAPIView.as_view(), name='api_profile'),
    path('prayer-times/', PrayerTimeAPIView.as_view(), name='api_prayer_times'),
    path('quran/ayah/daily/', AyahViewSet.as_view({'get': 'daily'}), name='api_daily_ayah'),
    path('hadiths/daily/', HadithViewSet.as_view({'get': 'daily'}), name='api_daily_hadith'),
    path('duas/daily/', DuaViewSet.as_view({'get': 'daily'}), name='api_daily_dua'),
    path('', include(router.urls)),
]
