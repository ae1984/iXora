/* 2lmon.p
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

/*отчет по платежам  очереди 2L  */
{get-dep.i} 

define temp-table rep
field cdep as char format 'x(10)' label "RMZ"
field l-cnt as int init 0 format "999" label "к-во"
field l-acc like aaa.aaa format 'x(9)' label "Счет получ."
field l-acc2 like aaa.aaa format 'x(9)' label "Счет отправ."
field l-crc like remtrz.tcrc label 'Валюта'
field l-rem as char label 'Назнач. платежа'
field l-sum as deci format '>>>>>>>>9.99' init 0.0 label "2L:  сумма"
index cdep is unique primary cdep.
def var i as int init 0.
def var dep as char.
&scoped-define L que.pid begins "2l" 
define button brnew.
define button bprit.
define button bexit.

def frame totf with no-labels /*centered*/ row 19 overlay.
define frame ctrlf 
brnew label "Обновить"
bprit label "Печать"
bexit label "Выход"
with no-box centered row 22 overlay.

def var v-name like cif.fname.
def var v-sub as int.
on choose of brnew in frame ctrlf do:
for each rep: delete rep. end.

for each que where {&L} no-lock :
create rep. 
cdep = que.remtrz. l-cnt = 1.  
find remtrz where remtrz.remtrz = que.remtrz.
l-sum = remtrz.amt. l-acc = remtrz.sacc. 
l-crc = remtrz.tcrc.  l-acc2 = remtrz.racc. 
l-rem = trim(remtrz.detpay[1]) + trim(remtrz.detpay[2]) + trim(remtrz.detpay[3]) .  
end.
/*for each rep: displ rep. end. pause. */

for each rep  break by l-acc2 :
accumulate l-sum (total).
accumulate l-cnt (total).

displ skip(1)  
cdep format 'x(11)' label ' RMZ'
 string(l-acc) format "x(9)" label "Счет отправ." 
 string(l-acc2) format "x(9)" label "Счет получ."
l-crc format 'zz' label '   Валюта' string(l-sum , ">>,>>,>>>,>>9.99") 
format "x(17)" label "       Сумма"  
l-rem format 'x(60)' label '   Назначение платежа' with 13  down frame  repf.
end.
pause 0.

displ "Итого" format "x(24)"
string(accum total rep.l-sum, ">,>>>,>>>,>>9.99") + '/' + string(accum total rep.l-cnt) format "x(25)" with frame totf. 
pause 0.
end.

on choose of bexit in frame ctrlf do:
    apply "window-close" to CURRENT-WINDOW.
end.

/*on choose of bprit in frame ctrlf do:
apply "choose" to brnew.
output to rpt.img.
put unformatted "                    Отчет о и исходящих платежей." skip
today skip
string(time, "HH:MM:SS") skip "Исполнитель: " userid skip(1).
put unformatted  fill("-", 80) skip
"|     Подразделение      |  2L сумма/к-во   |      Всего      |" skip fill("-", 80) skip.
for each rep:
accumulate l-sum (total).
accumulate l-cnt (total).
put "|"
cdep format "x(24)" "|"
string(2l-sum, ">>>>>>>>>9.99") + '/' + string(2l-cnt)
format "x(17)" "|"
string(2l-sum , ">>>>>>>>>9.99") + '/' + string(2l-cnt )
format "x(17)" "|"skip.
end.
put unformatted fill("-", 80) skip "|" "Итого" format "x(24)" "|"
string(accum total 2l-sum, ">>>>>>>>>9.99") + '/' + string(accum total 2l-cnt)
format "x(17)" "|"
string(accum total 2l-sum , ">>>>>>>>>9.99") + '/' +
string(accum total 2l-cnt )
format "x(17)" "|" skip fill("-", 80).
output close.
unix silent prit rpt.img.
end.*/

enable all with frame ctrlf.
apply "choose" to brnew.
WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.
