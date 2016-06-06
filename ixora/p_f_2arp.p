/* p_f_2arp.p
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

/* p_f_2arp.p
 * Модуль
     Коммунальные платежи
 * Назначение
     Процедура зачисления пенсионных платежей на транзитные счета АРП
 * Применение
     Применяется при непосредственном зачислении пенсионных платежей на АРП

 * Вызов
     В данной процедуре вызывается процедура commpl, в которой происходит генерация REMTRZ
 * Меню
     3.2.10.6 Зачисление на АРП по каждому кассиру

 * Автор
     pragma
 * Дата создания:
     16.09.02
 * Изменения
     07.07.03 kanat добавил новый параметр при вызове процедуры commpl - РНН плательщика для таможенных платежей, по - умолчанию ставятся пустые кавычки
     25.07.03 kanat добавил зачисление на кассу в пути для кассиров из sysc.sysc = "csptdp"
     31.07.03 kanat добавил новый параметр при вызове процедуры commpl
     19.05.2004 valery - перенес зачисление на АРП на кассы в пути в - comm-arp1.i
     20.01.2005 kanat - перенес зачисление на другие АРП - счета
        24/05/06   marinav  - добавлен параметр даты факт приема платежа
        01.02.2012 lyubov - изменила символ кассплана (180 на 100)
*/


{global.i}
{comm-txb.i}
{sysc.i}

def var seltxb as int.
seltxb = comm-cod().

{get-dep.i}
{deparp_pmp.i}

def var dat as date.
def var uu as char.
def var tsum as decimal.
def var tsum_0 as decimal.
def var cho as logical init false.
def new shared var s-jh like jh.jh.


def var i_temp_dep as integer.
def var s_account_a as char.
def var s_account_b as char.
def var s_dep_cash as char.


dat = g-today.

update dat label ' Укажите дату ' format '99/99/9999' skip
with side-label row 5 centered frame dataa .
update uu label ' Укажите имя кассира ' format 'x(8)' skip
with side-label row 5 centered frame uuuu .

if get-dep(uu,dat) = ? then do:
message "Неверное имя кассира" VIEW-AS ALERT-BOX.
    return.
end.

if deparp_pmp(get-dep(uu,dat)) = ? then do:
    message "Не настроен транзитный счет департамента" VIEW-AS ALERT-BOX.
    return.
end.





/* -------- kanat зачисление на кассу в пути только для кассиров из sysc.sysc = "csptdp" ---------- */


i_temp_dep = int (get-dep (uu, dat)).

/*
find first depaccnt where depaccnt.depart = i_temp_dep no-lock no-error.
if avail depaccnt then do:

  s_dep_cash = GET-SYSC-CHA ("csptdp").
  if s_dep_cash = ? then s_dep_cash = "".

if lookup (string(depaccnt.depart), s_dep_cash) > 0 then do:
            s_account_a = ''.
            s_account_b = '000061302'.
end.
else do:

MESSAGE "Выберите счет кассы." skip(1)
    "<YES>  - Касса.        (g/l 1001)              " skip
    "<NO>   - Касса в пути. (g/l 1002 arp 000061302)" skip
    VIEW-AS ALERT-BOX QUESTION buttons yes-no
    TITLE "счет кассы" UPDATE cho.

            if cho then s_account_a = '100100'. else s_account_a = ''.
            if cho then s_account_b = ''. else s_account_b = '000061302'.
end.
end.

             /*if cho then '100100' else '',*/
             /*if cho then '' else '000061302',*/
*/

{comm-arp1.i}

/*--------------------------------------------------------------------------------------------------*/




hide all.
do transaction:
for each p_f_payment where txb = seltxb and date = dat and  uid = uu and stcif = 0 and p_f_payment.deluid = ?:
    ACCUMULATE p_f_payment.amt + p_f_payment.comiss (total).
    ACCUMULATE p_f_payment.amt (total).
end.

tsum = ( accum total p_f_payment.amt + p_f_payment.comiss ).
tsum_0 = accum total p_f_payment.amt.


if tsum <> 0 then do:
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

            run setcsymb (s-jh, 100).
            run jou.

            for each p_f_payment where txb = seltxb and date = dat and stcif = 0  and uid = uu and p_f_payment.deluid = ?:
                update  p_f_payment.stcif = 1.
            end.

            run vou_bank(2).


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
else do:
    MESSAGE "Необработанные платежи не найдены."
    VIEW-AS ALERT-BOX INFORMATION BUTTONS ok
    TITLE "Внимание".
end.
end.
