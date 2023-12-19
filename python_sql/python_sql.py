#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Dec 12 22:42:40 2023

@author: antony
"""

# Set the working directory
new_wd = "/Users/antony/Desktop/UoL/Programming for Data Science/st2195_assignment_3/r_sql"

# Import necessary libraries
import sqlite3
import pandas as pd

# Connect to the SQLite database
conn = sqlite3.connect("airline2.db")
c = conn.cursor()


# Query 1: Count the number of cancelled flights for specific airlines
q1 = c.execute('''
               SELECT carriers.Description, COUNT(*) AS cancelled_flights
               FROM carriers JOIN ontime ON (carriers.Code = ontime.UniqueCarrier)
               WHERE Cancelled > 0 AND Description IN ('United Air Lines Inc.', 'American Airlines Inc.', 'Pinnacle Airlines Inc.', 'Delta Air Lines Inc.')
               GROUP BY Description
               ORDER BY cancelled_flights DESC
               ''').fetchall()

df = pd.DataFrame(q1, columns=['Description', "# of Cancelled Flights"])
df.to_csv('Q1 Result.csv', index=False)


# Query 2: Calculate the average departure delay for specific plane models
q2 = c.execute('''
               SELECT planes.model,  AVG(DepDelay) AS avg_DepDelay
               FROM planes JOIN ontime USING(tailnum)
               WHERE ontime.DepDelay > 0 AND (Cancelled = 0 AND Diverted = 0) AND model IN ('737-230', 'ERJ 190-100 IGW', 'A330-223', '737-282')
               GROUP BY model
               ORDER BY avg_DepDelay
               ''').fetchall()

df = pd.DataFrame(q2, columns=['Model', "Average Delay"])
df.to_csv('Q2 Result.csv', index=False)


# Query 3: Count the number of cancelled flights for specific airlines (same as Query 1)
q3 = c.execute('''
               SELECT carriers.Description, COUNT(*) AS cancelled_flights
               FROM carriers JOIN ontime ON (carriers.Code = ontime.UniqueCarrier)
               WHERE Cancelled > 0 AND Description IN ('United Air Lines Inc.', 'American Airlines Inc.', 'Pinnacle Airlines Inc.', 'Delta Air Lines Inc.')
               GROUP BY Description
               ORDER BY cancelled_flights DESC
               ''').fetchall()

df = pd.DataFrame(q3, columns=['City', "# of Inbound Flights"])
df.to_csv('Q3 Result.csv', index=False)

# Query 4: Calculate the cancellation rate for specific airlines
q4 = c.execute('''
               SELECT q1.Description, CAST(q1.numerator AS float)/CAST(q2.denominator AS float) AS rate
               FROM
               (
                   SELECT carriers.Description, COUNT(*) AS numerator
                   FROM carriers JOIN ontime ON (carriers.Code = ontime.UniqueCarrier)
                   WHERE Cancelled > 0 AND Description IN ('United Air Lines Inc.', 'American Airlines Inc.', 'Pinnacle Airlines Inc.', 'Delta Air Lines Inc.')
                   GROUP BY Description
               ) AS q1 JOIN
               (
                   SELECT carriers.Description, COUNT(*) AS denominator
                   FROM carriers JOIN ontime ON (carriers.Code = ontime.UniqueCarrier)
                   WHERE Cancelled = 0 AND Description IN ('United Air Lines Inc.', 'American Airlines Inc.', 'Pinnacle Airlines Inc.', 'Delta Air Lines Inc.')
                   GROUP BY Description
               ) AS q2
               ON q1.Description = q2.Description
               ORDER BY rate DESC
               ''').fetchall()

df = pd.DataFrame(q4, columns=['City', "# of Inbound Flights"])
df.to_csv('Q4 Result.csv', index=False)

