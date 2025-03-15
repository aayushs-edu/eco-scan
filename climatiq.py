import requests
import os
from pprint import pprint

# Replace with your actual API key
MY_API_KEY = "082NCJSV751C37E60Y3GHZ4BPW"

BASE_URL = "https://api.climatiq.io"
AUTH_HEADERS = {
    "Authorization": f"Bearer {MY_API_KEY}",
    "Content-Type": "application/json"
}
ACTIVITY_FILE = "activity_ids.txt"

def fetch_activity_ids(category):
    """Fetch all activity IDs and unit types from the API."""
    url = f"{BASE_URL}/data/v1/search"
    activity_data = []
    page = 1

    while True:
        params = {
            "data_version": "^0",
            "category": category,
            "page": page,
        }
        response = requests.get(url, params=params, headers=AUTH_HEADERS)
        data = response.json()

        if "results" in data and data["results"]:
            for item in data["results"]:
                activity_data.append(f"{item['activity_id']}|{item['unit_type']}")
            page += 1
        else:
            break  # No more results

    return activity_data

def get_stored_activity_ids():
    """Reads stored activity IDs from file if available."""
    if os.path.exists(ACTIVITY_FILE) and os.path.getsize(ACTIVITY_FILE) > 0:
        with open(ACTIVITY_FILE, "r") as file:
            return [line.strip() for line in file.readlines()]
    return []

def store_activity_ids(activity_data):
    """Stores activity IDs and unit types in a text file."""
    with open(ACTIVITY_FILE, "w") as file:
        for entry in activity_data:
            file.write(entry + "\n")

def get_emission_estimate(activity_id, unit_type):
    """Get the emission estimate for a given activity ID using the correct unit type."""
    url = f"{BASE_URL}/data/v1/estimate"

    # Choose correct parameters based on unit type
    if "Money" in unit_type:
        parameters = {"money": 10, "money_unit": "usd"}
    elif "Weight" in unit_type:
        parameters = {"weight": 10, "weight_unit": "kg"}  # Adjust weight as needed
    else:
        print(f"Skipping {activity_id}: Unsupported unit type {unit_type}")
        return None

    payload = {
        "emission_factor": {
            "activity_id": activity_id,
            "data_version": "^0"
        },
        "parameters": parameters
    }
    response = requests.post(url, json=payload, headers=AUTH_HEADERS)

    if response.status_code == 200:
        return response.json()
    else:
        print(f"Error fetching emissions for {activity_id}: {response.text}")
        return None

def main():
    category = "Food/Beverages/Tobacco"
    total_entries = 5  # Limit for testing

    # Check if we have stored activity IDs
    stored_activity_data = get_stored_activity_ids()

    if stored_activity_data:
        print("✅ Using cached activity IDs from file.")
        activity_data = stored_activity_data
    else:
        print("🔄 Fetching activity IDs from API...")
        activity_data = fetch_activity_ids(category)
        if activity_data:
            store_activity_ids(activity_data)
            print("📂 Activity IDs stored in file.")
        else:
            print("❌ No activity IDs found!")
            return

    emissions_results = {}

    for entry in activity_data[:total_entries]:  # Limit to total_entries for testing
        print(f"Processing: {entry}")
        activity_id, unit_type = entry.split("|")
        estimate = get_emission_estimate(activity_id, unit_type)
        if estimate:
            emissions_results[activity_id] = estimate

    pprint(emissions_results)

if __name__ == "__main__":
    main()
