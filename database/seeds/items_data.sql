-- Realistic library seed data for the reduced project design.

-- Item
INSERT INTO Item (ItemID, Title, CreatorName, CollectionStatus) VALUES
(1, 'The Handmaid''s Tale', 'Margaret Atwood', 'InCollection'),
(2, '1984', 'George Orwell', 'InCollection'),
(3, 'Dune', 'Frank Herbert', 'InCollection'),
(4, 'Pride and Prejudice', 'Jane Austen', 'InCollection'),
(5, 'Beloved', 'Toni Morrison', 'InCollection'),
(6, 'The Hobbit', 'J.R.R. Tolkien', 'InCollection'),
(7, 'The Great Gatsby', 'F. Scott Fitzgerald', 'InCollection'),
(8, 'To Kill a Mockingbird', 'Harper Lee', 'InCollection'),
(9, 'The Kite Runner', 'Khaled Hosseini', 'InCollection'),
(10, 'The Marrow Thieves', 'Cherie Dimaline', 'InCollection'),
(11, 'National Geographic: Oceans', 'National Geographic Society', 'InCollection'),
(12, 'The New Yorker: Summer Fiction', 'The New Yorker', 'InCollection'),
(13, 'Time: Artificial Intelligence', 'Time USA', 'InCollection'),
(14, 'Scientific American: Climate', 'Springer Nature', 'InCollection'),
(15, 'Maclean''s: Canadian Cities', 'St. Joseph Communications', 'InCollection'),
(16, 'The Walrus: Northern Stories', 'The Walrus Foundation', 'InCollection'),
(17, 'Canadian Geographic: Wildlife', 'Royal Canadian Geographical Society', 'InCollection'),
(18, 'Wired: Future of Work', 'Condé Nast', 'InCollection'),
(19, 'The Atlantic: Democracy', 'The Atlantic Monthly Group', 'InCollection'),
(20, 'Popular Science: Space', 'Recurrent Ventures', 'InCollection'),
(21, 'Nature: Biodiversity Research', 'Springer Nature', 'InCollection'),
(22, 'Science: Renewable Energy', 'AAAS', 'InCollection'),
(23, 'The Lancet: Public Health', 'Elsevier', 'InCollection'),
(24, 'IEEE Spectrum: Robotics', 'IEEE', 'InCollection'),
(25, 'Canadian Journal of Economics', 'Wiley', 'InCollection'),
(26, 'Journal of Canadian Studies', 'University of Toronto Press', 'InCollection'),
(27, 'Ecology Letters', 'Wiley', 'InCollection'),
(28, 'Modern Language Quarterly', 'Duke University Press', 'InCollection'),
(29, 'Journal of Urban History', 'SAGE Publications', 'InCollection'),
(30, 'Library Quarterly', 'University of Chicago Press', 'InCollection'),
(31, 'Blue', 'Joni Mitchell', 'InCollection'),
(32, 'Abbey Road', 'The Beatles', 'InCollection'),
(33, 'Kind of Blue', 'Miles Davis', 'InCollection'),
(34, 'Songs in the Key of Life', 'Stevie Wonder', 'InCollection'),
(35, 'Rumours', 'Fleetwood Mac', 'InCollection'),
(36, 'Purple Rain', 'Prince and the Revolution', 'InCollection'),
(37, 'Back to Black', 'Amy Winehouse', 'InCollection'),
(38, 'The Miseducation of Lauryn Hill', 'Lauryn Hill', 'InCollection'),
(39, 'OK Computer', 'Radiohead', 'InCollection'),
(40, 'In Rainbows', 'Radiohead', 'InCollection'),
(41, 'The Left Hand of Darkness', 'Ursula K. Le Guin', 'InCollection'),
(42, 'Station Eleven', 'Emily St. John Mandel', 'InCollection'),
(43, 'The Book of Negroes', 'Lawrence Hill', 'InCollection'),
(44, 'Braiding Sweetgrass', 'Robin Wall Kimmerer', 'InCollection'),
(45, 'The Break', 'Katherena Vermette', 'InCollection'),
(46, 'Moon of the Crusted Snow', 'Waubgeshig Rice', 'InCollection'),
(47, 'Washington Black', 'Esi Edugyan', 'InCollection'),
(48, 'The Skin We''re In', 'Desmond Cole', 'InCollection'),
(49, 'Five Little Indians', 'Michelle Good', 'InCollection'),
(50, 'The In-Between World of Vikram Lall', 'M.G. Vassanji', 'InCollection');

-- PrintBook
INSERT INTO PrintBook (ItemID, ISBN) VALUES
(1, '9780771008795'),
(2, '9780451524935'),
(3, '9780441172719'),
(4, '9780141439518'),
(5, '9781400033416'),
(6, '9780547928227'),
(7, '9780743273565'),
(8, '9780061120084'),
(9, '9781594631931'),
(10, '9781770864869');

-- Magazine
INSERT INTO Magazine (ItemID, ISSN, VolumeNumber, IssueNumber) VALUES
(11, '0027-9358', 251, 3),
(12, '0028-792X', 102, 24),
(13, '0040-781X', 207, 10),
(14, '0036-8733', 329, 2),
(15, '0024-9262', 137, 6),
(16, '1480-3608', 21, 4),
(17, '0706-2168', 144, 5),
(18, '1059-1028', 32, 9),
(19, '1072-7825', 333, 1),
(20, '0161-7370', 297, 7);

-- Journal
INSERT INTO Journal (ItemID, ISSN, Volume, Issue) VALUES
(21, '0028-0836', 632, 8024),
(22, '0036-8075', 385, 6712),
(23, '0140-6736', 404, 10441),
(24, '0018-9235', 61, 8),
(25, '0008-4085', 57, 3),
(26, '0021-9495', 59, 2),
(27, '1461-023X', 27, 7),
(28, '0026-7929', 85, 4),
(29, '0096-1442', 50, 5),
(30, '0024-2519', 94, 1);

-- Record
INSERT INTO Record (ItemID, LabelName, RecordNumber) VALUES
(31, 'Reprise Records', 'MS-2038'),
(32, 'Apple Records', 'SO-383'),
(33, 'Columbia Records', 'CL-1355'),
(34, 'Tamla Records', 'T13-340C2'),
(35, 'Warner Bros. Records', 'BSK-3010'),
(36, 'Warner Bros. Records', '25110-1'),
(37, 'Island Records', 'B0008994-01'),
(38, 'Ruffhouse Records', 'C2-69035'),
(39, 'Parlophone', 'NODATA-02'),
(40, 'XL Recordings', 'XLLP-324');

-- OnlineBook
INSERT INTO OnlineBook (ItemID, ISBN, AccessURL) VALUES
(41, '9780441478125', 'https://ebooks.example.org/items/41'),
(42, '9780385353304', 'https://ebooks.example.org/items/42'),
(43, '9780393333091', 'https://ebooks.example.org/items/43'),
(44, '9781571313560', 'https://ebooks.example.org/items/44'),
(45, '9781487001117', 'https://ebooks.example.org/items/45'),
(46, '9781770414002', 'https://ebooks.example.org/items/46'),
(47, '9780525521426', 'https://ebooks.example.org/items/47'),
(48, '9780385686341', 'https://ebooks.example.org/items/48'),
(49, '9781443459181', 'https://ebooks.example.org/items/49'),
(50, '9780385660654', 'https://ebooks.example.org/items/50');

-- Copy
INSERT INTO Copy (ItemID, CopyNumber, Condition) VALUES
(1, 1, 'Usable'),
(2, 1, 'Usable'),
(3, 1, 'Usable'),
(4, 1, 'Usable'),
(5, 1, 'Usable'),
(6, 1, 'Usable'),
(7, 1, 'Usable'),
(8, 1, 'Usable'),
(9, 1, 'Usable'),
(10, 1, 'Usable'),
(11, 1, 'Usable'),
(12, 1, 'Usable'),
(13, 1, 'Usable'),
(14, 1, 'Usable'),
(15, 1, 'Usable'),
(16, 1, 'Damaged'),
(17, 1, 'UnderRepair'),
(18, 1, 'Lost'),
(19, 1, 'Retired'),
(20, 1, 'Usable');

-- Loan
INSERT INTO Loan (LoanID, MemberID, ItemID, CopyNumber, BorrowDate, DueDate, ReturnDate) VALUES
(1, 1, 1, 1, '2026-01-05', '2026-01-26', '2026-01-24'),
(2, 2, 2, 1, '2026-01-12', '2026-02-02', '2026-02-06'),
(3, 3, 3, 1, '2026-02-01', '2026-02-22', '2026-02-20'),
(4, 4, 4, 1, '2026-02-10', '2026-03-03', '2026-03-10'),
(5, 5, 5, 1, '2026-03-01', '2026-03-22', '2026-03-21'),
(6, 6, 6, 1, '2026-07-10', '2026-07-31', NULL),
(7, 7, 7, 1, '2026-07-15', '2026-08-05', NULL),
(8, 9, 8, 1, '2026-07-20', '2026-08-10', NULL),
(9, 1, 9, 1, '2026-07-25', '2026-08-15', NULL),
(10, 2, 10, 1, '2026-08-01', '2026-08-22', NULL);

-- Fine
INSERT INTO Fine (LoanID, FineNumber, FineType, AmountCents, AssessedDate, Status, ResolvedDate) VALUES
(1, 1, 'Damage', 1200, '2026-01-24', 'Paid', '2026-01-30'),
(2, 1, 'Overdue', 400, '2026-02-06', 'Paid', '2026-02-06'),
(3, 1, 'Damage', 750, '2026-02-20', 'Waived', '2026-02-21'),
(4, 1, 'Overdue', 700, '2026-03-10', 'Paid', '2026-03-12'),
(5, 1, 'Damage', 500, '2026-03-21', 'Paid', '2026-03-25'),
(6, 1, 'Overdue', 500, '2026-08-01', 'Unpaid', NULL),
(7, 1, 'Overdue', 300, '2026-08-06', 'Unpaid', NULL),
(8, 1, 'LostItem', 2500, '2026-08-11', 'Unpaid', NULL),
(9, 1, 'Damage', 900, '2026-08-02', 'Unpaid', NULL),
(10, 1, 'Overdue', 200, '2026-08-23', 'Unpaid', NULL);

-- DonationOffer
INSERT INTO DonationOffer (DonationOfferID, MemberID, OfferDateTime, OfferDescription, OfferStatus, ProducedItemID, ProducedCopyNumber) VALUES
(1, 1, '2026-01-08 10:15:00', 'Two recent Canadian novels in good condition', 'Pending', NULL, NULL),
(2, 2, '2026-01-20 14:30:00', 'Box of children''s picture books', 'Rejected', NULL, NULL),
(3, 3, '2026-02-02 09:45:00', 'Local history pamphlet collection', 'Pending', NULL, NULL),
(4, 4, '2026-02-17 16:20:00', 'Used university textbooks', 'Rejected', NULL, NULL),
(5, 5, '2026-03-06 11:00:00', 'Set of gardening magazines', 'Pending', NULL, NULL),
(6, 6, '2026-03-21 13:10:00', 'National Geographic ocean issue', 'Accepted', 11, 1),
(7, 7, '2026-04-04 15:35:00', 'New Yorker summer fiction issue', 'Accepted', 12, 1),
(8, 8, '2026-04-18 10:05:00', 'Time artificial intelligence issue', 'Accepted', 13, 1),
(9, 9, '2026-05-01 12:40:00', 'Scientific American climate issue', 'Accepted', 14, 1),
(10, 10, '2026-05-16 09:25:00', 'Maclean''s Canadian cities issue', 'Accepted', 15, 1);
