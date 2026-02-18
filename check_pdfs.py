import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'islamweb_clone.settings')
django.setup()

from django.conf import settings
from content.models import Book

def check_files():
    print(f"MEDIA_ROOT: {settings.MEDIA_ROOT}")
    pdf_dir = os.path.join(settings.MEDIA_ROOT, 'books', 'pdfs')
    print(f"Looking in: {pdf_dir}")
    
    if not os.path.exists(pdf_dir):
        print("ERROR: Directory does not exist!")
        return
        
    files = os.listdir(pdf_dir)
    print(f"Files found: {len(files)}")
    
    for f in files:
        full_path = os.path.join(pdf_dir, f)
        size = os.path.getsize(full_path)
        with open(full_path, 'rb') as fd:
            header = fd.read(10)
        print(f"File: {f} | Size: {size} | Header: {header}")

    print("\n--- Model Checks ---")
    for b in Book.objects.all():
        if b.pdf_file:
            print(f"Book: {b.title}")
            print(f"  Field: {b.pdf_file.name}")
            print(f"  Path: {b.pdf_file.path}")
            if os.path.exists(b.pdf_file.path):
                with open(b.pdf_file.path, 'rb') as fd:
                    header = fd.read(10)
                print(f"  Exists: True | Header: {header}")
            else:
                print("  Exists: False")

if __name__ == "__main__":
    check_files()
