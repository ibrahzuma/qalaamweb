import requests
from django.core.management.base import BaseCommand
from hadiths.models import HadithEdition, Hadith

class Command(BaseCommand):
    help = 'Imports Hadiths from the API'

    def add_arguments(self, parser):
        parser.add_argument('--edition', type=str, help='Edition key to import (e.g. eng-bukhari)')

    def handle(self, *args, **options):
        edition_key = options['edition']
        if not edition_key:
            self.stdout.write(self.style.ERROR('Please provide an edition key using --edition'))
            return

        base_url = "https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/"
        url = f"{base_url}editions/{edition_key}.json"
        
        self.stdout.write(f"Fetching {edition_key}...")
        response = requests.get(url)
        if response.status_code != 200:
            self.stdout.write(self.style.ERROR(f"Failed to fetch {edition_key}"))
            return

        data = response.json()
        metadata = data.get('metadata', {})
        
        edition, created = HadithEdition.objects.get_or_create(
            edition_key=edition_key,
            defaults={
                'name': metadata.get('name', edition_key),
                'language': edition_key.split('-')[0],
            }
        )

        hadiths_data = data.get('hadiths', [])
        self.stdout.write(f"Importing {len(hadiths_data)} hadiths...")
        
        hadith_objects = []
        for h_data in hadiths_data:
            hadith_objects.append(Hadith(
                edition=edition,
                hadith_number=h_data.get('hadithnumber'),
                arabic_number=h_data.get('arabic_number', ''),
                text=h_data.get('text', ''),
                grades=h_data.get('grades', []),
                section=metadata.get('section', {}).get(str(h_data.get('hadithnumber')), '') # Simplistic section mapping
            ))
            
            # Bulk create every 1000 to save memory
            if len(hadith_objects) >= 1000:
                Hadith.objects.bulk_create(hadith_objects)
                hadith_objects = []
        
        if hadith_objects:
            Hadith.objects.bulk_create(hadith_objects)

        self.stdout.write(self.style.SUCCESS(f"Successfully imported {edition_key}"))
