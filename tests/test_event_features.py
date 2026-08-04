"""Tests for Tushar's four event and service features."""

import pytest
from unittest.mock import MagicMock, patch

@pytest.mark.skip(reason="Event features have not been implemented yet.")
def test_event_features_placeholder():
    pass

from app.event_features import (
    find_event,
    register_for_event,
    volunteer,
    ask_librarian,
)


def make_mock_conn(fetchone_result = None, fetchall_result = None):
    cursor = MagicMock()
    cursor.__enter__.return_value = cursor
    cursor.__exit__.return_value = False
    cursor.fetchone.return_value = fetchone_result
    cursor.fetchall.return_value = fetchall_result or []

    conn = MagicMock()
    conn.__enter__.return_value = conn
    conn.__exit__.return_value = False
    conn.cursor.return_value = cursor
    return conn, cursor

@patch("app.event_features.get_connection")
def test_find_event_returns_matching_event(mock_get_connection):
    rows = [
        {"event_id": 1, "name": "Data Science Workshop", "description": "ML basics",
         "room_id": 6, "organizer_id": 1, "start_time": "2026-08-12 13:00",
         "end_time": "2026-08-12 17:00", "status": "scheduled"},
    ]
    conn, cursor = make_mock_conn(fetchall_result=rows)
    mock_get_connection.return_value = conn

    result = find_event("workshop")

    assert result == rows
    cursor.execute.assert_called_once()
    sql,params = cursor.execute.call_args[0]
    assert params["pattern"] == "%workshop%"


@patch("app.event_features.get_connection")
def test_find_event_no_matches_return_empty_list(mock_get_conn):
    conn,cursor = make_mock_conn(fetchall_result=[])
    mock_get_conn.return_value = conn
    result = find_event("nonexistent event")
    assert result == []

@patch("app.event_features.get_connection")
def test_register_for_event_suc(mock_get_conn):
    row = {
        "registration_id": 10, "event_id": 1, "audience_id": 2,
        "status": "confirmed", "registered_at": "2026-08-01 10:00",
    }

    conn,cursor = make_mock_conn(fetchone_result=row)
    mock_get_conn.return_value = conn

    result = register_for_event(member_id=2,event_id=1)
    assert result == row 
    conn.commit.assert_called_once()


@patch("app.event_features.get_connection")
def test_register_for_event_already_registered_for(mock_get_conn):
    conn,cursor = make_mock_conn(fetchone_result=None)
    mock_get_conn.return_value = conn
    with pytest.raises(ValueError):
        register_for_event(member_id=2,event_id=1)

@patch("app.event_features.get_connection")
def test_volunteer_success(mock_get_conn):
    member = {"first_name": "Emma", "last_name": "Watson",
              "email": "emma.watson@example.com", "phone": "555-0201"}
    inserted = {"volunteer_id": 5, "event_id": 4, "audience_id": 1,
                "role": None, "created_at": "2026-08-01 09:00"}

    conn,cursor = make_mock_conn()
    cursor.fetchone.side_effect = [member,inserted]
    mock_get_conn.return_value = conn

    result = volunteer(member_id=1,event_id=4)

    assert result == inserted
    conn.commit.assert_called_once()


@patch("app.event_features.get_connection")
def test_volunteer_uknown_member(mock_get_conn):
    conn,cursor = make_mock_conn(fetchone_result=None)
    mock_get_conn.return_value = conn

    with pytest.raises(ValueError):
        volunteer(member_id=999,event_id=4)

@patch("app.event_features.get_connection")
def test_ask_librarian_succ(mock_get_conn):
    row = {"help_request_id": 7, "audience_id": 3, "subject": "Wifi not connecting",
           "status": "open", "created_at": "2026-08-01 11:00"}
    conn,cursor = make_mock_conn(fetchone_result=row)
    mock_get_conn.return_value = conn

    result = ask_librarian(member_id=3,question="Wifi not connecting")

    assert result == row
    conn.commit.assert_called_once()


@patch("app.event_features.get_connection")
def test_ask_librarian_trunc_long_ques_for_subject(mock_get_conn):
    long_ques = "Why" * 100
    conn,cursor = make_mock_conn(fetchone_result={"help_request_id":8})
    mock_get_conn.return_value = conn

    ask_librarian(member_id=3,question=long_ques)
    _,params = cursor.execute.call_args[0]
    assert len(params["subject"]) <= 200
    assert params["question"] == long_ques