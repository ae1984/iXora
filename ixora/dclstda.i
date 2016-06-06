/* dclstda.i
 * MODULE
        Закрытие опердня
 * DESCRIPTION
        Начисление процентов по депозитам TDA
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        
 * AUTHOR
        01.01.1999 pragma
 * CHANGES
        01.08.2003 nadejda - оптимизация циклов для использования индексов
        20.05.2004 nadejda - добавлен параметр номера счета в вызов tdagetrate
*/

def var v-weekbeg as int.
def var v-weekend as int.
def var currate like aaa.rate.
def var v-brate like aaa.rate.

find sysc "bsrate" no-lock no-error.
if available sysc then v-brate = sysc.deval. else v-brate = 2.

find sysc "WKEND" no-lock no-error.
if available sysc then v-weekend = sysc.inval. else v-weekend = 6.
find sysc "WKSTRT" no-lock no-error.
if available sysc then v-weekbeg = sysc.inval. else v-weekbeg = 2.

Function EventInRange returns date (input event as char,
                                    input vdat1 as date,
                                    input vdat2 as date).
def var curdate as date.
def var e-fire as logi.
curdate = vdat1.
repeat:
/*  run EventHandler(event, curdate, aaa.lstmdt, aaa.expdt - 1, output e-fire). */
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
 if aaa.sta <> "M" then do:
    run tdagetrate(aaa.aaa, aaa.pri, aaa.cla, aaa.nextint, intbase, output currate).
    return currate.
 end.
 else 
 do:
    /* Ставка до востребования своя для каждой валюты */
    if aaa.crc = 1 then do:
       find sysc "ratekz" no-lock no-error.
       if available sysc then v-brate = sysc.deval.  
    end. else
    if aaa.crc = 2 then do:
       find sysc "rateus" no-lock no-error.
       if available sysc then v-brate = sysc.deval.
    end. else
    if aaa.crc = 11 then do:
       find sysc "rateeu" no-lock no-error.
       if available sysc then v-brate = sysc.deval.
    end.
    return v-brate.
 end.
End Function.
