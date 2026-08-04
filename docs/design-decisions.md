# Library Database Design Decisions

This document records the final design decisions for the library database mini
project. It consolidates the decisions made while reviewing the assignment,
redesigning the E/R model, translating it to relations, and implementing the
SQLite schema.

The revised conceptual model is the source of truth. The database, seed data,
application, tests, and written report should all be aligned with these
decisions.

## 1. Project scope

The database represents:

- library catalogue items and physical copies;
- members, loans, returns, and fines;
- future collection items and item donation offers;
- rooms, scheduled events, and intended audiences;
- event registrations and organizers;
- staff and departments;
- volunteer applications; and
- librarian help requests.

The application must support these eight features:

1. Find an item.
2. Borrow an item.
3. Return an item.
4. Donate an item.
5. Find an event.
6. Register for an event.
7. Volunteer for the library.
8. Ask a librarian for help.

The implementation database is SQLite. Facts that require cross-table checks
are enforced with SQLite triggers where possible.

## 2. General modelling decisions

### 2.1 Stable internal identifiers

Library-generated identifiers are used as primary keys for major entities.
Real-world identifiers such as ISBNs, ISSNs, room numbers, department names,
and email addresses are alternate identifiers rather than primary keys.

This keeps an entity's identity stable when a real-world label changes and
allows records to exist when an optional external identifier is unavailable.

### 2.2 Historical records are retained

Business events are normally retained and updated with a status instead of
being deleted. In particular:

- returned loans remain as loan history;
- paid or waived fines remain as fine history;
- cancelled registrations remain as registration history;
- cancelled events remain as event history;
- rejected or withdrawn applications remain as application history; and
- rejected donation offers remain as donation history.

### 2.3 Derived facts are not stored

The database does not store a separate `Available` or `Borrowed` value on a
physical copy. Availability is derived from both:

- the Copy's physical `Condition`; and
- whether the Copy currently has a Loan whose `ReturnDate` is null.

This avoids contradictory states such as a Copy marked available while it has
an active Loan.

### 2.4 SQLite date representation

Dates and date-times are stored as canonical sortable text:

- date: `YYYY-MM-DD`;
- date-time: `YYYY-MM-DD HH:MM:SS`.

SQLite date functions are used in `CHECK` constraints to reject malformed or
impossible values. Canonical text permits chronological comparisons without a
separate SQLite date type.

### 2.5 Money representation

Fine amounts are stored as integer cents in `AmountCents`, not floating-point
dollars. For example, $5.25 is stored as `525`. This avoids floating-point
rounding errors.

## 3. Item catalogue

### 3.1 Meaning of Item

An `Item` is a catalogue-level object, not one physical object. Depending on
the material, an Item represents a particular publication, edition, issue,
format, recording, or other catalogued collection object.

Examples:

- a particular print edition of a novel;
- one specific magazine issue;
- one specific scientific-journal issue;
- one sound-recording release; or
- one online-book edition.

Physical duplicates of the same Item are represented by separate `Copy`
records.

`ItemID` is the library-controlled primary key. `Title` is required but is not
unique because different catalogue objects can have the same title.

### 3.2 Collection status and future acquisitions

Every Item has one of these `CollectionStatus` values:

- `Prospective` — the library may add it in the future;
- `InCollection` — it is currently part of the collection; or
- `Removed` — it has been retired from the collection.

An Item may have zero Copies. Zero Copies alone does not determine its status,
because it could mean a prospective physical item, a currently accessible
online book, or a removed physical item.

Possible future acquisitions are represented as prospective Items. There is
no separate `AcquisitionRequest` entity because the project does not require a
requester, approval, supplier, ordering, or purchasing workflow.

A `Prospective` Item has no physical Copies. When the library acquires it,
staff first change its status to `InCollection` and then create its Copy
records. New Copies may be added only to `InCollection` Items. When an Item is
later changed to `Removed`, existing Copies remain to preserve Loan, Fine, and
donation history, but no new Copies may be added.

### 3.3 Creators and contributors

Creator information is modelled separately so the catalogue can support
searches such as "items by Margaret Atwood" and can represent works with more
than one creator.

`Creator` represents a person or organization associated with catalogue Items:

- `CreatorID` is the stable internal primary key;
- `CreatorName` is required but is not unique because different creators may
  share the same name; and
- detailed biographies, name aliases, and external authority identifiers are
  outside the current project scope.

Item and Creator have a many-to-many relationship implemented by
`ItemCreator`:

- one Item may have zero or many Creators;
- one Creator may be associated with zero or many Items;
- `CreatorRole` records how the Creator contributed to that Item; and
- the primary key is `(ItemID, CreatorID, CreatorRole)`, allowing the same
  Creator to hold multiple roles for one Item.

Supported roles are `Author`, `Artist`, `Editor`, `Illustrator`, `Translator`,
`Composer`, `Performer`, `Director`, `Photographer`, and `Contributor`.

An Item may have no Creator when the creator is unknown or inapplicable. The
Find Item feature searches CreatorName in addition to titles and item-specific
identifiers. Separate relations avoid storing several author or artist names
inside one text column and also support creators who contributed to several
Items.

### 3.4 Item specialization

The Item ISA specialization is **partial and disjoint**.

- Partial: an Item may belong to none of the listed subtypes. This supports
  other collection materials such as artifacts.
- Disjoint: an Item may belong to at most one listed subtype.

The explicit subtypes are:

- `PrintBook`;
- `Magazine`;
- `Journal`;
- `Record`; and
- `OnlineBook`.

If the same work exists in print and online formats, the formats are separate
Items with separate `ItemID` values.

### 3.5 PrintBook

- `ItemID` is inherited as the primary key.
- `ISBN` is optional.
- `ISBN` must be unique when present.
- ISBN is not a candidate key for the entire subtype because rare, donated,
  local, older, or privately distributed books may not have one.

One PrintBook Item represents a particular edition and format. Its physical
duplicates are Copies.

### 3.6 Magazine

One Magazine Item represents one specific published issue, not an entire
magazine series.

- `ItemID` is the inherited primary key.
- `ISSN` identifies the magazine series and therefore repeats across issues.
- `VolumeNumber` and `IssueNumber` are positive integers.
- `(ISSN, VolumeNumber, IssueNumber)` is an alternate candidate key.

### 3.7 Journal

One Journal Item represents one specific published journal issue, not the
entire journal series.

- `ItemID` is the inherited primary key.
- `ISSN` repeats across the journal series.
- `Volume` and `Issue` are positive integers.
- `(ISSN, Volume, Issue)` is an alternate candidate key.

### 3.8 Record

`Record` means a sound recording.

- `ItemID` is the inherited primary key.
- `RecordNumber` is the catalogue number assigned by a record label.
- Record numbers are not assumed to be globally unique across labels.
- `(LabelName, RecordNumber)` is an alternate candidate key.

### 3.9 OnlineBook

- `ItemID` is the inherited primary key.
- `ISBN` is optional and unique when present.
- `AccessURL` is required but is not a key because a provider may change the
  URL without changing the book's identity.
- An OnlineBook cannot have a physical Copy.

Online licence limits or concurrent digital checkouts are outside the project
scope.

## 4. Physical copies

`Copy` represents one physical object owned by the library.

Copy is a weak entity owned by Item:

- `CopyNumber` is assigned within an Item and may restart at 1 for another
  Item;
- the complete primary key is `(ItemID, CopyNumber)`;
- every Copy belongs to exactly one Item; and
- one Item may own zero or many Copies.

`Condition` describes physical state and has these values:

- `Usable`;
- `Damaged`;
- `UnderRepair`;
- `Lost`; and
- `Retired`.

Only a `Usable` Copy may begin a new Loan. Physical Items that do not belong to
one of the five explicit subtypes may still have Copies. OnlineBooks may not.
New Copies may be created only for Items whose CollectionStatus is
`InCollection`.

## 5. Members and borrowing

### 5.1 Member

`Member` represents one registered library member.

- `MemberID` is the primary key.
- `FullName` is required and need not be unique.
- `Email` is optional and unique when present.
- `Phone` is optional and is not unique.
- `MembershipStatus` is required and has values `Active`, `Suspended`, or
  `Expired`.

Suspended and expired Members remain in the database to preserve their
history. Only an `Active` Member may begin a new Loan.

### 5.2 Loan

`Loan` is a regular entity representing one checkout occurrence. It is not a
weak entity because it has its own primary key, `LoanID`.

This design permits the same Member to borrow the same Copy on different
occasions while retaining every occurrence separately.

Each Loan:

- belongs to exactly one Member;
- is for exactly one Copy;
- may begin only when that Copy's Item has `CollectionStatus = InCollection`;
- has a required `BorrowDate`;
- has a required `DueDate` that is not earlier than `BorrowDate`; and
- has an optional `ReturnDate` that is not earlier than `BorrowDate`.

A null `ReturnDate` means the Loan is active. A Copy may have many historical
Loans but at most one active Loan at a time.

Returning an item updates the existing Loan's `ReturnDate`; it does not delete
the Loan.

### 5.3 Fine

`Fine` is a weak entity owned by Loan.

- `FineNumber` is assigned within a Loan.
- The complete primary key is `(LoanID, FineNumber)`.
- Every Fine belongs to exactly one Loan.
- One Loan may have zero or many Fines.

A Loan may therefore have separate overdue, damage, and lost-item charges.

Fine decisions:

- `FineType`: `Overdue`, `Damage`, or `LostItem`;
- `AmountCents`: a positive integer;
- `AssessedDate`: required and cannot precede the Loan's `BorrowDate`;
- `Status`: `Unpaid`, `Paid`, or `Waived`; and
- `ResolvedDate`: null for an unpaid Fine and required for a paid or waived
  Fine; when present, it cannot precede `AssessedDate`.

## 6. Events and rooms

### 6.1 Meaning of Event

One `Event` represents one specific scheduled occurrence. Repeated weekly
meetings are separate Event records even when they share a title.

Event decisions:

- `EventID` is the primary key.
- `EventTitle` is required and not unique.
- `EventCategory` is required and supports searching or filtering. The exact
  category vocabulary is left to the sample data.
- `Description` is optional.
- `StartDateTime` and `EndDateTime` are required.
- `EndDateTime` must be later than `StartDateTime`.
- `EventStatus` is `Scheduled`, `Cancelled`, or `Completed`.
- Cancelled Events are retained rather than deleted.
- `CancellationReason` is required for a cancelled Event and null otherwise.
- `RegistrationLimit` is optional and must be positive when present.

### 6.2 Room

- `RoomID` is the stable internal primary key.
- `RoomNumber` is a required, unique, user-facing identifier stored as text so
  values such as `2109`, `B204`, and `LIB-305` are permitted.
- A separate `Location` attribute is omitted because the project models one
  library and the room number is sufficient.
- `Capacity` is a required positive physical occupancy limit.

Every Event is held in exactly one Room. Multi-room Events are outside this
project's chosen scope. A Room may host zero or many Events over time.

Two non-cancelled Events may not overlap in the same Room. End-to-start
adjacency is allowed; for example, an Event ending at 12:00 does not conflict
with one starting at 12:00.

### 6.3 Event registration limit

`Room.Capacity` is the physical occupancy limit. `Event.RegistrationLimit` is
an optional lower limit caused by supplies, staffing, or program needs.

- An Event's RegistrationLimit may not exceed its Room's Capacity.
- If RegistrationLimit is null, Room Capacity is the effective registration
  capacity.
- Lowering a Room's Capacity or an Event's limit may not invalidate existing
  active registrations.

## 7. Intended audiences and registration

### 7.1 Audience

`Audience` represents a reusable category of intended attendees, not an
individual person.

- `AudienceID` is the stable internal primary key.
- `AudienceName` is required and unique.
- Audience records form a controlled list.
- Audience categories may overlap because they are recommendation tags rather
  than mutually exclusive populations.

Examples include `School-Age Children`, `Teens`, `Adults`, `Families`,
`Parents/Caregivers`, `Educators`, and `Researchers`.

Event and Audience have a many-to-many `RecommendedFor` relationship:

- every Event must be recommended for at least one Audience; and
- one Audience may be recommended for zero or many Events.

### 7.2 Registration

`Registration` is the associative record between Member and Event.

- Every Registration belongs to exactly one Member and one Event.
- A Member may register for many Events.
- An Event may have many registrations.
- The primary key is `(MemberID, EventID)`.
- There is one evolving record per Member and Event; there is no separate
  `RegistrationID`.
- `RegistrationDateTime` records when the Member originally registered.
- `RegistrationStatus` is `Registered`, `Cancelled`, `Attended`, or `NoShow`.

Cancelling changes the existing row to `Cancelled` rather than deleting it. If
the Member later registers again for the same Event, that same row evolves
again. Separate registration-attempt history is intentionally not modelled.

Only `Registered` rows consume current event capacity. A Registration may
become `Registered` only while the Event is `Scheduled`.

## 8. Personnel and event organization

### 8.1 Staff

- `StaffID` is the primary key.
- `FullName` is required and need not be unique.
- `JobTitle` is required.
- `Email` is required and unique.
- `EmploymentStatus` is `Active`, `OnLeave`, or `Former`.
- `HireDate` is required.

Former and on-leave staff remain in the database so historical Events and help
requests retain their personnel references. Only active staff should normally
receive new assignments, although that administrative policy is not currently
enforced by a database trigger.

### 8.2 Department

- `DepartmentID` is the primary key.
- `DepartmentName` is required and unique.
- Every Staff member works in exactly one Department.
- A Department may have zero or many Staff members.

Department connects to the rest of the model through Staff rather than
directly organizing Events or handling requests.

### 8.3 Event organizers

Staff and Event have a many-to-many `Organizes` relationship:

- every Event must have at least one organizer;
- one Event may have several organizers; and
- one Staff member may organize zero or many Events.

The relation is implemented as `EventOrganizer(StaffID, EventID)`.

## 9. Volunteer applications

Volunteering is represented by `VolunteerApplication`, not by a duplicate
Volunteer person entity.

- Only registered Members submit volunteer applications.
- `VolunteerApplicationID` is the primary key because one Member may apply
  several times.
- `ApplicationDateTime` is required.
- `ApplicationStatus` is `Pending`, `Approved`, `Rejected`, or `Withdrawn`.
- Every application belongs to exactly one Member.
- An application may optionally refer to one Event.
- One Event may receive many volunteer applications.

The Event relationship is optional because volunteering may concern general
library work such as shelving or tutoring rather than a specific Event.

## 10. Librarian help requests

`HelpRequest` represents one occasion when a registered Member asks for help.

- `HelpRequestID` is the primary key.
- Every request belongs to exactly one Member.
- `RequestDateTime` and `QuestionText` are required.
- `RequestStatus` is `Pending`, `InProgress`, or `Resolved`.
- A request may initially have no assigned Staff member.
- At most one Staff member is responsible for a request.
- `InProgress` and `Resolved` requests require an assigned Staff member.
- `ResolvedDateTime` is required only for a resolved request and cannot precede
  `RequestDateTime`.

HelpRequest remains general and is not linked directly to Event. The question
may concern an Event, Item, Loan, research task, online access, or another
library service, so an Event-only subject link would be uneven.

## 11. Donation offers

`DonationOffer` covers offered collection material only. Monetary donations
are outside the project because they would require a separate financial model
with amounts, payment methods, receipts, and fund designations.

Donation decisions:

- One DonationOffer represents one offered physical object, not an entire
  batch.
- Only registered Members may submit offers.
- `DonationOfferID` is the primary key.
- `OfferDateTime` is required.
- `OfferDescription` is required and is used instead of the narrower
  `OfferedTitle`, allowing artifacts and untitled materials.
- `OfferStatus` is `Pending`, `Accepted`, or `Rejected`.

A DonationOffer has an optional one-to-one `MayProduce` relationship with
Copy:

- a pending or rejected offer produces no Copy;
- an accepted offer may temporarily have no Copy while staff process it;
- an accepted offer may ultimately produce at most one Copy;
- a Copy may originate from at most one DonationOffer; and
- a Copy may have no DonationOffer because it could have been purchased.

If the offered object matches an existing Item, acceptance creates a new Copy
of that Item. If it is a different edition or otherwise a distinct catalogue
object, the library creates a new Item and then its first Copy. For example, a
donated first edition is a different Item from a modern paperback edition of
the same title.

## 12. Relationship and participation summary

| Relationship | Decision |
| --- | --- |
| Item–Creator | Many-to-many through ItemCreator; CreatorRole distinguishes the contribution. |
| Item–Copy | One Item has 0..many Copies; every Copy has exactly one Item. |
| Member–Loan | One Member has 0..many Loans; every Loan has exactly one Member. |
| Copy–Loan | One Copy has 0..many historical Loans; every Loan has exactly one Copy. |
| Loan–Fine | One Loan has 0..many Fines; every Fine has exactly one Loan. |
| Room–Event | One Room has 0..many Events; every Event has exactly one Room. |
| Event–Audience | Many-to-many; every Event has at least one Audience. |
| Member–Registration | One Member has 0..many Registrations; each Registration has exactly one Member. |
| Event–Registration | One Event has 0..many Registrations; each Registration has exactly one Event. |
| Department–Staff | One Department has 0..many Staff; every Staff member has exactly one Department. |
| Staff–Event | Many-to-many; every Event has at least one organizer. |
| Member–VolunteerApplication | One Member has 0..many applications; each application has exactly one Member. |
| Event–VolunteerApplication | One Event has 0..many applications; an application has 0..1 Event. |
| Member–HelpRequest | One Member has 0..many requests; each request has exactly one Member. |
| Staff–HelpRequest | One Staff member handles 0..many requests; a request has 0..1 Staff member. |
| Member–DonationOffer | One Member has 0..many offers; each offer has exactly one Member. |
| DonationOffer–Copy | Optional one-to-one in both directions. |

## 13. Integrity enforcement decisions

The implementation divides integrity rules as follows:

### Ordinary table constraints

- primary and alternate keys;
- foreign keys;
- required attributes;
- controlled status and type values;
- controlled CreatorRole values;
- positive counts and monetary amounts;
- canonical date and date-time formats;
- chronological checks within one row;
- Fine status/resolution consistency;
- Event status/cancellation-reason consistency; and
- DonationOffer produced-Copy null-pair consistency.

### Partial unique index

`UniqueActiveLoanPerCopy` permits many historical Loans for a Copy but prevents
more than one Loan with a null `ReturnDate` for the same Copy.

### Cross-table triggers

- enforce disjoint Item subtypes;
- reject Copies for OnlineBooks in both insertion directions;
- permit new Copies only for `InCollection` Items;
- allow only Active Members and Usable Copies of `InCollection` Items to begin
  Loans;
- prevent a Fine from predating its Loan;
- prevent overlapping non-cancelled Events in one Room;
- prevent Event limits from exceeding Room Capacity;
- prevent registrations from exceeding the effective capacity;
- require a Scheduled Event for a `Registered` registration; and
- prevent an established Event from losing its last Audience or organizer.

### Final participation validation

SQLite cannot require EventAudience and EventOrganizer rows at the exact moment
an Event is inserted because the Event must exist before those relationship
rows can reference it. Event creation should therefore be performed as one
application transaction, followed by a validation query against
`EventParticipationViolations`.

A valid final database has zero rows in that view.

## 14. Feature coverage

| Required feature | Supporting relations |
| --- | --- |
| Find an item | Item, Creator, ItemCreator, subtypes, Copy |
| Borrow an item | Member, Item, Copy, Loan |
| Return an item | Loan, Copy |
| Donate an item | Member, DonationOffer, Item, Copy |
| Find an event | Event, Room, Audience, EventAudience |
| Register for an event | Member, Event, Registration, Room |
| Volunteer for the library | Member, VolunteerApplication, optional Event |
| Ask a librarian for help | Member, HelpRequest, Staff |

## 15. Explicit exclusions

The following are intentionally outside the chosen project scope:

- monetary donations;
- acquisition-request, supplier, ordering, and purchasing workflows;
- multi-room Events;
- separate digital licence and concurrent-access modelling;
- a separate Volunteer person entity;
- non-member registrations, volunteer applications, help requests, or
  donation offers;
- multiple simultaneous Staff handlers for one HelpRequest;
- a direct HelpRequest–Event relationship;
- a stored Copy availability flag;
- separate historical rows for repeated registration attempts by the same
  Member for the same Event; and
- detailed Creator biographies, aliases, and external authority identifiers.

## 16. E/R notation decisions

The diagram should express semantics using the notation taught in the CMPT 354
class deck:

- underline only the primary key in an entity;
- document alternate keys in the accompanying text because the class notation
  does not provide a distinct alternate-key symbol;
- use a double rectangle and identifying relationship for weak entities such
  as Copy and Fine;
- state that the Item ISA is partial and disjoint in words because the ISA
  triangle alone does not establish both facts;
- use the course's rounded-arrowhead notation for mandatory many-to-one
  participation rather than importing double participation lines from another
  E/R notation; and
- use an explicit `>= 1` degree constraint for the Event side of the
  many-to-many `RecommendedFor` and `Organizes` relationships.

The conceptual meaning in this document takes precedence if a drawing symbol
is ambiguous.

## 17. Schema file organization

- `database/schema/core.sql`: Member, Department, and Staff.
- `database/schema/items.sql`: Item, Creator, ItemCreator, subtypes, Copy,
  Loan, Fine, and DonationOffer.
- `database/schema/events.sql`: Room, Event, Audience, EventAudience,
  Registration, EventOrganizer, VolunteerApplication, and HelpRequest.
- `database/schema/integrity.sql`: cross-table triggers and validation views.
