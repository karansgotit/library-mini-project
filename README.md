# Library Mini Project

Python and SQLite application for managing a library's collection, members,
loans, fines, donations, events, rooms, personnel, volunteers, registrations,
and librarian help requests.

## Team responsibilities

| Work | Owner |
| --- | --- |
| Step 1: Project description | Tushar |
| Step 2: E/R diagram | Tushar |
| Step 3: Functional dependencies, anomalies, and BCNF | Karan |
| Step 4: SQLite database schema | Joint |
| Step 5: Realistic sample data | Joint |
| Find, borrow, return, and donate an item | Karan |
| Find/register for an event, volunteer, and ask a librarian | Tushar |
| Integration, testing, and final submission | Joint |

## Repository areas

- `docs/`: editable source material for Steps 1-3
- `database/`: SQL schema, sample data, and database builder
- `app/`: the eight-feature Python application
- `tests/`: automated database and application checks
- `build/`: generated development database
- `submission/`: final Canvas submission files

## Planned commands

Build the development database:

```bash
python3 database/build_database.py
```

Run the application:

```bash
python3 app/main.py
```

Run the tests:

```bash
python3 -m pytest
```

The repository currently contains starter placeholders. Features, tables,
sample data, documentation, and tests will be completed during development.
