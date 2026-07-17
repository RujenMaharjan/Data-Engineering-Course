import psycopg2
import logging
import os
from dotenv import load_dotenv
from datetime import datetime
from quality import DataQualityError
import shutil

import time

import argparse

from extract import (
    extract_driver,
    extract_passenger,
    extract_location,
    extract_payment_method,
    extract_promo_code,
    extract_trips,
    extract_vehicle,
    extract_lookup_dim,
    get_watermark
)
from load import (
    load_dim_driver,
    load_dim_passenger,
    load_dim_location,
    load_dim_payment_method,
    load_dim_promo_code,
    load_fact_trips,
    load_dim_vehicle
)
from transform import transform

from quality  import run_quality_checks

def parse_args():
    parser = argparse.ArgumentParser(description="Rides ETL pipeline")
    parser.add_argument(
        "--full-reload",
        action="store_true",
        help="Truncate warehouse and reload all data (default: incremental)"
    )
    return parser.parse_args()

LOG_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "logs")
os.makedirs(LOG_DIR, exist_ok=True)

temp_log_path = os.path.join(LOG_DIR, "_inprogress.log")

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s  %(levelname)s [%(filename)s:%(lineno)d] %(message)s",
    handlers=[
        logging.FileHandler(temp_log_path),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)


def finalize_log(label: str):
    """Close file handles and move the temp log to its final labeled name."""
    logging.shutdown()
    final_path = os.path.join(LOG_DIR, f"{label}.log")
    shutil.move(temp_log_path, final_path)
    print(f"Log saved to: {final_path}")

load_dotenv()

SOURCE_DB_CONFIG = dict(
    host=    os.getenv("SRC_DB_HOST"),
    port =   os.getenv("SRC_DB_PORT"),
    dbname = os.getenv("SRC_DB_NAME"),
    user=    os.getenv("SRC_DB_USER"),
    password=os.getenv("SRC_DB_PASSWORD")
)
DEST_DB_CONFIG = dict(
    host=    os.getenv("DEST_DB_HOST"),
    port =   os.getenv("DEST_DB_PORT"),
    dbname = os.getenv("DEST_DB_NAME"),
    user=    os.getenv("DEST_DB_USER"),
    password=os.getenv("DEST_DB_PASSWORD")
)



def main():
    args = parse_args()
    mode = 'FULL' if args.full_reload else 'INCREMENTAL'
    """
    Extract all dimension data from the source DB and load them into the target DB.
    """
    src_conn = psycopg2.connect(**SOURCE_DB_CONFIG)
    dst_conn = psycopg2.connect(**DEST_DB_CONFIG)
    try:
        if mode == 'FULL':
            with dst_conn.cursor() as cur:
                cur.execute("""
                    TRUNCATE TABLE fact_trips, dim_driver, dim_passenger,
                        dim_location, dim_payment_method, dim_promo_code
                    RESTART IDENTITY CASCADE
                """)
            dst_conn.commit()
            logger.info("Full reload: warehouse truncated")

        time0 = time.time()
        if mode=="INCREMENTAL":
            driver_wateremark=get_watermark(dst_conn,"dim_driver","joined_at")
            driver_data=extract_driver(src_conn,driver_wateremark)

            passenger_watermark=get_watermark(dst_conn,"dim_passenger","created_at")
            passenger_data=extract_passenger(src_conn,passenger_watermark)
        else:
            driver_data = extract_driver(src_conn)
            passenger_data = extract_passenger(src_conn)
        
        load_dim_driver(dst_conn, driver_data)
        load_dim_passenger(dst_conn, passenger_data)

        vehicle_data = extract_vehicle(src_conn)
        load_dim_vehicle(dst_conn, vehicle_data)

        location_data = extract_location(src_conn)
        load_dim_location(dst_conn, location_data)

        payment_method_data = extract_payment_method(src_conn)
        load_dim_payment_method(dst_conn, payment_method_data)

        promo_code_data = extract_promo_code(src_conn)
        load_dim_promo_code(dst_conn, promo_code_data)
        logger.info(f"Dimention table load completed on {time.time() - time0:.2f}s")


        time0 = time.time()
        lookups = extract_lookup_dim(dst_conn)
        logger.info(f"Lookup table extraction completed on {time.time() - time0:.2f}s")

        time0 = time.time()
        if mode == 'INCREMENTAL':
            watermark = get_watermark(dst_conn, "fact_trips", "requested_at")
            rows = extract_trips(src_conn,watermark)
        else:
            rows = extract_trips(src_conn)
        logger.info(f"Trip extraction  completed on {time.time() - time0:.2f}s")

        time0 = time.time()
        fact_rows = transform(rows, lookups)
        logger.info(f"Transformation completed on {time.time() - time0:.2f}s")

        time0 = time.time()
        if fact_rows:
            run_quality_checks(fact_rows)
            logger.info(f"Quality Check completed on {time.time() - time0:.2f}s")
        else:
            logger.info("No new fact rows, skipping quality check.")
        time0 = time.time()
        load_fact_trips(dst_conn, fact_rows)
        logger.info(f"Trip table load completed on {time.time() - time0:.2f}s")
        return len(fact_rows)
    finally:
        src_conn.close()
        dst_conn.close()


if __name__ == "__main__":
    try:
        new_row_count = main()
        label = "new_rows" if new_row_count > 0 else "normal"
        finalize_log(label)
    except DataQualityError as e:
        logger.error(f"Pipeline halted: {e}")
        finalize_log("bad_data")
        raise
    except Exception:
        finalize_log("error")
        raise

