# Library Database Design Decisions

This document records the final, reduced-scope design for the library database
mini project. The design intentionally prioritizes the assignment requirements
and a realistic two-student implementation over modelling every detail of a
production library system.

The E/R diagram, SQLite schema, seed data, application, tests, and written
report should all follow this document.

## 1. Project scope

The database represents:

- catalogue Items and physical Copies;
- Members, Loans, returns, and Fines;
- future Items and DonationOffers;
- Rooms, Events, and Registrations;
- Staff personnel records;
- VolunteerApplications; and
- librarian HelpRequests.

The application supports eight required features:

1. Find an item.
2. Borrow an item.
3. Return an item.
4. Donate an item.
5. Find an event.
6. Register for an event.
7. Volunteer for the library.
8. Ask a librarian for help.

The final implementation uses SQLite and contains 17 tables. The design keeps
foreign keys, basic domain constraints, one partial unique index, and ten
straightforward triggers.

## 2. Scope-control decisions

Several technically richer designs were considered and deliberately removed.
The final model uses:

- one optional creator display name directly on Item instead of separate
  Creator and ItemCreator tables;
- a department name directly on Staff instead of a Department table;
- one primary target audience directly on Event instead of Audience and
  EventAudience tables;
- one organizer foreign key directly on Event instead of an EventOrganizer
  table;
- plain SQLite TEXT columns for dates and date-times; and
- application validation for uncommon update cases and complicated status
  transitions.

These choices reduce seed-data, application, testing, and BCNF-report workload
while preserving every required feature.

## 3. General modelling conventions

### 3.1 Internal identifiers

Library-generated integer identifiers are used as primary keys for major
entities. Real-world identifiers such as ISBN, ISSN, room number, and email
are alternate identifiers where appropriate.

### 3.2 Historical records

Loans, Fines, Registrations, Events, applications, help requests, and donation
offers are retained as history. Status or return/resolution fields are updated
instead of deleting the record during ordinary workflows.

### 3.3 Derived availability

Copy availability is not stored. A Copy is available when:

- its Condition is `Usable`; and
- it has no Loan whose ReturnDate is null.

The database therefore avoids a separate availability flag that could
contradict Loan data.

### 3.4 Dates and date-times

Dates and date-times are stored as TEXT. The application and seed data use
consistent ISO-style values:

- date: `YYYY-MM-DD`;
- date-time: `YYYY-MM-DD HH:MM:SS`.

The schema does not use SQLite date-function format checks. Simple
chronological comparisons rely on the application storing this consistent
format.

### 3.5 Money

Fine amounts are stored as integer cents in AmountCents. For example, $5.25 is
stored as `525`, avoiding floating-point rounding problems.

## 4. Item catalogue

### 4.1 Item meaning

An Item is a catalogue-level record, not an individual physical object. It
represents a publication, edition, issue, format, recording, or another
catalogued collection object.

Item attributes are:

- `ItemID`: library-generated primary key;
- `Title`: required and not unique;
- `CreatorName`: optional searchable display text; and
- `CollectionStatus`: `Prospective`, `InCollection`, or `Removed`.

CreatorName may contain a primary creator or a simple display credit. For
example, a multi-author work may use `Neil Gaiman and Terry Pratchett`. The
project does not separately identify, relate, or assign roles to individual
creators.

### 4.2 Collection status

- `Prospective` means the library may acquire the Item later.
- `InCollection` means it is currently part of the collection.
- `Removed` means the library no longer offers it as an active collection
  Item.

A Prospective Item has no physical Copies. Staff first change the status to
InCollection and then create Copy records. New Copies may be added only to
InCollection Items.

When an Item becomes Removed, existing Copies remain so historical Loans,
Fines, and DonationOffers continue to reference valid records. No new Copies
are added to a Removed Item, and its Copies cannot begin new Loans.

Possible future acquisitions are represented by Prospective Items. There is
no separate acquisition-request, supplier, ordering, or purchasing workflow.

### 4.3 Item specialization

The Item ISA specialization is partial and disjoint.

- Partial: an Item may belong to none of the five explicit subtypes, allowing
  other collection materials.
- Disjoint: an Item may belong to at most one explicit subtype.

The five subtypes are PrintBook, Magazine, Journal, Record, and OnlineBook.
Different formats of the same work are separate Items with separate ItemID
values.

### 4.4 PrintBook

- ItemID is the inherited primary key.
- ISBN is optional and unique when present.
- ISBN is not a key for every PrintBook because older, rare, local, or donated
  books may not have one.

### 4.5 Magazine

One Magazine Item represents one specific published issue.

- ItemID is the inherited primary key.
- `(ISSN, VolumeNumber, IssueNumber)` is an alternate key.
- VolumeNumber and IssueNumber must be positive.

### 4.6 Journal

One Journal Item represents one specific journal issue.

- ItemID is the inherited primary key.
- `(ISSN, Volume, Issue)` is an alternate key.
- Volume and Issue must be positive.

### 4.7 Record

Record means a sound recording.

- ItemID is the inherited primary key.
- `(LabelName, RecordNumber)` is an alternate key.
- RecordNumber alone is not assumed to be unique across labels.

### 4.8 OnlineBook

- ItemID is the inherited primary key.
- ISBN is optional and unique when present.
- AccessURL is required but is not a key.
- An OnlineBook cannot have a physical Copy.

Digital licence and concurrent-access modelling are outside the project scope.

## 5. Physical Copies

Copy is a weak entity representing one physical library object.

- CopyNumber is assigned within an Item.
- The primary key is `(ItemID, CopyNumber)`.
- Every Copy belongs to exactly one Item.
- One Item may have zero or many Copies.

Condition has these values:

- `Usable`;
- `Damaged`;
- `UnderRepair`;
- `Lost`; and
- `Retired`.

Only Usable Copies of InCollection Items may begin new Loans.

## 6. Members, Loans, and Fines

### 6.1 Member

- MemberID is the primary key.
- FullName is required and not unique.
- Email is optional and unique when present.
- Phone is optional and not unique.
- MembershipStatus is `Active`, `Suspended`, or `Expired`.

Only Active Members may begin new Loans. Suspended and Expired Members remain
in the database to preserve history.

### 6.2 Loan

Loan represents one checkout occurrence and uses LoanID as its primary key.
This permits the same Member to borrow the same Copy on separate occasions.

Every Loan:

- belongs to exactly one Member;
- refers to exactly one Copy;
- has a BorrowDate and DueDate; and
- has an optional ReturnDate.

DueDate cannot be earlier than BorrowDate. ReturnDate, when present, cannot be
earlier than BorrowDate. A null ReturnDate means the Loan is active.

A Copy may have many historical Loans but at most one active Loan. Returning
an Item updates ReturnDate instead of deleting the Loan.

### 6.3 Fine

Fine is a weak entity owned by Loan.

- The primary key is `(LoanID, FineNumber)`.
- One Loan may have zero or many Fines.
- FineType is `Overdue`, `Damage`, or `LostItem`.
- AmountCents is positive.
- Status is `Unpaid`, `Paid`, or `Waived`.
- AssessedDate is required and ResolvedDate is optional.

Detailed consistency among Fine Status and ResolvedDate is handled by the
application rather than a complicated table CHECK.

## 7. Staff personnel records

Staff contains:

- StaffID as the primary key;
- required FullName;
- required JobTitle;
- required unique Email;
- EmploymentStatus of `Active`, `OnLeave`, or `Former`;
- required HireDate; and
- required DepartmentName.

DepartmentName is stored directly on Staff. The project does not maintain a
separate list of departments or department-specific facts.

Former and OnLeave Staff remain in the database for historical references.

## 8. Rooms and Events

### 8.1 Room

- RoomID is the primary key.
- RoomNumber is required and unique.
- Capacity is a required positive integer.

RoomNumber is TEXT so identifiers such as `2109`, `B204`, or `LIB-305` are
allowed. A separate Location field and multi-branch modelling are outside the
project scope.

### 8.2 Event

One Event represents one scheduled occurrence. Repeated meetings are separate
Event records even when they share a title.

Event contains:

- EventID as the primary key;
- required EventTitle and EventCategory;
- optional Description;
- one required TargetAudience description;
- required StartDateTime and EndDateTime;
- EventStatus of `Scheduled`, `Cancelled`, or `Completed`;
- optional positive RegistrationLimit;
- optional CancellationReason;
- exactly one Room; and
- exactly one organizing Staff member through OrganizerStaffID.

EndDateTime must be later than StartDateTime. Cancelled Events remain in the
database as history. CancellationReason consistency is handled by the
application rather than a conditional CHECK.

The project records one primary target audience per Event rather than a
controlled reusable audience list. It also records one organizer rather than
multiple organizers.

### 8.3 Scheduling and capacity

Two non-cancelled Events may not overlap in the same Room when they are
created. End-to-start adjacency is allowed.

Room Capacity is the physical maximum. RegistrationLimit is an optional lower
event-specific limit. When RegistrationLimit is null, Room Capacity is the
effective registration capacity.

The insert trigger rejects an Event whose RegistrationLimit exceeds its Room
Capacity. Event schedule and capacity updates are validated by the Python
application.

## 9. Registrations

Registration connects one Member with one Event.

- The primary key is `(MemberID, EventID)`.
- RegistrationDateTime is required.
- RegistrationStatus is `Registered`, `Cancelled`, `Attended`, or `NoShow`.
- A Member may register for many Events.
- An Event may receive many Registrations.

There is one evolving record per Member and Event. Cancellation changes the
status instead of deleting the row. Separate registration-attempt history is
not modelled.

Only Registered rows consume capacity. A new Registered row requires a
Scheduled Event and an available place. Registration-status updates are
validated by the application.

## 10. Volunteer applications

VolunteerApplication represents a Member's request to volunteer.

- VolunteerApplicationID is the primary key.
- Every application belongs to one Member.
- EventID is optional because volunteering may be general library work.
- ApplicationDateTime is required.
- ApplicationStatus is `Pending`, `Approved`, `Rejected`, or `Withdrawn`.

There is no separate Volunteer person table.

## 11. Librarian HelpRequests

HelpRequest represents one occasion when a registered Member asks for help.

- HelpRequestID is the primary key.
- Every request belongs to one Member.
- StaffID is optional while the request is unassigned.
- RequestDateTime and QuestionText are required.
- RequestStatus is `Pending`, `InProgress`, or `Resolved`.
- ResolvedDateTime is optional.

Staff assignment and ResolvedDateTime consistency are maintained by the
application. HelpRequest remains general and is not directly tied to Event or
Item.

## 12. DonationOffers

DonationOffer represents one physical collection object offered by a
registered Member. Monetary donations are outside the project scope.

- DonationOfferID is the primary key.
- MemberID, OfferDateTime, and OfferDescription are required.
- OfferStatus is `Pending`, `Accepted`, or `Rejected`.
- ProducedItemID and ProducedCopyNumber may optionally identify the resulting
  Copy.
- A Copy may be produced by at most one DonationOffer.

The Python application ensures that only an Accepted offer is linked to a
produced Copy and supplies both parts of the Copy key together.

If the offered object matches an existing Item, acceptance may create a new
Copy of that Item. A distinct edition or other catalogue object first becomes
a new InCollection Item and then receives its first Copy.

## 13. Relationship summary

| Relationship | Decision |
| --- | --- |
| Item–Copy | One Item has 0..many Copies; each Copy has exactly one Item. |
| Member–Loan | One Member has 0..many Loans; each Loan has exactly one Member. |
| Copy–Loan | One Copy has 0..many historical Loans; each Loan has exactly one Copy. |
| Loan–Fine | One Loan has 0..many Fines; each Fine has exactly one Loan. |
| Room–Event | One Room has 0..many Events; each Event has exactly one Room. |
| Staff–Event | One Staff member organizes 0..many Events; each Event has exactly one organizer. |
| Member–Registration | One Member has 0..many Registrations; each Registration has exactly one Member. |
| Event–Registration | One Event has 0..many Registrations; each Registration has exactly one Event. |
| Member–VolunteerApplication | One Member has 0..many applications; each application has exactly one Member. |
| Event–VolunteerApplication | One Event has 0..many applications; an application has 0..1 Event. |
| Member–HelpRequest | One Member has 0..many requests; each request has exactly one Member. |
| Staff–HelpRequest | One Staff member handles 0..many requests; a request has 0..1 Staff member. |
| Member–DonationOffer | One Member has 0..many offers; each offer has exactly one Member. |
| DonationOffer–Copy | An offer produces 0..1 Copy; a Copy comes from 0..1 offer. |

## 14. SQLite integrity enforcement

### 14.1 Table constraints

The schema uses:

- primary and alternate UNIQUE keys;
- foreign keys;
- NOT NULL constraints;
- basic status and type enums;
- positive-number checks; and
- simple within-row chronological checks for Loans and Events.

### 14.2 Active-Loan index

`UniqueActiveLoanPerCopy` prevents more than one Loan with a null ReturnDate
for the same `(ItemID, CopyNumber)`. It permits any number of returned
historical Loans.

### 14.3 Ten insert triggers

The schema keeps ten focused triggers:

1. Five subtype-insert triggers enforce disjoint Item specialization.
2. CopyEligibilityInsert permits physical Copies only for InCollection,
   non-OnlineBook Items.
3. OnlineBookRejectCopyInsert prevents classifying an Item with Copies as an
   OnlineBook.
4. LoanEligibilityInsert requires an Active Member, a Usable Copy, and an
   InCollection Item.
5. EventIntegrityInsert prevents room conflicts and limits above Room
   Capacity.
6. RegistrationCapacityInsert requires a Scheduled Event with remaining
   capacity.

The schema has no integrity views and no update-direction triggers. The Python
application validates updates that could affect these rules. Primary and
foreign-key identity columns are treated as immutable by the application.

## 15. Feature coverage

| Required feature | Supporting tables |
| --- | --- |
| Find an item | Item, subtype tables, Copy |
| Borrow an item | Member, Item, Copy, Loan |
| Return an item | Loan, Copy |
| Donate an item | Member, DonationOffer, Item, Copy |
| Find an event | Event, Room, Staff |
| Register for an event | Member, Event, Registration, Room |
| Volunteer for the library | Member, VolunteerApplication, optional Event |
| Ask a librarian for help | Member, HelpRequest, Staff |

## 16. Explicit exclusions

The project intentionally excludes:

- normalized individual creators and multiple creator roles;
- a separate Department entity;
- reusable or multiple Audience categories per Event;
- multiple organizers per Event;
- monetary donations;
- acquisition-request, supplier, ordering, and purchasing workflows;
- multi-room Events;
- digital licences and concurrent online access;
- a separate Volunteer person entity;
- non-member registrations, applications, help requests, or donation offers;
- multiple simultaneous Staff handlers for one HelpRequest;
- a direct HelpRequest–Event relationship;
- a stored Copy availability flag;
- separate registration-attempt history; and
- exhaustive database enforcement of every update and status transition.

## 17. E/R notation

The E/R diagram follows the CMPT 354 class notation:

- underline only primary keys;
- document alternate keys in accompanying text;
- use weak-entity notation for Copy and Fine;
- state in words that the Item ISA is partial and disjoint; and
- use the course's participation and arrowhead notation rather than mixing
  symbols from another E/R notation.

## 18. Schema organization

- `database/schema/core.sql`: Member and Staff.
- `database/schema/items.sql`: Item, five subtype tables, Copy, Loan, Fine, and
  DonationOffer.
- `database/schema/events.sql`: Room, Event, Registration,
  VolunteerApplication, and HelpRequest.
- `database/schema/integrity.sql`: ten insert-focused triggers.
