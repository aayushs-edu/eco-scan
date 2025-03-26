import pandas as pd

# List of file paths
file_paths = [
    "worldwidedairy_aligned.xlsx",
    "worldwidegrain_aligned.xlsx",
    "worldwidepoultry_aligned.xlsx",
    "worldwidefruit.xlsx",
    "worldwidevegetables_aligned.xlsx"
]

# Read and concatenate all files
merged_df = pd.concat([pd.read_excel(file) for file in file_paths], ignore_index=True)

# Save to a new Excel file
output_path = "merged_worldwide.xlsx"
merged_df.to_excel(output_path, index=False)

print(f"Merged file saved to: {output_path}")
