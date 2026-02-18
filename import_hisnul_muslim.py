import os
import django
import re
import json
from bs4 import BeautifulSoup

# Set up Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'islamweb_clone.settings')
django.setup()

from duas.models import Dua, DuaCategory
from django.utils.text import slugify

def clean_text(text):
    if not text:
        return ""
    # Remove excessive whitespace
    text = " ".join(text.split())
    # Basic cleaning for common encoding issues if any
    return text

def import_hisnul_muslim():
    file_path = 'hisnul_muslim_utf8.html'
    if not os.path.exists(file_path):
        print(f"Error: {file_path} not found.")
        return

    with open(file_path, 'r', encoding='utf-8') as f:
        html_content = f.read()

    soup = BeautifulSoup(html_content, 'html.parser')

    # 1. Extract Audio URLs
    audio_files = []
    audio_script_match = re.search(r'let hisnulMuslimAudioFiles = \[(.*?)\];', html_content, re.DOTALL)
    if audio_script_match:
        # Extract individual URLs from the bracketed list
        urls_raw = audio_script_match.group(1)
        audio_files = [url.strip().strip('"').strip("'") for url in urls_raw.split(',') if url.strip()]
    
    print(f"Found {len(audio_files)} audio files.")

    # 2. Extract Chapters (Categories)
    chapters = []
    chapter_divs = soup.find_all('div', class_='table-chapter-content')
    for div in chapter_divs:
        title_span = div.find('span', class_='chapter-title-table-contents')
        count_span = div.find('span', class_='dua-number-table-contents')
        if title_span and count_span:
            title = title_span.get_text().strip()
            count_text = count_span.get_text().strip()
            count_match = re.search(r'(\d+) Du\'as', count_text, re.IGNORECASE)
            dua_count = int(count_match.group(1)) if count_match else 0
            chapters.append({'title': title, 'count': dua_count})
    
    print(f"Parsed {len(chapters)} chapters.")

    # 3. Extract Duas
    dua_containers = soup.find_all('div', class_='dua-container')
    parsed_duas = []
    for container in dua_containers:
        dua_data = {}
        
        # Arabic Text
        arabic_div = container.find('div', class_='arabic-text')
        if arabic_div:
            # Join all spans
            spans = arabic_div.find_all('span', class_='aya-word')
            arabic_text = "".join([span.get_text().strip() for span in spans])
            # Note: strip() might remove spaces between words if not careful. 
            # Actually each word is in a span. So joining with space is better.
            arabic_text = " ".join([span.get_text().strip() for span in spans])
            dua_data['arabic_text'] = arabic_text
            
            # Audio Index
            audio_index = arabic_div.get('data-index')
            if audio_index is not None and int(audio_index) < len(audio_files):
                dua_data['audio_url'] = audio_files[int(audio_index)]
            else:
                dua_data['audio_url'] = None
        
        # Transliteration
        translit_div = container.find('div', class_='hisnul-transliteration')
        if translit_div:
            dua_data['transliteration'] = translit_div.get_text().strip()
        
        # Translation
        trans_div = container.find('div', class_='hisnul-translation')
        if trans_div:
            dua_data['translation'] = trans_div.get_text().strip()
            
        # Reference
        ref_div = container.find('div', class_='hisnul-reference')
        if ref_div:
            ref_text = ref_div.get_text().strip()
            ref_text = re.sub(r'^Reference:\s*', '', ref_text, flags=re.IGNORECASE)
            dua_data['reference'] = ref_text

        # Title
        if dua_data.get('translation'):
            title_text = dua_data['translation'].strip()
            dua_data['title'] = (title_text[:100] + '...') if len(title_text) > 100 else title_text
        
        if not dua_data.get('title') or not slugify(dua_data['title']):
            # Fallback title if translation is empty or not slugifiable
            dua_data['title'] = f"Dua {len(parsed_duas) + 1}"

        parsed_duas.append(dua_data)

    print(f"Extracted {len(parsed_duas)} duas.")

    # 4. Map Duas to Chapters and Save
    root_category, _ = DuaCategory.objects.get_or_create(name="Hisnul Muslim")
    
    dua_index = 0
    import_count = 0
    for chapter in chapters:
        cat_name = chapter['title']
        count = chapter['count']
        
        if count == 0:
            continue
            
        category, _ = DuaCategory.objects.get_or_create(name=cat_name, parent=root_category)
        
        for i in range(count):
            if dua_index >= len(parsed_duas):
                break
                
            data = parsed_duas[dua_index]
            
            title = data.get('title', f"Dua {dua_index + 1}")
            # Ensure title is not empty string
            if not title or not title.strip():
                title = f"Dua {dua_index + 1}"

            # We use get_or_create but we must be careful with the slug
            # If slug already exists, we might need to change it.
            slug_candidate = slugify(title)
            if not slug_candidate:
                slug_candidate = f"dua-{dua_index + 1}"

            # Check if slug exists
            if Dua.objects.filter(slug=slug_candidate).exclude(title=title, category=category).exists():
                # Append index
                slug_candidate = f"{slug_candidate}-{dua_index + 1}"

            dua, created = Dua.objects.get_or_create(
                slug=slug_candidate,
                defaults={
                    'title': title,
                    'category': category,
                    'arabic_text': data.get('arabic_text', ''),
                    'translation': data.get('translation', ''),
                    'transliteration': data.get('transliteration', ''),
                    'reference': data.get('reference', ''),
                    'audio_url': data.get('audio_url', ''),
                }
            )
            
            if not created:
                # Update audio_url if it was previously empty
                dua.audio_url = data.get('audio_url', '')
                dua.save()
            else:
                import_count += 1
            
            dua_index += 1
            
    print(f"Successfully imported {import_count} new duas.")

if __name__ == "__main__":
    import_hisnul_muslim()
