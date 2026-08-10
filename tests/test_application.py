"""Basic checks for the application menu and its eight features."""

from unittest.mock import patch

from app.main import MENU_OPTIONS, main
from app.item_features import (
    LOAN_PERIOD_DAYS,
    borrow_item,
    donate_item,
    find_item,
    return_item,
)
from app.event_features import (
    ask_librarian,
    find_event,
    register_for_event,
    volunteer,
)


def test_menu_options():
    assert len(MENU_OPTIONS) == 9
    assert MENU_OPTIONS["1"] == 'Find an item'
    assert MENU_OPTIONS["2"] == 'Borrow an item'
    assert MENU_OPTIONS["3"] == 'Return an item'
    assert MENU_OPTIONS["4"] == 'Donate an item'
    assert MENU_OPTIONS["5"] == 'Find an event'
    assert MENU_OPTIONS["6"] == 'Register for an event'
    assert MENU_OPTIONS["7"] == 'Volunteer'
    assert MENU_OPTIONS["8"] == 'Ask a librarian for help'
    assert MENU_OPTIONS["9"] == 'Exit'

def test_loan_period_constant():
    assert LOAN_PERIOD_DAYS == 14


def test_feature_functions_are_available():
    assert callable(find_item)
    assert callable(borrow_item)
    assert callable(return_item)
    assert callable(donate_item)
    assert callable(find_event)
    assert callable(register_for_event)
    assert callable(volunteer)
    assert callable(ask_librarian)


def run_menu(inputs):
    """Run the menu with prepared user input."""
    with patch("builtins.input", side_effect=inputs):
        main()


@patch("app.main.find_item")
def test_find_item_menu_option(mock_find_item, capsys):
    mock_find_item.return_value = [
        {
            "ItemID": 2,
            "Title": "The Hobbit",
            "CreatorName": "J.R.R. Tolkien",
            "CollectionStatus": "InCollection",
        }
    ]

    run_menu(["1", "hobbit", "9"])

    mock_find_item.assert_called_once_with("hobbit")
    assert "The Hobbit" in capsys.readouterr().out


@patch("app.main.borrow_item")
def test_borrow_item_menu_option(mock_borrow_item, capsys):
    mock_borrow_item.return_value = {
        "LoanID": 11,
        "CopyNumber": 1,
        "DueDate": "2026-08-24",
    }

    run_menu(["2", "1", "2", "9"])

    mock_borrow_item.assert_called_once_with(1, 2)
    assert "Loan 11 created" in capsys.readouterr().out


@patch("app.main.return_item")
def test_return_item_menu_option(mock_return_item, capsys):
    mock_return_item.return_value = {
        "LoanID": 3,
        "ReturnDate": "2026-08-10",
    }

    run_menu(["3", "3", "9"])

    mock_return_item.assert_called_once_with(3)
    assert "Loan 3 returned" in capsys.readouterr().out


@patch("app.main.donate_item")
def test_donate_item_menu_option(mock_donate_item, capsys):
    mock_donate_item.return_value = {
        "DonationOfferID": 12,
        "OfferStatus": "Pending",
    }

    run_menu(["4", "1", "Three mystery novels", "9"])

    mock_donate_item.assert_called_once_with(1, "Three mystery novels")
    assert "Donation offer 12 submitted" in capsys.readouterr().out


@patch("app.main.find_event")
def test_find_event_menu_option(mock_find_event, capsys):
    mock_find_event.return_value = [
        {
            "EventID": 4,
            "EventTitle": "Teen Writing Workshop",
            "StartDateTime": "2026-08-12 13:00:00",
            "EventStatus": "Scheduled",
        }
    ]

    run_menu(["5", "workshop", "9"])

    mock_find_event.assert_called_once_with("workshop")
    assert "Teen Writing Workshop" in capsys.readouterr().out


@patch("app.main.register_for_event")
def test_register_for_event_menu_option(mock_register, capsys):
    mock_register.return_value = {"MemberID": 2, "EventID": 4}

    run_menu(["6", "2", "4", "9"])

    mock_register.assert_called_once_with(2, 4)
    assert "Member 2 registered for event 4" in capsys.readouterr().out


@patch("app.main.volunteer")
def test_volunteer_menu_option(mock_volunteer, capsys):
    mock_volunteer.return_value = {
        "VolunteerApplicationID": 13,
        "ApplicationStatus": "Pending",
    }

    run_menu(["7", "2", "", "9"])

    mock_volunteer.assert_called_once_with(2, None)
    assert "Volunteer application 13 submitted" in capsys.readouterr().out


@patch("app.main.ask_librarian")
def test_ask_librarian_menu_option(mock_ask_librarian, capsys):
    mock_ask_librarian.return_value = {
        "HelpRequestID": 14,
        "RequestStatus": "Pending",
    }

    run_menu(["8", "3", "How do I renew a book?", "9"])

    mock_ask_librarian.assert_called_once_with(3, "How do I renew a book?")
    assert "Help request 14 submitted" in capsys.readouterr().out


def test_invalid_menu_option(capsys):
    run_menu(["0", "9"])

    assert "Please choose a number from 1 to 9" in capsys.readouterr().out


@patch("app.main.borrow_item")
def test_invalid_id_does_not_call_feature(mock_borrow_item, capsys):
    run_menu(["2", "not a number", "9"])

    mock_borrow_item.assert_not_called()
    assert "Please enter a whole number" in capsys.readouterr().out


@patch("app.main.borrow_item")
def test_feature_error_is_displayed(mock_borrow_item, capsys):
    mock_borrow_item.side_effect = ValueError("No available copy")

    run_menu(["2", "1", "2", "9"])

    assert "Could not complete request: No available copy" in capsys.readouterr().out
