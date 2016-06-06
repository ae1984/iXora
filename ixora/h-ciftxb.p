/* h-ciftxb.p
 * MODULE
        Программы общего назначения
 * DESCRIPTION
        Поиск клиента в базе txb
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
 * BASES
        BANK COMM TXB
 * CHANGES
        01/03/2011 madiyar - скопировал с изменениями программу h-cif.p
        14.05.2013 damir - Внедрено Т.З. № 1731.
*/

def output parameter p-cif as char no-undo.
def shared var g-lang as char.

/* h-cif.p */
define var vselect as cha format "x".
def var vcnt as int.
def var vvname as cha .
message "Выберите клиента   A)счет  G)гео Код  N)Имя  P)РНН  L)ссудный счет  B)ИИН/БИН" update vselect.

if vselect eq "A"  OR VSELECT EQ "а"  or vselect eq "А"  or vselect eq "ф" or vselect eq "Ф"
then do:
 {itemlist.i
   &updvar  = "def var vaaa like txb.aaa.aaa.
               find txb.msg where txb.msg.lang eq g-lang and txb.msg.ln eq 1812 no-lock.
               message '[MSG#' txb.msg.ln ']' txb.msg.msg update vaaa.
               find txb.aaa where txb.aaa.aaa eq vaaa no-lock no-error.
               if not avail txb.aaa then do: message 'Счет' vaaa 'не найден!'. pause 10. return. end."
   &where = "txb.cif.cif eq txb.aaa.cif"
   &form = "txb.cif.cif txb.cif.sname form ""x(40)"" txb.cif.jss txb.cif.tel "
   &frame = "row 5 centered scroll 1 down overlay "
   &index = "cif"
   &chkey = "cif"
   &chtype = "string"
   &file = "txb.cif"
   &flddisp = "cif.cif trim(trim(txb.cif.prefix) + ' ' + trim(txb.cif.sname)) @ txb.cif.sname txb.cif.jss txb.cif.tel"
   &funadd = "if frame-value = "" ""
               then do:
                       bell.
                       {imesg.i 9205}.
                       pause 1.
                       next.
               end."
   &set = "a"
   }
   p-cif = txb.cif.cif.
end.
else if vselect eq "N" OR VSELECT EQ "н" OR VSELECT EQ "Н" or vselect eq "т" or vselect eq "Т"
then do:
 {itemlist.i
   &updvar  = "def var vname like txb.cif.sname.
               find txb.msg where txb.msg.lang eq g-lang and txb.msg.ln eq 2808 no-lock.
               message '[MSG#' txb.msg.ln ']' txb.msg.msg update vname.
               vvname = '*' + vname + '*' . "
   &where = "
   ( caps(trim(trim(txb.cif.prefix) + ' ' + trim(txb.cif.sname)))  MATCHES vvname or
   caps(trim(trim(txb.cif.prefix) + ' ' + trim(txb.cif.name))) matches vvname )
   "
   &form = "txb.cif.cif txb.cif.sname form ""x(40)"" txb.cif.jss txb.cif.tel "
   &frame = "row 5 centered scroll 1 down overlay "
   &index = "sname"
   &chkey = "cif"
   &chtype = "string"
   &file = "txb.cif"
   &flddisp = "txb.cif.cif trim(trim(txb.cif.prefix) + ' ' + trim(txb.cif.sname)) @ txb.cif.sname  txb.cif.jss  txb.cif.tel "
   &funadd = "if frame-value = "" ""
               then do:
                       bell.
                       {imesg.i 9205}.
                       pause 1.
                       next.
               end."
   &set = "N"
   }
   p-cif = txb.cif.cif.
end.
else if vselect eq "S" or vselect eq "ы" or vselect eq "Ы"
then do:
 {itemlist.i
   &updvar  = "def var vpss like txb.cif.pss.
               find txb.msg where txb.msg.lang eq g-lang and txb.msg.ln eq 2805 no-lock.
               message '[MSG#' txb.msg.ln ']' txb.msg.msg update vpss."
   &where = "txb.cif.pss begins vpss "
   &form = "txb.cif.cif txb.cif.sname form ""x(10)"" txb.cif.jame form ""x(10)""
            label ""JOINT NAME""
            txb.cif.pss txb.cif.jss txb.cif.tel txb.cif.geo label ""GEO"" "
   &frame = "row 5 centered scroll 1 down overlay "
   &index = "pss"
   &chkey = "cif"
   &chtype = "string"
   &file = "txb.cif"
   &flddisp = "txb.cif.cif trim(trim(txb.cif.prefix) + ' ' + trim(txb.cif.sname)) @ txb.cif.sname txb.cif.pss txb.cif.tel "
   &funadd = "if frame-value = "" ""
               then do:
                       bell.
                       {imesg.i 9205}.
                       pause 1.
                       next.
               end."
   &set = "S"
   }
   p-cif = txb.cif.cif.
end.
else if vselect eq "T" or vselect eq "е" or vselect eq "Е"
then do:
 {itemlist.i
   &updvar  = "def var vtel like txb.cif.tel.
               find txb.msg where txb.msg.lang eq g-lang and txb.msg.ln eq 2806 no-lock.
               message '[MSG#' txb.msg.ln ']' txb.msg.msg update vtel."
   &where = "txb.cif.tel begins vtel"
   &form = "txb.cif.cif txb.cif.sname form ""x(10)"" txb.cif.jame form ""x(10)""
            label ""JOINT NAME""
            txb.cif.pss txb.cif.jss txb.cif.tel txb.cif.geo label ""GEO"" "
   &frame = "row 5 centered scroll 1 down overlay "
   &index = "tel"
   &chkey = "cif"
   &chtype = "string"
   &file = "txb.cif"
   &flddisp = "txb.cif.cif trim(trim(txb.cif.prefix) + ' ' + trim(txb.cif.sname)) @ txb.cif.sname txb.cif.pss txb.cif.tel "
   &funadd = "if frame-value = "" ""
               then do:
                       bell.
                       find txb.msg where txb.msg.lang eq g-lang and txb.msg.ln eq 9205 no-lock.
                       message '[MSG#' txb.msg.ln ']' txb.msg.msg.
                       pause 1.
                       next.
               end."
   &set = "T"
   }
   p-cif = txb.cif.cif.
end.
else if vselect eq "G" or vselect eq "п" or vselect eq "П"
then do:
 {itemlist.i
   &updvar  = "def var vgeo like txb.cif.geo.
               find txb.msg where txb.msg.lang eq g-lang and txb.msg.ln eq 0813 no-lock.
               message '[MSG#' txb.msg.ln ']' txb.msg.msg update vgeo."
   &where = "txb.cif.geo begins vgeo"
   &form = "txb.cif.cif txb.cif.sname form ""x(10)"" txb.cif.jame form ""x(10)""
            label ""JOINT NAME""
            txb.cif.pss txb.cif.jss txb.cif.tel txb.cif.geo label ""GEO"" "
   &frame = "row 5 centered scroll 1 down overlay "
   &index = "geo"
   &chkey = "cif"
   &chtype = "string"
   &file = "txb.cif"
   &flddisp = "txb.cif.cif trim(trim(txb.cif.prefix) + ' ' + trim(txb.cif.sname)) @ txb.cif.sname txb.cif.pss txb.cif.tel txb.cif.geo"
   &funadd = "if frame-value = "" ""
               then do:
                       bell.
                       find txb.msg where txb.msg.lang eq g-lang and txb.msg.ln eq 9205 no-lock.
                       message '[MSG#' txb.msg.ln ']' txb.msg.msg.
                       pause 1.
                       next.
               end."
   &set = "G"
   }
   p-cif = txb.cif.cif.
end.
else if vselect eq "J" or vselect eq "о" or vselect eq "О"
then do:
 {itemlist.i
   &updvar  = "def var vnam like txb.cif.jame.
               find txb.msg where txb.msg.lang eq g-lang and txb.msg.ln eq 2808 no-lock.
               message '[MSG#' txb.msg.ln ']' txb.msg.msg update vnam."
   &where = "txb.cif.jame ge vnam"
   &form = "txb.cif.cif txb.cif.sname form ""x(10)"" txb.cif.jame form ""x(10)""
            label ""JOINT NAME""
            txb.cif.pss txb.cif.jss txb.cif.tel txb.cif.geo label ""GEO"" "
   &frame = "row 5 centered scroll 1 down overlay "
   &index = "jame"
   &chkey = "cif"
   &chtype = "string"
   &file = "txb.cif"
   &flddisp = "txb.cif.cif trim(trim(txb.cif.prefix) + ' ' + trim(txb.cif.sname)) @ txb.cif.sname txb.cif.pss txb.cif.jame txb.cif.jss"
   &funadd = "if frame-value = "" ""
               then do:
                       bell.
                       find txb.msg where txb.msg.lang eq g-lang and txb.msg.ln eq 9205 no-lock.
                       message '[MSG#' txb.msg.ln ']' txb.msg.msg.
                       pause 1.
                       next.
               end."
   &set = "J"
   }
   p-cif = txb.cif.cif.
end.
else if vselect eq "P" or vselect = "П" or vselect = "п" or vselect eq "з" or vselect eq "З"
then do:
 {itemlist.i
   &updvar  = "def var vss like txb.cif.pss.
               find txb.msg where txb.msg.lang eq g-lang and txb.msg.ln eq 2805 no-lock.
               message '[MSG#' txb.msg.ln ']' txb.msg.msg update vss."
   &where = "txb.cif.jss begins vss "
   &form = "txb.cif.cif txb.cif.sname form ""x(40)"" txb.cif.jss txb.cif.tel "
   &frame = "row 5 centered scroll 1 down overlay "
   &index = "jss"
   &chkey = "cif"
   &chtype = "string"
   &file = "txb.cif"
   &flddisp = "txb.cif.cif trim(trim(txb.cif.prefix) + ' ' + trim(txb.cif.sname)) @ txb.cif.sname txb.cif.jss txb.cif.tel "
   &funadd = "if frame-value = "" ""
               then do:
                       bell.
                       find txb.msg where txb.msg.lang eq g-lang and txb.msg.ln eq 9205 no-lock.
                       message '[MSG#' txb.msg.ln ']' txb.msg.msg.
                       pause 1.
                       next.
               end."
   &set = "P"
   }
   p-cif = txb.cif.cif.
end.
else if vselect eq "L"  OR VSELECT EQ "l"   or vselect eq "д" or vselect eq "Д"
then do:
 {itemlist.i
   &updvar  = "def var vlon like txb.lon.lon.
               message ' Введите ссудный счет ' update vlon.
               find txb.lon where txb.lon.lon eq vlon no-lock no-error.
               if not avail txb.lon then do: message 'Ссудный счет' vlon 'не найден!'. pause 10. return. end. "
   &where = "txb.cif.cif eq txb.lon.cif"
   &form = "txb.cif.cif txb.cif.sname form ""x(40)"" txb.cif.jss txb.cif.tel "
   &frame = "row 5 centered scroll 1 down overlay "
   &index = "cif"
   &chkey = "cif"
   &chtype = "string"
   &file = "txb.cif"
   &flddisp = "txb.cif.cif trim(trim(txb.cif.prefix) + ' ' + trim(txb.cif.sname)) @ txb.cif.sname txb.cif.jss txb.cif.tel"
   &funadd = "if frame-value = "" ""
               then do:
                       bell.
                       find txb.msg where txb.msg.lang eq g-lang and txb.msg.ln eq 9205 no-lock.
                       message '[MSG#' txb.msg.ln ']' txb.msg.msg.
                       pause 1.
                       next.
               end."
   &set = "L"
   }
   p-cif = txb.cif.cif.
end.
else if vselect eq "B"  OR VSELECT EQ "b"   or vselect eq "и" or vselect eq "И"
then do:
    {itemlist.i
        &updvar     = "def var v-clbin like txb.cif.bin.
                       {imesg.i 2805} update v-clbin."
        &where      = "txb.cif.bin begins v-clbin "
        &form       = "txb.cif.cif txb.cif.sname form ""x(40)"" txb.cif.bin txb.cif.tel "
        &frame      = "row 5 centered scroll 1 down overlay width 100 "
        &index      = "bin"
        &chkey      = "cif"
        &chtype     = "string"
        &file       = "txb.cif"
        &flddisp    = "txb.cif.cif trim(trim(txb.cif.prefix) + ' ' + trim(txb.cif.sname)) @ txb.cif.sname txb.cif.bin txb.cif.tel "
        &funadd     = "if frame-value = "" ""
                       then do:
                            bell.
                            {imesg.i 9205}.
                            pause 1.
                            next.
                       end."
        &set = "B"
    }
end.
