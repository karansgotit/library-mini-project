-- Primary owner: Tushar | Reviewer: Karan
-- TODO: Create event, room, audience, registration, employee, volunteer,
-- and help-request tables.


CREATE TABLE room (
    room_id       SERIAL PRIMARY KEY,
    name          VARCHAR(60) NOT NULL,
    location      VARCHAR(100),
    capacity      INTEGER CHECK (capacity >= 0),
    created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
)


CREATE TABLE employee (
    employee_id   SERIAL PRIMARY KEY,
    first_name    VARCHAR(60) NOT NULL,
    last_name     VARCHAR(60) NOT NULL,
    email         VARCHAR(255) NOT NULL UNIQUE,
    phone         VARCHAR(13),
    role          VARCHAR(25),
    department    VARCHAR(100),
    hired_at      DATE,
    created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE event (
    event_id      SERIAL PRIMARY KEY,
    name          VARCHAR(60) NOT NULL,
    description   TEXT,
    room_id       INTEGER REFERENCES room(room_id) ON DELETE SET NULL,
    organizer_id  INTEGER REFERENCES employee(employee_id) ON DELETE SET NULL,
    start_time    TIMESTAMP NOT NULL,
    end_time      TIMESTAMP NOT NULL,
    status        VARCHAR(20) NOT NULL DEFAULT 'scheduled'
                  CHECK (status IN ('scheduled', 'ongoing', 'completed', 'cancelled')),
    created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (end_time > start_time)
);

CREATE TABLE audience (
    audience_id   SERIAL PRIMARY KEY,
    first_name    VARCHAR(60) NOT NULL,
    last_name     VARCHAR(60) NOT NULL,
    email         VARCHAR(255) NOT NULL UNIQUE,
    phone         VARCHAR(13),
    created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE registration (
    registration_id   SERIAL PRIMARY KEY,
    event_id          INTEGER NOT NULL REFERENCES event(event_id) ON DELETE CASCADE,
    audience_id       INTEGER NOT NULL REFERENCES audience(audience_id) ON DELETE CASCADE,
    registered_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status            VARCHAR(20) NOT NULL DEFAULT 'confirmed'
                      CHECK (status IN ('confirmed', 'waitlisted', 'cancelled', 'attended')),
    UNIQUE (event_id, audience_id)
);
 

CREATE TABLE volunteer (
    volunteer_id  SERIAL PRIMARY KEY,
    first_name    VARCHAR(100),
    last_name     VARCHAR(100),
    email         VARCHAR(255) UNIQUE,
    phone         VARCHAR(20),
    event_id      INTEGER REFERENCES event(event_id) ON DELETE SET NULL,
    audience_id   INTEGER REFERENCES audience(audience_id) ON DELETE SET NULL,
    role          VARCHAR(100),
    created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
 
CREATE TABLE help_request (
    help_request_id   SERIAL PRIMARY KEY,
    event_id          INTEGER REFERENCES event(event_id) ON DELETE SET NULL,
    audience_id       INTEGER REFERENCES audience(audience_id) ON DELETE SET NULL,
    assigned_to       INTEGER REFERENCES employee(employee_id) ON DELETE SET NULL,
    subject           VARCHAR(50) NOT NULL,
    description       TEXT,
    status            VARCHAR(20) NOT NULL DEFAULT 'open'
                      CHECK (status IN ('open', 'in_progress', 'resolved', 'closed')),
    created_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    resolved_at       TIMESTAMP,
    CHECK (resolved_at IS NULL OR resolved_at >= created_at)
);
 

 CREATE INDEX idx_event_room       ON event(room_id);
CREATE INDEX idx_event_organizer  ON event(organizer_id);
CREATE INDEX idx_registration_evt ON registration(event_id);
CREATE INDEX idx_registration_aud ON registration(audience_id);
CREATE INDEX idx_volunteer_event  ON volunteer(event_id);
CREATE INDEX idx_help_event       ON help_request(event_id);
CREATE INDEX idx_help_status      ON help_request(status);
 