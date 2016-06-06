/* taxcomtr.p
 * MODULE
        Коммунальные платежи
 * DESCRIPTION
        Зачисление комиссии за налоговые платежи
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
        18/06/03 nataly 460714 -> 461110, 460716 -> 461120
        13/12/03 sasco проверка остатков на транзитных счетах
        04/04/06   marinav проставление кодов доходов и департаментов в проводке
	05/0706 suchkov - do transaction переделаны по уму
*/

{deparp.i}
{get-dep.i}
{comm-txb.i}
{comm-arp.i}

define temp-table ttax no-undo like comm.tax
    field accnt like depaccnt.accnt
    field depd as char      
    field v-gl as char      
    field rid as rowid.

define temp-table tcom no-undo 
            field accnt like depaccnt.accnt
            field depd as char      
            field v-gl as char      
            field comdoc as int.

def shared var g-today as date.
def var dat as date no-undo.
def var tsum as decimal no-undo.
def new shared var s-jh like jh.jh.
def var ourcode as integer. /* Number of the branch 0 */
def var v-gl-f as char no-undo.
def var v-gl-u as char no-undo.
def var v-depd as char no-undo.
def var v-dep  as char no-undo.

ourcode = comm-cod().

dat = g-today.

update dat label ' Укажите дату  ' format '99/99/9999' skip with side-label row 5 centered frame dataa .

find first sysc where sysc.sysc = 'GLCOMM' no-lock no-error.
if avail sysc then assign v-gl-u = entry(1, sysc.chval) v-gl-f = entry(2, sysc.chval).
              else do:
                  message "Не найдена настройка в SYSC 'GLCOMM'"  view-as alert-box.
                  return.
              end.

for each comm.tax where comm.tax.date = dat and comm.tax.txb = ourcode and comm.tax.duid = ? 
                    and comm.tax.taxdoc <> ? and comm.tax.comdoc = ?  no-lock:
    accumulate tax.comsum (total).
    create ttax.
    buffer-copy comm.tax to ttax.
    v-dep = string(get-dep(comm.tax.uid, dat)).
    ttax.accnt = deparp(get-dep(comm.tax.uid, dat)).
    run get-profit (input tax.uid, input v-dep, output v-depd).
    if v-depd = '' then v-depd = '227'.
    ttax.depd = v-depd.
    ttax.uid = comm.tax.uid.
    ttax.rid = rowid(comm.tax).
    if substring(tax.rnn,5,1) = '0' then ttax.v-gl = v-gl-u.
                                    else ttax.v-gl = v-gl-f.   
end.
/*
for each ttax break by ttax.accnt:
    accumulate ttax.comsum(total).
end.
*/
if (accum total tax.comsum) = 0 then do:
    MESSAGE "Необработанные платежи не найдены."
    VIEW-AS ALERT-BOX TITLE "Внимание".
    return.
end.

/* проверка остатков */
do transaction.
for each ttax break by ttax.accnt :
    accumulate ttax.comsum(total by ttax.accnt).
    if last-of( ttax.accnt ) and  (accum total by ttax.accnt ttax.comsum) > 0
    then if not comm-arp (ttax.accnt, accum total by ttax.accnt ttax.comsum) then undo, return.
end. /* each ttax */
end .

MESSAGE "Сформировать транзакц. на сумму " (accum total tax.comsum) " тенге."
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
    TITLE "Налоговые платежи" UPDATE choice4 as logical.
    case choice4:
       when false then return.
    end.        

do transaction:
find first cods where cods.gl  = integer(v-gl-u) and cods.arc = no exclusive-lock no-error.
if avail cods then cods.lookaaa = yes.
find first cods where cods.gl  = integer(v-gl-f) and cods.arc = no exclusive-lock no-error.
if avail cods then cods.lookaaa = yes.
end .

/*output to temp_tax3.txt.                    */
do transaction:
for each ttax  break by ttax.v-gl by ttax.depd by ttax.accnt :
    accumulate ttax.comsum (total by ttax.v-gl by ttax.depd by ttax.accnt).
    if last-of( ttax.depd ) and  (accum total by ttax.depd ttax.comsum) > 0
    then do:

            find first comm.taxnk where comm.taxnk.rnn = ttax.rnn_nk no-lock no-error.
/*            
            displ ttax.v-gl ttax.depd ttax.accnt (accum total by ttax.depd ttax.comsum).
            pause 0.
 */           
            run trx (
            6, 
            (accum total by ttax.depd ttax.comsum), 
            1, 
            '', 
            ttax.accnt,
            ttax.v-gl, 
            '', 
            'Комиссия за налоговые платежи',comm.taxnk.kbe,'14','840').
            
            if return-value = '' then undo, return.
            s-jh = int(return-value).            
            run cods-com (input integer(ttax.v-gl), input ttax.depd, input "6").

            create tcom.
            tcom.accnt = ttax.accnt.
            tcom.depd = ttax.depd.
            tcom.v-gl = ttax.v-gl.
            tcom.comdoc = s-jh.
          
            /*displ s-jh skip.*/

        end.

end.  
end .

do transaction:
find first cods where cods.gl  = integer(v-gl-u) and cods.arc = no exclusive-lock no-error.
if avail cods and cods.lookaaa = yes then cods.lookaaa = no.
find first cods where cods.gl  = integer(v-gl-f) and cods.arc = no exclusive-lock no-error.
if avail cods and cods.lookaaa = yes then cods.lookaaa = no.
end .

do transaction:
for each ttax, comm.tax where rowid(comm.tax) = ttax.rid :

    find tcom where tcom.accnt = ttax.accnt and tcom.depd = ttax.depd and tcom.v-gl = ttax.v-gl no-error.
    if avail tcom then comm.tax.comdoc = string (tcom.comdoc).

end.
end.
  