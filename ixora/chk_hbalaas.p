/* chk_hbalaas.p
 * MODULE
        сверка aaa.hbal c SUM(aas.chkamt)
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
        30/06/2011 evseev
 * BASES
        COMM TXB
 * CHANGES
        03/08/2011 evseev - добавил if length(aaa.aaa) <> 20 then next.
        08/09/2011 evseev - исправил length(aaa.aaa) на length(txb.aaa.aaa)
        05/10/2011 evseev - изменил на txb.aaa.hbal <> 0
*/

def var v-chkamt like txb.aas.chkamt.
for each txb.aaa where txb.aaa.hbal <> 0 and txb.aaa.sta <> "C" and txb.aaa.sta <> "E" no-lock:
    if length(txb.aaa.aaa) <> 20 then next.
    v-chkamt = 0.
    for each txb.aas where txb.aas.aaa = txb.aaa.aaa no-lock:
       v-chkamt = v-chkamt + txb.aas.chkamt.
    end.
    if txb.aaa.hbal <> v-chkamt then
        run mail("id00787@metrocombank.kz", "METROCOMBANK <abpk@metrocombank.kz>", "ОШИБКА: Заморозка не верна",
            txb.aaa.aaa + " sum(aas.chkamt) = " + string(v-chkamt) + ";  aaa.hbal = " + string(txb.aaa.hbal), "1", "", "").
end.
