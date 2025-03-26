import pandas as pd

def remove_duplicates(input_file):
    # Read the Excel file
    df = pd.read_excel(input_file)
    
    # Remove duplicate rows
    df = df.drop_duplicates(inplace=True)
    
    # Save the cleaned data to a new Excel file
    # df_cleaned.to_excel("worldwide_organics.xlsx", index=False)
    
    print(f"Duplicate rows removed.")

# Example usage
remove_duplicates("merged_worldwide.xlsx")