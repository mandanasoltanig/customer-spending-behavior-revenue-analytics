import pandas as pd
from pathlib import Path


RAW_DATA_PATH = Path("data/raw/online_retail_II.xlsx")
OUTPUT_PATH = Path("data/raw/online_retail_combined.csv")


def extract_data():
    """
    Load the raw Online Retail II Excel file and combine all sheets
    into one CSV file for further processing.
    """

    try:
        print("Starting data extraction...")

        # Read all sheets from the Excel workbook
        sheets = pd.read_excel(RAW_DATA_PATH, sheet_name=None)

        # Combine the sheets into one DataFrame
        df = pd.concat(sheets.values(), ignore_index=True)

        print(f"Successfully extracted {len(df):,} rows.")

        # Save the combined raw data
        df.to_csv(OUTPUT_PATH, index=False)

        print(f"Combined dataset saved to: {OUTPUT_PATH}")

        return df

    except FileNotFoundError:
        print(f"Error: source file not found at {RAW_DATA_PATH}")

    except Exception as error:
        print(f"Unexpected error during extraction: {error}")


if __name__ == "__main__":
    extract_data()