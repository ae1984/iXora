/* runlcmt.p
 * MODULE

 * DESCRIPTION
   импорт swift-сообщений по аккредитивам и чистка каталога
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        28.01.2011 id00810
 * BASES
        BANK
 * CHANGES
    01/02/2011 id00810 - перекомпиляция
    04/02/2011 id00810 - архив без сохранения пути
*/

{global.i}
def var filestr as char.
def var v-dir   as char format 'x(20)'.
def var v-dir1   as char format 'x(20)'.

find first sysc where sysc.sysc = "lcmt" no-lock no-error.
if not avail sysc then do:
    create sysc.
    sysc.sysc = "lcmt".
    sysc.des = "Дата архивации каталога /swift/out".
    sysc.daval = g-today - 1.
    find current sysc no-lock.
end.

if sysc.daval < g-today then do:
    run LCMT_ps.
    filestr = "lc" + string(day(g-today), "99") + "-" + string(month(g-today), "99") + "-" +
                        substr(string(year(g-today), "9999"), 3, 2).

    unix silent value ("cd /swift/out/; tar cvf " + filestr + ".tar" + " * > /dev/null; gzip -9 " + filestr + ".tar > /dev/null;
    mv " + filestr + ".tar.gz" + " " + "/swift/archiv/  > /dev/null; rm -f * ").

    find current sysc exclusive-lock.
    sysc.daval = g-today.
    find current sysc no-lock.
end.



