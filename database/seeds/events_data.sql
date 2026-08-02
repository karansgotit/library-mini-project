-- Primary owner: Tushar | Reviewer: Karan
-- TODO: Insert at least 10 realistic rows into every event-domain table.


INSERT INTO room (name, location, capacity) VALUES
('Grand Ballroom',        'Main Building, 1st Floor',        400),
('Auditorium A',          'North Wing, Ground Floor',        250),
('Conference Room 101',   'East Wing, 1st Floor',             30),
('Conference Room 102',   'East Wing, 1st Floor',             30),
('Sky Lounge',            'Main Building, Rooftop',          120),
('Workshop Studio B',     'South Wing, 2nd Floor',            50),
('Exhibition Hall',       'Main Building, Ground Floor',     600),
('Boardroom',             'North Wing, 3rd Floor',            16),
('Outdoor Pavilion',      'Garden Courtyard',                200),
('Media Lab',             'South Wing, 1st Floor',            40);
 

 INSERT INTO employee (first_name, last_name, email, phone, role, department, hired_at) VALUES
('Tushar',  'Mehta',     'tushar.mehta@company.com',   '555-0101', 'Events Manager',      'Events',        '2021-03-15'),
('Karan',   'Shah',      'karan.shah@company.com',     '555-0102', 'Operations Lead',     'Operations',    '2020-07-01'),
('Priya',   'Nair',      'priya.nair@company.com',     '555-0103', 'Marketing Coordinator','Marketing',    '2022-01-10'),
('Alex',    'Johnson',   'alex.johnson@company.com',   '555-0104', 'Logistics Coordinator','Operations',   '2019-11-20'),
('Maria',   'Garcia',    'maria.garcia@company.com',   '555-0105', 'Guest Relations Lead','Guest Services', '2023-02-28'),
('Wei',     'Zhang',     'wei.zhang@company.com',      '555-0106', 'IT Support Specialist','IT',           '2021-09-05'),
('Sara',    'Kim',       'sara.kim@company.com',       '555-0107', 'Volunteer Coordinator','Events',       '2022-06-14'),
('David',   'Brown',     'david.brown@company.com',    '555-0108', 'Finance Analyst',     'Finance',       '2018-04-02'),
('Layla',   'Hassan',    'layla.hassan@company.com',   '555-0109', 'Catering Manager',    'Operations',    '2020-12-01'),
('Tom',     'Wilson',    'tom.wilson@company.com',     '555-0110', 'Security Lead',       'Security',      '2019-08-17');
 
 INSERT INTO event (name, description, room_id, organizer_id, start_time, end_time, status) VALUES
('Annual Tech Summit',        'Full-day summit on emerging tech trends.',        1, 1,  '2026-09-10 09:00', '2026-09-10 17:00', 'scheduled'),
('Product Launch: Nova',      'Launch event for the new Nova product line.',     7, 3,  '2026-09-15 18:00', '2026-09-15 21:00', 'scheduled'),
('Board Strategy Meeting',    'Quarterly strategy review with the board.',       8, 2,  '2026-08-05 10:00', '2026-08-05 13:00', 'completed'),
('Community Volunteer Fair',  'Fair connecting volunteers with local nonprofits.',9, 7, '2026-08-20 11:00', '2026-08-20 16:00', 'scheduled'),
('Data Science Workshop',     'Hands-on workshop covering ML fundamentals.',     6, 1,  '2026-08-12 13:00', '2026-08-12 17:00', 'scheduled'),
('Investor Roundtable',       'Closed-door roundtable with key investors.',      3, 2,  '2026-08-01 09:00', '2026-08-01 11:00', 'completed'),
('Sales Kickoff 2026',        'Annual sales team kickoff and training.',         2, 1,  '2026-09-25 08:30', '2026-09-25 16:00', 'scheduled'),
('Charity Gala Dinner',       'Black-tie fundraising dinner for local charities.',1, 5,  '2026-10-02 18:30', '2026-10-02 23:00', 'scheduled'),
('IT Infrastructure Briefing','Internal briefing on new IT systems rollout.',    4, 6,  '2026-08-28 14:00', '2026-08-28 15:30', 'scheduled'),
('Media & Press Day',         'Press event with hands-on product demos.',        10,3,  '2026-07-15 10:00', '2026-07-15 14:00', 'cancelled');


INSERT INTO audience (first_name, last_name, email, phone) VALUES
('Emma',    'Watson',    'emma.watson@example.com',    '555-0201'),
('Liam',    'Chen',      'liam.chen@example.com',      '555-0202'),
('Olivia',  'Rossi',     'olivia.rossi@example.com',   '555-0203'),
('Noah',    'Patel',     'noah.patel@example.com',     '555-0204'),
('Ava',     'Kowalski',  'ava.kowalski@example.com',   '555-0205'),
('Ethan',   'Okafor',    'ethan.okafor@example.com',   '555-0206'),
('Sophia',  'Martinez',  'sophia.martinez@example.com','555-0207'),
('Mason',   'Dubois',    'mason.dubois@example.com',   '555-0208'),
('Isabella','Fischer',   'isabella.fischer@example.com','555-0209'),
('James',   'Novak',     'james.novak@example.com',    '555-0210');
 

 INSERT INTO volunteer (first_name, last_name, email, phone, event_id, role) VALUES
('Grace',   'Lee',       'grace.lee@volunteers.org',      '555-0301', 4, 'Check-in Desk'),
('Lucas',   'Silva',     'lucas.silva@volunteers.org',    '555-0302', 4, 'Booth Setup'),
('Chloe',   'Anderson',  'chloe.anderson@volunteers.org', '555-0303', 1, 'Registration Desk'),
('Henry',   'Kimura',    'henry.kimura@volunteers.org',   '555-0304', 1, 'AV Support'),
('Zoe',     'Ibrahim',   'zoe.ibrahim@volunteers.org',    '555-0305', 8, 'Guest Escort'),
('Daniel',  'Costa',     'daniel.costa@volunteers.org',   '555-0306', 8, 'Coat Check'),
('Amara',   'Diallo',    'amara.diallo@volunteers.org',   '555-0307', 5, 'Workshop Assistant'),
('Ryan',    'Murphy',    'ryan.murphy@volunteers.org',    '555-0308', 7, 'Room Monitor'),
('Nina',    'Petrova',   'nina.petrova@volunteers.org',   '555-0309', 2, 'Merch Table'),
('Leo',     'Tanaka',    'leo.tanaka@volunteers.org',     '555-0310', NULL, 'General / Unassigned');
 

 INSERT INTO registration (event_id, audience_id, status) VALUES
(1, 1,  'confirmed'),
(1, 2,  'confirmed'),
(1, 3,  'waitlisted'),
(2, 4,  'confirmed'),
(2, 5,  'confirmed'),
(4, 6,  'confirmed'),
(4, 7,  'attended'),
(5, 8,  'confirmed'),
(7, 9,  'confirmed'),
(7, 10, 'cancelled'),
(8, 1,  'confirmed'),
(9, 2,  'confirmed');
 

 INSERT INTO help_request (event_id, audience_id, assigned_to, subject, description, status, resolved_at) VALUES
(1, 1,  6, 'Wifi not connecting',            'Attendee unable to join event wifi network.',        'resolved',     '2026-09-10 09:45'),
(1, 3,  NULL, 'Wheelchair access question',  'Asking about accessible seating in Auditorium A.',   'open',         NULL),
(2, 4,  3, 'Missing swag bag',                'Registered but did not receive product swag.',       'resolved',     '2026-09-15 19:10'),
(4, 6,  7, 'Volunteer shift confusion',       'Volunteer unsure of assigned shift time.',            'closed',       '2026-08-20 12:00'),
(4, 7,  NULL, 'Booth location question',      'Nonprofit asking where their booth is located.',     'in_progress',  NULL),
(5, 8,  1, 'Workshop materials not printed',  'Handouts for workshop were not available on-site.',  'resolved',     '2026-08-12 13:30'),
(7, 9,  1, 'Badge printer malfunction',       'Badge printer jammed at registration desk.',          'in_progress',  NULL),
(8, 1,  5, 'Dietary restriction not logged',  'Guest has a nut allergy not reflected in catering.',  'open',         NULL),
(9, 2,  6, 'Projector not working',           'Presenter cannot connect laptop to room projector.',  'resolved',     '2026-08-28 14:15'),
(NULL, 5, 2, 'General billing question',      'Question about an invoice unrelated to a specific event.', 'open',    NULL);
 