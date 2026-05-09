"""Custom admin dashboard at /admin-panel/.

Generic CRUD for every content model. The form template uses crispy-forms
+ CKEditor (via {{ form.media }}) so RichTextField fields render fine.
"""
from django.contrib import messages
from django.contrib.auth.mixins import LoginRequiredMixin, UserPassesTestMixin
from django.contrib.auth.views import LoginView, LogoutView
from django.http import HttpResponseRedirect
from django.shortcuts import redirect
from django.urls import reverse_lazy
from django.views import View
from django.views.generic import (
    CreateView, DeleteView, ListView, TemplateView, UpdateView,
)

from articles.models import Article, ArticleCategory
from content.models import (
    Audio, Ayah, Book, Clip, ContentCategory, Podcast, PodcastEpisode,
    QuranSurah, Reel, Video, VideoSeries,
)
from core.models import Notification, Profile, User
from duas.models import Dhikr, Dua, DuaCategory
from fatwa.models import Fatwa, FatwaCategory
from hadiths.models import Hadith, HadithBook, HadithCollection
from services.models import Mosque, PrayerTime

from .forms import CustomUserCreationForm


# ── Auth gates ───────────────────────────────────────────────────────────
class AdminRequiredMixin(UserPassesTestMixin):
    def test_func(self):
        return self.request.user.is_superuser


class _DashboardMixin(LoginRequiredMixin, AdminRequiredMixin):
    pass


# ── Auth views ──────────────────────────────────────────────────────────
class DashboardLoginView(LoginView):
    template_name = 'dashboard/login.html'

    def get_success_url(self):
        return reverse_lazy('dashboard:index')


class DashboardLogoutView(LogoutView):
    next_page = reverse_lazy('dashboard:login')


class RegisterView(CreateView):
    form_class = CustomUserCreationForm
    template_name = 'dashboard/register.html'
    success_url = reverse_lazy('dashboard:login')

    def dispatch(self, request, *args, **kwargs):
        if request.user.is_authenticated:
            return redirect('dashboard:index')
        return super().dispatch(request, *args, **kwargs)


# ── Dashboard home ──────────────────────────────────────────────────────
class DashboardIndexView(_DashboardMixin, TemplateView):
    template_name = 'dashboard/index.html'

    def get_context_data(self, **kwargs):
        ctx = super().get_context_data(**kwargs)
        ctx['stats'] = {
            'users_count': User.objects.count(),
            'articles_count': Article.objects.count(),
            'fatawa_count': Fatwa.objects.filter(status='answered').count(),
            'pending_fatawa': Fatwa.objects.filter(status='pending').count(),
            'books_count': Book.objects.count(),
            'audio_count': Audio.objects.count(),
            'videos_count': Video.objects.count(),
            'podcasts_count': Podcast.objects.count(),
            'duas_count': Dua.objects.count(),
            'dhikrs_count': Dhikr.objects.count(),
            'hadiths_count': Hadith.objects.count(),
            'hadith_collections_count': HadithCollection.objects.count(),
            'surahs_count': QuranSurah.objects.count(),
            'ayahs_count': Ayah.objects.count(),
            'reels_count': Reel.objects.count(),
            'mosques_count': Mosque.objects.count(),
        }
        ctx['recent_users'] = User.objects.order_by('-date_joined')[:5]

        # Recent items across content types — newest 8 entries.
        recent = []
        for item in Article.objects.order_by('-created_at')[:3]:
            recent.append({'title': item.title, 'author': item.author or 'Admin',
                           'type': 'Article', 'views': item.view_count, 'date': item.created_at})
        for item in Fatwa.objects.order_by('-created_at')[:3]:
            recent.append({'title': item.title, 'author': '', 'type': 'Fatwa',
                           'views': item.view_count, 'date': item.created_at})
        for item in Book.objects.order_by('-created_at')[:2]:
            recent.append({'title': item.title, 'author': item.author, 'type': 'Book',
                           'views': 0, 'date': item.created_at})
        recent.sort(key=lambda x: x['date'], reverse=True)
        ctx['recent_items'] = recent[:8]

        ctx['popular_items'] = [
            {'title': a.title, 'views': a.view_count}
            for a in Article.objects.order_by('-view_count')[:5]
        ]
        return ctx


# ── Users ───────────────────────────────────────────────────────────────
class UserManagementView(_DashboardMixin, ListView):
    model = User
    template_name = 'dashboard/user_list.html'
    context_object_name = 'users'
    paginate_by = 25


# ── CRUD factory ────────────────────────────────────────────────────────
class _CreateMixin:
    template_name = 'dashboard/form.html'

    def get_context_data(self, **kwargs):
        ctx = super().get_context_data(**kwargs)
        ctx['title'] = f'Create {self.model._meta.verbose_name.title()}'
        return ctx


class _UpdateMixin:
    template_name = 'dashboard/form.html'

    def get_context_data(self, **kwargs):
        ctx = super().get_context_data(**kwargs)
        ctx['title'] = f'Edit {self.model._meta.verbose_name.title()}'
        return ctx


class _DeleteMixin:
    template_name = 'dashboard/confirm_delete.html'


def _crud_for(model, list_url_name, fields='__all__'):
    """Generate Create/Update/Delete view classes for `model`. List views are
    defined explicitly per model since they map to bespoke templates."""
    success = reverse_lazy(f'dashboard:{list_url_name}')
    create_cls = type(
        f'{model.__name__}CreateView',
        (_DashboardMixin, _CreateMixin, CreateView),
        {'model': model, 'fields': fields, 'success_url': success},
    )
    update_cls = type(
        f'{model.__name__}UpdateView',
        (_DashboardMixin, _UpdateMixin, UpdateView),
        {'model': model, 'fields': fields, 'success_url': success},
    )
    delete_cls = type(
        f'{model.__name__}DeleteView',
        (_DashboardMixin, _DeleteMixin, DeleteView),
        {'model': model, 'success_url': success},
    )
    return create_cls, update_cls, delete_cls


# ── Articles ────────────────────────────────────────────────────────────
class ArticleListView(_DashboardMixin, ListView):
    model = Article
    template_name = 'dashboard/article_list.html'
    context_object_name = 'articles'
    paginate_by = 25
    queryset = Article.objects.select_related('category').order_by('-created_at')


ArticleCreateView, ArticleUpdateView, ArticleDeleteView = _crud_for(Article, 'article_list')


# ── Fatwas ──────────────────────────────────────────────────────────────
class FatwaListView(_DashboardMixin, ListView):
    model = Fatwa
    template_name = 'dashboard/fatwa_list.html'
    context_object_name = 'fatawa'
    paginate_by = 25
    queryset = Fatwa.objects.select_related('category').order_by('-created_at')


FatwaCreateView, FatwaUpdateView, FatwaDeleteView = _crud_for(Fatwa, 'fatwa_list')


# ── Audio ───────────────────────────────────────────────────────────────
class AudioListView(_DashboardMixin, ListView):
    model = Audio
    template_name = 'dashboard/audio_list.html'
    context_object_name = 'audios'
    paginate_by = 25


AudioCreateView, AudioUpdateView, AudioDeleteView = _crud_for(Audio, 'audio_list')


# ── Books ───────────────────────────────────────────────────────────────
class BookListView(_DashboardMixin, ListView):
    model = Book
    template_name = 'dashboard/book_list.html'
    context_object_name = 'books'
    paginate_by = 25


BookCreateView, BookUpdateView, BookDeleteView = _crud_for(Book, 'book_list')


# ── Videos ──────────────────────────────────────────────────────────────
class VideoListView(_DashboardMixin, ListView):
    model = Video
    template_name = 'dashboard/video_list.html'
    context_object_name = 'videos'
    paginate_by = 25


VideoCreateView, VideoUpdateView, VideoDeleteView = _crud_for(Video, 'video_list')


# ── Podcasts ────────────────────────────────────────────────────────────
class PodcastListView(_DashboardMixin, ListView):
    model = Podcast
    template_name = 'dashboard/podcast_list.html'
    context_object_name = 'podcasts'
    paginate_by = 25


PodcastCreateView, PodcastUpdateView, PodcastDeleteView = _crud_for(Podcast, 'podcast_list')


class PodcastEpisodeListView(_DashboardMixin, ListView):
    model = PodcastEpisode
    template_name = 'dashboard/podcast_episode_list.html'
    context_object_name = 'episodes'
    paginate_by = 25

    def get_queryset(self):
        qs = PodcastEpisode.objects.select_related('podcast').order_by('-created_at')
        pod_id = self.request.GET.get('podcast')
        if pod_id:
            qs = qs.filter(podcast_id=pod_id)
        return qs

    def get_context_data(self, **kwargs):
        ctx = super().get_context_data(**kwargs)
        pod_id = self.request.GET.get('podcast')
        if pod_id:
            try:
                ctx['current_podcast'] = Podcast.objects.get(pk=pod_id)
            except Podcast.DoesNotExist:
                pass
        ctx['podcasts'] = Podcast.objects.all()
        return ctx


PodcastEpisodeCreateView, PodcastEpisodeUpdateView, PodcastEpisodeDeleteView = _crud_for(
    PodcastEpisode, 'podcast_episode_list',
)


# ── Reels ───────────────────────────────────────────────────────────────
class ReelListView(_DashboardMixin, ListView):
    model = Reel
    template_name = 'dashboard/reel_list.html'
    context_object_name = 'reels'
    paginate_by = 25


ReelCreateView, ReelUpdateView, ReelDeleteView = _crud_for(Reel, 'reel_list')


# ── Quran ───────────────────────────────────────────────────────────────
class QuranSurahListView(_DashboardMixin, ListView):
    model = QuranSurah
    template_name = 'dashboard/quran_list.html'
    context_object_name = 'surahs'
    paginate_by = 50
    ordering = ['surah_number']


QuranSurahCreateView, QuranSurahUpdateView, QuranSurahDeleteView = _crud_for(
    QuranSurah, 'quran_list',
)


# ── Hadiths ─────────────────────────────────────────────────────────────
class HadithListView(_DashboardMixin, ListView):
    model = Hadith
    template_name = 'dashboard/hadith_list.html'
    context_object_name = 'hadiths'
    paginate_by = 25

    def get_queryset(self):
        qs = Hadith.objects.select_related('collection', 'book').order_by('collection', 'hadith_number')
        coll_id = self.request.GET.get('collection')
        if coll_id:
            qs = qs.filter(collection_id=coll_id)
        return qs

    def get_context_data(self, **kwargs):
        ctx = super().get_context_data(**kwargs)
        ctx['collections'] = HadithCollection.objects.all()
        return ctx


HadithCreateView, HadithUpdateView, HadithDeleteView = _crud_for(Hadith, 'hadith_list')


class HadithCollectionListView(_DashboardMixin, ListView):
    model = HadithCollection
    template_name = 'dashboard/hadith_collection_list.html'
    context_object_name = 'collections'
    paginate_by = 25


HadithCollectionCreateView, HadithCollectionUpdateView, HadithCollectionDeleteView = _crud_for(
    HadithCollection, 'hadith_collection_list',
)


# ── Duas ────────────────────────────────────────────────────────────────
class DuaListView(_DashboardMixin, ListView):
    model = Dua
    template_name = 'dashboard/dua_list.html'
    context_object_name = 'duas'
    paginate_by = 25
    queryset = Dua.objects.select_related('category').order_by('-created_at')


DuaCreateView, DuaUpdateView, DuaDeleteView = _crud_for(Dua, 'dua_list')


# ── Dhikrs ──────────────────────────────────────────────────────────────
class DhikrListView(_DashboardMixin, ListView):
    model = Dhikr
    template_name = 'dashboard/dhikr_list.html'
    context_object_name = 'dhikrs'
    paginate_by = 25


DhikrCreateView, DhikrUpdateView, DhikrDeleteView = _crud_for(Dhikr, 'dhikr_list')


# ── Mosques ─────────────────────────────────────────────────────────────
class MosqueListView(_DashboardMixin, ListView):
    model = Mosque
    template_name = 'dashboard/mosque_list.html'
    context_object_name = 'mosques'
    paginate_by = 25


MosqueCreateView, MosqueUpdateView, MosqueDeleteView = _crud_for(Mosque, 'mosque_list')


# ── User CRUD (password changes go through Django /admin/) ─────────────
UserCreateView, UserUpdateView, UserDeleteView = _crud_for(
    User, 'users',
    fields=('username', 'email', 'first_name', 'last_name', 'is_scholar', 'phone_number',
            'is_staff', 'is_superuser', 'is_active'),
)


# ── Categories overview (consolidated) ─────────────────────────────────
class CategoryListView(_DashboardMixin, TemplateView):
    template_name = 'dashboard/category_list.html'

    def get_context_data(self, **kwargs):
        ctx = super().get_context_data(**kwargs)
        ctx.update({
            'article_categories': ArticleCategory.objects.all(),
            'fatwa_categories': FatwaCategory.objects.all(),
            'dua_categories': DuaCategory.objects.all(),
            'content_categories': ContentCategory.objects.all(),
        })
        return ctx


# Category CRUD for each MPTT category model.
ArticleCategoryCreateView, ArticleCategoryUpdateView, ArticleCategoryDeleteView = _crud_for(
    ArticleCategory, 'category_list',
)
FatwaCategoryCreateView, FatwaCategoryUpdateView, FatwaCategoryDeleteView = _crud_for(
    FatwaCategory, 'category_list',
)
ContentCategoryCreateView, ContentCategoryUpdateView, ContentCategoryDeleteView = _crud_for(
    ContentCategory, 'category_list',
)
DuaCategoryCreateView, DuaCategoryUpdateView, DuaCategoryDeleteView = _crud_for(
    DuaCategory, 'category_list',
)


# ── Bulk delete ────────────────────────────────────────────────────────
_BULK_MODELS = {
    'article': Article, 'fatwa': Fatwa, 'audio': Audio, 'book': Book,
    'video': Video, 'podcast': Podcast, 'podcast-episode': PodcastEpisode,
    'reel': Reel, 'quran': QuranSurah, 'ayah': Ayah, 'hadith': Hadith,
    'hadith-collection': HadithCollection, 'dua': Dua, 'dhikr': Dhikr,
    'mosque': Mosque, 'user': User, 'clip': Clip, 'video-series': VideoSeries,
}


class BulkDeleteView(_DashboardMixin, View):
    """Delete multiple rows of a model at once. Posted from list pages."""

    def post(self, request, model_name):
        model = _BULK_MODELS.get(model_name)
        if not model:
            messages.error(request, f"Unknown model: {model_name}")
            return HttpResponseRedirect(request.META.get('HTTP_REFERER', '/admin-panel/'))
        ids = request.POST.getlist('selected_ids') or request.POST.getlist('ids')
        if not ids:
            messages.warning(request, 'No items selected.')
            return HttpResponseRedirect(request.META.get('HTTP_REFERER', '/admin-panel/'))
        try:
            deleted, _ = model.objects.filter(pk__in=ids).delete()
            messages.success(request, f"Deleted {deleted} {model_name}(s).")
        except Exception as e:
            messages.error(request, f"Delete failed: {e}")
        return HttpResponseRedirect(request.META.get('HTTP_REFERER', '/admin-panel/'))


# ── Backwards-compat aliases ────────────────────────────────────────────
# Old code imported DashboardHomeView + ContentManagementView.
DashboardHomeView = DashboardIndexView


class ContentManagementView(_DashboardMixin, TemplateView):
    template_name = 'dashboard/content.html'

    def get_context_data(self, **kwargs):
        ctx = super().get_context_data(**kwargs)
        ctx['content_links'] = [
            ('Articles', 'dashboard:article_list', 'journal-text', 'primary'),
            ('Fatawa', 'dashboard:fatwa_list', 'patch-question', 'success'),
            ('Books', 'dashboard:book_list', 'book', 'warning'),
            ('Audio', 'dashboard:audio_list', 'mic', 'danger'),
            ('Videos', 'dashboard:video_list', 'film', 'info'),
            ('Podcasts', 'dashboard:podcast_list', 'broadcast', 'dark'),
            ('Reels', 'dashboard:reel_list', 'play-circle', 'primary'),
            ('Duas', 'dashboard:dua_list', 'hands-pray', 'info'),
            ('Dhikrs', 'dashboard:dhikr_list', 'gem', 'warning'),
            ('Hadiths', 'dashboard:hadith_list', 'book-half', 'danger'),
            ('Hadith Collections', 'dashboard:hadith_collection_list', 'collection', 'success'),
            ('Quran (Surahs)', 'dashboard:quran_list', 'book-fill', 'primary'),
            ('Mosques', 'dashboard:mosque_list', 'geo-alt', 'success'),
        ]
        return ctx
