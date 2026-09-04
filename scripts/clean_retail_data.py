import pandas as pd
from pathlib import Path


INPUT_PATH = Path("data/raw/online_retail_combined.csv")

CLEANED_OUTPUT = Path("data/processed/online_retail_cleaned.csv")
CANCELLATIONS_OUTPUT = Path("data/processed/cancellations.csv")
CUSTOMER_OUTPUT = Path("data/processed/online_retail_with_customer.csv")


def clean_retail_data():
    """Clean and prepare the Online Retail II dataset."""

    try:
        print("Starting retail data cleaning...")

        # Load extracted retail data
        df = pd.read_csv(INPUT_PATH)
        print(f"Input rows: {len(df):,}")

        # Standardize data types and formats
        df["InvoiceDate"] = pd.to_datetime(df["InvoiceDate"])
        df["StockCode"] = df["StockCode"].astype(str).str.upper()
        df["Invoice"] = df["Invoice"].astype(str)

        # Identify cancelled invoices
        df["is_cancelled"] = df["Invoice"].str.startswith("C")

        # Separate completed sales and cancellations
        df_sales = df[~df["is_cancelled"]].copy()
        df_cancellations = df[df["is_cancelled"]].copy()

        print(f"Cancelled rows: {len(df_cancellations):,}")

        # Remove completed-sale rows with invalid prices
        df_sales = df_sales[df_sales["Price"] > 0].copy()

        # Fill missing product descriptions
        df_sales["Description"] = df_sales["Description"].fillna(
            "Unknown Product"
        )

        # Remove exact duplicate rows
        df_sales = df_sales.drop_duplicates().copy()

        # Create revenue feature
        df_sales["Revenue"] = (
            df_sales["Quantity"] * df_sales["Price"]
        )

        # Create dataset for customer-level analysis
        df_with_customer = df_sales.dropna(
            subset=["Customer ID"]
        ).copy()

        df_with_customer["Customer ID"] = (
            df_with_customer["Customer ID"].astype(int)
        )

        # Prepare cancellation dataset for analysis
        df_cancellations["Revenue"] = (
            df_cancellations["Quantity"] * df_cancellations["Price"]
        )

        # Save cleaned datasets
        df_sales.to_csv(CLEANED_OUTPUT, index=False)
        df_cancellations.to_csv(CANCELLATIONS_OUTPUT, index=False)
        df_with_customer.to_csv(CUSTOMER_OUTPUT, index=False)

        print(f"Cleaned sales rows: {len(df_sales):,}")
        print(f"Customer-level rows: {len(df_with_customer):,}")
        print("Cleaned datasets saved successfully.")

        return df_sales, df_cancellations, df_with_customer

    except FileNotFoundError:
        print(f"Error: input file not found at {INPUT_PATH}")

    except Exception as error:
        print(f"Unexpected error during cleaning: {error}")


if __name__ == "__main__":
    clean_retail_data()