-- Realistic library seed data for the reduced project design.

-- Member
INSERT INTO Member (MemberID, FullName, Email, Phone, MembershipStatus) VALUES
(1, 'Aisha Khan', 'aisha.khan@example.com', '604-555-0101', 'Active'),
(2, 'Ben Carter', 'ben.carter@example.com', '604-555-0102', 'Active'),
(3, 'Chloe Martin', 'chloe.martin@example.com', '604-555-0103', 'Active'),
(4, 'Daniel Kim', 'daniel.kim@example.com', '604-555-0104', 'Active'),
(5, 'Elena Garcia', 'elena.garcia@example.com', '604-555-0105', 'Active'),
(6, 'Farah Ali', 'farah.ali@example.com', '604-555-0106', 'Active'),
(7, 'Gabriel Wong', 'gabriel.wong@example.com', '604-555-0107', 'Active'),
(8, 'Hannah Wilson', 'hannah.wilson@example.com', NULL, 'Suspended'),
(9, 'Isaac Brown', 'isaac.brown@example.com', '604-555-0109', 'Active'),
(10, 'Julia Singh', 'julia.singh@example.com', NULL, 'Expired');

-- Staff
INSERT INTO Staff (StaffID, FullName, JobTitle, Email, EmploymentStatus, HireDate, DepartmentName) VALUES
(1, 'Alice Park', 'Librarian', 'alice.park@library.ca', 'Active', '2019-02-11', 'Circulation'),
(2, 'Marcus Lee', 'Branch Manager', 'marcus.lee@library.ca', 'Active', '2016-06-20', 'Administration'),
(3, 'Priya Nair', 'Program Coordinator', 'priya.nair@library.ca', 'Active', '2021-01-18', 'Programs'),
(4, 'Owen Taylor', 'Library Assistant', 'owen.taylor@library.ca', 'Active', '2023-04-03', 'Circulation'),
(5, 'Sofia Chen', 'Youth Librarian', 'sofia.chen@library.ca', 'Active', '2020-09-14', 'Youth Services'),
(6, 'Noah Williams', 'Digital Services Librarian', 'noah.williams@library.ca', 'Active', '2018-11-05', 'Digital Services'),
(7, 'Maya Patel', 'Community Librarian', 'maya.patel@library.ca', 'Active', '2022-03-28', 'Outreach'),
(8, 'Liam Thompson', 'Archivist', 'liam.thompson@library.ca', 'OnLeave', '2017-08-07', 'Collections'),
(9, 'Grace Nguyen', 'Collections Librarian', 'grace.nguyen@library.ca', 'Active', '2015-05-25', 'Collections'),
(10, 'Ethan Miller', 'Library Technician', 'ethan.miller@library.ca', 'Former', '2014-10-06', 'Technical Services');
