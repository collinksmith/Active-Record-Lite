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
