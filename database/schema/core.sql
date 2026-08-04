PRAGMA foreign_keys = ON;

CREATE TABLE Member (
    MemberID          INTEGER PRIMARY KEY,
    FullName          TEXT NOT NULL,
    Email             TEXT UNIQUE,
    Phone             TEXT,
    MembershipStatus  TEXT NOT NULL
        CHECK (MembershipStatus IN (
            'Active',
            'Suspended',
            'Expired'
        ))
);

CREATE TABLE Staff (
    StaffID           INTEGER PRIMARY KEY,
    FullName          TEXT NOT NULL,
    JobTitle          TEXT NOT NULL,
    Email             TEXT NOT NULL UNIQUE,
    EmploymentStatus  TEXT NOT NULL
        CHECK (EmploymentStatus IN (
            'Active',
            'OnLeave',
            'Former'
        )),
    HireDate          TEXT NOT NULL,
    DepartmentName    TEXT NOT NULL
);
