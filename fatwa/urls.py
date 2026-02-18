from django.urls import path
from . import views

app_name = 'fatwa'

urlpatterns = [
    path('', views.FatwaListView.as_view(), name='fatwa_list'),
    path('<int:pk>/', views.FatwaDetailView.as_view(), name='fatwa_detail'),
    path('ask/', views.ask_fatwa, name='ask_fatwa'),
]
