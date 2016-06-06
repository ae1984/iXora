/* h-cif.p
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
        19/08/03 nataly - при выборе счета была добавлена проверка на букву "ф" ("a" на русском языке)
        20.05.2004 nadejda - добавлены русские буквы по всем вариантам, добавлен выбор по ссудному счету
        19/07/04 sasco - добавил скобки в условие по where для "N"
        03.12.08 marinav compile
        12/12/11 evseev - добавил поиск по БИН. ТЗ-625
*/

/* h-cif.p */
{global.i}
define var vselect as cha format "x".
def var vcnt as int.
def var vvname as cha .
message "Выберите клиента   A)счет  G)гео Код  N)Имя  P)РНН  L)ссудный счет  B)ИИН/БИН" update vselect.

if vselect eq "A"  OR VSELECT EQ "а"  or vselect eq "А"  or vselect eq "ф" or vselect eq "Ф"
then do:
 {itemlist.i
   &updvar  = "def var vaaa like aaa.aaa.
               {imesg.i 1812} update vaaa.
               find aaa where aaa.aaa eq vaaa no-lock no-error.
               if not avail aaa then do: message 'Счет' vaaa 'не найден!'. pause 10. return. end."
   &where = "cif.cif eq aaa.cif"
   &form = "cif.cif cif.sname form ""x(40)"" cif.jss cif.bin cif.tel "
   &frame = "row 5 centered scroll 1 down overlay width 100 "
   &index = "cif"
   &chkey = "cif"
   &chtype = "string"
   &file = "cif"
   &flddisp = "cif.cif trim(trim(cif.prefix) + ' ' + trim(cif.sname)) @ cif.sname cif.jss cif.bin cif.tel"
   &funadd = "if frame-value = "" ""
               then do:
                       bell.
                       {imesg.i 9205}.
                       pause 1.
                       next.
               end."
   &set = "a"
   }
end.
else if vselect eq "N" OR VSELECT EQ "н" OR VSELECT EQ "Н" or vselect eq "т" or vselect eq "Т"
then do:
 {itemlist.i
   &updvar  = "def var vname like cif.sname.
               {imesg.i 2808} update vname.
               vvname = '*' + vname + '*' . "
   &where = "
   ( caps(trim(trim(cif.prefix) + ' ' + trim(cif.sname)))  MATCHES vvname or
   caps(trim(trim(cif.prefix) + ' ' + trim(cif.name))) matches vvname )
   "
   &form = "cif.cif cif.sname form ""x(40)"" cif.jss cif.bin cif.tel "
   &frame = "row 5 centered scroll 1 down overlay width 100 "
   &index = "sname"
   &chkey = "cif"
   &chtype = "string"
   &file = "cif"
   &flddisp = "cif.cif trim(trim(cif.prefix) + ' ' + trim(cif.sname)) @ cif.sname  cif.jss cif.bin  cif.tel "
   &funadd = "if frame-value = "" ""
               then do:
                       bell.
                       {imesg.i 9205}.
                       pause 1.
                       next.
               end."
   &set = "N"
   }
end.
else if vselect eq "S" or vselect eq "ы" or vselect eq "Ы"
then do:
 {itemlist.i
   &updvar  = "def var vpss like cif.pss.
               {imesg.i 2805} update vpss."
   &where = "cif.pss begins vpss "
   &form = "cif.cif cif.sname form ""x(10)"" cif.jame form ""x(10)""
            label ""JOINT NAME""
            cif.pss cif.jss cif.tel cif.geo label ""GEO"" "
   &frame = "row 5 centered scroll 1 down overlay width 100 "
   &index = "pss"
   &chkey = "cif"
   &chtype = "string"
   &file = "cif"
   &flddisp = "cif.cif trim(trim(cif.prefix) + ' ' + trim(cif.sname)) @ cif.sname cif.pss cif.tel "
   &funadd = "if frame-value = "" ""
               then do:
                       bell.
                       {imesg.i 9205}.
                       pause 1.
                       next.
               end."
   &set = "S"
   }
end.
else if vselect eq "T" or vselect eq "е" or vselect eq "Е"
then do:
 {itemlist.i
   &updvar  = "def var vtel like cif.tel.
               {imesg.i 2806} update vtel."
   &where = "cif.tel begins vtel"
   &form = "cif.cif cif.sname form ""x(10)"" cif.jame form ""x(10)""
            label ""JOINT NAME""
            cif.pss cif.jss cif.tel cif.geo label ""GEO"" "
   &frame = "row 5 centered scroll 1 down overlay width 100 "
   &index = "tel"
   &chkey = "cif"
   &chtype = "string"
   &file = "cif"
   &flddisp = "cif.cif trim(trim(cif.prefix) + ' ' + trim(cif.sname)) @ cif.sname cif.pss cif.tel "
   &funadd = "if frame-value = "" ""
               then do:
                       bell.
                       {imesg.i 9205}.
                       pause 1.
                       next.
               end."
   &set = "T"
   }
end.
else if vselect eq "G" or vselect eq "п" or vselect eq "П"
then do:
 {itemlist.i
   &updvar  = "def var vgeo like cif.geo.
               {imesg.i 0813} update vgeo."
   &where = "cif.geo begins vgeo"
   &form = "cif.cif cif.sname form ""x(10)"" cif.jame form ""x(10)""
            label ""JOINT NAME""
            cif.pss cif.jss cif.bin cif.tel cif.geo label ""GEO"" "
   &frame = "row 5 centered scroll 1 down overlay width 100 "
   &index = "geo"
   &chkey = "cif"
   &chtype = "string"
   &file = "cif"
   &flddisp = "cif.cif trim(trim(cif.prefix) + ' ' + trim(cif.sname)) @ cif.sname cif.pss cif.bin  cif.tel cif.geo"
   &funadd = "if frame-value = "" ""
               then do:
                       bell.
                       {imesg.i 9205}.
                       pause 1.
                       next.
               end."
   &set = "G"
   }
end.
else if vselect eq "J" or vselect eq "о" or vselect eq "О"
then do:
 {itemlist.i
   &updvar  = "def var vnam like cif.jame.
               {imesg.i 2808} update vnam."
   &where = "cif.jame ge vnam"
   &form = "cif.cif cif.sname form ""x(10)"" cif.jame form ""x(10)""
            label ""JOINT NAME""
            cif.pss cif.jss cif.tel cif.geo label ""GEO"" "
   &frame = "row 5 centered scroll 1 down overlay width 100 "
   &index = "jame"
   &chkey = "cif"
   &chtype = "string"
   &file = "cif"
   &flddisp = "cif.cif trim(trim(cif.prefix) + ' ' + trim(cif.sname)) @ cif.sname cif.pss cif.jame cif.jss"
   &funadd = "if frame-value = "" ""
               then do:
                       bell.
                       {imesg.i 9205}.
                       pause 1.
                       next.
               end."
   &set = "J"
   }
end.
else if vselect eq "P" or vselect = "П" or vselect = "п" or vselect eq "з" or vselect eq "З"
then do:
 {itemlist.i
   &updvar  = "def var vss like cif.pss.
               {imesg.i 2805} update vss."
   &where = "cif.jss begins vss "
   &form = "cif.cif cif.sname form ""x(40)"" cif.jss cif.bin  cif.tel "
   &frame = "row 5 centered scroll 1 down overlay width 100 "
   &index = "jss"
   &chkey = "cif"
   &chtype = "string"
   &file = "cif"
   &flddisp = "cif.cif trim(trim(cif.prefix) + ' ' + trim(cif.sname)) @ cif.sname cif.jss cif.bin  cif.tel "
   &funadd = "if frame-value = "" ""
               then do:
                       bell.
                       {imesg.i 9205}.
                       pause 1.
                       next.
               end."
   &set = "P"
   }
end.
else if vselect eq "L"  OR VSELECT EQ "l"   or vselect eq "д" or vselect eq "Д"
then do:
 {itemlist.i
   &updvar  = "def var vlon like lon.lon.
               message ' Введите ссудный счет ' update vlon.
               find lon where lon.lon eq vlon no-lock no-error.
               if not avail lon then do: message 'Ссудный счет' vlon 'не найден!'. pause 10. return. end. "
   &where = "cif.cif eq lon.cif"
   &form = "cif.cif cif.sname form ""x(40)"" cif.jss cif.bin  cif.tel "
   &frame = "row 5 centered scroll 1 down overlay width 100 "
   &index = "cif"
   &chkey = "cif"
   &chtype = "string"
   &file = "cif"
   &flddisp = "cif.cif trim(trim(cif.prefix) + ' ' + trim(cif.sname)) @ cif.sname cif.jss cif.bin  cif.tel"
   &funadd = "if frame-value = "" ""
               then do:
                       bell.
                       {imesg.i 9205}.
                       pause 1.
                       next.
               end."
   &set = "L"
   }
end.
else if vselect eq "B"  OR VSELECT EQ "b"   or vselect eq "и" or vselect eq "И"
then do:
 {itemlist.i
   &updvar  = "def var v-clbin like cif.bin.
               {imesg.i 2805} update v-clbin."
   &where = "cif.bin begins v-clbin "
   &form = "cif.cif cif.sname form ""x(40)"" cif.bin cif.tel "
   &frame = "row 5 centered scroll 1 down overlay width 100 "
   &index = "bin"
   &chkey = "cif"
   &chtype = "string"
   &file = "cif"
   &flddisp = "cif.cif trim(trim(cif.prefix) + ' ' + trim(cif.sname)) @ cif.sname cif.bin cif.tel "
   &funadd = "if frame-value = "" ""
               then do:
                       bell.
                       {imesg.i 9205}.
                       pause 1.
                       next.
               end."
   &set = "B"
   }
end.