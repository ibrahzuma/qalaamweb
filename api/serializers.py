from core.models import User
from rest_framework import serializers
from fatwa.models import Fatwa, FatwaCategory
from articles.models import Article, ArticleCategory
from hadiths.models import Hadith, HadithBook, HadithCollection
from content.models import ContentCategory, Audio, Book, Video, Podcast, PodcastEpisode, QuranSurah, Reel, Ayah, VideoSeries, Clip
from duas.models import Dua, DuaCategory, Dhikr
from services.models import Mosque, PrayerTime

class AyahSerializer(serializers.ModelSerializer):
    class Meta:
        model = Ayah
        fields = ('id', 'text', 'translation', 'reference', 'is_daily')

class UserSerializer(serializers.ModelSerializer):
    name = serializers.ReadOnlyField(source='first_name')
    class Meta:
        model = User
        fields = ('id', 'username', 'email', 'name')

class RegisterSerializer(serializers.ModelSerializer):
    name = serializers.CharField(write_only=True)
    email = serializers.EmailField(required=True)

    class Meta:
        model = User
        fields = ('id', 'name', 'email', 'password')
        extra_kwargs = {
            'password': {'write_only': True},
        }

    def validate_email(self, value):
        if User.objects.filter(username=value).exists() or User.objects.filter(email=value).exists():
            raise serializers.ValidationError("A user with this email already exists.")
        return value

    def create(self, validated_data):
        name = validated_data.pop('name')
        email = validated_data['email']
        # Use email as username for uniqueness
        user = User.objects.create_user(
            username=email,
            email=email,
            password=validated_data['password'],
            first_name=name
        )
        return user

# Categories
class FatwaCategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = FatwaCategory
        fields = '__all__'

class ArticleCategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = ArticleCategory
        fields = '__all__'

class ContentCategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = ContentCategory
        fields = '__all__'

class DuaCategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = DuaCategory
        fields = '__all__'

# Core Content
class FatwaSerializer(serializers.ModelSerializer):
    category_name = serializers.ReadOnlyField(source='category.name')
    class Meta:
        model = Fatwa
        fields = '__all__'

class ArticleSerializer(serializers.ModelSerializer):
    category_name = serializers.ReadOnlyField(source='category.name')
    class Meta:
        model = Article
        fields = '__all__'

# Hadiths
class HadithCollectionSerializer(serializers.ModelSerializer):
    class Meta:
        model = HadithCollection
        fields = '__all__'

class HadithBookSerializer(serializers.ModelSerializer):
    class Meta:
        model = HadithBook
        fields = '__all__'

class HadithSerializer(serializers.ModelSerializer):
    collection_name = serializers.ReadOnlyField(source='collection.name')
    book_name = serializers.ReadOnlyField(source='book.name')
    text = serializers.SerializerMethodField()
    reference = serializers.SerializerMethodField()
    narrator = serializers.SerializerMethodField()
    category = serializers.SerializerMethodField()

    class Meta:
        model = Hadith
        fields = '__all__'

    def get_text(self, obj):
        return obj.text_english or obj.text_arabic or obj.text_swahili or ''

    def get_reference(self, obj):
        collection_name = obj.collection.name if obj.collection_id else ''
        if collection_name and obj.hadith_number:
            return f"{collection_name} {obj.hadith_number}"
        return collection_name or obj.hadith_number or ''

    def get_narrator(self, obj):
        grades = obj.grades or []
        if isinstance(grades, list):
            for entry in grades:
                if isinstance(entry, dict):
                    narrator = entry.get('narrator') or entry.get('grader')
                    if narrator:
                        return str(narrator)
        return ''

    def get_category(self, obj):
        if obj.book_id and obj.book and obj.book.name:
            return obj.book.name
        if obj.collection_id and obj.collection:
            return obj.collection.name
        return 'General'

# Multimedia & Quran
class AudioSerializer(serializers.ModelSerializer):
    class Meta:
        model = Audio
        fields = '__all__'

class BookSerializer(serializers.ModelSerializer):
    class Meta:
        model = Book
        fields = '__all__'

class VideoSerializer(serializers.ModelSerializer):
    class Meta:
        model = Video
        fields = '__all__'

class ReelSerializer(serializers.ModelSerializer):
    class Meta:
        model = Reel
        fields = '__all__'

class PodcastSerializer(serializers.ModelSerializer):
    class Meta:
        model = Podcast
        fields = '__all__'

class PodcastEpisodeSerializer(serializers.ModelSerializer):
    class Meta:
        model = PodcastEpisode
        fields = '__all__'

class QuranSurahSerializer(serializers.ModelSerializer):
    number = serializers.IntegerField(source='surah_number')
    name = serializers.CharField(source='surah_name')
    english_name = serializers.CharField(source='surah_name')
    english_name_translation = serializers.CharField(default='The Opening') # Placeholder
    number_of_ayahs = serializers.SerializerMethodField()
    revelation_type = serializers.CharField(default='MECCAN')

    class Meta:
        model = QuranSurah
        fields = ['id', 'number', 'name', 'english_name', 'english_name_translation', 'number_of_ayahs', 'revelation_type']

    def get_number_of_ayahs(self, obj):
        return obj.ayahs.count()

class AyahSerializer(serializers.ModelSerializer):
    class Meta:
        model = Ayah
        fields = ['id', 'surah_number', 'ayah_number', 'text', 'translation', 'reference']

class DuaSerializer(serializers.ModelSerializer):
    category_name = serializers.ReadOnlyField(source='category.name')
    class Meta:
        model = Dua
        fields = '__all__'

class MosqueSerializer(serializers.ModelSerializer):
    image_url = serializers.SerializerMethodField()
    prayer_times = serializers.SerializerMethodField()
    distance = serializers.SerializerMethodField()

    class Meta:
        model = Mosque
        fields = (
            'id', 'name', 'address', 'latitude', 'longitude',
            'imam_name', 'contact_number', 'description',
            'is_verified', 'created_at',
            'image_url', 'prayer_times', 'distance',
        )

    def get_image_url(self, obj):
        if not obj.image:
            return ''
        request = self.context.get('request')
        url = obj.image.url
        return request.build_absolute_uri(url) if request else url

    def get_prayer_times(self, obj):
        from datetime import date as _date
        record = obj.prayer_times.filter(date=_date.today()).first()
        if not record:
            return {}
        def fmt(t):
            return t.strftime('%H:%M') if t else ''
        return {
            'fajr': fmt(record.fajr),
            'dhuhr': fmt(record.dhuhr),
            'asr': fmt(record.asr),
            'maghrib': fmt(record.maghrib),
            'isha': fmt(record.isha),
        }

    def get_distance(self, obj):
        lat = self.context.get('lat')
        lng = self.context.get('lng')
        if lat is None or lng is None:
            return 0.0
        from .geo import haversine_km
        return round(haversine_km(lat, lng, float(obj.latitude), float(obj.longitude)), 2)

class PrayerTimeSerializer(serializers.ModelSerializer):
    class Meta:
        model = PrayerTime
        fields = '__all__'

class VideoSeriesSerializer(serializers.ModelSerializer):
    class Meta:
        model = VideoSeries
        fields = '__all__'

class ClipSerializer(serializers.ModelSerializer):
    class Meta:
        model = Clip
        fields = '__all__'

class DhikrSerializer(serializers.ModelSerializer):
    class Meta:
        model = Dhikr
        fields = '__all__'
