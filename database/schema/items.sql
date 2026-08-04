CREATE TABLE Item (
    ItemID            INTEGER PRIMARY KEY,
    Title             TEXT NOT NULL,
    CreatorName       TEXT,
    CollectionStatus  TEXT NOT NULL
        CHECK (CollectionStatus IN (
            'Prospective',
            'InCollection',
            'Removed'
        ))
);

CREATE TABLE PrintBook (
    ItemID  INTEGER PRIMARY KEY,
    ISBN    TEXT UNIQUE,

    FOREIGN KEY (ItemID)
        REFERENCES Item(ItemID)
        ON DELETE CASCADE
);

CREATE TABLE Magazine (
    ItemID        INTEGER PRIMARY KEY,
    ISSN          TEXT NOT NULL,
    VolumeNumber  INTEGER NOT NULL,
    IssueNumber   INTEGER NOT NULL,

    UNIQUE (ISSN, VolumeNumber, IssueNumber),

    FOREIGN KEY (ItemID)
        REFERENCES Item(ItemID)
        ON DELETE CASCADE,

    CHECK (VolumeNumber > 0),
    CHECK (IssueNumber > 0)
);

CREATE TABLE Journal (
    ItemID  INTEGER PRIMARY KEY,
    ISSN    TEXT NOT NULL,
    Volume  INTEGER NOT NULL,
    Issue   INTEGER NOT NULL,

    UNIQUE (ISSN, Volume, Issue),

    FOREIGN KEY (ItemID)
        REFERENCES Item(ItemID)
        ON DELETE CASCADE,

    CHECK (Volume > 0),
    CHECK (Issue > 0)
);

CREATE TABLE Record (
    ItemID        INTEGER PRIMARY KEY,
    LabelName     TEXT NOT NULL,
    RecordNumber  TEXT NOT NULL,

    UNIQUE (LabelName, RecordNumber),

    FOREIGN KEY (ItemID)
        REFERENCES Item(ItemID)
        ON DELETE CASCADE
);

CREATE TABLE OnlineBook (
    ItemID     INTEGER PRIMARY KEY,
    ISBN       TEXT UNIQUE,
    AccessURL  TEXT NOT NULL,

    FOREIGN KEY (ItemID)
        REFERENCES Item(ItemID)
        ON DELETE CASCADE
);

CREATE TABLE Copy (
    ItemID      INTEGER NOT NULL,
    CopyNumber  INTEGER NOT NULL,
    Condition   TEXT NOT NULL
        CHECK (Condition IN (
            'Usable',
            'Damaged',
            'UnderRepair',
            'Lost',
            'Retired'
        )),

    PRIMARY KEY (ItemID, CopyNumber),

    FOREIGN KEY (ItemID)
        REFERENCES Item(ItemID),

    CHECK (CopyNumber > 0)
);

CREATE TABLE Loan (
    LoanID      INTEGER PRIMARY KEY,
    MemberID    INTEGER NOT NULL,
    ItemID      INTEGER NOT NULL,
    CopyNumber  INTEGER NOT NULL,
    BorrowDate  TEXT NOT NULL,
    DueDate     TEXT NOT NULL,
    ReturnDate  TEXT,

    FOREIGN KEY (MemberID)
        REFERENCES Member(MemberID),

    FOREIGN KEY (ItemID, CopyNumber)
        REFERENCES Copy(ItemID, CopyNumber),

    CHECK (DueDate >= BorrowDate),
    CHECK (
        ReturnDate IS NULL
        OR ReturnDate >= BorrowDate
    )
);

CREATE UNIQUE INDEX UniqueActiveLoanPerCopy
ON Loan(ItemID, CopyNumber)
WHERE ReturnDate IS NULL;

CREATE TABLE Fine (
    LoanID        INTEGER NOT NULL,
    FineNumber    INTEGER NOT NULL,
    FineType      TEXT NOT NULL
        CHECK (FineType IN (
            'Overdue',
            'Damage',
            'LostItem'
        )),
    AmountCents   INTEGER NOT NULL,
    AssessedDate  TEXT NOT NULL,
    Status        TEXT NOT NULL
        CHECK (Status IN (
            'Unpaid',
            'Paid',
            'Waived'
        )),
    ResolvedDate  TEXT,

    PRIMARY KEY (LoanID, FineNumber),

    FOREIGN KEY (LoanID)
        REFERENCES Loan(LoanID)
        ON DELETE CASCADE,

    CHECK (FineNumber > 0),
    CHECK (AmountCents > 0)
);

CREATE TABLE DonationOffer (
    DonationOfferID     INTEGER PRIMARY KEY,
    MemberID            INTEGER NOT NULL,
    OfferDateTime       TEXT NOT NULL,
    OfferDescription    TEXT NOT NULL,
    OfferStatus         TEXT NOT NULL
        CHECK (OfferStatus IN (
            'Pending',
            'Accepted',
            'Rejected'
        )),
    ProducedItemID      INTEGER,
    ProducedCopyNumber  INTEGER,

    FOREIGN KEY (MemberID)
        REFERENCES Member(MemberID),

    FOREIGN KEY (ProducedItemID, ProducedCopyNumber)
        REFERENCES Copy(ItemID, CopyNumber),

    UNIQUE (ProducedItemID, ProducedCopyNumber)
);

CREATE INDEX LoanMemberIndex
ON Loan(MemberID);

CREATE INDEX LoanCopyIndex
ON Loan(ItemID, CopyNumber);

CREATE INDEX DonationOfferMemberIndex
ON DonationOffer(MemberID);
