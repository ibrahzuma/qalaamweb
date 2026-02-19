from django.urls import path
from . import views

app_name = 'dashboard'

urlpatterns = [
    path('login/', views.CustomLoginView.as_view(), name='login'),
    path('logout/', views.admin_logout, name='logout'),
    path('', views.dashboard_index, name='index'),
    path('fatawa/', views.DashFatwaListView.as_view(), name='fatwa_list'),
    path('articles/', views.DashArticleListView.as_view(), name='article_list'),
    path('audio/', views.DashAudioListView.as_view(), name='audio_list'),
    path('books/', views.DashBookListView.as_view(), name='book_list'),
    
    path('fatwa/create/', views.FatwaCreateView.as_view(), name='fatwa_create'),
    path('fatwa/<int:pk>/update/', views.FatwaUpdateView.as_view(), name='fatwa_edit'),
    path('fatwa/<int:pk>/delete/', views.FatwaDeleteView.as_view(), name='fatwa_delete'),
    
    path('article/create/', views.ArticleCreateView.as_view(), name='article_create'),
    path('article/<int:pk>/update/', views.ArticleUpdateView.as_view(), name='article_edit'),
    path('article/<int:pk>/delete/', views.ArticleDeleteView.as_view(), name='article_delete'),
    
    path('categories/', views.DashCategoryListView.as_view(), name='category_list'),
    path('categories/fatwa/create/', views.FatwaCategoryCreateView.as_view(), name='fatwa_category_create'),
    path('categories/fatwa/<int:pk>/update/', views.FatwaCategoryUpdateView.as_view(), name='fatwa_category_edit'),
    path('categories/fatwa/<int:pk>/delete/', views.FatwaCategoryDeleteView.as_view(), name='fatwa_category_delete'),
    
    path('categories/article/create/', views.ArticleCategoryCreateView.as_view(), name='article_category_create'),
    path('categories/article/<int:pk>/update/', views.ArticleCategoryUpdateView.as_view(), name='article_category_edit'),
    path('categories/article/<int:pk>/delete/', views.ArticleCategoryDeleteView.as_view(), name='article_category_delete'),
    
    path('categories/content/create/', views.ContentCategoryCreateView.as_view(), name='content_category_create'),
    path('categories/content/<int:pk>/update/', views.ContentCategoryUpdateView.as_view(), name='content_category_edit'),
    path('categories/content/<int:pk>/delete/', views.ContentCategoryDeleteView.as_view(), name='content_category_delete'),

    path('audio/create/', views.AudioCreateView.as_view(), name='audio_create'),
    path('audio/<int:pk>/update/', views.AudioUpdateView.as_view(), name='audio_edit'),
    path('audio/<int:pk>/delete/', views.AudioDeleteView.as_view(), name='audio_delete'),
    
    path('book/create/', views.BookCreateView.as_view(), name='book_create'),
    path('book/<int:pk>/update/', views.BookUpdateView.as_view(), name='book_edit'),
    path('book/<int:pk>/delete/', views.BookDeleteView.as_view(), name='book_delete'),
    
    path('duas/', views.DashDuaListView.as_view(), name='dua_list'),
    path('duas/create/', views.DuaCreateView.as_view(), name='dua_create'),
    path('duas/<int:pk>/update/', views.DuaUpdateView.as_view(), name='dua_edit'),
    path('duas/<int:pk>/delete/', views.DuaDeleteView.as_view(), name='dua_delete'),
    path('categories/dua/create/', views.DuaCategoryCreateView.as_view(), name='dua_category_create'),
    path('categories/dua/<int:pk>/update/', views.DuaCategoryUpdateView.as_view(), name='dua_category_edit'),
    path('categories/dua/<int:pk>/delete/', views.DuaCategoryDeleteView.as_view(), name='dua_category_delete'),

    # Hadith Management
    path('hadiths/', views.DashHadithListView.as_view(), name='hadith_list'),
    path('hadiths/create/', views.HadithCreateView.as_view(), name='hadith_create'),
    path('hadiths/<int:pk>/update/', views.HadithUpdateView.as_view(), name='hadith_edit'),
    path('hadiths/<int:pk>/delete/', views.HadithDeleteView.as_view(), name='hadith_delete'),
    
    path('hadith-collections/', views.DashHadithCollectionListView.as_view(), name='hadith_collection_list'),
    path('hadith-collections/create/', views.HadithCollectionCreateView.as_view(), name='hadith_collection_create'),
]
