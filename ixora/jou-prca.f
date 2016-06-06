/* jou-prca.f
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

/* 01.10.02 nadejda - наименование клиента заменено на форма собств + наименование */

def shared var v-point like point.point.

def var vi as inte.
def var ss as inte.

find point where point.point = v-point no-lock no-error.


find first cmp.
put skip(3)
"============================================================================="
skip
    cmp.name "Кассовый Операционный Ордер"
jh.jdt " " string(time,"HH:MM") "   * " jh.who skip
point.addr[1] skip.
if point.addr[2] <> " " then put point.addr[2] skip.
if point.addr[3] <> " " then put point.addr[3] skip.
put point.regno skip point.licno space(14) "Документ N " d_n skip
" " jh.jh " " jh.cif " " jh.party  skip
"============================================================================="
.

find sysc where sysc.sysc = "CASHGL".

for each jl of jh use-index jhln where jl.gl = sysc.inval no-lock
                                                      break by jl.crc :
   find crc of jl no-lock.
   if jl.dam gt 0 then do: 
      xin = jl.dam. 
      xout = 0. 
      intot = intot + xin. 
   end.
   else do:
      xin = 0. 
      xout = jl.cam.  
      outtot = outtot + xout. 
   end.
   disp crc.des label "ВАЛЮТА  "
        xin (sub-total by jl.crc)
        xout(sub-total by jl.crc)
        with  no-box down frame inout .
end.
put
"============================================================================="
skip.

for each jl of jh where jl.ln = 1 use-index jhln break by jl.crc by jl.ln:
   if trim(jl.rem[1] + jl.rem[2] + jl.rem[3] + jl.rem[4] + jl.rem[5]) ne "" then
      do vi = 1 to 5 :
    
      if vi = 1 then do:
         ss = 1.
         repeat:
            if (trim(substring(jl.rem[vi],ss,60)) ne "" ) then
              put "     " trim(substring(jl.rem[vi],ss,60)) format "x(60)"                                                                  skip(0).
            else leave.
            ss = ss + 60.
         end.       
      
         /* arp ili cif */
         for each wf:
            if wf.wsub eq "cif" then do:
               find cif where cif.cif eq wf.wcif no-lock.
               put unformatted "     " wf.wacc " " trim(trim(cif.prefix) + " " + trim(cif.name)) format "x(30)" " " cif.jss skip.
            end.
            else if wf.wsub eq "arp" then do:
               find arp where arp.arp eq wf.wacc no-lock.
               find sub-cod where sub-cod.d-cod eq "arprnn" and
                                 sub-cod.acc eq wf.wacc no-lock no-error.
               if available sub-cod then put unformatted
                  "     " wf.wacc " " arp.des " " sub-cod.rcode skip.
               else put unformatted "     " wf.wacc " " arp.des skip.
            end.
         end.
      end.
      else if (trim(jl.rem[vi]) ne "" ) then
                   put "     " trim(jl.rem[vi]) format "x(70)" skip(0).
   end.
   else do:
      /* arp ili cif */
      for each wf:
         if wf.wsub eq "cif" then do:
            find cif where cif.cif eq wf.wcif no-lock.
            put unformatted "     " wf.wacc " " trim(trim(cif.prefix) + " " + trim(cif.name)) format "x(30)" " " cif.jss skip.
         end.
         else if wf.wsub eq "arp" then do:
            find arp where arp.arp eq wf.wacc no-lock.
            find sub-cod where sub-cod.d-cod eq "arprnn" and
                                sub-cod.acc eq wf.wacc no-lock no-error.
            if available sub-cod then put unformatted
               "     " wf.wacc " " arp.des " " sub-cod.rcode skip.
            else put unformatted "     " wf.wacc " " arp.des skip.
         end.
      end.
   end.
end.



put
skip
"============================================================================="
skip(2).
pause 0.

/*********
put 
"Клиент ................ Менеджер ................ Контролер ................"
skip(1).

put 
"Кассир ................" skip(15).
***************/
