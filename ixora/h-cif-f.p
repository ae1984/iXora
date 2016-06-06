/* h-cif-f.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Поиск клиента на другом филиале
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
        TXB
 * AUTHOR
        2306.2010 marinav
 * CHANGES
*/

define var vselect as cha format "x".
def var vcnt as int.
def var vvname as cha .
message "Выберите клиента   A)счет  N)Имя  P)РНН    B)ИИН/БИН" update vselect.

if vselect eq "A"  OR VSELECT EQ "а"  or vselect eq "А"  or vselect eq "ф" or vselect eq "Ф"
then do:
 {itemlist.i
   &updvar  = "def var vaaa like txb.aaa.aaa.
               message 'Введите счет  ' update vaaa.
               find txb.aaa where txb.aaa.aaa eq vaaa no-lock no-error.
               if not avail txb.aaa then do: message 'Счет' vaaa 'не найден!'. pause 10. return. end."
   &where = "txb.cif.cif eq txb.aaa.cif"
   &form = "txb.cif.cif txb.cif.sname form ""x(40)"" txb.cif.jss txb.cif.tel "
   &frame = "row 5 centered scroll 1 down overlay width 100 "
   &index = "cif"
   &chkey = "cif"
   &chtype = "string"
   &file = "txb.cif"
   &flddisp = "txb.cif.cif trim(trim(txb.cif.prefix) + ' ' + trim(txb.cif.sname)) @ txb.cif.sname txb.cif.jss txb.cif.tel"
   &funadd = "if frame-value = "" ""
               then do:
                       message 'Клиент не найден'.
                       pause 1.
                       next.
               end."
   &set = "a"
   }
end.
else if vselect eq "N" OR VSELECT EQ "н" OR VSELECT EQ "Н" or vselect eq "т" or vselect eq "Т"
then do:
 {itemlist.i
   &updvar  = "def var vname like txb.cif.sname.
               message 'Введите данные  '  update vname.
               vvname = '*' + vname + '*' . "
   &where = "
   ( caps(trim(trim(txb.cif.prefix) + ' ' + trim(txb.cif.sname)))  MATCHES vvname or
   caps(trim(trim(txb.cif.prefix) + ' ' + trim(txb.cif.name))) matches vvname )
   "
   &form = "txb.cif.cif txb.cif.sname form ""x(40)"" txb.cif.jss txb.cif.tel "
   &frame = "row 5 centered scroll 1 down overlay width 100 "
   &index = "sname"
   &chkey = "cif"
   &chtype = "string"
   &file = "txb.cif"
   &flddisp = "txb.cif.cif trim(trim(txb.cif.prefix) + ' ' + trim(txb.cif.sname)) @ txb.cif.sname  txb.cif.jss  txb.cif.tel "
   &funadd = "if frame-value = "" ""
               then do:
                       message 'Клиент не найден'.
                       pause 1.
                       next.
               end."
   &set = "N"
   }
end.
else if vselect eq "P" or vselect = "П" or vselect = "п" or vselect eq "з" or vselect eq "З"
then do:
 {itemlist.i
   &updvar  = "def var vss like txb.cif.jss.
               message 'Введите РНН  '  update vss."
   &where = "txb.cif.jss begins vss "
   &form = "txb.cif.cif txb.cif.sname form ""x(40)"" txb.cif.jss txb.cif.tel "
   &frame = "row 5 centered scroll 1 down overlay width 100 "
   &index = "jss"
   &chkey = "cif"
   &chtype = "string"
   &file = "txb.cif"
   &flddisp = "txb.cif.cif trim(trim(txb.cif.prefix) + ' ' + trim(txb.cif.sname)) @ txb.cif.sname txb.cif.jss txb.cif.tel "
   &funadd = "if frame-value = "" ""
               then do:
                       message 'Клиент не найден'.
                       pause 1.
                       next.
               end."
   &set = "P"
   }
end.
else if vselect eq "И" or vselect = "и" or vselect = "B" or vselect eq "b"
then do:
 {itemlist.i
   &updvar  = "def var bin like txb.cif.bin.
               message 'Введите ИИН/БИН  '  update bin."
   &where = "txb.cif.bin begins bin "
   &form = "txb.cif.cif txb.cif.sname form ""x(40)"" txb.cif.bin txb.cif.tel "
   &frame = "row 5 centered scroll 1 down overlay width 100 "
   &index = "bin"
   &chkey = "cif"
   &chtype = "string"
   &file = "txb.cif"
   &flddisp = "txb.cif.cif trim(trim(txb.cif.prefix) + ' ' + trim(txb.cif.sname)) @ txb.cif.sname txb.cif.bin txb.cif.tel "
   &funadd = "if frame-value = "" ""
               then do:
                       message 'Клиент не найден'.
                       pause 1.
                       next.
               end."
   &set = "B"
   }
end.
