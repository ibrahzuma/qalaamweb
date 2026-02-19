from django.urls import path
from . import views

app_name = 'hadiths'

urlpatterns = [
    path('', views.CollectionListView.as_view(), name='collection_list'),
    path('<slug:slug>/', views.HadithListView.as_view(), name='hadith_list'),
    path('hadith/<int:pk>/', views.HadithDetailView.as_view(), name='hadith_detail'),
]
