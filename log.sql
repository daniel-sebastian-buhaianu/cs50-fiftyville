/* Keep a log of any SQL queries you execute as you solve the mystery. */

/*  Read the crime scene report in order to understand 
    what exactly happened at the time of the crime */

-- SELECT * FROM crime_scene_reports
--     WHERE year = 2021 
--     AND month = 7 
--     AND day = 28
--     AND street = 'Humphrey Street';

/* New clues: Theft at 10:15am at the humphrey street bakery, 3 witnesses + interviews */

/* Check the witnesses' interview transcript */

-- SELECT * FROM interviews
--     WHERE year = 2021
--     AND month = 7
--     AND day = 28;

/*

Now, the question is... who is the thief, and who is the accomplice?  

To answer this question, I need to review all the details 
from the beginning of the case, and fill in the gaps

1) Witness 1

"Sometime within ten minutes of the theft, 
I saw the thief get into a car in the bakery parking lot and drive away. 
If you have security footage from the bakery parking lot, 
you might want to look for cars that left the parking lot in that time frame."

After looking into this, I've found that...

5P2BI95 exited bakery @ 10:16am
94KL13X exited bakery @ 10:18am
6P58WS2 exited bakery @ 10:18am
4328GD8 exited bakery @ 10:19am
G412CB7 exited bakery @ 10:20am
L93JTIZ exited bakery @ 10:21am
322W7JE exited bakery @ 10:23am
0NTHK55 exited bakery @ 10:23am

2) Witness 2

"I don't know the thief's name, but it was someone I recognized. 
Earlier this morning, before I arrived at Emma's bakery, 
I was walking by the ATM on Leggett Street and saw the thief there withdrawing some money."

After looking into this...

SELECT * from people
    WHERE license_plate IN
        (SELECT license_plate FROM bakery_security_logs
            WHERE year = 2021
            AND month = 7
            AND day = 28
            AND hour = 10
            AND minute >= 15
            AND minute <= 25
            AND activity = 'exit')
    AND id IN
        (SELECT person_id FROM bank_accounts
            WHERE account_number IN
                (SELECT account_number FROM atm_transactions
                    WHERE year = 2021
                    AND month = 7
                    AND day = 28
                    AND atm_location = 'Leggett Street'
                    AND transaction_type = 'withdraw'));


I've found 4 people who exited the bakery within 10 minutes of the theft
and also withdrew money that morning:

396669|Iman|(829) 555-5269|7049073643|L93JTIZ
467400|Luca|(389) 555-5198|8496433585|4328GD8
514354|Diana|(770) 555-1861|3592750733|322W7JE
686048|Bruce|(367) 555-5533|5773159633|94KL13X

3) Witness 3

As the thief was leaving the bakery, 
they called someone who talked to them for less than a minute. 
In the call, I heard the thief say that they were planning to take the earliest flight out of Fiftyville tomorrow. 
The thief then asked the person on the other end of the phone to purchase the flight ticket.

SELECT * from people
    WHERE license_plate IN
        (SELECT license_plate FROM bakery_security_logs
            WHERE year = 2021
            AND month = 7
            AND day = 28
            AND hour = 10
            AND minute >= 15
            AND minute <= 25
            AND activity = 'exit')
    AND id IN
        (SELECT person_id FROM bank_accounts
            WHERE account_number IN
                (SELECT account_number FROM atm_transactions
                    WHERE year = 2021
                    AND month = 7
                    AND day = 28
                    AND atm_location = 'Leggett Street'
                    AND transaction_type = 'withdraw'))
    AND phone_number IN
        (SELECT caller FROM phone_calls
            WHERE year = 2021
            AND month = 7
            AND day = 28
            AND duration < 60);

After looking into this, I got only 2 suspects left:

514354|Diana|(770) 555-1861|3592750733|322W7JE
686048|Bruce|(367) 555-5533|5773159633|94KL13X

Diana and Bruce, both left the bakery within 10 minutes of the theft
both withdrew money from the ATM on Leggett Street that morning
and both made a quick call (less than 60s) that day.

However, only Bruce is the one who did all the above 
and also hopped on the first flight out of Fiftyville
first thing in the morning the next day

-- Code below finds out who the thief is:

SELECT * from people
    WHERE license_plate IN
        (SELECT license_plate FROM bakery_security_logs
            WHERE year = 2021
            AND month = 7
            AND day = 28
            AND hour = 10
            AND minute >= 15
            AND minute <= 25
            AND activity = 'exit')
    AND id IN
        (SELECT person_id FROM bank_accounts
            WHERE account_number IN
                (SELECT account_number FROM atm_transactions
                    WHERE year = 2021
                    AND month = 7
                    AND day = 28
                    AND atm_location = 'Leggett Street'
                    AND transaction_type = 'withdraw'))
    AND phone_number IN
        (SELECT caller FROM phone_calls
            WHERE year = 2021
            AND month = 7
            AND day = 28
            AND duration < 60)
    AND passport_number IN (
        SELECT passport_number FROM passengers
            WHERE flight_id IN (
                SELECT id FROM flights
                    WHERE origin_airport_id = (
                        SELECT id FROM airports
                            WHERE city = 'Fiftyville'
                    )
                    AND year = 2021
                    AND month = 7
                    AND day = 29
                    ORDER BY hour
                    LIMIT 1
            )
    );

All that's left to do now is find out who is Bruce's accomplice.
That's an easy one, as I can look into who Bruce called that day.


Code bellow finds out who the accomplice is:

SELECT * FROM people
    WHERE phone_number = (
        SELECT receiver FROM phone_calls
            WHERE year = 2021
            AND month = 7
            AND day = 28
            AND duration < 60
            AND caller = (
                SELECT phone_number FROM people
                    WHERE id = (
                        SELECT id from people
                            WHERE license_plate IN
                                (SELECT license_plate FROM bakery_security_logs
                                    WHERE year = 2021
                                    AND month = 7
                                    AND day = 28
                                    AND hour = 10
                                    AND minute >= 15
                                    AND minute <= 25
                                    AND activity = 'exit')
                            AND id IN
                                (SELECT person_id FROM bank_accounts
                                    WHERE account_number IN
                                        (SELECT account_number FROM atm_transactions
                                            WHERE year = 2021
                                            AND month = 7
                                            AND day = 28
                                            AND atm_location = 'Leggett Street'
                                            AND transaction_type = 'withdraw'))
                            AND phone_number IN
                                (SELECT caller FROM phone_calls
                                    WHERE year = 2021
                                    AND month = 7
                                    AND day = 28
                                    AND duration < 60)
                            AND passport_number IN (
                                SELECT passport_number FROM passengers
                                    WHERE flight_id IN (
                                        SELECT id FROM flights
                                            WHERE origin_airport_id = (
                                                SELECT id FROM airports
                                                    WHERE city = 'Fiftyville'
                                            )
                                            AND year = 2021
                                            AND month = 7
                                            AND day = 29
                                            ORDER BY hour
                                            LIMIT 1
                                    )
                            )
                        )   
                )   
    );

Answer: Robin

Up to this point, I know Bruce is the thief and Robin his accomplice.

The question is now... Where did Bruce fly to?

SELECT city FROM airports
    WHERE id = (
        SELECT destination_airport_id FROM flights
            WHERE origin_airport_id = (
                SELECT id FROM airports
                    WHERE city = 'Fiftyville'
            )
            AND year = 2021
            AND month = 7
            AND day = 29
            ORDER BY hour ASC 
            LIMIT 1
    );

Answer: New York City

To answer the questions from the beginning:
1) Who the thief is: Bruce
2) Where the thief escaped to: New York City
3) Who the thief's accomplice was who helped them escape town: Robin

*/