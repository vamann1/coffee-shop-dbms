# Coffee Shop Management — DBMS Academic Project

## Database structure
I included a database diagram in the repo. 

| Table | Description |
|---|---|
| `Angajati` (Employees) | Coffee shop employees; self-referencing hierarchy via `id_manager` (recursive foreign key) |
| `Furnizori` (Suppliers) | Product suppliers |
| `Produse` (Products) | Menu products, each linked to a supplier |
| `Mese` (Tables) | The tables in the shop |
| `Comenzi` (Orders) | Orders placed (table + employee who took it) |
| `DetaliiComanda` (Order lines) | Lines of each order (product, quantity, `pret_unitar` / unit price) |
| `ProgramAngajati` (Work schedule) | Employees' shifts and work schedule |
| `Plati` (Payments) | Payments for orders |

Business rules enforced through constraints and triggers: order operations only during business hours (08:00–22:00), protection of active employees' salaries, automatic stock check and decrement when an order is placed, and a limit on the length of work schedules.

## Contents

- **A. Schema** — table creation, constraints (`CHECK`, `UNIQUE`, foreign keys), `ALTER`
- **B. SQL (DDL/DML)** — `INSERT`/`UPDATE`/`DELETE`, dynamic SQL (`EXECUTE IMMEDIATE`), view creation
- **25 queries** — joins, grouping, subqueries, set operators, hierarchical `CONNECT BY`, views, synonyms, indexes
- **C. Conditional and iterative structures** — `IF`/`CASE`, `FOR LOOP`, `WHILE LOOP`
- **D. Collections** — `INDEX BY TABLE` (PLS_INTEGER / VARCHAR2), `NESTED TABLE`, `VARRAY`, `BULK COLLECT`
- **E. Exception handling** — implicit (`DUP_VAL_ON_INDEX`, `NO_DATA_FOUND`, `TOO_MANY_ROWS`) and explicit (`RAISE_APPLICATION_ERROR`, `PRAGMA EXCEPTION_INIT`)
- **F. Cursors** — explicit (with/without parameters), implicit, inline, `FOR UPDATE`
- **G. Subprograms** — functions, procedures, and a package (`pkg_cafenea`)
- **H. Triggers** — statement-level and row-level

## Technologies

Oracle Database · PL/SQL · SQL Developer

## Author

Vaman Mircea-George - Cybernetics, Statistics and Informatics Economics, Year II
