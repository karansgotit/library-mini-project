"""Build a fresh copy of library.db."""

from pathlib import Path
import sqlite3


PROJECT_ROOT = Path(__file__).resolve().parents[1]
BUILD_DIRECTORY = PROJECT_ROOT / "build"
DATABASE_PATH = BUILD_DIRECTORY / "library.db"

SQL_FILES = [
    PROJECT_ROOT / "database" / "schema" / "core.sql",
    PROJECT_ROOT / "database" / "schema" / "items.sql",
    PROJECT_ROOT / "database" / "schema" / "events.sql",
    PROJECT_ROOT / "database" / "schema" / "integrity.sql",
    PROJECT_ROOT / "database" / "seeds" / "core_data.sql",
    PROJECT_ROOT / "database" / "seeds" / "items_data.sql",
    PROJECT_ROOT / "database" / "seeds" / "events_data.sql",
]


def build_database() -> Path:
    """Create a clean database and run every SQL file in order."""
    BUILD_DIRECTORY.mkdir(parents=True, exist_ok=True)

    if DATABASE_PATH.exists():
        DATABASE_PATH.unlink()

    try:
        with sqlite3.connect(DATABASE_PATH) as connection:
            connection.execute("PRAGMA foreign_keys = ON")

            for sql_file in SQL_FILES:
                print(f"Running {sql_file.relative_to(PROJECT_ROOT)}")
                connection.executescript(sql_file.read_text(encoding="utf-8"))

            connection.commit()
    except Exception:
        if DATABASE_PATH.exists():
            DATABASE_PATH.unlink()
        raise

    print(f"Created {DATABASE_PATH.relative_to(PROJECT_ROOT)}")
    return DATABASE_PATH


if __name__ == "__main__":
    build_database()
