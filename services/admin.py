from django.contrib import admin
from .models import Mosque, PrayerTime


@admin.register(Mosque)
class MosqueAdmin(admin.ModelAdmin):
    list_display = ('name', 'imam_name', 'is_verified', 'created_at')
    list_filter = ('is_verified',)
    search_fields = ('name', 'imam_name', 'address')
    list_editable = ('is_verified',)
    fieldsets = (
        (None, {'fields': ('name', 'address', 'image', 'is_verified')}),
        ('Location', {'fields': ('latitude', 'longitude')}),
        ('Contact', {'fields': ('imam_name', 'contact_number', 'description')}),
    )


@admin.register(PrayerTime)
class PrayerTimeAdmin(admin.ModelAdmin):
    list_display = ('mosque', 'date', 'fajr', 'dhuhr', 'asr', 'maghrib', 'isha', 'jummah')
    list_filter = ('mosque', 'date')
    search_fields = ('mosque__name',)
    date_hierarchy = 'date'
    raw_id_fields = ('mosque',)
