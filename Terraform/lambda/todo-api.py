import json
import boto3
import psycopg2
import os

# ---------------------------
# Load Secrets
# ---------------------------
secrets_client = boto3.client("secretsmanager")
SECRET_NAME = os.environ.get("DB_SECRET_NAME", "todoapp/db_credentials")
cached_secret = None   # Cache to avoid repeated Secrets Manager calls

def get_db_credentials():
    """Fetch DB credentials from Secrets Manager (cached)."""
    global cached_secret
    if cached_secret:
        return cached_secret

    try:
        response = secrets_client.get_secret_value(SecretId=SECRET_NAME)
        secret_string = response["SecretString"]
        cached_secret = json.loads(secret_string)
        return cached_secret
    except Exception as e:
        print(f"ERROR: Unable to load DB credentials: {e}")
        raise e

# ---------------------------
# PostgreSQL Connection
# ---------------------------
conn = None

def get_db_connection():
    """Establish a DB connection using cached credentials."""
    global conn
    if conn is None or conn.closed:
        creds = get_db_credentials()
        try:
            conn = psycopg2.connect(
                host=creds["host"],
                database=creds["dbname"],
                user=creds["username"],
                password=creds["password"],
                port=creds.get("port", "5432"),
                connect_timeout=5
            )
            conn.autocommit = True
            print("Connected to PostgreSQL.")
        except Exception as e:
            print(f"Database Connection Failed: {e}")
            raise e
    return conn

# ---------------------------
# Helper Functions
# ---------------------------
def format_todo(row, cursor):
    col_names = [desc[0] for desc in cursor.description]
    return dict(zip(col_names, row))

def safe_json_parse(body):
    """Safely parse JSON from Lambda event body."""
    try:
        return json.loads(body or '{}')
    except json.JSONDecodeError:
        return None

# ---------------------------
# Lambda Handler
# ---------------------------
def lambda_handler(event, context):
    print("EVENT:", json.dumps(event))  # Debug: see incoming event

    # HTTP API v2 mapping
    method = event['requestContext']['http']['method']
    path = event['requestContext']['http']['path']
    path_parameters = event.get('pathParameters')
    todo_id = path_parameters.get('id') if path_parameters else None

    headers = {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
    }

    try:
        conn = get_db_connection()
        cur = conn.cursor()

        # --------------------------
        # CREATE (POST /todos)
        # --------------------------
        if method == 'POST' and path == '/todos':
            body = safe_json_parse(event.get('body'))
            if body is None:
                return {'statusCode': 400, 'headers': headers,
                        'body': json.dumps({'message': 'Invalid JSON'})}

            title = body.get('title')
            description = body.get('description', '')
            completed = body.get('completed', False)

            if not title:
                return {'statusCode': 400, 'headers': headers,
                        'body': json.dumps({'message': 'Title is required'})}

            cur.execute("""
                INSERT INTO todos (title, description, completed)
                VALUES (%s, %s, %s)
                RETURNING *;
            """, (title, description, completed))

            new_todo = format_todo(cur.fetchone(), cur)
            return {'statusCode': 201, 'headers': headers, 'body': json.dumps(new_todo)}

        # --------------------------
        # LIST (GET /todos)
        # --------------------------
        elif method == 'GET' and path == '/todos' and not todo_id:
            cur.execute("SELECT * FROM todos ORDER BY created_at DESC")
            todos = [format_todo(row, cur) for row in cur.fetchall()]
            return {'statusCode': 200, 'headers': headers, 'body': json.dumps(todos)}

        # --------------------------
        # READ (GET /todos/{id})
        # --------------------------
        elif method == 'GET' and todo_id:
            cur.execute("SELECT * FROM todos WHERE id = %s", (todo_id,))
            row = cur.fetchone()
            if row:
                return {'statusCode': 200, 'headers': headers,
                        'body': json.dumps(format_todo(row, cur))}
            else:
                return {'statusCode': 404, 'headers': headers,
                        'body': json.dumps({'message': 'Todo not found'})}

        # --------------------------
        # UPDATE (PUT /todos/{id})
        # --------------------------
        elif method == 'PUT' and todo_id:
            body = safe_json_parse(event.get('body'))
            if body is None:
                return {'statusCode': 400, 'headers': headers,
                        'body': json.dumps({'message': 'Invalid JSON'})}

            updates = []
            values = []

            for key in ['title', 'description', 'completed']:
                if key in body:
                    updates.append(f"{key} = %s")
                    values.append(body[key])

            if not updates:
                return {'statusCode': 400, 'headers': headers,
                        'body': json.dumps({'message': 'No fields to update'})}

            values.append(todo_id)
            query = f"UPDATE todos SET {', '.join(updates)} WHERE id = %s RETURNING *"
            cur.execute(query, tuple(values))
            row = cur.fetchone()

            if row:
                return {'statusCode': 200, 'headers': headers,
                        'body': json.dumps(format_todo(row, cur))}
            else:
                return {'statusCode': 404, 'headers': headers,
                        'body': json.dumps({'message': 'Todo not found'})}

        # --------------------------
        # DELETE (DELETE /todos/{id})
        # --------------------------
        elif method == 'DELETE' and todo_id:
            cur.execute("DELETE FROM todos WHERE id = %s", (todo_id,))
            if cur.rowcount > 0:
                return {'statusCode': 204, 'headers': headers, 'body': ''}
            else:
                return {'statusCode': 404, 'headers': headers,
                        'body': json.dumps({'message': 'Todo not found'})}

        else:
            return {'statusCode': 404, 'headers': headers,
                    'body': json.dumps({'message': 'Resource not found'})}

    except Exception as e:
        print(f"Unhandled Error: {e}")
        return {'statusCode': 500, 'headers': headers,
                'body': json.dumps({'message': 'Internal Server Error', 'error': str(e)})}
    finally:
        if 'cur' in locals() and cur:
            cur.close()
