# DVD-Rental-Revenue-Analysis-Balancing-Morality-and-Profitability
A SQL project exploring how business decisions around film ratings can impact rental revenue. Built using PostgreSQL and the publicly available DVD Rental sample database.

---

## Project Overview

This project analyzes rental revenue patterns using the [PostgreSQL DVD Rental sample database](https://neon.com/postgresql/postgresql-getting-started/postgresql-sample-database). The queries and business logic were written by me to simulate a real-world scenario: how a company might adjust its inventory to favor family-friendly films while maintaining profitability.

---

## Installation

- The database is formatted for **PostgreSQL**
- Queries are written in **PostgreSQL dialect**
- You may attempt to adapt the code for other DBMSs (e.g., MySQL, SQL Server), but compatibility is not guaranteed

---

## Comparisons
 _____________________   Runtime |  Buffers | Notes
| Before Optimization | ~ 250 ms |  Mixed   | Extra columns, no indices
| After Optimization  | ~ 121 ms |  All hit | Trimmed columns, indexed joins

---

## Usage

This project is ideal for:
- Practicing multi-table joins, aggregations, and transformations
- Utilizing functions, views, indexing, and I/O optimization through "explain analyze"
- Exploring business logic through SQL
- Understanding how film ratings and genres relate to rental revenue

---

## Contributing

Pull requests are welcome!  
If you'd like to suggest a major change or offer feedback, please open an issue first so we can discuss it.

---

## License

This project is released to the public domain.  
Feel free to use, remix, or build on it.

---

## Project Status

Originally completed as part of coursework at **Western Governors University**, this project is now open for further exploration.  
Future enhancements may include:
- Window functions for ranking films by revenue
- CTEs for modular query design
- Visualizations or dashboard integration

---

## Personal Note

This project reflects both technical growth and a values-driven approach to data analysis.  
It’s part of a broader portfolio aimed at solving real-world problems with clarity, precision, and impact.
