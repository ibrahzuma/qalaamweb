from django.views.generic import ListView, DetailView
from .models import HadithCollection, Hadith, HadithBook
from django.shortcuts import get_object_or_404

class CollectionListView(ListView):
    model = HadithCollection
    template_name = 'hadiths/collection_list.html'
    context_object_name = 'collections'

class BookListView(ListView):
    model = HadithBook
    template_name = 'hadiths/book_list.html'
    context_object_name = 'books'

    def get_queryset(self):
        return HadithBook.objects.filter(collection__slug=self.kwargs['slug']).order_by('book_number')

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['collection'] = get_object_or_404(HadithCollection, slug=self.kwargs['slug'])
        return context

class HadithListView(ListView):
    model = Hadith
    template_name = 'hadiths/hadith_list.html'
    context_object_name = 'hadiths'
    paginate_by = 50

    def get_queryset(self):
        qs = Hadith.objects.filter(collection__slug=self.kwargs['slug'])
        book_number = self.kwargs.get('book_number')
        if book_number:
            qs = qs.filter(book__book_number=book_number)
        return qs.order_by('id')

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['collection'] = get_object_or_404(HadithCollection, slug=self.kwargs['slug'])
        book_number = self.kwargs.get('book_number')
        if book_number:
            context['book'] = get_object_or_404(HadithBook, collection__slug=self.kwargs['slug'], book_number=book_number)
        return context

class HadithDetailView(DetailView):
    model = Hadith
    template_name = 'hadiths/hadith_detail.html'
    context_object_name = 'hadith'
