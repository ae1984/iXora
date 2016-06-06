/* vc_send.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
 * RUN
        v-stat2.p
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        28.05.2012 aigul
 * BASES
        BANK COMM
 * CHANGES
*/
{global.i}
for each vcblock where vcblock.sts = "b"  no-lock:
    if g-today - vcblock.rdt >= 170 then do:
        find txb where txb.consolid = true and txb.bank = vcblock.bank no-lock no-error.
        if avail txb then do:
            if connected ("txb") then disconnect "txb".
            connect value(" -db " + replace(txb.path,"/data/","/data/b") + " -ld txb -U " + txb.login + " -P " + txb.password).
                run send_vc1("1", vcblock.remtrz).
            if connected ("txb") then disconnect "txb".
        end.
    end.
    if g-today - vcblock.rdt >= 181 then do:
        find txb where txb.consolid = true and txb.bank = vcblock.bank no-lock no-error.
        if avail txb then do:
            if connected ("txb") then disconnect "txb".
            connect value(" -db " + replace(txb.path,"/data/","/data/b") + " -ld txb -U " + txb.login + " -P " + txb.password).
                run vc_send1("2", vcblock.remtrz, txb.name, g-today - vcblock.rdt).
            if connected ("txb") then disconnect "txb".
        end.
    end.
end.


