/* qpsmng.p
 * MODULE
        Процессы для работы с Sonic
 * DESCRIPTION
        Административные процедуры по запуску/остановке процессов для работы с Sonic
 * RUN
        При передаче параметра - выполнение соотв. директивы, пустой параметр - запрос
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
        11/03/2009 madiyar - переделал, теперь принимает входные параметры и может использоваться в silent-режиме
        19/10/2009 madiyar - запуск процесса - при отсутствии уже запущенных копий номер копии 0
        05/11/2009 madiyar - перекомпиляция
        06/11/2009 madiyar - добавил "мягкое" завершение процесса
        17/07/2010 madiyar - "мягкое" завершение процесса происходит путем отправки сообщения
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
*/

{global.i}

def input parameter p-command as char no-undo.
def input parameter p-pid as char no-undo.
def input parameter p-copy as integer no-undo.

if p-command <> '' and lookup(p-command, "startall,startprc,stopall,stopprc,killall,killprc") = 0 then return.

def var v-select as integer no-undo.
def var v-pid as char no-undo.
def var v-copy as integer no-undo.
def var v-str as char no-undo.
def var v-proceed as logi no-undo.
def var v-title as char no-undo.

def buffer b-qproca for qproca.

def temp-table t-ln no-undo
  field pid like qproc.pid
  field des like qproc.des
  index main is primary pid.

def var s-ourbank as char no-undo.
find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).

def var v-log as char no-undo.
find first sysc where sysc.sysc = "PS_LOG" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
    message "Не найдена запись PS-LOG в настроечном (sysc) файле !" .
    pause.
end.
v-log = trim(sysc.chval).

form
    v-pid label " Код процесса ? " format 'x(20)'
    v-copy label " Номер копии    "
    v-proceed label " Продолжить ?   " format 'да/нет'
    with overlay row 5 side-label 1 column column 5 title " Запустить " frame startpr.

form
    v-title no-label format "x(25)" skip
    v-pid label " Код процесса ? " format 'x(20)'
    v-copy label " Номер копии    "
    v-proceed label " Продолжить ?   " format 'да/нет'
    with overlay row 5 side-label 1 column column 5 title " Остановить " frame stoppr.

on help of v-pid in frame startpr do:
    find first qproc no-lock no-error.
    if not avail qproc then message skip " Нет зарегистрированных процессов! " skip(1) view-as alert-box error.

    {itemlist.i
       &file = "qproc"
       &frame = "row 6 centered scroll 1 20 down overlay "
       &where = " true "
       &flddisp = " qproc.pid label 'Код' format 'x(8)'
                    qproc.des label 'Описание' format 'x(50)'
                  "
       &chkey = "pid"
       &chtype = "string"
       &index  = "pid"
    }
    v-pid = qproc.pid.
    displ v-pid with frame startpr.
end.

on help of v-pid in frame stoppr do:
    find first qproca no-lock no-error.
    if not avail qproca then message skip " Нет запущенных процессов! " skip(1) view-as alert-box error.

    for each qproca no-lock break by qproca.pid:
        if first-of(qproca.pid) then do:
            find first qproc where qproc.pid = qproca.pid no-lock no-error.
            if avail qproc then do:
                create t-ln.
                assign t-ln.pid = qproc.pid
                       t-ln.des = qproc.des.
            end.
        end.
    end.

    {itemlist.i
       &set = "a"
       &file = "t-ln"
       &frame = "row 6 centered scroll 1 20 down overlay "
       &where = " true "
       &flddisp = " t-ln.pid label 'Код' format 'x(8)'
                    t-ln.des label 'Описание' format 'x(50)'
                  "
       &chkey = "pid"
       &chtype = "string"
       &index  = "main"
    }
    v-pid = t-ln.pid.
    displ v-pid with frame stoppr.
end.

repeat:

    if p-command = '' then run sel2 (" Sonic 4-gl процессы ", " 1. Старт всех процессов | 2. Старт процесса | 3. Стоп всех процессов | 4. Стоп процесса |  5. Kill всех процессов |  6. Kill процесса | 7. Выход ", output v-select).
    else v-select = lookup(p-command, "startall,startprc,stopall,stopprc,killall,killprc").

    if (v-select < 1) or (v-select > 7) then return.

    case v-select:

    when 1 then do:
        /* 1. Старт всех процессов */
        find first qproca no-lock no-error.
        if avail qproca then message "Ошибка: остановите запущенные процессы!" view-as alert-box error.
        else do:
            for each qproc where qproc.active no-lock:
                if qproc.proc = '' then message "Процесс '" + qproc.pid + "' - не указана процедура для запуска!~nПродолжаем запуск остальных процессов..." view-as alert-box error.
                else do:
                    if search("/pragma/bin9/q_pid") ne ? then unix silent value("/pragma/bin9/q_pid " + s-ourbank + " " + qproc.pid + " 00 " + v-log).
                    else message "q_pid script не найден!" view-as alert-box error.
                end.
            end.
        end.
    end.

    when 2 then do:
        /* 2. Старт процесса */
        assign v-pid = '' v-copy = 0 v-proceed = yes.

        if p-command <> '' then v-pid = p-pid.

        displ v-pid v-copy v-proceed with frame startpr.
        update v-pid with frame startpr.

        find first qproc where qproc.pid = v-pid no-lock no-error.
        if not avail qproc then message "Ошибка: описания процесса с таким кодом не существует!" view-as alert-box error.
        else do:
            find last qproca where qproca.pid = v-pid no-lock no-error.
            if avail qproca then v-copy = qproca.copy + 1.
            else v-copy = 0.

            displ v-copy with frame startpr.
            update v-proceed with frame startpr.

            if v-proceed then do:
                if qproc.proc = '' then message "Процесс '" + qproc.pid + "' - не указана процедура для запуска!" view-as alert-box error.
                else do:
                    if search("/pragma/bin9/q_pid") ne ? then unix silent value("/pragma/bin9/q_pid " + s-ourbank + " " + qproc.pid + " " + string(v-copy,"99") + " " + v-log).
                    else do: message "q_pid script не найден!". pause. end.
                end.
            end.
        end.

        hide frame startpr.

    end.

    when 3 then do:
        /* 3. Стоп всех процессов */
        find first qproca no-lock no-error.
        if not avail qproca then message "Ошибка: нет запущенных процессов!" view-as alert-box error.
        else do:
            for each qproca no-lock:
                find first qproc where qproc.pid = qproca.pid no-lock no-error.
                if avail qproc then do:
                    find b-qproca where rowid(b-qproca) = rowid(qproca) exclusive-lock no-error.
                    if avail b-qproca then do:
                        qproca.terminate = yes.
                        run qsendcom(qproc.q[1],"terminate",qproc.username,qproc.pass,qproc.sonichost,qproc.sonicport).
                    end.
                    release b-qproca.
                end.
            end.
        end.
    end.

    when 4 then do:
        /* 4. Стоп процесса */
        find first qproca no-lock no-error.
        if not avail qproca then message "Ошибка: нет запущенных процессов!" view-as alert-box error.
        else do:
            assign v-pid = '' v-copy = 0 v-proceed = yes.

            if p-command <> '' then assign v-pid = p-pid v-copy = p-copy.

            v-title = " <Стоп процесса> ".
            displ v-title v-pid v-copy v-proceed with frame stoppr.
            update v-pid with frame stoppr.

            find last qproca where qproca.pid = v-pid no-lock no-error.
            if not avail qproca then message "Ошибка: нет запущенного процесса с таким кодом!" view-as alert-box error.
            else do:
                if v-copy = 0 then v-copy = qproca.copy.

                displ v-copy with frame stoppr.
                update v-copy v-proceed with frame stoppr.

                if v-proceed then do:
                    find first qproc where qproc.pid = v-pid no-lock no-error.
                    if not avail qproc then message "Ошибка: нет зарегистрированного процесса с таким PID!" view-as alert-box error.
                    else do:
                        find first qproca where qproca.pid = v-pid and qproca.copy = v-copy exclusive-lock no-error.
                        if not avail qproca then message "Ошибка: нет запущенного процесса с указанными параметрами!" view-as alert-box error.
                        else do:
                            qproca.terminate = yes.
                            run qsendcom(qproc.q[1],"terminate",qproc.username,qproc.pass,qproc.sonichost,qproc.sonicport).
                            clear frame stoppr all.
                        end.
                    end.
                    release qproca.
                end.
            end.

            hide frame stoppr.

        end.
    end.

    when 5 then do:
        /* 5. Kill всех процессов */
        find first qproca no-lock no-error.
        if not avail qproca then message "Ошибка: нет запущенных процессов!" view-as alert-box error.
        else do:
            for each qproca exclusive-lock:
                /* input through value("kill -SIGALRM " + string(qproca.u_pid) + ";echo $?"). */
                input through value("kill " + string(qproca.u_pid) + ";echo $?").
                import unformatted v-str.
                input close.
                v-str = trim(v-str).
                if v-str = '0' then delete qproca.
                else message "Ошибка остановки процесса " + qproca.pid + " copy=" + string(qproca.copy,"99") + " u_pid=" + string(qproca.u_pid) view-as alert-box error.
            end.
            release qproca.
        end.
    end.

    when 6 then do:
        /* 6. Kill процесса */
        find first qproca no-lock no-error.
        if not avail qproca then message "Ошибка: нет запущенных процессов!" view-as alert-box error.
        else do:
            assign v-pid = '' v-copy = 0 v-proceed = yes.

            if p-command <> '' then assign v-pid = p-pid v-copy = p-copy.

            v-title = " <KILL процесса> ".
            displ v-title v-pid v-copy v-proceed with frame stoppr.
            update v-pid with frame stoppr.

            find last qproca where qproca.pid = v-pid no-lock no-error.
            if not avail qproca then message "Ошибка: нет запущенного процесса с таким кодом!" view-as alert-box error.
            else do:
                if v-copy = 0 then v-copy = qproca.copy.

                displ v-copy with frame stoppr.
                update v-copy v-proceed with frame stoppr.

                if v-proceed then do:
                    find first qproca where qproca.pid = v-pid and qproca.copy = v-copy exclusive-lock no-error.
                    if not avail qproca then message "Ошибка: нет запущенного процесса с указанными параметрами!" view-as alert-box error.
                    else do:
                        /*input through value("kill -SIGALRM " + string(qproca.u_pid) + ";echo $?").*/
                        input through value("kill " + string(qproca.u_pid) + ";echo $?").
                        import unformatted v-str.
                        input close.
                        v-str = trim(v-str).
                        if v-str = '0' then do:
                            delete qproca.
                            message "Процесс остановлен" view-as alert-box information.
                        end.
                        else message "Ошибка остановки процесса " + qproca.pid + " copy=" + string(qproca.copy,"99") + " u_pid=" + string(qproca.u_pid) view-as alert-box error.
                        clear frame stoppr all.
                    end.
                    release qproca.
                end.
            end.

            hide frame stoppr.

        end.
    end.

    end case.

    if p-command <> '' then leave.

end.

