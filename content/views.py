from .models import Audio, Book, ContentCategory
from django.db.models import Q
from django.views.generic import ListView, DetailView

class AudioListView(ListView):
    model = Audio
    template_name = 'content/audio_list.html'
    context_object_name = 'audios'
    paginate_by = 20

    def get_queryset(self):
        # Filter for Lectures root or children of Lectures
        queryset = Audio.objects.filter(
            Q(category__name__iexact='Lectures') | 
            Q(category__parent__name__iexact='Lectures')
        )
        
        query = self.request.GET.get('q')
        category_slug = self.request.GET.get('category')
        
        if query:
            queryset = queryset.filter(
                Q(title__icontains=query) | 
                Q(speaker__icontains=query)
            )
        
        if category_slug:
            queryset = queryset.filter(category__slug=category_slug)
            
        return queryset

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        query = self.request.GET.get('q')
        category_slug = self.request.GET.get('category')
        
        try:
            lectures_cat = ContentCategory.objects.get(name__iexact='Lectures')
            context['categories'] = lectures_cat.get_children()
        except ContentCategory.DoesNotExist:
            context['categories'] = []
            
        context['current_category'] = category_slug
        context['query'] = query
        
        # Logic to show categories grid or audio list
        # Show categories if no category is selected AND no search query
        context['show_categories'] = not category_slug and not query
        
        return context

class BookListView(ListView):
    model = Book
    template_name = 'content/book_list.html'
    context_object_name = 'books'
    paginate_by = 12

    def get_queryset(self):
        queryset = super().get_queryset()
        query = self.request.GET.get('q')
        category_slug = self.request.GET.get('category')
        
        if query:
            queryset = queryset.filter(
                Q(title__icontains=query) | 
                Q(author__icontains=query) |
                Q(description__icontains=query)
            )
        
        if category_slug:
            queryset = queryset.filter(category__slug=category_slug)
            
        return queryset

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['categories'] = ContentCategory.objects.all()
        context['current_category'] = self.request.GET.get('category')
        context['query'] = self.request.GET.get('q')
        return context

class QuranListView(ListView):
    model = Audio
    template_name = 'content/quran_list.html'
    context_object_name = 'surahs'
    paginate_by = 50

    def get_queryset(self):
        queryset = Audio.objects.filter(
            Q(category__name__iexact='Quran') | 
            Q(category__parent__name__iexact='Quran')
        )
        
        query = self.request.GET.get('q')
        reciter_slug = self.request.GET.get('reciter')
        
        if query:
            queryset = queryset.filter(title__icontains=query)
        
        if reciter_slug:
            queryset = queryset.filter(category__slug=reciter_slug)
            
        return queryset

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        try:
            quran_cat = ContentCategory.objects.get(name__iexact='Quran')
            context['reciters'] = quran_cat.get_children()
        except ContentCategory.DoesNotExist:
            context['reciters'] = []
            
        context['current_reciter'] = self.request.GET.get('reciter')
        context['query'] = self.request.GET.get('q')
        return context

class KidsListView(ListView):
    model = Audio  # Primary model, we'll fetch books in context
    template_name = 'content/kids_list.html'
    context_object_name = 'audios'
    paginate_by = 20

    def get_queryset(self):
        # Filter for Kids root or children of Kids
        queryset = Audio.objects.filter(
            Q(category__name__iexact='Kids') | 
            Q(category__parent__name__iexact='Kids')
        )
        
        query = self.request.GET.get('q')
        category_slug = self.request.GET.get('category')
        
        if query:
            queryset = queryset.filter(title__icontains=query)
        
        if category_slug:
            queryset = queryset.filter(category__slug=category_slug)
            
        return queryset

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        try:
            kids_cat = ContentCategory.objects.get(name__iexact='Kids')
            context['kids_categories'] = kids_cat.get_children()
        except ContentCategory.DoesNotExist:
            context['kids_categories'] = []
            
        # Also fetch Kids books
        kids_books = Book.objects.filter(
            Q(category__name__iexact='Kids') | 
            Q(category__parent__name__iexact='Kids')
        )
        
        category_slug = self.request.GET.get('category')
        if category_slug:
            kids_books = kids_books.filter(category__slug=category_slug)
            
        context['books'] = kids_books
        context['current_category'] = self.request.GET.get('category')
        context['query'] = self.request.GET.get('q')
        return context

class BookReaderView(DetailView):
    model = Book
    template_name = 'content/book_reader.html'
    context_object_name = 'book'
