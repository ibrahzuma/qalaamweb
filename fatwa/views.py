from django.shortcuts import render, redirect
from django.views.generic import ListView, DetailView
from .models import Fatwa
from .forms import FatwaForm

class FatwaListView(ListView):
    model = Fatwa
    template_name = 'fatwa/fatwa_list.html'
    context_object_name = 'fatawa'
    paginate_by = 20

    def get_queryset(self):
        return Fatwa.objects.filter(status='answered').order_by('-created_at')

class FatwaDetailView(DetailView):
    model = Fatwa
    template_name = 'fatwa/fatwa_detail.html'
    context_object_name = 'fatwa'

    def get_object(self):
        obj = super().get_object()
        obj.view_count += 1
        obj.save()
        return obj

def ask_fatwa(request):
    if request.method == 'POST':
        form = FatwaForm(request.POST)
        if form.is_valid():
            form.save()
            return redirect('fatwa:fatwa_list')
    else:
        form = FatwaForm()
    return render(request, 'fatwa/ask_fatwa.html', {'form': form})
