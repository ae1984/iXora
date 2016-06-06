/* debost4.p
 * MODULE
        Дебиторы
 * DESCRIPTION
        Суммарные остатки по срокам на АРП карточках дебиторов
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
	debost-get.p
 * MENU
        8-3-2-5
 * AUTHOR
        19/05/04 sasco
 * CHANGES
        19/05/04 sasco добавил вывод счета Г/К
        03/11/04 tsoy добавил поле в таблицу wrk
        16/08/05 marinav добавлен фактический срок
	10/05/06 u00121 - добавил индекс во временную таблицу wjh - формирование отчета сократилось с ~40 минут до ~ 1 минуты 
			- Добавил опцию no-undo в описание переменных и временных таблиц
*/

{debls.f}

def shared var g-today as date.

def var vlen as int  init 54 no-undo.
def var slen as char init "54" no-undo.
def var grpost as decimal init 0.0 no-undo.

def temp-table wrkgrp no-undo
         field grp  like debls.grp          label "GRP"
         field ls   like debls.ls           label "NN"
         field arp  like debgrp.arp.

define new shared temp-table wrk no-undo
         field arp like debgrp.arp
         field grp like debls.grp
         field ls like debls.ls
         field jh like debhis.jh
         field ost  like debhis.ost         label "Остаток"
         field date like debhis.date        label "Дата"
         field ctime like debhis.ctime
         field period as character format "x(40)"
         field attn like debop.attn
         field srok as character
         field fsrok as character
         field name as char
         index idx_wrk is primary grp ls date ctime.


define new shared temp-table wjh no-undo
         field grp like debls.grp
         field ls like debls.ls
         field jh like debhis.jh
         field closed like debop.closed initial no
	index idx_wjh grp ls jh /*10/05/06 u00121*/
         .


define temp-table wost no-undo
         field arp like arp.arp
         field grp like debls.grp
         field srok as character 
         field ost like debhis.ost
         index idx_wost is primary arp srok.
                  

define buffer bdebhis for debhis.

hide all no-pause.
displ "<ВСЕ КАРТОЧКИ>" @ v-ls-des with frame get-grp-all. pause 0.

update v-grp with frame get-grp-all.

find debgrp where debgrp.grp = v-grp no-lock.
displ debgrp.des @ v-grp-des with frame get-grp-all.
pause 0.

v-ls = 0. /* sasco : берем ВСЕ карточки дебиторов в этой группе */

v-dat = g-today.
update v-dat with frame get-dat.

hide frame get-dat.
hide frame get-grp-all.


if v-grp = 0 then
do:
   for each debls where debls.grp > 0 and debls.ls ne 0 no-lock:
       find first debgrp where debgrp.grp = debls.grp no-lock.
       create wrkgrp.
       assign wrkgrp.grp = debls.grp
              wrkgrp.ls = debls.ls
              wrkgrp.arp = debgrp.arp.
   end.
end.
else
do:
	for each debls where debls.grp = v-grp and debls.ls ne 0  no-lock:
       		find first debgrp where debgrp.grp = debls.grp no-lock.
	       create wrkgrp.
	       assign wrkgrp.grp = debls.grp
        	      wrkgrp.ls = debls.ls
	              wrkgrp.arp = debgrp.arp.
	end.
end.

define variable v-dtost as date format "99/99/99" no-undo.

/* сформируем список проводок с остатками */
for each wrkgrp:
    run debost-get (wrkgrp.grp, wrkgrp.ls, wrkgrp.arp, v-dat).
end. 

if not can-find (first wrk) then do:
   message "На указанную дату нет остатков!" view-as alert-box.
   return.
end.


for each wrk:
    find wost where wost.arp = wrk.arp and wost.srok = wrk.period no-lock no-error.
    if not avail wost then create wost.
    assign wost.arp = wrk.arp
           wost.grp = wrk.grp
           wost.srok = wrk.period.
    wost.ost = wost.ost + wrk.ost.
end.



output to debost.img.
put unformatted skip
                "        ОСТАТКИ ПО ДЕБИТОРАМ НА ДАТУ: " v-dat skip
                "        ГРУППА  : " get-grp-des (v-grp) skip (1).


for each wost no-lock use-index idx_wost break by wost.arp by wost.srok:
    if first-of (wost.arp) then do:
       find arp where arp.arp = wost.arp no-lock no-error.
       put unformatted skip "ГРУППА  : " get-grp-des (wost.grp) " (ARP: " wost.arp " - " arp.gl ")" skip
                       fill ("-", vlen) format "x(" + slen + ")" skip
           "СРОК                 |             ОСТАТОК" skip
                       fill (" -", vlen) format "x(" + slen + ")" skip.
       grpost = 0.0.
    end.

    put unformatted wost.srok format "x(20)" " | " 
                    wost.ost format ("->>,>>>,>>>,>>9.99")
                    skip.
    grpost = grpost + wost.ost.

    if last-of (wost.arp) then do:
       put unformatted fill (" -", vlen) format "x(" + slen + ")" skip
                       " ИТОГО ПО АРП:"
                       " " format "x(7)" "| " 
                       grpost format ("->>,>>>,>>>,>>9.99")
                       skip
                       fill ("-", vlen) format "x(" + slen + ")" skip(1).
    end.

end.

output close.

run menu-prt ("debost.img").

