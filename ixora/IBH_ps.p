/* IBH_ps.p
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
        07.06.2004  tsoy  Добавил автоматическое закрытие сессий run ibh_clr_ip. 
        01.09.2006  tsoy  закоментарил вызов  ibh_clr_ip, блокируются сессии 

*/


{Hvars_ps.i "NEW" }

find sysc "WKEND" no-lock no-error.
if available sysc then v-weekend = sysc.inval. else v-weekend = 6.

find sysc "WKSTRT" no-lock no-error.
if available sysc then v-weekbeg = sysc.inval. else v-weekbeg = 2.

{global.i }
{lgps.i }
{rmz.f}
def var ibhost as cha .
def new shared var clearing as char.

def var v-txbtime as integer.

v-text = "" .


  /*
    m_pid = "H10".
    u_pid = "HOME".                    
  */

find sysc where sysc.sysc = "IBHOST" no-lock no-error .
if not avail sysc or sysc.chval = "" then do :
 v-text = " Нет IBHOST записи в sysc файле ! ".
 run lgps .
 return .
end .
ibhost = sysc.chval .

find sysc where sysc.sysc = "clcen" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 v-text = " Нет CLGEN записи в sysc файле ! ".
 run lgps.
 return .
end.
clecod = sysc.chval.

find sysc where sysc.sysc = 'LBNSTR' no-lock  no-error.
if not avail sysc then
  do:
       v-text  =  " Нет LBNSTR записи в sysc файле ! ".
       run lgps .
       return.
 end.
 lbnstr = sysc.chval .


find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 v-text = " Нет OURBNK записи в sysc файле ! ".
 run lgps.
 return .
end.
ourbank = sysc.chval.

if clecod ne ourbank then brnch = yes.

find first bankl where bankl.bank = ourbank no-lock .

find sysc where sysc.sysc = "PS_ERR" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 v-text = " Нет PS_ERR записи в sysc файле ! ".
 run lgps.
 return .
end.
 v-err = sysc.chval.


find sysc where sysc.sysc = "TXBTIM" no-lock no-error .
if not avail sysc then do:
 v-text = " Нет TXBTIM записи в sysc файле ! ".
 run lgps.
 return .
end.
v-txbtime = sysc.inval.


v-text = "Прямой доступ к INTERNET базе данных"  . run lgps . 
 if not connected("ib") then 
  connect value(ibhost) no-error .

if not connected("ib") 
then do:
 v-text = " INTERNET HOST не отвечает ." .  run lgps .           
 return .
end.

/*
run ibh_clr_ip.
*/

run IBHtrz_ps(v-txbtime).

if connected("ib") then
 disconnect ib .


