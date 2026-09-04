import pandas as pd
from pathlib import Path


RETAIL_PATH = Path("data/raw/online_retail_combined.csv")
WORLD_BANK_PATH = Path("data/raw/world_bank_population.csv")
OUTPUT_PATH = Path("data/processed/retail_with_population.csv")


def merge_retail_with_population():
    """
    Combine Online Retail II data with World Bank population data.
    """

    try:
        print("Starting data integration...")

        # Load both data sources
        retail = pd.read_csv(RETAIL_PATH)
        population = pd.read_csv(WORLD_BANK_PATH)

        # Create a year column from the retail invoice date
        retail["InvoiceDate"] = pd.to_datetime(retail["InvoiceDate"])
        retail["year"] = retail["InvoiceDate"].dt.year

        # Standardize country names so they match World Bank naming
        country_mapping = {
            "EIRE": "Ireland",
            "RSA": "South Africa",
            "USA": "United States",
            "Korea": "Korea, Rep.",
            "Hong Kong": "Hong Kong SAR, China",
            "Czech Republic": "Czechia"
        }

        retail["country_standardized"] = retail["Country"].replace(
            country_mapping
        )

        # Merge the two sources using country and year
        merged = retail.merge(
            population,
            left_on=["country_standardized", "year"],
            right_on=["country", "year"],
            how="left"
        )

        # Save the integrated dataset
        merged.to_csv(OUTPUT_PATH, index=False)

        print(f"Retail rows: {len(retail):,}")
        print(f"Merged rows: {len(merged):,}")
        print(f"Integrated dataset saved to: {OUTPUT_PATH}")

        return merged

    except FileNotFoundError as error:
        print(f"File not found: {error}")

    except Exception as error:
        print(f"Unexpected error during data integration: {error}")


if __name__ == "__main__":
    merge_retail_with_population()