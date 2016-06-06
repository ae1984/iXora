/* pmpmarp.p
 * MODULE
        Пенсионные платежи (соц. отчисления)
 * DESCRIPTION
        Зачисление на транзитный счет
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
        18/01/05 kanat
 * CHANGES
        19/01/05 kanat - АРП счета для соц. отчислений берутся по департаментам
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

i_temp_dep = int (get-dep(uu, dat)).
{comm-arp1.i}

hide all.
do transaction:
for each commonpl where commonpl.txb = seltxb and
                        commonpl.date = dat and
                        commonpl.uid = uu and
                        commonpl.grp = 15 and
                        commonpl.joudoc = ? and
                        commonpl.deluid = ? no-lock.
    ACCUMULATE commonpl.sum + commonpl.comsum (total).
    ACCUMULATE commonpl.sum (total).
end.

tsum = ( accum total commonpl.sum + commonpl.comsum ).
tsum_0 = accum total commonpl.sum.

if tsum <> 0 then do:
    MESSAGE "Сформировать кассовый ордер на сумму " tsum " тенге."
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
    TITLE "Платежи соц. отчислений" UPDATE choice3 as logical.
    case choice3:
        when true then do:

            find first commonls where commonls.txb = seltxb and commonls.visible = no and commonls.grp = 15 no-lock use-index type.

            run trx (
            6,                                          /* 150904824 - TXB01 */
            tsum,
            1,
            s_account_a, /*if cho then '100100' else '',*/
            s_account_b, /*if cho then '' else '000061302',*/
            '',
            deparp_pmp(get-dep(uu,dat)),
            'Зачисление на транзитный счет','14',commonls.kbe,'856').

            if return-value = '' then undo, return.
            s-jh = int(return-value).

            run setcsymb (s-jh, 100).
            run jou.

            for each commonpl where commonpl.txb = seltxb and
                                    commonpl.date = dat and
                                    commonpl.grp = 15 and
                                    commonpl.joudoc = ? and
                                    commonpl.uid = uu and
                                    commonpl.deluid = ?:
                update  commonpl.joudoc = return-value.
            end.

            run vou_bank(2).

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

