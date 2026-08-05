"""End-to-end tests for the core database schema (Member and Staff tables)."""

import pytest
import sqlite3
from app.database import get_connection, find_database


class TestCoreSchema:
    """Test the core database schema (Member and Staff tables)."""

    @pytest.fixture
    def conn(self):
        """Provide a database connection for testing."""
        conn = get_connection()
        yield conn
        conn.close()

    def test_database_file_exists(self):
        """Test that the database file exists."""
        db_path = find_database()
        assert db_path.exists()
        assert db_path.suffix == '.db'

    def test_foreign_keys_enabled(self, conn):
        """Test that foreign key enforcement is enabled."""
        result = conn.execute("PRAGMA foreign_keys").fetchone()
        assert result[0] == 1, "Foreign key constraints are not enabled"

    def test_core_tables_exist(self, conn):
        tables = conn.execute(
            "SELECT name FROM sqlite_master WHERE type='table'"
        ).fetchall()
        table_names = [row['name'] for row in tables]

        expected_tables = ['Member', 'Staff']
        for table in expected_tables:
            assert table in table_names, f"Table '{table}' not found in database"

    def test_member_table_structure(self, conn):
        table_info = conn.execute("PRAGMA table_info(Member)").fetchall()
        columns = {row['name']: row for row in table_info}

        expected_columns = {
            'MemberID': {'type': 'INTEGER', 'notnull': 0, 'pk': 1},
            'FullName': {'type': 'TEXT', 'notnull': 1, 'pk': 0},
            'Email': {'type': 'TEXT', 'notnull': 0, 'pk': 0},
            'Phone': {'type': 'TEXT', 'notnull': 0, 'pk': 0},
            'MembershipStatus': {'type': 'TEXT', 'notnull': 1, 'pk': 0}
        }

        for col_name, col_info in expected_columns.items():
            assert col_name in columns, f"Column '{col_name}' not found in Member table"
            assert columns[col_name]['type'] == col_info['type']
            assert columns[col_name]['notnull'] == col_info['notnull']
            assert columns[col_name]['pk'] == col_info['pk']

    def test_member_not_null_constraint(self, conn):
        # full name cant be null
        with pytest.raises(sqlite3.IntegrityError):
            conn.execute(
                "INSERT INTO Member (FullName, Email, Phone, MembershipStatus) "
                "VALUES (NULL, 'test_notnull@example.com', '123-456-7890', 'Active')"
            )
            conn.commit()

        # membership status cant be null
        with pytest.raises(sqlite3.IntegrityError):
            conn.execute(
                "INSERT INTO Member (FullName, Email, Phone, MembershipStatus) "
                "VALUES ('Test User', 'test_notnull2@example.com', '123-456-7890', NULL)"
            )
            conn.commit()

    def test_member_check_constraints(self, conn):
        valid_statuses = ['Active', 'Suspended', 'Expired']

        # test valid membership statuses - use unique emails
        for i, status in enumerate(valid_statuses):
            conn.execute(
                "INSERT INTO Member (FullName, Email, Phone, MembershipStatus) "
                "VALUES (?, ?, ?, ?)",
                (f'User {status}', f'check_{i}_{status.lower()}@example.com', '123-456-7890', status)
            )
            conn.commit()

        # test invalid membership status
        with pytest.raises(sqlite3.IntegrityError):
            conn.execute(
                "INSERT INTO Member (FullName, Email, Phone, MembershipStatus) "
                "VALUES ('Invalid User', 'invalid_check@example.com', '123-456-7890', 'Invalid')"
            )
            conn.commit()

    def test_member_unique_constraints(self, conn):
        # insert first member with email - use unique email
        conn.execute(
            "INSERT INTO Member (FullName, Email, Phone, MembershipStatus) "
            "VALUES ('First User', 'unique_test@example.com', '123-456-7890', 'Active')"
        )
        conn.commit()

        # insert second member with same email (should fail)
        with pytest.raises(sqlite3.IntegrityError):
            conn.execute(
                "INSERT INTO Member (FullName, Email, Phone, MembershipStatus) "
                "VALUES ('Second User', 'unique_test@example.com', '987-654-3210', 'Active')"
            )
            conn.commit()

        # checking if null email values are allowed
        conn.execute(
            "INSERT INTO Member (FullName, Email, Phone, MembershipStatus) "
            "VALUES ('User One', NULL, '111-111-1111', 'Active')"
        )
        conn.execute(
            "INSERT INTO Member (FullName, Email, Phone, MembershipStatus) "
            "VALUES ('User Two', NULL, '222-222-2222', 'Active')"
        )
        conn.commit()

    def test_member_primary_key_auto_increment(self, conn):
        conn.execute(
            "INSERT INTO Member (FullName, Email, Phone, MembershipStatus) "
            "VALUES ('User A', 'auto_a@example.com', '111-111-1111', 'Active')"
        )
        first_id = conn.execute("SELECT last_insert_rowid()").fetchone()[0]
        conn.execute(
            "INSERT INTO Member (FullName, Email, Phone, MembershipStatus) "
            "VALUES ('User B', 'auto_b@example.com', '222-222-2222', 'Active')"
        )
        second_id = conn.execute("SELECT last_insert_rowid()").fetchone()[0]

        assert second_id > first_id

    def test_staff_not_null_constraints(self, conn):
        # fullname cant be null
        with pytest.raises(sqlite3.IntegrityError):
            conn.execute(
                "INSERT INTO Staff (FullName, JobTitle, Email, EmploymentStatus, HireDate, DepartmentName) "
                "VALUES (NULL, 'Librarian', 'staff_notnull@example.com', 'Active', '2024-01-01', 'Library')"
            )
            conn.commit()

        # job title cant be null
        with pytest.raises(sqlite3.IntegrityError):
            conn.execute(
                "INSERT INTO Staff (FullName, JobTitle, Email, EmploymentStatus, HireDate, DepartmentName) "
                "VALUES ('Staff User', NULL, 'staff_notnull2@example.com', 'Active', '2024-01-01', 'Library')"
            )
            conn.commit()

        # Email cant be null
        with pytest.raises(sqlite3.IntegrityError):
            conn.execute(
                "INSERT INTO Staff (FullName, JobTitle, Email, EmploymentStatus, HireDate, DepartmentName) "
                "VALUES ('Staff User', 'Librarian', NULL, 'Active', '2024-01-01', 'Library')"
            )
            conn.commit()

        # Employment status cant be null
        with pytest.raises(sqlite3.IntegrityError):
            conn.execute(
                "INSERT INTO Staff (FullName, JobTitle, Email, EmploymentStatus, HireDate, DepartmentName) "
                "VALUES ('Staff User', 'Librarian', 'staff_notnull3@example.com', NULL, '2024-01-01', 'Library')"
            )
            conn.commit()

        # HireDate cant be null
        with pytest.raises(sqlite3.IntegrityError):
            conn.execute(
                "INSERT INTO Staff (FullName, JobTitle, Email, EmploymentStatus, HireDate, DepartmentName) "
                "VALUES ('Staff User', 'Librarian', 'staff_notnull4@example.com', 'Active', NULL, 'Library')"
            )
            conn.commit()

        # DepartmentName cannot be null
        with pytest.raises(sqlite3.IntegrityError):
            conn.execute(
                "INSERT INTO Staff (FullName, JobTitle, Email, EmploymentStatus, HireDate, DepartmentName) "
                "VALUES ('Staff User', 'Librarian', 'staff_notnull5@example.com', 'Active', '2024-01-01', NULL)"
            )
            conn.commit()

    def test_staff_check_constraints(self, conn):
        # checking valid employment status - use unique emails
        valid_statuses = ['Active', 'OnLeave', 'Former']
        for i, status in enumerate(valid_statuses):
            conn.execute(
                "INSERT INTO Staff (FullName, JobTitle, Email, EmploymentStatus, HireDate, DepartmentName) "
                "VALUES (?, ?, ?, ?, ?, ?)",
                (f'Staff {status}', 'Librarian', f'check_staff_{i}_{status.lower()}@example.com', status, '2024-01-01', 'Library')
            )
            conn.commit()

        # testing for invalid employment status
        with pytest.raises(sqlite3.IntegrityError):
            conn.execute(
                "INSERT INTO Staff (FullName, JobTitle, Email, EmploymentStatus, HireDate, DepartmentName) "
                "VALUES ('Invalid Staff', 'Librarian', 'invalid_staff_check@example.com', 'Invalid', '2024-01-01', 'Library')"
            )
            conn.commit()

    def test_staff_unique_constraints(self, conn):
        # inserting staff member 1 with email
        conn.execute(
            "INSERT INTO Staff (FullName, JobTitle, Email, EmploymentStatus, HireDate, DepartmentName) "
            "VALUES ('First Staff', 'Librarian', 'staff_unique_test@example.com', 'Active', '2024-01-01', 'Library')"
        )
        conn.commit()

        # inserting staff member 2 with same email (should fail)
        with pytest.raises(sqlite3.IntegrityError):
            conn.execute(
                "INSERT INTO Staff (FullName, JobTitle, Email, EmploymentStatus, HireDate, DepartmentName) "
                "VALUES ('Second Staff', 'Librarian', 'staff_unique_test@example.com', 'Active', '2024-01-01', 'Library')"
            )
            conn.commit()

    def test_staff_primary_key_auto_increment(self, conn):
        conn.execute(
            "INSERT INTO Staff (FullName, JobTitle, Email, EmploymentStatus, HireDate, DepartmentName) "
            "VALUES ('Staff A', 'Librarian', 'staff_auto_a@example.com', 'Active', '2024-01-01', 'Library')"
        )
        first_id = conn.execute("SELECT last_insert_rowid()").fetchone()[0]
        
        conn.execute(
            "INSERT INTO Staff (FullName, JobTitle, Email, EmploymentStatus, HireDate, DepartmentName) "
            "VALUES ('Staff B', 'Librarian', 'staff_auto_b@example.com', 'Active', '2024-01-01', 'Library')"
        )
        second_id = conn.execute("SELECT last_insert_rowid()").fetchone()[0]
        
        assert second_id > first_id

    def test_member_insert_valid_data(self, conn):
        conn.execute(
            "INSERT INTO Member (FullName, Email, Phone, MembershipStatus) "
            "VALUES ('John Doe', 'john_valid@example.com', '555-123-4567', 'Active')"
        )
        conn.commit()
        
        # Verify the data was inserted
        result = conn.execute(
            "SELECT FullName, Email, Phone, MembershipStatus FROM Member WHERE Email = 'john_valid@example.com'"
        ).fetchone()
        
        assert result is not None
        assert result['FullName'] == 'John Doe'
        assert result['Email'] == 'john_valid@example.com'
        assert result['Phone'] == '555-123-4567'
        assert result['MembershipStatus'] == 'Active'

    def test_staff_insert_valid_data(self, conn):
        conn.execute(
            "INSERT INTO Staff (FullName, JobTitle, Email, EmploymentStatus, HireDate, DepartmentName) "
            "VALUES ('Jane Smith', 'Head Librarian', 'jane_valid@example.com', 'Active', '2020-06-15', 'Library Services')"
        )
        conn.commit()
        
        # Verify the data was inserted
        result = conn.execute(
            "SELECT FullName, JobTitle, Email, EmploymentStatus, HireDate, DepartmentName "
            "FROM Staff WHERE Email = 'jane_valid@example.com'"
        ).fetchone()
        
        assert result is not None
        assert result['FullName'] == 'Jane Smith'
        assert result['JobTitle'] == 'Head Librarian'
        assert result['Email'] == 'jane_valid@example.com'
        assert result['EmploymentStatus'] == 'Active'
        assert result['HireDate'] == '2020-06-15'
        assert result['DepartmentName'] == 'Library Services'