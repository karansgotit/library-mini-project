CREATE TRIGGER PrintBookDisjointInsert
BEFORE INSERT ON PrintBook
WHEN EXISTS (SELECT 1 FROM Magazine WHERE ItemID = NEW.ItemID)
  OR EXISTS (SELECT 1 FROM Journal WHERE ItemID = NEW.ItemID)
  OR EXISTS (SELECT 1 FROM Record WHERE ItemID = NEW.ItemID)
  OR EXISTS (SELECT 1 FROM OnlineBook WHERE ItemID = NEW.ItemID)
BEGIN
    SELECT RAISE(ABORT, 'Item already belongs to another subtype');
END;

CREATE TRIGGER MagazineDisjointInsert
BEFORE INSERT ON Magazine
WHEN EXISTS (SELECT 1 FROM PrintBook WHERE ItemID = NEW.ItemID)
  OR EXISTS (SELECT 1 FROM Journal WHERE ItemID = NEW.ItemID)
  OR EXISTS (SELECT 1 FROM Record WHERE ItemID = NEW.ItemID)
  OR EXISTS (SELECT 1 FROM OnlineBook WHERE ItemID = NEW.ItemID)
BEGIN
    SELECT RAISE(ABORT, 'Item already belongs to another subtype');
END;

CREATE TRIGGER JournalDisjointInsert
BEFORE INSERT ON Journal
WHEN EXISTS (SELECT 1 FROM PrintBook WHERE ItemID = NEW.ItemID)
  OR EXISTS (SELECT 1 FROM Magazine WHERE ItemID = NEW.ItemID)
  OR EXISTS (SELECT 1 FROM Record WHERE ItemID = NEW.ItemID)
  OR EXISTS (SELECT 1 FROM OnlineBook WHERE ItemID = NEW.ItemID)
BEGIN
    SELECT RAISE(ABORT, 'Item already belongs to another subtype');
END;

CREATE TRIGGER RecordDisjointInsert
BEFORE INSERT ON Record
WHEN EXISTS (SELECT 1 FROM PrintBook WHERE ItemID = NEW.ItemID)
  OR EXISTS (SELECT 1 FROM Magazine WHERE ItemID = NEW.ItemID)
  OR EXISTS (SELECT 1 FROM Journal WHERE ItemID = NEW.ItemID)
  OR EXISTS (SELECT 1 FROM OnlineBook WHERE ItemID = NEW.ItemID)
BEGIN
    SELECT RAISE(ABORT, 'Item already belongs to another subtype');
END;

CREATE TRIGGER OnlineBookDisjointInsert
BEFORE INSERT ON OnlineBook
WHEN EXISTS (SELECT 1 FROM PrintBook WHERE ItemID = NEW.ItemID)
  OR EXISTS (SELECT 1 FROM Magazine WHERE ItemID = NEW.ItemID)
  OR EXISTS (SELECT 1 FROM Journal WHERE ItemID = NEW.ItemID)
  OR EXISTS (SELECT 1 FROM Record WHERE ItemID = NEW.ItemID)
BEGIN
    SELECT RAISE(ABORT, 'Item already belongs to another subtype');
END;

CREATE TRIGGER CopyEligibilityInsert
BEFORE INSERT ON Copy
BEGIN
    SELECT RAISE(ABORT, 'Copies may be added only to InCollection Items')
    WHERE (
        SELECT CollectionStatus
        FROM Item
        WHERE ItemID = NEW.ItemID
    ) <> 'InCollection';

    SELECT RAISE(ABORT, 'OnlineBook Items cannot have physical Copies')
    WHERE EXISTS (
        SELECT 1
        FROM OnlineBook
        WHERE ItemID = NEW.ItemID
    );
END;

CREATE TRIGGER OnlineBookRejectCopyInsert
BEFORE INSERT ON OnlineBook
WHEN EXISTS (
    SELECT 1
    FROM Copy
    WHERE ItemID = NEW.ItemID
)
BEGIN
    SELECT RAISE(ABORT, 'An Item with physical Copies cannot be an OnlineBook');
END;

CREATE TRIGGER LoanEligibilityInsert
BEFORE INSERT ON Loan
BEGIN
    SELECT RAISE(ABORT, 'Only Active Members may begin a Loan')
    WHERE (
        SELECT MembershipStatus
        FROM Member
        WHERE MemberID = NEW.MemberID
    ) <> 'Active';

    SELECT RAISE(ABORT, 'Only Usable Copies may be loaned')
    WHERE (
        SELECT Condition
        FROM Copy
        WHERE ItemID = NEW.ItemID
          AND CopyNumber = NEW.CopyNumber
    ) <> 'Usable';

    SELECT RAISE(ABORT, 'Only InCollection Items may be loaned')
    WHERE (
        SELECT CollectionStatus
        FROM Item
        WHERE ItemID = NEW.ItemID
    ) <> 'InCollection';

    SELECT RAISE(ABORT, 'Copy already has an active Loan')
    WHERE NEW.ReturnDate IS NULL
      AND EXISTS (
          SELECT 1
          FROM Loan
          WHERE ItemID = NEW.ItemID
            AND CopyNumber = NEW.CopyNumber
            AND ReturnDate IS NULL
      );
END;

CREATE TRIGGER EventIntegrityInsert
BEFORE INSERT ON Event
BEGIN
    SELECT RAISE(ABORT, 'Registration limit cannot exceed Room Capacity')
    WHERE NEW.RegistrationLimit IS NOT NULL
      AND NEW.RegistrationLimit > (
          SELECT Capacity
          FROM Room
          WHERE RoomID = NEW.RoomID
      );

    SELECT RAISE(ABORT, 'Event overlaps another Event in the same Room')
    WHERE NEW.EventStatus <> 'Cancelled'
      AND EXISTS (
          SELECT 1
          FROM Event
          WHERE RoomID = NEW.RoomID
            AND EventStatus <> 'Cancelled'
            AND NEW.StartDateTime < EndDateTime
            AND NEW.EndDateTime > StartDateTime
      );
END;

CREATE TRIGGER RegistrationCapacityInsert
BEFORE INSERT ON Registration
WHEN NEW.RegistrationStatus = 'Registered'
BEGIN
    SELECT RAISE(ABORT, 'Registration requires a Scheduled Event')
    WHERE (
        SELECT EventStatus
        FROM Event
        WHERE EventID = NEW.EventID
    ) <> 'Scheduled';

    SELECT RAISE(ABORT, 'Event registration capacity has been reached')
    WHERE (
        SELECT COUNT(*)
        FROM Registration
        WHERE EventID = NEW.EventID
          AND RegistrationStatus = 'Registered'
    ) >= (
        SELECT CASE
            WHEN Event.RegistrationLimit IS NULL THEN Room.Capacity
            ELSE Event.RegistrationLimit
        END
        FROM Event
        JOIN Room ON Room.RoomID = Event.RoomID
        WHERE Event.EventID = NEW.EventID
    );
END;
