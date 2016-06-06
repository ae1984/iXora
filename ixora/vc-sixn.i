/* vc-sixn.i
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
        17/06/04   saltanat - включена shared переменная "s-contrstat" для определения статуса контрактов(откр.,закр.)
        12.01.2009 galina   - добавила проверку наличия пункта верхнего меню перед вызовом процедуры
        11.05.2012 damir    - привел программу в читаемый вид.
*/

/* sixn.i для валютного контроля
   ввод нового контракта

   18.10.2002 nadejda - изменен поиск: не по F2, а сразу запрос на вид поиска
*/

define new shared variable s-contrstat  as char initial 'all'.
define new shared variable s-{&headkey} like {&head}.{&headkey}.
define new shared variable s-newrec     as logical.
/*define new shared variable s-contrstat as char.*/

define new shared frame {&pre}{&head}{&post}.
define new shared frame menu.

def buffer b{&head} for {&head}.

define variable v-procro as char.

{opt-prmt.i}

{nlvar.i new
"s-main = ""MAIN"". s-opt = ""{&option}"". s-page = 1."}

{&variable}

s-page = 1.
run nlmenu.

form s-sign[1] s-menu s-sign[2] with frame menu col 1 row 1 width 110 no-box no-label.

{{&pre}{&head}{&post}.f}
{&frame}

{&start}

/* Для определения необходимого статуса контрактов. */
s-contrstat = {&status}.

main:
repeat:
    hide message no-pause.
    clear frame {&pre}{&head}{&post}.
    {&clearframe}
    view frame {&pre}{&head}{&post}.
    {&viewframe}

    choose:
    repeat:
        display s-sign s-menu with no-box no-label frame menu.
        choose field s-menu no-error with frame menu.
        if keyfunction(lastkey) eq "CURSOR-RIGHT" and frame-index eq 11 then do:
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
    end. /* choose */

    if keyfunction(lastkey) eq "END-ERROR" then leave main.

    if s-page eq 1 and (frame-index eq 1 or frame-index eq 2) then do:

        if frame-index eq 1 then do:
            {&no-find}
            {&prefind}
            run h-{&headkey}.
            find {&head} where {&head}.{&headkey} = s-{&headkey} no-lock no-error.
            {&postfind}
            pause 0.
        end.
        else if frame-index eq 2 then do:
            {&no-add}
            do transaction on error undo, retry:
                if "{&numsys}" begins "auto" then do:
                    if "{&keytype}" begins "integer" or "{&keytype}" begins "decimal"  then do:
                        {&preadd}
                        create {&head}.
                        find last b{&head} no-lock no-error.
                        if available b{&head} then {&head}.{&headkey} = {&keytype}(integer({&head}.{&headkey}) + 1).
                        else {&head}.{&headkey} = {&keytype}(1).
                        s-{&headkey} = {&head}.{&headkey}.
                    end.
                    else if "{&keytype}" begins "string" then do:
                        find nmbr where nmbr.code = "{&nmbrcode}" exclusive-lock.
                        s-{&headkey} = {&keytype}(nmbr.prefix + string(nmbr.nmbr + 1) + nmbr.sufix).
                        nmbr.nmbr = nmbr.nmbr + 1.
                        release nmbr.
                        {&preadd}
                        create {&head}.
                        {&head}.{&headkey} = s-{&headkey}.
                    end.
                end.    /* end auto */
                else if "{&numsys}" begins "prog" then do:
                    {&preadd}
                    run {&numprg}.
                    find {&head} where {&head}.{&headkey} = s-{&headkey} no-error.
                end.    /* program */
                {&postadd}
                pause 0.
                s-newrec = true.
            end. /* error */
        end. /* add */
        run {&subprg} .
        s-newrec = false.
        s-page = 1.
        s-main = "MAIN".
        s-opt = "{&option}".
        run nlmenu.
    end.
    else do:
        find optitem where optitem.optmenu eq s-opt and optitem.ln eq (s-page - 1) * 11 + frame-index - 2 no-lock no-error.
        if avail optitem then do:
            if chkrights(optitem.proc) then do:
                if search(optitem.proc + ".r") <> ? then do:
                    run value(optitem.proc).
                    pause 0.
                end.
                else do:
                    {mesg.i 0210}.
                end.
            end.
            else do:
                v-procro = chkproc-ro(s-opt, optitem.proc).
                if v-procro = "" then do:
                    bell.
                    message "   У вас нет прав для выполнения процедуры " + optitem.proc + " !" view-as alert-box button ok title "".
                end.
                else do: /* процедура только для чтения */
                    if search(v-procro + ".r") <> ? then do:
                        run value(v-procro).
                        pause 0.
                    end.
                    else do:
                        {mesg.i 0210}.
                    end.
                end.
            end.
        end.
    end.
end. /* main */
{&end}





