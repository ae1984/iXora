/* taxoutdet0rp.p
 * MODULE
     Коммунальные платежи
 * DESCRIPTION
     Формирование детального реестра налоговых платежей (без перенумерации)
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
        20.06.03 kanat
 * CHANGES
     17.07.03 kanat по некоторым счетам АРП (sysc.chval = "ARPCSM") номер пачки будет равен номеру квитанции
     30.10.03 sasco для Алматы: вывод отчета в Excel для свода
     23.01.04 sasco пачки не перенумеровываются
     10/09/04 kanat - вывод ФИО плательщика через поле chval[1]
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
def var dlm as char initial "|".
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

put stream s3 unformatted "                        Реестр электронных платежей " skip.

put stream s3 unformatted
fill("-", 129) format "x(129)" skip
"  Дата  |Пачка |No    |    РНН     |           ФИО                |Назнач|  РНН НК    |
      Сумма    |Комиссия |    Итого      |" skip
      fill("-", 129) format "x(129)" skip.
      
gr = 0.

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
      
put stream s3 unformatted
ttax.date FORMAT "99/99/99" dlm
ttax.grp FORMAT "zzzzz9" dlm
ttax.dnum format "999999" dlm
ttax.rnn format "x(12)" dlm
/*
if avail comm.rnn then
    trim( comm.rnn.lname ) + " " + trim( comm.rnn.fname ) + " " + trim( comm.rnn.mname ) 
else if avail comm.rnnu then
    caps(trim( comm.rnnu.busname ))
else ""
*/
ttax.chval[1] format "x(30)" dlm
ttax.kb format "999999" dlm
ttax.rnn_nk format "999999999999" dlm
ttax.sum format ">>>>>>>>>>>9.99" dlm
ttax.comsum
format ">>>>>9.99" dlm
ttax.comsum + ttax.sum
format ">>>>>>>>>>>9.99" dlm
skip.

if last-of(ttax.accnt) then do:
put stream s3 unformatted
      fill("-", 129) format "x(129)" skip
      "Итого по счету " ttax.accnt
      (accum sub-count by ttax.accnt ttax.sum)
      format "zzzz9" " платежей" space(49)
      (accum sub-total by ttax.accnt ttax.sum)
      format ">>>>>>>>>>>9.99" dlm
      (accum sub-total by ttax.accnt ttax.comsum)
      format ">>>>>9.99" dlm
      (accum sub-total by ttax.accnt ttax.comsum) +
      (accum sub-total by ttax.accnt ttax.sum)
      format ">>>>>>>>>>>9.99" dlm skip
      fill("-", 129) format "x(129)" skip(1).
end.

end. /* КОНЕЦ СПИСКА */

put stream s3 unformatted
    fill("-", 129) format "x(129)" skip
    "Всего " 
    gr
    format "zzzzz9" " платежей" space(66).

put stream s3 unformatted
    (accum total ttax.sum)
    format ">>>>>>>>>>>9.99" dlm.

put stream s3 unformatted
    (accum total ttax.comsum) 
    format ">>>>>9.99" dlm.

put stream s3 unformatted
    (accum total ttax.comsum) + (accum total ttax.sum)
    format ">>>>>>>>>>>9.99" dlm skip
    fill("-", 129) format "x(129)" skip(1).
    
OUTPUT STREAM s3 CLOSE.

