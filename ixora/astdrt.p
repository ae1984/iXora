/* astdrt.p
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


/**************************************************************************************************************************************/
/* 
 astdrt.p
Модуль:
     Коммунальные платежи
Назначение:
     Формирование реестра налоговых платежей по г. Астана

Вызывается:   
Пункты меню:
   3.2.10.2.14

Автор:
     kanat     Канат Аяпбергенов 
Дата создания:
     18.06.2003
Протокол изменений:
     18.06.2003 kanat написал процедуру
*/
/**************************************************************************************************************************************/



{deparp.i}
{get-dep.i}
{sysc.i}
{comm-rnn.i}

def variable dat as date.
def variable out as character.
def variable bc as integer.
def variable rnk as character.
def variable psum as decimal init 0.
def variable csum as decimal init 0.
def variable tsum as decimal init 0.
def variable pcsum as decimal init 0.
def variable ptsum as decimal init 0.
def variable tpcsum as decimal init 0.
def variable tpsum as decimal init 0.
def variable dlm as character initial "|".
def variable count as integer init 0.
def variable pcount as integer init 0.
def variable detarps as character.
def variable c_choice as character.


define temp-table ttax like comm.tax
    field accnt like depaccnt.accnt
    field rid as rowid.
        
{comm-txb.i}
def var ourbank as char.
def var ourcode as integer.
ourbank = comm-txb().
ourcode = comm-cod().


update dat format '99/99/9999' label "Введите дату формирования реестра: ".


/* Здесь будет список АРП счетов, по которым надо */
/* разбивать все платежи по отдельным пачкам */
detarps = GET-SYSC-CHA ("TAXDET").
if detarps = ? then detarps = "".

DEFINE STREAM s3.


   run sel (" Выберите тип форм. реeстра ",  "1.Найденные РНН   |" +
  				             "2.Не найденные РНН|" +
                                             "3.Выход            ").

       case return-value:
          when "1" then c_choice = "1".
          when "2" then c_choice = "2".
          when "3" then c_choice = "3".
       end.


       if c_choice = "1" then do:

       for each comm.txb where city = ourcode and comm.txb.visible no-lock.

       	for each comm.tax where comm.tax.txb = comm.txb.txb and comm.tax.date = dat and comm.tax.duid = ? and comm.tax.sum <> 0.0
       	use-index datenum no-lock:

       		find first comm.rnn where comm.rnn.trn = tax.rnn USE-INDEX rnn no-lock no-error.
       		find first comm.rnnu where comm.rnnu.trn = tax.rnn USE-INDEX rnn no-lock no-error.

       if avail rnn or avail rnnu then do:

       create ttax.
       buffer-copy comm.tax to ttax.

       ttax.rid = rowid(comm.tax).

       if comm.tax.txb=ourcode then ttax.accnt = deparp(get-dep(comm.tax.uid, dat)).
       else ttax.accnt = comm.txb.taxarp.

       end.
       end.
       end.
       end.



       if c_choice = "2" then do:

       for each comm.txb where city = ourcode and comm.txb.visible no-lock.

       	for each comm.tax where comm.tax.txb = comm.txb.txb and comm.tax.date = dat and comm.tax.duid = ? and comm.tax.sum <> 0.0
       	use-index datenum no-lock:

       		find first comm.rnn where comm.rnn.trn = tax.rnn USE-INDEX rnn no-lock no-error.
       		find first comm.rnnu where comm.rnnu.trn = tax.rnn USE-INDEX rnn no-lock no-error.

       if not avail rnn and not avail rnnu then do:

       create ttax.
       buffer-copy comm.tax to ttax.
       ttax.rid = rowid(comm.tax).
       if comm.tax.txb=ourcode then ttax.accnt = deparp(get-dep(comm.tax.uid, dat)).
       else ttax.accnt = comm.txb.taxarp.

       end.
       end.
       end.
       end.


       if c_choice = "3" then do:
       return.
       end.


OUTPUT STREAM s3 TO taxast.log.

put stream s3 unformatted "                             АО TEXAKABANK                      " skip.
put stream s3 unformatted "            Реестр электронных налоговых платежей по г. Астана. за " dat skip.



if c_choice = "1" then
put stream s3 unformatted "                    (НАЙДЕННЫЕ РНН НАЛОГОПЛАТЕЛЬЩИКОВ)          " skip.

if c_choice = "2" then
put stream s3 unformatted "                   (НЕ НАЙДЕННЫЕ РНН НАЛОГОПЛАТЕЛЬЩИКОВ)        " skip.



put stream s3 unformatted
fill("-", 95) format "x(95)" skip
"  Дата  |No   |    РНН     |           ФИО                |Назнач|  РНН НК    |      Сумма    |" skip
      fill("-", 95) format "x(95)" skip.
      
FOR EACH ttax break by ttax.accnt by ttax.rnn_nk by ttax.kb by ttax.sum:
find first comm.rnn where comm.rnn.trn=ttax.rnn USE-INDEX rnn no-lock no-error.
if not avail comm.rnn then
find first comm.rnnu where comm.rnnu.trn=ttax.rnn USE-INDEX rnn no-lock no-error.

accumulate ttax.sum
    (total count).
       
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
    fill("-", 95) format "x(95)" skip space(15)
    'Пачка ' ttax.gr ' Тр. счет ' ttax.accnt ' РНН НК ' ttax.rnn_nk ' Код бюджета '     ttax.kb skip
    fill("-", 95) format "x(95)" skip. 
end.
else do:   
if first-of(ttax.kb) then do:
    put stream s3 unformatted
    fill("-", 95) format "x(95)" skip space(15)
    'Пачка ' ttax.gr ' Тр. счет ' ttax.accnt ' РНН НК ' ttax.rnn_nk ' Код бюджета '     ttax.kb skip
    fill("-", 95) format "x(95)" skip. 
end.    
end.


put stream s3 unformatted
ttax.date FORMAT "99/99/99" dlm
ttax.dnum format "999999" dlm
ttax.rnn format "x(12)" dlm


if avail comm.rnn then
    trim( comm.rnn.lname ) + " " + trim( comm.rnn.fname ) + " " + trim( comm.rnn.mname ) 
else if avail comm.rnnu then
    caps(trim( comm.rnnu.busname ))
else " --- РНН НЕ НАЙДЕН В БАЗЕ --- " format "x(30)" dlm


ttax.kb format "999999" dlm
ttax.rnn_nk format "999999999999" dlm
ttax.sum format ">>>>>>>>>>>9.99" dlm skip.

if lookup (ttax.accnt, detarps) > 0 then do:
put stream s3 unformatted
      fill("-", 95) format "x(95)" skip
      "Итого по пачке 1 платежей" space(52)
      ttax.sum format ">>>>>>>>>>>9.99" dlm skip
	      fill("-", 95) format "x(95)" skip(1).
end.
else do:
if last-of(ttax.kb) then do:
put stream s3 unformatted
      fill("-", 95) format "x(95)" skip
      "Итого по пачке" 
      (accum sub-count by ttax.kb ttax.sum)
      format "zzzz9" " платежей" space(52)
      (accum sub-total by ttax.kb ttax.sum) 
      format ">>>>>>>>>>>9.99" dlm skip
      fill("-", 95) format "x(95)" skip(1).
end.
end.

if last-of(ttax.accnt) then do:
put stream s3 unformatted
      fill("-", 95) format "x(95)" skip
      "Итого по счету " ttax.accnt
      (accum sub-count by ttax.accnt ttax.sum)
      format "zzzz9" " платежей" space(42)
      (accum sub-total by ttax.accnt ttax.sum)
      format ">>>>>>>>>>>9.99" dlm skip
      fill("-", 95) format "x(95)" skip(1).
end.
                              
end.

put stream s3 unformatted
    fill("-", 95) format "x(95)" skip
    "Всего " 
    (accum count ttax.sum)
    format "zzzz9" " платежей" space(60)
    (accum total ttax.sum)
    format ">>>>>>>>>>>9.99" dlm skip
    fill("-", 95) format "x(95)" skip(1).
    
OUTPUT STREAM s3 CLOSE.

run menu-prt ("taxast.log").

    
    