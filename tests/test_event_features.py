"""Tests for Tushar's four event and service features."""

import pytest
from unittest.mock import MagicMock, patch
from datetime import datetime

from app.event_features import (
    find_event,
    register_for_event,
    volunteer,
    ask_librarian,
)


def make_mock_conn(fetchone_result=None, fetchall_result=None):
    cursor = MagicMock()
    cursor.__enter__.return_value = cursor
    cursor.__exit__.return_value = False
    cursor.fetchone.return_value = fetchone_result
    cursor.fetchall.return_value = fetchall_result or []
    cursor.lastrowid = 1

    conn = MagicMock()
    conn.__enter__.return_value = conn
    conn.__exit__.return_value = False
    conn.cursor.return_value = cursor
    conn.execute.return_value = cursor
    return conn, cursor


@patch("app.event_features.get_connection")
def test_find_event_returns_matching_event(mock_get_connection):
    """Test that find_event returns matching events."""
    rows = [
        {
            "EventID": 1, 
            "EventTitle": "Data Science Workshop", 
            "Description": "ML basics",
            "EventCategory": "Workshop",
            "TargetAudience": "Students",
            "StartDateTime": "2026-08-12 13:00",
            "EndDateTime": "2026-08-12 17:00",
            "EventStatus": "Scheduled",
            "RegistrationLimit": 20,
            "RoomID": 6,
            "OrganizerStaffID": 1
        },
    ]
    conn, cursor = make_mock_conn(fetchall_result=rows)
    mock_get_connection.return_value = conn

    result = find_event("workshop")

    assert result == rows
    # Change this line:
    conn.execute.assert_called_once()  # Not cursor.execute
    # And update the params check:
    sql, params = conn.execute.call_args[0]
    assert params[0] == "%workshop%"
    assert params[1] == "%workshop%"


@patch("app.event_features.get_connection")
def test_find_event_no_matches_return_empty_list(mock_get_conn):
    """Test that find_event returns empty list when no matches found."""
    conn, cursor = make_mock_conn(fetchall_result=[])
    mock_get_conn.return_value = conn
    result = find_event("nonexistent event")
    assert result == []


@patch("app.event_features.get_connection")
def test_register_for_event_success(mock_get_conn):
    """Test successful event registration."""
    # Mock that no existing registration exists
    none_row = None
    # Mock the inserted registration
    row = {
        "MemberID": 2,
        "EventID": 1,
        "RegistrationDateTime": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "RegistrationStatus": "Registered"
    }
    
    conn, cursor = make_mock_conn()
    cursor.fetchone.side_effect = [none_row, row]
    cursor.lastrowid = 10
    mock_get_conn.return_value = conn

    result = register_for_event(member_id=2, event_id=1)
    
    assert result["MemberID"] == 2
    assert result["EventID"] == 1
    assert result["RegistrationStatus"] == "Registered"
    conn.commit.assert_called_once()


@patch("app.event_features.get_connection")
def test_register_for_event_already_registered(mock_get_conn):
    """Test that registering for an already registered event raises error."""
    row = {"MemberID": 1, "EventID": 1, "RegistrationStatus": "Registered"}
    conn, cursor = make_mock_conn(fetchone_result=row)
    mock_get_conn.return_value = conn

    with pytest.raises(ValueError, match="already registered"):
        register_for_event(member_id=1, event_id=1)


@patch("app.event_features.get_connection")
def test_volunteer_success(mock_get_conn):
    """Test successful volunteer application."""
    member = {"MemberID": 1, "FullName": "Emma Watson", "Email": "emma@example.com"}
    inserted = {
        "VolunteerApplicationID": 5,
        "MemberID": 1,
        "EventID": 4,
        "ApplicationDateTime": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "ApplicationStatus": "Pending"
    }

    conn, cursor = make_mock_conn()
    cursor.fetchone.side_effect = [member, inserted]
    cursor.lastrowid = 5
    mock_get_conn.return_value = conn

    result = volunteer(member_id=1, event_id=4)

    assert result["MemberID"] == 1
    assert result["EventID"] == 4
    assert result["ApplicationStatus"] == "Pending"
    assert "VolunteerApplicationID" in result
    conn.commit.assert_called_once()


@patch("app.event_features.get_connection")
def test_volunteer_unknown_member(mock_get_conn):
    """Test that volunteering with unknown member raises error."""
    conn, cursor = make_mock_conn(fetchone_result=None)
    mock_get_conn.return_value = conn

    with pytest.raises(ValueError, match="No member found with id"):
        volunteer(member_id=999, event_id=4)


@patch("app.event_features.get_connection")
def test_volunteer_general_no_event(mock_get_conn):
    """Test volunteering without a specific event."""
    member = {"MemberID": 1, "FullName": "Test User"}
    inserted = {
        "VolunteerApplicationID": 6,
        "MemberID": 1,
        "EventID": None,
        "ApplicationDateTime": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "ApplicationStatus": "Pending"
    }

    conn, cursor = make_mock_conn()
    cursor.fetchone.side_effect = [member, inserted]
    cursor.lastrowid = 6
    mock_get_conn.return_value = conn

    result = volunteer(member_id=1)

    assert result["MemberID"] == 1
    assert result["EventID"] is None
    assert result["ApplicationStatus"] == "Pending"
    conn.commit.assert_called_once()


@patch("app.event_features.get_connection")
def test_ask_librarian_success(mock_get_conn):
    """Test successful help request."""
    member = {"MemberID": 3, "FullName": "Test User"}
    row = {
        "HelpRequestID": 7,
        "MemberID": 3,
        "StaffID": None,
        "RequestDateTime": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "QuestionText": "Wifi not connecting",
        "RequestStatus": "Pending",
        "ResolvedDateTime": None
    }
    
    conn, cursor = make_mock_conn()
    cursor.fetchone.side_effect = [member, row]
    cursor.lastrowid = 7
    mock_get_conn.return_value = conn

    result = ask_librarian(member_id=3, question="Wifi not connecting")

    assert result["MemberID"] == 3
    assert result["QuestionText"] == "Wifi not connecting"
    assert result["RequestStatus"] == "Pending"
    assert result["StaffID"] is None
    conn.commit.assert_called_once()


@patch("app.event_features.get_connection")
def test_ask_librarian_unknown_member(mock_get_conn):
    """Test that asking with unknown member raises error."""
    conn, cursor = make_mock_conn(fetchone_result=None)
    mock_get_conn.return_value = conn

    with pytest.raises(ValueError, match="No member found with id"):
        ask_librarian(member_id=999, question="Help me")


@patch("app.event_features.get_connection")
def test_ask_librarian_long_question(mock_get_conn):
    """Test that long questions are handled correctly."""
    member = {"MemberID": 3, "FullName": "Test User"}
    long_question = "Why" * 100
    row = {
        "HelpRequestID": 8,
        "MemberID": 3,
        "StaffID": None,
        "RequestDateTime": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "QuestionText": long_question,
        "RequestStatus": "Pending",
        "ResolvedDateTime": None
    }
    
    conn, cursor = make_mock_conn()
    cursor.fetchone.side_effect = [member, row]
    cursor.lastrowid = 8
    mock_get_conn.return_value = conn

    result = ask_librarian(member_id=3, question=long_question)

    assert result["QuestionText"] == long_question
    assert result["RequestStatus"] == "Pending"
    conn.commit.assert_called_once()


@pytest.mark.skip(reason="Event features placeholder test")
def test_event_features_placeholder():
    """Placeholder for event features tests."""
    pass