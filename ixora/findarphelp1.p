/* findarphelp1.p
 * MODULE
        Название модуля
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

 * BASES

 * CHANGES
                07.12.2011 Luiza
*/

define shared temp-table tempch
       field tempch as char
       field tempdes as char
       field tempswibic as char
       field tempcrc as int
       field temprnn as char.

find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
find first txb.cmp no-lock no-error.
for each txb.arp where txb.arp.gl = 287032 and txb.arp.crc = 1 and txb.arp.des  MATCHES '*вх*' and length(txb.arp.arp) >= 20 no-lock.
    create tempch.
    tempch.tempch = txb.arp.arp.
    tempch.tempdes = txb.arp.des.
    tempch.tempswibic = txb.sysc.chval.
    tempch.tempcrc = txb.arp.crc.
    tempch.temprnn = txb.cmp.addr[2].

end.

