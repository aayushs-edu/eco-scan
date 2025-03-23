import pandas as pd

# Load the dataset
file_path = "fairtrade.csv"
df = pd.read_csv(file_path)

# Define allowed keywords for preferred Form values (case-insensitive)
allowed_keywords = ['fresh', 'consumption']

def is_allowed_form(form):
    if pd.isna(form):
        return False
    form_lower = str(form).lower()
    return any(keyword in form_lower for keyword in allowed_keywords)

# Conversion rates for non-USD currencies (update these as needed)
conversion_rates = {
    "EUR": 1.10,  # 1 EUR = 1.10 USD (example)
    "GBP": 1.30,  # 1 GBP = 1.30 USD (example)
    "CAD": 0.75,  # 1 CAD = 0.75 USD (example)
    "AUD": 0.70,  # 1 AUD = 0.70 USD (example)
    "ZAR": 0.055, # 1 ZAR = 0.055 USD (example)
    # Add more currencies if needed.
}

def to_float(val):
    try:
        return float(val)
    except (ValueError, TypeError):
        return None

def convert_currency(row):
    curr = row.get('Currency')
    price = row.get('Fairtrade minimum price')
    if pd.notnull(curr) and curr.strip().upper() != "USD":
        price_num = to_float(price)
        if price_num is not None:
            rate = conversion_rates.get(curr.strip().upper())
            if rate is not None:
                row['Fairtrade minimum price'] = round(price_num * rate, 2)
                row['Currency'] = "USD"
    return row

def choose_one_row(subgroup):
    """
    subgroup: DataFrame for a given product name and quality.
    Returns one row based on preferred "Form" values.
    """
    # Identify rows with preferred Form values (i.e. those that contain allowed keywords)
    preferred = subgroup[subgroup['Form'].apply(is_allowed_form)]
    
    if not preferred.empty:
        # Within preferred rows, check if any row has Country/Region == "Worldwide"
        worldwide = preferred[preferred['Country / Region'].str.lower() == "worldwide"]
        if not worldwide.empty:
            selected = worldwide.iloc[0]
        else:
            selected = preferred.iloc[0]
    else:
        # Fallback: none of the rows have a preferred Form.
        # Even if multiple rows (possibly with different Form values) exist,
        # choose one – giving a slight preference to "Worldwide" if available.
        worldwide = subgroup[subgroup['Country / Region'].str.lower() == "worldwide"]
        if not worldwide.empty:
            selected = worldwide.iloc[0]
        else:
            selected = subgroup.iloc[0]
    
    return selected

# Process each product's quality subgroup (each product should have one conventional and one organic row)
def process_product_group(group):
    # Within this product group, further split by quality ('conventional' and 'organic')
    selected_rows = []
    for quality in ['conventional', 'organic']:
        # Filter rows for this quality (case-insensitive match)
        quality_sub = group[group['Quality'].str.lower() == quality]
        if not quality_sub.empty:
            selected = choose_one_row(quality_sub)
            selected_rows.append(selected)
    if selected_rows:
        return pd.DataFrame(selected_rows)
    else:
        return pd.DataFrame([])

print(df.columns)
result = df.groupby('Product', group_keys=False).apply(process_product_group)

# Apply currency conversion for each selected row
converted = result.apply(convert_currency, axis=1)

# Reset index if desired and save the resulting DataFrame
result = converted.reset_index(drop=True)
output_file = "filtered_fair_trade_prices.csv"
result.to_csv(output_file, index=False)

# Display the first few rows of the result
print(result.head())
