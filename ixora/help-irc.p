/* help-irc.p
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

/* help-irc.p */

{global.i}

define temp-table ttrem
    field ttrz like remtrz.remtrz
    field tamt like remtrz.amt
    field tcrc like remtrz.fcrc
    field tdet like remtrz.detpay
    index ttrz-value ttrz.

for each que where que.pid eq "2L" no-lock:
    find remtrz where remtrz.remtrz eq que.remtrz no-lock.
        if remtrz.rsub eq "CRCARD" then do:
            create ttrem.
            ttrem.ttrz    = remtrz.remtrz.
            ttrem.tamt    = remtrz.payment.
            ttrem.tcrc    = remtrz.tcrc.
            ttrem.tdet[1] = remtrz.detpay[1].
        end.
end.

repeat on endkey undo, return:

    if keyfunction(lastkey) = "end-error" then do:
        hide frame ttrem.
        return.
    end.

    {aapbra.i

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






