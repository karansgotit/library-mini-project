"""Item features for the library application."""

import sqlite3
from datetime import date, datetime, timedelta

from app.database import get_connection

LOAN_PERIOD_DAYS = 14


def find_item(query: str):
    """Find catalogue items whose title or creator matches the query."""
    pattern = f"%{query}%"
    with get_connection() as conn:
        rows = conn.execute(
            """
            SELECT ItemID, Title, CreatorName, CollectionStatus
            FROM Item
            WHERE Title LIKE ?
               OR CreatorName LIKE ?
            ORDER BY Title
            """,
            (pattern, pattern),
        ).fetchall()
        return [dict(row) for row in rows]


def borrow_item(member_id: int, item_id: int):
    """Borrow the first available copy of an item for a member."""
    with get_connection() as conn:
        copy_row = conn.execute(
            """
            SELECT Copy.CopyNumber
            FROM Copy
            JOIN Item ON Item.ItemID = Copy.ItemID
            WHERE Copy.ItemID = ?
              AND Copy.Condition = 'Usable'
              AND Item.CollectionStatus = 'InCollection'
              AND NOT EXISTS (
                  SELECT 1 FROM Loan
                  WHERE Loan.ItemID = Copy.ItemID
                    AND Loan.CopyNumber = Copy.CopyNumber
                    AND Loan.ReturnDate IS NULL
              )
            ORDER BY Copy.CopyNumber
            """,
            (item_id,),
        ).fetchone()

        if copy_row is None:
            raise ValueError(f"No available copy of item {item_id} to borrow.")

        copy_number = copy_row["CopyNumber"]
        borrow_date = date.today().isoformat()
        due_date = (date.today() + timedelta(days=LOAN_PERIOD_DAYS)).isoformat()

        try:
            cursor = conn.execute(
                """
                INSERT INTO Loan
                    (MemberID, ItemID, CopyNumber, BorrowDate, DueDate, ReturnDate)
                VALUES (?, ?, ?, ?, ?, NULL)
                RETURNING LoanID
                """,
                (member_id, item_id, copy_number, borrow_date, due_date),
            )
            loan_row = cursor.fetchone()
            conn.commit()
        except sqlite3.IntegrityError as exc:
            raise ValueError(str(exc)) from exc

        return {
            "LoanID": loan_row["LoanID"],
            "MemberID": member_id,
            "ItemID": item_id,
            "CopyNumber": copy_number,
            "BorrowDate": borrow_date,
            "DueDate": due_date,
            "ReturnDate": None,
        }


def return_item(loan_id: int):
    """Return the item associated with an active loan."""
    with get_connection() as conn:
        loan = conn.execute(
            "SELECT LoanID, ReturnDate FROM Loan WHERE LoanID = ?",
            (loan_id,),
        ).fetchone()

        if loan is None:
            raise ValueError(f"No loan found with id {loan_id}.")
        if loan["ReturnDate"] is not None:
            raise ValueError(f"Loan {loan_id} has already been returned.")

        return_date = date.today().isoformat()
        conn.execute(
            "UPDATE Loan SET ReturnDate = ? WHERE LoanID = ?",
            (return_date, loan_id),
        )
        conn.commit()

        updated = conn.execute(
            "SELECT * FROM Loan WHERE LoanID = ?", (loan_id,)
        ).fetchone()
        return dict(updated)


def donate_item(member_id: int, description: str):
    """Record a proposed item donation from a member."""
    with get_connection() as conn:
        member = conn.execute(
            "SELECT MemberID FROM Member WHERE MemberID = ?", (member_id,)
        ).fetchone()
        if member is None:
            raise ValueError(f"No member found with id {member_id}.")

        offer_datetime = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        cursor = conn.execute(
            """
            INSERT INTO DonationOffer
                (MemberID, OfferDateTime, OfferDescription, OfferStatus,
                 ProducedItemID, ProducedCopyNumber)
            VALUES (?, ?, ?, 'Pending', NULL, NULL)
            RETURNING DonationOfferID
            """,
            (member_id, offer_datetime, description),
        )
        donation_row = cursor.fetchone()
        conn.commit()

        return {
            "DonationOfferID": donation_row["DonationOfferID"],
            "MemberID": member_id,
            "OfferDateTime": offer_datetime,
            "OfferDescription": description,
            "OfferStatus": "Pending",
            "ProducedItemID": None,
            "ProducedCopyNumber": None,
        }
