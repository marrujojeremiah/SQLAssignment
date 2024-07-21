# Movie Rental Database Project

This project was created as part of a school assignment to manage a movie rental database. The SQL code provided here includes functions, triggers, and procedures to create, update, and refresh detailed and summary tables.

Business Summary:
This project is about a DVD rental business that needs profit assessment. The chief financial officer needs a report on which store has been the most profitable over its lifetime. With the ability to refresh the data, quarterly. A summary of each stores profits can make his job a lot easier. This will aid in better understanding where they first need to focus their efforts and what could be potentially hurting the stores profits. This report will provide the data needed to aid in better profits in the future. Lastly, it can help evaluate whether a store is worth keeping or closing for a new location. A lifetime profits report can aid in that. It will also allow the CFO to check in on the stores profits to see if newly implemented business strategies have worked to increase profits and sales. 

## Summary of the Code

### Transformation Function
The `calc_avg_per_rental` function calculates the average amount per rental. It takes the total amount and the total number of rentals as input and returns the average.

### Create Tables
- **Detailed Table**: Stores detailed information for each store, including store ID, total amount, total rentals, average rentals, and store city.
- **Summary Table**: Stores summary information for each store, including store ID and total amount.

### Data Extraction
The code extracts raw data for the detailed table from the source database, calculating total amount, total rentals, and average rentals for each store and city.

### Trigger Function
The `update_summary_table` function updates the summary table whenever a new entry is added to the detailed table. This ensures that the summary table is always up-to-date.

### Trigger Statement
The trigger `trigger_update_summary` calls the `update_summary_table` function after each insert operation on the detailed table.

### Refresh Procedure
The `refresh_data` procedure clears the data from both tables and performs raw data extraction to repopulate them. This ensures that both tables can be refreshed with the latest data from the source database.

### Verification
The code includes SQL statements to verify that the detailed and summary tables are populated correctly and that the trigger and refresh procedure work as expected.

## Usage
- To use the functions, triggers, and procedures, execute the SQL code in your PostgreSQL database.
- Modify the source database queries as needed to match your database schema and data.

Feel free to explore the code and modify it according to your needs. This project demonstrates basic SQL operations, data extraction, and maintaining data integrity using triggers and stored procedures.
