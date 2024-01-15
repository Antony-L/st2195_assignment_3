# ST2195 Assignment 3

This repository contains the third assignment for the ST2195 course. The assignment involves working with the Data Expo 2009 data from the Harvard Dataverse and constructing an SQLite Database called `airline2.db` with the following tables:

1.  `ontime` (with the data from 2000 to 2005 -- including 2000 and 2005)
2.  `airports` (with the data in `airports.csv`)
3.  `carriers` (with the data in `carriers.csv`)
4.  `planes` (with the data in `plane-data.csv`)

The Data Expo 2009 data can be found [here](https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi%3A10.7910%2FDVN%2FHG7NV7).

## R and Python Scripts

The `r_sql` folder contains R code for constructing the database from the CSV inputs and replicating the queries in the practice quiz. The queries are performed using both DBI and dplyr notation.

The `python_sql` folder contains a Python version of the code in the `r_sql` folder, based on sqlite3.

Both the R and Python scripts save the output of the queries in CSV within their respective folders.

## Note

The database file is not placed in the GitHub repository due to its large size.

## Simplified Solution

A simplified solution for the query in Q4 is provided in R placed in the `r_sql` folder.
