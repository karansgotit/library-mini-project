"""Tushar's four event and service application features."""

import sqlite3
from datetime import datetime

from database import get_connection


def find_event(query: str):
    """Find matching library events."""
    pattern = f"%{query}%"
    with get_connection() as conn:
        rows = conn.execute(
            """
            SELECT EventID, EventTitle, EventCategory, Description,
                   TargetAudience, StartDateTime, EndDateTime, EventStatus,
                   RegistrationLimit, RoomID, OrganizerStaffID
            FROM Event
            WHERE EventTitle LIKE ? COLLATE NOCASE
               OR Description LIKE ? COLLATE NOCASE
            ORDER BY StartDateTime ASC
            """,
            (pattern, pattern),
        ).fetchall()
        return [dict(row) for row in rows]


def register_for_event(member_id: int, event_id: int):
    """Register a member for an event."""
    with get_connection() as conn:
        existing = conn.execute(
            "SELECT 1 FROM Registration WHERE MemberID = ? AND EventID = ?",
            (member_id, event_id),
        ).fetchone()
        if existing is not None:
            raise ValueError(
                f"Member {member_id} is already registered for event {event_id}"
            )

        registered_at = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        try:
            conn.execute(
                """
                INSERT INTO Registration
                    (MemberID, EventID, RegistrationDateTime, RegistrationStatus)
                VALUES (?, ?, ?, 'Registered')
                """,
                (member_id, event_id, registered_at),
            )
            conn.commit()
        except sqlite3.IntegrityError as exc:
            raise ValueError(str(exc)) from exc

        return {
            "MemberID": member_id,
            "EventID": event_id,
            "RegistrationDateTime": registered_at,
            "RegistrationStatus": "Registered",
        }


def volunteer(member_id: int, event_id: int = None):
    """Record a member's request to volunteer, optionally for a specific event."""
    with get_connection() as conn:
        member = conn.execute(
            "SELECT MemberID FROM Member WHERE MemberID = ?", (member_id,)
        ).fetchone()
        if member is None:
            raise ValueError(f"No member found with id {member_id}.")

        applied_at = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        try:
            cursor = conn.execute(
                """
                INSERT INTO VolunteerApplication
                    (MemberID, EventID, ApplicationDateTime, ApplicationStatus)
                VALUES (?, ?, ?, 'Pending')
                """,
                (member_id, event_id, applied_at),
            )
            conn.commit()
        except sqlite3.IntegrityError as exc:
            raise ValueError(str(exc)) from exc

        return {
            "VolunteerApplicationID": cursor.lastrowid,
            "MemberID": member_id,
            "EventID": event_id,
            "ApplicationDateTime": applied_at,
            "ApplicationStatus": "Pending",
        }


def ask_librarian(member_id: int, question: str):
    """Submit a member's help request to a librarian."""
    with get_connection() as conn:
        member = conn.execute(
            "SELECT MemberID FROM Member WHERE MemberID = ?", (member_id,)
        ).fetchone()
        if member is None:
            raise ValueError(f"No member found with id {member_id}.")

        requested_at = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        cursor = conn.execute(
            """
            INSERT INTO HelpRequest
                (MemberID, StaffID, RequestDateTime, QuestionText,
                 RequestStatus, ResolvedDateTime)
            VALUES (?, NULL, ?, ?, 'Pending', NULL)
            """,
            (member_id, requested_at, question),
        )
        conn.commit()

        return {
            "HelpRequestID": cursor.lastrowid,
            "MemberID": member_id,
            "StaffID": None,
            "RequestDateTime": requested_at,
            "QuestionText": question,
            "RequestStatus": "Pending",
            "ResolvedDateTime": None,
        }