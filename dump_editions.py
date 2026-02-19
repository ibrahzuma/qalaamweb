import requests
import json

def dump_editions():
    url = "https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions.json"
    response = requests.get(url)
    if response.status_code == 200:
        data = response.json()
        # Just print keys to see the format
        keys = list(data.keys())
        print(f"Total editions: {len(keys)}")
        print("First 50 keys:")
        print(keys[:50])
        
        # Search for any key containing 'sw' or 'th' (just in case)
        sw_keys = [k for k in keys if 'sw' in k.lower()]
        print(f"Keys with 'sw': {sw_keys}")
    else:
        print("Failed")

if __name__ == "__main__":
    dump_editions()
