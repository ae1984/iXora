/* cifcrgh.p
 * MODULE
        Клиенты и их счета
 * DESCRIPTION
        История изменения статуса контроля признаков клиента
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        s-cifchk.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        1.11
 * AUTHOR
        04.11.03 sasco
 * CHANGES
*/

{functions-def.i}
  
define shared variable s-cif like cif.cif.
define shared variable g-ofc as character.

define variable v-ofcname as char init "(не найден в списке офицеров)".
define variable v-rezid as char init "(не указан)".
define variable v-secek as char init "(не указан)".
define variable v-ecdivis as char init "(не указан)".
define variable v-i as int init 0.
define variable v-c as char.
define stream rep.

output stream rep to rptcntr.img.

find first crg where crg.des = s-cif no-lock no-error.
if not available crg then do:
  message " Нет отметок о контроле признаков данного клиента ".
  pause.
  return.
end.

find ofc where ofc.ofc = g-ofc no-lock no-error.
if available ofc then v-ofcname = ofc.name.

find cif where cif.cif = s-cif no-lock no-error.
if not available cif then return.

find sub-cod where sub-cod.acc = s-cif and sub-cod.sub = "cln" and sub-cod.d-cod = "clnsts" no-lock no-error.
if available sub-cod then do:
  v-rezid = sub-cod.ccode.
  find codfr where codfr.codfr = "clnsts" and codfr.code = sub-cod.ccode no-lock no-error.
  v-rezid = "(" + v-rezid + ") " + codfr.name[1].
end.

find sub-cod where sub-cod.acc = s-cif and sub-cod.sub = "cln" and sub-cod.d-cod = "secek" no-lock no-error.
if available sub-cod then do:
  v-secek = sub-cod.ccode.
  find codfr where codfr.codfr = "secek" and codfr.code = sub-cod.ccode no-lock no-error.
  v-secek = "(" + v-secek + ") " + codfr.name[1].
end.

find sub-cod where sub-cod.acc = s-cif and sub-cod.sub = "cln" and sub-cod.d-cod = "ecdivis" no-lock no-error.
if available sub-cod then do:
  v-ecdivis = sub-cod.ccode.
  find codfr where codfr.codfr = "ecdivis" and codfr.code = sub-cod.ccode no-lock no-error.
  v-ecdivis = "(" + v-ecdivis + ") " + codfr.name[1].
end.

put stream rep
FirstLine( 1, 1 ) format "x(70)" skip
"Исполнитель :  " v-ofcname format "x(50)" skip(2)
"ПРОТОКОЛ КОНТРОЛЯ ПРИЗНАКОВ КЛИЕНТА" skip(1)
"Код клиента       :  " cif.cif format "x(6)" skip
"Наименование      :  " cif.name format "x(40)" skip
"Резидентство      :  " v-rezid format "x(30)" skip
"Сектор экономики  :  " v-secek format "x(30)" skip
"Отрасль экономики :  " v-ecdivis format "x(40)" skip(1)
fill("-", 79) format "x(79)" skip
"  N  |   Офицер      |    Дата    |    Время   |  Статус отметки" skip
fill("-", 79) format "x(79)" skip.

for each crg where crg.des = s-cif  no-lock by crg.crg desc:
  v-i = v-i + 1.
  if crg.stn = 0 then
    v-c = "снять".
  else
    v-c = "установить".
  put stream rep 
     v-i format "zzz9" "|" at 6 
     crg.who at 9 "|" at 22 
     crg.whn format "99/99/99" at 25 "|" at 35 
     string(crg.tim,"HH:MM:SS") at 38 "|" at 48 
     v-c format "x(12)" at 51 skip.
end.

put stream rep fill("-", 79) format "x(79)" skip.

output stream rep close.

run menu-prt("rptcntr.img").
unix silent rm rptcntr.img.

