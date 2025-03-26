import pandas as pd
import os

# File path
file_path = "FAOSTAT_data_en_3-18-2025.csv"

# Load the CSV file
df = pd.read_csv(file_path)

# Check if "Value" column exists
if "Value" in df.columns:
    # Create a new dataframe to store processed rows
    processed_rows = []

    # Iterate through the dataset in chunks of 6 rows
    for i in range(0, len(df), 6):
        chunk = df.iloc[i:i+6].copy()  # Get 6 consecutive rows
        avg_value = chunk["Value"].mean()  # Compute the average price

        # Retain the first row and replace its "Value" with the average
        chunk.iloc[0, chunk.columns.get_loc("Value")] = avg_value

        # Append only the first row (modified) to the new dataset
        processed_rows.append(chunk.iloc[0])

    # Create a new dataframe from processed rows
    df_processed = pd.DataFrame(processed_rows)

    # Convert from USD/tonne to USD/kg
    df_processed["Value"] = df_processed["Value"] / 1000
    df_processed["Value"] = round(df_processed["Value"], 2)

    df_processed["Unit"] = "(USD/kg)"
    df_processed.drop("Year", axis=1, inplace=True) 



    # Average all the countries' prices to get worldwide, average price.
    df_processed = df_processed.sort_values(by="Item")
    
    processed_rows = []
    i = 0  # Iterator for dataset length
    
    while i < len(df_processed):
        current_item = df_processed.iloc[i]["Item"]  # Get the current product
        temp_rows = []  # Store rows for the same product
        
        # Collect all rows that belong to the current product
        while i < len(df_processed) and df_processed.iloc[i]["Item"] == current_item:
            temp_rows.append(df_processed.iloc[i])
            i += 1  # Move to the next row

        # Convert the collected rows into a DataFrame
        temp_df = pd.DataFrame(temp_rows)
        
        # Compute the worldwide average price
        avg_price = round(temp_df["Value"].mean(), 2)
        
        # Keep only one row, update its Value with the worldwide average
        temp_df.iloc[0, temp_df.columns.get_loc("Value")] = avg_price
        
        # Store the modified row
        processed_rows.append(temp_df.iloc[0])

    # Create a new DataFrame from processed rows
    df_processed = pd.DataFrame(processed_rows) 

    df_processed["Area"] = "Worldwide"

    df_processed.drop("Domain", axis=1, inplace=True)
    df_processed.drop("Months", axis=1, inplace=True)
    df_processed.drop("Element", axis=1, inplace=True)



    # Save back to the same file
    df_processed.to_csv(file_path, index=False)

    print("Processing completed: replaced 6-year price data with averages and converted to USD/kg.")
else:
    print("Error: 'Value' column not found in the CSV file.")


df = pd.read_csv(file_path)
new_file_path = "FAO_2018-2023_worldwide_average_producer_prices.csv"
df.to_csv(new_file_path, index=False)
os.remove(file_path)
print(f"File renamed successfully from '{file_path}' to '{new_file_path}'")