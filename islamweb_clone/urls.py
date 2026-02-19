from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from core.views import home

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', home, name='home'),
    path('fatwa/', include('fatwa.urls')),
    path('articles/', include('articles.urls')),
    path('duas/', include('duas.urls')),
    path('content/', include('content.urls')),
    path('services/', include('services.urls')), # Added services.urls
    path('ckeditor/', include('ckeditor_uploader.urls')),
    path('admin-panel/', include('dashboard.urls')),
    path('hadiths/', include('hadiths.urls')),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
