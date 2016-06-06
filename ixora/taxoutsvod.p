/* taxoutsvod.p
 * MODULE
        Налоговые платежи
 * DESCRIPTION
        Сводный реестр налоговых платежей
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
        13/01/04 sasco расширил поле для номера пачки
*/


{deparp.i}
{get-dep.i}
{comm-txb.i}

def var ourbank as char.
def var ourcode as integer.
ourbank = comm-txb().
ourcode = comm-cod().

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

define temp-table ttax like comm.tax
    field accnt like depaccnt.accnt.
        

DEFINE STREAM s3.
OUTPUT STREAM s3 TO tax.log.

for each comm.txb where city = ourcode and comm.txb.visible and comm.txb.consolid no-lock.

  for each comm.tax where comm.tax.txb = comm.txb.txb  and comm.tax.date = dat and comm.tax.duid = ? 
  use-index datenum no-lock:
    create ttax.
    buffer-copy comm.tax to ttax.
    if comm.tax.txb=ourcode then ttax.accnt = deparp(get-dep(comm.tax.uid, dat)).
                            else ttax.accnt = comm.txb.taxarp.
 end.

end.

/*
for each comm.tax where comm.tax.date = dat and comm.tax.duid = ? and comm.tax.txb = ourcode no-lock:
    create ttax.
    buffer-copy comm.tax to ttax.
    ttax.accnt = deparp(get-dep(tax.uid, dat)).
end.
*/

put stream s3 unformatted "                        Сводный отчет по электронным платежам " skip.
put stream s3 unformatted skip (1) "  Дата: " dat FORMAT "99/99/99" skip(1).

put stream s3 unformatted
fill("-", 74) format "x(74)" skip
"Пачка   | Тр. счет  |   РНН НК   |Код бюджета|Кол.платежей|      Сумма   |" format "x(74)" skip
fill("-", 74) format "x(74)" skip.

   
FOR EACH ttax break by ttax.grp by ttax.rnn_nk by ttax.kb by ttax.sum:

accumulate ttax.sum
    (total count).
    
accumulate ttax.comsum
    (sub-total by ttax.grp by ttax.rnn_nk by ttax.kb).

accumulate ttax.comsum
    (sub-count by ttax.grp by ttax.rnn_nk by ttax.kb).
    
accumulate ttax.sum
    (sub-total by ttax.grp by ttax.rnn_nk by ttax.kb).

accumulate ttax.sum
    (sub-count by ttax.grp by ttax.rnn_nk by ttax.kb).

    
if first-of(ttax.kb) then do:
    put stream s3 unformatted
    string (ttax.grp, "zzzzzz9") format "x(7)" space(1) dlm
    space(1) ttax.accnt format "999999999" space(1) dlm 
    ttax.rnn_nk format "999999999999" dlm
    space(4)
    ttax.kb format "999999" space(1) dlm.
end.    

if last-of(ttax.kb) then do:
 put stream s3 unformatted
      space(6) (accum sub-count by ttax.kb ttax.sum)
      format "zzzzz9" dlm
      (accum sub-total by ttax.kb ttax.sum) 
      format ">>>>>>>>>>9.99" dlm skip.
end.

end.

put stream s3 unformatted
    fill("-", 74) format "x(74)" skip
    "Всего " space(37) dlm
    space(6) (accum count ttax.sum)
    format "zzzzz9" dlm
    (accum total ttax.sum)
    format ">>>>>>>>>>9.99" dlm skip(1).
    
OUTPUT STREAM s3 CLOSE.


    