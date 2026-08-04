CREATE TABLE Room (
    RoomID      INTEGER PRIMARY KEY,
    RoomNumber  TEXT NOT NULL UNIQUE,
    Capacity    INTEGER NOT NULL,

    CHECK (Capacity > 0)
);

CREATE TABLE Event (
    EventID             INTEGER PRIMARY KEY,
    EventTitle          TEXT NOT NULL,
    EventCategory       TEXT NOT NULL,
    Description         TEXT,
    TargetAudience      TEXT NOT NULL,
    StartDateTime       TEXT NOT NULL,
    EndDateTime         TEXT NOT NULL,
    EventStatus         TEXT NOT NULL
        CHECK (EventStatus IN (
            'Scheduled',
            'Cancelled',
            'Completed'
        )),
    RegistrationLimit   INTEGER,
    CancellationReason  TEXT,
    RoomID              INTEGER NOT NULL,
    OrganizerStaffID    INTEGER NOT NULL,

    FOREIGN KEY (RoomID)
        REFERENCES Room(RoomID),

    FOREIGN KEY (OrganizerStaffID)
        REFERENCES Staff(StaffID),

    CHECK (EndDateTime > StartDateTime),
    CHECK (
        RegistrationLimit IS NULL
        OR RegistrationLimit > 0
    )
);

CREATE TABLE Registration (
    MemberID              INTEGER NOT NULL,
    EventID               INTEGER NOT NULL,
    RegistrationDateTime  TEXT NOT NULL,
    RegistrationStatus    TEXT NOT NULL
        CHECK (RegistrationStatus IN (
            'Registered',
            'Cancelled',
            'Attended',
            'NoShow'
        )),

    PRIMARY KEY (MemberID, EventID),

    FOREIGN KEY (MemberID)
        REFERENCES Member(MemberID),

    FOREIGN KEY (EventID)
        REFERENCES Event(EventID)
);

CREATE TABLE VolunteerApplication (
    VolunteerApplicationID  INTEGER PRIMARY KEY,
    MemberID                 INTEGER NOT NULL,
    EventID                  INTEGER,
    ApplicationDateTime      TEXT NOT NULL,
    ApplicationStatus        TEXT NOT NULL
        CHECK (ApplicationStatus IN (
            'Pending',
            'Approved',
            'Rejected',
            'Withdrawn'
        )),

    FOREIGN KEY (MemberID)
        REFERENCES Member(MemberID),

    FOREIGN KEY (EventID)
        REFERENCES Event(EventID)
);

CREATE TABLE HelpRequest (
    HelpRequestID     INTEGER PRIMARY KEY,
    MemberID          INTEGER NOT NULL,
    StaffID           INTEGER,
    RequestDateTime   TEXT NOT NULL,
    QuestionText      TEXT NOT NULL,
    RequestStatus     TEXT NOT NULL
        CHECK (RequestStatus IN (
            'Pending',
            'InProgress',
            'Resolved'
        )),
    ResolvedDateTime  TEXT,

    FOREIGN KEY (MemberID)
        REFERENCES Member(MemberID),

    FOREIGN KEY (StaffID)
        REFERENCES Staff(StaffID)
);

CREATE INDEX EventRoomIndex
ON Event(RoomID);

CREATE INDEX EventOrganizerStaffIndex
ON Event(OrganizerStaffID);

CREATE INDEX RegistrationEventIndex
ON Registration(EventID);

CREATE INDEX VolunteerApplicationMemberIndex
ON VolunteerApplication(MemberID);

CREATE INDEX VolunteerApplicationEventIndex
ON VolunteerApplication(EventID);

CREATE INDEX HelpRequestMemberIndex
ON HelpRequest(MemberID);

CREATE INDEX HelpRequestStaffIndex
ON HelpRequest(StaffID);

CREATE INDEX HelpRequestStatusIndex
ON HelpRequest(RequestStatus);
