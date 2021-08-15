CREATE TABLE employee_position (
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    name VARCHAR NOT NULL UNIQUE
);

CREATE TABLE employee (
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    name VARCHAR NOT NULL,
    access_group INTEGER NOT NULL,
    position_id INTEGER NOT NULL,
    CONSTRAINT fk_position
        FOREIGN KEY (position_id)
        REFERENCES employee_position(id)
);

CREATE TABLE request_type (
   id  INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
   short_name VARCHAR NOT NULL UNIQUE,
   full_name  VARCHAR NOT NULL
);

CREATE TABLE megabilling_type_assoc (
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    name VARCHAR NOT NULL,
    request_type_id INTEGER NOT NULL,
    CONSTRAINT fk_request_type
        FOREIGN KEY (request_type_id)
        REFERENCES request_type(id)
);

CREATE TABLE recent_documents (
   id  INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
   path VARCHAR NOT NULL
);
