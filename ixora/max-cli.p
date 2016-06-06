/* max-cli.p
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

def stream rpt.
def var maxval as decimal init 50000.
def shared var g-today as date.
output stream rpt to 'rpt.img'.

put stream rpt skip  'СПИСОК ВАЛЮТНЫХ СЧЕТОВ КЛИЕНТОВ С ОСТАТКОМ >= ' at 5 maxval format 'z,zzz,zz9'
   skip 'НА ' at 20 g-today skip(2).

put stream rpt skip ' ' fill( '-', 97 )           format 'x(97)'       skip.
put stream rpt skip 
  '   СЧЕТ              НАИМЕНОВАНИЕ                         ВАЛЮТА            СУММА   %СТАВКА ДАТА ОТК ДАТА ЗАКР'.
put stream rpt skip ' ' fill( '-', 97 )           format 'x(97)'       skip.

 for each aaa where aaa.sta <> 'C' and aaa.cr[1] <> aaa.dr[1] 
           and aaa.crc <> 1  break by crc  . 
 find cif where cif.cif = aaa.cif no-lock no-error.
 find crc where crc.crc = aaa.crc no-lock no-error.
 
if  aaa.cr[1] - aaa.dr[1] >= maxval then 
     put stream rpt skip
      aaa.aaa cif.name format 'x(50)' crc.code ' ' 
      aaa.cr[1] - aaa.dr[1] format 'z,zzz,zzz,zzz,zz9.99' 
      aaa.rate format 'z9.99' 
       ' ' aaa.regdt  ' ' aaa.expdt   ' '    .
 end.

output stream rpt close.
run menu-prt('rpt.img').
