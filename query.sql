-- user table
CREATE TABLE if not exists Users (
    user_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    role VARCHAR(20) NOT NULL
        CHECK (role IN ('Ticket Manager', 'Football Fan')),
    phone_number VARCHAR(20)
);
-- matches table
CREATE TABLE if not exists Matches (
    match_id SERIAL PRIMARY KEY,
    fixture VARCHAR(100) NOT NULL,
    tournament_category VARCHAR(100) NOT NULL,
    base_ticket_price DECIMAL(10,2) NOT NULL
        CHECK (base_ticket_price >= 0),
    match_status VARCHAR(20) NOT NULL
        CHECK (match_status IN ('Available', 'Selling Fast', 'Sold Out', 'Postponed'))
);
-- bookings table
CREATE TABLE if not exists Bookings (
    booking_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    match_id INT NOT NULL,
    seat_number VARCHAR(20),
    payment_status VARCHAR(20)
        CHECK (payment_status IN ('Pending', 'Confirmed', 'Cancelled', 'Refunded')),
    total_cost DECIMAL(10,2) NOT NULL
        CHECK (total_cost >= 0),

    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (match_id) REFERENCES Matches(match_id),

    UNIQUE (match_id, seat_number)
);

-- queries
--1
SELECT fixture,
       ROUND(base_ticket_price, 0) AS base_ticket_price
FROM Matches
WHERE tournament_category = 'Champions League';

--2
SELECT full_name, email
FROM Users
WHERE full_name ILIKE 'Tanvir%' OR full_name ILIKE '%Haque%';

--3
SELECT booking_id,user_id,match_id , coalesce(payment_status,'Action Required')FROM bookings
WHERE payment_status IS NULL;

--4
SELECT booking_id,full_name,fixture,ROUND(total_cost) AS total_cost FROM bookings
INNER JOIN users ON bookings.user_id = users.user_id
INNER JOIN matches ON bookings.match_id = matches.match_id;

--5
SELECT
    users.user_id,
    users.full_name,
    bookings.booking_id
FROM users
FULL JOIN bookings
ON users.user_id = bookings.user_id;


--6
SELECT booking_id,match_id, round(total_cost) as total_cost FROM bookings
WHERE total_cost > (
  SELECT AVG(total_cost) FROM bookings
);

--7
SELECT match_id,fixture,round(base_ticket_price)as base_ticket_price FROM matches
ORDER BY base_ticket_price DESC LIMIT 2 OFFSET 1