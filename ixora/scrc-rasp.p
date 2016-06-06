/* scrc-rasp.p
 * MODULE
        Рассылка опорных курсов по филиалам
 * DESCRIPTION
        Описание
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
        19.04.2011 aigul
 * BASES
        BANK TXB
 * CHANGES
*/

def input parameter file1 as char.
for each txb.ofcsend where txb.ofcsend.typ = "oporn" no-lock:
    run mail(txb.ofcsend.ofc + "@metrocombank.kz", "BANK <abpk@metrocombank.kz>", "Опорные курсы", "", "", "",file1).
end.

