

CREATE VIEW ItemSubtypeMembership AS
SELECT ItemID, 'PrintBook' AS SubtypeName FROM PrintBook
UNION ALL
SELECT ItemID, 'Magazine' FROM Magazine
UNION ALL
SELECT ItemID, 'Journal' FROM Journal
UNION ALL
SELECT ItemID, 'Record' FROM Record
UNION ALL
SELECT ItemID, 'OnlineBook' FROM OnlineBook;

CREATE TRIGGER PrintBookDisjointInsert
BEFORE INSERT ON PrintBook
WHEN EXISTS (
    SELECT 1
    FROM ItemSubtypeMembership
    WHERE ItemID = NEW.ItemID
      AND SubtypeName <> 'PrintBook'
)
BEGIN
    SELECT RAISE(ABORT, 'Item already belongs to another subtype');
END;

CREATE TRIGGER PrintBookDisjointUpdate
BEFORE UPDATE OF ItemID ON PrintBook
WHEN EXISTS (
    SELECT 1
    FROM ItemSubtypeMembership
    WHERE ItemID = NEW.ItemID
      AND SubtypeName <> 'PrintBook'
)
BEGIN
    SELECT RAISE(ABORT, 'Item already belongs to another subtype');
END;

CREATE TRIGGER MagazineDisjointInsert
BEFORE INSERT ON Magazine
WHEN EXISTS (
    SELECT 1
    FROM ItemSubtypeMembership
    WHERE ItemID = NEW.ItemID
      AND SubtypeName <> 'Magazine'
)
BEGIN
    SELECT RAISE(ABORT, 'Item already belongs to another subtype');
END;

CREATE TRIGGER MagazineDisjointUpdate
BEFORE UPDATE OF ItemID ON Magazine
WHEN EXISTS (
    SELECT 1
    FROM ItemSubtypeMembership
    WHERE ItemID = NEW.ItemID
      AND SubtypeName <> 'Magazine'
)
BEGIN
    SELECT RAISE(ABORT, 'Item already belongs to another subtype');
END;

CREATE TRIGGER JournalDisjointInsert
BEFORE INSERT ON Journal
WHEN EXISTS (
    SELECT 1
    FROM ItemSubtypeMembership
    WHERE ItemID = NEW.ItemID
      AND SubtypeName <> 'Journal'
)
BEGIN
    SELECT RAISE(ABORT, 'Item already belongs to another subtype');
END;

CREATE TRIGGER JournalDisjointUpdate
BEFORE UPDATE OF ItemID ON Journal
WHEN EXISTS (
    SELECT 1
    FROM ItemSubtypeMembership
    WHERE ItemID = NEW.ItemID
      AND SubtypeName <> 'Journal'
)
BEGIN
    SELECT RAISE(ABORT, 'Item already belongs to another subtype');
END;

CREATE TRIGGER RecordDisjointInsert
BEFORE INSERT ON Record
WHEN EXISTS (
    SELECT 1
    FROM ItemSubtypeMembership
    WHERE ItemID = NEW.ItemID
      AND SubtypeName <> 'Record'
)
BEGIN
    SELECT RAISE(ABORT, 'Item already belongs to another subtype');
END;

CREATE TRIGGER RecordDisjointUpdate
BEFORE UPDATE OF ItemID ON Record
WHEN EXISTS (
    SELECT 1
    FROM ItemSubtypeMembership
    WHERE ItemID = NEW.ItemID
      AND SubtypeName <> 'Record'
)
BEGIN
    SELECT RAISE(ABORT, 'Item already belongs to another subtype');
END;

CREATE TRIGGER OnlineBookDisjointInsert
BEFORE INSERT ON OnlineBook
WHEN EXISTS (
    SELECT 1
    FROM ItemSubtypeMembership
    WHERE ItemID = NEW.ItemID
      AND SubtypeName <> 'OnlineBook'
)
BEGIN
    SELECT RAISE(ABORT, 'Item already belongs to another subtype');
END;

CREATE TRIGGER OnlineBookDisjointUpdate
BEFORE UPDATE OF ItemID ON OnlineBook
WHEN EXISTS (
    SELECT 1
    FROM ItemSubtypeMembership
    WHERE ItemID = NEW.ItemID
      AND SubtypeName <> 'OnlineBook'
)
BEGIN
    SELECT RAISE(ABORT, 'Item already belongs to another subtype');
END;


CREATE TRIGGER CopyRequireInCollectionInsert
BEFORE INSERT ON Copy
WHEN (
    SELECT CollectionStatus
    FROM Item
    WHERE ItemID = NEW.ItemID
) IS NOT 'InCollection'
BEGIN
    SELECT RAISE(ABORT, 'Copies may be added only to InCollection Items');
END;

CREATE TRIGGER CopyRequireInCollectionUpdate
BEFORE UPDATE OF ItemID ON Copy
WHEN (
    SELECT CollectionStatus
    FROM Item
    WHERE ItemID = NEW.ItemID
) IS NOT 'InCollection'
BEGIN
    SELECT RAISE(ABORT, 'Copies may be added only to InCollection Items');
END;

CREATE TRIGGER CopyRejectOnlineBookInsert
BEFORE INSERT ON Copy
WHEN EXISTS (
    SELECT 1
    FROM OnlineBook
    WHERE ItemID = NEW.ItemID
)
BEGIN
    SELECT RAISE(ABORT, 'OnlineBook items cannot have physical copies');
END;

CREATE TRIGGER CopyRejectOnlineBookUpdate
BEFORE UPDATE OF ItemID ON Copy
WHEN EXISTS (
    SELECT 1
    FROM OnlineBook
    WHERE ItemID = NEW.ItemID
)
BEGIN
    SELECT RAISE(ABORT, 'OnlineBook items cannot have physical copies');
END;

CREATE TRIGGER OnlineBookRejectCopyInsert
BEFORE INSERT ON OnlineBook
WHEN EXISTS (
    SELECT 1
    FROM Copy
    WHERE ItemID = NEW.ItemID
)
BEGIN
    SELECT RAISE(ABORT, 'An Item with physical copies cannot be an OnlineBook');
END;

CREATE TRIGGER OnlineBookRejectCopyUpdate
BEFORE UPDATE OF ItemID ON OnlineBook
WHEN EXISTS (
    SELECT 1
    FROM Copy
    WHERE ItemID = NEW.ItemID
)
BEGIN
    SELECT RAISE(ABORT, 'An Item with physical copies cannot be an OnlineBook');
END;


CREATE TRIGGER LoanEligibilityInsert
BEFORE INSERT ON Loan
BEGIN
    SELECT RAISE(ABORT, 'Only Active members may begin a loan')
    WHERE (
        SELECT MembershipStatus
        FROM Member
        WHERE MemberID = NEW.MemberID
    ) IS NOT 'Active';

    SELECT RAISE(ABORT, 'Only Usable copies may be loaned')
    WHERE (
        SELECT Condition
        FROM Copy
        WHERE ItemID = NEW.ItemID
          AND CopyNumber = NEW.CopyNumber
    ) IS NOT 'Usable';

    SELECT RAISE(ABORT, 'Only Copies of InCollection Items may be loaned')
    WHERE (
        SELECT CollectionStatus
        FROM Item
        WHERE ItemID = NEW.ItemID
    ) IS NOT 'InCollection';
END;

CREATE TRIGGER LoanEligibilityUpdate
BEFORE UPDATE OF MemberID, ItemID, CopyNumber, ReturnDate ON Loan
WHEN NEW.ReturnDate IS NULL
BEGIN
    SELECT RAISE(ABORT, 'Only Active members may begin a loan')
    WHERE (
        SELECT MembershipStatus
        FROM Member
        WHERE MemberID = NEW.MemberID
    ) IS NOT 'Active';

    SELECT RAISE(ABORT, 'Only Usable copies may be loaned')
    WHERE (
        SELECT Condition
        FROM Copy
        WHERE ItemID = NEW.ItemID
          AND CopyNumber = NEW.CopyNumber
    ) IS NOT 'Usable';

    SELECT RAISE(ABORT, 'Only Copies of InCollection Items may be loaned')
    WHERE (
        SELECT CollectionStatus
        FROM Item
        WHERE ItemID = NEW.ItemID
    ) IS NOT 'InCollection';
END;

CREATE TRIGGER FineAssessmentDateInsert
BEFORE INSERT ON Fine
WHEN NEW.AssessedDate < (
    SELECT BorrowDate
    FROM Loan
    WHERE LoanID = NEW.LoanID
)
BEGIN
    SELECT RAISE(ABORT, 'Fine cannot be assessed before the loan begins');
END;

CREATE TRIGGER FineAssessmentDateUpdate
BEFORE UPDATE OF LoanID, AssessedDate ON Fine
WHEN NEW.AssessedDate < (
    SELECT BorrowDate
    FROM Loan
    WHERE LoanID = NEW.LoanID
)
BEGIN
    SELECT RAISE(ABORT, 'Fine cannot be assessed before the loan begins');
END;


CREATE TRIGGER EventRoomConflictInsert
BEFORE INSERT ON Event
WHEN NEW.EventStatus <> 'Cancelled'
 AND EXISTS (
    SELECT 1
    FROM Event AS ExistingEvent
    WHERE ExistingEvent.RoomID = NEW.RoomID
      AND ExistingEvent.EventStatus <> 'Cancelled'
      AND NEW.StartDateTime < ExistingEvent.EndDateTime
      AND NEW.EndDateTime > ExistingEvent.StartDateTime
)
BEGIN
    SELECT RAISE(ABORT, 'Event overlaps another event in the same room');
END;

CREATE TRIGGER EventRoomConflictUpdate
BEFORE UPDATE OF EventID, RoomID, StartDateTime, EndDateTime, EventStatus
ON Event
WHEN NEW.EventStatus <> 'Cancelled'
 AND EXISTS (
    SELECT 1
    FROM Event AS ExistingEvent
    WHERE ExistingEvent.EventID <> OLD.EventID
      AND ExistingEvent.RoomID = NEW.RoomID
      AND ExistingEvent.EventStatus <> 'Cancelled'
      AND NEW.StartDateTime < ExistingEvent.EndDateTime
      AND NEW.EndDateTime > ExistingEvent.StartDateTime
)
BEGIN
    SELECT RAISE(ABORT, 'Event overlaps another event in the same room');
END;


CREATE TRIGGER EventCapacityInsert
BEFORE INSERT ON Event
WHEN NEW.RegistrationLimit IS NOT NULL
 AND NEW.RegistrationLimit > (
    SELECT Capacity
    FROM Room
    WHERE RoomID = NEW.RoomID
)
BEGIN
    SELECT RAISE(ABORT, 'Registration limit cannot exceed room capacity');
END;

CREATE TRIGGER EventCapacityUpdate
BEFORE UPDATE OF EventID, RoomID, RegistrationLimit ON Event
BEGIN
    SELECT RAISE(ABORT, 'Registration limit cannot exceed room capacity')
    WHERE NEW.RegistrationLimit IS NOT NULL
      AND NEW.RegistrationLimit > (
          SELECT Capacity
          FROM Room
          WHERE RoomID = NEW.RoomID
      );

    SELECT RAISE(ABORT, 'Event capacity is below its active registrations')
    WHERE (
        SELECT COUNT(*)
        FROM Registration
        WHERE EventID = OLD.EventID
          AND RegistrationStatus = 'Registered'
    ) > (
        SELECT COALESCE(NEW.RegistrationLimit, Capacity)
        FROM Room
        WHERE RoomID = NEW.RoomID
    );
END;

CREATE TRIGGER RoomCapacityUpdate
BEFORE UPDATE OF Capacity ON Room
WHEN EXISTS (
    SELECT 1
    FROM Event
    WHERE RoomID = OLD.RoomID
      AND (
          (RegistrationLimit IS NOT NULL
           AND RegistrationLimit > NEW.Capacity)
          OR
          (
              SELECT COUNT(*)
              FROM Registration
              WHERE Registration.EventID = Event.EventID
                AND RegistrationStatus = 'Registered'
          ) > COALESCE(RegistrationLimit, NEW.Capacity)
      )
)
BEGIN
    SELECT RAISE(ABORT, 'Room capacity is below an event limit or registration count');
END;

CREATE TRIGGER RegistrationCapacityInsert
BEFORE INSERT ON Registration
WHEN NEW.RegistrationStatus = 'Registered'
BEGIN
    SELECT RAISE(ABORT, 'Registration requires a Scheduled event')
    WHERE (
        SELECT EventStatus
        FROM Event
        WHERE EventID = NEW.EventID
    ) IS NOT 'Scheduled';

    SELECT RAISE(ABORT, 'Event registration capacity has been reached')
    WHERE (
        SELECT COUNT(*)
        FROM Registration
        WHERE EventID = NEW.EventID
          AND RegistrationStatus = 'Registered'
    ) >= (
        SELECT COALESCE(Event.RegistrationLimit, Room.Capacity)
        FROM Event
        JOIN Room ON Room.RoomID = Event.RoomID
        WHERE Event.EventID = NEW.EventID
    );
END;

CREATE TRIGGER RegistrationCapacityUpdate
BEFORE UPDATE OF MemberID, EventID, RegistrationStatus ON Registration
WHEN NEW.RegistrationStatus = 'Registered'
BEGIN
    SELECT RAISE(ABORT, 'Registration requires a Scheduled event')
    WHERE (
        SELECT EventStatus
        FROM Event
        WHERE EventID = NEW.EventID
    ) IS NOT 'Scheduled';

    SELECT RAISE(ABORT, 'Event registration capacity has been reached')
    WHERE (
        SELECT COUNT(*)
        FROM Registration
        WHERE EventID = NEW.EventID
          AND RegistrationStatus = 'Registered'
          AND NOT (
              MemberID = OLD.MemberID
              AND EventID = OLD.EventID
          )
    ) >= (
        SELECT COALESCE(Event.RegistrationLimit, Room.Capacity)
        FROM Event
        JOIN Room ON Room.RoomID = Event.RoomID
        WHERE Event.EventID = NEW.EventID
    );
END;


CREATE TRIGGER EventAudienceKeepAtLeastOneDelete
BEFORE DELETE ON EventAudience
WHEN (
    SELECT COUNT(*)
    FROM EventAudience
    WHERE EventID = OLD.EventID
) = 1
BEGIN
    SELECT RAISE(ABORT, 'An Event must have at least one intended audience');
END;

CREATE TRIGGER EventAudienceKeepAtLeastOneUpdate
BEFORE UPDATE OF EventID ON EventAudience
WHEN NEW.EventID <> OLD.EventID
 AND (
    SELECT COUNT(*)
    FROM EventAudience
    WHERE EventID = OLD.EventID
) = 1
BEGIN
    SELECT RAISE(ABORT, 'An Event must have at least one intended audience');
END;

CREATE TRIGGER EventOrganizerKeepAtLeastOneDelete
BEFORE DELETE ON EventOrganizer
WHEN (
    SELECT COUNT(*)
    FROM EventOrganizer
    WHERE EventID = OLD.EventID
) = 1
BEGIN
    SELECT RAISE(ABORT, 'An Event must have at least one organizer');
END;

CREATE TRIGGER EventOrganizerKeepAtLeastOneUpdate
BEFORE UPDATE OF EventID ON EventOrganizer
WHEN NEW.EventID <> OLD.EventID
 AND (
    SELECT COUNT(*)
    FROM EventOrganizer
    WHERE EventID = OLD.EventID
) = 1
BEGIN
    SELECT RAISE(ABORT, 'An Event must have at least one organizer');
END;

CREATE VIEW EventParticipationViolations AS
SELECT EventID, 'MissingAudience' AS Violation
FROM Event
WHERE NOT EXISTS (
    SELECT 1
    FROM EventAudience
    WHERE EventAudience.EventID = Event.EventID
)
UNION ALL
SELECT EventID, 'MissingOrganizer'
FROM Event
WHERE NOT EXISTS (
    SELECT 1
    FROM EventOrganizer
    WHERE EventOrganizer.EventID = Event.EventID
);
