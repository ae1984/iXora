/* RET_ps.p
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
        31/10/2013 galina - ТЗ2105 если v-errубрала undo.
*/

{global.i}
{lgps.i }

def var v-err as logical no-undo.
def var v-msg as char no-undo.
def var v-sum as deci.
def var v-cor-bal as deci.
def var v-cred-bal as deci.
def var ourbank like bankl.bank.
def var clcen like bankl.bank.

find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
    v-text = " There isn't record OURBNK in sysc file !!!".
    run lgps.
    return.
end.
ourbank = sysc.chval.
find sysc where sysc.sysc = "clcen" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
    v-text = " There isn't record OURBNK in sysc file !!!".
    run lgps.
return.
end.
clcen = sysc.chval.

l1:
for each banka where bank = ourbank no-lock:
    find first arp where arp = banka.cacc no-lock.
    find gl where gl.gl eq arp.gl no-lock.
    if gl.type eq "A" then v-cred-bal = arp.dam[1] - arp.cam[1].
    else v-cred-bal = arp.cam[1] - arp.dam[1].
    if v-cred-bal > 0 then do:
        find first bankt where bankt.cbank = clcen and bankt.crc = banka.crc no-lock no-error.
        if not avail bankt then do:
            v-text = " There isn't record in bankt file !!! ".
            run lgps.
            next.
        end.
        find first dfb where dfb = bankt.acc no-lock no-error.
        if not avail dfb then do:
            v-text = " There isn't record in dfb file !!! ".
            run lgps.
            next.
        end.
        for each sts no-lock, each que of sts no-lock, each remtrz of que
        where sts.pid <> "F" and cracc = dfb.dfb no-lock:
            next l1.
        end.
        find gl where gl.gl eq dfb.gl no-lock.
        if gl.type eq "A"
        then v-cor-bal = dfb.dam[1] - dfb.cam[1].
        else v-cor-bal = dfb.cam[1] - dfb.dam[1].
        if v-cor-bal <= 0 then next l1.
        v-sum = if v-cred-bal < v-cor-bal then v-cred-bal else v-cor-bal.
        do transaction:
            run retcor(
            arp.arp,
            v-sum,
            output v-err,
            output v-msg).
/*            if v-err then undo, leave.*/
            v-text = v-msg.
            run lgps.
        end.
/*        if v-err then do:
        v-text = "Ошибка при создании платежа!" + v-msg.
        run lgps.
        end.*/
    end.
end.



