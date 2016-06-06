/* RIF_ps.p
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
        09.11.10 def var v-oda-accnt like aaa.aaa.
        31/10/2013 galina - ТЗ2105 если при пополнении корсчета фиилала возникла ошибка, то rcode = 1
*/

{global.i}
{lgps.i }

def var v-err as logical no-undo.
def var v-msg as char no-undo.
def var v-bal as deci.
def var v-avail-bal as deci.
def var v-hold-bal as deci.
def var v-frozen-bal as deci.
def var v-cred-line as deci.
def var v-cred-line-used as deci.
def var v-oda-accnt like aaa.aaa.

define temp-table rif
field rmz like remtrz.remtrz
field dracc like remtrz.dracc
field amt like remtrz.amt
index dra dracc.
define temp-table rif1
field dracc like remtrz.dracc
field amt like remtrz.amt
index dra dracc.

for each que where que.pid = "2t" and que.con = "W" use-index fprc no-lock:
    find first remtrz of que no-lock.
    if remtrz.info[8] = "REINFORCED" then return.
end.

for each que where que.pid = "2w" and que.con = "W" use-index fprc no-lock:
    find first remtrz of que no-lock.
    if remtrz.info[8] = "REINFORCED" then return.
end.

for each que where que.pid = m_pid and que.con = "W" use-index fprc no-lock:
    find first remtrz of que no-lock.
    create rif.
    assign
    rif.rmz = que.remtrz
    rif.dracc = remtrz.dracc
    rif.amt = remtrz.amt.
end.
for each rif break by rif.dracc:
    accumulate rif.amt (sub-total by rif.dracc).
    if last-of(rif.dracc) then do:
        create rif1.
        assign
        rif1.dracc = rif.dracc
        rif1.amt = (accum sub-total by rif.dracc rif.amt).
    end.
end.

l1:
for each rif1:
    l2:
    do transaction on error undo l2, next l1:

        run aaa-bal777(rif1.dracc,
        output v-bal,
        output v-avail-bal,
        output v-hold-bal,
        output v-frozen-bal,
        output v-cred-line,
        output v-cred-line-used,
        output v-oda-accnt).

        v-err = false.
        v-msg = ''.

        if rif1.amt - v-avail-bal > 0 then do:
            run reinfcor(
            rif1.dracc,
            rif1.amt - v-avail-bal,
            output v-err,
            output v-msg).

            if v-err then do:
                for each rif where rif.dracc = rif1.dracc no-lock:
                  find first que where que.remtrz = rif.rmz exclusive-lock no-error.
                  que.dw = today.
                  que.tw = time.
                  que.dp   = today.
                  que.tp   = time.
                  que.con  = "F".
                  que.rcod = "1".
                  find current que no-lock no-error.
                  v-text = rif.rmz + " Ошибка при создании платежа в процедуре reinfcor!" + v-msg.
                  run lgps.

                end.
            end.
        end.
        if v-err = false then do:
            if v-msg <> '' then do:
                v-text = v-msg.
                run lgps.
            end.
            for each rif where rif.dracc = rif1.dracc on error undo l2, next l1:
                    find first que where que.remtrz = rif.rmz exclusive-lock no-wait no-error.
                    if error-status:error then undo l2, next l1.
                    find first remtrz where remtrz.remtrz = rif.rmz  exclusive-lock no-wait no-error.
                    if error-status:error then undo l2, next l1.
                    que.dw = today.
                    que.tw = time.
                    que.dp   = today.
                    que.tp   = time.
                    que.con  = "F".
                    que.rcod = "0".
                    remtrz.info[8] = "REINFORCED".
                    v-text = "Платеж " + que.remtrz + " обработан. rcod = " + que.rcod.
                    run lgps.
            end.
        end.

    end.
end.



