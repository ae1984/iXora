/* help-trz.p
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
*/

/* help-trz.p */

{global.i}

define temp-table ttrem
    field ttrz like remtrz.remtrz
    field tamt like remtrz.amt
    field tcrc like remtrz.fcrc
    field tdet like remtrz.detpay
    index ttrz-value ttrz.

for each que where que.pid eq "2L" no-lock:
    find remtrz where remtrz.remtrz eq que.remtrz no-lock.
        if remtrz.rsub eq "BOX" then do:
            create ttrem.
            ttrem.ttrz    = remtrz.remtrz.
            ttrem.tamt    = remtrz.amt.
            ttrem.tcrc    = remtrz.fcrc.
            ttrem.tdet[1] = remtrz.detpay[1].
        end.
end.

repeat on endkey undo, return:

    if keyfunction(lastkey) = "end-error" then do:
        hide frame ttrem.
        return.
    end.

    {apbra.i

    &start     = " "
    &head      = "ttrem"
    &headkey   = "ttrz"
    &index     = "ttrz"
    &formname  = "ttrem"
    &framename = "ttrem"
    &where     = "true"
    &addcon    = "false"
    &deletecon = "false"
    &precreate = " "
    &display   = "ttrem.ttrz ttrem.tamt ttrem.tcrc ttrem.tdet[1]"
    &highlight = "ttrem.ttrz ttrem.tamt ttrem.tcrc ttrem.tdet[1]"
    &postadd   = " "
    &postkey   = "else if keyfunction(lastkey) = 'RETURN' then do 
                on endkey undo, leave:
                    frame-value = ttrem.ttrz.
                    hide frame ttrem.
                    return.
                end."
    }
end.






