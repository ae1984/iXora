/* chk_rmzink0.p
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
        BANK COMM
 * CHANGES
        25/04/2012 evseev  - rebranding. Название банка из sysc или изменил проверку банка или рко
*/

def var v-path as char no-undo.

{global.i}

           /*9:01              18:00  */
if (time >= 32500) and (time < 64800) and (g-today = today) then do:
        find first bank.cmp no-lock no-error.
        if not avail bank.cmp then do:
            message " Не найдена запись cmp " view-as alert-box error.
            return.
        end.

        if bank.cmp.name matches "*МКО*" then v-path = '/data/'.
        else v-path = '/data/b'.

        for each comm.txb where comm.txb.consolid = true no-lock:

            if connected ("txb") then disconnect "txb".
            connect value(" -db " + replace(comm.txb.path,'/data/',v-path) + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).

           run  chk_rmzink.
        end.
end.

