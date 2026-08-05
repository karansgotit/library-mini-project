"""End-to-end tests for all integrity triggers from integrity.sql."""

import pytest
import sqlite3
from datetime import datetime, timedelta

from app.database import get_connection, find_database


class TestDisjointSubtypeTriggers:
    """Test the disjoint subtype triggers (PrintBook, Magazine, Journal, Record, OnlineBook)."""

    @pytest.fixture
    def conn(self):
        """Provide a database connection for testing."""
        conn = get_connection()
        # Don't autocommit - we'll rollback after each test
        conn.execute("BEGIN TRANSACTION")
        yield conn
        conn.rollback()
        conn.close()

    def test_printbook_disjoint_insert(self, conn):
        """Test that an item cannot be inserted into PrintBook if it already belongs to another subtype."""
        # Create an item
        conn.execute(
            "INSERT INTO Item (Title, CreatorName, CollectionStatus) "
            "VALUES ('Test Book', 'Test Author', 'InCollection')"
        )
        item_id = conn.execute("SELECT last_insert_rowid()").fetchone()[0]
        
        # Add it as a Magazine first
        conn.execute(
            "INSERT INTO Magazine (ItemID, ISSN, VolumeNumber, IssueNumber) "
            "VALUES (?, '1234-5678', 1, 1)",
            (item_id,)
        )
        
        # Try to add it as a PrintBook (should fail)
        with pytest.raises(sqlite3.IntegrityError) as exc_info:
            conn.execute(
                "INSERT INTO PrintBook (ItemID, ISBN) "
                "VALUES (?, '978-3-16-148410-0')",
                (item_id,)
            )
        
        assert "already belongs to another subtype" in str(exc_info.value)

    def test_magazine_disjoint_insert(self, conn):
        """Test that an item cannot be inserted into Magazine if it already belongs to another subtype."""
        conn.execute(
            "INSERT INTO Item (Title, CreatorName, CollectionStatus) "
            "VALUES ('Test Magazine', 'Publisher', 'InCollection')"
        )
        item_id = conn.execute("SELECT last_insert_rowid()").fetchone()[0]
        
        # Add it as a PrintBook first
        conn.execute(
            "INSERT INTO PrintBook (ItemID, ISBN) "
            "VALUES (?, '978-3-16-148410-1')",
            (item_id,)
        )
        
        # Try to add it as a Magazine (should fail)
        with pytest.raises(sqlite3.IntegrityError) as exc_info:
            conn.execute(
                "INSERT INTO Magazine (ItemID, ISSN, VolumeNumber, IssueNumber) "
                "VALUES (?, '1234-5679', 1, 1)",
                (item_id,)
            )
        
        assert "already belongs to another subtype" in str(exc_info.value)

    def test_journal_disjoint_insert(self, conn):
        """Test that an item cannot be inserted into Journal if it already belongs to another subtype."""
        conn.execute(
            "INSERT INTO Item (Title, CreatorName, CollectionStatus) "
            "VALUES ('Test Journal', 'Publisher', 'InCollection')"
        )
        item_id = conn.execute("SELECT last_insert_rowid()").fetchone()[0]
        
        # Add it as a PrintBook first with unique ISBN
        conn.execute(
            "INSERT INTO PrintBook (ItemID, ISBN) "
            "VALUES (?, '978-3-16-148410-2')",
            (item_id,)
        )
        
        # Try to add it as a Journal (should fail)
        with pytest.raises(sqlite3.IntegrityError) as exc_info:
            conn.execute(
                "INSERT INTO Journal (ItemID, ISSN, Volume, Issue) "
                "VALUES (?, '1234-5680', 1, 1)",
                (item_id,)
            )
        
        assert "already belongs to another subtype" in str(exc_info.value)

    def test_record_disjoint_insert(self, conn):
        """Test that an item cannot be inserted into Record if it already belongs to another subtype."""
        conn.execute(
            "INSERT INTO Item (Title, CreatorName, CollectionStatus) "
            "VALUES ('Test Record', 'Artist', 'InCollection')"
        )
        item_id = conn.execute("SELECT last_insert_rowid()").fetchone()[0]
        
        # Add it as a PrintBook first with unique ISBN
        conn.execute(
            "INSERT INTO PrintBook (ItemID, ISBN) "
            "VALUES (?, '978-3-16-148410-3')",
            (item_id,)
        )
        
        # Try to add it as a Record (should fail)
        with pytest.raises(sqlite3.IntegrityError) as exc_info:
            conn.execute(
                "INSERT INTO Record (ItemID, LabelName, RecordNumber) "
                "VALUES (?, 'Label', 'RN123')",
                (item_id,)
            )
        
        assert "already belongs to another subtype" in str(exc_info.value)

    def test_onlinebook_disjoint_insert(self, conn):
        """Test that an item cannot be inserted into OnlineBook if it already belongs to another subtype."""
        conn.execute(
            "INSERT INTO Item (Title, CreatorName, CollectionStatus) "
            "VALUES ('Test E-Book', 'Author', 'InCollection')"
        )
        item_id = conn.execute("SELECT last_insert_rowid()").fetchone()[0]
        
        # Add it as a PrintBook first with unique ISBN
        conn.execute(
            "INSERT INTO PrintBook (ItemID, ISBN) "
            "VALUES (?, '978-3-16-148410-4')",
            (item_id,)
        )
        
        # Try to add it as an OnlineBook (should fail)
        with pytest.raises(sqlite3.IntegrityError) as exc_info:
            conn.execute(
                "INSERT INTO OnlineBook (ItemID, ISBN, AccessURL) "
                "VALUES (?, '978-3-16-148410-5', 'http://example.com')",
                (item_id,)
            )
        
        assert "already belongs to another subtype" in str(exc_info.value)


class TestCopyEligibilityTriggers:
    """Test the copy eligibility triggers."""

    @pytest.fixture
    def conn(self):
        """Provide a database connection for testing."""
        conn = get_connection()
        conn.execute("BEGIN TRANSACTION")
        yield conn
        conn.rollback()
        conn.close()

    def test_copy_eligibility_in_collection_only(self, conn):
        """Test that copies can only be added to InCollection items."""
        # Create a Prospective item
        conn.execute(
            "INSERT INTO Item (Title, CreatorName, CollectionStatus) "
            "VALUES ('Prospective Book', 'Author', 'Prospective')"
        )
        item_id = conn.execute("SELECT last_insert_rowid()").fetchone()[0]
        
        # Try to add a copy (should fail)
        with pytest.raises(sqlite3.IntegrityError) as exc_info:
            conn.execute(
                "INSERT INTO Copy (ItemID, CopyNumber, Condition) "
                "VALUES (?, 1, 'Usable')",
                (item_id,)
            )
        
        assert "Copies may be added only to InCollection Items" in str(exc_info.value)

    def test_copy_eligibility_onlinebook_no_copies(self, conn):
        """Test that OnlineBook items cannot have physical copies."""
        # Create an item
        conn.execute(
            "INSERT INTO Item (Title, CreatorName, CollectionStatus) "
            "VALUES ('E-Book', 'Author', 'InCollection')"
        )
        item_id = conn.execute("SELECT last_insert_rowid()").fetchone()[0]
        
        # Add as OnlineBook
        conn.execute(
            "INSERT INTO OnlineBook (ItemID, ISBN, AccessURL) "
            "VALUES (?, '978-3-16-148410-6', 'http://example.com')",
            (item_id,)
        )
        
        # Try to add a copy (should fail)
        with pytest.raises(sqlite3.IntegrityError) as exc_info:
            conn.execute(
                "INSERT INTO Copy (ItemID, CopyNumber, Condition) "
                "VALUES (?, 1, 'Usable')",
                (item_id,)
            )
        
        assert "OnlineBook Items cannot have physical Copies" in str(exc_info.value)

    def test_onlinebook_reject_copy_insert(self, conn):
        """Test that an item with physical copies cannot be an OnlineBook."""
        # Create an item
        conn.execute(
            "INSERT INTO Item (Title, CreatorName, CollectionStatus) "
            "VALUES ('Book with Copy', 'Author', 'InCollection')"
        )
        item_id = conn.execute("SELECT last_insert_rowid()").fetchone()[0]
        
        # Add a copy first
        conn.execute(
            "INSERT INTO Copy (ItemID, CopyNumber, Condition) "
            "VALUES (?, 1, 'Usable')",
            (item_id,)
        )
        
        # Try to add it as an OnlineBook (should fail)
        with pytest.raises(sqlite3.IntegrityError) as exc_info:
            conn.execute(
                "INSERT INTO OnlineBook (ItemID, ISBN, AccessURL) "
                "VALUES (?, '978-3-16-148410-7', 'http://example.com')",
                (item_id,)
            )
        
        assert "An Item with physical Copies cannot be an OnlineBook" in str(exc_info.value)


class TestLoanEligibilityTrigger:
    """Test the loan eligibility trigger."""

    @pytest.fixture
    def conn(self):
        """Provide a database connection for testing."""
        conn = get_connection()
        conn.execute("BEGIN TRANSACTION")
        yield conn
        conn.rollback()
        conn.close()

    def test_loan_only_active_members(self, conn):
        """Test that only active members can borrow items."""
        # Create an active member with unique email
        conn.execute(
            "INSERT INTO Member (FullName, Email, Phone, MembershipStatus) "
            "VALUES ('Active Member', 'active_loan_1@example.com', '123-456-7890', 'Active')"
        )
        active_member_id = conn.execute("SELECT last_insert_rowid()").fetchone()[0]
        
        # Create a suspended member with unique email
        conn.execute(
            "INSERT INTO Member (FullName, Email, Phone, MembershipStatus) "
            "VALUES ('Suspended Member', 'suspended_loan_1@example.com', '987-654-3210', 'Suspended')"
        )
        suspended_member_id = conn.execute("SELECT last_insert_rowid()").fetchone()[0]
        
        # Create an InCollection item
        conn.execute(
            "INSERT INTO Item (Title, CreatorName, CollectionStatus) "
            "VALUES ('Loan Test Book 1', 'Test Author', 'InCollection')"
        )
        item_id = conn.execute("SELECT last_insert_rowid()").fetchone()[0]
        
        # Create a Usable copy
        conn.execute(
            "INSERT INTO Copy (ItemID, CopyNumber, Condition) "
            "VALUES (?, 1, 'Usable')",
            (item_id,)
        )
        
        # Try to borrow with suspended member (should fail)
        with pytest.raises(sqlite3.IntegrityError) as exc_info:
            conn.execute(
                "INSERT INTO Loan (MemberID, ItemID, CopyNumber, BorrowDate, DueDate) "
                "VALUES (?, ?, 1, ?, ?)",
                (
                    suspended_member_id,
                    item_id,
                    datetime.now().strftime('%Y-%m-%d'),
                    (datetime.now() + timedelta(days=14)).strftime('%Y-%m-%d')
                )
            )
        
        assert "Only Active Members may begin a Loan" in str(exc_info.value)

    def test_loan_only_usable_copies(self, conn):
        """Test that only usable copies can be loaned."""
        # Create an active member
        conn.execute(
            "INSERT INTO Member (FullName, Email, Phone, MembershipStatus) "
            "VALUES ('Active Member 2', 'active_loan_2@example.com', '123-456-7890', 'Active')"
        )
        active_member_id = conn.execute("SELECT last_insert_rowid()").fetchone()[0]
        
        # Create an InCollection item
        conn.execute(
            "INSERT INTO Item (Title, CreatorName, CollectionStatus) "
            "VALUES ('Loan Test Book 2', 'Test Author', 'InCollection')"
        )
        item_id = conn.execute("SELECT last_insert_rowid()").fetchone()[0]
        
        # Create a Usable copy
        conn.execute(
            "INSERT INTO Copy (ItemID, CopyNumber, Condition) "
            "VALUES (?, 1, 'Usable')",
            (item_id,)
        )
        
        # Create a Damaged copy
        conn.execute(
            "INSERT INTO Copy (ItemID, CopyNumber, Condition) "
            "VALUES (?, 2, 'Damaged')",
            (item_id,)
        )
        
        # Try to borrow damaged copy (should fail)
        with pytest.raises(sqlite3.IntegrityError) as exc_info:
            conn.execute(
                "INSERT INTO Loan (MemberID, ItemID, CopyNumber, BorrowDate, DueDate) "
                "VALUES (?, ?, 2, ?, ?)",
                (
                    active_member_id,
                    item_id,
                    datetime.now().strftime('%Y-%m-%d'),
                    (datetime.now() + timedelta(days=14)).strftime('%Y-%m-%d')
                )
            )
        
        assert "Only Usable Copies may be loaned" in str(exc_info.value)

    def test_loan_only_in_collection_items(self, conn):
        """Test that only InCollection items can be loaned."""
        # Create an active member
        conn.execute(
            "INSERT INTO Member (FullName, Email, Phone, MembershipStatus) "
            "VALUES ('Active Member 3', 'active_loan_3@example.com', '123-456-7890', 'Active')"
        )
        active_member_id = conn.execute("SELECT last_insert_rowid()").fetchone()[0]
        
        # Create an InCollection item first (so we can add a copy)
        conn.execute(
            "INSERT INTO Item (Title, CreatorName, CollectionStatus) "
            "VALUES ('Book to be Removed', 'Test Author', 'InCollection')"
        )
        item_id = conn.execute("SELECT last_insert_rowid()").fetchone()[0]
        
        # Add a copy (allowed since item is InCollection)
        conn.execute(
            "INSERT INTO Copy (ItemID, CopyNumber, Condition) "
            "VALUES (?, 1, 'Usable')",
            (item_id,)
        )
        
        # Now change the item status to Removed
        conn.execute(
            "UPDATE Item SET CollectionStatus = 'Removed' "
            "WHERE ItemID = ?",
            (item_id,)
        )
        
        # Try to borrow the removed item (should fail)
        with pytest.raises(sqlite3.IntegrityError) as exc_info:
            conn.execute(
                "INSERT INTO Loan (MemberID, ItemID, CopyNumber, BorrowDate, DueDate) "
                "VALUES (?, ?, 1, ?, ?)",
                (
                    active_member_id,
                    item_id,
                    datetime.now().strftime('%Y-%m-%d'),
                    (datetime.now() + timedelta(days=14)).strftime('%Y-%m-%d')
                )
            )
        
        assert "Only InCollection Items may be loaned" in str(exc_info.value)

    def test_loan_successful_borrow(self, conn):
        """Test successful borrowing with all conditions met."""
        # Create an active member
        conn.execute(
            "INSERT INTO Member (FullName, Email, Phone, MembershipStatus) "
            "VALUES ('Active Member 4', 'active_loan_4@example.com', '123-456-7890', 'Active')"
        )
        active_member_id = conn.execute("SELECT last_insert_rowid()").fetchone()[0]
        
        # Create an InCollection item
        conn.execute(
            "INSERT INTO Item (Title, CreatorName, CollectionStatus) "
            "VALUES ('Loan Test Book 4', 'Test Author', 'InCollection')"
        )
        item_id = conn.execute("SELECT last_insert_rowid()").fetchone()[0]
        
        # Create a Usable copy
        conn.execute(
            "INSERT INTO Copy (ItemID, CopyNumber, Condition) "
            "VALUES (?, 1, 'Usable')",
            (item_id,)
        )
        
        # Borrow with active member, usable copy, InCollection item (should succeed)
        conn.execute(
            "INSERT INTO Loan (MemberID, ItemID, CopyNumber, BorrowDate, DueDate) "
            "VALUES (?, ?, 1, ?, ?)",
            (
                active_member_id,
                item_id,
                datetime.now().strftime('%Y-%m-%d'),
                (datetime.now() + timedelta(days=14)).strftime('%Y-%m-%d')
            )
        )
        
        # Verify the loan was created
        loan = conn.execute(
            "SELECT * FROM Loan WHERE MemberID = ? AND ItemID = ? AND CopyNumber = 1",
            (active_member_id, item_id)
        ).fetchone()
        
        assert loan is not None
        assert loan['ReturnDate'] is None


class TestEventIntegrityTrigger:
    """Test the event integrity trigger."""

    @pytest.fixture
    def conn(self):
        """Provide a database connection for testing."""
        conn = get_connection()
        conn.execute("BEGIN TRANSACTION")
        yield conn
        conn.rollback()
        conn.close()

    def test_event_registration_limit_vs_room_capacity(self, conn):
        """Test that registration limit cannot exceed room capacity."""
        # Create a room with unique room number
        conn.execute(
            "INSERT INTO Room (RoomNumber, Capacity) "
            "VALUES ('E101_TEST1', 30)"
        )
        room_id = conn.execute("SELECT last_insert_rowid()").fetchone()[0]
        
        # Create staff with unique email
        conn.execute(
            "INSERT INTO Staff (FullName, JobTitle, Email, EmploymentStatus, HireDate, DepartmentName) "
            "VALUES ('Event Staff 1', 'Coordinator', 'event_staff_1@example.com', 'Active', '2024-01-01', 'Events')"
        )
        staff_id = conn.execute("SELECT last_insert_rowid()").fetchone()[0]
        
        # Try to create event with registration limit > room capacity (should fail)
        with pytest.raises(sqlite3.IntegrityError) as exc_info:
            conn.execute(
                "INSERT INTO Event (EventTitle, EventCategory, Description, TargetAudience, "
                "StartDateTime, EndDateTime, EventStatus, RegistrationLimit, RoomID, OrganizerStaffID) "
                "VALUES ('Capacity Event', 'Workshop', 'Description', 'All Ages', "
                "'2024-02-01 10:00:00', '2024-02-01 12:00:00', 'Scheduled', 50, ?, ?)",
                (room_id, staff_id)
            )
        
        assert "Registration limit cannot exceed Room Capacity" in str(exc_info.value)

    def test_event_no_overlap_same_room(self, conn):
        """Test that events in the same room cannot overlap."""
        # Create a room with unique room number
        conn.execute(
            "INSERT INTO Room (RoomNumber, Capacity) "
            "VALUES ('E101_TEST2', 30)"
        )
        room_id = conn.execute("SELECT last_insert_rowid()").fetchone()[0]
        
        # Create staff with unique email
        conn.execute(
            "INSERT INTO Staff (FullName, JobTitle, Email, EmploymentStatus, HireDate, DepartmentName) "
            "VALUES ('Event Staff 2', 'Coordinator', 'event_staff_2@example.com', 'Active', '2024-01-01', 'Events')"
        )
        staff_id = conn.execute("SELECT last_insert_rowid()").fetchone()[0]
        
        # Create first event
        conn.execute(
            "INSERT INTO Event (EventTitle, EventCategory, Description, TargetAudience, "
            "StartDateTime, EndDateTime, EventStatus, RegistrationLimit, RoomID, OrganizerStaffID) "
            "VALUES ('First Event', 'Workshop', 'Description', 'All Ages', "
            "'2024-01-01 10:00:00', '2024-01-01 12:00:00', 'Scheduled', 20, ?, ?)",
            (room_id, staff_id)
        )
        
        # Try to create overlapping event (should fail)
        with pytest.raises(sqlite3.IntegrityError) as exc_info:
            conn.execute(
                "INSERT INTO Event (EventTitle, EventCategory, Description, TargetAudience, "
                "StartDateTime, EndDateTime, EventStatus, RegistrationLimit, RoomID, OrganizerStaffID) "
                "VALUES ('Second Event', 'Workshop', 'Description', 'All Ages', "
                "'2024-01-01 10:30:00', '2024-01-01 11:30:00', 'Scheduled', 15, ?, ?)",
                (room_id, staff_id)
            )
        
        assert "Event overlaps another Event in the same Room" in str(exc_info.value)

    def test_event_cancelled_events_dont_block(self, conn):
        """Test that cancelled events don't prevent overlapping events."""
        # Create a room with unique room number
        conn.execute(
            "INSERT INTO Room (RoomNumber, Capacity) "
            "VALUES ('E101_TEST3', 30)"
        )
        room_id = conn.execute("SELECT last_insert_rowid()").fetchone()[0]
        
        # Create staff with unique email
        conn.execute(
            "INSERT INTO Staff (FullName, JobTitle, Email, EmploymentStatus, HireDate, DepartmentName) "
            "VALUES ('Event Staff 3', 'Coordinator', 'event_staff_3@example.com', 'Active', '2024-01-01', 'Events')"
        )
        staff_id = conn.execute("SELECT last_insert_rowid()").fetchone()[0]
        
        # Create first event (cancelled)
        conn.execute(
            "INSERT INTO Event (EventTitle, EventCategory, Description, TargetAudience, "
            "StartDateTime, EndDateTime, EventStatus, RegistrationLimit, RoomID, OrganizerStaffID, CancellationReason) "
            "VALUES ('Cancelled Event', 'Workshop', 'Description', 'All Ages', "
            "'2024-01-01 10:00:00', '2024-01-01 12:00:00', 'Cancelled', 20, ?, ?, 'Test cancellation')",
            (room_id, staff_id)
        )
        
        # Create overlapping event (should succeed because first is cancelled)
        conn.execute(
            "INSERT INTO Event (EventTitle, EventCategory, Description, TargetAudience, "
            "StartDateTime, EndDateTime, EventStatus, RegistrationLimit, RoomID, OrganizerStaffID) "
            "VALUES ('Second Event', 'Workshop', 'Description', 'All Ages', "
            "'2024-01-01 10:30:00', '2024-01-01 11:30:00', 'Scheduled', 15, ?, ?)",
            (room_id, staff_id)
        )


class TestRegistrationCapacityTrigger:
    """Test the registration capacity trigger."""

    @pytest.fixture
    def conn(self):
        """Provide a database connection for testing."""
        conn = get_connection()
        conn.execute("BEGIN TRANSACTION")
        yield conn
        conn.rollback()
        conn.close()

    def test_registration_requires_scheduled_event(self, conn):
        """Test that registration requires a scheduled event."""
        # Create a room with unique room number
        conn.execute(
            "INSERT INTO Room (RoomNumber, Capacity) "
            "VALUES ('R101_TEST1', 30)"
        )
        room_id = conn.execute("SELECT last_insert_rowid()").fetchone()[0]
        
        # Create staff with unique email
        conn.execute(
            "INSERT INTO Staff (FullName, JobTitle, Email, EmploymentStatus, HireDate, DepartmentName) "
            "VALUES ('Reg Staff 1', 'Coordinator', 'reg_staff_1@example.com', 'Active', '2024-01-01', 'Events')"
        )
        staff_id = conn.execute("SELECT last_insert_rowid()").fetchone()[0]
        
        # Create active member
        conn.execute(
            "INSERT INTO Member (FullName, Email, Phone, MembershipStatus) "
            "VALUES ('Test Member', 'reg_member_1@example.com', '123-456-7890', 'Active')"
        )
        member_id = conn.execute("SELECT last_insert_rowid()").fetchone()[0]
        
        # Create a cancelled event
        conn.execute(
            "INSERT INTO Event (EventTitle, EventCategory, Description, TargetAudience, "
            "StartDateTime, EndDateTime, EventStatus, RegistrationLimit, RoomID, OrganizerStaffID, CancellationReason) "
            "VALUES ('Cancelled Event', 'Workshop', 'Description', 'All Ages', "
            "'2024-03-01 10:00:00', '2024-03-01 12:00:00', 'Cancelled', 20, ?, ?, 'Test cancellation')",
            (room_id, staff_id)
        )
        cancelled_event_id = conn.execute("SELECT last_insert_rowid()").fetchone()[0]
        
        # Try to register for cancelled event (should fail)
        with pytest.raises(sqlite3.IntegrityError) as exc_info:
            conn.execute(
                "INSERT INTO Registration (MemberID, EventID, RegistrationDateTime, RegistrationStatus) "
                "VALUES (?, ?, ?, 'Registered')",
                (member_id, cancelled_event_id, datetime.now().strftime('%Y-%m-%d %H:%M:%S'))
            )
        
        assert "Registration requires a Scheduled Event" in str(exc_info.value)

    def test_registration_capacity_limit(self, conn):
        """Test that event registration capacity is enforced."""
        # Create a room with unique room number
        conn.execute(
            "INSERT INTO Room (RoomNumber, Capacity) "
            "VALUES ('R101_TEST2', 30)"
        )
        room_id = conn.execute("SELECT last_insert_rowid()").fetchone()[0]
        
        # Create staff with unique email
        conn.execute(
            "INSERT INTO Staff (FullName, JobTitle, Email, EmploymentStatus, HireDate, DepartmentName) "
            "VALUES ('Reg Staff 2', 'Coordinator', 'reg_staff_2@example.com', 'Active', '2024-01-01', 'Events')"
        )
        staff_id = conn.execute("SELECT last_insert_rowid()").fetchone()[0]
        
        # Create event with registration limit of 3
        conn.execute(
            "INSERT INTO Event (EventTitle, EventCategory, Description, TargetAudience, "
            "StartDateTime, EndDateTime, EventStatus, RegistrationLimit, RoomID, OrganizerStaffID) "
            "VALUES ('Limited Event', 'Workshop', 'Description', 'All Ages', "
            "'2024-04-01 10:00:00', '2024-04-01 12:00:00', 'Scheduled', 3, ?, ?)",
            (room_id, staff_id)
        )
        event_id = conn.execute("SELECT last_insert_rowid()").fetchone()[0]
        
        # Create 4 members with unique emails
        member_ids = []
        for i in range(4):
            conn.execute(
                "INSERT INTO Member (FullName, Email, Phone, MembershipStatus) "
                "VALUES (?, ?, '123-456-7890', 'Active')",
                (f'Member {i}', f'reg_member_{i}_test@example.com')
            )
            member_ids.append(conn.execute("SELECT last_insert_rowid()").fetchone()[0])
        
        # Register 3 members (should succeed)
        for i in range(3):
            conn.execute(
                "INSERT INTO Registration (MemberID, EventID, RegistrationDateTime, RegistrationStatus) "
                "VALUES (?, ?, ?, 'Registered')",
                (member_ids[i], event_id, datetime.now().strftime('%Y-%m-%d %H:%M:%S'))
            )
        
        # Try to register 4th member (should fail)
        with pytest.raises(sqlite3.IntegrityError) as exc_info:
            conn.execute(
                "INSERT INTO Registration (MemberID, EventID, RegistrationDateTime, RegistrationStatus) "
                "VALUES (?, ?, ?, 'Registered')",
                (member_ids[3], event_id, datetime.now().strftime('%Y-%m-%d %H:%M:%S'))
            )
        
        assert "Event registration capacity has been reached" in str(exc_info.value)

    def test_registration_capacity_uses_room_capacity(self, conn):
        """Test that registration capacity uses room capacity when no registration limit is set."""
        # Create a small room with capacity 2
        conn.execute(
            "INSERT INTO Room (RoomNumber, Capacity) "
            "VALUES ('R102_TEST', 2)"
        )
        small_room_id = conn.execute("SELECT last_insert_rowid()").fetchone()[0]
        
        # Create staff with unique email
        conn.execute(
            "INSERT INTO Staff (FullName, JobTitle, Email, EmploymentStatus, HireDate, DepartmentName) "
            "VALUES ('Reg Staff 3', 'Coordinator', 'reg_staff_3@example.com', 'Active', '2024-01-01', 'Events')"
        )
        staff_id = conn.execute("SELECT last_insert_rowid()").fetchone()[0]
        
        # Create 3 members with unique emails
        member_ids = []
        for i in range(3):
            conn.execute(
                "INSERT INTO Member (FullName, Email, Phone, MembershipStatus) "
                "VALUES (?, ?, '123-456-7890', 'Active')",
                (f'Room Member {i}', f'room_member_{i}@example.com')
            )
            member_ids.append(conn.execute("SELECT last_insert_rowid()").fetchone()[0])
        
        # Create event with no registration limit (uses room capacity)
        conn.execute(
            "INSERT INTO Event (EventTitle, EventCategory, Description, TargetAudience, "
            "StartDateTime, EndDateTime, EventStatus, RegistrationLimit, RoomID, OrganizerStaffID) "
            "VALUES ('No Limit Event', 'Workshop', 'Description', 'All Ages', "
            "'2024-05-01 10:00:00', '2024-05-01 12:00:00', 'Scheduled', NULL, ?, ?)",
            (small_room_id, staff_id)
        )
        event_id = conn.execute("SELECT last_insert_rowid()").fetchone()[0]
        
        # Register 2 members (room capacity)
        for i in range(2):
            conn.execute(
                "INSERT INTO Registration (MemberID, EventID, RegistrationDateTime, RegistrationStatus) "
                "VALUES (?, ?, ?, 'Registered')",
                (member_ids[i], event_id, datetime.now().strftime('%Y-%m-%d %H:%M:%S'))
            )
        
        # Try to register 3rd member (should fail - room capacity reached)
        with pytest.raises(sqlite3.IntegrityError) as exc_info:
            conn.execute(
                "INSERT INTO Registration (MemberID, EventID, RegistrationDateTime, RegistrationStatus) "
                "VALUES (?, ?, ?, 'Registered')",
                (member_ids[2], event_id, datetime.now().strftime('%Y-%m-%d %H:%M:%S'))
            )
        
        assert "Event registration capacity has been reached" in str(exc_info.value)

    def test_registration_status_not_registered_ignores_capacity(self, conn):
        """Test that non-Registered statuses don't count toward capacity."""
        # Create a room with unique room number
        conn.execute(
            "INSERT INTO Room (RoomNumber, Capacity) "
            "VALUES ('R101_TEST3', 30)"
        )
        room_id = conn.execute("SELECT last_insert_rowid()").fetchone()[0]
        
        # Create staff with unique email
        conn.execute(
            "INSERT INTO Staff (FullName, JobTitle, Email, EmploymentStatus, HireDate, DepartmentName) "
            "VALUES ('Reg Staff 4', 'Coordinator', 'reg_staff_4@example.com', 'Active', '2024-01-01', 'Events')"
        )
        staff_id = conn.execute("SELECT last_insert_rowid()").fetchone()[0]
        
        # Create 3 members with unique emails
        member_ids = []
        for i in range(3):
            conn.execute(
                "INSERT INTO Member (FullName, Email, Phone, MembershipStatus) "
                "VALUES (?, ?, '123-456-7890', 'Active')",
                (f'Status Member {i}', f'status_member_{i}@example.com')
            )
            member_ids.append(conn.execute("SELECT last_insert_rowid()").fetchone()[0])
        
        # Create event with registration limit of 1
        conn.execute(
            "INSERT INTO Event (EventTitle, EventCategory, Description, TargetAudience, "
            "StartDateTime, EndDateTime, EventStatus, RegistrationLimit, RoomID, OrganizerStaffID) "
            "VALUES ('Test Event', 'Workshop', 'Description', 'All Ages', "
            "'2024-06-01 10:00:00', '2024-06-01 12:00:00', 'Scheduled', 1, ?, ?)",
            (room_id, staff_id)
        )
        event_id = conn.execute("SELECT last_insert_rowid()").fetchone()[0]
        
        # Register with 'Registered' status (should succeed)
        conn.execute(
            "INSERT INTO Registration (MemberID, EventID, RegistrationDateTime, RegistrationStatus) "
            "VALUES (?, ?, ?, 'Registered')",
            (member_ids[0], event_id, datetime.now().strftime('%Y-%m-%d %H:%M:%S'))
        )
        
        # Try to register with 'Cancelled' status (should succeed - not counted toward capacity)
        conn.execute(
            "INSERT INTO Registration (MemberID, EventID, RegistrationDateTime, RegistrationStatus) "
            "VALUES (?, ?, ?, 'Cancelled')",
            (member_ids[1], event_id, datetime.now().strftime('%Y-%m-%d %H:%M:%S'))
        )
        
        # Try to register with 'Registered' status (should fail - capacity reached)
        with pytest.raises(sqlite3.IntegrityError) as exc_info:
            conn.execute(
                "INSERT INTO Registration (MemberID, EventID, RegistrationDateTime, RegistrationStatus) "
                "VALUES (?, ?, ?, 'Registered')",
                (member_ids[2], event_id, datetime.now().strftime('%Y-%m-%d %H:%M:%S'))
            )
        
        assert "Event registration capacity has been reached" in str(exc_info.value)


