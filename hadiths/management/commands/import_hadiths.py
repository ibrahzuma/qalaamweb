import requests
from django.core.management.base import BaseCommand
from hadiths.models import HadithCollection, Hadith
from django.utils.text import slugify

class Command(BaseCommand):
    help = 'Imports Hadiths from the API and merges translations'

    def add_arguments(self, parser):
        parser.add_argument('--collection', type=str, help='Collection slug (e.g. bukhari)')
        parser.add_argument('--edition', type=str, help='Edition key to import (e.g. ara-bukhari, eng-bukhari)')

    def handle(self, *args, **options):
        coll_slug = options['collection']
        edition_key = options['edition']

        if not coll_slug or not edition_key:
            self.stdout.write(self.style.ERROR('Please provide both --collection and --edition'))
            return

        # Determine language from edition key
        lang_code = edition_key.split('-')[0] # 'ara', 'eng', 'swa'
        
        base_url = "https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/"
        url = f"{base_url}editions/{edition_key}.json"
        
        self.stdout.write(f"Fetching {edition_key} for collection {coll_slug}...")
        response = requests.get(url)
        if response.status_code != 200:
            self.stdout.write(self.style.ERROR(f"Failed to fetch {edition_key}"))
            return

        data = response.json()
        metadata = data.get('metadata', {})
        
        collection, _ = HadithCollection.objects.get_or_create(
            slug=coll_slug,
            defaults={'name': metadata.get('name', coll_slug.title())}
        )

        hadiths_data = data.get('hadiths', [])
        self.stdout.write(f"Processing {len(hadiths_data)} hadiths for language: {lang_code}...")
        
        count = 0
        for h_data in hadiths_data:
            h_number = str(h_data.get('hadithnumber'))
            text = h_data.get('text', '')
            
            hadith, created = Hadith.objects.get_or_create(
                collection=collection,
                hadith_number=h_number,
                defaults={
                    'arabic_number': h_data.get('arabic_number', ''),
                    'grades': h_data.get('grades', []),
                }
            )
            
            # Update the specific language field
            if lang_code == 'ara':
                hadith.text_arabic = text
            elif lang_code == 'eng':
                hadith.text_english = text
            elif lang_code == 'swa':
                hadith.text_swahili = text
            
            # Update metadata if not already set
            if not hadith.section:
                hadith.section = metadata.get('section', {}).get(h_number, '')
            
            hadith.save()
            count += 1
            if count % 500 == 0:
                self.stdout.write(f"Processed {count} hadiths...")

        self.stdout.write(self.style.SUCCESS(f"Successfully updated {coll_slug} with {lang_code} translation."))
