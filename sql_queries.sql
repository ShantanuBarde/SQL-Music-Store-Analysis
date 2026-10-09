-- Q.1 WHO IS THE SENIOR MOST EMPLOYEE BASED ON JOB TITLE\
SELECT * FROM EMPLOYEE
ORDER BY LEVELS DESC
LIMIT 1

-- Q.2 WHICH COUNTRY HAVE THE MOST INVOICES?
SELECT COUNT (*) AS  C, BILLING_COUNTRY FROM INVOICE
GROUP BY BILLING_COUNTRY
ORDER BY C DESC

-- Q.3 WHAT ARE TOP 3 VALUES OF TOTAL INVOICE
SELECT TOTAL FROM INVOICE
ORDER BY TOTAL DESC
LIMIT 3

-- Q.4 WHIHC CITY HAS THE BEST CUSTOMERS? WE WOULD LIKE TO THROW
-- A PROMOTIONAL MUSIC FESTIVAL IN THE CITY WE MADE THE MOST MONEY. 
-- WRITE A QUERY THAT RETURNS ONE CITY
-- THAT HAS THE HIGHEST SUM OF INVOICE TOTALS RETURN BOTH THE CITY NAME & SUM 
-- OF ALL INVOICE TOTALS.

SELECT SUM(TOTAL) AS INVOICE_TOTAL , BILLING_CITY
FROM INVOICE 
GROUP BY BILLING_CITY
ORDER BY INVOICE_TOTAL DESC

-- Q.5 WHO IS THE BEST CUSTOMER? THE CUSTOMER WHO HAS SPENT THE MOST
-- MOST MONEY WILL BE DECLARED THE BEST CUSTOMER. WRITE A QUERY THAT RETURNS
-- THE PERSON WHO HAS SPENT THE MOST MONEY.

SELECT CUSTOMER.CUSTOMER_ID, CUSTOMER.FIRST_NAME, CUSTOMER.LAST_NAME, SUM(INVOICE.TOTAL) AS TOTAL
FROM CUSTOMER
JOIN INVOICE ON CUSTOMER.CUSTOMER_ID = INVOICE.CUSTOMER_ID
GROUP BY
CUSTOMER.CUSTOMER_ID
ORDER BY TOTAL DESC
LIMIT 1


QUESTION SET 2- MODERATE

-- Q.1 WRITE QUERY TO RETURN THE EMSIL, FIERST_NAME, LAST_NAME, & GENRE
-- OF ALL ROCK MUSIC LISTENERS. RETURN YOUR LIST ORDERES=D ALPHABETICALLY BY EMAIL STARTING WITH A

SELECT DISTINCT
    CUSTOMER.EMAIL,
    CUSTOMER.FIRST_NAME,
    CUSTOMER.LAST_NAME,
    GENRE.NAME AS GENRE
FROM CUSTOMER
JOIN INVOICE
    ON CUSTOMER.CUSTOMER_ID = INVOICE.CUSTOMER_ID
JOIN INVOICE_LINE
    ON INVOICE.INVOICE_ID = INVOICE_LINE.INVOICE_ID
JOIN TRACK
    ON INVOICE_LINE.TRACK_ID = TRACK.TRACK_ID
JOIN GENRE
    ON TRACK.GENRE_ID = GENRE.GENRE_ID
WHERE GENRE.NAME = 'Rock'
ORDER BY CUSTOMER.EMAIL ASC;

-- Q.2 LETS INVITE THE ARTISTS WHO HAVE WRITTEN THE MOST ROCK MUSIC IN
-- OUR DATASET. WRITE A QUERY THAT RETURNS THE ARTIST NAME AND TOTAL
-- TRACK COUNT OF THE TOP 10 ROCKS BANDS.

SELECT 
    ARTIST.ARTIST_ID,
    ARTIST.NAME,
    COUNT(TRACK.TRACK_ID) AS NUMBER_OF_SONGS
FROM TRACK
JOIN ALBUM 
    ON ALBUM.ALBUM_ID = TRACK.ALBUM_ID
JOIN ARTIST 
    ON ARTIST.ARTIST_ID = ALBUM.ARTIST_ID
JOIN GENRE 
    ON GENRE.GENRE_ID = TRACK.GENRE_ID
WHERE GENRE.NAME = 'Rock'
GROUP BY 
    ARTIST.ARTIST_ID,
    ARTIST.NAME
ORDER BY NUMBER_OF_SONGS DESC
LIMIT 10;

-- Q.3 RETURN ALL THE TRACK NAMES THAT HAVE A SONG LENGTH LONGER THAN
-- THE AVERAGE SONG LENGTH. RETURN THE NAME AND MILISECOONDS FOR EACH TRACK. ORDER BY 
-- THE SONG LENGTH WILL THE LONGEST SONGS LISTED FIRST.

SELECT NAME, MILLISECONDS
FROM TRACK
WHERE MILLISECONDS>(
SELECT AVG(MILLISECONDS) AS AVG_TRACK_LENGTH
FROM TRACK)
ORDER BY MILLISECONDS DESC;

QUESTION SET 3- ADVANCE

-- Q.1 FIND HOW MUCH AMOUNT SPENT BY EACH CUSTOMER ON ARTISTS? WRITE A QUERY TO RETURN
-- CUSTOMER NAME, ARTIST NAME AND TOTAL SPENT.

WITH BEST_SELLING_ARTIST AS(
SELECT ARTIST.ARTIST_ID AS ARTIST_ID, ARTIST.NAME AS ARTIST_NAME,
SUM(INVOICE_LINE.UNIT_PRICE* INVOICE_LINE.QUANTITY) AS TOTAL_SALES
FROM INVOICE_LINE
JOIN TRACK ON TRACK.TRACK_ID= INVOICE_LINE.TRACK_ID
JOIN ALBUM ON ALBUM.ALBUM_ID=TRACK.ALBUM_ID
JOIN ARTIST ON ARTIST.ARTIST_ID=ALBUM.ARTIST_ID
GROUP BY 1
ORDER BY 3 DESC
LIMIT 1
)
SELECT c.customer_id,
       c.first_name,
       c.last_name,
       bsa.artist_name,
       SUM(il.unit_price * il.quantity) AS amount_spent
FROM invoice i
JOIN customer c 
    ON c.customer_id = i.customer_id
JOIN invoice_line il 
    ON il.invoice_id = i.invoice_id
JOIN track t 
    ON t.track_id = il.track_id
JOIN album alb 
    ON alb.album_id = t.album_id
JOIN best_selling_artist bsa 
    ON bsa.artist_id = alb.artist_id
GROUP BY 1, 2, 3, 4
ORDER BY 5 DESC;

-- Q.2 WE WANT TO FIND OUT THE MOST POPULAR MUSIC GENRE FOR EACH COUNTRY. WE DETERMINE THE MOST POPULAR GENRE AS THE GENRE WITH THE HIGHEST AMOUNT OF PURCHASES. WRITE A QUERY THAT RETURNS EACH COUNTRY ALONG WITH THE TOP GENRE. FOR COUNTRIES WHERE THE MAXIMUM NUMBER
-- OF PURCHAES IS SHARED RETURN ALL GENRES.

WITH popular_genre AS
(
    SELECT 
        COUNT(invoice_line.quantity) AS purchases,
        customer.country,
        genre.name,
        genre.genre_id,
        ROW_NUMBER() OVER (
            PARTITION BY customer.country 
            ORDER BY COUNT(invoice_line.quantity) DESC
        ) AS RowNo
    FROM invoice_line
    JOIN invoice 
        ON invoice.invoice_id = invoice_line.invoice_id
    JOIN customer 
        ON customer.customer_id = invoice.customer_id
    JOIN track 
        ON track.track_id = invoice_line.track_id
    JOIN genre 
        ON genre.genre_id = track.genre_id
    GROUP BY 2, 3, 4
    ORDER BY 2 ASC, 1 DESC
)

SELECT *
FROM popular_genre
WHERE RowNo <= 1;

-- Q3: Write a query that determines the customer that has spent the most on music for each country.
-- Write a query that returns the country along with the top customer and how much they spent.
-- For countries where the top amount spent is shared, provide all customers who spent this amount.

-- WITH RECURSIVE
--     customer_with_country AS (
--         SELECT 
--             customer.customer_id,
--             first_name,
--             last_name,
--             billing_country,
--             SUM(total) AS total_spending
--         FROM invoice
--         JOIN customer 
--             ON customer.customer_id = invoice.customer_id
--         GROUP BY 1, 2, 3, 4
--         ORDER BY 2, 3 DESC
--     ),

--     country_max_spending AS (
--         SELECT 
--             billing_country,
--             MAX(total_spending) AS max_spending
--         FROM customer_with_country
--         GROUP BY billing_country
--     )

-- SELECT 
--     cc.billing_country,
--     cc.total_spending,
--     cc.first_name,
--     cc.last_name
-- FROM customer_with_country cc
-- JOIN country_max_spending ms
--     ON cc.billing_country = ms.billing_country
--     AND cc.total_spending = ms.max_spending
-- ORDER BY cc.billing_country;

WITH Customer_with_country AS (
    SELECT 
        customer.customer_id,
        first_name,
        last_name,
        billing_country,
        SUM(total) AS total_spending,
        ROW_NUMBER() OVER (
            PARTITION BY billing_country 
            ORDER BY SUM(total) DESC
        ) AS RowNo
    FROM invoice
    JOIN customer 
        ON customer.customer_id = invoice.customer_id
    GROUP BY 1, 2, 3, 4
    ORDER BY 4 ASC, 5 DESC
)

SELECT *
FROM Customer_with_country
WHERE RowNo <= 1;