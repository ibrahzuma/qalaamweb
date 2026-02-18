from django.shortcuts import render
from django.views.generic import ListView, DetailView
from .models import Article

class ArticleListView(ListView):
    model = Article
    template_name = 'articles/article_list.html'
    context_object_name = 'articles'
    paginate_by = 12

    def get_queryset(self):
        return Article.objects.all().order_by('-created_at')

class ArticleDetailView(DetailView):
    model = Article
    template_name = 'articles/article_detail.html'
    context_object_name = 'article'

    def get_object(self):
        obj = super().get_object()
        obj.view_count += 1
        obj.save()
        return obj
