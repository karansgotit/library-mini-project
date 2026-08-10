-- Realistic library seed data for the reduced project design.

-- Room
INSERT INTO Room (RoomID, RoomNumber, Capacity) VALUES
(1, 'CED-100', 80),
(2, 'CED-110', 30),
(3, 'CED-120', 24),
(4, 'CED-130', 16),
(5, 'CED-140', 40),
(6, 'CED-150', 12),
(7, 'CED-200', 60),
(8, 'CED-210', 20),
(9, 'CED-220', 35),
(10, 'CED-230', 10);

-- Event
INSERT INTO Event (EventID, EventTitle, EventCategory, Description, TargetAudience, StartDateTime, EndDateTime, EventStatus, RegistrationLimit, CancellationReason, RoomID, OrganizerStaffID) VALUES
(1, 'Evening Book Club', 'BookClub', 'Discussion of a contemporary Canadian novel.', 'Adults', '2026-09-03 18:00:00', '2026-09-03 20:00:00', 'Scheduled', 20, NULL, 1, 1),
(2, 'Preschool Story Time', 'StoryTime', 'Stories, songs, and simple crafts for young children.', 'Children ages 3 to 5 and caregivers', '2026-09-05 10:00:00', '2026-09-05 11:00:00', 'Scheduled', 25, NULL, 2, 5),
(3, 'Introduction to Genealogy', 'Workshop', 'Learn how to begin researching family history.', 'Adults', '2026-08-12 14:00:00', '2026-08-12 16:00:00', 'Completed', 20, NULL, 3, 8),
(4, 'Teen Writing Workshop', 'Workshop', 'Creative writing exercises led by a local author.', 'Teens ages 13 to 18', '2026-09-12 13:00:00', '2026-09-12 15:30:00', 'Scheduled', 15, NULL, 4, 5),
(5, 'Digital Privacy Basics', 'Technology', 'Practical steps for safer browsing and online accounts.', 'Adults and seniors', '2026-09-16 18:30:00', '2026-09-16 20:00:00', 'Scheduled', 30, NULL, 5, 6),
(6, 'Local Authors Panel', 'AuthorTalk', 'Three writers discuss publishing in British Columbia.', 'General public', '2026-07-22 18:00:00', '2026-07-22 20:00:00', 'Completed', 12, NULL, 6, 7),
(7, 'Resume Help Drop-In', 'CareerSupport', 'One-on-one feedback on resumes and cover letters.', 'Job seekers', '2026-09-20 11:00:00', '2026-09-20 14:00:00', 'Scheduled', 40, NULL, 7, 7),
(8, 'Indigenous Literature Circle', 'BookClub', 'Monthly discussion of a work by an Indigenous author.', 'Adults', '2026-09-24 18:00:00', '2026-09-24 19:30:00', 'Scheduled', 18, NULL, 8, 1),
(9, 'Research Skills for Students', 'Workshop', 'Using catalogues and databases for school research.', 'Secondary and post-secondary students', '2026-09-27 13:00:00', '2026-09-27 15:00:00', 'Scheduled', 30, NULL, 9, 9),
(10, 'Outdoor Poetry Reading', 'AuthorTalk', 'Community poetry reading in the library courtyard.', 'General public', '2026-08-30 17:00:00', '2026-08-30 19:00:00', 'Cancelled', 10, 'Cancelled because of poor weather', 10, 3);

-- Registration
INSERT INTO Registration (MemberID, EventID, RegistrationDateTime, RegistrationStatus) VALUES
(1, 1, '2026-08-01 10:15:00', 'Registered'),
(1, 8, '2026-08-12 10:05:00', 'Registered'),
(2, 1, '2026-08-01 11:40:00', 'Registered'),
(2, 9, '2026-08-14 14:15:00', 'Registered'),
(3, 2, '2026-08-03 09:10:00', 'Registered'),
(4, 2, '2026-08-03 12:25:00', 'Registered'),
(5, 4, '2026-08-05 16:45:00', 'Registered'),
(6, 5, '2026-08-07 13:20:00', 'Registered'),
(7, 5, '2026-08-08 08:55:00', 'Registered'),
(9, 7, '2026-08-10 15:30:00', 'Registered');

-- VolunteerApplication
INSERT INTO VolunteerApplication (VolunteerApplicationID, MemberID, EventID, ApplicationDateTime, ApplicationStatus) VALUES
(1, 1, 1, '2026-08-02 09:00:00', 'Approved'),
(2, 2, 2, '2026-08-04 10:30:00', 'Pending'),
(3, 3, 3, '2026-07-20 11:15:00', 'Approved'),
(4, 4, 4, '2026-08-06 14:40:00', 'Approved'),
(5, 5, 5, '2026-08-08 16:05:00', 'Rejected'),
(6, 6, 6, '2026-07-01 12:25:00', 'Approved'),
(7, 7, 7, '2026-08-11 09:45:00', 'Pending'),
(8, 8, 8, '2026-08-13 13:35:00', 'Withdrawn'),
(9, 9, 9, '2026-08-15 15:55:00', 'Approved'),
(10, 10, NULL, '2026-08-16 10:20:00', 'Pending');

-- HelpRequest
INSERT INTO HelpRequest (HelpRequestID, MemberID, StaffID, RequestDateTime, QuestionText, RequestStatus, ResolvedDateTime) VALUES
(1, 1, 1, '2026-06-01 09:15:00', 'How can I renew a book online?', 'Resolved', '2026-06-01 09:30:00'),
(2, 2, 4, '2026-06-04 13:40:00', 'Where can I find books about local history?', 'Resolved', '2026-06-04 14:05:00'),
(3, 3, 6, '2026-06-10 11:20:00', 'How do I access an online book from home?', 'Resolved', '2026-06-10 11:45:00'),
(4, 4, NULL, '2026-06-18 15:05:00', 'Can I reserve a study room for a group?', 'Pending', NULL),
(5, 5, 5, '2026-06-25 10:35:00', 'Which reading program is suitable for my child?', 'InProgress', NULL),
(6, 6, 9, '2026-07-02 14:50:00', 'Can the library order a book it does not own?', 'Resolved', '2026-07-03 09:10:00'),
(7, 7, 7, '2026-07-09 12:15:00', 'How do I volunteer at a library event?', 'Resolved', '2026-07-09 13:00:00'),
(8, 8, NULL, '2026-07-16 16:30:00', 'Why is my membership currently suspended?', 'Pending', NULL),
(9, 9, 1, '2026-07-23 09:55:00', 'How can I pay an outstanding fine?', 'InProgress', NULL),
(10, 10, 4, '2026-07-30 13:25:00', 'What identification is needed to renew membership?', 'Resolved', '2026-07-30 14:10:00');
