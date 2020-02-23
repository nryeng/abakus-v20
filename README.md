# Modern SQL in MySQL

These instructions are meant to be used together with a live presentation.

This training course will show you how to use JSON, CTEs and window
functions in MySQL. As a finishing touch, if we have time, we'll finish
with some geographical data.


## Requirements

This training session assumes that you're using MySQL 8.0.18 or
newer. It has not been tested with older versions.


## 0. Getting started

Download the file `dataset.sql`
(https://raw.githubusercontent.com/nryeng/abakus-v20/master/dataset.sql)
from the Github repository and put it on your hard drive (`/tmp`, or
`C:\` on Windows).

Start the MySQL client and load the data set: `source /tmp/dataset.sql`
(or `source C:\dataset.sql` on Windows)

Let's examine the data set:

1. `SHOW TABLES;`

2. `SHOW CREATE TABLE employees;`

3. `SELECT * FROM employees;`

4. `SHOW CREATE TABLE courses;`

5. `SELECT * FROM courses;`

6. `SHOW CREATE TABLE prerequisites;`

7. `SELECT * FROM prerequisites;`

8. `SHOW CREATE TABLE students;`

9. `SELECT * FROM students;` or maybe `SELECT id, JSON_PRETTY(doc) FROM
   students\G` is easier to read.


## 1. Non-recursive CTEs

Use CTEs to give name to a query:

    WITH course_info AS (
      SELECT
        id AS course_id,
        courses.name AS course_name,
        employees.number AS lecturer_id,
        employees.name AS lecturer_name
      FROM courses, employees
      WHERE lecturer = number
    )
    SELECT * FROM course_info WHERE lecturer_name = 'Bob';

## 2. Recursive CTEs

We want to find the reporting chain for all employees.

It's straight forward to find everyone who reports directly to a
particular manager:

    SELECT name
    FROM employees
    WHERE
      manager = (SELECT number FROM employees WHERE name = 'Betty');

If we want to find the entire hierarchy under the manager, we have to
use a recursive CTE:

    WITH RECURSIVE subordinates AS (
        SELECT number, name
        FROM employees
        WHERE
          manager = (SELECT number FROM employees WHERE name = 'Betty')
      UNION ALL
        SELECT e.number, e.name
        FROM employees e JOIN subordinates s ON e.manager = s.number
    )
    SELECT name FROM subordinates;

We can use this to find the reporting chain for all employees:

    WITH RECURSIVE emps AS (
        SELECT number, name, manager, name AS reporting_chain
        FROM employees
        WHERE manager IS NULL
      UNION ALL
        SELECT
          e.number,
          e.name,
          e.manager,
          CONCAT(e.name, ', ', m.reporting_chain)
        FROM employees AS e JOIN emps AS m ON e.manager = m.number
      )
      SELECT * FROM emps;

## 3. Window functions

Window functions
(https://dev.mysql.com/doc/refman/8.0/en/window-functions.html) compute
one value using a number of rows as input. It can look at rows before
and after the current row.

    SELECT
      name,
      dept_id,
      salary,
      SUM(salary) OVER (PARTITION BY dept_id) AS dept_total
    FROM employees
    ORDER BY dept_id, name;


## 4. JSON paths

We'll use the `->>` operator to extract data from the JSON document in
the `students` table. The operator takes a JSON value (e.g., a JSON
column) on its left hand side and a JSON path string on the right hand
side. The JSON path syntax
(https://dev.mysql.com/doc/refman/8.0/en/json.html#json-path-syntax)
allows us to refer to specific elements in a JSON document.

We can extract the names of all students:

    SELECT doc->>'$.name' FROM students;

In order to refer to the extracted value, e.g., to do sorting, it's
easiest to give it an alias:

    SELECT doc->>'$.name' AS name FROM students ORDER BY name DESC;

We can also extract JSON values, like an entire JSON array:

    SELECT doc->>'$.courses' FROM students;

The JSON path expression can also refer to specific array elements:

    SELECT doc->>'$.courses[0]' FROM students;


## 5. Combining JSON and relational

MySQL has a number of JSON functions we can use to manipulate the
doucment
(https://dev.mysql.com/doc/refman/8.0/en/json-function-reference.html).

Using the extract operator in a JOIN condition, we can match JSON and
tabular data as we please.

All courses all students are signed up for:

    SELECT doc->>'$.name', courses.id, courses.name
    FROM students, courses
    WHERE courses.id MEMBER OF(doc->>'$.courses');

With a little tweak, we can use the `JSON_OBJECT()` function to return
the course as a JSON object instead of a separate course code and name:

    SELECT
      doc->>'$.name',
      JSON_OBJECT('id', courses.id, 'name', courses.name)
    FROM students, courses
    WHERE courses.id MEMBER OF(doc->>'$.courses');

We can use aggregation with `JSON_ARRAYAGG()` to return a single row per
student with a JSON array of all courses:

    SELECT
      students.id AS sid,
      JSON_ARRAYAGG(JSON_OBJECT('id', courses.id, 'name', courses.name))
    FROM students, courses
    WHERE courses.id
    MEMBER OF(doc->>'$.courses')
    GROUP BY sid;

Going one step further, we can insert the aggregated array into the
student document:

    SELECT
      students.id AS sid,
      JSON_INSERT(
        students.doc,
        '$.courses_json',
        JSON_ARRAYAGG(JSON_OBJECT('id', courses.id, 'name', courses.name))
      )
    FROM students, courses
    WHERE courses.id MEMBER OF(doc->>'$.courses')
    GROUP BY sid;


## 6. Transforming JSON into a table

While `JSON_OBJECT()`, `JSON_OBJECTAGG()` and `JSON_ARRAYAGG()` can
construct JSON objects from tabular data, the `JSON_TABLE()` function
(https://dev.mysql.com/doc/refman/8.0/en/json-table-functions.html#function_json-table)
does the opposite. It constructs a table from a JSON document.

E.g., we can extract only one row (although that would be easier with
the `->>` operator):

    SELECT id, json.*
    FROM
      students,
      JSON_TABLE(
        doc,
        '$'
        COLUMNS (
           name VARCHAR(200) PATH '$.name'
        )
      ) AS json;

It's more useful when we unnest arrays:

    SELECT id, json.*
    FROM
      students,
      JSON_TABLE(
        doc,
        '$'
        COLUMNS (
           name VARCHAR(200) PATH '$.name',
           NESTED PATH '$.courses[*]' COLUMNS (
            course_id VARCHAR(10) PATH '$'
          )
        )
      ) AS json;

## 7. Index on a JSON array

Let's organize a lottery among the students:

    UPDATE students
    SET doc = JSON_INSERT(doc, '$.lottery_tickets',
      JSON_ARRAY(1)
    )
    WHERE id = 1;

    UPDATE students
    SET doc = JSON_INSERT(doc, '$.lottery_tickets',
      JSON_ARRAY(2, 22)
    )
    WHERE id = 2;

    UPDATE students
    SET doc = JSON_INSERT(doc, '$.lottery_tickets',
      JSON_ARRAY(3, 33, 333)
    )
    WHERE id = 3;

    UPDATE students
    SET doc = JSON_INSERT(doc, '$.lottery_tickets',
      JSON_ARRAY(4, 44, 444, 4444)
    )
    WHERE id = 4;

    UPDATE students
    SET doc = JSON_INSERT(doc, '$.lottery_tickets',
      JSON_ARRAY(5, 55, 555, 5555, 55555)
    )
    WHERE id = 5;

We draw 22 as the winning ticket and find the lucky winner:

    SELECT id, doc->>'$.name'
    FROM students
    WHERE 22 MEMBER OF (doc->>'$.lottery_tickets');

If we have more than one winning ticket, we can find all winners in one
go:

    SELECT id, doc->>'$.name'
    FROM students
    WHERE JSON_OVERLAPS(doc->>'$.lottery_tickets', CAST('[22, 44]' AS
    JSON));

But this means that we are reading the entire table (table scan):

    EXPLAIN FORMAT=TREE
    SELECT id, doc->>'$.name'
    FROM students
    WHERE JSON_OVERLAPS(doc->>'$.lottery_tickets', CAST('[22, 44]' AS
    JSON));

In order to be more efficient, we create an index:

    CREATE UNIQUE INDEX lottery_idx
    ON students((CAST(doc->>'$.lottery_tickets' AS UNSIGNED INT ARRAY)));

This index will also prevent us from selling negatively numbered tickets
and selling the same ticket twice:

    UPDATE students
    SET doc = JSON_INSERT(doc, '$.lottery_tickets',
      JSON_ARRAY(5, 55, 555, 5555, 55555)
    )
    WHERE id = 7;

    UPDATE students
    SET doc = JSON_INSERT(doc, '$.lottery_tickets',
      JSON_ARRAY(-1)
    )
    WHERE id = 7;

## 8. Geographical data

We're going sightseeing in Trondheim, and we have a list of tings to
visit in the `sights` table:

    SELECT description FROM sights;

We can store the definition of the city center in a session variable:

    SET @city_center = ST_GeomFromText(
        'POLYGON((10.3765 63.4292, 10.3847 63.4277, 10.3902 63.4247, 10.3986 63.4245,
        10.4013 63.4264, 10.4013 63.4283, 10.4072 63.4347, 10.4037 63.4354,
        10.3954 63.4350, 10.3799 63.4314, 10.3765 63.4292))',
        4326,
        'axis-order=long-lat'
    );

We can convert this to GeoJSON and use it in any web map with the
`ST_AsGeoJSON()` function. For just a quick look, we can paste the
definition (the "POLYGON(...)" string) into a simple web display service
(https://arthur-e.github.io/Wicket/sandbox-gmaps3.html). (You may have
to remove some line breaks to make it work.)

So which sights are within the city center?

    SELECT description
    FROM sights
    WHERE ST_Within(pos, @city_center);

How far is it from any sight to any other sight?

    SELECT s1.description, s2.description, ST_Distance(s1.pos, s2.pos)
    FROM sights AS s1, sights AS s2;

How far is it from the Nidaros Cathedral to the Olav Tryggvason
monument?

    WITH dist AS (
      SELECT
        s1.description AS a,
        s2.description AS b,
        ST_Distance(s1.pos, s2.pos) AS d
      FROM sights AS s1, sights AS s2
    )
    SELECT d
    FROM dist
    WHERE a = 'Nidaros Cathedral' AND b = 'Olav Tryggvason Monument';

We can also use general JSON functionality to create more complicated
GeoJSON features (https://geojson.org/) that include the description:

    SELECT
      JSON_OBJECT(
        'type',
        'FeatureCollection',
        'features',
        JSON_ARRAYAGG(
          JSON_INSERT(
            '{"type":"Feature"}',
            '$.geometry',
            ST_AsGeoJSON(pos),
            '$.properties',
            JSON_OBJECT('name', description)
          )
        )
      ) AS json
    FROM sights;

This array can go into a GeoJSON viewer
(http://geojson.io/#map=2/20.0/0.0) or directly into all popular web map
framework.

By putting the description into the `properties` field of the GeoJSON
object, it is handled automatically by all GeoJSON tools.

## The end

For more information, see the MySQL Reference Manual
(https://dev.mysql.com/doc/refman/8.0/en/), the MySQL Server Team Blog
(https://mysqlserverteam.com) or my slides on Slideshare
(https://www.slideshare.net/NorvaldRyeng/presentations).

Thank you for learning more SQL!
