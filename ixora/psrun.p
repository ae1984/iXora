/* psrun.p
 * MODULE
        Для использования в скриптах администраторов БД
 * DESCRIPTION
        Остановка, запуск процессов платежной системы по одному или все разом.
        Закрытие опер дня платежной системы
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        psman <VPARAM>
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        28.11.2012 id00477
 *BASES
        BANK
 * CHANGES
        29.11.2012 id00477 - добавил коннект к базе BANK
		11.02.2013 id00477 - убрал синхронизацию очередей, в соответствии с v-stat2.p
        31/07/2013 galina - ТЗ 1994 перенесла запуск программы inkclose в psrun


*/

def var v-pid like que.pid.
def var v-copy as integer.
def var yn as log initial false format "да/нет".
def var v-param as character.
def new shared var v-log as cha .
def new shared var g-today as date.
def new shared var g-ofc like ofc.ofc.

def var v-path as char.
def new shared var db-path as char.

{lgps.i "new" }

input through whoami.
import g-ofc.
input close.

input through echo $VPARAM.
import v-param.
input close.

u_pid = "v-stat".
m_pid = "PS_".

find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then
    do:
    message " Не найдена запись OURBNK в sysc файле !!".
    pause .
    end.

m_hst = trim(sysc.chval).

find sysc where sysc.sysc = "PS_LOG" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 message  " Не найдена запись PS-LOG в настроечном (sysc) файле !!" .
 pause .
end.

v-log = trim(sysc.chval).

case v-param:
    when "run_all" then
        do:
             v-copy = 0.
             display " .Старт всех процессов ... " with centered frame www1.  pause 0 .
             for each fproc where fproc.tout ne 1000 :
             pause 2 no-message .
             v-pid = caps(fproc.pid).
             if search("/pragma/bin9/u_pid") ne ? then
                unix silent value("/pragma/bin9/u_pid " + m_hst + " " + v-pid + " " + string(v-copy,"99") + " " + v-log ).
             else do:
                  message " u_pid script не найден !! . " . pause . end .
             end.

             find sysc where sysc.sysc = "ourbnk" no-lock no-error .
                if not avail sysc or sysc.chval = "" then do:
                    display " This isn't record OURBNK in bank.sysc file !!".
                    pause.
                end.
             if trim(sysc.chval) = 'TXB00' then do:
                 run runautosl.
                 run runlcmt.
             end.

             clear frame www1 .

             /*comm должен быть запущен*/
             /*display " Автоматическая Регистрация инкассовых распоряжений! " with centered frame www2.  pause 0 .
             run inkclose.*/

             find sysc where sysc.sysc = "ourbnk" no-lock no-error .
             if avail sysc and trim(sysc.chval) = "TXB00" then do:
                display " Автоматическая загрузка Статистического реестра! " with centered frame www2.  pause 0 .
                run loadnkstatreg("","").
             end.

             /**/
             if trim(sysc.chval) = 'TXB00' then do:
                display " Обновление данных по кредитам на портале " with centered frame www2.  pause 0 .
                run crdinfo.
             end.
        end.

    when "run_one" then
        do:
            input through echo $VPID.
            import v-pid.
            input close.
            v-pid = caps(v-pid).
            find fproc where fproc.pid = v-pid no-lock no-error.
            if not avail fproc then do:
                message "Нет описания процесса в 'fproc' файле ! " .
                pause .
            end.
            else
                do:
                    if search("/pragma/bin9/u_pid") ne ? then
                        do:
                            unix silent value("/pragma/bin9/u_pid " + m_hst + " " + v-pid + " " + string(v-copy,"99") + " " + v-log ).
                        end.
                    else
                        do:
                            message " u_pid script не найден !! . " . pause .
                        end .
                    end.
                    clear frame upd all.
            end.

   when "stop_all" then
        do:
            do transaction :
                clear frame pid all.
                for each dproc with row 3 frame pid.
                    dproc.tout = 1000.
                    unix silent value("kill -SIGALRM " + string(dproc.u_pid)) .

                end.
             end.
        end.
    when "stop_one" then
        do transaction :
            input through echo $VPID.
            import v-pid.
            input close.

            v-pid = caps(v-pid).
            find dproc where dproc.pid = v-pid and dproc.copy = v-copy
            exclusive-lock no-error.
            if avail dproc then do:
                dproc.tout = 1000.
                unix silent value("kill -SIGALRM " + string(dproc.u_pid)) .
                clear frame updb all.
            end.
            release dproc .
        end.

    when "close" then
        do:
            run psdclose.
        end.

    OTHERWISE message "no valid param. v-param = "v-param.

end case.

quit.