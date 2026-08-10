"""Basic checks for the application menu and its eight features."""

from app.main import MENU_OPTIONS
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
