from django.urls import path
from . import views

app_name = 'duas'

urlpatterns = [
    path('', views.dua_list, name='dua_list'),
    path('<slug:slug>/', views.dua_detail, name='dua_detail'),
]
