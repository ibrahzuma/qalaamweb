from django.urls import path

from . import views as v

app_name = 'dashboard'


def _crud_paths(slug, list_view, create_view, update_view, delete_view, *,
                base=None, name_prefix=None):
    """Yield 4 URL patterns for list/create/edit/delete of one model."""
    base = base or slug
    name_prefix = name_prefix or slug
    return [
        path(f'{base}/', list_view.as_view(), name=f'{name_prefix}_list'),
        path(f'{base}/new/', create_view.as_view(), name=f'{name_prefix}_create'),
        path(f'{base}/<int:pk>/edit/', update_view.as_view(), name=f'{name_prefix}_edit'),
        path(f'{base}/<int:pk>/delete/', delete_view.as_view(), name=f'{name_prefix}_delete'),
    ]


urlpatterns = [
    # Index + auth
    path('', v.DashboardIndexView.as_view(), name='index'),
    path('login/', v.DashboardLoginView.as_view(), name='login'),
    path('logout/', v.DashboardLogoutView.as_view(), name='logout'),
    path('register/', v.RegisterView.as_view(), name='register'),

    # Users
    path('users/', v.UserManagementView.as_view(), name='users'),
    path('users/new/', v.UserCreateView.as_view(), name='user_create'),
    path('users/<int:pk>/edit/', v.UserUpdateView.as_view(), name='user_edit'),
    path('users/<int:pk>/delete/', v.UserDeleteView.as_view(), name='user_delete'),

    # Categories overview
    path('categories/', v.CategoryListView.as_view(), name='category_list'),

    # Category CRUD per type
    path('categories/article/new/', v.ArticleCategoryCreateView.as_view(), name='article_category_create'),
    path('categories/article/<int:pk>/edit/', v.ArticleCategoryUpdateView.as_view(), name='article_category_edit'),
    path('categories/article/<int:pk>/delete/', v.ArticleCategoryDeleteView.as_view(), name='article_category_delete'),
    path('categories/fatwa/new/', v.FatwaCategoryCreateView.as_view(), name='fatwa_category_create'),
    path('categories/fatwa/<int:pk>/edit/', v.FatwaCategoryUpdateView.as_view(), name='fatwa_category_edit'),
    path('categories/fatwa/<int:pk>/delete/', v.FatwaCategoryDeleteView.as_view(), name='fatwa_category_delete'),
    path('categories/content/new/', v.ContentCategoryCreateView.as_view(), name='content_category_create'),
    path('categories/content/<int:pk>/edit/', v.ContentCategoryUpdateView.as_view(), name='content_category_edit'),
    path('categories/content/<int:pk>/delete/', v.ContentCategoryDeleteView.as_view(), name='content_category_delete'),
    path('categories/dua/new/', v.DuaCategoryCreateView.as_view(), name='dua_category_create'),
    path('categories/dua/<int:pk>/edit/', v.DuaCategoryUpdateView.as_view(), name='dua_category_edit'),
    path('categories/dua/<int:pk>/delete/', v.DuaCategoryDeleteView.as_view(), name='dua_category_delete'),

    # Bulk delete
    path('bulk-delete/<str:model_name>/', v.BulkDeleteView.as_view(), name='bulk_delete'),

    # Backwards-compat alias for old templates that use {% url 'dashboard:home' %}
    path('home/', v.DashboardIndexView.as_view(), name='home'),
    path('content/', v.ContentManagementView.as_view(), name='content'),

    # ── CRUD ─────────────────────────────────────────────────────
    *_crud_paths('articles', v.ArticleListView, v.ArticleCreateView, v.ArticleUpdateView, v.ArticleDeleteView, name_prefix='article'),
    *_crud_paths('fatwa', v.FatwaListView, v.FatwaCreateView, v.FatwaUpdateView, v.FatwaDeleteView, name_prefix='fatwa'),
    *_crud_paths('audio', v.AudioListView, v.AudioCreateView, v.AudioUpdateView, v.AudioDeleteView, name_prefix='audio'),
    *_crud_paths('books', v.BookListView, v.BookCreateView, v.BookUpdateView, v.BookDeleteView, name_prefix='book'),
    *_crud_paths('videos', v.VideoListView, v.VideoCreateView, v.VideoUpdateView, v.VideoDeleteView, name_prefix='video'),
    *_crud_paths('podcasts', v.PodcastListView, v.PodcastCreateView, v.PodcastUpdateView, v.PodcastDeleteView, name_prefix='podcast'),
    *_crud_paths('podcast-episodes', v.PodcastEpisodeListView, v.PodcastEpisodeCreateView, v.PodcastEpisodeUpdateView, v.PodcastEpisodeDeleteView, name_prefix='podcast_episode'),
    *_crud_paths('reels', v.ReelListView, v.ReelCreateView, v.ReelUpdateView, v.ReelDeleteView, name_prefix='reel'),
    *_crud_paths('quran', v.QuranSurahListView, v.QuranSurahCreateView, v.QuranSurahUpdateView, v.QuranSurahDeleteView, name_prefix='quran'),
    *_crud_paths('hadiths', v.HadithListView, v.HadithCreateView, v.HadithUpdateView, v.HadithDeleteView, name_prefix='hadith'),
    *_crud_paths('hadith-collections', v.HadithCollectionListView, v.HadithCollectionCreateView, v.HadithCollectionUpdateView, v.HadithCollectionDeleteView, name_prefix='hadith_collection'),
    *_crud_paths('duas', v.DuaListView, v.DuaCreateView, v.DuaUpdateView, v.DuaDeleteView, name_prefix='dua'),
    *_crud_paths('dhikrs', v.DhikrListView, v.DhikrCreateView, v.DhikrUpdateView, v.DhikrDeleteView, name_prefix='dhikr'),
    *_crud_paths('mosques', v.MosqueListView, v.MosqueCreateView, v.MosqueUpdateView, v.MosqueDeleteView, name_prefix='mosque'),
]
