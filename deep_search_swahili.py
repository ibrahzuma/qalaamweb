import requests
import json

def deep_search():
    url = "https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions.json"
    response = requests.get(url)
    if response.status_code == 200:
        data = response.json()
        raw_text = json.dumps(data)
        if "swa" in raw_text.lower() or "swahili" in raw_text.lower():
            print("Swahili found in editions.json!")
            # Find which keys contain it
            for k, v in data.items():
                if "swa" in str(v).lower() or "swahili" in str(v).lower():
                    print(f"Key: {k}, Value: {v}")
        else:
            print("Swahili NOT found in editions.json.")
            # Print a few to see the structure
            print("Structure example:")
            first_key = list(data.keys())[0]
            print(f"{first_key}: {data[first_key]}")
    else:
        print("Failed")

if __name__ == "__main__":
    deep_search()
