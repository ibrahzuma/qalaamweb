from django.views.generic import ListView, DetailView
from .models import HadithCollection, Hadith

class CollectionListView(ListView):
    model = HadithCollection
    template_name = 'hadiths/collection_list.html'
    context_object_name = 'collections'

class HadithListView(ListView):
    model = Hadith
    template_name = 'hadiths/hadith_list.html'
    context_object_name = 'hadiths'
    paginate_by = 20

    def get_queryset(self):
        return Hadith.objects.filter(collection__slug=self.kwargs['slug']).order_by('id')

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['collection'] = HadithCollection.objects.get(slug=self.kwargs['slug'])
        return context

class HadithDetailView(DetailView):
    model = Hadith
    template_name = 'hadiths/hadith_detail.html'
    context_object_name = 'hadith'
