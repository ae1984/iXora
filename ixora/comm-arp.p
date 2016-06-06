/* comm-arp.p
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
        25/03/2005 kanat - перекомпиляция
*/

/* comm-arp.p
 * Модуль
     Коммунальные платежи 
 * Назначение
     Процедура зачисления платежей АЛМА ТВ
 * Применение
     Применяется при непосредственном зачислении платежей на АРП
  
 * Вызов
     В данной процедуре вызывается процедура commpl, в которой происходит генерация REMTRZ
 * Меню
     3.2.10.9 Зачисление платежей на АРП

 * Автор
     pragma
 * Дата создания:
     27.06.03
 * Изменения
     07.07.03 kanat добавил новый параметр при вызове процедуры commpl - РНН плательщика для таможенных платежей, по - умолчанию ставятся пустые кавычки 
     24.07.02 kanat добавил зачисление на кассу в пути по департаментам по sysc.chval = "csptdp"
     13.05.04 valery Добавил автоматическое переключение с кассы 100100 на кассу в пути 100200 после 18:00, 
                     возможность выбора Касса или Кассы в пути между 18:00 и 17:00,
                     до 17:00 всегда будет использоваться только Касса 100100,
                     а также добавлена проверка на блокировку кассы.
     17.05.2004 nadejda - при переключении на счет 100200 счет кассы в пути выбирается свой для каждого департамента
     19.05.2004 valery - перенес последние два изменения в отдельную "ишку" - comm-arp1.i
     30.03.2005 kanat - перекомпиляция
        24/05/06   marinav  - добавлен параметр даты факт приема платежа
     28.07.2006 dpuchkov - добавил обработку прочих платежей Алматытелеком.
     10.08.2006 dpuchkov - вынес АРП по прочим платежам в SYSC
*/

{global.i}
{comm-txb.i}
def var seltxb as int.
seltxb = comm-cod().

{get-dep.i}
{deparp.i}
{sysc.i}

def new shared var s-jh like jh.jh.
def var dat as date                    no-undo.
def var uu as char                     no-undo.
def var s-arp as char                  no-undo.
def var tsum as decimal                no-undo.
def var tsum_wc as decimal             no-undo.
def var cho as logical init false      no-undo. 

def var i_temp_dep as integer          no-undo.
def var s_dep_cash as char             no-undo.

def var s_account_a as char            no-undo.
def var s_account_b as char            no-undo.



dat = g-today.

update dat    label ' Укажите дату ' format '99/99/9999'  skip
       uu     label ' Имя кассира  ' format 'x(8)' skip
with side-label row 6 centered frame uuuu .

i_temp_dep = int (get-dep (uu, dat)).

if i_temp_dep = ? then do:
    message "Неверное имя кассира" VIEW-AS ALERT-BOX.
    return.
end.
        
if deparp(i_temp_dep) = ? then do:
    message "Не настроен транзитный счет департамента" VIEW-AS ALERT-BOX.
    return.
end.

{comm-sel.i}


if selarp = "" then do:
    MESSAGE "Не выбран АРП-счет." VIEW-AS ALERT-BOX TITLE "Внимание".
    return.
end.



{comm-arp1.i}  /* --------- valery 19/05/04 ----------- */

do transaction:
for each commonpl where commonpl.txb    = seltxb and
                        commonpl.date   = dat    and 
                        commonpl.joudoc = ?      and 
                        commonpl.uid    = uu     and 
                        commonpl.deluid = ?      and 
                        commonpl.arp    = selarp and 
                        commonpl.grp    = selgrp
                        no-lock:
    ACCUMULATE commonpl.comsum + commonpl.sum (total).
    ACCUMULATE commonpl.sum (total).
end.
tsum = (accum total commonpl.comsum + commonpl.sum).
tsum_wc = ( accum total commonpl.sum ).

def buffer b-syscarp for sysc.
find last b-syscarp where b-syscarp.sysc = "ATARP" no-lock no-error.

if selarp = b-syscarp.chval then do:
/*if selbn = "АлматыТелеком Прочие" then do:*/
    for each commtk where commtk.txb    = seltxb and
                            commtk.date   = dat    and 
                            commtk.joudoc = ?      and 
                            commtk.uid    = uu     and 
                            commtk.deluid = ?      and 
                            commtk.arp    = selarp and 
                            commtk.grp    = selgrp
                            no-lock:
        ACCUMULATE commtk.comsum + commtk.sum (total).
        ACCUMULATE commtk.sum (total).
    end.
    tsum = (accum total commtk.comsum + commtk.sum).
    tsum_wc = ( accum total commtk.sum ).
end.


if tsum <> 0 then do:
    MESSAGE "Сформировать кассовый ордер на сумму " tsum " тенге?"
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
    TITLE "Внимание" UPDATE choice3 as logical.
    case choice3:
        when true then do:

            find first commonls where commonls.txb = seltxb and commonls.arp = selarp and 
                       commonls.visible = yes and commonls.grp = selgrp no-lock use-index type.

            run trx(
            6, 
            tsum, 
            1, 
            s_account_a, /*if return-value = '1' then '100100' else '',*/ 
            s_account_b, /*if return-value = '1' then '' else '000061302',*/ 
            '', 
            selarp, 
            'Зачисление на транзитный счет',
            '14',commonls.kbe,'856').
            
            if return-value = '' then undo, return.
            
            s-jh = int(return-value).            
            run setcsymb (s-jh, commonls.symb).
            run jou.
            if return-value begins "Not cash" then do:
                message "Возможно, что произошла ошибка при зачислении!" skip
                   "свяжитесь с Департаментом Информационных Технологий"
                        view-as alert-box title "ВНИМАНИЕ".
                undo, return.
            end.
            if return-value = "" then undo, return.
            for each commonpl where txb = seltxb and date = dat and arp = selarp and joudoc = ? and uid = uu and commonpl.deluid = ? and commonpl.grp = selgrp exclusive-lock:
                assign commonpl.joudoc = return-value.
            end.


/*if selbn = "АлматыТелеком Прочие" then do:*/
if selarp = b-syscarp.chval then do:
   for each commtk where txb = seltxb and date = dat and arp = selarp and joudoc = ? and uid = uu and commtk.deluid = ? and commtk.grp = selgrp exclusive-lock:
       assign commtk.joudoc = return-value.
   end.
end.


            run vou_bank(2).

            find first comm.txb where comm.txb.txb = seltxb and comm.txb.visible and comm.txb.consolid no-lock.

            if comm.txb.city <> seltxb then do:

                          find first cmp no-lock.
                          run commpl(
                               seltxb,
                               tsum_wc,
                               deparp(i_temp_dep),
                               "TXB" + string(comm.txb.city,"99"),
/*                             comm.txb.commarp, */
                               selarp,
                               0,                     
                               no,
                               trim(cmp.name),
                               cmp.addr[2],
/*                             "919",
                               "14",
                               "14", */
                               commonls.knp,
                               commonls.kod,
                               commonls.kbe,
                               'Зачисление на транзитный счет коммун.пл.',
                               "1P",
                               1,
                               5,
                               "","",
                               dat).

            for each commonpl where txb = seltxb and date = dat and arp = selarp and rmzdoc = ? and uid = uu and commonpl.deluid = ? and commonpl.grp = selgrp and joudoc <> ? exclusive-lock:
                assign commonpl.rmzdoc = return-value.
            end.
if selarp = b-syscarp.chval then do:
/*if selbn = "АлматыТелеком Прочие" then do:*/
            for each commtk where txb = seltxb and date = dat and arp = selarp and rmzdoc = ? and uid = uu and commtk.deluid = ? and commtk.grp = selgrp and joudoc <> ? exclusive-lock:
                assign commtk.rmzdoc = return-value.
            end.
end.

           end.

        end.

        when false then undo.

        end case.
end. /* tsum */
else do:
    MESSAGE "Необработанные платежи не найдены."
    VIEW-AS ALERT-BOX INFORMATION BUTTONS ok
    TITLE "Внимание".
end.
end.
