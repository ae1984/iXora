/* txplinfo.p
 * MODULE
     	Налоговые платежи 
 * DESCRIPTION
     	Процедура - Формирование расширенного детального реестра по платежам
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT
 	menu-prt
 * MENU
        г. Астана п.п. 3.2.10.8.11
 * AUTHOR
        06/10/03 kanat
 * CHANGES
    	06/10/03 kanat created procedure
    	09/10/03 kanat Добавил печать сумм по п/п
*/

{deparp.i}
{global.i}
{get-dep.i}
{sysc.i}

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

def var v-senddoc as char.
def var v-platpor as char.
def var v-platdate as date.
def var v-platamt as decimal.

def var d_date_begin as date.
def var d_date_end as date.

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
detarps = GET-SYSC-CHA ("TAXDET").
if detarps = ? then detarps = "".

update d_date_begin   label "Введите дату начала периода" with centered side-label.
update d_date_end     label "Введите дату конца периода" with centered side-label.

DEFINE STREAM s3.
OUTPUT STREAM s3 TO tax.log.

/* Выбираем все филиалы принадлежащие этому городу */
for each comm.txb where city = ourcode and comm.txb.visible and comm.txb.consolid no-lock.

  for each comm.tax where comm.tax.txb = comm.txb.txb and comm.tax.date >= d_date_begin and comm.tax.date <= d_date_end and 
  comm.tax.duid = ? and comm.tax.sum <> 0.0
  use-index datenum no-lock:
    create ttax.
    buffer-copy comm.tax to ttax.
    ttax.rid = rowid(comm.tax).
    if comm.tax.txb=ourcode then ttax.accnt = deparp(get-dep(comm.tax.uid, comm.tax.date)).
    			    else ttax.accnt = comm.txb.taxarp.
 end.

end.


put stream s3 "Сотрудник: " g-ofc skip.
put stream s3 "Дата: " string(today) skip(2).

put stream s3 unformatted "             Реестр электронных платежей с " string(d_date_begin) " по " string(d_date_end) skip.

put stream s3 unformatted
fill("-", 120) format "x(120)" skip
"  Дата  |  No  |    РНН     |           ФИО                |Назнач|  РНН НК    |
      Сумма    |Комиссия | Итого         | Референс | Номер п/п|Дата п/п |  Сумма п/п. " skip
      fill("-", 120) format "x(120)" skip.
      
FOR EACH ttax no-lock break by ttax.date by ttax.accnt by ttax.rnn_nk by ttax.kb by ttax.sum:
find first comm.rnn where comm.rnn.trn=ttax.rnn USE-INDEX rnn no-lock no-error.
if not avail comm.rnn then
find first comm.rnnu where comm.rnnu.trn=ttax.rnn USE-INDEX rnn no-lock no-error.

accumulate ttax.sum
    (total count).
    
accumulate ttax.comsum
    (sub-total by ttax.accnt by ttax.rnn_nk by ttax.kb).

accumulate ttax.comsum
    (sub-count by ttax.accnt by ttax.rnn_nk by ttax.kb).
    
accumulate ttax.sum
    (sub-total by ttax.accnt by ttax.rnn_nk by ttax.kb).

accumulate ttax.sum
    (sub-count by ttax.accnt by ttax.rnn_nk by ttax.kb).

accumulate ttax.sum
    (sub-total by ttax.accnt).
    
accumulate ttax.sum
    (sub-count by ttax.accnt).
        
if lookup (ttax.accnt, detarps) > 0 then do:
    put stream s3 unformatted
    fill("-", 120) format "x(120)" skip space(15)
    'Пачка ' ttax.grp ' Тр. счет ' ttax.accnt ' РНН НК ' ttax.rnn_nk ' Код бюджета '     ttax.kb skip
    fill("-", 120) format "x(120)" skip. 
end.
else do:   
if first-of(ttax.kb) then do:
    put stream s3 unformatted
    fill("-", 120) format "x(120)" skip space(15)
    'Пачка ' ttax.grp ' Тр. счет ' ttax.accnt ' РНН НК ' ttax.rnn_nk ' Код бюджета '     ttax.kb skip
    fill("-", 120) format "x(120)" skip. 
end.    
end.


find first remtrz where remtrz.remtrz = ttax.senddoc no-lock no-error.
if avail remtrz then do:
v-senddoc = ttax.senddoc.
v-platpor = trim(substring(remtrz.sqn,19,8)).
v-platdate = remtrz.valdt2.
v-platamt = remtrz.amt.
end.
else do:
v-senddoc = " ".
v-platpor = " ".
v-platamt = 0.
end.


put stream s3 unformatted
ttax.date FORMAT "99/99/99" dlm
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
ttax.comsum + ttax.sum format ">>>>>>>>>>>9.99" dlm 
ttax.senddoc dlm
v-platpor format "x(10)" dlm
v-platdate dlm
v-platamt format ">>>>>>>>>>>9.99" skip.


if lookup (ttax.accnt, detarps) > 0 then do:
put stream s3 unformatted
      fill("-", 120) format "x(120)" skip
      "Итого по пачке 1 платежей" space(52)
      ttax.sum format ">>>>>>>>>>>9.99" dlm
      ttax.comsum format ">>>>>9.99" dlm
      (ttax.comsum + ttax.sum) format ">>>>>>>>>>>9.99" dlm skip
      fill("-", 120) format "x(120)" skip(1).
end.
else do:
if last-of(ttax.kb) then do:
put stream s3 unformatted
      fill("-", 120) format "x(120)" skip
      "Итого по пачке" 
      (accum sub-count by ttax.kb ttax.sum)
      format "zzzz9" " платежей" space(52)
      (accum sub-total by ttax.kb ttax.sum) 
      format ">>>>>>>>>>>9.99" dlm
      (accum sub-total by ttax.kb ttax.comsum) 
      format ">>>>>9.99" dlm
      (accum sub-total by ttax.kb ttax.comsum) + 
      (accum sub-total by ttax.kb ttax.sum) 
      format ">>>>>>>>>>>9.99" dlm skip
      fill("-", 120) format "x(120)" skip(1).
end.
end.

if last-of(ttax.accnt) then do:
put stream s3 unformatted
      fill("-", 120) format "x(120)" skip
      "Итого по счету " ttax.accnt
      (accum sub-count by ttax.accnt ttax.sum)
      format "zzzz9" " платежей" space(42)
      (accum sub-total by ttax.accnt ttax.sum)
      format ">>>>>>>>>>>9.99" dlm
      (accum sub-total by ttax.accnt ttax.comsum)
      format ">>>>>9.99" dlm
      (accum sub-total by ttax.accnt ttax.comsum) +
      (accum sub-total by ttax.accnt ttax.sum)
      format ">>>>>>>>>>>9.99" dlm skip
      fill("-", 120) format "x(120)" skip(1).
end.
                              
end.

put stream s3 unformatted
    fill("-", 120) format "x(120)" skip
    "Всего " 
    (accum count ttax.sum)
    format "zzzz9" " платежей" space(60)
    (accum total ttax.sum)
    format ">>>>>>>>>>>9.99" dlm
    (accum total ttax.comsum) 
    format ">>>>>9.99" dlm
    (accum total ttax.comsum) + (accum total ttax.sum)
    format ">>>>>>>>>>>9.99" dlm skip
    fill("-", 120) format "x(120)" skip(1).
    
OUTPUT STREAM s3 CLOSE.

run menu-prt ("tax.log").
    

