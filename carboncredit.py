import pandas as pd

def filter_agriculture_rows(file_path, output_path):
    # Load the Excel file
    df = pd.read_excel(file_path)
    
    # Check if there are at least three columns
    if df.shape[1] < 3:
        raise ValueError("The Excel file does not have at least three columns.")
    
    # Get the third column name
    third_column = df.columns[2]
    
    # Filter rows where the third column is 'Agriculture'
    filtered_df = df[df[third_column] == 'Agriculture']
    
    # Save the filtered data to a new Excel file
    filtered_df.to_excel(output_path, index=False)
    
    print(f"Filtered data saved to {output_path}")

# Example usage:
filter_agriculture_rows('Voluntary-Registry-Offsets-Database--v2025-02.xlsx', 'filtered_output.xlsx')
