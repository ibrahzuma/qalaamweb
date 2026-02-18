from django.shortcuts import render

def prayer_times(request):
    return render(request, 'services/prayer_times.html')

def calendar_view(request):
    return render(request, 'services/calendar.html')
