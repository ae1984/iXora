/* .p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        --/--/2011 damir
 * BASES
        BANK
 * CHANGES
*/

{functions-def.i}

def shared var s-cif like cif.cif.
def shared var g-ofc as character.

def var v-cif     as char.
def var v-aaa1    as char.
def var v-aaa2    as char.
def var v-i       as int init 0.
def var v-ofcname as char init "(не найден в списке офицеров)".
def var v-rezid as char init "(не указан)".
def var v-secek as char init "(не указан)".
def var v-ecdivis as char init "(не указан)".

define stream rep.

output stream rep to rptcntr.img.

find first aaaperost where aaaperost.cif = s-cif no-lock no-error.
if not avail aaaperost then do:
    message " Клиент не найден !".
    pause.
    return.
end.
else do:
    v-cif  = aaaperost.cif.
    v-aaa1 = aaaperost.aaacif1.
    v-aaa2 = aaaperost.aaacif2.
end.
find ofc where ofc.ofc = g-ofc no-lock no-error.
if avail ofc then v-ofcname = ofc.name.

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
"ИСТОРИЯ ПЕРЕВОДА ОСТАТКОВ С ОДНОГО СЧЕТА НА ДРУГОЙ КЛИЕНТА" skip(1)
"Код клиента       :  " cif.cif format "x(6)" skip
"Наименование      :  " cif.name format "x(40)" skip
"Резидентство      :  " v-rezid format "x(30)" skip
"Сектор экономики  :  " v-secek format "x(30)" skip
"Отрасль экономики :  " v-ecdivis format "x(40)" skip(1)
fill("-", 88) format "x(88)" skip
"   N | Код клиента |       Счет 1         |       Счет 2         | Офицер   |   Дата         " skip
fill("-", 88) format "x(88)" skip.

find last aaaperost where aaaperost.cif = s-cif no-lock no-error.
if avail aaaperost then do:
    v-i = v-i + 1.
    put stream rep
    v-i format "zzz9" "|" at 6
    aaaperost.cif at 9 "|" at 20
    aaaperost.aaacif1 at 22 "|" at 43
    aaaperost.aaacif2 at 45 "|" at 66
    aaaperost.who at 67 "|" at 77
    aaaperost.whn format "99/99/9999" at 79 skip.
end.

put stream rep fill("-", 88) format "x(88)" skip.

output stream rep close.

run menu-prt("rptcntr.img").
unix silent rm rptcntr.img.