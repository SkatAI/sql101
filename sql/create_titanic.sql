-- Titanic Dataset Table Creation
-- PostgreSQL

DROP TABLE IF EXISTS titanic CASCADE;

CREATE TABLE titanic (
    passenger_id INTEGER PRIMARY KEY,
    survived INTEGER CHECK (survived IN (0, 1)),  -- 0 = No, 1 = Yes
    pclass INTEGER CHECK (pclass IN (1, 2, 3)),   -- Passenger class (1st, 2nd, 3rd)
    name VARCHAR(100) NOT NULL,
    sex VARCHAR(10) CHECK (sex IN ('male', 'female')),
    age DECIMAL(5,2),  -- Age in years, can have decimals for infants
    sibsp INTEGER,     -- Number of siblings/spouses aboard
    parch INTEGER,     -- Number of parents/children aboard
    ticket VARCHAR(20),
    fare DECIMAL(10,4),
    cabin VARCHAR(20),
    embarked CHAR(1) CHECK (embarked IN ('C', 'Q', 'S'))  -- Port: C=Cherbourg, Q=Queenstown, S=Southampton
);

-- Create indexes for common queries
CREATE INDEX idx_titanic_survived ON titanic(survived);
CREATE INDEX idx_titanic_pclass ON titanic(pclass);
CREATE INDEX idx_titanic_sex ON titanic(sex);
CREATE INDEX idx_titanic_age ON titanic(age);

-- Import command:
-- \COPY titanic FROM 'titanic.csv' WITH (FORMAT CSV, HEADER true, DELIMITER ',', NULL '');