 -- Creating the Tenant database
CREATE DATABASE Tenant
-- Now adding all the required tables one at a time

-- 1. Creating the Profiles table
CREATE TABLE Profiles(
  profile_id int IDENTITY(1,1) NOT NULL,
  first_name varchar(255) NULL,
  last_name varchar(255) NULL,
  email varchar(255) NOT NULL,
  phone varchar(255) NOT NULL,
  city varchar(255) NULL,
  created_at date NOT NULL,
  gender varchar(255) NOT NULL,
  referral_code varchar(255) NULL,
  marital_status varchar(255) NULL,
  CONSTRAINT pk_profile_id 
  PRIMARY KEY (profile_id)
)

-- 2. Creating the Houses table
CREATE TABLE Houses(
  house_type varchar(255) NULL,
  bhk_details varchar(255) NULL,
  bed_count int NOT NULL,
  furnishing_type varchar(255) NULL,
  beds_vacant int NOT NULL,
  house_id int IDENTITY(1,1) NOT NULL,
  CONSTRAINT pk_house_id
  PRIMARY KEY (house_id)
)

-- 3. Creating the Tenancy_histories table
CREATE TABLE Tenancy_histories(
   id int IDENTITY(1,1) NOT NULL,
   profile_id int NOT NULL,
   house_id int NOT NULL,
   move_in_date date NOT NULL,
   move_out_date date NULL,
   rent int NOT NULL,
   bed_type varchar(255) NULL,
   move_out_reason varchar(255) NULL,
   CONSTRAINT pk_id PRIMARY KEY (id),
   CONSTRAINT rk_profile_id
   FOREIGN KEY (profile_id)
   REFERENCES Profiles (profile_id),
   CONSTRAINT rk_house_id
   FOREIGN KEY (house_id)
   REFERENCES Houses (house_id)
)

-- 4. Creating the Addresses table
CREATE TABLE Addresses(
  ad_id int IDENTITY(1,1) NOT NULL,
  [name] varchar(255) NULL,
  [description] text NULL,
  pincode int NULL,
  city varchar(255) NULL,
  house_id int NOT NULL,
  CONSTRAINT pk_ad_id PRIMARY KEY (ad_id),
  CONSTRAINT rk_houseid
  FOREIGN KEY (house_id)
  REFERENCES Houses (house_id)
)

-- 5. Creating the Referrals table
CREATE TABLE Referrals(
  ref_id int IDENTITY(1,1) NOT NULL,
  referrer_id int NOT NULL,
  referrer_bonus_amount float NULL,
  referral_valid tinyint NULL
  CONSTRAINT ck_refvalid
  CHECK (referral_valid IN (0,1)),
  valid_from date NULL,
  valid_till date NULL,
  CONSTRAINT pk_ref_id PRIMARY KEY (ref_id),
  CONSTRAINT rk_referrer_id
  FOREIGN KEY (referrer_id)
  REFERENCES Profiles (profile_id)
)

-- 6. Creating the Employment_details table
CREATE TABLE Employment_details(
  id int IDENTITY(1,1) NOT NULL,
  profile_id int NOT NULL,
  latest_employer varchar(255) NULL,
  official_mail_id varchar(255) NULL,
  yrs_experience int NULL,
  occupational_category varchar(255) NULL,
  CONSTRAINT pk_empid PRIMARY KEY (id),
  CONSTRAINT rk_profileid
  FOREIGN KEY (profile_id)
  REFERENCES Profiles (profile_id)
)

-- First allowing the insertion of identity values into the tables
SET IDENTITY_INSERT Addresses OFF
SET IDENTITY_INSERT Employment_details OFF
SET IDENTITY_INSERT Houses OFF
SET IDENTITY_INSERT Profiles OFF
SET IDENTITY_INSERT Referrals OFF
SET IDENTITY_INSERT Tenancy_histories OFF

-- Trying to bulk insert values into the specified tables
BULK INSERT Addresses
FROM 'D:\Edvancer_IITK\SQL\project_details\SQL_Old_Project_Import_Data_Files\Addresses.csv'
WITH(
  --FIELDTERMINATOR = ',',
  --ROWTERMINATOR = '\n',
  FORMAT = 'CSV',
  FIRSTROW = 2
  --LASTROW = 21
)

-- Inserting single values at a time as this is working just fine
-- For Houses table
INSERT INTO Houses(house_type,bhk_details,bed_count,furnishing_type,beds_vacant,house_id)
VALUES('Independent','1 BHK',2,'unfurnished',2,20)

SELECT * FROM Houses

-- For Profiles table
--DELETE FROM Profiles WHERE profile_id = 3
INSERT INTO Profiles(first_name, last_name, email, phone, city, created_at,
                     gender, referral_code, marital_status, profile_id)
VALUES('Karan','Singh','karan.singh@gmail.com',8976665768,'Delhi','2015-09-15','M','LRF34F','N',20)

SELECT * FROM Profiles

-- For Tenancy_histories table
INSERT INTO Tenancy_histories(move_in_date,move_out_date,rent,bed_type,
                              move_out_reason, house_id, profile_id, id)
VALUES('2015-09-30',NULL,9500,'bed',NULL,11,20,20)

SELECT * FROM Tenancy_histories

-- For Addresses table
INSERT INTO Addresses([name], [description], city, pincode, house_id, ad_id)
VALUES('Sun city appartments','Majeera Diamond Towers,malad-west','Pune',5600263,20,21)

SELECT * FROM Addresses

-- For Referrals table
INSERT INTO Referrals(referrer_bonus_amount,referral_valid,valid_from,valid_till,referrer_id,ref_id)
VALUES(1000,1,'2016-04-25','2016-06-24',5,15)

SELECT * FROM Referrals

-- For Emploment_details table
INSERT INTO Employment_details(latest_employer, official_mail_id, yrs_experience, 
                               occupational_category, profile_id, id)
VALUES('Tiny Mogul Games','sanchit@hike.in',3,'Working',20,20)

SELECT * FROM Employment_details


-- This portion contains queries for the project questions
-- 1. sol_1
SELECT p.profile_id AS 'Profile ID',
  (p.first_name +' '+ p.last_name) AS 'Full Name',
  p.phone AS 'Contact Number'
FROM Profiles AS p
WHERE p.profile_id IN (SELECT th.profile_id
                       FROM Tenancy_histories AS th
					   WHERE th.move_out_date IS NULL)

-- 2. sol_2
SELECT p.profile_id AS 'Profile ID',
  (p.first_name +' '+ p.last_name) AS 'Full Name',
  p.phone AS 'Contact Number'
FROM Profiles AS p
WHERE p.marital_status = 'Y' AND
     p.profile_id IN (SELECT th.profile_id 
	                 FROM Tenancy_histories AS th
					 WHERE th.rent > 9000)

-- 3. sol_3
SELECT p.profile_id AS 'Profile ID',
  (p.first_name + ' ' + p.last_name) AS 'Full Name',
  p.phone AS Contact,
  p.email AS 'Email ID',
  p.city AS City,
  th.house_id AS 'House ID',
  th.move_in_date AS move_in_date,
  th.move_out_date AS move_out_date,
  th.rent AS Rent,
  SUM(ref.referral_valid)
   OVER(PARTITION BY p.profile_id) AS 'Total No. of Referrals', 
  ed.latest_employer AS 'Latest Employer',
  ed.occupational_category AS 'Occupation Category'
FROM Profiles AS p
FULL JOIN Tenancy_histories AS th
ON th.profile_id = p.profile_id
FULL JOIN Employment_details AS ed
ON ed.profile_id = p.profile_id
FULL JOIN Referrals AS ref
ON ref.referrer_id = p.profile_id
WHERE p.city IN ('Bangalore','Pune') AND
  th.move_in_date >= '2015-01-01' AND th.move_out_date < '2016-01-31'
ORDER BY th.rent DESC

-- 4. sol_4
SELECT (p.first_name + ' ' + p.last_name) AS full_name,
  p.email AS email_id,
  p.phone AS 'phone number',
  p.referral_code AS 'referral code',
  SUM(ref.referrer_bonus_amount) AS 'total bonus'
FROM Profiles AS p
FULL JOIN Referrals AS ref
ON ref.referrer_id = p.profile_id
WHERE ref.referral_valid = 1 --AND
      -- p.referral_code IS NOT NULL
GROUP BY p.first_name,p.last_name,
         p.email,p.phone,p.referral_code

-- 5. sol_5
SELECT ad.city AS City, th.rent AS Rent,
   SUM(th.rent) OVER(PARTITION BY ad.city) AS Rent_over_cities
FROM Tenancy_histories AS th
FULL JOIN Addresses AS ad
ON ad.house_id = th.house_id 

-- 6. sol_6
CREATE VIEW vw_tenant
AS
SELECT th.profile_id AS profile_id,
  th.rent AS rent,
  th.move_in_date AS move_in_date,
  h.house_type AS house_type,
  h.beds_vacant AS beds_vacant,
  ad.[description] AS 'description',
  ad.city AS city,
  CONCAT(ad.[name],  ' ',  ad.[description], ' ',
   ad.city, ' ',  ad.pincode) AS 'address'
FROM Tenancy_histories AS th
FULL JOIN Houses AS h
ON h.house_id = th.house_id
FULL JOIN Addresses AS ad
ON ad.house_id = th.house_id
WHERE th.move_in_date >= '2015-04-30' AND
  h.beds_vacant > 0

-- checking if the view is working
SELECT * FROM vw_tenant

-- 7. sol_7
-- creating a view to not affect the Referrals table
CREATE VIEW vw_val_till
AS 
SELECT * FROM Referrals

-- updating the view as per the condition
UPDATE vw_val_till
SET valid_till = DATEADD(MM, 1, valid_till)
FROM vw_val_till
WHERE referral_valid > 0 

-- checking the updated view
SELECT * FROM vw_val_till

-- 8. sol_8
SELECT p.profile_id AS 'Profile ID', 
 (p.first_name + ' ' + p.last_name) AS 'Full Name',
 p.phone AS 'Contact Number',
 IIF(th.rent > 10000, 'A',
     IIF(th.rent >= 7500 AND th.rent <= 10000, 'B', 'C')) AS 'Customer Segment'
FROM Profiles AS p
FULL JOIN Tenancy_histories AS th
ON th.profile_id = p.profile_id

-- 9. sol_9
SELECT p.profile_id AS 'Profile ID', 
 (p.first_name + ' ' + p.last_name) AS 'Full Name',
 p.phone AS 'Contact Number',
 p.city AS City,
 h.*
FROM Profiles AS p
FULL JOIN Houses AS h
ON h.house_id = p.profile_id
WHERE p.profile_id NOT IN 
  (SELECT referrer_id FROM Referrals)

-- 10. sol_10
SELECT *,
 (bed_count - beds_vacant) AS vacancy
FROM Houses
ORDER BY (bed_count - beds_vacant) DESC


-- Below question are changed as per the suggestion
-- from initial submission.

-- Q4 as suggested 
select 
  p1.first_name + '  '  + p1.last_name as full_name,
  p1.email,
  p1.phone,
  p1.referral_code,
  t2.total_bonus 
from profiles as p1
join (select referrer_id,
        count(referrer_id) as referral_code
	  from Referrals 
	  group by referrer_id)
  as t1 on p1.profile_id = t1.referrer_id
join (select referrer_id,
        sum(referrer_bonus_amount) as total_bonus
	  from Referrals 
      where referral_valid=1
	  group by referrer_id)
   as t2 on t1.referrer_id = t2.referrer_id
where t1.referral_code > 1

-- Q1
SELECT p.profile_id AS 'Profile ID',
  (p.first_name +' '+ p.last_name) AS 'Full Name',
  p.phone AS 'Contact Number',
  p.email,
  CONCAT(th.diff/12, ' year ',th.diff%12, ' month') AS 'time period'
FROM Profiles AS p
JOIN (SELECT profile_id,
       move_in_date,
	   move_out_date,
	   DATEDIFF(MM, move_in_date, GETDATE()) AS diff
      FROM Tenancy_histories
	  WHERE move_out_date IS NULL) AS th
ON th.profile_id = p.profile_id
WHERE p.profile_id LIKE th.profile_id

-- Q2
SELECT p.profile_id AS 'Profile ID',
  (p.first_name +' '+ p.last_name) AS 'Full Name',
  p.phone AS 'Contact Number',
  p.email
FROM Profiles AS p
WHERE p.marital_status = 'Y' AND
     p.profile_id IN (SELECT th.profile_id 
	                 FROM Tenancy_histories AS th
					 WHERE th.rent > 9000)

-- Q10
SELECT h.house_type,
 h.bhk_details,
 h.bed_count,
 h.furnishing_type,
 h.beds_vacant,
 h.house_id,
 (h.bed_count - h.beds_vacant) AS vacancy,
 ad.[name]
FROM Houses AS h
JOIN Addresses AS ad
ON ad.house_id = h.house_id
ORDER BY (h.bed_count - h.beds_vacant) DESC