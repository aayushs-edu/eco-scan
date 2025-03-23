import requests
import pandas as pd

def get_product_categories(gtin):
    # OpenFoodFacts API URL for a specific product by GTIN
    url = f"https://world.openfoodfacts.org/api/v0/product/{gtin}.json"
    
    # Send GET request to the API
    response = requests.get(url)
    
    # Check if the request was successful
    if response.status_code == 200:
        product_data = response.json()
        
        # Check if the product data contains the 'categories_tags' field
        if 'product' in product_data and 'categories_tags' in product_data['product']:
            categories_tags = product_data['product']['categories_tags']
            return categories_tags
        else:
            print("Categories tags not found in the product data.")
            return None
    else:
        print(f"Error: Unable to fetch data (Status code: {response.status_code})")
        return None

def process_categories(categories_tags):
    processed_categories = []
    
    for category in categories_tags:
        # Remove the first 3 characters
        category = category[3:]
        
        
        # Split the string by hyphen
        category_parts = category.split("-")
        
        # Remove occurrences of "and"
        category_parts = [part for part in category_parts if part != "and"]
        
        # Add the processed category to the list
        for cat in category_parts:
            if cat.endswith("s"):
                    cat = cat[:-1]
            if cat not in processed_categories:
                processed_categories.append(cat)
    
    return processed_categories

def search_emission_results(processed_categories):
    # Load the emission results CSV using pandas
    emission_df = pd.read_csv('emission_results.csv')

    # Create a dictionary to store the results for each category
    category_matches = {}

    # Iterate over each processed category
    for category in processed_categories:
        # Search for activity_id that contains the category string
        matching_rows = emission_df[emission_df['activity_id'].str.contains(category, case=False, na=False)]
        
        if not matching_rows.empty:
            # Store the matching rows in the dictionary
            category_matches[category] = matching_rows
        else:
            category_matches[category] = None
    
    return category_matches

# GTIN for the product you want to query
gtin = "078742434230"  # Example GTIN

# Fetch the categories_tags
categories_tags = get_product_categories(gtin)

if categories_tags:
    processed_categories = process_categories(categories_tags)
    print("Processed categories:", processed_categories)
    
    # Search for matches in the emission_results CSV
    category_matches = search_emission_results(processed_categories)
    
    # Initialize variables to track the category with the least matches
    min_matches_category = None
    min_matches_count = float('inf')  # Set initial min matches to a large number
    min_matches_data = None
    
    # Print or process the matches found
    for category, matches in category_matches.items():
        if matches is not None:
            print(f"\nMatches for category '{category}':")
            print(list(matches["activity_id"]))
            
            # Check if this category has the least matches so far
            matches_count = len(matches)
            if matches_count < min_matches_count:
                min_matches_category = category
                min_matches_count = matches_count
                min_matches_data = matches
        else:
            print(f"\nNo matches found for category '{category}'.")
    
    # After processing all categories, print the category with the least matches
    if min_matches_category:
        print(f"\nCategory with the least matches: '{min_matches_category}'")
        print(f"Number of matches: {min_matches_count}")
        print("Matches:")
        print(list(min_matches_data["activity_id"]))
        print("Final choice: ", min_matches_data["activity_id"].iloc[0])
