from .models import Audio, Book, ContentCategory, Video, Podcast, PodcastEpisode
from django.db.models import Q
from django.views.generic import ListView, DetailView

class AudioListView(ListView):
    # ... (existing code remains substantially same, just ensuring imports are correct)
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

class VideoListView(ListView):
    model = Video
    template_name = 'content/video_list.html'
    context_object_name = 'videos'
    paginate_by = 12

    def get_queryset(self):
        queryset = super().get_queryset()
        query = self.request.GET.get('q')
        category_slug = self.request.GET.get('category')
        if query:
            queryset = queryset.filter(title__icontains=query)
        if category_slug:
            queryset = queryset.filter(category__slug=category_slug)
        return queryset

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['categories'] = ContentCategory.objects.all()
        context['current_category'] = self.request.GET.get('category')
        context['query'] = self.request.GET.get('q')
        return context

class PodcastListView(ListView):
    model = Podcast
    template_name = 'content/podcast_list.html'
    context_object_name = 'podcasts'
    paginate_by = 12

    def get_queryset(self):
        queryset = super().get_queryset()
        query = self.request.GET.get('q')
        if query:
            queryset = queryset.filter(title__icontains=query)
        return queryset

class PodcastDetailView(DetailView):
    model = Podcast
    template_name = 'content/podcast_detail.html'
    context_object_name = 'podcast'

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['episodes'] = self.object.episodes.all().order_by('-created_at')
        return context

class TeachingListView(ListView):
    template_name = 'content/teaching_list.html'
    context_object_name = 'teachings'
    
    def get_queryset(self):
        # We'll handle multiple types of content in context
        return None

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        # Filter content related to Teachings category
        try:
            teaching_cat = ContentCategory.objects.get(name__iexact='Teachings')
            teaching_cats = [teaching_cat] + list(teaching_cat.get_descendants())
            
            context['audios'] = Audio.objects.filter(category__in=teaching_cats)[:4]
            context['videos'] = Video.objects.filter(category__in=teaching_cats)[:4]
            context['books'] = Book.objects.filter(category__in=teaching_cats)[:4]
            context['category'] = teaching_cat
        except ContentCategory.DoesNotExist:
            context['audios'] = Audio.objects.none()
            context['videos'] = Video.objects.none()
            context['books'] = Book.objects.none()
            
        return context
