/* h-cf.p
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
        25/10/11 lyubov
 * CHANGES

*/

/* h-cif.p */
{global.i}
define var vselect as cha format "x".
def var vcnt as int.
def var vcf as cha .
message "Выберите клиента  N)Имя  P)РНН " update vselect.

if vselect eq "N" OR VSELECT EQ "н" OR VSELECT EQ "Н" or vselect eq "т" or vselect eq "Т"
then do:
 {itemlist.i
   &updvar  = "def var vname like cif.sname.
               {imesg.i 2808} update vname.
               vcf = '*' + vname + '*' . "
   &where = "
   ( caps(trim(trim(cif.prefix) + ' ' + trim(cif.sname)))  MATCHES vcf or
   caps(trim(trim(cif.prefix) + ' ' + trim(cif.name))) matches vcf )
   "
   &form = "cif.cif cif.sname form ""x(40)"" cif.jss cif.tel "
   &frame = "row 5 centered scroll 1 down overlay "
   &index = "sname"
   &chkey = "cif"
   &chtype = "string"
   &file = "cif"
   &flddisp = "cif.cif trim(trim(cif.prefix) + ' ' + trim(cif.sname)) @ cif.sname  cif.jss  cif.tel "
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
else if vselect eq "P" or vselect = "П" or vselect = "п" or vselect eq "з" or vselect eq "З"
then do:
 {itemlist.i
   &updvar  = "def var vss like cif.pss.
               {imesg.i 2805} update vss."
   &where = "cif.jss begins vss "
   &form = "cif.cif cif.sname form ""x(40)"" cif.jss cif.tel "
   &frame = "row 5 centered scroll 1 down overlay "
   &index = "jss"
   &chkey = "cif"
   &chtype = "string"
   &file = "cif"
   &flddisp = "cif.cif trim(trim(cif.prefix) + ' ' + trim(cif.sname)) @ cif.sname cif.jss cif.tel "
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
