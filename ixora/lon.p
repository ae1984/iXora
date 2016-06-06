/* lon.p
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
       22.10.03 nataly были добавлены код клиента и наименование  - по заявке Касимовой Т.
*/

output to lon.txt.

for each lon where gl = 140130 or gl = 140140 or gl = 141110 or gl = 141120 or gl = 141410 or gl = 141420 or gl = 141710 or gl = 141720 or gl = 144000 no-lock:
   find trxbal where trxbal.subled eq 'lon' and trxbal.acc eq lon.lon and    trxbal.level = 10 no-lock no-error.
   if avail trxbal  then if trxbal.cam - trxbal.dam <> 0 then
     do:
      find cif where cif.cif = lon.cif no-lock no-error.
      put trxbal.acc trxbal.cam - trxbal.dam format 'zzz,zzz,zzz,zzz.99-' cif.cif ' ' cif.name  skip. 
      ACCUMULATE (trxbal.cam - trxbal.dam) (TOTAL).
     end. 
end.        
put fill('-',30) format 'x(30)' skip.

put 'Сумма' format 'x(10)'(ACCUM TOTAL trxbal.cam - trxbal.dam) format 'zzz,zzz,zzz,zzz.99-' skip.

output close.

run menu-prt('lon.txt').