/* sec.i
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
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
        --/--/2011 damir
 * BASES
        BANK COMM
 * CHANGES
        07.11.2011 damir - it's jabro.i copy.
*/

define new shared variable s-{&headkey} like {&head}.{&headkey}.
define new shared variable s-newrec as logical.

define new shared frame {&pre}{&post}{&formname}.
define new shared frame menu.
def buffer b{&head} for {&head}.
define variable v-procro as char.
def var v-log as logical init false.

define var v-max as int initial 15.

{opt-prmt.i}

{nlvar.i new
"s-main = ""MAIN"". s-opt = ""{&option}"". s-page = 1."}

{&variable}

s-page = 1.
run nlmenu.

form s-sign[1] s-menu s-sign[2] with frame menu col 1 row 1 width 110 no-box no-label.

{{&pre}{&post}{&formname}.f}
{&frame}

{&start}

main:
repeat:
    hide message no-pause.
    clear frame {&pre}{&post}{&formname}.
    {&clearframe}
    view frame {&pre}{&post}{&formname}.
    {&viewframe}

    choose:
    repeat:
        display s-sign s-menu with no-box no-label frame menu.
        choose field s-menu no-error with frame menu.
        if keyfunction(lastkey) eq "CURSOR-RIGHT" and frame-index eq v-max then do:
            if s-sign[2] ne ">" then do:
                bell.
            end.
            else do:
                s-page = s-page + 1.
                run nlmenu.
            end.
        end.
        else if keyfunction(lastkey) eq "CURSOR-LEFT" and frame-index eq 1 then do:
            if s-sign[1] ne "<" then do:
                bell.
            end.
            else do:
                s-page = s-page - 1.
                run nlmenu.
            end.
        end.
        else if keyfunction(lastkey) eq "RETURN" or keyfunction(lastkey) eq "GO" then leave choose.
        else do:
            bell.
        end.
    end.

    if keyfunction(lastkey) eq "END-ERROR" then leave main.

    if s-page eq 1 and (frame-index eq 1 or frame-index eq 2) then do:
        if frame-index eq 1 then do:
            {&no-find}
            {&prefind}
            run h-{&head}.
            {&postfind}
            pause 0.
        end.
        else if frame-index eq 2 then do:
            if "{&numsys}" begins "auto" then do:
                if "{&keytype}" begins "string" then do:
                    do transaction on error undo, leave:
                        {&preadd}
                        {&update}
                        if keyfunction(lastkey) eq "END-ERROR" then next main.
                        create {&head}.
                        {&head}.{&headkey} = next-value(secser).
                        {&postupdate}
                    end.
                end.
            end.
            pause 0.
            s-newrec = true.
        end.
        s-newrec = false.
        s-page = 1.
        s-main = "MAIN".
        s-opt = "{&option}".
        run nlmenu.
    end.
end.
{&end}
