import os
import django
import requests
from django.utils.text import slugify

# Set up Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'islamweb_clone.settings')
django.setup()

from content.models import ContentCategory, Book
from django.core.files import File
from django.core.files.temp import NamedTemporaryFile

import subprocess

def download_file(url, filename, retries=3):
    print(f"Downloading {filename} from {url}...")
    
    for i in range(retries):
        try:
            # Use curl directly which is more robust
            temp_file_path = os.path.join(os.environ.get('TEMP', ''), f"temp_{filename}")
            result = subprocess.run([
                'curl.exe', '-L', '-A', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
                '-o', temp_file_path, url
            ], capture_output=True)
            
            if result.returncode == 0 and os.path.getsize(temp_file_path) > 1000: # Ensure it's not a tiny error page
                print(f"Success: {filename}")
                return temp_file_path
            else:
                print(f"Curl failed for {url}. Attempt {i+1}...")
        except Exception as e:
            print(f"Error downloading with curl: {e}")
            
    return None

def create_categories():
    categories_data = [
        {'name': 'Aqeedah', 'slug': 'aqeedah', 'icon': 'bi-shield-check'},
        {'name': 'Fiqh', 'slug': 'fiqh', 'icon': 'bi-journal-text'},
        {'name': 'Seerah', 'slug': 'seerah', 'icon': 'bi-person-badge'},
    ]
    
    cats = {}
    for cat_data in categories_data:
        cat, created = ContentCategory.objects.get_or_create(
            slug=cat_data['slug'],
            defaults={'name': cat_data['name'], 'icon': cat_data['icon']}
        )
        cats[cat_data['slug']] = cat
        if created:
            print(f"Created category: {cat.name}")
    return cats

def import_books():
    cats = create_categories()
    
    books_data = [
        # Aqeedah
        {
            'title': 'Minhaj Al-Muslim (The Way of a Muslim)',
            'author': 'Abu Bakr Jabir Al-Jazairy',
            'category': cats['aqeedah'],
            'url': 'https://emaanlibrary.com/wp-content/uploads/2016/06/Minhaj-Al-Muslim-Vol-1.pdf',
            'description': 'A comprehensive guide encompasses everything of importance to a Muslim in terms of creed, personal conduct, moral integrity, worship, and interactions.'
        },
        {
            'title': 'Basic Tenets Of Faith',
            'author': 'Imaam Muhammad ibn Abd al-Wahhaab',
            'category': cats['aqeedah'],
            'url': 'https://www.muslim-library.com/dl/books/English_THE_THREE_FUNDAMENTAL_PRINCIPLES.pdf',
            'description': 'This foundational text elucidates prophethood, religion, and monotheism, crucial for understanding the Islamic creed correctly.'
        },
        {
            'title': 'The Book of Tawheed (Oneness of God)',
            'author': 'Sheikh Muhammad ibn Abd al Wahhab',
            'category': cats['aqeedah'],
            'url': 'https://www.worldofislam.info/books/kitab-at-tawhid.pdf',
            'description': 'Significant text outlining the creed of Ahl al-Sunnah wa al-Jama’ah with evidence from the Quran and the Sunnah.'
        },
        # Fiqh
        {
            'title': 'Al-Fiqh Al-Mouyassar',
            'author': 'King Fahd Complex',
            'category': cats['fiqh'],
            'url': 'https://archive.org/download/SimpleFiqhPart1ByShaykhDr.AbdullahAt-tayyar/SimpleFiqhPart1ByShaykhDr.AbdullahAt-tayyar.pdf',
            'description': 'A simple and clear explanation of Islamic jurisprudence based on the Quran and Sunnah.'
        },
        {
            'title': 'Fiqh al-Ibadat',
            'author': 'Ibn Uthaymin',
            'category': cats['fiqh'],
            'url': 'http://abdurrahman.org/wp-content/uploads/2014/10/Fiqh-of-Worship-Sh.-al-Uthaymeen.pdf',
            'description': 'Rulings on worship including purification, prayer, fasting, zakat, and hajj by Sheikh Ibn Uthaymin.'
        },
        # Seerah
        {
            'title': 'The Sealed Nectar (Ar-Raheeq Al-Makhtum)',
            'author': 'Safi-ur-Rahman al-Mubarkpuri',
            'category': cats['seerah'],
            'url': 'https://www.missionislam.com/knowledge/books/Ar-Raheeq_Al-Makhtum.pdf',
            'description': 'Award-winning biography of Prophet Muhammad (PBUH), providing a detailed and authentic account of his life.'
        },
        {
            'title': 'Zaad al-Ma’aad',
            'author': 'Ibn al-Qayyim',
            'category': cats['seerah'],
            'url': 'https://archive.org/download/ZaadAlMaaadByIbnAlQayyim/Zaad%20al-Ma%27aad%20-%20Vol%201.pdf',
            'description': 'An immense work dealing with the biography of the Prophet (PBUH) and the guidance derived from it for every aspect of life.'
        },
        {
            'title': 'Siyar A’laam al-Nubalaa’',
            'author': 'al-Dhahabi',
            'category': cats['seerah'],
            'url': 'https://ia801602.us.archive.org/29/items/biographies-of-noble-scholars-dhahabi/Biographies%20of%20Noble%20Scholars%20-%20Al-Dhahabi.pdf',
            'description': 'A biographical encyclopedia of notable figures in Islamic history, providing lessons from their lives and characters.'
        },
        {
            'title': 'Ash-Shama-il Al-Mohammadiyah',
            'author': 'Imam At-Tirmidhi',
            'category': cats['seerah'],
            'url': 'https://ia801007.us.archive.org/4/items/ShamaileTirmizi/Shama-il-Tirmidhi.pdf',
            'description': 'A collection of hadiths describing the physical appearance, characteristics, and lifestyle of the Prophet Muhammad (PBUH).'
        }
    ]
    
    for book_data in books_data:
        book = Book.objects.filter(title=book_data['title']).first()
        
        # Always re-download to fix corrupted files
        print(f"Processing: {book_data['title']}...")
            
        if not book:
            book = Book(
                title=book_data['title'],
                author=book_data['author'],
                category=book_data['category'],
                description=book_data['description']
            )
            print(f"Creating record for: {book_data['title']}")

        temp_pdf_path = download_file(book_data['url'], f"{slugify(book_data['title'])}.pdf")
        
        if temp_pdf_path and os.path.exists(temp_pdf_path):
            with open(temp_pdf_path, 'rb') as f:
                # This will automatically replace the old file and handle naming
                book.pdf_file.save(f"{slugify(book_data['title'])}.pdf", File(f))
            book.save()
            os.remove(temp_pdf_path)
            print(f"Successfully updated: {book.title}")
        else:
            print(f"Failed to fetch PDF for: {book_data['title']}")

if __name__ == "__main__":
    import_books()
