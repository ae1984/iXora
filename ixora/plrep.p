/* plrep.p
 * MODULE
       Платежная система
 * DESCRIPTION
       Динамический отчет по платежам на очереди
 * RUN

 * CALLER
        
 * SCRIPT

 * INHERIT

 * MENU
        6.3.12
 * AUTHOR
        20.12.05 suchkov
 * CHANGES
	07.04.06 suchkov - исправлены ошибки, добавлены no-undo
        05.10.06 suchkov - добавил логи
*/

define variable vpid   as character initial "LB" no-undo.
define variable newpid as character no-undo.
define variable vacc   as character no-undo.
define variable vrnn   as character no-undo.
define variable vknp   as character initial "*" no-undo.
define variable v-amt  as decimal no-undo.
define variable i      as integer initial 0 no-undo.
define variable vamt   as decimal initial 0 no-undo.
{lgps.i "new" }
m_pid = "6.3.12".
{yes-no.i}
define temp-table t-rmz no-undo
        field remtrz like remtrz.remtrz 
        field sacc like remtrz.sacc
        field ord like remtrz.ord
        field amt like remtrz.amt .

hide frame npid .
update vpid  label "Код очереди         " format "x(5)" skip
       v-amt label "Сумма (0 - для всех)" format ">>>,>>>.99" skip
       vknp  label "КНП (* - для всех)  " format "x(3)" skip 
       vacc  label "Номер счета         " format "x(9)" with centered side-labels.

output to rep.img .
put "   RMZ       Счет        Отправитель                          Сумма" skip(1) .

for each que where que.pid = vpid no-lock .
        find remtrz of que no-lock no-error .
        if not available remtrz then next .
        /*vrnn = entry(3,remtrz.ord,"/") no-error .*/
        find sub-cod where sub-cod.sub = "RMZ" and sub-cod.acc = remtrz.remtrz and sub-cod.d-cod = "eknp" no-lock no-error .
        if available sub-cod and vknp <> "*" and substring(sub-cod.rcode,7,3) <> vknp then next .
        if remtrz.sacc = vacc and (v-amt = 0 or remtrz.amt = v-amt) then do:
                i = i + 1 . 
                vamt = vamt + remtrz.amt .
                create t-rmz.
                assign t-rmz.remtrz = remtrz.remtrz
                       t-rmz.sacc = remtrz.sacc
                       t-rmz.ord = remtrz.ord
                       t-rmz.amt = remtrz.amt .
        end.

end.

        for each t-rmz by t-rmz.ord  .
                put t-rmz.remtrz " " 
                    t-rmz.sacc format "x(10)"
                    t-rmz.ord  format "x(35)"
                    t-rmz.amt skip .
        end.


put "=======================================================" 
    skip "Общее количество:" i format ">>>>>" "     Общая сумма:" vamt format ">>>,>>>,>>>.99" .

output close .
unix silent cptwo rep.img .

if vamt = 0 then return .

if yes-no ("Обработка платежей", "Пореставить платежи на другую очередь?") then do:
        update newpid label "Новая очередь" with view-as dialog-box frame npid.
        for each que where que.pid = vpid .
                find remtrz of que no-lock no-error .
                if not available remtrz then next .
                find sub-cod where sub-cod.sub = "RMZ" and sub-cod.acc = remtrz.remtrz and sub-cod.d-cod = "eknp" no-lock no-error .
                if available sub-cod and vknp <> "*" and substring(sub-cod.rcode,7,3) <> vknp then next .
	        if remtrz.sacc = vacc and (v-amt = 0 or remtrz.amt = v-amt) then do:
                        v-text = que.remtrz + " перенесена " + que.pid + " -> " + newpid + " по счету " + vacc .
                        run lgps .
			que.pid = newpid .
		end.
        end.
end.
