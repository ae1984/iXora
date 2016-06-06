/* iovyp6.p
 * MODULE
        Интернет-банкинг
 * DESCRIPTION
        Обработка инкассовых для интернет банкинга.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU

 * BASES
        BANK COMM TXB
 * AUTHOR
        10/02/10 id00004
 * CHANGES
        06/10/10 id00004 для отображения добавлены инкассовые которые регистрируются вручную
        02.01.2013 damir - Переход на ИИН/БИН. Оптимизация кода.
        28.01.2013 damir - <Доработка выписок, выгружаемых в DBF - файл>. Оптимизация кода.
*/
{iovypshared.i}

def input parameter pExtid as char no-undo.

def var v_ost as decimal.
def var v-stat  as char init ["err|paid|pay|returned|blk|K2_sent|recall|wait|accept|"].
def var v-stat2 as char init ["Ошибка|Оплачено||Возвращено|Заблокировано|Поставлено в картотеку|Отозвано|Получено после 18:00|Обрабатывается|"].
def var v-sts   as char init ["00|01|03|11|12|13|14|15|16|20|21|22|err"].
def var v-sts2  as char init ["Обрабатывается|Принят|К-2|Клиент не найден|Счет не найден|Cчет закрыт|Недопустимый КБК|Недопустимый ЕКНП|Неверный РНН|Не найдено ИР|Возврщено банком|ИР оплачено|Ошибка|"].
def var v-recall_reason  as char init ["01|03|04|05|06|07|"].
def var v-recall_reason2 as char init ["Банкротство|Закрытие счета|Уменьшение|Ликвидация|Оплата|Реабилитация|"].
def var v-vo   as char init ["03|04|05|07|09"].
def var v-vo2  as char init ["Налог|Налог.дебит.|Тамож|ОПВ|СО"].

find last txb.sysc where txb.sysc.sysc = "OURBNK" no-lock no-error.
find last txb.cif where txb.cif.cif = pExtid no-lock no-error.
if avail txb.cif then do:
    for each txb.aaa where txb.aaa.cif = txb.cif.cif  no-lock:
        find last txb.crc where txb.crc.crc = txb.aaa.crc no-lock no-error.
        if length(txb.aaa.aaa) > 15 and txb.aaa.sta <> "C" then do:
            for each inc100 where inc100.bank = txb.sysc.chval and inc100.iik = txb.aaa.aaa no-lock:
                create t-ink.
                t-ink.aaa = txb.aaa.aaa.
                t-ink.currency = txb.crc.code.
                t-ink.datetime = string(inc100.rdt, "99/99/9999") + " " + string(inc100.rtm, "hh:mm") .
                t-ink.summa = string(inc100.sum, ">>>,>>>,>>>,>>>,>>9.99").
                t-ink.vid_operacii = string(inc100.bnf).
                t-ink.kbk = string(inc100.kbk).
                t-ink.num = string(inc100.num).
                t-ink.ink_status = entry(lookup(inc100.mnu, v-stat, "|"), v-stat2, "|").
            end.
            for each txb.aas where txb.aas.aaa = txb.aaa.aaa and lookup(string(aas.sta), "4,5,15,6,7,8,9") <> 0 no-lock:
                create t-ink.
                t-ink.aaa = string(txb.aas.aaa).
                t-ink.currency = string(txb.crc.code).
                t-ink.datetime = string(txb.aas.regdt).
                t-ink.summa = string(txb.aas.docprim).
                if txb.aas.sta = 9 or txb.aas.sta = 15 then t-ink.vid_operacii = string(txb.aas.bnfname).
                else t-ink.vid_operacii = string(txb.aas.bnf).
                t-ink.ink_status =  string(txb.aas.irsts).
                t-ink.kbk =  string(txb.aas.kbk).
                t-ink.num =  string(txb.aas.fnum).
            end.
        end.
    end.
    create t-ink.
    t-ink.aaa = "".
    t-ink.currency = "".
    t-ink.datetime = "".
    t-ink.summa = "".
    t-ink.vid_operacii = "".
    t-ink.ink_status = "".
    t-ink.kbk = "".
    t-ink.num = "".
end.