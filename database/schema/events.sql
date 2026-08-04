
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
    StartDateTime       TEXT NOT NULL
        CHECK (StartDateTime IS datetime(StartDateTime, '+0 seconds')),
    EndDateTime         TEXT NOT NULL
        CHECK (EndDateTime IS datetime(EndDateTime, '+0 seconds')),
    EventStatus         TEXT NOT NULL
        CHECK (EventStatus IN (
            'Scheduled',
            'Cancelled',
            'Completed'
        )),
    RegistrationLimit   INTEGER,
    CancellationReason  TEXT,
    RoomID              INTEGER NOT NULL,

    FOREIGN KEY (RoomID)
        REFERENCES Room(RoomID),

    CHECK (EndDateTime > StartDateTime),
    CHECK (
        RegistrationLimit IS NULL
        OR RegistrationLimit > 0
    ),
    CHECK (
        (
            EventStatus = 'Cancelled'
            AND CancellationReason IS NOT NULL
        )
        OR
        (
            EventStatus IN ('Scheduled', 'Completed')
            AND CancellationReason IS NULL
        )
    )
);

CREATE TABLE Audience (
    AudienceID    INTEGER PRIMARY KEY,
    AudienceName  TEXT NOT NULL UNIQUE
);

CREATE TABLE EventAudience (
    EventID     INTEGER NOT NULL,
    AudienceID  INTEGER NOT NULL,

    PRIMARY KEY (EventID, AudienceID),

    FOREIGN KEY (EventID)
        REFERENCES Event(EventID),

    FOREIGN KEY (AudienceID)
        REFERENCES Audience(AudienceID)
);

CREATE TABLE Registration (
    MemberID              INTEGER NOT NULL,
    EventID               INTEGER NOT NULL,
    RegistrationDateTime  TEXT NOT NULL
        CHECK (
            RegistrationDateTime IS
            datetime(RegistrationDateTime, '+0 seconds')
        ),
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

CREATE TABLE EventOrganizer (
    StaffID  INTEGER NOT NULL,
    EventID  INTEGER NOT NULL,

    PRIMARY KEY (StaffID, EventID),

    FOREIGN KEY (StaffID)
        REFERENCES Staff(StaffID),

    FOREIGN KEY (EventID)
        REFERENCES Event(EventID)
);

CREATE TABLE VolunteerApplication (
    VolunteerApplicationID  INTEGER PRIMARY KEY,
    MemberID                 INTEGER NOT NULL,
    EventID                  INTEGER,
    ApplicationDateTime      TEXT NOT NULL
        CHECK (
            ApplicationDateTime IS
            datetime(ApplicationDateTime, '+0 seconds')
        ),
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
    RequestDateTime   TEXT NOT NULL
        CHECK (
            RequestDateTime IS datetime(RequestDateTime, '+0 seconds')
        ),
    QuestionText      TEXT NOT NULL,
    RequestStatus     TEXT NOT NULL
        CHECK (RequestStatus IN (
            'Pending',
            'InProgress',
            'Resolved'
        )),
    ResolvedDateTime  TEXT
        CHECK (
            ResolvedDateTime IS NULL
            OR ResolvedDateTime IS datetime(ResolvedDateTime, '+0 seconds')
        ),

    FOREIGN KEY (MemberID)
        REFERENCES Member(MemberID),

    FOREIGN KEY (StaffID)
        REFERENCES Staff(StaffID),

    CHECK (
        ResolvedDateTime IS NULL
        OR ResolvedDateTime >= RequestDateTime
    ),
    CHECK (
        (
            RequestStatus = 'Pending'
            AND ResolvedDateTime IS NULL
        )
        OR
        (
            RequestStatus = 'InProgress'
            AND StaffID IS NOT NULL
            AND ResolvedDateTime IS NULL
        )
        OR
        (
            RequestStatus = 'Resolved'
            AND StaffID IS NOT NULL
            AND ResolvedDateTime IS NOT NULL
        )
    )
);

CREATE INDEX EventRoomIndex
ON Event(RoomID);

CREATE INDEX EventAudienceAudienceIndex
ON EventAudience(AudienceID);

CREATE INDEX RegistrationEventIndex
ON Registration(EventID);

CREATE INDEX EventOrganizerEventIndex
ON EventOrganizer(EventID);

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
