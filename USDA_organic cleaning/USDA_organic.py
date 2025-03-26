import pandas as pd

# Read the fruit dataset, which will provide the master column list
fruit_df = pd.read_excel("worldwidefruit.xlsx")
fruit_columns = list(fruit_df.columns)

# Function to align a dataset with the fruit dataset's columns
def align_columns(df, master_columns):
    # Keep only the columns that match the master list
    # and add any missing columns with NaN values.
    df_aligned = df.reindex(columns=master_columns)
    return df_aligned

# Read the dairy dataset and align its columns
dairy_df = pd.read_excel("worldwidedairy.xlsx")
dairy_df_aligned = align_columns(dairy_df, fruit_columns)

# Read the grain dataset and align its columns
grain_df = pd.read_excel("worldwidegrain.xlsx")
grain_df_aligned = align_columns(grain_df, fruit_columns)

grain_df = pd.read_excel("worldwidepoultry.xlsx")
poultry_df_aligned = align_columns(grain_df, fruit_columns)

grain_df = pd.read_excel("worldwidevegetables.xlsx")
poultry_df_aligned = align_columns(grain_df, fruit_columns)

# Optionally, write the updated datasets to new Excel files
poultry_df_aligned.to_excel("worldwidepoultry_aligned.xlsx", index=False)
dairy_df_aligned.to_excel("worldwidedairy_aligned.xlsx", index=False)
grain_df_aligned.to_excel("worldwidegrain_aligned.xlsx", index=False)
grain_df_aligned.to_excel("worldwidevegetables_aligned.xlsx", index=False)

print("All datasets have been aligned to the fruit dataset columns.")
