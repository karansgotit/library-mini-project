"""Karan's four item-related application features."""


def find_item(query: str):
    """Find matching library items."""
    raise NotImplementedError("Find an item has not been implemented yet.")


def borrow_item(member_id: int, copy_id: int):
    """Borrow an available item copy for a member."""
    raise NotImplementedError("Borrow an item has not been implemented yet.")


def return_item(loan_id: int):
    """Return the item associated with an active loan."""
    raise NotImplementedError("Return an item has not been implemented yet.")


def donate_item(member_id: int, title: str):
    """Record a proposed item donation from a member."""
    raise NotImplementedError("Donate an item has not been implemented yet.")
