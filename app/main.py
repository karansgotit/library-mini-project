"""Terminal menu for the library database application."""


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


def main() -> None:
    """Run the starter menu until the user exits."""
    while True:
        display_menu()
        choice = input("Choose an option: ").strip()

        if choice == "9":
            print("Goodbye.")
            return

        if choice in MENU_OPTIONS:
            print(f"{MENU_OPTIONS[choice]} is not implemented yet.")
        else:
            print("Please choose a number from 1 to 9.")


if __name__ == "__main__":
    main()
