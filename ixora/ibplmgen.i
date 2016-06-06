/* ibplmgen.i
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
 * BASES
        BANK COMM IB
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

/*     Internet Banking
    Teller menu
    Generic menu wrapper. 
    Connect database, set common shared variables.         
    Parameter - name of procedure to run
    

    Alexey Truhan (sweer@rkb.lv),
    May 1998
*/

define variable noconn as int.
define variable IBhost as char.

noconn = 0.
if not connected("ib") then do:
  
  find sysc where sysc.sysc = "IBHOST" no-lock.  IBhost = sysc.chval.
   
  connect value(IBhost) .
/*  -U platon -P ckr14 . */
  noconn = 1.
end.

/* ******     V A R I A B L E S      ***** */

define shared variable g-ofc as char. 
define new shared variable ib-brnch as char. 

find sysc where sysc.sysc="OURBNK" no-lock. 
ib-brnch = sysc.chval. 

run {1}.

if noconn = 1 then do: 
  disconnect ib .
end.
