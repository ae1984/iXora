/* dcls_luks.i
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
        29.11.2005 dpuchkov
 * CHANGES
*/

def var v-weekbeg as int.
def var v-weekend as int.
def var currate like aaa.rate.
def var v-brate like aaa.rate.
def buffer ddd for sysc.
def buffer bbbjl for jl.

find sysc "bsrate" no-lock no-error.
if available sysc then v-brate = sysc.deval. else v-brate = 2.

find sysc "WKEND" no-lock no-error.
if available sysc then v-weekend = sysc.inval. else v-weekend = 6.
find sysc "WKSTRT" no-lock no-error.
if available sysc then v-weekbeg = sysc.inval. else v-weekbeg = 2.





Function EventInRange returns date (input event as char, input vdat1 as date, input vdat2 as date).
def var curdate as date.
def var e-fire as logi.
curdate = vdat1.
repeat:
  run EventHandler(event, curdate, date(acvolt.x1), date(acvolt.x3) - 1, output e-fire).
  if e-fire then do:
     return curdate.
  end.
  curdate = curdate + 1.
  if curdate > vdat2 then return ?.   
end.        
End Function.





Function IntBase returns decimal.
find aas where aas.aaa = aaa.aaa and aas.ln = 7777777 no-lock no-error.
 if available aas then return aas.chkamt.
 else return 0.0.
End Function.




Function GetRate returns decimal (input intbase as decimal).
    run tdagetrate(aaa.aaa, aaa.pri, aaa.cla, aaa.nextint, intbase, output currate).
    return currate.
End Function.
















