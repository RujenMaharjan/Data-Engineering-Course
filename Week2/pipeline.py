"""
pipeline.py
-----------
Runs all migration files in Week2/migrations/ in sequential order.
Each file is executed in its own transaction — if one fails the
pipeline stops and rolls back that step.
"""

import os
import psycopg2
from dotenv import load_dotenv

load_dotenv()

MIGRATIONS_DIR = os.path.join(os.path.dirname(__file__), "migrations")


def get_connection():
    return psycopg2.connect(
        host=os.getenv("DB_HOST"),
        port=os.getenv("DB_PORT"),
        dbname=os.getenv("DB_NAME"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD"),
    )


def run_migrations(conn):
    migration_files = sorted(
        f for f in os.listdir(MIGRATIONS_DIR) if f.endswith(".sql")
    )

    if not migration_files:
        print("No migration files found.")
        return

    for filename in migration_files:
        filepath = os.path.join(MIGRATIONS_DIR, filename)
        print(f"Running: {filename} ...", end=" ")

        with open(filepath, "r", encoding="utf-8") as f:
            sql = f.read()

        try:
            with conn.cursor() as cur:
                cur.execute(sql)
            conn.commit()
            print("OK")
        except psycopg2.Error as e:
            conn.rollback()
            print(f"FAILED\n  Error: {e}")
            raise SystemExit(1)


def main():
    try:
        conn = get_connection()
    except psycopg2.Error as e:
        print(f"Could not connect to database: {e}")
        raise SystemExit(1)

    print("Starting migration pipeline...\n")
    run_migrations(conn)
    print("\nAll migrations completed successfully.")
    conn.close()


if __name__ == "__main__":
    main()
