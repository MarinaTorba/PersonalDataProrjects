import os
import re
import pandas as pd
from dotenv import load_dotenv, find_dotenv
import mysql.connector
from mysql.connector import Error

def get_latest_table(config):
    
    """
    Input: config - dict, configuration for MySQL connection
    Connects to MySQL and retrieves the latest table 
    based on date in the name.
    Output:
    - str: The latest table name
    - pd.DataFrame: DataFrame of the latest table
    """
    try:
        cnx = mysql.connector.connect(**config)
        cursor = cnx.cursor(dictionary=True)

        cursor.execute('SHOW TABLES;')
        tables = [list(row.values())[0] for row in cursor.fetchall()]

        # table names ending with exactly 8 digits
        date_pattern = re.compile(r'(\d{8})$')
        # find the latest table
        latest_table = max(tables, key=lambda x: date_pattern.findall(x))
        
        query = f"SELECT * FROM {latest_table}"
        cursor.execute(query)
        records = cursor.fetchall()
        print(f"Total rows in table {latest_table}: {cursor.rowcount}")
        
        df = pd.DataFrame(records)
        return latest_table, df

    except mysql.connector.Error as error:
        print(f"Failed to fetch data: {error}")
        return None, None

    finally:
        if cnx.is_connected():
            cursor.close()
            cnx.close()
            print("MySQL connection closed")