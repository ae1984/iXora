/* 4N_ps.p
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
        24.05.2003 nadejda - убраны параметры -H -S из коннекта
        07.06.2012 evseev - отструктурировал код, логирование
*/

{global.i}
{lgps.i}
def new shared var v-weekbeg as int.
def new shared var v-weekend as int.
def var dueto as log .
def new shared var rhost as cha.
def new shared var s-remtrz like remtrz.remtrz .
def var i as int init 0 .
def var i1 as int init  0 .

/* 18.08.98  10 santim */
def new shared var lbnstr as cha .
find first sysc where sysc.sysc = "LBNSTR" no-lock no-error .
if avail sysc then lbnstr = sysc.chval .
/* 18.08.98  10 santim */

find sysc "WKEND" no-lock no-error.
if available sysc then v-weekend = sysc.inval. else v-weekend = 6.

find sysc "WKSTRT" no-lock no-error.
if available sysc then v-weekbeg = sysc.inval. else v-weekbeg = 2.

find first sysc where sysc.sysc = "M-DIR" no-lock no-error.
if not avail sysc then do:
    v-text = " Нет записи  M-DIR в sysc файле  ".
    run lgps.
    return.
end.
rhost = "TXB" + substr(string(m_pid),2,2).

find first bankl where bankl.bank = rhost no-lock no-error.
if not avail bankl then do:
   run savelog("4N_ps","55" ).
   return.
end.


v-text = "Прямой доступ к базе данных " + rhost  .
run lgps .
if not connected("shtbnk") then connect value(" -db " + bankl.chipno + " -ld shtbnk") no-error.

if not connected("shtbnk") then do:
    v-text = " Ошибка ! . HOST " + bankl.acct + " не отвечает .".
    run lgps.
    return.
end.

if connected("shtbnk") then do:
    for each que where que.pid = "4N" and que.con = "W" use-index fprc no-lock.
        run savelog("4N_ps","69. que.rcod=" + que.rcod ).
        find first remtrz of que no-lock.
        if remtrz.rbank = rhost then do:
            s-remtrz = remtrz.remtrz .
            run savelog("4N_ps","76. remtrz.remtrz=" + s-remtrz + "que.rcod=" + que.rcod ).
            run pssend.
            run savelog("4N_ps","78. remtrz.remtrz=" + s-remtrz + "que.rcod=" + que.rcod ).
        end.
        if not connected("shtbnk") then do:
            v-text = " Error !! . HOST " + bankl.acct + " Ошибка ! . HOST " + bankl.acct + " не отвечает ." .
            run lgps.
            run savelog("4N_ps","83. que.rcod=" + que.rcod ).
            return.
        end.
    end.
end.

if connected("shtbnk") then do:
    for each que where que.pid = "8" and que.con = "W" use-index fprc no-lock.
        find first remtrz of que no-lock.
        if remtrz.rbank = rhost then do:
            s-remtrz = remtrz.remtrz.
            run savelog("4N_ps","94. remtrz.remtrz=" + s-remtrz + "que.rcod=" + que.rcod ).
            run psconf.
            run savelog("4N_ps","96. remtrz.remtrz=" + s-remtrz + "que.rcod=" + que.rcod ).
        end.

        if not connected("shtbnk") then do:
            v-text = " Ошибка ! . HOST " + bankl.acct + " не отвечает .".
            run lgps.
        end.
    end.
end.

if connected("shtbnk") then do:
    for each que where que.pid = "8A" and que.con = "W" use-index fprc no-lock.
        find first remtrz of que no-lock.
        if remtrz.rbank = rhost then do:
            s-remtrz = remtrz.remtrz .
            run savelog("4N_ps","111. remtrz.remtrz=" + s-remtrz + "que.rcod=" + que.rcod ).
            run psconf1.
            run savelog("4N_ps","113. remtrz.remtrz=" + s-remtrz + "que.rcod=" + que.rcod ).
        end.
        if not connected("shtbnk") then do:
            v-text = " Ошибка ! . HOST " + bankl.acct + " не отвечает .".
            run lgps.
        end.
    end.
end.

if connected("shtbnk") then run 4Nrmt.

if connected("shtbnk") then disconnect shtbnk.
