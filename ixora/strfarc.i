/* strfarc.i
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
*/

/* strfarc.i from stmarc.i  Optimal Archive DataBase Choice 
             Start 13/04/1998    End 14/04/1999    */

def var v-weekend as integer.
def var v-weekstrt as integer.
def var min_date as date format "99/99/9999".
def var max_date like min_date.
def var lastday like min_date.
def var myday like min_date.
def var days as integer.
def var numbase as integer.
def var datefrom as date format "99/99/9999". 
def var dateto as date format "99/99/9999". 

def temp-table BaseList field d_from as date format "99/99/9999"
                        field d_to   as date format "99/99/9999"
                        field path   as char format "X(40)"
                        field conprm as char format "X(20)".

/*    1. Archive Map Preparation --> BaseList   */

min_date = dat1.
max_date = min(dat2,g-today - 1).

find first arcmap where arcmap.path eq pdbname("bank") 
and arcmap.d_from ne ? no-lock no-error.

if not available arcmap then do:
if not g-batch then message 
"Нет описания рабочей базы в таблице ARCMAP " skip
"Режим работы с архивом игнорируется !" view-as alert-box title "ОШИБКА ARCMAP".
end.

if available arcmap then do: 

  if arcmap.d_from ge start_dt then do: 
  start_dt = arcmap.d_from.

  end.   /* choose max start_dt from arcmap */ 

  else do:  /* first prostm date > arcmap.date-from due to holidays */
  find sysc where sysc.sysc eq "WKEND" no-lock no-error.
  if available sysc then v-weekend = sysc.inval.
                    else v-weekend = 6.
  find sysc where sysc.sysc eq "WKSTRT" no-lock no-error.
  if available sysc then v-weekstrt = sysc.inval.
                    else v-weekstrt = 2.

    do while (weekday(start_dt - 1) gt v-weekend 
           or weekday(start_dt - 1) lt v-weekstrt
           or can-find(hol where hol.hol eq start_dt - 1))
          and start_dt gt arcmap.d_from:
    start_dt = start_dt - 1.
    end.  /* do while */ 
    end.  /* if first prostm date > arcmap date-from */ 
end.   /* available arcmap  */

if start_dt > min_date then do:

for each BaseList: delete BaseList. end.
days = 0. lastday = min_date.
i = 0.

MAP-LOOP:
do while lastday <= min(max_date,start_dt - 1):
i = i + 1. 

  if i gt 20 then do:
  message "Нельзя собрать данные из архивных баз" skip
  "без промежутков во времени" 
  view-as alert-box error title " ОШИБКА ОПИСАНИЯ СПИСКА АРХИВНЫХ БАЗ ".
  return "1".
  end.

LIST-LOOP: 
DO ON ERROR UNDO,LEAVE:

days = 0.   /* for optimal choice of Archive Base */ 
create BaseList.

for each arcmap where arcmap.d_from <= lastday 
and arcmap.path ne pdbname("bank") no-lock:
numbase = numbase + 1.        
        if arcmap.d_to >= min(start_dt - 1,max_date) then do:   /* MAP completed */ 
        days = max_date - min_date + 1.
        BaseList.d_from = lastday.
        BaseList.d_to   = arcmap.d_to.
        if arcmap.d_to ge start_dt then BaseList.d_to = start_dt - 1.
        if arcmap.d_to ge max_date then BaseList.d_to = max_date.
        baseList.path   = arcmap.path.
        BaseList.conprm  = arcmap.conprm.
        lastday = max_date.
        leave MAP-LOOP.
        end.
        
        if (arcmap.d_to - lastday + 1) gt days then do:  /* MAP OPTIMIZING */
        BaseList.d_from = arcmap.d_from.   /* lastday.  */
        BaseList.d_to   = arcmap.d_to.
        BaseList.path   = arcmap.path.
        BaseList.conprm = arcmap.conprm.
        days = arcmap.d_to - lastday + 1.
        end.    /* if */   

        /*else undo,leave LIST-LOOP.*/

end.    /* for each arcmap  */

  if BaseList.d_to ne ? then do: 
  lastday = BaseList.d_to + 1. days = 0.
  if BaseList.d_to ge start_dt then BaseList.d_to = start_dt - 1.
  end. 

END.
end.    /* MAP-LOOP do while lastday */

myday = min_date.
for each BaseList break by BaseList.d_to:
if BaseList.d_from lt myday then BaseList.d_from = myday.
if BaseList.d_to >= start_dt then BaseList.d_to = start_dt - 1.
myday = BaseList.d_to + 1.
end.

if lastday < start_dt and lastday < max_date then do:
   if not g-batch then do:
   message "В списке архивных баз есть интервал" skip 
   "с " lastday " до первой даты рабочей базы " start_dt  
   view-as alert-box error title " В СПИСКЕ АРХИВНЫХ БАЗ ПРОПУЩЕН ИНТЕРВАЛ ВРЕМЕНИ ".
   end.
 return "1".
end.


lastday = min_date.
for each BaseList break by BaseList.d_to: 
if BaseList.d_to >= g-today then BaseList.d_to = g-today - 1.
 if BaseList.d_from gt lastday then do:
   if not g-batch then do:
   message "В списке архивных баз пропущен интервал времени" skip 
   "с " lastday " по " BaseList.d_from  
   view-as alert-box error title " В СПИСКЕ АРХИВНЫХ БАЗ ПРОПУЩЕН ИНТЕРВАЛ ВРЕМЕНИ ".
   end.
 return "1".
 end.
lastday = BaseList.d_to + 1.
end.
end.  /* if archive base needed  */

for each BaseList where BaseList.d_from eq ? 
                     or BaseList.d_to   eq ?
                     or BaseList.path   eq ?
                     or BaseList.path   eq "":
delete BaseList.
end.

/* 2. Archive Processing */

for each BaseList 
where BaseList.path ne pdbname("bank") break by BaseList.d_to:           
datefrom = max(BaseList.d_from, dat1). 
dateto = min(BaseList.d_to,start_dt - 1).  

connect value(BaseList.path) 
value(trim("-ld arcbase -d dmy " + BaseList.conprm)) no-error.
if not connected("arcbase") then 
connect value(BaseList.path) 
value(trim("-ld arcbase -d dmy -1 " + BaseList.conprm)) no-error.         

  if not connected ("arcbase") then do:
  message "Не могу подключиться к архивной базе " BaseList.path
  skip "Параметры связи: " skip 
  BaseList.conprm skip 
  "База данных: " BaseList.path 
  view-as alert-box error title "Отказ в связи".
  return "1".
  end. 

  message "РАБОТА С АРХИВНОЙ БАЗОЙ ДАННЫХ " BaseList.path 
  BaseList.d_from " - " BaseList.d_to ":" 
  if connected("arcbase") then "Ok!" else "Fail...".
  pause 2. hide message no-pause.
  if connected("arcbase") then do:
    FOR EACH C-AAA WHERE C-AAA.CIF EQ S-CIF AND (C-AAA.AAA EQ S-HACC OR
    S-HACC EQ "" OR S-HACC EQ "ALL") NO-LOCK:
    IN_ACCOUNT = C-AAA.AAA.
    run fakturar(input datefrom, input dateto, input in_account, input "chg").
    END.  
  end. 
if connected("arcbase") and pdbname("arcbase") ne pdbname("bank") then disconnect arcbase no-error. 
end.    /* .. for each BaseList (arcmap    .. */
         

 
