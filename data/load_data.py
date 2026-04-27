import pandas as pd
import mysql.connector
from mysql.connector import Error

# ------------------------------------------------
# CHANGE these values to match your MySQL setup
# ------------------------------------------------
DB_HOST     = 'localhost'
DB_USER     = 'root'         # your MySQL username
DB_PASSWORD = 'Pass123' # your MySQL password
DB_NAME     = 'retail_sales'
# ------------------------------------------------

def get_connection():
    return mysql.connector.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASSWORD,
        database=DB_NAME
    )

def load_customers(cursor, df):
    print("Loading customers...")
    sql = """
        INSERT IGNORE INTO customers
            (customer_id, customer_name, email, region, signup_date)
        VALUES (%s, %s, %s, %s, %s)
    """
    rows = [tuple(r) for r in df[['customer_id','customer_name','email','region','signup_date']].values]
    cursor.executemany(sql, rows)
    print(f"  Inserted {cursor.rowcount} customers.")

def load_sales(cursor, df, batch=5000):
    print("Loading sales (this may take a minute)...")
    sql = """
        INSERT IGNORE INTO sales
            (sale_id, sale_date, customer_id, customer_name,
             region, category, product_name, unit_price,
             quantity, discount, revenue)
        VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)
    """
    cols = ['sale_id','sale_date','customer_id','customer_name',
            'region','category','product_name','unit_price',
            'quantity','discount','revenue']
    rows = [tuple(r) for r in df[cols].values]
    total = 0
    for i in range(0, len(rows), batch):
        cursor.executemany(sql, rows[i:i+batch])
        total += cursor.rowcount
        print(f"  {min(i+batch, len(rows)):,} / {len(rows):,} rows loaded...")
    print(f"  Done. Total inserted: {total:,} rows.")

def main():
    try:
        conn   = get_connection()
        cursor = conn.cursor()

        customers = pd.read_csv('data/customers.csv')
        sales     = pd.read_csv('data/sales.csv')

        load_customers(cursor, customers)
        conn.commit()

        load_sales(cursor, sales)
        conn.commit()

        print("\nAll data loaded successfully into retail_sales database!")

    except Error as e:
        print(f"MySQL Error: {e}")
    finally:
        if conn.is_connected():
            cursor.close()
            conn.close()

if __name__ == '__main__':
    main()