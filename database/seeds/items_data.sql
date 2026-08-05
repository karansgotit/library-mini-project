-- Primary owner: Karan | Reviewer: Tushar
-- TODO: Insert at least 10 realistic rows into every item-domain table.
-- =========================================================================
-- Item
-- =========================================================================
INSERT INTO Item (ItemID, Title, CreatorName, CollectionStatus) VALUES
(1,  'Neuromancer',                        'William Gibson',                     'InCollection'),
(2,  'The Hobbit',                         'J.R.R. Tolkien',                     'InCollection'),
(3,  'Good Omens',                         'Neil Gaiman and Terry Pratchett',    'InCollection'),
(4,  '1984',                               'George Orwell',                      'Removed'),
(5,  'National Geographic, Nov 2025',      NULL,                                 'InCollection'),
(6,  'Wired, Dec 2025',                    NULL,                                 'InCollection'),
(7,  'Time Magazine, Jan 2026',            NULL,                                 'InCollection'),
(8,  'Journal of Database Systems',        NULL,                                 'InCollection'),
(9,  'ACM Transactions on Software',       NULL,                                 'Removed'),
(10, 'IEEE Software',                      NULL,                                 'InCollection'),
(11, 'Kind of Blue',                       'Miles Davis',                        'InCollection'),
(12, 'Abbey Road',                         'The Beatles',                        'InCollection'),
(13, 'Rumours',                            'Fleetwood Mac',                      'InCollection'),
(14, 'Sapiens',                            'Yuval Noah Harari',                  'InCollection'),
(15, 'Free Culture',                       'Lawrence Lessig',                    'InCollection'),
(16, 'The Odyssey',                        'Homer',                              'InCollection'),
(17, 'Untitled Manuscript Donation',       NULL,                                 'Prospective'),
(18, 'Local History Zine Collection',      'Community Press',                    'Prospective');

-- =========================================================================
-- PrintBook
-- =========================================================================
INSERT INTO PrintBook (ItemID, ISBN) VALUES
(1, '978-0-441-56956-4'),
(2, '978-0-547-92822-7'),
(3, '978-0-06-085398-8'),
(4, NULL);

-- =========================================================================
-- Magazine
-- =========================================================================
INSERT INTO Magazine (ItemID, ISSN, VolumeNumber, IssueNumber) VALUES
(5, '0027-9358', 248, 5),
(6, '1059-1028', 33,  12),
(7, '0040-781X', 207, 1);

-- =========================================================================
-- Journal
-- =========================================================================
INSERT INTO Journal (ItemID, ISSN, Volume, Issue) VALUES
(8,  '0362-5915', 51, 1),
(9,  '1049-331X', 34, 4),
(10, '0740-7459', 43, 2);

-- =========================================================================
-- Record
-- =========================================================================
INSERT INTO Record (ItemID, LabelName, RecordNumber) VALUES
(11, 'Columbia Records', 'CL 1355'),
(12, 'Apple Records',    'PCS 7088'),
(13, 'Warner Bros.',     'BSK 3010');

-- =========================================================================
-- OnlineBook
-- =========================================================================
INSERT INTO OnlineBook (ItemID, ISBN, AccessURL) VALUES
(14, '978-0-06-231609-7', 'https://library.example.org/ebooks/sapiens'),
(15, NULL,                'https://library.example.org/ebooks/free-culture'),
(16, NULL,                'https://library.example.org/ebooks/odyssey');

-- =========================================================================
-- Copy
-- =========================================================================
INSERT INTO Copy (ItemID, CopyNumber, Condition) VALUES
(1, 1, 'Usable'),
(1, 2, 'Usable'),
(1, 3, 'Usable'),
(2, 1, 'Usable'),
(2, 2, 'Damaged'),
(2, 3, 'Usable'),
(2, 4, 'Usable'),
(3, 1, 'Usable'),
(4, 1, 'Retired'),
(5, 1, 'Usable'),
(6, 1, 'Usable'),
(7, 1, 'Usable'),
(8, 1, 'Usable'),
(9, 1, 'Retired'),
(10, 1, 'Usable'),
(11, 1, 'Usable'),
(11, 2, 'UnderRepair'),
(11, 3, 'Usable'),
(12, 1, 'Usable'),
(12, 2, 'Usable'),
(13, 1, 'Lost');

-- =========================================================================
-- Loan
-- =========================================================================
INSERT INTO Loan (LoanID, MemberID, ItemID, CopyNumber, BorrowDate, DueDate, ReturnDate) VALUES
(1,  1,  1,  1, '2026-07-01', '2026-07-15', NULL),
(2,  2,  2,  2, '2026-07-05', '2026-07-19', '2026-07-18'),
(3,  3,  3,  1, '2026-07-10', '2026-07-24', NULL),
(4,  5,  5,  1, '2026-06-20', '2026-07-04', '2026-07-02'),
(5,  7,  6,  1, '2026-07-12', '2026-07-26', NULL),
(6,  9,  8,  1, '2026-06-15', '2026-06-29', '2026-07-02'),
(7,  10, 10, 1, '2026-07-18', '2026-08-01', NULL),
(8,  1,  11, 1, '2026-05-01', '2026-05-15', '2026-05-20'),
(9,  3,  12, 1, '2026-07-20', '2026-08-03', NULL),
(10, 5,  1,  2, '2026-06-01', '2026-06-15', '2026-06-18'),
(11, 7,  7,  1, '2026-07-22', '2026-08-05', NULL),
(12, 2,  5,  1, '2026-07-10', '2026-07-24', NULL),
(13, 9,  2,  1, '2026-07-20', '2026-08-03', NULL),
(14, 6,  13, 1, '2026-04-01', '2026-04-15', NULL);

-- =========================================================================
-- Fine
-- =========================================================================
INSERT INTO Fine (LoanID, FineNumber, FineType, AmountCents, AssessedDate, Status, ResolvedDate) VALUES
(2,  1, 'Damage',   1500, '2026-07-18', 'Unpaid', NULL),
(6,  1, 'Overdue',   100, '2026-07-02', 'Waived', '2026-07-05'),
(8,  1, 'Overdue',   250, '2026-05-20', 'Paid',   '2026-05-25'),
(10, 1, 'Overdue',   300, '2026-06-18', 'Paid',   '2026-06-20'),
(14, 1, 'LostItem', 2000, '2026-05-01', 'Unpaid', NULL);

-- =========================================================================
-- DonationOffer
-- =========================================================================
INSERT INTO DonationOffer (DonationOfferID, MemberID, OfferDateTime, OfferDescription, OfferStatus, ProducedItemID, ProducedCopyNumber) VALUES
(1,  1,  '2026-06-01 10:00:00', 'Box of vintage sci-fi paperbacks',      'Accepted', 1,  3),
(2,  3,  '2026-06-05 14:30:00', 'Local zine back issues',                'Pending',  NULL, NULL),
(3,  5,  '2026-06-10 09:15:00', 'Jazz vinyl collection',                 'Accepted', 11, 3),
(4,  7,  '2026-06-12 16:00:00', 'Old National Geographic issues',        'Rejected', NULL, NULL),
(5,  9,  '2026-06-15 11:00:00', 'Rare first-edition Hobbit copy',        'Accepted', 2,  4),
(6,  2,  '2026-06-18 13:45:00', 'Community history manuscript',          'Pending',  NULL, NULL),
(7,  4,  '2026-06-20 10:30:00', 'Damaged encyclopedia set',              'Rejected', NULL, NULL),
(8,  6,  '2026-06-22 15:00:00', 'Box of assorted CDs',                   'Pending',  NULL, NULL),
(9,  8,  '2026-06-25 09:00:00', 'Beatles memorabilia and spare vinyl',   'Accepted', 12, 2),
(10, 10, '2026-06-28 12:00:00', 'Assorted paperback donations',          'Pending',  NULL, NULL);