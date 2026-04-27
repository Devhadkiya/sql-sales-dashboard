import pandas as pd
import numpy as np
from faker import Faker
import random
from datetime import datetime, timedelta

fake = Faker()
np.random.seed(42)
random.seed(42)

# --- reference data ---
regions    = ['North', 'South', 'East', 'West', 'Central']
categories = ['Electronics', 'Clothing', 'Furniture', 'Food & Beverage', 'Sports']
products   = {
    'Electronics':     [('Laptop', 799.99), ('Smartphone', 499.99), ('Headphones', 149.99), ('Tablet', 329.99)],
    'Clothing':        [('T-Shirt', 19.99), ('Jeans', 49.99), ('Jacket', 89.99), ('Dress', 59.99)],
    'Furniture':       [('Chair', 129.99), ('Desk', 249.99), ('Sofa', 599.99), ('Bookshelf', 179.99)],
    'Food & Beverage': [('Coffee Pack', 12.99), ('Tea Set', 24.99), ('Juice Box', 8.99), ('Snack Bundle', 15.99)],
    'Sports':          [('Yoga Mat', 34.99), ('Dumbbells', 59.99), ('Running Shoes', 119.99), ('Bicycle', 399.99)],
}

# --- generate customers ---
n_customers = 2000
customers = pd.DataFrame({
    'customer_id':   [f'C{str(i).zfill(5)}' for i in range(1, n_customers + 1)],
    'customer_name': [fake.name() for _ in range(n_customers)],
    'email':         [fake.email() for _ in range(n_customers)],
    'region':        [random.choice(regions) for _ in range(n_customers)],
    'signup_date':   [fake.date_between(start_date='-5y', end_date='-1y') for _ in range(n_customers)],
})

# --- generate sales ---
n_sales = 100_000
rows = []
start_date = datetime(2022, 1, 1)

for i in range(1, n_sales + 1):
    cat        = random.choice(categories)
    prod, price = random.choice(products[cat])
    qty        = random.randint(1, 10)
    discount   = random.choice([0, 0, 0, 0.05, 0.10, 0.15, 0.20])
    sale_date  = start_date + timedelta(days=random.randint(0, 1000))
    cust       = customers.sample(1).iloc[0]

    rows.append({
        'sale_id':      f'S{str(i).zfill(7)}',
        'sale_date':    sale_date.strftime('%Y-%m-%d'),
        'customer_id':  cust['customer_id'],
        'customer_name':cust['customer_name'],
        'region':       cust['region'],
        'category':     cat,
        'product_name': prod,
        'unit_price':   price,
        'quantity':     qty,
        'discount':     discount,
        'revenue':      round(price * qty * (1 - discount), 2),
    })

sales = pd.DataFrame(rows)

# --- save ---
customers.to_csv('data/customers.csv', index=False)
sales.to_csv('data/sales.csv', index=False)
print(f"Done! Generated {len(sales):,} sales rows and {len(customers):,} customers.")
print("Files saved: data/customers.csv, data/sales.csv")