-- Primary owner: Karan | Reviewer: Tushar
-- TODO: Insert at least 10 realistic rows into every shared table.
-- =========================================================================
-- Member
-- =========================================================================
INSERT INTO Member (MemberID, FullName, Email, Phone, MembershipStatus) VALUES
(1,  'Emma Watson',     'emma.watson@example.com',     '555-0201', 'Active'),
(2,  'Liam Chen',       'liam.chen@example.com',       '555-0202', 'Active'),
(3,  'Olivia Rossi',    'olivia.rossi@example.com',    '555-0203', 'Active'),
(4,  'Noah Patel',      'noah.patel@example.com',      '555-0204', 'Suspended'),
(5,  'Ava Kowalski',    'ava.kowalski@example.com',    '555-0205', 'Active'),
(6,  'Ethan Okafor',    'ethan.okafor@example.com',    '555-0206', 'Expired'),
(7,  'Sophia Martinez', 'sophia.martinez@example.com', '555-0207', 'Active'),
(8,  'Mason Dubois',    NULL,                           '555-0208', 'Active'),
(9,  'Isabella Fischer','isabella.fischer@example.com','555-0209', 'Active'),
(10, 'James Novak',     'james.novak@example.com',     '555-0210', 'Active');

-- =========================================================================
-- Staff
-- =========================================================================
INSERT INTO Staff (StaffID, FullName, JobTitle, Email, EmploymentStatus, HireDate, DepartmentName) VALUES
(1,  'Tushar Mehta',  'Events Manager',        'tushar.mehta@library.org',  'Active',  '2021-03-15', 'Events'),
(2,  'Karan Shah',    'Operations Lead',       'karan.shah@library.org',    'Active',  '2020-07-01', 'Operations'),
(3,  'Priya Nair',    'Marketing Coordinator', 'priya.nair@library.org',    'Active',  '2022-01-10', 'Marketing'),
(4,  'Alex Johnson',  'Logistics Coordinator', 'alex.johnson@library.org',  'Active',  '2019-11-20', 'Operations'),
(5,  'Maria Garcia',  'Guest Relations Lead',  'maria.garcia@library.org',  'OnLeave', '2023-02-28', 'Guest Services'),
(6,  'Wei Zhang',     'IT Support Specialist', 'wei.zhang@library.org',     'Active',  '2021-09-05', 'IT'),
(7,  'Sara Kim',      'Volunteer Coordinator', 'sara.kim@library.org',      'Active',  '2022-06-14', 'Events'),
(8,  'David Brown',   'Finance Analyst',       'david.brown@library.org',   'Active',  '2018-04-02', 'Finance'),
(9,  'Layla Hassan',  'Catering Manager',      'layla.hassan@library.org',  'Former',  '2020-12-01', 'Operations'),
(10, 'Tom Wilson',    'Security Lead',         'tom.wilson@library.org',    'Active',  '2019-08-17', 'Security');