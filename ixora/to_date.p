/* to_date.p
 * MODULE
        Ценные бумаги
 * DESCRIPTION
        Преобразует дату  формата "26 May 2004" в дату прогресс
          
 * RUN
        
 * CALLER
        VALM_ps.p
 * SCRIPT
        
 * INHERIT
        
 * MENU

 * AUTHOR
        31.05.2004 tsoy
 * CHANGES
        01.09.2004 tsoy Исправил названия месяцев
*/

def input  parameter p-chdate as char.
def output parameter p-ddate as date.

def var v-d  as char.
def var v-m  as char.
def var v-y  as char.

v-d = string(entry (1,p-chdate, " "), "99").

if trim(entry (2,p-chdate, " ")) = "January" then do:
   v-m =  "01" .
end.

if trim(entry (2,p-chdate, " ")) = "February" then do:
   v-m =  "02" .
end.

if trim(entry (2,p-chdate, " ")) = "March" then do:
   v-m =  "03" .
end.


if trim(entry (2,p-chdate, " ")) = "April" then do:
   v-m =  "04" .
end.

if trim(entry (2,p-chdate, " ")) = "May" then do:
   v-m =  "05" .
end.

if trim(entry (2,p-chdate, " ")) = "June" then do:
   v-m = "06" .
end.

if trim(entry (2,p-chdate, " ")) = "July" then do:
   v-m =  "07" .
end.

if trim(entry (2,p-chdate, " ")) = "August" then do:
   v-m =  "08" .
end.

if trim(entry (2,p-chdate, " ")) = "September" then do:
   v-m =  "09" .
end.

if trim(entry (2,p-chdate, " ")) = "November" then do:
   v-m =  "10" .
end.

if trim(entry (2,p-chdate, " ")) = "October" then do:
   v-m =  "11" .
end.

if trim(entry (2,p-chdate, " ")) = "December" then do:
   v-m =  "12" .
end.

v-y = entry (3,p-chdate, " ").

p-ddate =  date(integer(v-m), integer(v-d), integer(v-y)) .  

