"""Karan-owned terminal menu integrating all eight application features."""

import sqlite3

from app.event_features import (
    ask_librarian,
    find_event,
    register_for_event,
    volunteer,
)
from app.item_features import borrow_item, donate_item, find_item, return_item


MENU_OPTIONS = {
    "1": "Find an item",
    "2": "Borrow an item",
    "3": "Return an item",
    "4": "Donate an item",
    "5": "Find an event",
    "6": "Register for an event",
    "7": "Volunteer",
    "8": "Ask a librarian for help",
    "9": "Exit",
}


def display_menu() -> None:
    """Display every application option."""
    print("\nLIBRARY DATABASE APPLICATION")
    for number, label in MENU_OPTIONS.items():
        print(f"{number}. {label}")


def read_id(prompt: str) -> int:
    """Read a required whole-number ID."""
    value = input(prompt).strip()
    if value == "":
        raise ValueError("An ID is required.")
    try:
        return int(value)
    except ValueError:
        raise ValueError("Please enter a whole number.")


def read_text(prompt: str) -> str:
    """Read required text from the user."""
    value = input(prompt).strip()
    if value == "":
        raise ValueError("Please enter some text.")
    return value


def read_optional_id(prompt: str):
    """Read an optional whole-number ID."""
    value = input(prompt).strip()
    if value == "":
        return None
    try:
        return int(value)
    except ValueError:
        raise ValueError("Please enter a whole number.")


def display_items(items) -> None:
    """Display item search results."""
    if not items:
        print("No matching items found.")
        return

    for item in items:
        creator = item["CreatorName"] or "Unknown creator"
        print(
            f"Item {item['ItemID']}: {item['Title']} by {creator} "
            f"[{item['CollectionStatus']}]"
        )


def display_events(events) -> None:
    """Display event search results."""
    if not events:
        print("No matching events found.")
        return

    for event in events:
        print(
            f"Event {event['EventID']}: {event['EventTitle']} - "
            f"{event['StartDateTime']} [{event['EventStatus']}]"
        )


def main() -> None:
    """Run the library application until the user exits."""
    while True:
        display_menu()
        choice = input("Choose an option: ").strip()

        if choice == "9":
            print("Goodbye.")
            return

        if choice not in MENU_OPTIONS:
            print("Please choose a number from 1 to 9.")
            continue

        try:
            if choice == "1":
                query = read_text("Enter an item title or creator: ")
                display_items(find_item(query))

            elif choice == "2":
                member_id = read_id("Enter member ID: ")
                item_id = read_id("Enter item ID: ")
                loan = borrow_item(member_id, item_id)
                print(
                    f"Loan {loan['LoanID']} created. "
                    f"Copy {loan['CopyNumber']} is due {loan['DueDate']}."
                )

            elif choice == "3":
                loan_id = read_id("Enter loan ID: ")
                loan = return_item(loan_id)
                print(
                    f"Loan {loan['LoanID']} returned on "
                    f"{loan['ReturnDate']}."
                )

            elif choice == "4":
                member_id = read_id("Enter member ID: ")
                description = read_text("Describe the item donation: ")
                donation = donate_item(member_id, description)
                print(
                    f"Donation offer {donation['DonationOfferID']} submitted "
                    f"with status {donation['OfferStatus']}."
                )

            elif choice == "5":
                query = read_text("Enter an event title or description: ")
                display_events(find_event(query))

            elif choice == "6":
                member_id = read_id("Enter member ID: ")
                event_id = read_id("Enter event ID: ")
                registration = register_for_event(member_id, event_id)
                print(
                    f"Member {registration['MemberID']} registered for "
                    f"event {registration['EventID']}."
                )

            elif choice == "7":
                member_id = read_id("Enter member ID: ")
                event_id = read_optional_id(
                    "Enter event ID, or press Enter for general volunteering: "
                )
                application = volunteer(member_id, event_id)
                print(
                    f"Volunteer application "
                    f"{application['VolunteerApplicationID']} submitted "
                    f"with status {application['ApplicationStatus']}."
                )

            elif choice == "8":
                member_id = read_id("Enter member ID: ")
                question = read_text("Enter your question: ")
                request = ask_librarian(member_id, question)
                print(
                    f"Help request {request['HelpRequestID']} submitted "
                    f"with status {request['RequestStatus']}."
                )

        except (ValueError, sqlite3.Error) as exc:
            print(f"Could not complete request: {exc}")


if __name__ == "__main__":
    main()
