/* TS_ps.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        07.06.2012 evseev - отструктурировал код
		17.10.2013 madiyar - изменил для обработки всх платежей на очереди, а не по одному
*/

/* {global.i}     */
 {lgps.i }
def var exitcod as char.
def var v-sqn as char.
def buffer b-que for que.
def var retcode as char no-undo.
def var logtext as char no-undo.

for each que where que.pid = m_pid and que.con = "W" use-index fprc no-lock:

    retcode = "-1".
    do transaction:
        find first b-que where b-que.remtrz = que.remtrz exclusive-lock no-error no-wait.
        if avail b-que then do:
            que.dw = today.
            que.tw = time.
            que.con = "P".

            find first remtrz where remtrz.remtrz = que.remtrz no-lock no-error.
            if avail remtrz then do:
                find jh where jh.jh = remtrz.jh1 no-lock no-error.
                if not available jh then do:
                    retcode = "10".
                    logtext = " Ошибка ! 1 проводка не найдена " + remtrz.remtrz.
                end.
                else do:
                    if remtrz.jh2 ne ? then do :
                        find jh where jh.jh = remtrz.jh2 no-lock no-error.
                        if not available jh then do:
                            retcode = "10".
                            logtext = " Ошибка ! 2 проводка не найдена " + remtrz.remtrz.
                        end.
                    end.
                end.

                que.dp = today.
                que.tp = time.
                que.con = "F".

                if retcode = "-1" then do:
                    if remtrz.jh2 = ? then do:
                        find first bankl where bankl.bank = remtrz.rbank no-lock no-error.
                        if avail bankl and bankl.acct <> "" and not bankl.acct begins "#"  then retcode = "4" . else retcode = "0".
                    end.
                    else retcode = "2".
                    logtext = remtrz.remtrz + " обработан код завершения = " + retcode.
                end.
                que.rcod = retcode.
                v-text = logtext.
                run lgps.
            end. /* if avail remtrz */
        end. /* if avail b-que */
    end. /* transaction */

end.


