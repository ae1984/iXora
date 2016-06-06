/* cif-npr.p
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
         25/09/2008 galina - перекомпиляция в спвязи с изменениями cif-npr.f
*/

/* r-aaatrc.p     09/12/93 AGA печать открытых счетов     */
/*  ACCOUNT STATEMENT */

def buffer b-aaa for aaa.
def buffer b-cif for cif.
def var s-aaa like aaa.aaa.

def shared var s-cif like cif.cif.
def shared var g-comp as char.
def shared var g-today as date.
{cif-npr.f}.


find first b-cif where b-cif.cif = s-cif.
 output to rpt.img page-size 0.

display  CHR(18) +
         g-comp format "x(50)" ci2 string(time,"HH:MM:SS")
         skip(0) with no-label
         no-underline width 130  /*frame comp*/.
display  ci3 format "x(40)"  "      " ci4 string(g-today)
          skip(0) with width 130 .
display  "======================================================"
         format "x(65)" skip(0).



disp
        ci5  b-cif.cif  
        substr(trim(trim(b-cif.prefix) + " " + trim(b-cif.name)),1,60) format "x(60)" skip(0)
        "              " 
        substr(trim(trim(b-cif.prefix) + " " + trim(b-cif.name)),61) format "x(60)" skip(0)
        "       "  trim(b-cif.addr[1]) format "x(30)"  "  РЕГ. "
        trim(b-cif.jss) format "x(13)"  skip(0)
        "       "  trim(b-cif.addr[2]) format "x(30)" skip(0)
        "       "  trim(b-cif.addr[3]) format "x(30)" skip(1)
        with no-label no-underline width 130 /* frame cust */.


for each aaa where aaa.cif = s-cif no-lock by aaa.aaa:
   find crc where crc.crc  EQ aaa.crc.
   if aaa.sta EQ "C" then
      put ci6 string(aaa.cltdt) " " ci7 at 18 aaa.aaa " " 
          crc.code " " crc.des skip(1).
   else
      put "        " ci7 at 18 aaa.aaa " " crc.code " " crc.des skip(1).

end.   /* for each aaa    */
disp  "=================" + ci8 + "=================="
       skip(15)
       with frame fg.
pause 0.
output close.

unix silent prit  rpt.img.
/*unix silent less rpt.img.          */
return.
