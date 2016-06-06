/* qset.p
 * MODULE
        Процессы для работы с Sonic
 * DESCRIPTION
        Администрирование процессов для работы с Sonic
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
        05/03/2009 madiyar
 * BASES
        BANK COMM
 * CHANGES
        11/03/2009 madiyar - существенно расширена информация о процессе
        12/03/2009 madiyar - сделал кнопки для запуска и остановки процессов такие же, как в платежной системе
        19/03/2009 madiyar - мелкие исправления
        19/10/2009 madiyar - удаление из списка активных процессов несуществующих
        05/11/2009 madiyar - перекомпиляция
        06/11/2009 madiyar - добавил "мягкое" завершение процесса
        17/07/2010 madiyar - подправил сообщение
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
*/

{mainhead.i}

define query q_running for qproca.
define query q_existing for qproc.

def var v-rid as rowid.
def var choice as logical no-undo.
def var v-pid as char no-undo.
def var v-copy as integer no-undo.
def var v-scn as char no-undo.
def var v-scn_list as char no-undo init '---,\\\\\\,|||,///'.
def var i as integer no-undo.

def var new-pid as char no-undo.
def var new-des as char no-undo.
def var new-proc as char no-undo.
def var new-q as char no-undo extent 5.

def var new-shost as char no-undo.
def var new-sport as integer no-undo.
def var new-user as char no-undo.
def var new-password as char no-undo.
def var new-active as logi no-undo.
def var v-txt as char no-undo.
def var v-rneed as logi no-undo.

define browse b1 query q_running
       displ qproca.pid label "Код" format "x(8)"
             qproca.copy label "Copy" format ">>>9"
             qproca.u_pid label "UnixPID" format ">>>>>>9"
             qproca.terminate label "X" format "X/ "
             with 29 down overlay no-label title " Активные процессы ".

define browse b2 query q_existing
       displ qproc.pid label "Код" format "x(8)"
             qproc.des label "Описание" format "x(44)"
             qproc.proc label "Процедура" format "x(20)"
             with 29 down overlay no-label title " Зарегистрированные процессы ".

define frame ft b1 help "F1 - Помощь" b2 help "F1 - Помощь" skip(1) v-scn at 10 format "x(50)" with width 110 row 3 overlay no-label no-box.
define frame fnew
    new-pid label "Код       " format "x(8)" skip
    new-des label "Описание  " format "x(56)" skip
    new-proc label "Процедура " format "x(20)" skip(1)
    new-shost label "Сервер    " format "x(20)" skip
    new-sport label "Порт      " format ">>>,>>>,>>9" skip
    new-user label "Логин     " format "x(20)" skip
    new-password label "Пароль    " format "x(20)" skip(1)
    new-active label "Активный? " format "да/нет" skip(1)
    new-q[1] label "Очередь 1 " format "x(20)" skip
    new-q[2] label "Очередь 2 " format "x(20)" skip
    new-q[3] label "Очередь 3 " format "x(20)" skip
    new-q[4] label "Очередь 4 " format "x(20)" skip
    new-q[5] label "Очередь 5 " format "x(20)" skip(1)
    with title " Регистрация нового процесса " width 70 row 5 column 30 overlay side-labels.

def buffer b-qproc for qproc.
def buffer b-qproca for qproca.
def buffer b2-qproca for qproca.

procedure scn_refresh:
    i = i + 1.
    if i = 5 then i = 1.
    v-scn = entry(i,v-scn_list).
    v-rneed = no.
    for each b-qproca no-lock:
        v-txt = ''.
        input through value("ps -p " + trim(string(b-qproca.u_pid,">>>>>>>>>9")) + " -o pid").
        repeat:
            import unformatted v-txt.
            v-txt = trim(v-txt).
            if v-txt = 'pid' then v-txt = ''.
        end.
        input close.
        if v-txt = '' then do transaction:
            find first b2-qproca where rowid(b2-qproca) = rowid(b-qproca) exclusive-lock.
            delete b2-qproca.
            release b2-qproca.
            v-rneed = yes.
        end. /* transaction */
    end.
    displ v-scn with frame ft.
    if v-rneed then do:
        open query q_running for each qproca no-lock.
        reposition q_running to rowid v-rid no-error.
        if avail qproca then b1:refresh().
    end.
end procedure.

on "go" of b1 in frame ft or "go" of b2 in frame ft do:
    message "      Активные процессы                Зарегистрированные процессы         ~n~n" +
            "[Space]  - обновить                      [Space]  - обновить               ~n" +
            "[Insert] - запустить процесс             [Insert] - зарегистрировать новый ~n" +
            "[Ctrl+P] - запустить все процессы        [Delete] - удалить                ~n" +
            "[Delete] - остановить процесс            [Enter]  - редактировать          ~n" +
            "[Home]   - остановить все процессы                                         ~n" +
            "[Ctrl+D] - послать 'kill' процессу                                         ~n" +
            "[Ctrl+A] - послать 'kill' всем процессам                                   ~n~n"
    view-as alert-box information title "Помощь".
end. /* on "return" of b1 */

/* [Space]  - обновить */
on " " of b1 in frame ft or
   "return" of b1 in frame ft do:
    b2:set-repositioned-row(b2:focused-row, "always").
    v-rid = rowid(qproc).
    open query q_existing for each qproc no-lock.
    reposition q_existing to rowid v-rid no-error.
    if avail qproc then b2:refresh().
    b1:set-repositioned-row(b1:focused-row, "always").
    v-rid = rowid(qproca).
    open query q_running for each qproca no-lock.
    reposition q_running to rowid v-rid no-error.
    if avail qproca then b1:refresh().
    run scn_refresh.
end. /* on "return" of b1 */

/* [Space]  - обновить */
on " " of b2 in frame ft or
   "return" of b2 in frame ft do:
    b1:set-repositioned-row(b1:focused-row, "always").
    v-rid = rowid(qproca).
    open query q_running for each qproca no-lock.
    reposition q_running to rowid v-rid no-error.
    if avail qproca then b1:refresh().
    b2:set-repositioned-row(b2:focused-row, "always").
    v-rid = rowid(qproc).
    open query q_existing for each qproc no-lock.
    reposition q_existing to rowid v-rid no-error.
    if avail qproc then b2:refresh().
    run scn_refresh.
end. /* on "return" of b1 */

/* [Insert] - запустить процесс */
on "insert-mode" of b1 in frame ft do:
    b1:set-repositioned-row(b1:focused-row, "always").
    v-rid = rowid(qproca).

    run qpsmng("startprc","",0).

    pause 1.

    open query q_running for each qproca no-lock.
    reposition q_running to rowid v-rid no-error.
    if avail qproca then b1:refresh().
    run scn_refresh.
end.

/* [Delete] - остановить процесс */
on "delete-character" of b1 in frame ft do:
    if avail qproca then do:
        assign v-pid = qproca.pid v-copy = qproca.copy.
        b1:set-repositioned-row(b1:focused-row, "always").
        get next q_running.
        if not avail qproca then get last q_running.
        v-rid = rowid(qproca).

        run qpsmng("stopprc",v-pid,v-copy).

        open query q_running for each qproca no-lock.
        reposition q_running to rowid v-rid no-error.
        if avail qproca then b1:refresh().
        run scn_refresh.
    end.
end.

/* [Ctrl+D] - завершить процесс (kill) */
on "delete-line" of b1 in frame ft do:
    if avail qproca then do:
        assign v-pid = qproca.pid v-copy = qproca.copy.
        b1:set-repositioned-row(b1:focused-row, "always").
        get next q_running.
        if not avail qproca then get last q_running.
        v-rid = rowid(qproca).

        run qpsmng("killprc",v-pid,v-copy).

        open query q_running for each qproca no-lock.
        reposition q_running to rowid v-rid no-error.
        if avail qproca then b1:refresh().
        run scn_refresh.
    end.
end.

/* [Ctrl+P] - запустить все процессы */
on "prev-word" of b1 in frame ft do: /* при нажатии Ctrl+P */
    choice = no.
    message "Запрос на запуск всех процессов.~nПродолжить?" view-as alert-box question buttons yes-no title "Запуск всех процессов" update choice.
    if choice then do:
        b1:set-repositioned-row(b1:focused-row, "always").
        v-rid = rowid(qproca).

        run qpsmng("startall","",0).

        pause 1.

        open query q_running for each qproca no-lock.
        reposition q_running to rowid v-rid no-error.
        if avail qproca then b1:refresh().
        run scn_refresh.
    end.
end.

/* [Home]   - остановить все процессы */
on "home" of b1 in frame ft do:
    choice = no.
    message "Запрос на остановку всех процессов.~nПродолжить?" view-as alert-box question buttons yes-no title "Стоп всех процессов" update choice.
    if choice then do:
        b1:set-repositioned-row(b1:focused-row, "always").
        v-rid = rowid(qproca).

        run qpsmng("stopall","",0).

        pause 1.

        open query q_running for each qproca no-lock.
        reposition q_running to rowid v-rid no-error.
        if avail qproca then b1:refresh().
        run scn_refresh.
    end.
end.

/* [Ctrl+A] - завершить все процессы (kill) */
on "append-line" of b1 in frame ft do:
    choice = no.
    message "Запрос на экстренное завершение всех процессов.~nПродолжить?" view-as alert-box question buttons yes-no title "Kill all processes" update choice.
    if choice then do:
        b1:set-repositioned-row(b1:focused-row, "always").
        v-rid = rowid(qproca).

        run qpsmng("killall","",0).

        pause 1.

        open query q_running for each qproca no-lock.
        reposition q_running to rowid v-rid no-error.
        if avail qproca then b1:refresh().
        run scn_refresh.
    end.
end.

/* [Insert] - зарегистрировать процесс */
on "insert-mode" of b2 in frame ft do:
    def var v-go as logical init no.

    assign new-pid = ''
           new-des = ''
           new-proc = ''
           new-q = ''
           new-shost = ''
           new-sport = 0
           new-user = ''
           new-password = ''
           new-active = yes.

    displ new-pid new-des new-proc new-q new-shost new-sport new-user new-password new-active with frame fnew.

    repeat:
        update new-pid new-des new-proc new-shost new-sport new-user new-password new-active new-q with frame fnew.
        assign new-pid = trim(new-pid)
               new-des = trim(new-des)
               new-proc = trim(new-proc)
               new-shost = trim(new-shost)
               new-user = trim(new-user)
               new-password = trim(new-password)
               new-q[1] = trim(new-q[1])
               new-q[2] = trim(new-q[2])
               new-q[3] = trim(new-q[3])
               new-q[4] = trim(new-q[4])
               new-q[5] = trim(new-q[5]).
        if new-pid <> '' and new-des <> '' and new-proc <> '' and new-shost <> '' and new-sport > 0 and new-user <> '' and new-password <> '' then do: v-go = yes. leave. end.
    end.

    hide frame fnew.

    if v-go then do:
        do transaction:
            create b-qproc.
            assign b-qproc.pid = new-pid
                   b-qproc.des = new-des
                   b-qproc.proc = new-proc
                   b-qproc.sonichost = new-shost
                   b-qproc.sonicport = new-sport
                   b-qproc.username = new-user
                   b-qproc.pass = new-password
                   b-qproc.active = new-active
                   b-qproc.q[1] = new-q[1]
                   b-qproc.q[2] = new-q[2]
                   b-qproc.q[3] = new-q[3]
                   b-qproc.q[4] = new-q[4]
                   b-qproc.q[5] = new-q[5].
        end. /* transaction */
        v-rid = rowid(b-qproc).

        open query q_existing for each qproc no-lock.
        reposition q_existing to rowid v-rid no-error.
        if avail qproc then b2:refresh().
        run scn_refresh.
    end.
end.

/* [Enter]  - редактирование информации */
on "enter" of b2 in frame ft do:
    def var v-go as logical init no.

    if avail qproc then do:
        v-rid = rowid(qproc).
        assign new-pid = qproc.pid
               new-des = qproc.des
               new-shost = qproc.sonichost
               new-sport = qproc.sonicport
               new-user = qproc.username
               new-password = qproc.pass
               new-active = qproc.active
               new-proc = qproc.proc
               new-q[1] = qproc.q[1]
               new-q[2] = qproc.q[2]
               new-q[3] = qproc.q[3]
               new-q[4] = qproc.q[4]
               new-q[5] = qproc.q[5].

        displ new-pid new-des new-proc new-q new-shost new-sport new-user new-password new-active with frame fnew.

        repeat:
            update new-des new-proc new-shost new-sport new-user new-password new-active new-q with frame fnew.
            assign new-des = trim(new-des)
                   new-proc = trim(new-proc)
                   new-shost = trim(new-shost)
                   new-user = trim(new-user)
                   new-password = trim(new-password)
                   new-q[1] = trim(new-q[1])
                   new-q[2] = trim(new-q[2])
                   new-q[3] = trim(new-q[3])
                   new-q[4] = trim(new-q[4])
                   new-q[5] = trim(new-q[5]).
            if new-pid <> '' and new-des <> '' and new-proc <> '' and new-shost <> '' and new-sport > 0 and new-user <> '' and new-password <> '' then do: v-go = yes. leave. end.
        end.

        hide frame fnew.

        if v-go then do:
            do transaction:
                find first b-qproc where b-qproc.pid = new-pid exclusive-lock no-error.
                if avail b-qproc then do:
                    assign b-qproc.des = new-des
                           b-qproc.proc = new-proc
                           b-qproc.sonichost = new-shost
                           b-qproc.sonicport = new-sport
                           b-qproc.username = new-user
                           b-qproc.pass = new-password
                           b-qproc.active = new-active
                           b-qproc.q[1] = new-q[1]
                           b-qproc.q[2] = new-q[2]
                           b-qproc.q[3] = new-q[3]
                           b-qproc.q[4] = new-q[4]
                           b-qproc.q[5] = new-q[5].
                end.
                find current b-qproc no-lock.
            end. /* transaction */

            open query q_existing for each qproc no-lock.
            reposition q_existing to rowid v-rid no-error.
            if avail qproc then b2:refresh().
            run scn_refresh.
        end.
    end. /* if avail qproc */
end.

/* [Delete] - удалить информацию о процессе */
on "delete-character" of b2 in frame ft do:
    if avail qproc then do:
        v-pid = qproc.pid.
        b2:set-repositioned-row(b1:focused-row, "always").
        get next q_existing.
        if not avail qproc then get last q_existing.
        v-rid = rowid(qproc).

        choice = no.
        message "Запрос на удаление зарегистрированного процесса с кодом '" + v-pid + "'.~nПродолжить?" view-as alert-box question buttons yes-no title "Удаление" update choice.
        if choice then do:
            find first b-qproca where b-qproca.pid = v-pid no-lock no-error.
            if avail b-qproca then message "Запущены активные копии данного процесса, удаление невозможно!" view-as alert-box error.
            else do transaction:
                find first b-qproc where b-qproc.pid = v-pid exclusive-lock no-error.
                if avail b-qproc then delete b-qproc.
            end.
        end.

        open query q_existing for each qproc no-lock.
        reposition q_existing to rowid v-rid no-error.
        if avail qproc then b2:refresh().
        run scn_refresh.
    end.
end.

/* проверим отвалившиеся процессы */
for each b-qproca no-lock:
    v-txt = ''.
    input through value("ps -p " + trim(string(b-qproca.u_pid,">>>>>>>>>9")) + " -o pid").
    repeat:
        import unformatted v-txt.
        v-txt = trim(v-txt).
        if v-txt = 'pid' then v-txt = ''.
    end.
    input close.
    if v-txt = '' then do transaction:
        find first b2-qproca where rowid(b2-qproca) = rowid(b-qproca) exclusive-lock.
        delete b2-qproca.
        release b2-qproca.
    end. /* transaction */
end.

open query q_running for each qproca no-lock.
open query q_existing for each qproc no-lock.
enable b1 b2 with frame ft.
i = 1. v-scn = entry(i,v-scn_list).
displ v-scn with frame ft.



wait-for window-close of current-window.
pause 0.

