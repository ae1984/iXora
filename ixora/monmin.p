/* monmin.p
 * MODULE 
        Монитор для казначейства.
 * DESCRIPTION 
        Консолидированный отчет по минимальным резервным требованиям для монитора.
 * RUN
 
 * CALLER
 
 * SCRIPT
 
 * INHERIT

 * MENU 
        
 * AUTHOR  
        03/08/2006 Ten
 * CHANGES
        05/09/2006 tsoy переделал под прагму

*/

def shared var g-today as date.
def shared var v-sum as dec.


function is-working-day returns logical (input dt as date).

find txb.cls where txb.cls.whn = dt no-lock no-error.
if available txb.cls and txb.cls.del then return true. /* если есть запись в cls, то все ясно */

find txb.hol where txb.hol.hol eq dt no-lock no-error. /* праздники */
if available txb.hol then return false.

def var v-weekbeg as int init 2.
def var v-weekend as int init 6.

/* если текущая неделя - то начало и конец рабочей недели из справочника, если нет - то с понедельника по пятницу */

if dt >= g-today - weekday(g-today) + 1 and dt <= g-today + 7 - weekday(g-today) then do:
  find txb.sysc where txb.sysc.sysc = "WKEND" no-lock no-error.
  if available txb.sysc then v-weekend = txb.sysc.inval.
  find txb.sysc where sysc.sysc = "WKSTRT" no-lock no-error.
  if available txb.sysc then v-weekbeg = txb.sysc.inval.
end.

if weekday(dt) >= v-weekbeg and weekday(dt) <= v-weekend then return true.
else return false.

end function.


def var v-day as date.
v-day = g-today  .


def var v-sum1 as dec.
def var v-sum2 as dec.
def var v-sum3 as dec.
def buffer bhol for hol.
def var v-list3 as char init "20141,20341,20361,20381,20641,20661,20671,20681,22011,22021,22031,22041,22051,22061,22071,22081,22091,22101,22111,22121,22131,22151,22171,22191,22211,22231,22241,22251,22261,22271,22281,22301,22321,22371,22401,22551,25521,27011,27031,27061,27171,27181,27191,27201,27211,27231,27251,27261,27311,27411,27421,27431,27451,27461,27471,27481,27491,27551,28551,28911,28921,28931,28941,28951,29991".
def var v-list1 as char init "20122,20132,20142,20162,20222,20232,20242,20442,20462,20482,20522,20542,20562,20572,20582,20642,20662,20672,20682,21122,21132,21222,21232,21242,21252,21272,21302,21312,21332,21352,21382,22032,22042,22052,22062,22072,22092,22102,22112,22122,22132,22152,22172,22192,22212,22222,22232,22242,22252,22262,22272,22282,22302,22322,22372,22402,22552,25512,25522,27012,27022,27042,27052,27062,27082,27112,27122,27132,27142,27172,27182,27192,27202,27212,27222,27232,27252,27262,27312,27412,27422,27432,27452,27462,27472,27482,27492,27552,28552,22082,28912,28922,28932,28942,28952,28992 ".
def var v-list2 as char init "2301,2303,2401,2402,2406,2451,2730,2740,2744,2757".


def var rez as char no-undo.
def var priz as char no-undo.
def var num as integer no-undo.
def var i1 as integer no-undo.

v-day = v-day - 2.

if is-working-day(v-day) = false then 

do while is-working-day(v-day) = false:
   v-day = v-day - 1.
end.

v-sum1 = 0.
v-sum2 = 0.
v-sum3 = 0.
def var i as int.

find first txb.sthead where txb.sthead.rptfrom = v-day and txb.sthead.rptto = v-day and txb.sthead.rptform = '7pn' no-lock no-error.
if avail txb.sthead then do:
   for each txb.stdata where txb.stdata.referid = txb.sthead.referid and  txb.stdata.x1 >= '0000009' no-lock.

       if lookup(substring(trim(txb.stdata.fun),1,5), v-list3) <> 0 then do:
          i = i + 1.
          i1 = index(txb.stdata.fun,',').
          if i1 > 0  and substr(trim(txb.stdata.fun),1,1) <> '0' then v-sum1 = v-sum1 + decimal(substr(trim(txb.stdata.fun),i1 + 1)).
       end.
       else 
       if lookup(substring(trim(txb.stdata.fun),1,5), v-list1) <> 0 then do:
          i1 = index(txb.stdata.fun,',').
          if i1 > 0  and substr(trim(txb.stdata.fun),1,1) <> '0' then v-sum2 = v-sum2 + decimal(substr(trim(txb.stdata.fun),i1 + 1)).
       end.
       else 
       if lookup(substring(trim(txb.stdata.fun),1,4), v-list2) <> 0 then do:
          i1 = index(txb.stdata.fun,',').
          if i1 > 0  and substr(trim(txb.stdata.fun),1,1) <> '0' then v-sum3 = v-sum3 + decimal(substr(trim(txb.stdata.fun),i1 + 1)).
       end.

   end.
end.

v-sum1 = v-sum1 * 0.06.
v-sum2 = (v-sum2 + v-sum3) * 0.08.

v-sum = v-sum + v-sum1 + v-sum2.
