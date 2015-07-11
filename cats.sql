CREATE TABLE cats (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  owner_id INTEGER,

  FOREIGN KEY(owner_id) REFERENCES human(id)
);

CREATE TABLE humans (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL,
  house_id INTEGER,

  FOREIGN KEY(house_id) REFERENCES human(id)
);

CREATE TABLE houses (
  id INTEGER PRIMARY KEY,
  address VARCHAR(255) NOT NULL
);

INSERT INTO
  houses (id, address)
VALUES
  (1, "26th and Guerrero"), (2, "Dolores and Market");

INSERT INTO
  humans (id, fname, lname, house_id)
VALUES
  (1, "Devon", "Watts", 1),
  (2, "Matt", "Rubens", 1),
  (3, "Ned", "Ruggeri", 2),
  (4, "Catless", "Human", NULL);

INSERT INTO
  cats (id, name, owner_id)
VALUES
  (1, "Breakfast", 1),
  (2, "Earl", 2),
  (3, "Haskell", 3),
  (4, "Markov", 3),
  (5, "Stray Cat", NULL);


DROP TABLE IF EXISTS patients;

CREATE TABLE patients(
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL
);

DROP TABLE IF EXISTS appointments;

CREATE TABLE appointments(
  id INTEGER PRIMARY KEY,
  patient_id INTEGER,
  doctor_id INTEGER,

  FOREIGN KEY(patient_id) REFERENCES patient(id),
  FOREIGN KEY(doctor_id) REFERENCES doctor(id)
);

DROP TABLE IF EXISTS doctors;

CREATE TABLE doctors(
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  type VARCHAR(255) NOT NULL
);

DROP TABLE IF EXISTS stethoscopes;

CREATE TABLE stethoscopes(
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  doctor_id INTEGER,

  FOREIGN KEY(doctor_id) REFERENCES doctor(id)
);

INSERT INTO
  patients (fname, lname)
VALUES
  ("Joe", "Johnson"),
  ("Bob", "Builder"),
  ("Mary", "Jane");

INSERT INTO
  appointments (patient_id, doctor_id)
VALUES
  (1, 2),
  (1, 1),
  (1, 3),
  (2, 3),
  (2, 1);

INSERT INTO
  doctors (name, type)
VALUES
  ("House", "Badass"),
  ("Turk", "Surgeon"),
  ("J.D.", "Resident");

INSERT INTO
  stethoscopes (name, doctor_id)
VALUES
  ("Blue scope", 2),
  ("Red scope", 2);
