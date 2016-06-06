/* vccompare-send.p
 * MODULE
        Название модуля - Валютный контроль.
 * DESCRIPTION
        Описание - Сверка оборотов по счету клиента и платежей Валютного Контроля.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        16.01.2012 aigul
 * BASES
        BANK COMM TXB
 * CHANGES
        17.01.2012 AIGUL - добвила ВК в рассылку для Алматы.
        20.01.2012 aigul - убрала себя из рассылки
        26.01.2012 aigul - email to id00661
        22.05.2012 aigul - заменила macthes на begins
        29.01.2013 damir - Полностью переделал. Оптимизация кода. Внедрено Техническое Задание.
*/

def input parameter p-bank as char.
def input parameter p-file as char.

unix silent value ("cp " + p-file + " rep_temp.xls").
unix silent value ("un-win rep_temp.xls Reconciliation_of_payments.xls").

for each txb.ofc where trim(txb.ofc.exp[1]) matches "*p00136*" or trim(txb.ofc.exp[1]) matches "*p00121*" no-lock:
    run mail(txb.ofc.ofc + "@metrocombank.kz", "BANK <abpk@metrocombank.kz>","Сообщение от ДВК филиалу",
    "ВНИМАНИЕ! В вашем филиале есть платежи, которые не прошли сверку с о счетом клиента! Устраните несоответствие!",
    "", "","Reconciliation_of_payments.xls").
end.


