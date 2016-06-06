/* lbmon.p
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

/*добавлена информация по Интернет-платежам из РКО-1 и РКО-3  */

{get-dep.i} 
{global.i}
define temp-table rep
  field cdep as char format 'x(25)' label "Подразделение"
  field depnamelong as char format 'x(25)'
  field depnameshort as char format 'x(14)'
  field lb-cnt as int init 0 format "9999" label "к-во"
  field lb-sum as deci format '>>>,>>>,>>9.99' init 0.0 label "LB:  сумма"
  field lbg-cnt as int init 0 format "9999" label "к-во"
  field lbg-sum as deci format '>>>,>>>,>>9.99' init 0.0 label "LBG: сумма"
  index cdep is unique primary cdep.

define new shared temp-table lbrep
  field cdep as char format 'x(25)'
  field depnamelong as char format 'x(25)' label "Подразделение"
  field depnameshort as char format 'x(14)'.

def var dep as char.
&scoped-define LB que.pid = "LB" or que.pid begins "LB-"
&scoped-define LBG que.pid begins "LBG"
define button brnew.
define button bprit.
define button bexit.
define button brems.
define button bmail.
define frame totf with no-labels centered row 19 overlay.
define frame ctrlf 
brnew label "Обновить"
bprit label "Печать"
brems label "Платежи"
bexit label "Выход"
bmail label "         Почта"
with no-box centered row 22 overlay.
define variable v-fname as character format "x(16)".
def var v-name like cif.fname.
def var v-sub as int.
v-fname = 'c:\plat.txt'.
def var priz as int.
find first clrdoc where clrdoc.rdt = g-today no-lock no-error.
if avail clrdoc then 
  select max(pr) into priz from  clrdoc where clrdoc.rdt = g-today.
else 
  priz = 0.
v-fname = 'c:\pl' + substr(string(g-today),1,2) + substr(string(g-today),4,2) +
string(priz + 1) + '.txt'.

def var i as int.      
def var c as char.
def var v-dep as integer.

on choose of brnew in frame ctrlf do:
  for each rep: delete rep. end.
  for each ppoint no-lock:
      create rep.
      assign cdep = string(ppoint.depart).
      assign depnamelong = ppoint.name.
      assign depnameshort = ppoint.name.
  end.
  for each bankl where bank begins "TXB" and bank <> "TXB00" no-lock:
      create rep.
      assign cdep = bank.

      c = trim(bankl.name).
      i = index(c,"АО").
      c = substring(c, 1, i - 1) + substring(c, i + 17).
      assign depnamelong = c.

      i = index(c,"г.").
      c = substring(c, 1, i - 1) + substring(c, i + 2).
      assign depnameshort = c.
  end.
        
create rep.
rep.cdep = 'I1'.
rep.depnamelong = 'Интернет-офис'.
rep.depnameshort = 'Интернет-офис'.

create rep. 
rep.cdep = "I2". 
rep.depnamelong = 'Интернет-офис ("Меркур")'.
rep.depnameshort = 'Инет-"Меркур"'.

create rep. 
rep.cdep = "I3". 
rep.depnamelong = 'Интернет-офис ("Реиз")'.
rep.depnameshort = 'Инет-"Реиз"'.

create rep. 
rep.cdep = "I4".
rep.depnamelong = 'Интернет-офис ("Самал")'.
rep.depnameshort = 'Инет-"Самал"'.

def var v-aaa as int.
for each que where {&LB} or {&LBG} 
no-lock:
    find first remtrz where remtrz.remtrz = que.remtrz no-lock no-error.
    if avail remtrz then do:
      if source = "IBH" then do:
        find first aaa where aaa.aaa = dracc.
        find first cif where cif.cif = aaa.cif.

        if cif.fname = '' then do:
          if cif.jame <> '' then
            v-dep = integer(cif.jame) mod 1000.
          else 
            v-dep = get-dep('superman', remtrz.rdt).
        end.
        else do:
          v-name = trim(substr(trim(cif.fname),1,8)).
          v-dep = get-dep(v-name, remtrz.rdt).
        end.
      
        dep = "I" + string(v-dep).
      end.  /* end-of do*/
      else if sbank begins "TXB" and sbank <> "TXB00" then
         dep = sbank.
      else do:
        find first ppoint where ppoint.depart = get-dep(rwho, rdt) no-lock no-error.
        if not avail ppoint then displ rwho get-dep(rwho, rdt).
        dep = string(ppoint.depart).
      end.

      find first rep where cdep = dep exclusive-lock no-error.
      if {&LB} then assign
          lb-cnt = lb-cnt + 1
          lb-sum = lb-sum + remtrz.amt.
      if {&LBG} then assign
          lbg-cnt = lbg-cnt + 1
          lbg-sum = lbg-sum + remtrz.amt.
    end.
end.

for each rep where (lb-cnt > 0 or lbg-cnt > 0) :
  accumulate lb-sum (total).
  accumulate lb-cnt (total).
  accumulate lbg-sum (total).
  accumulate lbg-cnt (total).
  accumulate lb-sum + lbg-sum (total).
  accumulate lb-cnt + lbg-cnt (total).

  displ 
    rep.depnameshort  format 'x(14)' label "Подразделение"
    string(lb-sum, ">,>>>,>>>,>>9.99") + '/' + string(lb-cnt)
    format "x(21)" label "      LB   сумма/к-во" at 16
    string(lbg-sum, ">,>>>,>>>,>>9.99") + '/' + string(lbg-cnt)
    format "x(21)" label "     LBG   сумма/к-во"at 37
    string(lb-sum + lbg-sum, ">,>>>,>>>,>>9.99") + '/' + string(lb-cnt + lbg-cnt)
    format "x(21)" label "   ВСЕГО   сумма/к-во" at 58 with 14 down frame repf.
end.

pause 0.

displ "Итого" format "x(14)"
string(accum total lb-sum, ">,>>>,>>>,>>9.99") + '/' + string(accum total lb-cnt) 
format "x(21)" at 16
string(accum total lbg-sum, ">,>>>,>>>,>>9.99") + '/' + string(accum total lbg-cnt)
format "x(21)" at 37
string(accum total lb-sum + lbg-sum, ">,>>>,>>>,>>9.99") + '/' + 
string(accum total lb-cnt + lbg-cnt)
format "x(21)" at 58
with frame totf.
pause 0.
end.


on choose of brems in frame ctrlf do:
   for each lbrep: delete lbrep. end.
   for each rep where (lb-cnt > 0 or lbg-cnt > 0):
     create lbrep.
     lbrep.cdep = rep.cdep.
     lbrep.depnamelong = rep.depnamelong.
     lbrep.depnameshort = rep.depnameshort.
   end.
   run lbmon1.
end.

on choose of bexit in frame ctrlf do:
    apply "window-close" to CURRENT-WINDOW.
end.

on choose of bprit in frame ctrlf do:
apply "choose" to brnew.
output to rpt.img.
put unformatted "                    Отчет о состоянии исходящих платежей." skip
today skip
string(time, "HH:MM:SS") skip "Исполнитель: " userid skip(1).
put unformatted  fill("-", 93) skip
"|     Подразделение       |     LB    сумма/к-во|    LBG    сумма/к-во|    ВСЕГО  сумма/к-во|" skip fill("-", 93) skip.

for each rep  where (lb-cnt > 0 or lbg-cnt > 0):
accumulate lb-sum (total).
accumulate lb-cnt (total).
accumulate lbg-sum (total).
accumulate lbg-cnt (total).
accumulate lb-sum + lbg-sum (total).
accumulate lb-cnt + lbg-cnt (total).

put "|"
depnamelong format "x(25)" "|"
string(lb-sum, ">,>>>,>>>,>>9.99") + '/' + string(lb-cnt)
format "x(21)" "|"
string(lbg-sum, ">,>>>,>>>,>>9.99") + '/' + string(lbg-cnt)
format "x(21)" "|"
string(lb-sum + lbg-sum, ">,>>>,>>>,>>9.99") + '/' + string(lb-cnt + lbg-cnt)
format "x(21)" "|"skip.
end.
put unformatted fill("-", 93) skip "|" "Итого" format "x(25)" "|"
string(accum total lb-sum, ">,>>>,>>>,>>9.99") + '/' + string(accum total lb-cnt)
format "x(21)" "|"
string(accum total lbg-sum, ">,>>>,>>>,>>9.99") + '/' + string(accum total lbg-cnt)
format "x(21)" "|"
string(accum total lb-sum + lbg-sum, ">,>>>,>>>,>>9.99") + '/' +
string(accum total lb-cnt + lbg-cnt)
format "x(21)" "|" skip fill("-", 93).
output close.
/* unix silent prit rpt.img. */
run menu-prt ('rpt.img').
end.

on choose of bmail in frame ctrlf do:
  output to rpt.img.
  put unformatted "                    Отчет о состоянии исходящих платежей." skip
  today skip
  string(time, "HH:MM:SS") skip "Исполнитель: " userid skip(1).
  put unformatted  fill("-", 93) skip
  "|     Подразделение       |     LB    сумма/к-во|    LBG    сумма/к-во|    ВСЕГО  сумма/к-во|" skip fill("-", 93) skip.

  for each rep where (lb-cnt > 0 or lbg-cnt > 0):
    accumulate lb-sum (total).
    accumulate lb-cnt (total).
    accumulate lbg-sum (total).
    accumulate lbg-cnt (total).
    accumulate lb-sum + lbg-sum (total).
    accumulate lb-cnt + lbg-cnt (total).

    put "|"
      depnamelong format "x(25)" "|"
      string(lb-sum, ">,>>>,>>>,>>9.99") + '/' + string(lb-cnt)
      format "x(21)" "|"
      string(lbg-sum, ">,>>>,>>>,>>9.99") + '/' + string(lbg-cnt)
      format "x(21)" "|"
      string(lb-sum + lbg-sum, ">,>>>,>>>,>>9.99") + '/' + string(lb-cnt + lbg-cnt)
      format "x(21)" "|"skip.
  end.

  put unformatted fill("-", 93) skip "|" "Итого" format "x(25)" "|"
    string(accum total lb-sum, ">,>>>,>>>,>>9.99") + '/' + string(accum total lb-cnt)
    format "x(21)" "|"
    string(accum total lbg-sum, ">,>>>,>>>,>>9.99") + '/' + string(accum total lbg-cnt)
    format "x(21)" "|"
    string(accum total lb-sum + lbg-sum, ">,>>>,>>>,>>9.99") + '/' +
    string(accum total lb-cnt + lbg-cnt)
    format "x(21)" "|" skip fill("-", 93).
  output close.
  unix silent un-win rpt.img value(v-fname).
  run mail("gulya@elexnet.kz", 
           "TEXAKABANK <" + userid("bank") + "@elexnet.kz>", "Clearing " +
            string(today,"99.99.99"), "", "1", "", v-fname).


end.

enable all with frame ctrlf.
apply "choose" to brnew.
WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.

