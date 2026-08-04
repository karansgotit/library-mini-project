
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

CREATE TABLE Department (
    DepartmentID    INTEGER PRIMARY KEY,
    DepartmentName  TEXT NOT NULL UNIQUE
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
    HireDate          TEXT NOT NULL
        CHECK (HireDate IS date(HireDate, '+0 days')),
    DepartmentID      INTEGER NOT NULL,

    FOREIGN KEY (DepartmentID)
        REFERENCES Department(DepartmentID)
);

CREATE INDEX StaffDepartmentIndex
ON Staff(DepartmentID);
