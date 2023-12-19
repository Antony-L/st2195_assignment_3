# Load the necessary libraries
library(DBI)
library(dplyr)
library(readr)

setwd("/Users/antony/Downloads/archive")

db_path <- "/Users/antony/Desktop/UoL/Programming for Data Science/st2195_assignment_3/airline2.db"

tables_data <- list(
  ontime = list("2000.csv", "2001.csv",
                "2002.csv", "2003.csv",
                "2004.csv", "2005.csv"),
  airports = "airports.csv",
  carriers = "carriers.csv",
  planes = "plane-data.csv")

load_data <- function(db_path, tables_data) {
  # Establish connection to the SQLite database
  db_conn <- dbConnect(RSQLite::SQLite(), dbname = db_path)
  
  # Iterate over the tables_data and load each table with csv data
  for (table_name in names(tables_data)) {
    csv_files <- tables_data[[table_name]]
    
    # Check if csv_files is a list (case 'ontime' table)
    if (is.list(csv_files)) {
      for (csv_file in csv_files) {
        load_table(csv_file, table_name, db_conn)
      }
    } else {
      load_table(csv_files, table_name, db_conn)
    }
    cat("Data loaded into", table_name, "table\n")
  }
  
  # Close the database connection
  #dbDisconnect(db_conn)
}

load_table <- function(csv_file, table_name, db_connection) {
  cat("Processing", csv_file, "\n")
  # show_col_types = FALSE suppress column specification messages
  data <- read_csv(csv_file, show_col_types = FALSE)
  
  # Load data into SQLite
  dbWriteTable(db_connection, table_name, data, append = TRUE)
}


load_data(db_path, tables_data)
  
  

--------------------------------------------------------------------------------

# Quiz Queries
  
# Connect to the SQLite database named "airline2.db"
conn <- dbConnect(RSQLite::SQLite(), dbname = db_path)


# Create tbl objects that map to the tables in the SQLite database
ontime_db <- tbl(conn, "ontime")
airports_db <- tbl(conn, "airports")
carriers_db <- tbl(conn, "carriers")
planes_db <- tbl(conn, "planes")


# Question 1: Which of the following companies has the highest number of cancelled flights?
q1 <- inner_join(ontime_db, carriers_db, by = c("UniqueCarrier" = "Code")) %>%
  filter(Cancelled == 1, 
         Description %in% c('United Air Lines Inc.', 'American Airlines Inc.', 'Pinnacle Airlines Inc.', 'Delta Air Lines Inc.')) %>%
  group_by(Description) %>%
  summarise(cancelled_flights = n()) %>%
  arrange(desc(cancelled_flights)) %>%
  distinct()

write.csv(q1, "Q1 Result.csv", row.names = TRUE)


# Question 2: Which of the following airplanes has the lowest associated average departure delay (excluding cancelled and diverted flights)?
q2 <- inner_join(planes_db, ontime_db, by = c('tailnum' = 'TailNum')) %>%
  filter(Cancelled == 0, 
         Diverted == 0, 
         DepDelay > 0, 
         model %in% c('737-230', 'ERJ 190-100 IGW', 'A330-223', '737-282')) %>%
  group_by(model) %>%
  summarise(avg_dep_delay = mean(DepDelay)) %>%
  arrange(avg_dep_delay)

write.csv(q2, "Q2 Results.csv", row.names = TRUE)


# Question 3: Which of the following cities has the highest number of inbound flights (excluding cancelled flights)?
q3 <- inner_join(ontime_db, airports_db, by = c('Origin' = 'iata')) %>%
  filter(Cancelled == 0, 
         city %in% c('Chicago', 'Atlanta', 'New York', 'Houston')) %>%
  group_by(city) %>%
  summarise(inbound_flights = n()) %>%
  arrange(desc(inbound_flights)) %>%
  distinct()

write.csv(q3, "Q3 Results.csv", row.names = TRUE)

# Question 4: Which of the following companies has the highest number of cancelled flights, relative to their number of total flights?
n_cancelled <- inner_join(ontime_db, carriers_db, by = c("UniqueCarrier" = "Code")) %>%
  filter(Cancelled == 1, 
         Description %in% c('United Air Lines Inc.', 'American Airlines Inc.', 'Pinnacle Airlines Inc.', 'Delta Air Lines Inc.')) %>%
  group_by(Description) %>%
  summarise(cancelled_flights = n())

n_total <- inner_join(ontime_db, carriers_db, by = c("UniqueCarrier" = "Code")) %>%
  filter(Description %in% c('United Air Lines Inc.', 'American Airlines Inc.', 'Pinnacle Airlines Inc.', 'Delta Air Lines Inc.')) %>%
  group_by(Description) %>%
  summarise(total_flights = n())

q4 <- inner_join(n_cancelled, n_total, by = "Description") %>%
  mutate(cancelled_ratio = as.numeric(cancelled_flights) / as.numeric(total_flights)) %>%
  select(Description, cancelled_ratio) %>%
  arrange(desc(cancelled_ratio)) %>%  
  distinct()

write.csv(q4, "Q4 Results.csv", row.names = TRUE)

dbDisconnect(conn)