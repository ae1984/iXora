/* chk_rmzink.p
 * MODULE
        проверка rmz по ир
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
        23/09/2011 evseev
 * BASES
        COMM TXB
 * CHANGES

*/

for each txb.remtrz where txb.remtrz.source = 'INK' and  txb.remtrz.racc = 'KZ24070105KSN0000000' and txb.remtrz.rdt >= today - 5 and txb.remtrz.jh1 = ?  no-lock:
   if (time - txb.remtrz.rtim) <= 1200 then next.
   find first txb.que where txb.que.remtrz = txb.remtrz.remtrz no-lock no-error.
   if not avail txb.que then next.
   if txb.que.pid = 'F' or txb.que.pid = 'ARC' then next.
   run mail("id00787@metrocombank.kz", "METROCOMBANK <abpk@metrocombank.kz>", "ОШИБКА: RMZ завис",
           txb.remtrz.remtrz + " " + txb.remtrz.sacc , "1", "", "").
end.
