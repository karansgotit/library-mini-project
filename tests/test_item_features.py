"""Tests for the four item features."""

from datetime import date, datetime
from unittest.mock import MagicMock, patch

import pytest

from app.item_features import (
    find_item,
    borrow_item,
    return_item,
    donate_item,
    LOAN_PERIOD_DAYS
)


def make_mock_conn(fetchone_result=None, fetchall_result=None):
    """Helper to create a mock connection and cursor."""
    cursor = MagicMock()
    cursor.fetchone.return_value = fetchone_result
    cursor.fetchall.return_value = fetchall_result or []

    conn = MagicMock()
    conn.__enter__.return_value = conn
    conn.__exit__.return_value = False
    conn.execute.return_value = cursor
    
    return conn, cursor


class TestItemFeatures:
    """Test the four item features."""

    @patch("app.item_features.get_connection")
    def test_find_item_returns_matching_items(self, mock_get_connection):
        """Test that find_item returns matching items by title or creator."""
        rows = [
            {
                "ItemID": 1,
                "Title": "Neuromancer",
                "CreatorName": "William Gibson",
                "CollectionStatus": "InCollection"
            },
            {
                "ItemID": 2,
                "Title": "The Hobbit",
                "CreatorName": "J.R.R. Tolkien",
                "CollectionStatus": "InCollection"
            },
        ]
        conn, cursor = make_mock_conn(fetchall_result=rows)
        mock_get_connection.return_value = conn

        result = find_item("Neuromancer")

        assert result == rows
        conn.execute.assert_called_once()

    @patch("app.item_features.get_connection")
    def test_find_item_no_matches_return_empty_list(self, mock_get_connection):
        """Test that find_item returns empty list when no matches found."""
        conn, cursor = make_mock_conn(fetchall_result=[])
        mock_get_connection.return_value = conn

        result = find_item("nonexistent")

        assert result == []

    @patch("app.item_features.get_connection")
    def test_find_item_case_insensitive(self, mock_get_connection):
        """Test that find_item is case insensitive."""
        rows = [
            {
                "ItemID": 1,
                "Title": "Neuromancer",
                "CreatorName": "William Gibson",
                "CollectionStatus": "InCollection"
            },
        ]
        conn, cursor = make_mock_conn(fetchall_result=rows)
        mock_get_connection.return_value = conn

        result_lower = find_item("neuromancer")
        result_upper = find_item("NEUROMANCER")

        assert result_lower == rows
        assert result_upper == rows

    @patch("app.item_features.get_connection")
    def test_borrow_item_success(self, mock_get_connection):
        """Test successful borrowing of an available item."""
        copy_row = {"CopyNumber": 1}
        
        conn, cursor = make_mock_conn()
        cursor.fetchone.side_effect = [copy_row, {"LoanID": 1}]
        mock_get_connection.return_value = conn

        result = borrow_item(member_id=1, item_id=1)

        assert result["MemberID"] == 1
        assert result["ItemID"] == 1
        assert result["CopyNumber"] == 1
        assert result["ReturnDate"] is None
        assert "LoanID" in result
        assert "BorrowDate" in result
        assert "DueDate" in result
        conn.commit.assert_called_once()

    @patch("app.item_features.get_connection")
    def test_borrow_item_no_available_copy(self, mock_get_connection):
        """Test that borrowing fails when no available copy exists."""
        conn, cursor = make_mock_conn(fetchone_result=None)
        mock_get_connection.return_value = conn

        with pytest.raises(ValueError, match="No available copy of item"):
            borrow_item(member_id=1, item_id=999)

    @patch("app.item_features.get_connection")
    def test_borrow_item_loan_period_constant(self, mock_get_connection):
        """Test that LOAN_PERIOD_DAYS is used correctly."""
        copy_row = {"CopyNumber": 1}
        conn, cursor = make_mock_conn()
        cursor.fetchone.side_effect = [copy_row, {"LoanID": 1}]
        mock_get_connection.return_value = conn

        result = borrow_item(member_id=1, item_id=1)

        borrow_date = datetime.strptime(result["BorrowDate"], "%Y-%m-%d")
        due_date = datetime.strptime(result["DueDate"], "%Y-%m-%d")
        days_diff = (due_date - borrow_date).days
        assert days_diff == LOAN_PERIOD_DAYS

    @patch("app.item_features.get_connection")
    def test_return_item_success(self, mock_get_connection):
        """Test successful return of a borrowed item."""
        loan_before = {"LoanID": 1, "ReturnDate": None}
        loan_after = {
            "LoanID": 1,
            "MemberID": 1,
            "ItemID": 1,
            "CopyNumber": 1,
            "BorrowDate": "2026-07-01",
            "DueDate": "2026-07-15",
            "ReturnDate": date.today().isoformat()
        }

        conn, cursor = make_mock_conn()
        cursor.fetchone.side_effect = [loan_before, loan_after]
        mock_get_connection.return_value = conn

        result = return_item(loan_id=1)

        assert result["LoanID"] == 1
        assert result["ReturnDate"] is not None
        conn.commit.assert_called_once()

    @patch("app.item_features.get_connection")
    def test_return_item_invalid_loan(self, mock_get_connection):
        """Test that returning a non-existent loan raises error."""
        conn, cursor = make_mock_conn(fetchone_result=None)
        mock_get_connection.return_value = conn

        with pytest.raises(ValueError, match="No loan found with id"):
            return_item(loan_id=999)

    @patch("app.item_features.get_connection")
    def test_return_item_already_returned(self, mock_get_connection):
        """Test that returning an already returned loan raises error."""
        loan = {"LoanID": 1, "ReturnDate": "2026-07-20"}
        conn, cursor = make_mock_conn(fetchone_result=loan)
        mock_get_connection.return_value = conn

        with pytest.raises(ValueError, match="has already been returned"):
            return_item(loan_id=1)

    @patch("app.item_features.get_connection")
    def test_donate_item_success(self, mock_get_connection):
        """Test successful donation offer."""
        member = {"MemberID": 1, "FullName": "Test Member"}
        
        conn, cursor = make_mock_conn()
        cursor.fetchone.side_effect = [member, {"DonationOfferID": 1}]
        mock_get_connection.return_value = conn

        result = donate_item(member_id=1, description="Test Book Donation")

        assert result["MemberID"] == 1
        assert result["OfferDescription"] == "Test Book Donation"
        assert result["OfferStatus"] == "Pending"
        assert result["ProducedItemID"] is None
        assert result["ProducedCopyNumber"] is None
        assert "DonationOfferID" in result
        conn.commit.assert_called_once()

    @patch("app.item_features.get_connection")
    def test_donate_item_unknown_member(self, mock_get_connection):
        """Test that donating with unknown member raises error."""
        conn, cursor = make_mock_conn(fetchone_result=None)
        mock_get_connection.return_value = conn

        with pytest.raises(ValueError, match="No member found with id"):
            donate_item(member_id=999, description="Test Donation")

    @patch("app.item_features.get_connection")
    def test_donate_item_offer_status_pending(self, mock_get_connection):
        """Test that donation offer status is always 'Pending' initially."""
        member = {"MemberID": 1, "FullName": "Test Member"}
        conn, cursor = make_mock_conn()
        cursor.fetchone.side_effect = [member, {"DonationOfferID": 1}]
        mock_get_connection.return_value = conn

        result = donate_item(member_id=1, description="Test Book")

        assert result["OfferStatus"] == "Pending"
