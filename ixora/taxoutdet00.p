/* taxoutdet00.p
 * MODULE
     Коммунальные платежи
 * DESCRIPTION
     Формирование детального реестра налоговых платежей для Алматы *special*
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
     31/10/03 sasco
 * CHANGES

*/

{deparp.i}
{get-dep.i}
{sysc.i}
{gl-utils.i}

def input parameter dat as date.
def var out as char.
def var gr as integer init 0.
def var bc as integer.
def var rnk as char.
def var psum as deci init 0.
def var csum as deci init 0.
def var tsum as deci init 0.
def var pcsum as deci init 0.
def var ptsum as deci init 0.
def var tpcsum as deci init 0.
def var tpsum as deci init 0.
def var dlm as char initial " | ".
def var count as integer init 0.
def var pcount as integer init 0.
def var detarps as char.

define temp-table ttax like comm.tax
    field accnt like depaccnt.accnt
    field rid as rowid.
        
{comm-txb.i}
def var ourbank as char.
def var ourcode as integer.
ourbank = comm-txb().
ourcode = comm-cod().

/* Здесь будет список АРП счетов, по которым надо */
/* разбивать все платежи по отдельным пачкам */

detarps = GET-SYSC-CHA ("ARPCSM").
if detarps = ? then detarps = "".

DEFINE STREAM s3.
OUTPUT STREAM s3 TO tax.log.

/* Выбираем все филиалы принадлежащие этому городу */
for each comm.txb where city = ourcode and comm.txb.visible and comm.txb.consolid no-lock.

  /* зачисляем все с ненулевой суммой */
  for each comm.tax where comm.tax.txb = comm.txb.txb and comm.tax.date = dat and comm.tax.duid = ? and comm.tax.sum <> 0.0
  use-index datenum no-lock:
    create ttax.
    buffer-copy comm.tax to ttax.
    ttax.rid = rowid(comm.tax).
    if comm.tax.txb=ourcode then ttax.accnt = deparp(get-dep(comm.tax.uid, dat)).
                            else ttax.accnt = comm.txb.taxarp.
  end.

  /* удалим нулевые */
  for each comm.tax where comm.tax.txb = comm.txb.txb and comm.tax.date = dat and comm.tax.duid = ? and comm.tax.sum = 0.0
  use-index datenum:
      comm.tax.duid = comm.tax.uid.
      comm.tax.deldate = today.
      comm.tax.deltime = time.
  end.

end.

put stream s3 unformatted "                        Реестр налоговых платежей за " dat skip (1).

put stream s3 unformatted
fill("-", 83) format "x(83)" skip
"Счет      | Кол-во платежей | Сумма           | Комиссия        | Итого           |" skip
fill("-", 83) format "x(83)" skip.

gr = 0.

if ourcode = 0 then output to tax.csv. /* sasco */

FOR EACH ttax break by ttax.accnt by ttax.sum:

   gr = gr + 1.

/*
   find first comm.rnn where comm.rnn.trn=ttax.rnn USE-INDEX rnn no-lock no-error.

   if not avail comm.rnn then find first comm.rnnu where comm.rnnu.trn=ttax.rnn USE-INDEX rnn no-lock no-error.
*/

   accumulate ttax.sum
    (total count).
    
   accumulate ttax.sum
    (total).
    
   accumulate ttax.comsum
    (total count).
    
   accumulate ttax.comsum
    (total).
    
   accumulate ttax.comsum
   (sub-total by ttax.accnt).

   accumulate ttax.comsum
   (sub-count by ttax.accnt).
    
   accumulate ttax.sum
   (sub-total by ttax.accnt).
    
   accumulate ttax.sum
   (sub-count by ttax.accnt).
      


if lookup (ttax.accnt, detarps) > 0 then 
   ttax.grp = ttax.dnum.
   else 
   ttax.grp = gr.

/*
put stream s3 unformatted
ttax.date FORMAT "99/99/99" dlm
ttax.grp FORMAT "zzzzz9" dlm
ttax.dnum format "999999" dlm
ttax.rnn format "x(12)" dlm
if avail comm.rnn then
    trim( comm.rnn.lname ) + " " + trim( comm.rnn.fname ) + " " + trim( comm.rnn.mname ) 
else if avail comm.rnnu then
    caps(trim( comm.rnnu.busname ))
else ""
    format "x(30)" dlm
ttax.kb format "999999" dlm
ttax.rnn_nk format "999999999999" dlm
ttax.sum format ">>>>>>>>>>>9.99" dlm
ttax.comsum
format ">>>>>9.99" dlm
ttax.comsum + ttax.sum
format ">>>>>>>>>>>9.99" dlm
skip.
*/
   /* sasco */
   if ourcode = 0 then put unformatted XLS-NUMBER (ttax.sum) skip.


if last-of(ttax.accnt) then do:
put stream s3 unformatted
      ttax.accnt format "x(9)" dlm
      (accum sub-count by ttax.accnt ttax.sum) format "zzzzzzzzzzzzzz9" dlm
      (accum sub-total by ttax.accnt ttax.sum) format ">>>>>>>>>>>9.99" dlm
      (accum sub-total by ttax.accnt ttax.comsum) format ">>>>>>>>>>>9.99" dlm
      (accum sub-total by ttax.accnt ttax.comsum) + (accum sub-total by ttax.accnt ttax.sum) format ">>>>>>>>>>>9.99" dlm skip
      skip.

/* sasco */
if ourcode = 0 then
put unformatted "Тр. счет;" ttax.accnt "; платежей ;" 
                (accum sub-count by ttax.accnt ttax.sum)
                format "zzzz9" "; на сумму ;" 
                XLS-NUMBER ((accum sub-total by ttax.accnt ttax.sum))
                skip.
           
end.
                              
end. /* КОНЕЦ СПИСКА */

if ourcode = 0 then do:
   output close.
   unix silent cptwin tax.csv excel.
   unix silent rm tax.csv.
end.

put stream s3 unformatted
    fill("-", 83) format "x(83)" skip
    "Всего " format "x(9)" dlm
    gr format "zzzzzzzzzzzzzz9" dlm.

put stream s3 unformatted
    (accum total ttax.sum)
    format ">>>>>>>>>>>9.99" dlm.

put stream s3 unformatted
    (accum total ttax.comsum) 
    format ">>>>>>>>>>>9.99" dlm.

put stream s3 unformatted
    (accum total ttax.comsum) + (accum total ttax.sum)
    format ">>>>>>>>>>>9.99" dlm skip
    fill("-", 83) format "x(83)" skip(1).
    
OUTPUT STREAM s3 CLOSE.

for each ttax:
    find first comm.tax where rowid(comm.tax) = ttax.rid exclusive-lock no-error.
    tax.grp = ttax.grp.
    release comm.tax.
end.
    
