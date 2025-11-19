import json
import os
import pymysql
import boto3

# Global connection reused between Lambda invocations
CONN = None

# --- Secrets Manager: Fetch DB Creds ---
def get_db_credentials():
    secret_name = os.environ.get("DB_SECRET_NAME")

    if not secret_name:
        raise Exception("Environment variable DB_SECRET_NAME not set")

    region = os.environ.get("AWS_REGION", "us-east-1")
    client = boto3.client("secretsmanager", region_name=region)

    response = client.get_secret_value(SecretId=secret_name)
    secrets = json.loads(response["SecretString"])

    return secrets

# --- API Gateway Response Helper ---
def build_response(status_code, body=None):
    return {
        "statusCode": status_code,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
        },
        "body": json.dumps(body) if body else "{}"
    }

# --- CRUD Operations ---
def create_todo(data, conn):
    title = data.get("title")
    description = data.get("description")
    completed = data.get("completed", 0)

    if not title:
        return build_response(400, {"error": "Title is required"})

    sql = "INSERT INTO todos (title, description, completed) VALUES (%s, %s, %s)"
    with conn.cursor() as cursor:
        cursor.execute(sql, (title, description, completed))
        conn.commit()
        todo_id = cursor.lastrowid

    return build_response(201, {"id": todo_id, "message": "Todo created successfully"})


def get_todos(todo_id, conn):
    with conn.cursor() as cursor:
        if todo_id:
            sql = "SELECT id, title, description, completed FROM todos WHERE id = %s"
            cursor.execute(sql, (todo_id,))
            result = cursor.fetchone()

            if result:
                return build_response(200, result)
            return build_response(404, {"error": f"Todo with ID {todo_id} not found"})

        else:
            sql = "SELECT id, title, description, completed FROM todos ORDER BY id DESC"
            cursor.execute(sql)
            results = cursor.fetchall()
            return build_response(200, results)


def update_todo(todo_id, data, conn):
    if not todo_id:
        return build_response(400, {"error": "Todo ID is required"})

    updates = []
    params = []

    if "title" in data:
        updates.append("title = %s")
        params.append(data["title"])

    if "description" in data:
        updates.append("description = %s")
        params.append(data["description"])

    if "completed" in data:
        updates.append("completed = %s")
        params.append(data["completed"])

    if not updates:
        return build_response(400, {"error": "No fields provided to update"})

    sql = f"UPDATE todos SET {', '.join(updates)} WHERE id = %s"
    params.append(todo_id)

    with conn.cursor() as cursor:
        cursor.execute(sql, tuple(params))
        conn.commit()

        if cursor.rowcount == 0:
            return build_response(404, {"error": f"Todo with ID {todo_id} not found"})

    return build_response(200, {"message": f"Todo {todo_id} updated successfully"})


def delete_todo(todo_id, conn):
    if not todo_id:
        return build_response(400, {"error": "Todo ID is required"})

    sql = "DELETE FROM todos WHERE id = %s"
    with conn.cursor() as cursor:
        cursor.execute(sql, (todo_id,))
        conn.commit()

        if cursor.rowcount == 0:
            return build_response(404, {"error": f"Todo with ID {todo_id} not found"})

    return build_response(204)


# --- MAIN LAMBDA HANDLER ---
def lambda_handler(event, context):
    global CONN

    # --- Ensure DB Connection exists ---
    if CONN is None:
        print("Creating new MySQL connection...")
        creds = get_db_credentials()

        CONN = pymysql.connect(
            host=creds["host"],
            user=creds["username"],
            passwd=creds["password"],
            db=creds["dbname"],
            connect_timeout=5,
            cursorclass=pymysql.cursors.DictCursor
        )

    http_method = event.get("httpMethod")
    path = event.get("path")

    # Extract ID from /todos/{id}
    path_parts = path.strip("/").split("/")
    todo_id = int(path_parts[-1]) if len(path_parts) == 2 and path_parts[-1].isdigit() else None

    # Parse JSON body
    body_data = {}
    if event.get("body"):
        try:
            body_data = json.loads(event["body"])
        except json.JSONDecodeError:
            return build_response(400, {"error": "Invalid JSON format"})

    try:
        # Routes
        if http_method == "POST" and path == "/todos":
            return create_todo(body_data, CONN)

        elif http_method == "GET" and path == "/todos":
            return get_todos(None, CONN)

        elif http_method == "GET" and todo_id:
            return get_todos(todo_id, CONN)

        elif http_method == "PUT" and todo_id:
            return update_todo(todo_id, body_data, CONN)

        elif http_method == "DELETE" and todo_id:
            return delete_todo(todo_id, CONN)

        else:
            return build_response(405, {"error": "Method not allowed"})
    except Exception as e:
        print("ERROR:", e)
        return build_response(500, {"error": "Internal Server Error", "details": str(e)})
