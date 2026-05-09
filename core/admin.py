from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as DjangoUserAdmin
from .models import User, Profile, Notification


@admin.register(User)
class UserAdmin(DjangoUserAdmin):
    list_display = ('username', 'email', 'first_name', 'is_scholar', 'is_staff', 'date_joined')
    list_filter = ('is_scholar', 'is_staff', 'is_superuser', 'is_active')
    search_fields = ('username', 'email', 'first_name', 'last_name', 'phone_number')
    fieldsets = DjangoUserAdmin.fieldsets + (
        ('Qalaam', {'fields': ('is_scholar', 'phone_number')}),
    )


@admin.register(Profile)
class ProfileAdmin(admin.ModelAdmin):
    list_display = ('user', 'location')
    search_fields = ('user__username', 'user__email', 'location')
    raw_id_fields = ('user',)


@admin.register(Notification)
class NotificationAdmin(admin.ModelAdmin):
    list_display = ('title', 'user', 'is_read', 'created_at')
    list_filter = ('is_read', 'created_at')
    search_fields = ('title', 'message', 'user__username')
    raw_id_fields = ('user',)
    list_editable = ('is_read',)
