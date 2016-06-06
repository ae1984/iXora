/* pen2arp.p
 * MODULE
        Коммунальные платежи
 * DESCRIPTION
        Зачисление пенсионных платежей
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        pensofp.p
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
        24/01/05 kanat - зачисление будет проводиться на другие АРП счета для пенсионных и соц. отчислений
        04.03.2005 kanat - добавил условия по АРП счетам для филиалов
        11.04.2005 kanat - дополнительно инкассированные кассы заисляются со  специального АРП счета
        12.04.2005 kanat - добавил no-lock и no-error
        14.04.2005 kanat - дополнительное инкассирование только для ЦО
        18/08/05 kanat - убрал формирование операционных ордеров т.к. у менеджеров в конце зачислений формируется единый прих. ордер
        24/05/06   marinav  - добавлен параметр даты факт приема платежа
        01.02.2012 lyubov - изменила символ кассплана (180 на 100)

*/


{comm-txb.i}
{sysc.i}


def input parameter dat as date.
def input parameter uu as char.
def output parameter v-pen-jh as integer.

def var seltxb as int.
seltxb = comm-cod().

{get-dep.i}
{deparp_pmp.i}
def shared var g-today as date.
def var tsum as decimal.
def var tsum_0 as decimal.

def var tsum1 as decimal.
def var tsum_01 as decimal.

def var cho as logical init false.
def new shared var s-jh like jh.jh.


def var i_temp_dep as integer.
def var s_account_a as char.
def var s_account_b as char.
def var s_dep_cash as char.

def buffer penbuf for p_f_payment.

def var v-kaslkm as char.

if get-dep(uu,dat) = ? then do:
message "Неверное имя кассира" VIEW-AS ALERT-BOX.
    return.
end.

if deparp_pmp(get-dep(uu,dat)) = ? then do:
    message "Не настроен транзитный счет департамента" VIEW-AS ALERT-BOX.
    return.
end.

if seltxb = 0 then do:
find first sysc where sysc.sysc = "KASLKM" no-lock no-error.
if avail sysc then
v-kaslkm = trim(sysc.chval).
else do:
message "Отсутствует запись sysc.chval = KASLKM" view-as alert-box title "Внимание".
return.
end.
end.

/* -------- kanat зачисление на кассу в пути только для кассиров из sysc.sysc = "csptdp" ---------- */

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


             /*if cho then '100100' else '',*/
             /*if cho then '' else '000061302',*/

/*--------------------------------------------------------------------------------------------------*/



if seltxb = 1 then do:
     assign s_account_a = ''
            s_account_b = '150076778'.
end.

if seltxb = 2 then do:
     assign s_account_a = ''
            s_account_b = '250076676'.
end.



hide all.
do transaction:
for each p_f_payment where p_f_payment.txb = seltxb and p_f_payment.date = dat and p_f_payment.uid = uu and p_f_payment.stcif = 0 and
                           p_f_payment.deluid = ? and p_f_payment.chval[3] <> "1" no-lock:
    ACCUMULATE p_f_payment.amt + p_f_payment.comiss (total).
    ACCUMULATE p_f_payment.amt (total).
end.

tsum = (accum total p_f_payment.amt + p_f_payment.comiss).
tsum_0 = accum total p_f_payment.amt.

for each penbuf where penbuf.txb = seltxb and penbuf.date = dat and penbuf.uid = uu and penbuf.stcif = 0 and
                      penbuf.deluid = ? and penbuf.chval[3] = "1" no-lock:
    ACCUMULATE penbuf.amt + penbuf.comiss (total).
    ACCUMULATE penbuf.amt (total).
end.

tsum1 = (accum total penbuf.amt + penbuf.comiss).
tsum_01 = accum total penbuf.amt.


/* не инкассированные квитанции */
if tsum <> 0 then do:
if seltxb = 0 then do:
            s_account_a = '100100'.
            s_account_b = ''.
end.

    MESSAGE "Сформировать кассовый ордер на сумму " tsum " тенге."
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
    TITLE "Пенсионные и др. платежи" UPDATE choice3 as logical.
    case choice3:

        when true then do:
            run trx (
            6,                                          /* 150904824 - TXB01 */
            tsum,
            1,
            s_account_a, /*if cho then '100100' else '',*/
            s_account_b, /*if cho then '' else '000061302',*/
            '',
            deparp_pmp(get-dep(uu,dat)),
            'Зачисление на транзитный счет','14','14','856').

            if return-value = '' then undo, return.
            s-jh = int(return-value).

            v-pen-jh = s-jh.

            run setcsymb (s-jh, 100).
            run jou.

            for each p_f_payment where p_f_payment.txb = seltxb and p_f_payment.date = dat and p_f_payment.stcif = 0 and
                                       p_f_payment.uid = uu and p_f_payment.deluid = ? and
                                       p_f_payment.chval[3] <> "1":
                update  p_f_payment.stcif = 1.
            end.

/*
            run vou_import.
*/

            find first comm.txb where comm.txb.txb = seltxb and comm.txb.visible no-lock.

            if comm.txb.city <> seltxb then do:
                           /* Если филиал */
                           /* Отправка платежа в головной офис */

                          find first cmp no-lock.

                          run commpl (
                               seltxb,
                               tsum_0,
                               deparp_pmp(get-dep(uu, dat)),
                               "TXB" + string(comm.txb.city,"99"),
                               "020076720",
                               0,                      /* KBK string(tcommpl.kb,"999999") */
                               no,                     /* MB or RB   */
                               trim(cmp.name),      /* name */
                               cmp.addr[2],         /* rnn_nk     */
                               "919",
                               "14",
                               "14",
                               'Зачисление на транзитный счет пенсионных и пр. плат.',
                               "1P",
                               1,
                               5,
                               "",
                               "",
                               dat).  /* Внутренний платеж на TXB00 */

                    end.
            end.

        when false then undo.
        end.
end.


/* не инкассированные квитанции */

if tsum1 <> 0 then do:
if seltxb = 0 then do:
            s_account_a = ''.
            s_account_b = v-kaslkm.
end.

    MESSAGE "Зачислить с АРП " v-kaslkm " сумму " tsum1 " тенге?"
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
    TITLE "Пенсионные и др. платежи" UPDATE choice4 as logical.
    case choice4:

        when true then do:
            run trx(
            6,                                          /* 150904824 - TXB01 */
            tsum1,
            1,
            s_account_a, /*if cho then '100100' else '',*/
            s_account_b, /*if cho then '' else '000061302',*/
            '',
            deparp_pmp(get-dep(uu,dat)),
            'Зачисление на транзитный счет','14','14','856').

            if return-value = '' then undo, return.
            s-jh = int(return-value).

            v-pen-jh = s-jh.

            run setcsymb (s-jh, 100).
            run jou.

            for each p_f_payment where p_f_payment.txb = seltxb and p_f_payment.date = dat and p_f_payment.stcif = 0 and
                                       p_f_payment.uid = uu and p_f_payment.deluid = ? and
                                       p_f_payment.chval[3] = "1" exclusive-lock:
                update  p_f_payment.stcif = 1.
            end.
/*
            run vou_import.
*/

            find first comm.txb where comm.txb.txb = seltxb and comm.txb.visible no-lock no-error.
            end.

        when false then undo.
        end.
end.
end.
