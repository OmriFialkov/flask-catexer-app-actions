from flask import Flask, request, jsonify, render_template
import os
import random
import pymysql
from prometheus_client import Gauge, generate_latest, CONTENT_TYPE_LATEST


app = Flask(__name__)

# Connect to the MySQL database with pymysql
def get_db_connection():
    return pymysql.connect(
        host=os.getenv("MYSQL_HOST"),
        user=os.getenv("MYSQL_USER"),
        password=os.getenv("MYSQL_PASSWORD"),
        database=os.getenv("MYSQL_DATABASE")
    )

visitor_count_gauge = Gauge('flask_app_visitor_count', 'Current number of visitors')
@app.route("/")
def index():
    try:
        # Connect to DB.
        connection = get_db_connection()
        cursor = connection.cursor()

        # Increment counter
        cursor.execute("UPDATE visitor_counter SET count = count + 1 WHERE id = 1")
        connection.commit()

        # Fetch updated count
        cursor.execute("SELECT count FROM visitor_counter WHERE id = 1")
        visitor_count = cursor.fetchone()[0]

        # Fetch image URLs
        cursor.execute("SELECT image_url FROM images")
        result = cursor.fetchall()
        connection.close()

        # Transform the result into a list of URLs
        images = [row[0] for row in result]

        # Pick a random image
        url = random.choice(images) if images else None
    except Exception as e:
        print(f"Error: {e}")  # Log the error for debugging
        visitor_count = "unknown"
        url = None

    # Fallback rendering
    if url:
        return render_template("index.html", url=url, visitor_count=visitor_count)
    else:
        return render_template("index.html", url=None, visitor_count=visitor_count, message="No images available.")
    



@app.route('/metrics')
def metrics():
    try:
        connection = get_db_connection()
        cursor = connection.cursor()

        # Fetch the latest visitor count
        cursor.execute("SELECT count FROM visitor_counter WHERE id = 1")
        visitor_count = cursor.fetchone()[0]
        connection.close()

        # Update the Prometheus gauge with the latest visitor count
        visitor_count_gauge.set(visitor_count)
    except Exception as e:
        print(f"Error fetching visitor count: {e}")  # Log error

    # Return all metrics in Prometheus format
    return generate_latest(), 200, {'Content-Type': CONTENT_TYPE_LATEST}



if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.getenv("PORT", 5000)))
