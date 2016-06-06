/* crcclose.p
 * MODULE
        блокировка валют
 * DESCRIPTION
        В закрытии дня блокируем валюты, что бы на следующий день
        не было возможности провести наличный обмен валюты
        до выставления курса покупки и продажи валют .
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
        05/04/2013 Luiza - ТЗ 1764
 * BASES
        BANK
 * CHANGES
        09/04/2013 Luiza - ТЗ 1764
*/


do transaction:
    find sysc where sysc.sysc = "SCRC-ORDER" exclusive-lock no-error.
    if available sysc then do:
        sysc.daval = today.
        sysc.loval = yes.
    end.
    find sysc where sysc.sysc = "SCRC-ORDER" no-lock no-error.
end.

