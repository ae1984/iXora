/* a_filpplist.p
 * MODULE
        ОД
 * DESCRIPTION
        Список длительных платежных поручений
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
        16/07/2013 Luiza ТЗ № 1738
 * BASES
        BANK COMM
 * CHANGES
*/

{global.i}

define shared var s-target as date.
def var v-bank   as char no-undo.

find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
    message "Нет параметра ourbnk sysc! модуль a_filpplist.p" view-as alert-box.
    return.
end.
v-bank = sysc.chval.

for each pplist where pplist.txb = v-bank no-lock. /* переместим в историю */
    create pplisthis.
    buffer-copy pplist to pplisthis.
end.
for each pplist where pplist.txb = v-bank exclusive-lock. /*обработанные удалим */
    delete pplist.
end.
for each ppout where ppout.con and ppout.del = no no-lock.

    if ppout.opl = 1 then do: /* вид оплаты постоянно  */
        if ppout.dtcl >= s-target and DATE( month(g-today), ppout.dtop, year(g-today)) > g-today and DATE( month(g-today), ppout.dtop, year(g-today)) <= s-target then do:
            find first pplist where pplist.txb = v-bank and pplist.id = ppout.id and pplist.aaa = ppout.aaa no-lock no-error.
            if not available pplist then do:
                create pplist.
                pplist.txb       = v-bank.
                pplist.id        = ppout.id.
                pplist.cif       = ppout.cif.
                pplist.stat      = "Новый".
                pplist.aaa       = ppout.aaa.
                pplist.crc       = ppout.crc.
                pplist.sum       = ppout.sum.
                pplist.who       = "".
                pplist.dtout     = s-target.
                pplist.timout    = 0.        /* время отправки */
                pplist.dtin      = ?.        /* дата обработки ответа */
                pplist.timin     = 0.        /* время обработки ответа */
                pplist.opl       = ppout.opl .
                pplist.id        = ppout.id.
                pplist.nom       = ppout.nom .
                pplist.dtnom     = ppout.dtnom .
            end.
        end.
    end.
    if ppout.opl = 2 then do: /* оплата по графику */
        for each ppgraf where ppgraf.id = ppout.id and ppgraf.cif = ppout.cif and ppgraf.aaa = ppout.aaa and ppgraf.dat > g-today and ppgraf.dat <= s-target no-lock.
            find first pplist where pplist.txb = v-bank and pplist.id = ppout.id and pplist.aaa = ppout.aaa no-lock no-error.
            if not available pplist then do:
                create pplist.
                pplist.txb       = v-bank.
                pplist.id        = ppout.id.
                pplist.cif       = ppout.cif.
                pplist.stat      = "Новый".
                pplist.aaa       = ppout.aaa.
                pplist.crc       = ppout.crc.
                pplist.who       = ppout.who.
                pplist.sum       = ppgraf.sum.
                pplist.dtout     = ppgraf.dat.
                pplist.timout    = 0.        /* время отправки */
                pplist.dtin      = ?.        /* дата обработки ответа */
                pplist.timin     = 0.         /* время обработки ответа */
                pplist.opl       = ppout.opl .
                pplist.id        = ppout.id.
                pplist.nom       = ppout.nom .
                pplist.dtnom     = ppout.dtnom .
            end.
        end.
    end.
end.
if v-bank = "TXB00" then do:
    find first sysc where sysc.sysc = "ppout10" exclusive-lock no-error.
    if not avail sysc  then do:
        message  " Нет параметра ppout10 в sysc!" view-as alert-box.
        return.
    end.
    sysc.loval = no.
    sysc.inval = 0.
    find first sysc where sysc.sysc = "ppout10" no-lock no-error.

    find first sysc where sysc.sysc = "ppout13" exclusive-lock no-error.
    if not avail sysc  then do:
        message  " Нет параметра ppout13 в sysc!" view-as alert-box.
        return.
    end.
    sysc.loval = no.
    sysc.inval = 0.
    find first sysc where sysc.sysc = "ppout13" no-lock no-error.
end.

