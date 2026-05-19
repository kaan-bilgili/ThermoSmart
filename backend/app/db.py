import os
from dotenv import load_dotenv
from psycopg import connect
from psycopg.rows import dict_row

load_dotenv()

DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = os.getenv("DB_PORT", "5432")
DB_NAME = os.getenv("DB_NAME", "thermostat_db")
DB_USER = os.getenv("DB_USER", "postgres")
DB_PASSWORD = os.getenv("DB_PASSWORD", "")


def get_db_connection():
    return connect(
        host=DB_HOST,
        port=DB_PORT,
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD,
        row_factory=dict_row
    )


# ---------------------------
# READINGS TABLE FUNCTIONS
# ---------------------------

def insert_reading(temp, humidity, setpoint=None):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO readings (temp, humidity, setpoint)
                VALUES (%s, %s, %s)
                RETURNING *;
                """,
                (temp, humidity, setpoint)
            )
            result = cur.fetchone()
        conn.commit()
    return result


def get_latest_reading():
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT * FROM readings
                ORDER BY timestamp DESC
                LIMIT 1;
                """
            )
            return cur.fetchone()


def get_all_readings(limit=50):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT * FROM readings
                ORDER BY timestamp DESC
                LIMIT %s;
                """,
                (limit,)
            )
            return cur.fetchall()


# ---------------------------
# RELAY LOGS TABLE FUNCTIONS
# ---------------------------

def insert_relay_log(state, triggered_by):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO relay_logs (state, triggered_by)
                VALUES (%s, %s)
                RETURNING *;
                """,
                (state, triggered_by)
            )
            result = cur.fetchone()
        conn.commit()
    return result


def get_relay_logs(limit=50):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT * FROM relay_logs
                ORDER BY timestamp DESC
                LIMIT %s;
                """,
                (limit,)
            )
            return cur.fetchall()

