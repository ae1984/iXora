/* h-vcif.p
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

/* h-cif.p */
{global.i}
define var vselect as cha format "x".

{mesg.i 2402} update vselect.

if vselect eq "A"
then do:
 {itemlist.i
   &var  = "def var vaaa like aaa.aaa."
   &updvar  = "{imesg.i 1812} update vaaa.
               find aaa where aaa.aaa eq vaaa."
   &where = "cif.cif eq aaa.cif"
   &frame = "row 2 centered scroll 1 15 down overlay
             top-only title "" Select from List "" "
   &index = "cif"
   &chkey = "cif"
   &chtype = "string"
   &file = "cif"
   &flddisp = "cif.cif trim(trim(cif.prefix) + ' ' + trim(cif.sname)) @ cif.sname cif.pss cif.tel"
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
else if vselect eq "N"
then do:
 {itemlist.i
   &var  = "def var vname like cif.sname."
   &updvar  = "{imesg.i 2808} update vname."
   &where = "trim(trim(cif.prefix) + ' ' + trim(cif.sname)) matches '*' + vname + '*' "
   &frame = "row 2 centered scroll 1 15 down overlay
             top-only title "" Select from List "" "
   &index = "sname"
   &chkey = "cif"
   &chtype = "string"
   &file = "cif"
   &flddisp = "cif.cif trim(trim(cif.prefix) + ' ' + trim(cif.sname)) @ cif.sname  cif.pss  cif.tel "
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
else if vselect eq "S"
then do:
 {itemlist.i
   &var  = "def var vpss like cif.pss."
   &updvar  = "{imesg.i 2805} update vpss."
   &where = "cif.pss begins vpss "
   &frame = "row 2 centered scroll 1 15 down overlay
             top-only title "" Select from List "" "
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
else if vselect eq "T"
then do:
 {itemlist.i
   &var  = "def var vtel like cif.tel."
   &updvar  = "{imesg.i 2806} update vtel."
   &where = "cif.tel begins vtel"
   &frame = "row 2 centered scroll 1 15 down overlay
             top-only title "" Select from List "" "
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
else if vselect eq "G"
then do:
 {itemlist.i
   &var  = "def var vgeo like cif.geo."
   &updvar  = "{imesg.i 0813} update vgeo."
   &where = "cif.geo begins vgeo"
   &frame = "row 2 centered scroll 1 15 down overlay
             top-only title "" Select from List "" "
   &index = "geo"
   &chkey = "cif"
   &chtype = "string"
   &file = "cif"
   &flddisp = "cif.cif trim(trim(cif.prefix) + ' ' + trim(cif.sname)) @ cif.sname cif.pss cif.tel cif.geo"
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

else if vselect eq "J"
then do:
 {itemlist.i
   &var  = "def var vnam like cif.jame."
   &updvar  = "{imesg.i 2808} update vnam."
   &where = "cif.jame ge vnam"
   &frame = "row 2 scroll 1 15 down overlay
             top-only title "" Select from List "" "
   &index = "jame"
   &chkey = "cif"
   &chtype = "string"
   &file = "cif"
   &flddisp = "cif.cif trim(trim(cif.prefix) + ' ' + trim(cif.name)) @ cif.name format ""x(20)"" cif.pss format ""x(9)""
               cif.jame  format ""x(20)"" cif.jss format ""x(9)"""
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
else if vselect eq "P"
then do:
 {itemlist.i
   &var  = "def var vss like cif.pss."
   &updvar  = "{imesg.i 2805} update vss."
   &where = "cif.jss begins vss "
   &frame = "row 2  scroll 1 15 down overlay
             top-only title "" Select from List "" "
   &index = "jss"
   &chkey = "cif"
   &chtype = "string"
   &file = "cif"
   &flddisp = "cif.cif trim(trim(cif.prefix) + ' ' + trim(cif.sname)) @ cif.sname format ""x(20)"" cif.pss format ""x(9)""
               cif.jame format ""x(20)"" cif.jss  format ""x(9)"""
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
