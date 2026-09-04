import requests
import pandas as pd
from pathlib import Path

# World Bank API endpoint for population data
COUNTRY_CODES = {
    "Australia": "AU",
    "Austria": "AT",
    "Bahrain": "BH",
    "Belgium": "BE",
    "Bermuda": "BM",
    "Brazil": "BR",
    "Canada": "CA",
    "Cyprus": "CY",
    "Czech Republic": "CZ",
    "Denmark": "DK",
    "EIRE": "IE",
    "Finland": "FI",
    "France": "FR",
    "Germany": "DE",
    "Greece": "GR",
    "Hong Kong": "HK",
    "Iceland": "IS",
    "Israel": "IL",
    "Italy": "IT",
    "Japan": "JP",
    "Korea": "KR",
    "Lebanon": "LB",
    "Lithuania": "LT",
    "Malta": "MT",
    "Netherlands": "NL",
    "Nigeria": "NG",
    "Norway": "NO",
    "Poland": "PL",
    "Portugal": "PT",
    "RSA": "ZA",
    "Saudi Arabia": "SA",
    "Singapore": "SG",
    "Spain": "ES",
    "Sweden": "SE",
    "Switzerland": "CH",
    "Thailand": "TH",
    "USA": "US",
    "United Arab Emirates": "AE",
    "United Kingdom": "GB"
}

country_codes = ";".join(COUNTRY_CODES.values())

API_URL = (
    f"https://api.worldbank.org/v2/country/"
    f"{country_codes}/indicator/SP.POP.TOTL"
)

# Location where the extracted API data will be saved
OUTPUT_PATH = Path("data/raw/world_bank_population.csv")

def extract_world_bank_data():
    """
    Retrieve population data from the World Bank REST API.
    """

    try:
        print("Starting World Bank API extraction...")

        params = {
            "format": "json",
            "date": "2009:2011",
            "per_page": 1000
        }
        
        response = requests.get(API_URL, params=params, timeout=30)
        response.raise_for_status()

        data = response.json()

        # The World Bank API returns metadata first, then the actual records
        records = data[1]

        # Convert the records into a DataFrame
        df = pd.DataFrame(records)

        # Keep only the fields we need
        df = df[["country", "countryiso3code", "date", "value"]]

        # Extract the country name from the nested dictionary
        df["country"] = df["country"].apply(lambda x: x["value"])

        # Rename columns to make them clearer
        df = df.rename(columns={
            "countryiso3code": "country_code",
            "date": "year",
            "value": "population"
        })
       

        # Save the extracted API data
        df.to_csv(OUTPUT_PATH, index=False)

        print(f"Retrieved {len(df):,} population records.")
        print(f"World Bank population data saved to: {OUTPUT_PATH}")
        print("World Bank data successfully retrieved.")

        return df

    except requests.RequestException as error:
        print(f"API request failed: {error}")


if __name__ == "__main__":
    extract_world_bank_data()