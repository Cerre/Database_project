from bottle import get, post, run, request, response
import sqlite3
import json


HOST = 'localhost'
PORT = 8888

conn = sqlite3.connect("db.sqlite")

def url(resource):
    return f"http://{HOST}:{PORT}{resource}"

def format_response(d):
    return json.dumps(d, indent=4) + "\n"

@get('/ping')
def get_ping():
    return "pong"

@post('/reset')
def post_reset():
    f = open('database.sql')
    query = f.read() 
    f.close()
    c = conn.cursor()
    c.executescript(query)
    response.status = 200
    return json.dumps({"status" : "ok"}, indent=4)

@get('/customers')
def get_customers():
    c = conn.cursor()
    c.execute(
        """
        SELECT customer_name, address
        FROM   customers
        """
    )
    s = [{"name": customer_name, "address": address}
         for (customer_name, address) in c]
    return json.dumps({"customers": s}, indent=4)

@get('/ingredients')
def get_ingredients():
    c = conn.cursor()
    c.execute(
        """
        SELECT ingredient_name, sum(quantity) AS tot_quantity, unit
        FROM   ingredient_transitions
        JOIN   ingredients
        USING  (ingredient_name)
        GROUP BY ingredient_name
        """
    )
    s = [{"name": ingredient_name, "quantity": tot_quantity, "unit": unit}
         for (ingredient_name, tot_quantity, unit) in c]
    return json.dumps({"ingredients": s}, indent=4)


@get('/cookies')
def get_cookies():
    c = conn.cursor()
    c.execute(
        """
        SELECT cookie_name
        FROM   cookies
        ORDER BY cookie_name
        """
    )
    s = [{"name": cookie_name[0]} for cookie_name in c] 
    return json.dumps({"cookies": s}, indent=4)

@get('/recipes')
def get_recipes():
    c = conn.cursor()
    c.execute(
        """
        SELECT cookie_name, ingredient_name, amount, unit
        FROM   recipes
        JOIN   ingredients
        USING  (ingredient_name)
        ORDER BY cookie_name, ingredient_name
        """
    )
    s = [{"cookie": cookie_name, "ingredient": ingredient_name, "amount": amount, "unit": unit} 
    for (cookie_name, ingredient_name, amount, unit) in c] 
    return json.dumps({"recipes": s}, indent=4)

@post('/pallets')
def post_pallets():
    response.content_type = 'database/json'
    cookie = request.query.cookie
    if not (cookie):
        response.status = 400
        return format_response({"error": "Missing parameter"})
    c = conn.cursor() 
    c.execute(
      """
      SELECT cookie_name 
      FROM   cookies
      WHERE  cookie_name = ?
      """,  
      [cookie]
    ) 
    if len(c.fetchall()) == 0:
        response.status = 400
        return json.dumps({"status": "no such cookie"}, indent=4)

    try: 
        c.execute(
            """
            INSERT
            INTO   pallets(cookie_name)
            VALUES (?)
            """,
            [cookie]
        )
        conn.commit()
        c.execute(
            """
            SELECT   bar_code
            FROM     pallets
            WHERE    rowid = last_insert_rowid()
            """
        )
        id = c.fetchone()[0]
        response.status = 200
        return json.dumps({"status" : "ok", "id" : id}, indent=4)
    except:
        return json.dumps({"status": "not enough ingredients"}, indent=4)

@get('/pallets')
def get_pallets():
    response.content_type = 'database/json'
    query = """
        SELECT bar_code, cookie_name, prod_date, customer_name, blocked
        FROM   pallets
        LEFT JOIN   orders
        USING  (order_id)
        WHERE  1 = 1
        """
    params = []
    if request.query.after:
        query += "AND prod_date > ?"
        params.append(request.query.after)
    if request.query.before:
        query += "AND prod_date < ?"
        params.append(request.query.before)
    if request.query.cookie:
        query += "AND cookie_name = ?"
        params.append(request.query.cookie)
    if request.query.blocked:
        query += "AND blocked = ?"
        params.append(request.query.blocked)
    c = conn.cursor()
    c.execute(
        query,
        params
    )
    s = [{"bar_code": bar_code, "cookie": cookie_name, "prod_date": prod_date, "customer": customer_name, "blocked": blocked}
         for (bar_code, cookie_name, prod_date, customer_name, blocked) in c]

    response.status = 200
    return json.dumps({"pallets": s}, indent=4)

@post('/block/<cookie_name>/<from_date>/<to_date>')
def post_block(cookie_name, from_date, to_date):
    response.content_type = 'theater/json'
    c = conn.cursor()
    c.execute(
        """
        UPDATE pallets
        SET    blocked = 1
        WHERE  cookie_name = ? AND prod_date >= ? AND prod_date <= ?
        """,
        [cookie_name, from_date, to_date]
    )
    response.status = 200
    return json.dumps({"status" : "ok"}, indent=4)

@post('/unblock/<cookie_name>/<from_date>/<to_date>')
def post_unblock(cookie_name, from_date, to_date):
    response.content_type = 'theater/json'
    c = conn.cursor()
    c.execute(
        """
        UPDATE pallets
        SET    blocked = 0
        WHERE  cookie_name = ? AND prod_date > ? AND prod_date < ?
        """,
        [cookie_name, from_date, to_date]
    )
    response.status = 200
    return json.dumps({"status" : "ok"}, indent=4)

run(host=HOST, port=PORT, debug=True)