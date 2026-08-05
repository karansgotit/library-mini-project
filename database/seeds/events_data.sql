-- =========================================================================
-- Room
-- =========================================================================
INSERT INTO Room (RoomID, RoomNumber, Capacity) VALUES
(1,  'GB-1',     400),
(2,  'AUD-A',    250),
(3,  '101',       30),
(4,  '102',       30),
(5,  'SKY-1',    120),
(6,  'WS-B',      50),
(7,  'EXH-1',    600),
(8,  'BRD-1',     16),
(9,  'OUT-PAV',  200),
(10, 'MEDIA-1',   40);

-- =========================================================================
-- Event
-- =========================================================================
INSERT INTO Event (EventID, EventTitle, EventCategory, Description, TargetAudience, StartDateTime, EndDateTime, EventStatus, RegistrationLimit, CancellationReason, RoomID, OrganizerStaffID) VALUES
(1,  'Annual Tech Summit',         'Conference',  'Full-day summit on emerging tech trends.',        'Technology professionals',      '2026-09-10 09:00:00', '2026-09-10 17:00:00', 'Scheduled', 350, NULL, 1,  1),
(2,  'Product Launch: Nova',       'Launch',      'Launch event for the new Nova product line.',     'Press and customers',           '2026-09-15 18:00:00', '2026-09-15 21:00:00', 'Scheduled', 500, NULL, 7,  3),
(3,  'Board Strategy Meeting',     'Meeting',     'Quarterly strategy review with the board.',       'Board members',                 '2026-08-05 10:00:00', '2026-08-05 13:00:00', 'Completed', 16,  NULL, 8,  2),
(4,  'Community Volunteer Fair',   'Fair',        'Fair connecting volunteers with local nonprofits.','General public',                '2026-08-20 11:00:00', '2026-08-20 16:00:00', 'Scheduled', 180, NULL, 9,  7),
(5,  'Data Science Workshop',      'Workshop',    'Hands-on workshop covering ML fundamentals.',     'Students and professionals',    '2026-08-12 13:00:00', '2026-08-12 17:00:00', 'Scheduled', 45,  NULL, 6,  1),
(6,  'Investor Roundtable',        'Meeting',     'Closed-door roundtable with key investors.',      'Investors',                     '2026-08-01 09:00:00', '2026-08-01 11:00:00', 'Completed', 25,  NULL, 3,  2),
(7,  'Sales Kickoff 2026',         'Conference',  'Annual sales team kickoff and training.',         'Sales staff',                   '2026-09-25 08:30:00', '2026-09-25 16:00:00', 'Scheduled', 240, NULL, 2,  1),
(8,  'Charity Gala Dinner',        'Fundraiser',  'Black-tie fundraising dinner for local charities.','Donors and community members', '2026-10-02 18:30:00', '2026-10-02 23:00:00', 'Scheduled', 380, NULL, 1,  5),
(9,  'IT Infrastructure Briefing', 'Briefing',    'Internal briefing on new IT systems rollout.',    'Staff',                         '2026-08-28 14:00:00', '2026-08-28 15:30:00', 'Scheduled', 28,  NULL, 4,  6),
(10, 'Media & Press Day',          'Press',       'Press event with hands-on product demos.',        'Media',                         '2026-07-15 10:00:00', '2026-07-15 14:00:00', 'Cancelled', NULL,'Venue unavailable due to construction delay', 10, 3);

-- =========================================================================
-- Registration
-- =========================================================================
INSERT INTO Registration (MemberID, EventID, RegistrationDateTime, RegistrationStatus) VALUES
(1,  1, '2026-08-01 10:00:00', 'Registered'),
(2,  1, '2026-08-02 11:00:00', 'Registered'),
(3,  1, '2026-08-03 09:30:00', 'Registered'),
(4,  2, '2026-08-05 14:00:00', 'Registered'),
(5,  2, '2026-08-06 15:30:00', 'Registered'),
(6,  4, '2026-08-10 10:00:00', 'Registered'),
(7,  4, '2026-08-11 11:15:00', 'Attended'),
(8,  5, '2026-08-01 09:00:00', 'Registered'),
(9,  7, '2026-08-15 13:00:00', 'Registered'),
(10, 7, '2026-08-16 10:45:00', 'Cancelled'),
(1,  8, '2026-08-20 12:00:00', 'Registered'),
(2,  9, '2026-08-22 09:15:00', 'Registered');

-- =========================================================================
-- VolunteerApplication
-- =========================================================================
INSERT INTO VolunteerApplication (VolunteerApplicationID, MemberID, EventID, ApplicationDateTime, ApplicationStatus) VALUES
(1,  1,  4,    '2026-07-01 09:00:00', 'Approved'),
(2,  2,  4,    '2026-07-02 10:30:00', 'Approved'),
(3,  3,  1,    '2026-07-05 08:45:00', 'Pending'),
(4,  4,  1,    '2026-07-06 11:00:00', 'Rejected'),
(5,  5,  8,    '2026-07-10 14:00:00', 'Approved'),
(6,  6,  8,    '2026-07-11 15:30:00', 'Withdrawn'),
(7,  7,  5,    '2026-07-12 09:15:00', 'Approved'),
(8,  8,  7,    '2026-07-14 10:00:00', 'Approved'),
(9,  9,  2,    '2026-07-15 13:20:00', 'Pending'),
(10, 10, NULL, '2026-07-16 16:00:00', 'Approved');

-- =========================================================================
-- HelpRequest
-- =========================================================================
INSERT INTO HelpRequest (HelpRequestID, MemberID, StaffID, RequestDateTime, QuestionText, RequestStatus, ResolvedDateTime) VALUES
(1,  1, 6,    '2026-09-10 09:45:00', 'Wifi not connecting during the event.',                'Resolved',   '2026-09-10 10:15:00'),
(2,  3, NULL, '2026-08-20 11:30:00', 'Wheelchair access question for Auditorium A.',         'Pending',    NULL),
(3,  4, 3,    '2026-09-15 19:00:00', 'Missing swag bag from the product launch.',            'Resolved',   '2026-09-15 19:30:00'),
(4,  6, 7,    '2026-08-20 12:00:00', 'Confusion about assigned volunteer shift time.',       'Resolved',   '2026-08-20 12:20:00'),
(5,  7, NULL, '2026-08-20 13:00:00', 'Question about booth location for our nonprofit.',     'InProgress', NULL),
(6,  8, 1,    '2026-08-12 13:15:00', 'Workshop handouts were not printed on-site.',          'Resolved',   '2026-08-12 13:45:00'),
(7,  9, 1,    '2026-09-25 09:00:00', 'Badge printer jammed at the registration desk.',       'InProgress', NULL),
(8,  1, 5,    '2026-10-02 19:00:00', 'Dietary restriction was not reflected in catering.',   'Pending',    NULL),
(9,  2, 6,    '2026-08-28 14:15:00', 'Projector will not connect to presenter laptop.',      'Resolved',   '2026-08-28 14:30:00'),
(10, 5, 8,    '2026-07-20 10:00:00', 'General billing question about an invoice.',           'Pending',    NULL);