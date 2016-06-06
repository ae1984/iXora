/* securprog.i
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
*/

define shared variable s-{&headkey} like {&head}.{&headkey}.
define shared variable s-newrec as logical.
define shared frame {&pre}{&post}.

define variable v-ans as logical.
define variable v-procro as char.
define var v-max as int initial 15.

{opt-prmt.i}

find {&head} where {&head}.{&headkey} eq s-{&headkey} no-lock no-error.

{nlvar.i new
"s-main = ""SUB"". s-opt = ""{&option}"". s-page = 1."}

{&variable}

s-page = 1.
run nlmenu.

form s-sign[1] s-menu s-sign[2] with frame menu col 1 row 1 width 110 no-box no-label.

{{&pre}{&post}.f}
{&frame}

{&start}

main:
repeat:
    hide message.
    {&predisplay}
    {&display}
    {&postdisplay}
    view frame {&pre}{&post}.
    {&viewframe}

    choose:
    repeat:
        display s-sign s-menu with no-box no-label frame menu.
        if s-newrec eq true then leave choose.
        choose field s-menu no-error with frame menu.
        if keyfunction(lastkey) eq "CURSOR-RIGHT" and frame-index eq v-max
        then do:
            if s-sign[2] ne ">" then do:
                bell.
            end.
            else do:
                s-page = s-page + 1.
                run nlmenu.
            end.
        end.
        else
        if keyfunction(lastkey) eq "CURSOR-LEFT" and frame-index eq 1
        then do:
            if s-sign[1] ne "<" then do:
                bell.
            end.
            else do:
                s-page = s-page - 1.
                run nlmenu.
            end.
        end.
        else
        if keyfunction(lastkey) eq "RETURN" or
        keyfunction(lastkey) eq "GO" then leave choose.
        else do:
            bell.
        end.
    end.

    if keyfunction(lastkey) eq "END-ERROR" then leave main.

    if s-page eq 1 and (frame-index eq 1 or frame-index eq 2) then do:
        if frame-index eq 1 and s-menu[1] ne " " then do:
            {&no-update}
            do transaction on error undo, retry:
                find current {&head} exclusive-lock.
                {&preupdate}
                {&update}
                {&postupdate}
                find current {&head} no-lock.
            end.
            s-newrec = false.
        end.
        else
        if frame-index eq 2 and s-menu[2] ne " " then do:
            bell.
            {mesg.i 0824} update v-ans.
            if v-ans eq false then do:
                bell.
                undo, next main.
            end.
            {&no-delete}
            find current {&head} exclusive-lock.
            do transaction on error undo, retry:
                {&predelete}
                {&delete}
                {&postdelete}
                clear frame {&pre}{&head}{&post}.
                {&clearframe}
            end.
            find {&head} where {&head}.{&headkey} eq s-{&headkey} no-lock no-error.
            leave main.
        end.
    end.
end.


