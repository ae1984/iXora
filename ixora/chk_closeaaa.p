/* chk_closeaaa.p
 * MODULE
        проверка на наличие арестов на закрытых счетах
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
        23/11/2011 evseev
 * BASES
        COMM TXB
 * CHANGES
        19/04/2012 evseev - исправил орфоошибку
        03/05/2012 evseev - проверка только по статусу С
*/

for each txb.aaa where txb.aaa.sta = "C" no-lock:
    if length(txb.aaa.aaa) <> 20 then next.
    find first txb.aas where txb.aas.aaa = txb.aaa.aaa no-lock no-error.
    if avail txb.aas then
        run mail("id00787@metrocombank.kz", "METROCOMBANK <abpk@metrocombank.kz>", "ОШИБКА: На закрытом счете аресты",
            txb.aaa.aaa, "1", "", "").
end.
