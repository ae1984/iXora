/* tax2arp.p
 * MODULE
        Коммунальные платежи
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        taxsofp.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        27/10/03 kanat
 * CHANGES
        11/11/03 kanat - кассир зачисляет только на кассу
	27/05/04 valery - отменена распечатка операционных ордеров
	28/05/04 kanat - добавил проверку на КНП квитанций
	29/07/04 kanat - добавил печать приходника
        04.03.2005 kanat - добавил условия по АРП счетам для филиалов
        11.04.2005 kanat - дополнительно инкассированные кассы заисляются со  специального АРП счета
        12.04.2005 kanat - добавил no-lock и no-error
        14.04.2005 kanat - дополнительное инкассирование только для ЦО
        18/08/05 kanat - убрал формирование операционных ордеров т.к. у менеджеров в конце зачислений формируется единый прих. ордер
        24/05/06   marinav  - добавлен параметр даты факт приема платежа
        01.02.2012 lyubov - изменила символ кассплана (260 на 130)

*/


{get-dep.i}
{deparp.i}
{comm-txb.i}
{sysc.i}

def input parameter dat as date.
def input parameter uu as char.

def shared var g-today as date.
def var ourbank as char.
def var ourcode as integer.
ourbank = comm-txb().
ourcode = comm-cod().

def new shared var s-jh like jh.jh.
def var tsum as decimal.
def var tsum_wc as decimal.

def var tsum1 as decimal.
def var tsum_wc1 as decimal.

def var cho as logical init false.


def var i_temp_dep as integer.
def var s_dep_cash as char.
def var s_account_a as char.
def var s_account_b as char.

def var seltxb as int.
seltxb = comm-cod().

def buffer taxbuf for tax.
def var v-kaslkm as char.

if seltxb = 0 then do:
find first sysc where sysc.sysc = "KASLKM" no-lock no-error.
if avail sysc then
v-kaslkm = sysc.chval.
else do:
message "Отсутствует запись sysc.chval = KASLKM" view-as alert-box title "Внимание".
return.
end.
end.


if get-dep(uu, dat) = ? then do:
message "Неверное имя кассира" VIEW-AS ALERT-BOX.
    return.
end.

if deparp(get-dep(uu, dat)) = ? then do:
    message "Не настроен транзитный счет департамента" VIEW-AS ALERT-BOX.
    return.
end.



/* kanat Касса или касса в пути для отдельных департаментов sysc.sysc = "csptdp" */

/*
i_temp_dep = int (get-dep (uu, dat)).

find first depaccnt where depaccnt.depart = i_temp_dep no-lock no-error.
if avail depaccnt then do:

  s_dep_cash = GET-SYSC-CHA ("csptdp").
  if s_dep_cash = ? then s_dep_cash = "".

if lookup (string(depaccnt.depart), s_dep_cash) > 0 then do:
            s_account_a = ''.
            s_account_b = '000061302'.
end.
else do:
            s_account_a = '100100'.
            s_account_b = ''.
end.
end.
*/


/* --------------------------------------------------- */
/*
	            if return-value = '1' then '100100' else '',
	            if return-value = '1' then '' else '000061302',
*/


if seltxb = 1 then do:
     assign s_account_a = ''
            s_account_b = '150076778'.
end.

if seltxb = 2 then do:
     assign s_account_a = ''
            s_account_b = '250076676'.
end.


for each tax where tax.date = dat and tax.taxdoc = ? and tax.uid = uu and tax.duid = ? and tax.txb = ourcode and tax.chval[3] <> "1" no-lock:
    find first codfr where codfr.codfr = 'spnpl' and (codfr.code = string(tax.intval[1],"999") or string(tax.intval[1],"999") = "000") no-lock no-error.
    if avail codfr then do:
    ACCUMULATE tax.comsum + tax.sum (total).
    ACCUMULATE tax.sum (total).
    end.
    else do:
    message "Квитанция N " string(tax.dnum) " введена с неправильным КНП " string(tax.intval[1],"999") skip
            "Исправьте квитанцию и зачислите через пункт меню." view-as alert-box title "Внимание".
    return.
    end.
end.

tsum    = (accum total tax.comsum + tax.sum).
tsum_wc = (accum total tax.sum).

for each taxbuf where taxbuf.date = dat and taxbuf.taxdoc = ? and taxbuf.uid = uu and taxbuf.duid = ? and taxbuf.txb = ourcode and taxbuf.chval[3] = "1" no-lock:
    find first codfr where codfr.codfr = 'spnpl' and (codfr.code = string(taxbuf.intval[1],"999") or string(taxbuf.intval[1],"999") = "000") no-lock no-error.
    if avail codfr then do:
    ACCUMULATE taxbuf.comsum + taxbuf.sum (total).
    ACCUMULATE taxbuf.sum (total).
    end.
    else do:
    message "Квитанция N " string(taxbuf.dnum) " введена с неправильным КНП " string(taxbuf.intval[1],"999") skip
            "Исправьте квитанцию и зачислите через пункт меню." view-as alert-box title "Внимание".
    return.
    end.
end.

tsum1    = (accum total taxbuf.comsum + taxbuf.sum) .
tsum_wc1 = (accum total taxbuf.sum).


/* не инкассированные квитанции */
do transaction:
if tsum <> 0 then do:
if seltxb = 0 then do:
            s_account_a = '100100'.
            s_account_b = ''.
end.

    MESSAGE "Сформировать кассовый ордер на сумму " tsum " тенге."
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
    TITLE "Налоговые платежи" UPDATE choice3 as logical.
    case choice3:
        when true then do:

	            run trx(
	            6,
	            tsum,
	            1,
	            s_account_a, /*if return-value = '1' then '100100' else '', */
	            s_account_b, /*if return-value = '1' then '' else '000061302',*/
	            '',
	            deparp(get-dep(uu, dat)),
	            'Зачисление на транзитный счет',
	            '14','11','856').

	            if return-value = '' then undo, return.

	            s-jh = int(return-value).
	            run setcsymb.p(s-jh, 130).
	            run jou.
	            if return-value = "" then undo, return.
	            message "Обработка квитанций, ждите...". pause 0.

  	            find first comm.tax where comm.tax.date = dat and comm.tax.taxdoc = ? and comm.tax.duid = ? and
	                                      comm.tax.uid = uu and comm.tax.txb = ourcode and
                                              comm.tax.chval[3] <> "1" exclusive-lock no-error.
	            do while true:
	                if not avail comm.tax then leave.
                 	comm.tax.taxdoc = return-value.
  	            	find next comm.tax where comm.tax.date = dat and comm.tax.taxdoc = ? and comm.tax.duid = ? and
	                	                 comm.tax.uid = uu and comm.tax.txb = ourcode and
                                                 comm.tax.chval[3] <> "1" exclusive-lock no-error.
	            end.
	            release comm.tax.

/*
	            run vou_import.
*/


	            hide message. pause 0.

            find first comm.txb where comm.txb.txb = ourcode and comm.txb.visible no-lock no-error.

            if comm.txb.city <> ourcode then do:
                           /* Если филиал */
                           /* Отправка платежа в головной офис */

			  find first cmp no-lock.

                          run commpl(
                               ourcode,
                               tsum_wc,
                               deparp(get-dep(uu, dat)),
                               "TXB" + string(comm.txb.city,"99"),
                               comm.txb.taxarp,
                               0,                      /* KBK string(tcommpl.kb,"999999") */
                               no,                     /* MB or RB   */
                               trim(cmp.name),      /* name */
                               cmp.addr[2],         /* rnn_nk     */
                               "919",
                               "14",
                               "14",
                               'Зачисление на транзитный счет налог.пл.',
                               "1P",
                               1,
                               5,
                               "",
                               "",
                               dat).  /* Внутренний платеж на TXB00 */

	            find first comm.tax where comm.tax.date = dat and comm.tax.taxdoc <> ? and comm.tax.senddoc = ? and comm.tax.duid = ? and
	                                      comm.tax.uid = uu and comm.tax.txb = ourcode and comm.tax.chval[3] <> "1" exclusive-lock no-error.
	            do while true:
	                if not avail comm.tax then leave.
	                comm.tax.senddoc = return-value.
                     find next comm.tax where comm.tax.date = dat and comm.tax.taxdoc <> ? and comm.tax.senddoc = ? and comm.tax.duid = ? and
                                              comm.tax.uid = uu and comm.tax.txb = ourcode and comm.tax.chval[3] <> "1" exclusive-lock no-error.
	            end.
	            release comm.tax.
            end.

        end.
        when false then undo.
    end case.
end.
end.



/* инкассированные квитанции */
do transaction:
if tsum1 <> 0 then do:
if seltxb = 0 then do:
            s_account_a = ''.
            s_account_b = v-kaslkm.
end.

    MESSAGE "Зачислить с АРП " v-kaslkm " сумму " tsum1 " тенге?"
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
    TITLE "Налоговые платежи" UPDATE choice4 as logical.
    case choice4:
        when true then do:

	            run trx(
	            6,
	            tsum1,
	            1,
	            s_account_a, /*if return-value = '1' then '100100' else '', */
	            s_account_b, /*if return-value = '1' then '' else '000061302',*/
	            '',
	            deparp(get-dep(uu, dat)),
	            'Зачисление на транзитный счет',
	            '14','11','856').

	            if return-value = '' then undo, return.

	            s-jh = int(return-value).
	            run setcsymb.p(s-jh, 130).
	            run jou.
	            if return-value = "" then undo, return.
	            message "Обработка квитанций, ждите...". pause 0.

  	            find first comm.tax where comm.tax.date = dat and comm.tax.taxdoc = ? and comm.tax.duid = ? and
	                                      comm.tax.uid = uu and comm.tax.txb = ourcode and
                                              comm.tax.chval[3] = "1" exclusive-lock no-error.
	            do while true:
	                if not avail comm.tax then leave.
                 	comm.tax.taxdoc = return-value.
  	            	find next comm.tax where comm.tax.date = dat and comm.tax.taxdoc = ? and comm.tax.duid = ? and
	                	                 comm.tax.uid = uu and comm.tax.txb = ourcode and
                                                 comm.tax.chval[3] = "1" exclusive-lock no-error.
	            end.
	            release comm.tax.

/*
	            run vou_import.
*/

	            hide message. pause 0.

            find first comm.txb where comm.txb.txb = ourcode and comm.txb.visible no-lock no-error.

            if comm.txb.city <> ourcode then do:
                           /* Если филиал */
                           /* Отправка платежа в головной офис */

			  find first cmp no-lock no-error.

                          run commpl(
                               ourcode,
                               tsum_wc1,
                               deparp(get-dep(uu, dat)),
                               "TXB" + string(comm.txb.city,"99"),
                               comm.txb.taxarp,
                               0,                      /* KBK string(tcommpl.kb,"999999") */
                               no,                     /* MB or RB   */
                               trim(cmp.name),      /* name */
                               cmp.addr[2],         /* rnn_nk     */
                               "919",
                               "14",
                               "14",
                               'Зачисление на транзитный счет налог.пл.',
                               "1P",
                               1,
                               5,
                               "",
                               "",
                               dat).  /* Внутренний платеж на TXB00 */

	            find first comm.tax where comm.tax.date = dat and comm.tax.taxdoc <> ? and comm.tax.senddoc = ? and comm.tax.duid = ? and
	                                      comm.tax.uid = uu and comm.tax.txb = ourcode and comm.tax.chval[3] = "1" exclusive-lock no-error.
	            do while true:
	                if not avail comm.tax then leave.
	                comm.tax.senddoc = return-value.
                     find next comm.tax where comm.tax.date = dat and comm.tax.taxdoc <> ? and comm.tax.senddoc = ? and comm.tax.duid = ? and
                                              comm.tax.uid = uu and comm.tax.txb = ourcode and comm.tax.chval[3] = "1" exclusive-lock no-error.
	            end.
	            release comm.tax.
            end.

        end.
        when false then undo.
    end case.
end.
end.
