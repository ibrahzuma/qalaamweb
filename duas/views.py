from django.shortcuts import render, get_object_or_404
from .models import Dua, DuaCategory
from django.db.models import Q

def dua_list(request):
    categories = DuaCategory.objects.all()
    query = request.GET.get('q') or request.GET.get('search')
    category_slug = request.GET.get('category')
    
    duas = Dua.objects.all().order_by('-created_at')
    current_category = None
    
    if category_slug:
        current_category = get_object_or_404(DuaCategory, slug=category_slug)
        duas = duas.filter(Q(category=current_category) | Q(category__parent=current_category))
    
    if query:
        duas = duas.filter(
            Q(title__icontains=query) | 
            Q(translation__icontains=query) |
            Q(arabic_text__icontains=query)
        )
        
    return render(request, 'duas/dua_list.html', {
        'duas': duas,
        'categories': categories,
        'query': query,
        'current_category': current_category
    })

def dua_detail(request, slug):
    dua = get_object_or_404(Dua, slug=slug)
    return render(request, 'duas/dua_detail.html', {'dua': dua})
