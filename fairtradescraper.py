import requests
from bs4 import BeautifulSoup
import csv
import time

BASE_URL = "https://www.flocert.net/fairtrade-customer-search/"

def get_page(page_num):
    """
    Retrieves a page of results with the "Certified" filter applied.
    Adjust the parameters as required by the site's request format.
    """
    params = {
        "status": "Certified",
        # "page": page_num  # Adjust if the site uses a different parameter for pagination.
    }
    response = requests.get(BASE_URL, params=params)
    response.raise_for_status()
    return response.text

def parse_names(html):
    """
    Parses the HTML content to extract organization names.
    Instead of searching all <strong> tags, we first narrow the search to each 
    organization container (assumed here as <div class="customer">) and then look for 
    a <strong class="customer__name"> within that container.
    """
    soup = BeautifulSoup(html, 'html.parser')
    names = []
    
    # Adjust this container selector based on the actual HTML structure.
    # For example, if each organization is inside a div with class "customer", use:
    customer_containers = soup.find_all("div", class_="customer-search-results__customer cf")
    
    for container in customer_containers:
        name_tag = container.find("strong", class_="customer__name")
        if name_tag:
            name = name_tag.get_text(strip=True).strip("'\"")
            if name:
                names.append(name)
    return names

def main():
    all_names = []
    page = 1

    while True:
        print(f"Scraping page {page}...")
        try:
            html = get_page(page)
        except requests.HTTPError as e:
            print(f"Error retrieving page {page}: {e}")
            break
        
        names = parse_names(html)
        if not names:
            print("No more results found. Stopping.")
            break
        
        all_names.extend(names)
        page += 1
        
        # Pause between requests to be polite.
        time.sleep(1)

    # Write the names to a CSV file.
    csv_filename = "organizations.csv"
    with open(csv_filename, "w", newline="", encoding="utf-8") as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(["Organization Name"])
        for name in all_names:
            writer.writerow([name])
    
    print(f"Scraping complete. Total organizations scraped: {len(all_names)}")
    print(f"Results saved to {csv_filename}")

if __name__ == '__main__':
    main()