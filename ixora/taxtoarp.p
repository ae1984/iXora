/* taxtoarp.p
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

/* taxtoarp.p
 * Модуль
     Коммунальные (налоговые) платежи
 * Назначение
     Процедура зачисления налоговых платежей на АРП счета
 * Применение
     Применяется при зачислении налоговых платежей на АРП счета

 * Вызов
     В данной процедуре вызывается процедура commpl, в которой происходит генерация REMTRZ
 * Меню


 * Автор
     pragma
 * Дата создания:
     04.05.03
 * Изменения
     04.05.03 koval разделение по филиалам
     07.07.03 kanat добавил новый параметр при вызове процедуры commpl - РНН плательщика для таможенных платежей, по - умолчанию ставятся пустые кавычки
     24.07.03 kanat касса в пути - только для департаментов из sysc.chval = "cstdtp"
     31.07.03 kanat добавил новый параметр при вызове процедуры commpl
     19.05.2004 valery - перенес зачисление на АРП на кассы в пути в - comm-arp1.i
     26.05.2004 kanat - добавил проверку на КНП по квитанциям
     28.05.2004 kanat - Для филиала в г. Уральск ордера печатаются по - умолчанию.
        24/05/06   marinav  - добавлен параметр даты факт приема платежа
        01.02.2012 lyubov - изменила символ кассплана (260 на 130)
*/

{global.i}
{get-dep.i}
{deparp.i}
{comm-txb.i}
{sysc.i}

def var ourbank as char.
def var ourcode as integer.
ourbank = comm-txb().
ourcode = comm-cod().

def new shared var s-jh like jh.jh.
def var dat as date.
def var uu as char.
def var tsum as decimal.
def var tsum_wc as decimal.
def var cho as logical init false.
define variable seltxb     as integer .

def var i_temp_dep as integer.
def var s_dep_cash as char.
def var s_account_a as char.
def var s_account_b as char.


dat = g-today.

update dat label ' Укажите дату ' format '99/99/9999' skip
with side-label row 5 centered frame dataa .
update uu label ' Укажите имя кассира ' format 'x(8)' skip
with side-label row 5 centered frame uuuu .

if get-dep(uu, dat) = ? then do:
message "Неверное имя кассира" VIEW-AS ALERT-BOX.
    return.
end.

i_temp_dep = get-dep (uu, dat).

if deparp(i_temp_dep) = ? then do:
    message "Не настроен транзитный счет департамента" VIEW-AS ALERT-BOX.
    return.
end.





/* kanat Касса или касса в пути для отдельных департаментов sysc.sysc = "csptdp" */




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
run sel('Укажите счет кассы', 'Касса        100100|Касса в пути 100200').
            if return-value = '1' then s_account_a = '100100'. else s_account_a = ''.
            if return-value = '1' then s_account_b = ''. else s_account_b = '000061302'.
end.
end.
*/

{comm-arp1.i}


/* --------------------------------------------------- */
/*
                    if return-value = '1' then '100100' else '',
                    if return-value = '1' then '' else '000061302',
*/



for each tax where date = dat and taxdoc = ? and uid = uu and duid = ? and comm.tax.txb = ourcode no-lock:
    find first codfr where codfr.codfr = 'spnpl' and (codfr.code = string(intval[1],"999") or string(intval[1],"999") = "000") no-lock no-error.
    if avail codfr then do:
    ACCUMULATE tax.comsum + tax.sum (total).
    ACCUMULATE tax.sum (total).
    end.
    else do:
    message "Квитанция N " string(dnum) " введена с неправильным КНП " string(intval[1],"999") view-as alert-box title "Внимание".
    return.
    end.
end.

tsum    = ( accum total tax.comsum + tax.sum ).
tsum_wc = ( accum total tax.sum ).

do transaction:

if tsum <> 0 then do:
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
                    deparp(i_temp_dep),
                    'Зачисление на транзитный счет',
                    '14','11','856').

                    if return-value = '' then undo, return.

                    s-jh = int(return-value).
                    run setcsymb.p(s-jh, 130).
                    run jou.
                    if return-value = "" then undo, return.
                    message "Обработка квитанций, ждите...". pause 0.

                    find first comm.tax where comm.tax.date = dat and comm.tax.taxdoc = ? and comm.tax.duid = ? and
                                              comm.tax.uid = uu and comm.tax.txb = ourcode exclusive-lock no-error.
                    do while true:
                        if not avail comm.tax then leave.
                        comm.tax.taxdoc = return-value.
                        find next comm.tax where comm.tax.date = dat and comm.tax.taxdoc = ? and comm.tax.duid = ? and
                                                 comm.tax.uid = uu and comm.tax.txb = ourcode exclusive-lock no-error.
                    end.
                    release comm.tax.

                    if ourcode = 2 then
                    do:
                            run vou_bank(1). pause 0.
                    end.
                    else
                    do:
                        run vou_bank(2). pause 0.
                     end.

                    hide message. pause 0.

            find first comm.txb where comm.txb.txb = ourcode and comm.txb.visible no-lock.

            if comm.txb.city <> ourcode then do:
                           /* Если филиал */
                           /* Отправка платежа в головной офис */

                          find first cmp no-lock.

                          run commpl(
                               ourcode,
                               tsum_wc,
                               deparp(i_temp_dep),
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
                                              comm.tax.uid = uu and comm.tax.txb = ourcode exclusive-lock no-error.
                    do while true:
                        if not avail comm.tax then leave.
                        comm.tax.senddoc = return-value.
                        find next comm.tax where comm.tax.date = dat and comm.tax.taxdoc <> ? and comm.tax.senddoc = ? and comm.tax.duid = ? and
                                                 comm.tax.uid = uu and comm.tax.txb = ourcode exclusive-lock no-error.
                    end.
                    release comm.tax.
            end.

        end.
        when false then undo.
    end case.
end.
else do:
    MESSAGE "Необработанные платежи не найдены."
    VIEW-AS ALERT-BOX INFORMATION BUTTONS ok
    TITLE "Внимание".
end.
end.
