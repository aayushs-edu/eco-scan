from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time

# Initialize your driver
driver = webdriver.Chrome()  # or whatever browser you're using
driver.get("https://www.flocert.net/widget_customersearch/flocert_en/#page-1")

# First, you might need to click the dropdown button to expand it if not already expanded
# The aria-expanded="true" suggests it might be already expanded, but just in case:

def selectFilters():
    try:
        dropdown_button = WebDriverWait(driver, 10).until(
            EC.element_to_be_clickable((By.XPATH, '//*[@id="filter-picker--status"]/button'))
        )
    except:
        print("Button already expanded or couldn't find button")

    dropdown_button.click()

    # Now click the checkboxes
    # For "Certified" checkbox
    certified_checkbox = WebDriverWait(driver, 10).until(
        EC.presence_of_element_located((By.XPATH, '//*[@id="filter-picker--status"]/ul/li[1]/label'))
    )
    certified_checkbox.click()

def get_info():
    """
    Parses the currently loaded page to extract organization names using Selenium.
    """
    # Wait until the customer containers are loaded
    try:
        WebDriverWait(driver, 10).until(
            EC.presence_of_all_elements_located(
                (By.CSS_SELECTOR, "div.customer-search-results__customer.cf")
            )
        )
    except Exception as e:
        print("Customer containers not found:", e)
        return []
    
    containers = driver.find_elements(By.CSS_SELECTOR, "div.customer-search-results__customer.cf")
    names = []
    contacts = []
    flod_ids = []
    functions = []
    countries = []
    product_types = []
    for container in containers:
        try:
            # Extract the organization name
            name_tag = container.find_element(By.CSS_SELECTOR, "strong.customer__name")
            name = name_tag.text.strip().strip("'\"")
            if name:
                names.append(name)

            # Get contacts
            contact_tag = container.find_element(By.CSS_SELECTOR, "div.customer__contact")
            contact_text = contact_tag.find_element(By.TAG_NAME, "p").text[9:].strip()
            if contact_text:
                contacts.append(contact_text)
            
            # Get FLO ID
            flod_id_tag = container.find_element(By.CSS_SELECTOR, "div.customer__flo-id")
            flo_id = flod_id_tag.find_element(By.TAG_NAME, "p").text[8:].strip()
            if flo_id:
                flod_ids.append(flo_id)
            
            # Get function
            function_tag = container.find_element(By.CSS_SELECTOR, "div.customer__function")
            function_text = function_tag.find_element(By.TAG_NAME, "p").text[10:].strip()
            if function_text:
                functions.append(function_text)
            
            # Get country
            country_tag = container.find_element(By.CSS_SELECTOR, "div.customer__country")
            country_text = country_tag.find_element(By.TAG_NAME, "p").text[14:].strip()
            if country_text:
                countries.append(country_text)
            
            # Get product type
            product_type_tag = container.find_element(By.CSS_SELECTOR, "div.customer__product-types")
            product_type_text = product_type_tag.find_element(By.XPATH, ".//p|.//span").text[18:].strip()
            if product_type_text:
                product_types.append(product_type_text)


        except Exception:
            continue
    return names, contacts, flod_ids, functions, countries, product_types

def main():
    all_names = []
    all_contacts = []
    all_flo_ids = []
    all_functions = []
    all_countries = []
    all_product_types = []
    # Start from page 1
    page = 1
    end_page = 571

    selectFilters()

    time.sleep(7)

    while page < end_page:
        print(f"Scraping page {page}... {page * 100/end_page}%")
        names, contacts, flo_ids, functions, countries, product_types = get_info()
        if not names:
            print("No more results found. Stopping.")
            break

        all_names.extend(names)
        all_contacts.extend(contacts)
        all_flo_ids.extend(flo_ids)
        all_functions.extend(functions)
        all_countries.extend(countries)
        all_product_types.extend(product_types)
        
        # Attempt to set the page number in the input field and navigate to the next page
        try:
            page += 1
            # Locate the input field for pagination
            pagination_input = WebDriverWait(driver, 10).until(
                EC.presence_of_element_located((By.ID, "pagination-goto__number"))
            )
            
            # Clear the input field and set the page number
            pagination_input.clear()
            pagination_input.send_keys(str(page))  # Set the page variable as the input value
            
            # Press Enter to navigate to the specified page
            pagination_input.send_keys("\n")
            
            # Wait for the new page content to load
            time.sleep(2)  # Adjust the sleep time as needed
        except Exception as e:
            print("Error navigating to the next page:", e)
            break

    # Write the names to a CSV file.
    import csv  # Import here if not imported elsewhere.
    csv_filename = "organizations.csv"
    with open(csv_filename, "w", newline="", encoding="utf-8") as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(["Organization Name", "Contact", "FLO ID", "Function", "Country", "Product Type"])
        for name, contact, flo_id, func, country, product_type in zip(all_names, all_contacts, all_flo_ids, all_functions, all_countries, all_product_types):
            writer.writerow([name, contact, flo_id, func, country, product_type])
    
    print(f"Scraping complete. Total organizations scraped: {len(all_names)}")
    print(f"Results saved to {csv_filename}")

if __name__ == '__main__':
    main()
