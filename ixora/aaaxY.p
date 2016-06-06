/* aaaxY.p
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
*/

/* aaaxY.p from aaaxdc.p  Coded client account turnovers and balance */
/*                        Started 31/07/1998; Last Mo: 03/08/1998    */
/* For Use Only on Acrhive Database aplaton  */
/* {mainhead.i} */

def var g-today as date format "99/99/9999".
find last cls no-lock. g-today = cls.cls + 1.

def var svitra as char format "X(110)".
svitra = fill("-",110).
def var i as int. def var ok as log init no.
def var dat1 as date format "99/99/9999" label "No".
def var dat2 as date format "99/99/9999" label "Lidz".
def var comprt as char label "VIEW/PRINT BY" initial "joe  " format "x(10)" .
def var vbal like aab.bal.
def var odxt like aab.bal.
def var ocxt like aab.bal.
def var odx like aab.bal.
def var ocx like aab.bal.
def stream m-out.  def var yescif like cif.cif.
dat2 = g-today.
do while month(dat2 + 1) eq month(dat2):
dat2 = dat2 - 1.
end.
dat1 = dat2.
do while month(dat1 - 1) eq month(dat1):
dat1 = dat1 - 1.
end.

define temp-table ATA field aaa like aaa.aaa
                      field od as deci format "->,>>>,>>>,>>>,>>>,>>9.99"
                      field oc as deci format "->,>>>,>>>,>>>,>>>,>>9.99"
                      field bal as deci format "->,>>>,>>>,>>>,>>>,>>9.99".

define temp-table ACRC field crc like crc.crc
                       field od as deci format "->,>>>,>>>,>>>,>>>,>>9.99"
                       field oc as deci format "->,>>>,>>>,>>>,>>>,>>9.99"
                       field bal as deci format "->,>>>,>>>,>>>,>>>,>>9.99". 
       update dat1 validate(dat1 <= g-today , "") 
       dat2 validate(dat2 <= g-today,"")
       comprt with 1 column side-label centered .

disp "W a i t ..." with frame qq centered.
pause 0.        
output stream m-out to rpt.img .  

put stream m-out skip space(20) "X klientu kontu apgrozijumi un atlikumi" format "X(50)".
put stream m-out skip space (26) "no " string(dat1,"99/99/9999") format "X(10)" " lidz " string(dat2,"99/99/9999") format "X(10)" skip.
 


put stream m-out svitra format "X(120)" skip.
put stream m-out 
"Klients:  Konts  :S: Val :     Debeta apgrozijums     :    Kredita apgrozijums :        Atlikums        :" 
skip.
put stream m-out svitra skip.
for each cif where cif.type eq "X" no-lock:
odxt = 0.
ocxt = 0.
find first aaa of cif no-lock no-error.
    
    repeat while available aaa:
    odx = 0. ocx = 0.
        for each jl where jl.acc eq aaa.aaa 
        and jl.jdt >=dat1 and jl.jdt <=dat2 no-lock:
        odx = odx + jl.dam.
        ocx = ocx + jl.cam.
        end.  /* for each jl */
        find last aab where aab.aaa eq aaa.aaa and aab.fdt <= dat2 no-lock
        no-error.
        if available aab then vbal = aab.bal. else vbal = 0.
        
        odxt = odxt + odx. ocxt = ocxt + ocx.
        
        create ATA. ATA.aaa = aaa.aaa. 
        ATA.od = odx. ATA.oc = ocx. ATA.bal = vbal.
        
        find next aaa of cif no-lock no-error.
    end.   /* repeat aaa of cif */
  pause 0. disp cif.cif with frame qqqqq no-label centered row 10.
  if odxt ne 0 or ocxt ne 0 then do:
  yescif = cif.cif.
  put stream m-out skip(1) cif.cif at 1.
  find first aaa of cif no-lock no-error.
     repeat while available aaa: 
     find crc where crc.crc eq aaa.crc no-lock.
     find first ATA where ATA.aaa eq aaa.aaa no-lock.
     /*if (ATA.oc + ATA.od + ATA.bal) ne 0 then */ 
     put stream m-out aaa.aaa at 8 aaa.sta at 19 crc.code at 22 
     ATA.od at 30 ATA.oc at 55 ATA.bal at 80 skip.
     find first ACRC where ACRC.crc eq crc.crc no-error.
     if not available ACRC then do:
     create ACRC. ACRC.crc = crc.crc.  
     end.
     ACRC.od = ACRC.od + ATA.od.
     ACRC.oc = ACRC.oc + ATA.oc.
     ACRC.bal = ACRC.bal + ATA.bal.
     find next aaa of cif no-lock no-error.
     end.
    end.
/* pause 0. 
disp "| " yescif " |" with frame qqqq row 15 no-label centered. */ 
end. /* for each cif */

put stream m-out skip svitra.
put stream m-out skip(2) svitra format "X(85)".
put stream m-out skip
"# :VAL:    Debeta apgrozijumi   :   Kredita apgrozijumi   :             Atlikums    : ".    
put stream m-out skip svitra format "X(85)".
for each ACRC where (ACRC.od + ACRC.oc + ACRC.bal) ne 0 
no-lock break by ACRC.crc.
find crc where crc.crc eq ACRC.crc no-lock.
put stream m-out skip ACRC.crc " " crc.code " " 
ACRC.od " " ACRC.oc " " ACRC.bal.
end.

put stream m-out skip(1) svitra format "X(85)" skip.
put stream m-out "IZPILDITAJS: " at 40 userid("bank") at 60 skip.
put stream m-out "Datums: " at 40 string(g-today,"99/99/9999") format "X(10)" 
" Laiks: " string(time,"HH:MM:SS") .

pause 0 .
output stream m-out close .
clear frame qq all.
unix value(comprt + " rpt.img").
pause 0 .
