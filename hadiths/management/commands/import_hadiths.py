import requests
from django.core.management.base import BaseCommand
from hadiths.models import HadithCollection, Hadith, HadithBook
from django.utils.text import slugify

class Command(BaseCommand):
    help = 'Imports Hadiths from the API and merges translations with Book/Section support'

    def add_arguments(self, parser):
        parser.add_argument('--collection', type=str, help='Collection slug (e.g. bukhari)')
        parser.add_argument('--edition', type=str, help='Edition key to import (e.g. ara-bukhari, eng-bukhari)')

    def handle(self, *args, **options):
        coll_slug = options['collection']
        edition_key = options['edition']

        if not coll_slug or not edition_key:
            self.stdout.write(self.style.ERROR('Please provide both --collection and --edition'))
            return

        lang_code = edition_key.split('-')[0]
        base_url = "https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/"
        url = f"{base_url}editions/{edition_key}.json"
        
        self.stdout.write(f"Fetching {edition_key}...")
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

        # Import Books/Sections
        sections_map = metadata.get('sections', {})
        books_cache = {}
        for b_num, b_name in sections_map.items():
            try:
                num = int(b_num)
                book, _ = HadithBook.objects.get_or_create(
                    collection=collection,
                    book_number=num,
                    defaults={'name': b_name}
                )
                if book.name != b_name and b_name: # Update name if needed
                    book.name = b_name
                    book.save()
                books_cache[num] = book
            except ValueError:
                continue

        # Prepare section details mapping for faster lookup
        # section_details: {"1": {"hadithnumber_first": 1, "hadithnumber_last": 7}}
        section_details = metadata.get('section_details', {})
        range_to_book = []
        for b_num, details in section_details.items():
            try:
                num = int(b_num)
                if num in books_cache:
                    start = int(details.get('hadithnumber_first', 0))
                    end = int(details.get('hadithnumber_last', 0))
                    range_to_book.append((start, end, books_cache[num]))
            except ValueError:
                continue

        hadiths_data = data.get('hadiths', [])
        self.stdout.write(f"Processing {len(hadiths_data)} hadiths...")
        
        count = 0
        for h_data in hadiths_data:
            h_number_str = str(h_data.get('hadithnumber'))
            try:
                h_number_int = int(float(h_number_str))
            except ValueError:
                h_number_int = 0

            text = h_data.get('text', '')
            
            hadith, created = Hadith.objects.get_or_create(
                collection=collection,
                hadith_number=h_number_str,
                defaults={
                    'arabic_number': h_data.get('arabic_number', ''),
                    'grades': h_data.get('grades', []),
                }
            )
            
            # Link to book
            if not hadith.book:
                for start, end, book in range_to_book:
                    if start <= h_number_int <= end:
                        hadith.book = book
                        break

            # Update language field
            if lang_code == 'ara':
                hadith.text_arabic = text
            elif lang_code == 'eng':
                hadith.text_english = text
            elif lang_code == 'swa':
                hadith.text_swahili = text
            
            hadith.save()
            count += 1
            if count % 500 == 0:
                self.stdout.write(f"Processed {count} hadiths...")

        self.stdout.write(self.style.SUCCESS(f"Successfully updated {coll_slug} ({lang_code}) with Books and Hadiths."))
