DROP SCHEMA IF EXISTS demo;
CREATE SCHEMA demo;
USE demo;

DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS prerequisites;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS sights;

CREATE TABLE employees (number INTEGER PRIMARY KEY, name VARCHAR(100), manager INTEGER REFERENCES employees (number), dept_id INTEGER, salary INTEGER);
--                ____  Alice _____
--               /                 \
--             Bob                Betty
--          /   |    \            /   \
--   Charlie Cherise Chandler  Chris  Camilla
--                                     /  \
--                                  Dave  Denise
INSERT INTO employees VALUES
(1, 'Alice', NULL, NULL, 1000000),
(2, 'Bob', 1, 30, 900000),
(3, 'Betty', 1, 10, 950000),
(4, 'Charlie', 2, 20, 700000),
(5, 'Cherise', 2, 20, 750000),
(6, 'Chandler', 2, 20, 690000),
(7, 'Chris', 3, 10, 650000),
(8, 'Camilla', 3, 10, 640000),
(9, 'Dave', 8, 10, 500000),
(10, 'Denise', 8, 10, 510000);


CREATE TABLE courses (id VARCHAR(10) PRIMARY KEY, name VARCHAR(200), lecturer INTEGER REFERENCES employees(number));

INSERT INTO courses VALUES ('TDT4100', 'Object-Oriented Programming', 10);
INSERT INTO courses VALUES ('TDT4150', 'Advanced Database Management Systems', 3);
INSERT INTO courses VALUES ('TDT4145', 'Data Modelling, Databases and Database Management Systems', 9);
INSERT INTO courses VALUES ('TDT4120', 'Algorithms and Data Structures', 4);
INSERT INTO courses VALUES ('TMA4140', 'Discrete Mathematics', 5);
INSERT INTO courses VALUES ('TDT4110', 'Information Technology, Introduction', 10);
INSERT INTO courses VALUES ('TDT4125', 'Algorithm Construction', 4);
INSERT INTO courses VALUES ('TDT4205', 'Compiler Construction', 6);
INSERT INTO courses VALUES ('TDT4165', 'Programming Languages', 5);
INSERT INTO courses VALUES ('TDT4117', 'Information Retrieval', 7);
INSERT INTO courses VALUES ('TDT4300', 'Data Warehousing and Data Mining', 7);
INSERT INTO courses VALUES ('TDT4305', 'Big Data Architecture', 3);
INSERT INTO courses VALUES ('TDT4186', 'Operating Systems', 6);
INSERT INTO courses VALUES ('TDT4160', 'Computer Fundamentals', 2);
INSERT INTO courses VALUES ('TDT4255', 'Computer Design', 2);
INSERT INTO courses VALUES ('TDT4225', 'Very Large, Distributed Data Volumes', 8);
INSERT INTO courses VALUES ('TFE4101', 'Electrical Circuits and Digital Design', 2);
INSERT INTO courses VALUES ('TDT4171', 'Artificial Intelligence Methods', 10);
INSERT INTO courses VALUES ('TDT4136', 'Introduction to Artificial Intelligence', 10);
INSERT INTO courses VALUES ('DT8101', 'Highly Concurrent Algorithms', 2);
INSERT INTO courses VALUES ('DT8801', 'PhD Seminar in Database Systems', 3);

CREATE TABLE prerequisites (course_id VARCHAR(10), depends_on VARCHAR(7) REFERENCES courses(id), PRIMARY KEY (course_id, depends_on));

INSERT INTO prerequisites VALUES ('TDT4150', 'TDT4145');
INSERT INTO prerequisites VALUES ('TDT4145', 'TDT4100');
INSERT INTO prerequisites VALUES ('TDT4145', 'TDT4120');
INSERT INTO prerequisites VALUES ('TDT4120', 'TDT4100');
INSERT INTO prerequisites VALUES ('TDT4100', 'TDT4110');
INSERT INTO prerequisites VALUES ('TDT4125', 'TDT4120');
INSERT INTO prerequisites VALUES ('TDT4205', 'TDT4165');
INSERT INTO prerequisites VALUES ('TDT4205', 'TDT4120');
INSERT INTO prerequisites VALUES ('TDT4205', 'TMA4140');
INSERT INTO prerequisites VALUES ('TDT4117', 'TDT4100');
INSERT INTO prerequisites VALUES ('TDT4117', 'TDT4145');
INSERT INTO prerequisites VALUES ('TDT4165', 'TMA4140');
INSERT INTO prerequisites VALUES ('TDT4165', 'TDT4100');
INSERT INTO prerequisites VALUES ('TDT4165', 'TDT4120');
INSERT INTO prerequisites VALUES ('TDT4300', 'TDT4145');
INSERT INTO prerequisites VALUES ('TDT4305', 'TDT4145');
INSERT INTO prerequisites VALUES ('TDT4186', 'TDT4120');
INSERT INTO prerequisites VALUES ('TDT4186', 'TDT4160');
INSERT INTO prerequisites VALUES ('TDT4255', 'TDT4160');
INSERT INTO prerequisites VALUES ('TDT4225', 'TDT4120');
INSERT INTO prerequisites VALUES ('TDT4225', 'TDT4145');
INSERT INTO prerequisites VALUES ('TDT4160', 'TDT4100');
INSERT INTO prerequisites VALUES ('DT8801', 'TDT4145');
INSERT INTO prerequisites VALUES ('TDT4171', 'TDT4136');
INSERT INTO prerequisites VALUES ('DT8101', 'TDT4120');
INSERT INTO prerequisites VALUES ('DT8101', 'TDT4125');
INSERT INTO prerequisites VALUES ('TDT4136', 'TDT4120');
INSERT INTO prerequisites VALUES ('TDT4136', 'TMA4140');

CREATE TABLE students (doc JSON, id INTEGER AS (doc->>'$._id') STORED PRIMARY KEY);

INSERT INTO students(doc) VALUES ('{"_id":1,"name":"Anne","courses":["TDT4100","TDT4120","TDT4110"],"address":["Klostergata 35","7030 Trondheim"],"age":20}');
INSERT INTO students(doc) VALUES ('{"_id":2,"name":"Benny","courses":["TDT4100","TDT4110"],"address":["Rogerts gate 1","7052 Trondheim"],"age":20}');
INSERT INTO students(doc) VALUES ('{"_id":3,"name":"Camilla","courses":["TDT4100"],"address":["Herman Krags vei 1","7050 Trondheim"],"age":24}');
INSERT INTO students(doc) VALUES ('{"_id":4,"name":"David","courses":["TDT4120"],"address":["Rogerts gate 1","7052 Trondheim"],"age":21}');
INSERT INTO students(doc) VALUES ('{"_id":5,"name":"Emma","courses":["TDT4150","TDT4145","DT8801","TDT4225","TDT4300"],"address":["Herman Krags vei 12","7050 Trondheim"],"age":19}');
INSERT INTO students(doc) VALUES ('{"_id":6,"name":"Frank","courses":["TDT4255","TFE4101","TDT4160"],"address":["Herman Krags vei 7","7050 Trondheim"],"age":19}');
INSERT INTO students(doc) VALUES ('{"_id":7,"name":"Gabriella","courses":["TDT4160","TDT4100","TDT4186"],"address":["Herman Krags vei 1","7050 Trondheim"],"age":25}');
INSERT INTO students(doc) VALUES ('{"_id":8,"name":"Hans","courses":["TDT4100","TDT4120","TDT4186"],"address":["Klostergata 35","7030 Trondheim"],"age":30}');
INSERT INTO students(doc) VALUES ('{"_id":9,"name":"Isabel","courses":["TMA4140","TDT8101","TDT4120","TDT4125"],"address":["Herman Krags vei 12","7050 Trondheim"],"age":27}');
INSERT INTO students(doc) VALUES ('{"_id":10,"name":"John","courses":["TDT4100","TDT4120","TMA4140","TDT4110","TDT4125","TDT4186"],"address":["Herman Krags vei 10","7050 Trondheim"],"age":22}');
INSERT INTO students(doc) VALUES ('{"_id":11,"name":"Kirsten","courses":["TDT4100","TDT4120","TMA4140","TDT4110","TDT4125","TDT4186","TDT4136","TDT4171"],"address":["Prestekrageveien 4","7050 Trondheim"],"age":22}');
INSERT INTO students(doc) VALUES ('{"_id":12,"name":"Lars","courses":["TDT4100","TDT4120","TMA4140","TDT4110","TDT4125","TDT4186","TDT4150"],"address":["Rogerts gate 1","7052 Trondheim"],"age":32}');
INSERT INTO students(doc) VALUES ('{"_id":13,"name":"Marie","courses":["TDT4100","TDT4120","TMA4140","TDT4110","TDT4125","TDT4186","TDT4225","TDT4150","TDT4300", "TDT4305"],"address":["Rogerts gate 1","7052 Trondheim"],"age":26}');
INSERT INTO students(doc) VALUES ('{"_id":14,"name":"Niels","courses":["TDT4100","TDT4120","TMA4140","TDT4110","TDT4125","TDT4186","TFE4101","TDT4205","TDT4117"],"address":["Rogerts gate 1","7052 Trondheim"],"age":21}');
INSERT INTO students(doc) VALUES ('{"_id":15,"name":"Olivia","courses":["TDT4100","TDT4120","TMA4140","TDT4110"],"address":["Bregnevegen 60","7050 Trondheim"],"age":21}');
INSERT INTO students(doc) VALUES ('{"_id":16,"name":"Per","courses":["TDT4100","TDT4120","TMA4140","TDT4110","TFE4101"],"address":["Klostergata 35","7030 Trondheim"],"age":21}');
INSERT INTO students(doc) VALUES ('{"_id":17,"name":"Queen","courses":["TDT4100","TDT4120","TMA4140","TDT4110","TFE4101","TDT4160","TDT4255"],"address":["Klostergata 35","7030 Trondheim"],"age":23}');
INSERT INTO students(doc) VALUES ('{"_id":18,"name":"Rolf","courses":["TDT4120"],"address":["Bregnevegen 60","7050 Trondheim"],"age":20}');
INSERT INTO students(doc) VALUES ('{"_id":19,"name":"Simone","courses":["TDT4110"],"address":["Bregnevegen 60","7050 Trondheim"],"age":22}');
INSERT INTO students(doc) VALUES ('{"_id":20,"name":"Truls","courses":["TDT4110","TDT4100"],"address":["Vegamot 1","7049 Trondheim"],"age":22}');
INSERT INTO students(doc) VALUES ('{"_id":21,"name":"Una","courses":["DT8101","DT8801"],"address":["Vegamot 1","7049 Trondheim"],"age":24}');
INSERT INTO students(doc) VALUES ('{"_id":22,"name":"Viktor","courses":["TDT4145","TDT4150","TDT4117","TDT4225","TDT4300","TDT4305"],"address":["Bregnevegen 61","7050 Trondheim"],"age":24}');
INSERT INTO students(doc) VALUES ('{"_id":23,"name":"Wanda","courses":["TDT4110","TDT4100","TDT4120","TMA4140","TDT4186","TDT4205"],"address":["Herman Krags vei 20","7050 Trondheim"],"age":25}');
INSERT INTO students(doc) VALUES ('{"_id":24,"name":"Xzavier","courses":["TDT4171","TDT4136"],"age":20}');
INSERT INTO students(doc) VALUES ('{"_id":25,"name":"Ylva","courses":["TDT4110"],"address":["Vegamot 1","7049 Trondheim"],"age":23}');
INSERT INTO students(doc) VALUES ('{"_id":26,"name":"Zaid","courses":[],"age":25}');
INSERT INTO students(doc) VALUES ('{"_id":27,"name":"Ælin","age":24}');
INSERT INTO students(doc) VALUES ('{"_id":28,"name":"Øyvind","courses":["DT8801"],"age":28}');
INSERT INTO students(doc) VALUES ('{"_id":29,"name":"Åse","courses":["TDT4100","TDT4120","TMA4140","TDT4110","TDT4125","TDT4225","TDT4150","TDT4300", "TDT4305"],"age":22}');

CREATE TABLE sights (
  id INT AUTO_INCREMENT PRIMARY KEY,
  pos POINT SRID 4326 NOT NULL,
  description VARCHAR(200),
  SPATIAL INDEX (pos)
);
INSERT INTO sights (pos, description) VALUES (
  ST_PointFromText('POINT(10.3958 63.4269)', 4326, 'axis-order=long-lat'),
  'Nidaros Cathedral'
);
INSERT INTO sights (pos, description) VALUES (
  ST_GeomFromGeoJSON('{"type":"Point","coordinates":[10.4025,63.4194]}'),
  'Norwegian University of Science and Technology'
);
INSERT INTO sights (pos, description) VALUES (
  ST_PointFromText('POINT(63.4225 10.3948)', 4326),
  'Student Society Building'
);
INSERT INTO sights (pos, description) VALUES (
  ST_GeomFromText('POINT(10.3951 63.4305)', 4326, 'axis-order=long-lat'),
  'Olav Tryggvason Monument'
);
INSERT INTO sights (pos, description) VALUES (
  ST_GeomFromText('POINT(10.4017 63.4282)', 4326, 'axis-order=long-lat'),
  'Old Town Bridge'
);
INSERT INTO sights (pos, description) VALUES (
  ST_GeomFromText('POINT(10.3830 63.4510)', 4326, 'axis-order=long-lat'),
  'Munkholmen'
);
INSERT INTO sights (pos, description) VALUES (
  ST_GeomFromText('POINT(10.3930 63.4339)', 4326, 'axis-order=long-lat'),
  'Boat to Munkholmen'
);
INSERT INTO sights (pos, description) VALUES (
  ST_GeomFromText('POINT(10.3960 63.4261)', 4326, 'axis-order=long-lat'),
  'Archbishop\'s Palace'
);
INSERT INTO sights (pos, description) VALUES (
  ST_GeomFromText('POINT(10.3952 63.4261)', 4326, 'axis-order=long-lat'),
  'Crown Jewels'
);
INSERT INTO sights (pos, description) VALUES (
  ST_GeomFromText('POINT(10.4106 63.4269)', 4326, 'axis-order=long-lat'),
  'Kristiansten Fortress'
);
INSERT INTO sights (pos, description) VALUES (
  ST_GeomFromText('POINT(10.4523 63.4483)', 4326, 'axis-order=long-lat'),
  'Ringve Botanical Gardens'
);
INSERT INTO sights (pos, description) VALUES (
  ST_GeomFromText('POINT(10.4546 63.4474)', 4326, 'axis-order=long-lat'),
  'Ringve Museum'
); 
INSERT INTO sights (pos, description) VALUES (
  ST_GeomFromText('POINT(10.3783 63.4301)', 4326, 'axis-order=long-lat'),
  'Norwegian National Museum of Justice'
); 
INSERT INTO sights (pos, description) VALUES (
  ST_GeomFromText('POINT(10.4320 63.4224)', 4326, 'axis-order=long-lat'),
  'Tyholt Tower'
); 
INSERT INTO sights (pos, description) VALUES (
  ST_GeomFromText('POINT(10.4013 63.4389)', 4326, 'axis-order=long-lat'),
  'Rockheim - Museum of Pop and Rock'
); 
INSERT INTO sights (pos, description) VALUES (
  ST_GeomFromText('POINT(10.4031 63.42803)', 4326, 'axis-order=long-lat'),
  'Bicycle Lift'
);
INSERT INTO sights (pos, description) VALUES (
  ST_GeomFromText('POINT(10.4030 63.4281)', 4326, 'axis-order=long-lat'),
  'Bakklandet'
);
