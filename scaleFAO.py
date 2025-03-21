import pandas as pd
import os

# File path
file_path = "FAOSTAT_data_en_3-18-2025.csv"

# Load the CSV file
df = pd.read_csv(file_path)

# Check if "Value" column exists
if "Value" in df.columns:
    # Convert from USD/tonne to USD/kg
    df["Value"] = df["Value"] / 1000
    df["Value"] = round(df["Value"], 2)

    # Save back to the same file
    df.to_csv(file_path, index=False)
    print("Conversion completed successfully. File updated.")
else:
    print("Error: 'Value' column not found in the CSV file.")


df = pd.read_csv(file_path)
new_file_path = "FAO_commercial_prices.csv"
df.to_csv(new_file_path, index=False)
os.remove(file_path)
print(f"File renamed successfully from '{file_path}' to '{new_file_path}'")