"""
seed_fake_data.py
------------------
Generates new drivers, passengers, and trips in the SOURCE database
so the next pipeline run has non-zero incremental data to extract.
Run this, then run pipeline.py to test idempotency across 3 runs.
"""
import os
import random
import psycopg2
from datetime import timedelta
from dotenv import load_dotenv
from faker import Faker

load_dotenv()
fake = Faker()

SOURCE_DB_CONFIG = dict(
    host=os.getenv("SRC_DB_HOST"),
    port=os.getenv("SRC_DB_PORT"),
    dbname=os.getenv("SRC_DB_NAME"),
    user=os.getenv("SRC_DB_USER"),
    password=os.getenv("SRC_DB_PASSWORD"),
)

N_DRIVERS = 5
N_PASSENGERS = 5
N_TRIPS = 20


def get_existing_ids(cur, table, id_col):
    cur.execute(f"SELECT {id_col} FROM {table}")
    return [r[0] for r in cur.fetchall()]


def main():
    conn = psycopg2.connect(**SOURCE_DB_CONFIG)
    try:
        with conn.cursor() as cur:
            # --- new drivers ---
            driver_ids = []
            for _ in range(N_DRIVERS):
                cur.execute(
                    """
                    INSERT INTO drivers (name, status, joined_at)
                    VALUES (%s, %s, NOW())
                    RETURNING driver_id
                    """,
                    (fake.name(), random.choice(["active", "active", "inactive"])),
                )
                driver_ids.append(cur.fetchone()[0])

            # --- new passengers ---
            passenger_ids = []
            for _ in range(N_PASSENGERS):
                cur.execute(
                    """
                    INSERT INTO passengers (name, status, created_at)
                    VALUES (%s, %s, NOW())
                    RETURNING passenger_id
                    """,
                    (fake.name(), random.choice(["active", "active", "inactive"])),
                )
                passenger_ids.append(cur.fetchone()[0])

            # --- pull existing lookup ids for FKs ---
            location_ids = get_existing_ids(cur, "locations", "location_id")
            payment_method_ids = get_existing_ids(cur, "payment_methods", "payment_method_id")
            promo_code_ids = get_existing_ids(cur, "promo_codes", "promo_code_id")

            all_driver_ids = get_existing_ids(cur, "drivers", "driver_id")
            all_passenger_ids = get_existing_ids(cur, "passengers", "passenger_id")

            # --- new trips ---
            for _ in range(N_TRIPS):
                status = random.choices(
                    ["completed", "cancelled", "no_show"], weights=[0.8, 0.15, 0.05]
                )[0]
                requested_at = fake.date_time_between(start_date="-2h", end_date="now")
                completed_at = (
                    requested_at + timedelta(minutes=random.randint(5, 45))
                    if status == "completed"
                    else None
                )
                payment_method_id = (
                    random.choice(payment_method_ids) if status != "no_show" else None
                )
                promo_code_id = random.choice(promo_code_ids) if random.random() < 0.3 else None

                cur.execute(
                    """
                    INSERT INTO trips (
                        driver_id, passenger_id, pickup_location_id, dropoff_location_id,
                        payment_method_id, promo_code_id, base_fare, tip_amount,
                        discount_amount, surge_multiplier, distance_km, status,
                        requested_at, completed_at, driver_rating, passenger_rating
                    ) VALUES (
                        %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s
                    )
                    """,
                    (
                        random.choice(all_driver_ids),
                        random.choice(all_passenger_ids),
                        random.choice(location_ids),
                        random.choice(location_ids),
                        payment_method_id,
                        promo_code_id,
                        round(random.uniform(5, 40), 2),
                        round(random.uniform(0, 10), 2) if status == "completed" else 0,
                        round(random.uniform(0, 5), 2) if promo_code_id else 0,
                        random.choice([1.0, 1.0, 1.2, 1.5]),
                        round(random.uniform(1, 25), 2),
                        status,
                        requested_at,
                        completed_at,
                        random.randint(3, 5) if status == "completed" else None,
                        random.randint(3, 5) if status == "completed" else None,
                    ),
                )
        conn.commit()
        print(f"Inserted {N_DRIVERS} drivers, {N_PASSENGERS} passengers, {N_TRIPS} trips.")
    except Exception as e:
        conn.rollback()
        raise
    finally:
        conn.close()


if __name__ == "__main__":
    main()