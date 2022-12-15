/*
Some of the queires and views I wrote that I found interesting and important 
which highlight some of the key things the databse can enable
I also have some queries in routeInArea.py
*/

----------------------------------------------------------------------------------------------------------
-- QUERY SET 1 (quick and easy queries that answer some interesting question I've always had about mtp) --
----------------------------------------------------------------------------------------------------------

-- gets user with the highest number of ticks
select * from 
(select user_id, count(ticks.id) as c 
    from ticks join users on users.id=ticks.user_id group by user_id) as a 
join users on a.user_id = users.id order by c desc;

-- route with the most views
select * from routes where views = (select max(views) from routes);

-- route with the most ticks - I didnt re join it with routes becuase the beauty of this database is the 
-- primary keys can be pasted directly into a url bar and you get the whole page of that route with pretty
-- pcitures and all that stuff - go to https://www.mountainproject.com/route/{*route id here*}
select route_id, count(ticks.id) as c 
from ticks join routes on ticks.route_id = routes.id 
group by route_id order by c desc;

-- route on most todo lists
select route_id, count(user_id) as c from todos group by route_id order by c desc;

-- my ticks
-- can easilly get all the routes or areas withing these routes like below
select * from ticks where user_id = (select id from users where display_name = 'Cody Bryan');
select * from routes where id in (select route_id from ticks where user_id = (select id from users where display_name = 'Cody Bryan'));

-- user that is ranked #1 by points - can look it up on mtp - correct 
select * from users where points = (select max(points) from users);

-- first areas on mountain project
select * from areas where shared_on = (select min(shared_on) from areas);

-- first users on mtp
select * from users where start_date = (select min(start_date) from users);

-- first accents of henry barber 
select * from routes where lower(first_accent) like '%henry barber%';

-- get a count of 1 and ___ users mention beer as an interest if they included an interest 
-- can also change the keyword to whatever, like mountain biking or reading
with b as (
    select count(*) as beery
    from users
    where lower(other_interests) like '%beer%'),
a as (
    select count(*) as adds
    from users
    where other_interests is not null)
select a.adds / b.beery from a, b;

-------------------------------------------------
-- QUERY SET 2 (views used in routesInArea.py) --
-------------------------------------------------

-- basically just gets average star ratings, count of star ratings, and sum of star ratings fora all climbs 
create view avg_ratings as
select route_id, cast(count(star_rating) as float) as count, cast(sum(star_rating) as float) as sum, (cast(sum(star_rating) as float) / cast(count(star_rating) as float)) as avg 
from star_ratings group by route_id;

-- the above but with the area id 
create view avg_ratings_with_area as
select route_id, count, sum, avg, area_id from avg_ratings join routes on avg_ratings.route_id = routes.id;

-- the above but congergated by area, displays the sum of avgs and num of routes and avg
create view avg_route_ratings_per_area as
select area_id, sum(avg) as sum_avg, count(routes_areas.route_id) as num_routes, sum(avg)/ count(avg) as avg_route_grade 
from (select routes.id as route_id, areas.id as area_id from routes join areas on routes.area_id = areas.id) as routes_areas join avg_ratings on routes_areas.route_id = avg_ratings.route_id 
group by area_id;

-- this just gets the average ratings for all of mtp as a check to make sure above works - it does
with avgs as (
select route_id, avg
    (star_rating) as avg from star_ratings group by route_id)
select avg(avg) from avgs;

----------------------------------------------------------------
-- QUERY SET 3 (advanced filtering and other stuff like that) --
----------------------------------------------------------------

-- 1 --
-- this query gets the boldest climbs ordered
-- how it calculates this doing a weighted calculation of climbers who have climbed X rated climbs leading or soling
-- weighted based on how diffcult the climb was, ordered by sum of this, but also dislays how many X climbs they've done

with scaries as
    (select *
     from ticks
         natural join
         (select id as route_id, difficulty_rating, numeric, danger_rating, length, name
          from routes join difficulty_numbers on difficulty_numbers.yds_grade = routes.difficulty_rating
          where danger_rating = 'X') as a where style = 'Lead' or style = 'Solo')
select *
-- this is a group by of scaries that sums up numeric (which is the numeric version of the grade) and the count of the climbs
from (select user_id, sum(numeric) as sum, count(numeric) as count
      from scaries group by user_id) as a
    -- join with users and order by sum descending to get "boldest" climber first 
    join users on (a.user_id = users.id) order by sum desc;

-- END 1 --

-- 2 --
-- this query organizes the areas based on the number number of sport routes that are 5.7 or easier, 
-- rated G/PG, and dont have any ticks that mention scary keywords

-- this view is gets routes rated G/PG that doesn't mention scary keywords
create view safe_routes as
-- routes that mention scary keywords - interesting query in itself as it shows the routes most people say are scary
with scaries as
    (select route_id, count(id) as c
     from (select * from ticks
     where lower(notes) like '%scary%' or lower(notes) like '%chossy%' or lower(notes) like '%dangerous%' or lower(notes) like '%freaky%') as a
     group by route_id order by c desc
    ),
-- routes that are G/PG
saferoutes as (select * from routes where danger_rating = 'G/PG')
-- set subtraction
select * from (select id from saferoutes) as a except (select route_id from scaries);
-- routes that have "sport" as a type, and don't have any other types, and are rated 5.7 or under
with routes as
    (select *
     from routes join difficulty_numbers
     on routes.difficulty_rating = difficulty_numbers.yds_grade
     where numeric <= (select numeric from difficulty_numbers where yds_grade = '5.7')
     and (select count(*) from route_types where route_id = routes.id) = 1
     and (select count(*) from route_types where route_id = routes.id and type = 'Sport') = 1
    )
-- join the 5.7 and less sport routes with the safe routes and order by the count descending
select *
from
    (select area_id, count(routes.id) as count
        from (routes join safe_routes on routes.id = safe_routes.id) group by area_id)
    as a
    join areas
    on areas.id = area_id
    order by count desc;

-- END 2 -- 


-- 3 -- 
-- this gets highest star rated routes based on admins (weighted on how many routes they admin)
-- and only ones who started before 2015 
create view old_admins_fav_routes as
-- gets admins who started before 2015 and how many routes they are admins of by way of areas
with old_admins as
    (select *
     from users join
         -- number of routes user is admin of
         (select user_id, count(id) as c
          from admins_areas join routes on admins_areas.area_id = routes.area_id
          group by user_id order by c desc) as admins
     on users.id = admins.user_id where start_date < '2015-01-01')
-- gets the all the routes that these admins have rated, and counts the weighted sum based on how many routes
-- they admin 
select *
from (select route_id, sum(c*star_rating) as sum_rating
      from old_admins join star_ratings on star_ratings.user_id = old_admins.id
      group by route_id order by sum_rating desc) as rates
    join routes on rates.route_id = routes.id;
-- selects this, just the area
select * from old_admins_fav_routes;
-- this congerates it to areas, to get the count and sum of old admins rated routes in that area and orders 
-- it, finds old admins favorite areas
with weighted_areas as
    (select area_id, count(route_id) as count, sum(sum_rating) as sum
     from old_admins_fav_routes group by area_id order by sum desc)
select * from weighted_areas join areas on weighted_areas.area_id = areas.id;

-- END 3 -- 


-- 4 --
-- this orders all user by how they rate climbs. It gets all diffciulty ratings, and groups
-- it by users and compares that with the actual grade of routes, to get the sum of the "numeric grades"
-- that they've rated (rate_sum), the sum of the actual grades of the climbs (climb_sum), then finds the difference
-- the person with the highest differnce could be cnsidered the biggest sandbagger, as they consistantly rate climbs as
-- easier than they really are 
with a as 
    (select climbs.difficulty_rating as climb_grade, climbs.danger_rating as climb_danger, climbs.numeric climb_number, userrates.id as user_id, userrates.display_name, userrates.start_date, userrates.age, userrates.other_interests, points, userrates.difficulty_rating as rate_grade, userrates.danger_rating as rate_danger, userrates.numeric as rate_number 
     from (select * from routes join difficulty_numbers on routes.difficulty_rating = difficulty_numbers.yds_grade) as climbs join
    (select * from users join (select * from difficulty_ratings join difficulty_numbers on difficulty_ratings.difficulty_rating = difficulty_numbers.yds_grade) as dr
    on users.id = dr.user_id) as userrates on userrates.route_id = climbs.id)
select * from users join (select user_id, sum(climb_number) as climb_sum, sum(rate_number) as rate_sum, sum(climb_number) - sum(rate_number) as diff from a group by user_id) as a on users.id = a.user_id order by diff desc;

-- END 4 --
