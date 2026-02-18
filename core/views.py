from django.shortcuts import render
from fatwa.models import Fatwa
from articles.models import Article
from content.models import Audio, Book

def home(request):
    featured_fatawa = Fatwa.objects.filter(status='answered').order_by('-created_at')[:5]
    latest_articles = Article.objects.all().order_by('-created_at')[:6]
    latest_audio = Audio.objects.all().order_by('-created_at')[:4]
    latest_books = Book.objects.all().order_by('-created_at')[:4]
    
    context = {
        'featured_fatawa': featured_fatawa,
        'latest_articles': latest_articles,
        'latest_audio': latest_audio,
        'latest_books': latest_books,
    }
    return render(request, 'core/home.html', context)
