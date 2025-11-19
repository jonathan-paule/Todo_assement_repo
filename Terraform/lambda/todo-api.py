import json
import os
import boto3
import pymysql

# ---------------------------
# Load Secrets from Secrets Manager
# ---------------------------
def get_db_credentials():
    """Fetch DB credentials from AWS Secrets Manager."""
    secret_name = os.environ.get("DB_SECRET_NAME")
    if not secret_name:
        raise Exception("Environment variable DB_SECRET_NAME not set")

    client = boto3.client("secretsmanager")
    try:
        response = client.get_secret_value(SecretId=secret_name)
        secret = json.loads(response["SecretString"])
        return secret
    except Exception as e:
        print(f"ERROR: Unable to fetch DB credentials: {e}")
        raise e

# ---------------------------
# Initialize MySQL Connection (Cold Start)
# ---------------------------
try:
    creds = get_db_credentials()
    CONN = pymysql.connect(
        host=creds["host"],
        user=creds["username"],
        passwd=creds["password"],
        db=creds["dbname"],
        port=int(creds.get("port", 3306)),
        connect_timeout=5,
        cursorclass=pymysql.cursors.DictCursor
    )
    print("Connected to MySQL database")
except pymysql.MySQLError as e:
    print(f"ERROR: Could not connect to MySQL: {e}")
    CONN = None

# ---------------------------
# Helper Functions
# ---------------------------
def build_response(status_code, body=None):
    return {
        'statusCode': status_code,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'  # CORS
        },
        'body': json.dumps(body) if body is not None else '{}'
    }

# CRUD Operations
def create_todo(data):
    title = data.get('title')
    description = data.get('description', '')
    completed = data.get('completed', 0)

    if not title:
        return build_response(400, {"error": "Title is required"})

    sql = "INSERT INTO todos (title, description, completed) VALUES (%s, %s, %s)"
    with CONN.cursor() as cursor:
        cursor.execute(sql, (title, description, completed))
        CONN.commit()
        todo_id = cursor.lastrowid

    return build_response(201, {"id": todo_id, "message": "Todo created successfully"})

def get_todos(todo_id=None):
    with CONN.cursor() as cursor:
        if todo_id:
            sql = "SELECT id, title, description, completed FROM todos WHERE id=%s"
            cursor.execute(sql, (todo_id,))
            result = cursor.fetchone()
            if result:
                return build_response(200, result)
            return build_response(404, {"error": f"Todo with id {todo_id} not found"})
        else:
            sql = "SELECT id, title, description, completed FROM todos ORDER BY id DESC"
            cursor.execute(sql)
            results = cursor.fetchall()
            return build_response(200, results)

def update_todo(todo_id, data):
    if not todo_id:
        return build_response(400, {"error": "Todo ID is required for update"})

    updates = []
    params = []
    for key in ['title', 'description', 'completed']:
        if key in data:
            updates.append(f"{key}=%s")
            params.append(data[key])

    if not updates:
        return build_response(400, {"error": "No fields provided for update"})

    params.append(todo_id)
    sql = f"UPDATE todos SET {', '.join(updates)} WHERE id=%s"

    with CONN.cursor() as cursor:
        cursor.execute(sql, tuple(params))
        CONN.commit()
        if cursor.rowcount == 0:
            return build_response(404, {"error": f"Todo with id {todo_id} not found or no change made"})

    return build_response(200, {"message": f"Todo with id {todo_id} updated successfully"})

def delete_todo(todo_id):
    if not todo_id:
        return build_response(400, {"error": "Todo ID is required for delete"})

    sql = "DELETE FROM todos WHERE id=%s"
    with CONN.cursor() as cursor:
        cursor.execute(sql, (todo_id,))
        CONN.commit()
        if cursor.rowcount == 0:
            return build_response(404, {"error": f"Todo with id {todo_id} not found"})

    return build_response(204)

# ---------------------------
# Lambda Handler
# ---------------------------
def lambda_handler(event, context):
    if CONN is None:
        return build_response(500, {"error": "Database connection failed"})

    http_method = event.get("httpMethod")
    path = event.get("path", "").strip("/")
    path_parts = path.split("/")

    action = path_parts[1] if len(path_parts) > 1 else None
    todo_id = int(path_parts[2]) if len(path_parts) > 2 and path_parts[2].isdigit() else None

    # Parse body safely
    body_data = {}
    if event.get("body"):
        try:
            body_data = json.loads(event["body"])
        except json.JSONDecodeError:
            return build_response(400, {"error": "Invalid JSON body"})

    try:
        # Routing based on HTTP method and action
        if http_method == "POST" and action == "create":
            return create_todo(body_data)
        elif http_method == "GET" and action == "get":
            return get_todos(todo_id)
        elif http_method == "PUT" and action == "update":
            return update_todo(todo_id, body_data)
        elif http_method == "DELETE" and action == "delete":
            return delete_todo(todo_id)
        else:
            return build_response(405, {"error": "Method Not Allowed or Invalid Path"})
    except Exception as e:
        print(f"Unhandled error: {e}")
        return build_response(500, {"error": "Internal Server Error", "details": str(e)})
