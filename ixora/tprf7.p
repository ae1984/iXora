/* tprf7.p
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

/* 
   KOVAL
   Транзакции по счетам главной книги по счету 255120 и суммы
   по очередям STW ST2 V2
   20.11.2002

*/

{global.i}
{functions-def.i}

define var fdt as date.
define var tdt as date.
define var vgl like gl.gl init 255120.
define var vcrc like crc.crc init 1.
define var vtitle2 as char form "x(132)".
define var vwho like jl.who.
define var vcif like cif.cif.
define var vst  like jl.dam.
define var ven  like jl.dam.
define var ven1  like jl.dam.
define var vlog as log init false.
define variable dag as date.
def var sumST2 like remtrz.amt.
def var sumV2 like remtrz.amt.
def var iST2 as int.
def var iV2 as int.

fdt = g-today.
update "Дата: " fdt no-label with centered frame d.
tdt=fdt.

hide message no-pause.
message "Определение исходящего остатка по счету " + string(vgl) .

find gl where gl.gl eq vgl no-lock no-error.
for each jl no-lock where jl.jdt eq fdt and  
                          jl.crc eq vcrc use-index jdt,
    each gl no-lock where gl.gl eq jl.gl and  
                         (gl.gl eq vgl or vgl eq 0),
    jh no-lock where jh.jh eq jl.jh
               break by gl.gl by jl.jdt by jl.dam by jl.cam by jl.jh by jl.ln:

    /* Расчет НАЧАЛЬНОГО БАЛАНСА */
    if first-of(gl.gl) then do:
       if gl.type eq "A" or gl.type eq "E" then
          vlog = true.
       else
          vlog = false.

       find last glday where glday.gdt lt fdt 
                        and  glday.gl  eq gl.gl
                        and  glday.crc eq vcrc
                        no-lock no-error.

       if available glday then do:
            if (gl.type eq "R" or gl.type eq "E") and year(fdt) ne year(glday.gdt) then vst = 0.
            else do:
              if vlog eq true 
              	then vst = glday.dam - glday.cam.
              	else vst = glday.cam - glday.dam.
            end.
       end.
      
       ven = vst. /* vst - НАЧАЛЬНЫЙ БАЛАНС */

    end. /* РАСЧЕТ НАЧАЛЬНОГО БАЛАНСА */

      if vlog eq true then ven = ven + jl.dam - jl.cam.
		      else ven = ven - jl.dam + jl.cam.

      accumulate jl.dam (total by jl.jdt) jl.cam (total by jl.jdt).

     ven1 = ven.
     if tdt ne g-today then do:
	     find last glday where glday.gdt le tdt and  glday.gl eq gl.gl
	     and glday.crc eq vcrc no-lock no-error.
	     if available glday then do:
	        if vlog eq true then ven1 = glday.dam - glday.cam.
	        	   else ven1 = glday.cam - glday.dam.
	        if gl.type eq "R" or gl.type eq "E" then do:
        	if year(glday.gdt) ne year(tdt) then ven1 = 0.
	     end.
     end.  
     else ven1 = 0.


     /* ven - КОНЕЧНЫЙ БАЛАНС  at 40 ven ne ven1 format    */


    end.
end. /* for each jl */

hide message no-pause.
message "Определение остатков по очередям ".

sumST2 = 0. sumV2 = 0.
iST2   = 0. iV2   = 0.
for each que where que.pid = "ST2" and que.con ne "F" no-lock use-index fprc.
   find remtrz where remtrz.remtrz = que.remtrz no-lock no-error.
   if avail remtrz then assign sumST2 = sumST2 + remtrz.amt iST2 = iST2 + 1.
end.

for each que where que.pid = "V2" and que.con ne "F" no-lock use-index fprc.
   find remtrz where remtrz.remtrz = que.remtrz no-lock no-error.
   if avail remtrz then assign sumV2 = sumV2 + remtrz.amt iV2 = iV2 + 1.
end.

output to rptdcls.img.

put unformatted 
FirstLine(1,1) skip 
FirstLine(2,1) skip(1) 
"Отчет на " string(fdt,"99/99/99") skip(1)
" Конечный баланс на " string(vgl,"999999") " :" string(ven,'z,zzz,zzz,zzz,zz9.99-') ven ne ven1 format "***/   " skip(1)
" Сумма на очереди ST2      :" string(sumST2,'z,zzz,zzz,zzz,zz9.99-') ", " string(iST2,">>>>9") " платежей" skip
" Сумма на очереди V2       :" string(sumV2,'z,zzz,zzz,zzz,zz9.99-') ", " string(iV2,">>>>9") " платежей" skip
" Сумма на очереди ST2 + V2 :" string(sumST2 + sumV2,'z,zzz,zzz,zzz,zz9.99-') ", " string(iV2 + iST2,">>>>9") " платежей" skip(1)
if (sumV2 + sumST2) <> ven then " Внимание ! Сумма на счете ГК не совпадает с суммой на очередях V2 и ST2." else ""
skip
.

output close.
pause 0.

run menu-prt("rptdcls.img"). 
pause 0.

hide message no-pause.
