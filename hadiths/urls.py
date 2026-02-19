from django.urls import path
from . import views

app_name = 'hadiths'

urlpatterns = [
    path('', views.EditionListView.as_view(), name='edition_list'),
    path('<str:edition_key>/', views.HadithListView.as_view(), name='hadith_list'),
    path('hadith/<int:pk>/', views.HadithDetailView.as_view(), name='hadith_detail'),
]
