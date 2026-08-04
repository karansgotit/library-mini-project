"""Tushar's four event and service application features."""

import os
import psycopg2
import psycopg2.extras
from database import *
 

def find_event(query: str):
    """Find matching library events."""
    sql = """
        SELECT event_id, name, description, room_id, organizer_id,
               start_time, end_time, status
        FROM event
        WHERE name ILIKE %(pattern)s
           OR description ILIKE %(pattern)s
        ORDER BY start_time ASC
    """
    with get_connection() as conn:
        with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
            cur.execute(sql, {"pattern": f"%{query}%"})
            return [dict(row) for row in cur.fetchall()]
 
 

def register_for_event(member_id: int, event_id: int):
     """Register a member for an event."""
     sql = """
        INSERT INTO registration (event_id, audience_id, status)
        VALUES (%(event_id)s, %(member_id)s, 'confirmed')
        ON CONFLICT (event_id, audience_id) DO NOTHING
        RETURNING registration_id, event_id, audience_id, status, registered_at
    """
     with get_connection() as conn:
         with conn.cursor(cursor_factory= psycopg2.extras.RealDictCursor) as cur:
             cur.execute(sql, {"member_id":member_id,"event_id":event_id})
             row = cur.fetchone()
             if row is None:
                 raise ValueError(
                     f"Member {member_id} is already registered for event {event_id}"
                 )
             return dict(row)


def volunteer(member_id: int, event_id: int):
    """Record a member's request to volunteer for an event."""
    lookup_sql = """
        SELECT first_name, last_name, email, phone
        FROM audience
        WHERE audience_id = %(member_id)s
    """
    insert_sql = """
        INSERT INTO volunteer
            (first_name, last_name, email, phone, event_id, audience_id)
        VALUES (%(first_name)s, %(last_name)s, %(email)s, %(phone)s,
                %(event_id)s, %(member_id)s)
        RETURNING volunteer_id, event_id, audience_id, role, created_at
    """
    with get_connection as conn:
        with conn.cursor(cursor_factory= psycopg2.extras.RealDictCursor) as cur:
            cur.execute(lookup_sql,{"member_id":member_id})
            member = cur.fetchone()
            if member is None:
                raise ValueError(
                    f"No audience member found with id {member_id}."
                )
            cur.execute(insert_sql,{
                "first_name": member["first_name"],
                "last_name": member["last_name"],
                "email": member["email"],
                "phone": member["phone"],
                "event_id": event_id,
                "member_id": member_id,
            })
            row = cur.fetchone()
            conn.commit()
            return dict(row)

def ask_librarian(member_id: int, question: str):
    """Submit a member's help request to a librarian."""
    sql = """
        INSERT INTO help_request (audience_id, subject, description, status)
        VALUES (%(member_id)s, %(subject)s, %(question)s, 'open')
        RETURNING help_request_id, audience_id, subject, status, created_at
    """
    subject = question if len(question) <= 200 else question[:197] + '...'
    with get_connection() as conn:
        with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
            cur.execute(sql,{
                "member_id": member_id,
                "subject": subject,
                "question": question,
            })
            row = cur.fetchone()
            conn.commit()
            return dict(row)
