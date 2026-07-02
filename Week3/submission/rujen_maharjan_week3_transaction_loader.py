import psycopg2
from dotenv import load_dotenv
import os
import logging

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s  %(levelname)s  %(message)s"
)
logger = logging.getLogger(__name__)

load_dotenv()

DB_CONFIG = dict(
    host=os.getenv("DB_HOST"),
    port = os.getenv("DB_PORT"),
    dbname = os.getenv("DB_NAME"),
    user= os.getenv("DB_USER"),
    password=os.getenv("DB_PASSWORD")
)

INSERT_SQL = """
    INSERT INTO trips (
        driver_id, passenger_id,
        pickup_location_id, dropoff_location_id,
        fare_amount, distance_km, status,
        requested_at, completed_at, rating, payment_method_id
    ) VALUES (
        %(driver_id)s, %(passenger_id)s,
        %(pickup_location_id)s, %(dropoff_location_id)s,
        %(fare_amount)s, %(distance_km)s, %(status)s,
        %(requested_at)s, %(completed_at)s,
        %(rating)s, %(payment_method_id)s
    )
"""

def get_connection():
    return psycopg2.connect(**DB_CONFIG)


def load_batch(conn, rows: list) -> int:
    """
    Load a batch of trip rows inside a single transaction.

    Args:
        conn:  An open psycopg2 connection
        rows:  A list of dicts — each dict is one trip row

    Returns:
        Number of rows loaded (0 if the batch failed and rolled back)

    Raises:
        Exception: re-raised after rollback so the caller knows it failed
    """
    conn.autocommit=False
    row_num=0

    try:
        with conn.cursor() as curr:
            for row_num, row in enumerate(rows):
                curr.execute(INSERT_SQL,row)
    except Exception as e:
        conn.rollback()
        logger.error(f"Batch failed at row {row_num}: {e}")
        raise
    else:
        conn.commit()
        return len(rows)
    


def get_test_batches():
    """
    Returns two test batches:
      - good_batch: 5 valid trips (should commit)
      - bad_batch:  5 trips where row 3 has an invalid rating (should roll back)
    """
    base = dict(
        driver_id=1, passenger_id=1,
        pickup_location_id=1, dropoff_location_id=2,
        fare_amount=250.00, distance_km=8.5,
        status="completed",
        requested_at="2025-01-15 09:00:00",
        completed_at="2025-01-15 09:35:00",
        rating=4.5,
        payment_method_id=1
    )

    good_batch = [{**base, "fare_amount": 100 * (i + 1)} for i in range(5)]

    bad_batch = []
    for i in range(5):
        row = {**base, "fare_amount": 100 * (i + 1)}
        if i == 2:
            row["rating"] = 99  # violates CHECK (rating BETWEEN 1.0 AND 5.0)
        bad_batch.append(row)

    return good_batch, bad_batch


def main():
    conn=get_connection()

    good_batch, bad_batch= get_test_batches()

    try:
        loaded=load_batch(conn,good_batch)
        print(f"\n\nNumber of commited rows: {loaded} rows \n\n")
        loaded=load_batch(conn,bad_batch)
    except Exception as e:
        print(f"Commit Failed... Rollback")

    with conn.cursor() as curr:
        curr.execute("select count(*) from trips")
        row = curr.fetchone()
        print("\n\nNumber of trips: ",row)
    
    conn.close()

if __name__=="__main__":
    main()