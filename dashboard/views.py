from django.shortcuts import render
from django.contrib.admin.views.decorators import staff_member_required
from django.db.models import Count, Sum
from fatwa.models import Fatwa, FatwaCategory
from articles.models import Article, ArticleCategory
from content.models import Audio, Book, ContentCategory
from duas.models import Dua, DuaCategory
from django.views.generic import ListView, CreateView, UpdateView, DeleteView
from django.urls import reverse_lazy
from django.contrib.auth.mixins import LoginRequiredMixin, UserPassesTestMixin
from django.utils.text import slugify

@staff_member_required
def dashboard_index(request):
    fatawa_count = Fatwa.objects.filter(status='answered').count()
    pending_fatawa = Fatwa.objects.filter(status='pending').count()
    articles_count = Article.objects.count()
    audio_count = Audio.objects.count()
    duas_count = Dua.objects.count()
    
    # Simple "Recent items" logic
    recent_fatawa = Fatwa.objects.order_by('-created_at')[:3]
    recent_articles = Article.objects.order_by('-created_at')[:3]
    
    recent_items = []
    for f in recent_fatawa:
        recent_items.append({'title': f.title, 'type': 'Fatwa', 'views': f.view_count, 'date': f.created_at})
    for a in recent_articles:
        recent_items.append({'title': a.title, 'type': 'Article', 'views': a.view_count, 'date': a.created_at})
        
    recent_items = sorted(recent_items, key=lambda x: x['date'], reverse=True)

    # Popular content (highest views)
    popular_fatawa = Fatwa.objects.order_by('-view_count')[:3]
    popular_articles = Article.objects.order_by('-view_count')[:2]
    popular_items = list(popular_fatawa) + list(popular_articles)
    popular_items = sorted(popular_items, key=lambda x: x.view_count, reverse=True)[:5]

    stats = {
        'fatawa_count': fatawa_count,
        'pending_fatawa': pending_fatawa,
        'articles_count': articles_count,
        'audio_count': audio_count,
        'duas_count': duas_count,
    }
    
    return render(request, 'dashboard/index.html', {
        'stats': stats,
        'recent_items': recent_items,
        'popular_items': popular_items
    })

# Content Management Views (CRUD)
class StaffRequiredMixin(UserPassesTestMixin):
    def test_func(self):
        return self.request.user.is_staff

class DashFatwaListView(LoginRequiredMixin, StaffRequiredMixin, ListView):
    model = Fatwa
    template_name = 'dashboard/fatwa_list.html'
    context_object_name = 'fatawa'
    paginate_by = 15
    ordering = ['-created_at']

class DashArticleListView(LoginRequiredMixin, StaffRequiredMixin, ListView):
    model = Article
    template_name = 'dashboard/article_list.html'
    context_object_name = 'articles'
    paginate_by = 15
    ordering = ['-created_at']

# CRUD Views
class FatwaCreateView(LoginRequiredMixin, StaffRequiredMixin, CreateView):
    model = Fatwa
    fields = ['title', 'category', 'question', 'answer', 'status']
    template_name = 'dashboard/form.html'
    success_url = reverse_lazy('dashboard:fatwa_list')

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['title'] = "Push New Fatwa"
        return context

class ArticleCreateView(LoginRequiredMixin, StaffRequiredMixin, CreateView):
    model = Article
    fields = ['title', 'category', 'main_image', 'content', 'author']
    template_name = 'dashboard/form.html'
    success_url = reverse_lazy('dashboard:article_list')

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['title'] = "Write New Article"
        return context

class FatwaUpdateView(LoginRequiredMixin, StaffRequiredMixin, UpdateView):
    model = Fatwa
    fields = ['title', 'category', 'question', 'answer', 'status']
    template_name = 'dashboard/form.html'
    success_url = reverse_lazy('dashboard:fatwa_list')

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['title'] = "Edit Fatwa"
        return context

class ArticleUpdateView(LoginRequiredMixin, StaffRequiredMixin, UpdateView):
    model = Article
    fields = ['title', 'category', 'main_image', 'content', 'author']
    template_name = 'dashboard/form.html'
    success_url = reverse_lazy('dashboard:article_list')

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['title'] = "Edit Article"
        return context

class DashAudioListView(LoginRequiredMixin, StaffRequiredMixin, ListView):
    model = Audio
    template_name = 'dashboard/audio_list.html'
    context_object_name = 'audios'
    paginate_by = 15
    ordering = ['-created_at']

class DashBookListView(LoginRequiredMixin, StaffRequiredMixin, ListView):
    model = Book
    template_name = 'dashboard/book_list.html'
    context_object_name = 'books'
    paginate_by = 15
    ordering = ['-created_at']

class BookUpdateView(LoginRequiredMixin, StaffRequiredMixin, UpdateView):
    model = Book
    fields = ['title', 'author', 'category', 'cover_image', 'pdf_file', 'description']
    template_name = 'dashboard/form.html'
    success_url = reverse_lazy('dashboard:book_list')
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['title'] = "Edit Book"
        return context

class AudioCreateView(LoginRequiredMixin, StaffRequiredMixin, CreateView):
    model = Audio
    fields = ['title', 'speaker', 'category', 'file']
    template_name = 'dashboard/form.html'
    success_url = reverse_lazy('dashboard:audio_list')
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['title'] = "Add New Audio"
        return context

class AudioUpdateView(LoginRequiredMixin, StaffRequiredMixin, UpdateView):
    model = Audio
    fields = ['title', 'speaker', 'category', 'file']
    template_name = 'dashboard/form.html'
    success_url = reverse_lazy('dashboard:audio_list')
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['title'] = "Edit Audio"
        return context

class BookCreateView(LoginRequiredMixin, StaffRequiredMixin, CreateView):
    model = Book
    fields = ['title', 'author', 'category', 'cover_image', 'pdf_file', 'description']
    template_name = 'dashboard/form.html'
    success_url = reverse_lazy('dashboard:book_list')
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['title'] = "Add New Book"
        return context


# Category Management
class FatwaCategoryCreateView(LoginRequiredMixin, StaffRequiredMixin, CreateView):
    model = FatwaCategory
    fields = ['name', 'parent']
    template_name = 'dashboard/form.html'
    success_url = reverse_lazy('dashboard:fatwa_list')

    def form_valid(self, form):
        form.instance.slug = slugify(form.instance.name)
        return super().form_valid(form)

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['title'] = "Add Fatwa Category"
        return context

class ArticleCategoryCreateView(LoginRequiredMixin, StaffRequiredMixin, CreateView):
    model = ArticleCategory
    fields = ['name', 'parent']
    template_name = 'dashboard/form.html'
    success_url = reverse_lazy('dashboard:article_list')

    def form_valid(self, form):
        form.instance.slug = slugify(form.instance.name)
        return super().form_valid(form)

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['title'] = "Add Article Category"
        return context

class ContentCategoryCreateView(LoginRequiredMixin, StaffRequiredMixin, CreateView):
    model = ContentCategory
    fields = ['name', 'parent']
    template_name = 'dashboard/form.html'
    success_url = reverse_lazy('dashboard:audio_list')

    def form_valid(self, form):
        form.instance.slug = slugify(form.instance.name)
        return super().form_valid(form)

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['title'] = "Add Content Category"
        return context

# Dua Management
class DashDuaListView(LoginRequiredMixin, StaffRequiredMixin, ListView):
    model = Dua
    template_name = 'dashboard/dua_list.html'
    context_object_name = 'duas'
    paginate_by = 15
    ordering = ['-created_at']

class DuaCreateView(LoginRequiredMixin, StaffRequiredMixin, CreateView):
    model = Dua
    fields = ['title', 'category', 'arabic_text', 'translation', 'transliteration', 'reference']
    template_name = 'dashboard/form.html'
    success_url = reverse_lazy('dashboard:dua_list')
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['title'] = "Add New Dua"
        return context

class DuaUpdateView(LoginRequiredMixin, StaffRequiredMixin, UpdateView):
    model = Dua
    fields = ['title', 'category', 'arabic_text', 'translation', 'transliteration', 'reference']
    template_name = 'dashboard/form.html'
    success_url = reverse_lazy('dashboard:dua_list')
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['title'] = "Edit Dua"
        return context

class DuaCategoryCreateView(LoginRequiredMixin, StaffRequiredMixin, CreateView):
    model = DuaCategory
    fields = ['name', 'parent']
    template_name = 'dashboard/form.html'
    success_url = reverse_lazy('dashboard:dua_list')
    def form_valid(self, form):
        form.instance.slug = slugify(form.instance.name)
        return super().form_valid(form)
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['title'] = "Add Dua Category"
        return context

# Delete Views
class FatwaDeleteView(LoginRequiredMixin, StaffRequiredMixin, DeleteView):
    model = Fatwa
    template_name = 'dashboard/confirm_delete.html'
    success_url = reverse_lazy('dashboard:fatwa_list')

class ArticleDeleteView(LoginRequiredMixin, StaffRequiredMixin, DeleteView):
    model = Article
    template_name = 'dashboard/confirm_delete.html'
    success_url = reverse_lazy('dashboard:article_list')

class AudioDeleteView(LoginRequiredMixin, StaffRequiredMixin, DeleteView):
    model = Audio
    template_name = 'dashboard/confirm_delete.html'
    success_url = reverse_lazy('dashboard:audio_list')

class BookDeleteView(LoginRequiredMixin, StaffRequiredMixin, DeleteView):
    model = Book
    template_name = 'dashboard/confirm_delete.html'
    success_url = reverse_lazy('dashboard:book_list')

class DuaDeleteView(LoginRequiredMixin, StaffRequiredMixin, DeleteView):
    model = Dua
    template_name = 'dashboard/confirm_delete.html'
    success_url = reverse_lazy('dashboard:dua_list')

# Category Management (Update/Delete)
class FatwaCategoryUpdateView(LoginRequiredMixin, StaffRequiredMixin, UpdateView):
    model = FatwaCategory
    fields = ['name', 'parent']
    template_name = 'dashboard/form.html'
    success_url = reverse_lazy('dashboard:fatwa_list')
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['title'] = "Edit Fatwa Category"
        return context

class FatwaCategoryDeleteView(LoginRequiredMixin, StaffRequiredMixin, DeleteView):
    model = FatwaCategory
    template_name = 'dashboard/confirm_delete.html'
    success_url = reverse_lazy('dashboard:fatwa_list')

class ArticleCategoryUpdateView(LoginRequiredMixin, StaffRequiredMixin, UpdateView):
    model = ArticleCategory
    fields = ['name', 'parent']
    template_name = 'dashboard/form.html'
    success_url = reverse_lazy('dashboard:article_list')
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['title'] = "Edit Article Category"
        return context

class ArticleCategoryDeleteView(LoginRequiredMixin, StaffRequiredMixin, DeleteView):
    model = ArticleCategory
    template_name = 'dashboard/confirm_delete.html'
    success_url = reverse_lazy('dashboard:article_list')

class ContentCategoryUpdateView(LoginRequiredMixin, StaffRequiredMixin, UpdateView):
    model = ContentCategory
    fields = ['name', 'parent']
    template_name = 'dashboard/form.html'
    success_url = reverse_lazy('dashboard:audio_list')
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['title'] = "Edit Content Category"
        return context

class ContentCategoryDeleteView(LoginRequiredMixin, StaffRequiredMixin, DeleteView):
    model = ContentCategory
    template_name = 'dashboard/confirm_delete.html'
    success_url = reverse_lazy('dashboard:audio_list')

class DuaCategoryUpdateView(LoginRequiredMixin, StaffRequiredMixin, UpdateView):
    model = DuaCategory
    fields = ['name', 'parent']
    template_name = 'dashboard/form.html'
    success_url = reverse_lazy('dashboard:dua_list')
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['title'] = "Edit Dua Category"
        return context

class DuaCategoryDeleteView(LoginRequiredMixin, StaffRequiredMixin, DeleteView):
    model = DuaCategory
    template_name = 'dashboard/confirm_delete.html'
    success_url = reverse_lazy('dashboard:dua_list')

class DashCategoryListView(LoginRequiredMixin, StaffRequiredMixin, ListView):
    template_name = 'dashboard/category_list.html'
    context_object_name = 'categories'
    
    def get_queryset(self):
        return {
            'fatwa': FatwaCategory.objects.all(),
            'article': ArticleCategory.objects.all(),
            'content': ContentCategory.objects.all(),
            'dua': DuaCategory.objects.all(),
        }
