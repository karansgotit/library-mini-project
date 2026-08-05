"""Karan-owned end-to-end tests for the complete library application."""

import pytest

import pytest
from app.main import *
from app.database import *
from app.item_features import *
from app.event_features import *


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

def test_features_func():
    assert callable(find_item)
    assert callable(borrow_item)
    assert callable(return_item)
    assert callable(donate_item)
    assert callable(find_event)
    assert callable(register_for_event)
    assert callable(volunteer)
    assert callable(ask_librarian) 