CREATE OR REPLACE VIEW Match_Recognize_V AS
select personid 
,      to_char(login_time,'DD HH24:MI') block_start_login_time 
from logins 
match_recognize ( 
  partition by personid -- regard every person independently 
  order by login_time 
  measures  
         match_number()     mn, 
         block_start.login_time    as login_time   
  one row per match -- every block is represented by a single record  
  pattern (block_start same_block*) -- collect a log in record and all subsequent rows in same two hour block; once a row is assigned to a block it cannot start or be part of another block   
  define 
       same_block as (login_time <= block_start.login_time + interval '2' hour)  -- a login row is in the same block with its subsequent rows within 2 hours 
) 
/
CREATE OR REPLACE VIEW Model_V AS
select personid 
,      to_char(login_time,'DD HH24:MI')  block_start_login_time 
from   ( select * 
         from   logins 
         model 
         partition by (personid) 
         dimension by (row_number() over ( partition by personid 
                                           order by login_time 
                                         ) as rn    
                      ) 
         measures ( login_time 
                  , 'N' blockstarter_yn 
                  ) 
         rules ( blockstarter_yn[any] -- assign a value to the cell count_yn for all login_times  
                 order by rn   -- go through the cells ordered by login time, starting with the earliest 
                             = case 
                               when cv(rn) = 1  
                               then 'Y'  -- first login by a person 
                               when login_time[cv()] > -- when the login time in a cell is more than two hours later later than the last (or max)  
                                                       -- login time in an earlier cell (for a row that was identified as a block starter   
                                    max( case when blockstarter_yn = 'Y' 
                                              then login_time 
                                         end 
                                       ) [rn < cv()]  
                                       + interval '2' hour     -- when the login_time  
                               then 'Y' 
                               else 'N' 
                               end  
               ) 
       ) 
where blockstarter_yn = 'Y'
/
CREATE OR REPLACE VIEW Recursive_SQF_V AS
with recurs (personid, lvl, login_time, last_time, rn) as  
( select personid 
  ,      1 lvl 
  ,      min(login_time) 
  ,      min(login_time) + interval '2' hour  
  ,      1 
  from   logins 
  group  
  by     personid  -- return a single login record for each person - representing the earliest login and indicating the end of that first login block 
  union all 
  select r.personid 
  ,      r.lvl + 1 
  ,      l.login_time 
  ,      l.login_time + interval '2' hour 
  ,      row_number() over ( partition by r.personid 
                             order by     l.login_time 
                           ) rn  -- determine rank of login record among its siblings by login time; we are really only interested in the earliest of these, the ones that start a new block 
  from  recurs r 
        join 
        logins l 
        on  -- find all successor records for the new rows produced by the previous iteration (logins for the same person that were later than the end of the two hour block started by the predecessor)  
        ( r.rn =1   -- only start recursion from block starters - those "parent" records with rn = 1 
          and 
          l.personid = r.personid      
          and  
          l.login_time > r.last_time  -- login record has to be outside the block started by its predecessor or parent record 
        )   
) 
select personid 
,      to_char(login_time, 'DD HH24:MI') block_start_login_time 
,      lvl as iteration 
from   recurs 
where  rn = 1  -- only retain the first row in the block 
/
CREATE OR REPLACE VIEW Analytics_V AS
WITH earliest_logins AS (
	SELECT personid,
       	   login_time,
           First_Value(login_time) IGNORE NULLS 
       		   OVER (PARTITION BY personid ORDER BY login_time 
       		   RANGE BETWEEN INTERVAL '2' HOUR PRECEDING AND UNBOUNDED FOLLOWING) AS earliest_login 
  	  FROM logins
), block_starters AS (
	SELECT personid,
           login_time,
           login_time block_starttime,
           login_time + INTERVAL '2' HOUR block_endtime 
      FROM earliest_logins
     WHERE login_time = earliest_login
), duplicate_1ogins AS (
    SELECT bs.personid,
           bs.login_time
      FROM block_starters bs
      JOIN logins l
        ON l.personid = bs.personid 
       AND l.login_time BETWEEN bs.block_starttime AND bs.block_endtime
)
SELECT l.personid,
       to_char(l.login_time, 'DD HH24:MI') block_start_login_time
  FROM logins l
  LEFT JOIN duplicate_1ogins dl
    ON l.personid = dl.personid 
   AND l.login_time = dl.login_time
 WHERE dl.personid IS NULL
 UNION
SELECT bs.personid,
       to_char(bs.block_starttime, 'DD HH24:MI')
  FROM block_starters bs
/