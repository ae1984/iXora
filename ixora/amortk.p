/* amortk.p
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
*/

/* amortk.p */

{mainhead.i}

define new shared variable oneLs as integer initial 1.
define new shared variable ddate as date.
define new shared variable ddatm as integer format "99".
define new shared variable ddaty as integer format "9999".
define new shared variable v-gl like ast.gl.
define new shared variable v-fag like ast.fag.
define new shared variable v-ast like ast.ast format "x(8)".
define new shared variable kor-gl like gl.gl.
define variable v-ldd as char format "x(7)".
define new shared variable v-lddn as char format "x(7)".
define new shared variable was as logical.
define variable tran as logical.
def var dd-1 as char format "999999".
def var dd-a as char format "999999".
def new shared temp-table aast  field ast like ast.ast
                     index ast ast.     

v-ast="".

form
 skip(1)
 "             ПО  КАРТОЧКЕ           :"  v-ast skip
 "        или                         :" skip
 "             ПО СЧЕТУ               :" v-gl skip(1)
 " ПРЕДЫДУЩИЙ РАСЧЕТ АМОРИЗАЦИИ  ЗА   :" v-ldd skip(1)   
 "         РАСЧИТАТЬ АМОРТИЗАЦИЮ ЗА   :" ddaty ".г." ddatm ".мес." skip(3)
  with frame amor row 5 overlay centered no-label
       title " НАЧИСЛЕНИЕ АМОРТИЗАЦИИ   ".
  update v-ast  with frame amor.
     if v-ast<>"" then do:
         find ast where ast.ast = v-ast no-lock no-error. 
     end.          
     else do:
      update v-gl  with frame amor.
      find first ast where ast.gl = v-gl no-lock no-error. 
      if not avail ast then do:  
         Message " Карточек с таким счетом нет". Pause 4.
         undo, retry.
      end.
      find first ast where ast.gl = v-gl and ast.ldd ne ? 
      and  ast.dam[1] - ast.cam[1] >  ast.cam[3] - ast.dam[3] 
      no-lock no-error. 
     end.   
   if avail ast then do: v-gl= ast.gl. 
       v-ldd=string(month(ast.ldd),"z9.") + string(year(ast.ldd),"9999"). 
        displ v-gl v-ldd with frame amor.
   end.

  ddatm = month (g-today).  
  ddaty = year (g-today). 
  update ddaty with frame amor.
  update ddatm with frame amor.
   if ddaty = ? or ddatm = ?
     or ( ddaty > year (g-today)) or ( ddaty = year (g-today)
     and ddatm > month (g-today))
   then do:
     Message " Проверьте дату!!! ". Pause 4.
     undo,retry.   
   end.  
ddate = date(ddatm,28,ddaty).

if ddatm=1  then dd-1= string(ddaty - 1,"9999") + "12".
            else dd-1= string(ddaty,"9999") + string(ddatm - 1,"99").

v-lddn=string(ddatm,"z9.") + string(ddaty,"9999"). 

For each ast where (if v-ast<> "" then ast.ast=v-ast else ast.ast>"0") and  
   ast.gl = v-gl and ast.noy gt 0  

   and ast.dam[1] - ast.cam[1] >  ast.cam[3] - ast.dam[3] no-lock:
   
 if ast.ldd ne ? then dd-a=string(year(ast.ldd),"9999") +
                           string(month (ast.ldd),"99").
                 else dd-a=string(year(ast.rdt),"9999") +
                           string(month (ast.rdt),"99").
                         
  if dd-a < dd-1 then do:
    message "Для карт." + ast.ast + "не НАЧИСЛЕНА АМОРТИЗАЦИЯ за пред.месяц (посл.расчет " +
    string(ast.ldd) + ")".
         pause . return.
  end. 
/****
  if ast.ldd ne ? and (( year (ast.ldd) = ddaty and 
         ddatm - month (ast.ldd) > 1) or 
        ( ddaty - year (ast.ldd) = 1 and month (ast.ldd) <= 12)) 
   then do:
    message "Для карт." + ast.ast + "не НАЧИСЛЕНА АМОРТИЗАЦИЯ за пред.месяц (посл.расчет " +
    string(ast.ldd) + ")".
         pause . return.
  end. 

/*
   ifast.ldd ne ? and (( year (ast.ldd) = ddaty and 
         ddatm < month (ast.ldd) ) or 
        ddaty - year (ast.ldd) < 0) 
    then do:   

        message "Для карт." + ast.ast + "АМОРТИЗАЦИЯ уже НАЧИСЛЕНА за " +
        string(ast.ldd) + ")".
        pause . return.
    end.
*/ 

  if ast.ldd = ? and (( year (ast.rdt) = ddaty and 
     ddatm - month (ast.rdt) > 1)  or 
       ( year (ast.rdt) <  ddaty and month (ast.rdt) <> 12 ))
   then do:      
      message "Для карт." + ast.ast + " не НАЧИСЛЕНА АМОРТИЗАЦИЯ за пред.мес. ". 
         pause . return.
  end. 

  if ast.ldd = ? and ((year (ast.rdt) = ddaty and 
     ddatm - month (ast.rdt) < 0) or  ddaty < year(ast.rdt))
   then do:
 
        message "Карточка " + ast.ast + " принята " + string(ast.rdt) .
         pause . next.

  end. 

****/
end.    
    run amras.  
hide all no-pause.
if was then do:
   message "Транзакции по начислению амортизации выполнить ? (да/нет) " update tran format "да/нет".


    if tran then run amtran.
    hide all.   
end.


