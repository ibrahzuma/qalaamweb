from django.db.models import Q
from rest_framework import viewsets, response, generics, permissions, status
from rest_framework.views import APIView
from rest_framework.authtoken.models import Token
from rest_framework.decorators import action
# No top-level serializer imports to avoid circular issues
from rest_framework import exceptions
from django.conf import settings
from core.models import User

# No top-level authentication classes to avoid circular issues

from fatwa.models import Fatwa, FatwaCategory
from articles.models import Article, ArticleCategory
from hadiths.models import Hadith, HadithBook, HadithCollection
from content.models import ContentCategory, Audio, Book, Video, Podcast, PodcastEpisode, QuranSurah, Reel, Ayah, VideoSeries, Clip
from duas.models import Dua, DuaCategory, Dhikr
from services.models import Mosque, PrayerTime

class FatwaCategoryViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = FatwaCategory.objects.all()
    def get_serializer_class(self):
        from .serializers import FatwaCategorySerializer
        return FatwaCategorySerializer

class FatwaViewSet(viewsets.ModelViewSet):
    queryset = Fatwa.objects.filter(status='answered')
    def get_serializer_class(self):
        from .serializers import FatwaSerializer
        return FatwaSerializer
    permission_classes = [permissions.AllowAny]

    def get_queryset(self):
        queryset = Fatwa.objects.all()
        status = self.request.query_params.get('status')
        if status:
            queryset = queryset.filter(status=status)
        else:
            # Default to answered for GET requests if no status provided
            if self.action == 'list':
                queryset = queryset.filter(status='answered')
        
        category = self.request.query_params.get('category')
        if category:
            queryset = queryset.filter(category_id=category)
            
        search = self.request.query_params.get('search')
        if search:
            queryset = queryset.filter(title__icontains=search) | queryset.filter(question__icontains=search)
            
        return queryset

class ArticleCategoryViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = ArticleCategory.objects.all()
    def get_serializer_class(self):
        from .serializers import ArticleCategorySerializer
        return ArticleCategorySerializer

class ArticleViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Article.objects.all()
    def get_serializer_class(self):
        from .serializers import ArticleSerializer
        return ArticleSerializer
    permission_classes = [permissions.AllowAny]

class HadithCollectionViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = HadithCollection.objects.all()
    def get_serializer_class(self):
        from .serializers import HadithCollectionSerializer
        return HadithCollectionSerializer
    lookup_field = 'slug'

class HadithBookViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = HadithBook.objects.all()
    def get_serializer_class(self):
        from .serializers import HadithBookSerializer
        return HadithBookSerializer

    def get_queryset(self):
        queryset = HadithBook.objects.all()
        collection_slug = self.request.query_params.get('collection')
        if collection_slug:
            queryset = queryset.filter(collection__slug=collection_slug)
        return queryset.order_by('book_number')

class HadithViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Hadith.objects.all()
    def get_serializer_class(self):
        from .serializers import HadithSerializer
        return HadithSerializer
    permission_classes = [permissions.AllowAny]

    def get_queryset(self):
        queryset = Hadith.objects.all()
        collection_slug = self.request.query_params.get('collection')
        book_number = self.request.query_params.get('book')
        search = self.request.query_params.get('search')

        if collection_slug:
            queryset = queryset.filter(collection__slug=collection_slug)
        if book_number:
            queryset = queryset.filter(book__book_number=book_number)
        if search:
            queryset = queryset.filter(
                Q(text_english__icontains=search) |
                Q(text_arabic__icontains=search) |
                Q(hadith_number__icontains=search)
            )

        return queryset.order_by('id')

    def list(self, request, *args, **kwargs):
        # Hadith collections are huge (Bukhari = 7,500+). Default to a sane
        # page size to avoid 13 MB responses + mobile timeouts. Clients can
        # paginate via ?offset= and ?limit=.
        try:
            limit = int(request.query_params.get('limit') or 100)
            offset = int(request.query_params.get('offset') or 0)
        except (TypeError, ValueError):
            limit, offset = 100, 0
        limit = max(1, min(limit, 500))
        offset = max(0, offset)

        qs = self.filter_queryset(self.get_queryset())
        total = qs.count()
        page = qs[offset:offset + limit]
        serializer = self.get_serializer(page, many=True)
        # Keep response shape backwards-compat: still a list, but expose
        # totals via headers for clients that want to paginate.
        from django.http import HttpResponse
        resp = response.Response(serializer.data)
        resp['X-Total-Count'] = str(total)
        resp['X-Offset'] = str(offset)
        resp['X-Limit'] = str(limit)
        return resp

    @action(detail=False, methods=['get'])
    def daily(self, request):
        import random
        count = self.get_queryset().count()
        if count == 0:
            return response.Response({"detail": "No hadiths found"}, status=404)
        
        # Simple random for "Hadith of the Day"
        # In production, this could be cached for the day
        random_index = random.randint(0, count - 1)
        hadith = self.get_queryset()[random_index]
        serializer = self.get_serializer(hadith)
        return response.Response(serializer.data)

class ContentCategoryViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = ContentCategory.objects.all()
    def get_serializer_class(self):
        from .serializers import ContentCategorySerializer
        return ContentCategorySerializer
    permission_classes = [permissions.AllowAny]

class AudioViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Audio.objects.all()
    def get_serializer_class(self):
        from .serializers import AudioSerializer
        return AudioSerializer
    permission_classes = [permissions.AllowAny]

    def get_queryset(self):
        queryset = Audio.objects.all()
        category_id = self.request.query_params.get('category')
        if category_id:
            queryset = queryset.filter(category_id=category_id)
        return queryset

    @action(detail=False, methods=['get'])
    def related(self, request):
        queryset = self.get_queryset().order_by('-created_at')[:20]
        serializer = self.get_serializer(queryset, many=True)
        return response.Response(serializer.data)

class BookViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Book.objects.all()
    def get_serializer_class(self):
        from .serializers import BookSerializer
        return BookSerializer
    permission_classes = [permissions.AllowAny]

class VideoViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Video.objects.all()
    def get_serializer_class(self):
        from .serializers import VideoSerializer
        return VideoSerializer
    permission_classes = [permissions.AllowAny]

    def get_queryset(self):
        queryset = Video.objects.all()
        category_id = self.request.query_params.get('category')
        if category_id:
            queryset = queryset.filter(category_id=category_id)
        return queryset

    @action(detail=False, methods=['get'])
    def trending(self, request):
        # In a real app, this would be based on views/likes
        queryset = self.get_queryset().order_by('-created_at')[:10]
        serializer = self.get_serializer(queryset, many=True)
        return response.Response(serializer.data)

    @action(detail=False, methods=['get'], url_path='continue-watching')
    def continue_watching(self, request):
        # In a real app, this would track user progress
        queryset = self.get_queryset()[:5]
        serializer = self.get_serializer(queryset, many=True)
        return response.Response(serializer.data)

class ReelViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Reel.objects.all()
    def get_serializer_class(self):
        from .serializers import ReelSerializer
        return ReelSerializer
    permission_classes = [permissions.AllowAny]

    def get_queryset(self):
        queryset = Reel.objects.all()
        category_id = self.request.query_params.get('category')
        if category_id:
            queryset = queryset.filter(category_id=category_id)
        return queryset

class PodcastViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Podcast.objects.all()
    def get_serializer_class(self):
        from .serializers import PodcastSerializer
        return PodcastSerializer
    permission_classes = [permissions.AllowAny]

class PodcastEpisodeViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = PodcastEpisode.objects.all()
    def get_serializer_class(self):
        from .serializers import PodcastEpisodeSerializer
        return PodcastEpisodeSerializer
    permission_classes = [permissions.AllowAny]

class QuranSurahViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = QuranSurah.objects.all()
    def get_serializer_class(self):
        from .serializers import QuranSurahSerializer
        return QuranSurahSerializer
    permission_classes = [permissions.AllowAny]

    @action(detail=True, methods=['get'])
    def ayahs(self, request, pk=None):
        surah = self.get_object()
        ayahs = Ayah.objects.filter(surah_number=surah.surah_number).order_by('ayah_number')
        from .serializers import AyahSerializer
        serializer = AyahSerializer(ayahs, many=True)
        return response.Response(serializer.data)

class AyahViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Ayah.objects.all()
    def get_serializer_class(self):
        from .serializers import AyahSerializer
        return AyahSerializer
    permission_classes = [permissions.AllowAny]

    @action(detail=False, methods=['get'])
    def daily(self, request):
        import random
        # Try to get the one marked as is_daily first
        ayah = Ayah.objects.filter(is_daily=True).first()
        if not ayah:
            count = Ayah.objects.count()
            if count == 0:
                return response.Response({"detail": "No ayahs found"}, status=404)
            random_index = random.randint(0, count - 1)
            ayah = Ayah.objects.all()[random_index]
        
        serializer = self.get_serializer(ayah)
        return response.Response(serializer.data)

class DuaCategoryViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = DuaCategory.objects.all()
    def get_serializer_class(self):
        from .serializers import DuaCategorySerializer
        return DuaCategorySerializer

class DuaViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Dua.objects.all()
    def get_serializer_class(self):
        from .serializers import DuaSerializer
        return DuaSerializer
    permission_classes = [permissions.AllowAny]

    def get_queryset(self):
        queryset = Dua.objects.all()
        category_id = self.request.query_params.get('category')
        if category_id:
            queryset = queryset.filter(category_id=category_id)
        
        search = self.request.query_params.get('search')
        if search:
            queryset = queryset.filter(
                Q(title__icontains=search) | 
                Q(translation__icontains=search) | 
                Q(arabic_text__icontains=search)
            )
        return queryset

    @action(detail=False, methods=['get'])
    def daily(self, request):
        import random
        count = self.get_queryset().count()
        if count == 0:
            return response.Response({"detail": "No duas found"}, status=404)
        
        random_index = random.randint(0, count - 1)
        dua = self.get_queryset()[random_index]
        serializer = self.get_serializer(dua)
        return response.Response(serializer.data)

class LoginAPIView(APIView):
    permission_classes = (permissions.AllowAny,)

    def post(self, request):
        email = request.data.get('email')
        password = request.data.get('password')
        
        if not email or not password:
            return response.Response({"detail": "Please provide both email and password."}, status=status.HTTP_400_BAD_REQUEST)
        
        # In this project, email is the username
        from django.contrib.auth import authenticate
        user = authenticate(username=email, password=password)
        
        if not user:
            return response.Response({"detail": "Invalid credentials."}, status=status.HTTP_401_UNAUTHORIZED)
            
        token, created = Token.objects.get_or_create(user=user)
        from .serializers import UserSerializer
        return response.Response({
            "user": UserSerializer(user).data,
            "token": token.key
        })

class RegisterAPIView(generics.CreateAPIView):
    queryset = User.objects.all()
    permission_classes = (permissions.AllowAny,)
    def get_serializer_class(self):
        from .serializers import RegisterSerializer
        return RegisterSerializer

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        token, created = Token.objects.get_or_create(user=user)
        from .serializers import UserSerializer
        return response.Response({
            "user": UserSerializer(user).data,
            "token": token.key
        })

class UserAPIView(generics.RetrieveUpdateAPIView):
    permission_classes = [permissions.IsAuthenticated]
    def get_serializer_class(self):
        from .serializers import UserSerializer
        return UserSerializer

    def get_object(self):
        return self.request.user

class LogoutAPIView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        # Simply delete the token to force logout
        request.user.auth_token.delete()
        return response.Response({"detail": "Successfully logged out."}, status=200)

class MosqueViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Mosque.objects.all()
    def get_serializer_class(self):
        from .serializers import MosqueSerializer
        return MosqueSerializer
    permission_classes = [permissions.AllowAny]

    def _float_param(self, key):
        raw = self.request.query_params.get(key)
        try:
            return float(raw) if raw is not None else None
        except (TypeError, ValueError):
            return None

    def get_serializer_context(self):
        ctx = super().get_serializer_context()
        ctx['lat'] = self._float_param('lat')
        ctx['lng'] = self._float_param('lng')
        return ctx

    def list(self, request, *args, **kwargs):
        lat = self._float_param('lat')
        lng = self._float_param('lng')
        queryset = self.filter_queryset(self.get_queryset())
        if lat is not None and lng is not None:
            from .geo import haversine_km
            queryset = sorted(
                queryset,
                key=lambda m: haversine_km(lat, lng, float(m.latitude), float(m.longitude)),
            )
        serializer = self.get_serializer(queryset, many=True)
        return response.Response(serializer.data)

class PrayerTimeAPIView(APIView):
    permission_classes = [permissions.AllowAny]

    def get(self, request):
        from datetime import date as _date
        lat = request.query_params.get('lat')
        lng = request.query_params.get('lng')
        today = _date.today()

        try:
            lat_f = float(lat) if lat is not None else None
            lng_f = float(lng) if lng is not None else None
        except (TypeError, ValueError):
            lat_f = lng_f = None

        # 1) Prefer admin-curated PrayerTime entry from the nearest mosque for today.
        record = None
        if lat_f is not None and lng_f is not None:
            from .geo import haversine_km
            mosques = list(Mosque.objects.all())
            mosques.sort(key=lambda m: haversine_km(lat_f, lng_f, float(m.latitude), float(m.longitude)))
            for mosque in mosques[:5]:  # only the 5 nearest
                record = PrayerTime.objects.filter(mosque=mosque, date=today).first()
                if record:
                    break
        if record is None:
            record = PrayerTime.objects.filter(date=today).first()

        def fmt(t):
            return t.strftime('%H:%M') if t else '--:--'

        if record is not None:
            return response.Response({
                'fajr': fmt(record.fajr),
                'dhuhr': fmt(record.dhuhr),
                'asr': fmt(record.asr),
                'maghrib': fmt(record.maghrib),
                'isha': fmt(record.isha),
                'date': today.isoformat(),
                'source': 'mosque',
                'mosque': record.mosque.name if record.mosque_id else None,
            })

        # 2) No DB record — calculate via aladhan.com (free, no API key).
        if lat_f is not None and lng_f is not None:
            try:
                import urllib.request
                import json as _json
                url = (
                    f'https://api.aladhan.com/v1/timings/'
                    f'{today.strftime("%d-%m-%Y")}'
                    f'?latitude={lat_f}&longitude={lng_f}&method=2'
                )
                req = urllib.request.Request(url, headers={'User-Agent': 'qalaam-server/1.0'})
                with urllib.request.urlopen(req, timeout=8) as r:
                    data = _json.loads(r.read())
                t = data.get('data', {}).get('timings', {})
                if t:
                    def short(v):
                        if not v:
                            return '--:--'
                        return v.split(' ')[0]  # strip " (EAT)" etc.
                    return response.Response({
                        'fajr': short(t.get('Fajr')),
                        'dhuhr': short(t.get('Dhuhr')),
                        'asr': short(t.get('Asr')),
                        'maghrib': short(t.get('Maghrib')),
                        'isha': short(t.get('Isha')),
                        'date': today.isoformat(),
                        'source': 'calculated',
                        'method': 'ISNA (method=2)',
                    })
            except Exception as exc:
                # Fall through to placeholder.
                import logging
                logging.getLogger(__name__).warning(f'aladhan fetch failed: {exc}')

        # 3) Final fallback — placeholder.
        return response.Response({
            'fajr': '--:--', 'dhuhr': '--:--', 'asr': '--:--',
            'maghrib': '--:--', 'isha': '--:--',
            'date': today.isoformat(),
            'source': 'unavailable',
        })

class VideoSeriesViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = VideoSeries.objects.all()
    def get_serializer_class(self):
        from .serializers import VideoSeriesSerializer
        return VideoSeriesSerializer
    permission_classes = [permissions.AllowAny]

    @action(detail=False, methods=['get'])
    def educational(self, request):
        queryset = self.get_queryset().order_by('-created_at')
        serializer = self.get_serializer(queryset, many=True)
        return response.Response(serializer.data)

class ClipViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Clip.objects.all()
    def get_serializer_class(self):
        from .serializers import ClipSerializer
        return ClipSerializer
    permission_classes = [permissions.AllowAny]

class DhikrViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Dhikr.objects.all()
    def get_serializer_class(self):
        from .serializers import DhikrSerializer
        return DhikrSerializer
    permission_classes = [permissions.AllowAny]
