/* tets_counters.p 
 * MODULE
        Закрытие операционного дня банка
 * DESCRIPTION
        Проверка наших счетчиков
 * RUN
        из dayclose при закритии дня
 * CALLER
        dayclose
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        09.06.05 suchkov
 * CHANGES
        06.10.05 suchkov - Расширил границы предупреждений.
*/

find nmbr where nmbr.prefix = "RMZ" no-lock no-error . 
if available nmbr and nmbr.nmbr > 990000 then run mail("it@elexnet.kz", "", "ВНИМАНИЕ!!!", "Счетчик RMZ достиг " + string(nmbr.nmbr), "", "", "").
/*if nmbr.nmbr > 9 then run mail("suchkov@elexnet.kz", "", "ВНИМАНИЕ!!!", "Счетчик RMZ достиг " + string(nmbr.nmbr), "", "", "").*/

if current-value (journal) > 990000 then run mail("it@elexnet.kz", "", "ВНИМАНИЕ!!!", "Счетчик JOUDOC достиг " + string(current-value(journal)), "", "", "").
/*if current-value (journal) > 9 then run mail("suchkov@elexnet.kz", "", "ВНИМАНИЕ!!!", "Счетчик JOUDOC достиг " + string(current-value(journal)), "", "", "").*/

if current-value (jhnum) > 99900000 then run mail("it@elexnet.kz", "", "ВНИМАНИЕ!!!", "Счетчик транзакций достиг " + string(current-value(jhnum)), "", "", "").
/*if current-value (jhnum) > 9 then run mail("suchkov@elexnet.kz", "", "ВНИМАНИЕ!!!", "Счетчик транзакций достиг " + string(current-value(jhnum)), "", "", "").*/

if current-value (unijou) > 990000 then run mail("it@elexnet.kz", "", "ВНИМАНИЕ!!!", "Счетчик UJO достиг " + string(current-value(unijou)), "", "", "").
/*if current-value (unijou) > 9 then run mail("suchkov@elexnet.kz", "", "ВНИМАНИЕ!!!", "Счетчик UJO достиг " + string(current-value(unijou)), "", "", "").*/
