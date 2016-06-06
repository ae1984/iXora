/* jl-prcdl.f
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
        24.05.2004 nadejda - убран логин офицера из распечатки
*/

/** jl-prcd.f **/


def shared var v-point like point.point.

def var vi as inte.
def var ss as inte.

find point where point.point = v-point no-lock no-error.
find sysc where sysc.sysc = "CASHGL" no-lock no-error.
find ofc where ofc.ofc = jh.who no-lock no-error.

sxin = 0.
sxout = 0.

for each ljl of jh use-index jhln where ljl.gl = sysc.inval no-lock
    break by ljl.crc by ljl.dc:

    if first-of(ljl.dc) then do:
       if ljl.dc eq "D" then do:
          put skip(3) space(20) "ПРИХОДНЫЙ КАССОВЫЙ ОРДЕР" skip(2).
       end.
       else if ljl.dc eq "C" then do:
          put skip(3) space(20) "РАСХОДНЫЙ КАССОВЫЙ ОРДЕР" skip(2).
       end.
       v-margin = string (jh.jh) + "/" + v_doc + "/" + vv-cif + "/" + 
          "Dok.Nr." + trim(refn) + "/" + ofc.name.
       if length(v-margin) gt 68 then 
       v-margin = substring(v-margin,1,68) + " " + string(dtreg, "99/99/9999").
       else v-margin = v-margin + fill(" ",67 - length(v-margin))
       + string(dtreg, "99/99/9999").
       put unformatted v-margin
        skip.
 
       put
"============================================================================="
                                                         skip(1).
       put 
    "ВАЛЮТА                                      ПРИХОД                РАСХОД"
                                         skip.
       put unformatted fill ("-", 77) skip.    
    end.
    
    find crc of ljl.
    if ljl.dam gt 0 then do: 
        xin = ljl.dam. 
        xout = 0. 
        intot = intot + xin. 
    end.
    else do:
        xin = 0. 
        xout = ljl.cam.  
        outtot = outtot + xout. 
    end.  
    
    put crc.des xin xout skip.    
         
    sxin = sxin + xin.
    sxout = sxout + xout.     
        
    if last-of(ljl.dc) then do:    
       if ljl.dc eq "D" then put unformatted skip(1)
          space(22) "ИТОГО ПРИХОД" sxin format "z,zzz,zzz,zz9.99" skip(2).
       else if ljl.dc eq "C" then put unformatted skip(1)
          space(43) "ИТОГО РАСХОД" sxout format "z,zzz,zzz,zz9.99" skip(2).

       put drek[1] format "x(75)" skip(2).
        
       if ljl.dc eq "D" and length (trim (drek[2])) ne 0 then put drek[2] skip.
       else if ljl.dc eq "C" and length (trim (drek[3])) ne 0 then 
             put drek[3] skip.
       drek[4] = trim(drek[4]).
       v-margin = "".
       do while length(drek[4]) ne 0:
        if length(v-margin) eq 0 then 
        put unformatted substring(drek[4],1,60) skip.
        else do:
            put v-margin format "x(8)".
            put unformatted substring(drek[4],1,60 - length(v-margin))
            skip.
        end.
        if length(drek[4]) gt 60 - length(v-margin)
        then drek[4] = substring(drek[4],60 - length(v-margin) + 1).
        else drek[4] = "".
        v-margin = fill(" ",8).
       end.
       if length (trim (drek[5])) ne 0 then put drek[5] skip.
       if length (trim (drek[6])) ne 0 then put drek[6] .
       put skip(1).

put
"============================================================================="
skip(1).

       for each remfile:
          put unformatted remfile.rem skip.
       end.
    end.

    if last-of (ljl.crc) then do:
       sxin = 0.   sxout = 0.
    end.
end.
put skip(5).

