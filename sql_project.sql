/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */
USE  country_club;

SELECT * FROM Facilities WHERE membercost = 0.0;

/* Resulting list should be: Badminton Court, Table Tennis, Snooker Table, Pool Table */

/* Q2: How many facilities do not charge a fee to members? */
USE counry_club;
SELECT COUNT(*) FROM Facilities WHERE membercost = 0.0;

/* Result should be Count of 4 */

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
USE country_club;

SELECT * FROM Facilities WHERE (membercost * 10) < (.20 * monthlymaintenance);
/* I multiplied the membercost by 10 because it seemed silly to have numbers like 9.9 for membership and non of the other groups would have been removed from the list*/

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */
USE country_club;
SELECT * FROM Facilities WHERE facid IN (1, 5);

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */
USE country_club;
SELECT name, monthlymaintenance,
  CASE
    WHEN monthlymaintenance < 100
    THEN 'cheap'
    WHEN monthlymaintenance > 100
    THEN 'expensive'
  END AS relative_cost
FROM Facilities; 

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */
USE country_club;
SELECT concat(mem.firstname, mem.surname) as fullname, fac.name, sum(boo.cost, boo.guestcost) as totalcost
FROM Bookings as boo
JOIN Members as mem
ON boo.memid = mem.memid
JOIN Facility fac
ON boo.facid = fac.facid;

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
USE country_club;
SELECT DISTINCT concat(mem.firstname, mem.surname) as fullname, fac.name
FROM Bookings as boo
JOIN Members as mem
ON boo.memid = mem.memid
JOIN Facilities as fac
ON boo.facid = fac.facid
WHERE boo.facid = 0
OR boo.facid = 1
AND boo.memid != 0
GROUP BY fullname
ORDER BY fullname ASC;


/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

USE country_club;
SELECT fac.name, concat(mem.firstname, ' ', mem.surname) as fullname, starttime, (slots * 30) as mincost,
CASE
  WHEN boo.memid=0 THEN boo.slots*fac.guestcost
  ELSE boo.slots*fac.membercost
END AS cost
FROM Bookings as boo
LEFT JOIN Members as mem
ON boo.memid = mem.memid
LEFT JOIN Facilities as fac
ON boo.facid = fac.facid
WHERE starttime LIKE '2012-09-14%'
HAVING cost > 30;

/* Q9: This time, produce the same result as in Q8, but using a subquery. */
USE country_club;
SELECT facilities.name, 
	   concat(members.firstname, '_', members.surname) as member_name,
	   CASE WHEN members.memid = 0 THEN facilities.guestcost*bookings.slots
		ELSE facilities.membercost*bookings.slots END AS costs
FROM (
	SELECT memid, facid, slots FROM Bookings WHERE Bookings.starttime LIKE '2012-09-14%'
	 ) bookings
JOIN Facilities facilities ON bookings.facid = facilities.facid
JOIN Members members ON bookings.memid = members.memid
HAVING costs > 30
ORDER BY costs DESC;

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

USE country_club;
SELECT fac.name,
SUM(CASE
  WHEN boo.memid=0 THEN boo.slots*fac.guestcost
  ELSE boo.slots*fac.membercost
END) AS cost
FROM Bookings as boo
LEFT JOIN Members as mem
ON boo.memid = mem.memid
LEFT JOIN Facilities as fac
ON boo.facid = fac.facid
GROUP BY fac.name;