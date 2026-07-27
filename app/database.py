"""Karan-owned SQLite connection utilities for the library application."""

from pathlib import Path
import sqlite3


APP_DIRECTORY = Path(__file__).resolve().parent
PROJECT_ROOT = APP_DIRECTORY.parent


def find_database() -> Path:
    """Locate the packaged database or the development build."""
    possible_paths = [
        APP_DIRECTORY / "library.db",
        PROJECT_ROOT / "build" / "library.db",
    ]

    for database_path in possible_paths:
        if database_path.exists():
            return database_path

    raise FileNotFoundError(
        "library.db was not found. Run database/build_database.py first."
    )


def get_connection() -> sqlite3.Connection:
    """Open a database connection with integrity checking enabled."""
    connection = sqlite3.connect(find_database())
    connection.row_factory = sqlite3.Row
    connection.execute("PRAGMA foreign_keys = ON")
    return connection
