/* AML_ps.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Процесс выгрузки в AML из ЦО
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
        31/08/2010 galina
 * BASES
        BANK
 * CHANGES
        21/09/2010 galina - вынесла отправку в AML в отдельный процесс
        19/11/2010 madiyar - выгрузка несколько раз в течение дня
        18/09/2013 galina - ТЗ2092 добавила проверку g-today = today and time >= 36000
*/

def new shared var v-dt1 as date.
def new shared var v-dt2 as date.
def shared var g-today as date.

{lgps.i "new"}

m_pid = "AML".

if g-today = today and time >= 36000 then do:
    find first sysc where sysc.sysc = "AMLOFF" no-lock no-error.
    if not avail sysc then do transaction:
        create sysc.
        sysc.sysc = "AMLOFF".
        sysc.des = "Offline-выгрузка в AML - ЦО".
        sysc.daval = g-today - 1.
        sysc.loval = yes.
        find current sysc no-lock.
    end. /* transaction */

    if not sysc.loval then return.

    if sysc.daval < g-today then do:
        find last cls where cls.del no-lock no-error.
        v-dt1 = cls.whn.
        v-dt2 = v-dt1.
        run AMLoff_HQ.
        do transaction:
            find current sysc exclusive-lock.
            sysc.daval = g-today.
            find current sysc no-lock.
        end. /* transaction */
    end.

    v-dt1 = g-today.
    v-dt2 = v-dt1.
    run AMLoff_HQ.
end.
/*
find first dproc where dproc.pid = m_pid no-lock no-error.
if avail dproc then do transaction:
    v-text = " Процесс AML завершил свою работу. Начинается останов процесса... ".
    run lgps.
    find current dproc exclusive-lock no-error.
    dproc.tout = 1000.
    find current dproc no-lock no-error.
end.
*/


