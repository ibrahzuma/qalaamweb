import requests

def find_swahili():
    url = "https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions.json"
    response = requests.get(url)
    if response.status_code == 200:
        data = response.json()
        sw_editions = {k: v for k, v in data.items() if 'swa' in k or 'Swahili' in str(v)}
        print("Swahili Editions found:")
        for k, v in sw_editions.items():
            print(f"{k}: {v}")
    else:
        print("Failed to fetch editions.json")

if __name__ == "__main__":
    find_swahili()
