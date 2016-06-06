/* chgsts.p
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
 * BASES
      BANK COMM
 * CHANGES
        11.04.2012 damir - добавил return.
*/
{global.i}

def input parameter v-sub like gl.sub .
def input parameter v-acc like aaa.aaa.
def input parameter v-sts like stsdic.sts .

def var v-today as date .
def var v-time as int .

v-today = today .
v-time = time .

do transaction:
    find last substs where substs.sub = v-sub and substs.acc = v-acc  use-index substs no-lock no-error .
    if not avail substs or ( avail substs and substs.sts ne v-sts ) then do:
        create substs .
        substs.sub  = v-sub .
        substs.acc  = v-acc .
        substs.sts  = v-sts .
        substs.rdt  = v-today .
        substs.rtim = v-time .
        substs.who  = g-ofc .
    end.
    find first cursts where cursts.sub = v-sub and cursts.acc = v-acc  use-index subacc exclusive-lock no-error .
    if not avail cursts then do:
        create cursts .
        cursts.sub = v-sub .
        cursts.acc = v-acc .
    end.
    cursts.sts  = v-sts .
    cursts.rdt  = v-today .
    cursts.rtim = v-time .
    cursts.who  = g-ofc .
end.

return.