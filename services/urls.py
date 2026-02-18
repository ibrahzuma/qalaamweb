from django.urls import path
from . import views

app_name = 'services'

urlpatterns = [
    path('prayer-times/', views.prayer_times, name='prayer_times'),
    path('calendar/', views.calendar_view, name='calendar'),
]
