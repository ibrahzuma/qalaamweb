from django.views.generic import ListView, DetailView
from .models import HadithEdition, Hadith

class EditionListView(ListView):
    model = HadithEdition
    template_name = 'hadiths/edition_list.html'
    context_object_name = 'editions'

class HadithListView(ListView):
    model = Hadith
    template_name = 'hadiths/hadith_list.html'
    context_object_name = 'hadiths'
    paginate_by = 20

    def get_queryset(self):
        return Hadith.objects.filter(edition__edition_key=self.kwargs['edition_key']).order_by('id')

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['edition'] = HadithEdition.objects.get(edition_key=self.kwargs['edition_key'])
        return context

class HadithDetailView(DetailView):
    model = Hadith
    template_name = 'hadiths/hadith_detail.html'
    context_object_name = 'hadith'
