/* usrrights.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Процедура проверяет пользователя на наличие у него пакета прав, необходимых для проведения проводок в кредитном модуле.
 * RUN
        usrrights 
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        
 * AUTHOR
        13.07.2006 Natalya D.
 * CHANGES
        26.07.2006 Natalya D. - пакеты доступа берутся из sysc.        
*/

{global.i}
def var v-paket as char no-undo.
def var v-pak as char no-undo.
def var i as int no-undo.
def var v-trans as char init '0' no-undo.
find sysc where sysc = 'paket' no-lock no-error.
if not avail sysc then do: 
   message "В системных настройках не прописаны пакеты доступа для кредитного модуля! Параметр paket." view-as alert-box buttons ok title 'ВНИМАНИЕ!'.
   return.
end.
v-paket = sysc.chval.
find ofc where ofc.ofc = g-ofc no-lock no-error.
if avail ofc then do:
   v-pak = ofc.expr[1]. 
   i = num-entries(ofc.expr[1]).
end.
do while i > 0 :
   if lookup(entry(i,v-pak), v-paket) > 0 then do:
      v-trans = '1'.
      leave.
   end.   
   i = i - 1.
end.
return v-trans.
