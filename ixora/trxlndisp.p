/* trxlndisp.p
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
        04/12/08 marinav - увеличение формы для IBAN
*/

def input parameter vcode as char.
def var iii as inte.
{trxtmpl1.f}
    iii = 0.
    clear frame trxtmpl1 all.
for each trxtmpl where trxtmpl.code = vcode no-lock.
    iii = iii + 1.
    if iii > vdown then leave.
    disp trxtmpl.ln trxtmpl.amt trxtmpl.amt-f 
         trxtmpl.crc trxtmpl.crc-f 
         trxtmpl.rate trxtmpl.rate-f  
         trxtmpl.drgl trxtmpl.drgl-f
         trxtmpl.drsub trxtmpl.drsub-f 
         trxtmpl.dev trxtmpl.dev-f 
         trxtmpl.dracc trxtmpl.dracc-f
         trxtmpl.crgl trxtmpl.crgl-f 
         trxtmpl.crsub trxtmpl.crsub-f
         trxtmpl.cev trxtmpl.cev-f 
         trxtmpl.cracc trxtmpl.cracc-f
         with frame trxtmpl1.
    color disp input trxtmpl.amt-f trxtmpl.crc-f trxtmpl.rate-f trxtmpl.drgl-f
                     trxtmpl.drsub-f trxtmpl.dev-f trxtmpl.dracc-f
                     trxtmpl.crgl-f trxtmpl.crsub-f trxtmpl.cev-f 
                     trxtmpl.cracc-f
         with frame trxtmpl1.
      
if trxtmpl.amt-f = "r" then color disp messages trxtmpl.amt with frame trxtmpl1.
if trxtmpl.crc-f = "r" then color disp messages trxtmpl.crc with frame trxtmpl1.
if trxtmpl.rate-f = "r" then color disp messages trxtmpl.rate with frame trxtmpl1.
if trxtmpl.drgl-f = "r" then color disp messages trxtmpl.drgl with frame trxtmpl1.
if trxtmpl.drsub-f = "r" then color disp messages trxtmpl.drsub with frame trxtmpl1.
if trxtmpl.dracc-f = "r" then color disp messages trxtmpl.dracc with frame trxtmpl1.
if trxtmpl.crgl-f = "r" then color disp messages trxtmpl.crgl with frame trxtmpl1.
if trxtmpl.crsub-f = "r" then color disp messages trxtmpl.crsub with frame trxtmpl1.
if trxtmpl.cracc-f = "r" then color disp messages trxtmpl.cracc with frame trxtmpl1.
         
    down with frame trxtmpl1.
end.

