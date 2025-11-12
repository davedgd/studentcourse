# ------------
# Instructions
# ------------

# To run this script, first install the necessary libraries via pip:

# pip install mysql-connector colorama pandas

# Alternatively, in conda/mamba use mysql-connector-python
# Note: you must use 8.4.0 or older with Python 3.12 for password authentication

# mamba install python=3.12 mysql-connector-python=8.4.0 colorama pandas -y

# Next, run this script via python:

# python studentcourse.py

# Note that you may need to change the server settings based on your configuration (see mysql.connector.connect below).

# ----------------
# Import Libraries
# ----------------

from mysql.connector import connect
from colorama import init, Fore, Back, Style
import pandas as pd

init() # for colorama

# -----------------------------
# Define Custom Print Functions
# -----------------------------

def PrintHeading (headingText):
    print(
    Fore.RED + Back.BLUE + Style.BRIGHT +
    "\n" + headingText + "\n" +
    Style.RESET_ALL
    )

def PrintQueryResult (result):
    resultDF = pd.DataFrame(result)

    fieldNames = [i[0] for i in cursor.description]
    resultDF.columns = fieldNames

    print(resultDF)

# -------------
# Connect to DB
# -------------

db = connect(
    database = "studentcourse",
    host = "localhost",
    user = "root",
    passwd = "root"
    )

cursor = db.cursor()

# --------------------
# DBI Command Examples
# --------------------

PrintHeading("List all tables:")
cursor.execute("SHOW TABLES;");
PrintQueryResult(cursor.fetchall())

PrintHeading("Describe (a MySQL keyword) student table:")
cursor.execute("DESCRIBE student;");
PrintQueryResult(cursor.fetchall())

# ---------------
# Running Queries
# ---------------

PrintHeading("Return an Entire Table:")
cursor.execute("SELECT * FROM student;");
PrintQueryResult(cursor.fetchall())

PrintHeading("Group By and Having:")
cursor.execute("SELECT studentid, COUNT(courseid) FROM takes WHERE courseid != 3100 GROUP BY studentid HAVING COUNT(courseid) > 2;");
PrintQueryResult(cursor.fetchall())

PrintHeading("Joining Multiple Tables at Once:")
cursor.execute("SELECT * FROM student NATURAL JOIN major NATURAL JOIN takes NATURAL JOIN course;");
PrintQueryResult(cursor.fetchall())

# ------------------
# Disconnect from DB
# ------------------

db.close()
