from django.db import models

class Mosque(models.Model):
    name = models.CharField(max_length=255)
    address = models.TextField()
    latitude = models.DecimalField(max_digits=9, decimal_places=6)
    longitude = models.DecimalField(max_digits=9, decimal_places=6)
    imam_name = models.CharField(max_length=200, blank=True)
    contact_number = models.CharField(max_length=20, blank=True)
    description = models.TextField(blank=True)
    image = models.ImageField(upload_to='mosques/', null=True, blank=True)
    is_verified = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name

class PrayerTime(models.Model):
    mosque = models.ForeignKey(Mosque, on_delete=models.CASCADE, related_name='prayer_times')
    date = models.DateField()
    fajr = models.TimeField()
    dhuhr = models.TimeField()
    asr = models.TimeField()
    maghrib = models.TimeField()
    isha = models.TimeField()
    jummah = models.TimeField(null=True, blank=True)

    class Meta:
        unique_together = ('mosque', 'date')

    def __str__(self):
        return f"{self.mosque.name} - {self.date}"
