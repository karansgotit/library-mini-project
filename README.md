# Library Mini Project

Python and SQLite application for managing a library's collection, members,
loans, fines, donations, events, rooms, personnel, volunteers, registrations,
and librarian help requests.

## Team responsibilities

Every deliverable has one primary owner and one reviewer. The primary owner is
responsible for finishing the work, responding to review comments, and getting
the file merged. The reviewer checks the work but does not replace the owner.

### Documentation and final report

| Deliverable | Primary owner | Reviewer |
| --- | --- | --- |
| Step 1 project description | Tushar | Karan |
| Step 2 E/R diagram | Tushar | Karan |
| Step 3 functional dependencies, anomalies, and BCNF | Karan | Tushar |
| Combine Steps 1-3 into `submission/mp.pdf` | Tushar | Karan |

### Database schema and sample data

| File or deliverable | Primary owner | Reviewer |
| --- | --- | --- |
| `database/schema/core.sql` | Karan | Tushar |
| `database/schema/items.sql` | Karan | Tushar |
| `database/schema/events.sql` | Tushar | Karan |
| `database/schema/integrity.sql` | Karan | Tushar |
| `database/seeds/core_data.sql` | Karan | Tushar |
| `database/seeds/items_data.sql` | Karan | Tushar |
| `database/seeds/events_data.sql` | Tushar | Karan |
| `database/build_database.py` | Karan | Tushar |
| Final `submission/library.db` | Karan | Tushar |

### Application and testing

| File or deliverable | Primary owner | Reviewer |
| --- | --- | --- |
| `app/main.py` | Karan | Tushar |
| `app/database.py` | Karan | Tushar |
| `app/item_features.py` | Karan | Tushar |
| `app/event_features.py` | Tushar | Karan |
| `tests/test_database.py` | Karan | Tushar |
| `tests/test_item_features.py` | Karan | Tushar |
| `tests/test_event_features.py` | Tushar | Karan |
| `tests/test_application.py` | Karan | Tushar |

### Repository and submission administration

| Deliverable | Primary owner | Reviewer |
| --- | --- | --- |
| Repository structure, `README.md`, and dependency list | Karan | Tushar |
| Copy verified application files into `submission/` | Karan | Tushar |
| Create the final Canvas ZIP | Tushar | Karan |
| Check the final submission against the checklist | Tushar | Karan |

## Repository areas

- `docs/`: editable source material for Steps 1-3
- `database/`: SQL schema, sample data, and database builder
- `app/`: the eight-feature Python application
- `tests/`: automated database and application checks
- `build/`: generated development database
- `submission/`: final Canvas submission files

## Final submission checklist

- [ ] Step 1 is included in `mp.pdf`
- [ ] Step 2 E/R diagram is readable in `mp.pdf`
- [ ] Step 3 BCNF analysis is included in `mp.pdf`
- [ ] Every database table contains at least 10 realistic rows
- [ ] `library.db` opens successfully
- [ ] All eight application features work correctly
- [ ] Database integrity and application tests pass
- [ ] All required application files are included
- [ ] Application setup and running instructions are included
- [ ] The final ZIP opens and contains every required file
- [ ] The ZIP is submitted to the correct Canvas activity

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
