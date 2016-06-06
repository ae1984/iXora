/* jset.p
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

/** jset.p **/


{mainhead.i}
{jset.f}

define new shared variable set_rec as recid.

define shared variable funct as character.
      
define buffer bjouset for jouset.

define variable vrec as recid.

on help of jouset.drtype or help of jouset.crtype do:
    run help-jnum.
end.


{jabre.i

&head = "jouset"
&where = "jouset.fname eq funct"
&formname = "jset"
&framename = "fset"
&addcon = "true"
&deletecon = "true"
&display = "jouset.drtype jouset.crtype jouset.natcur jouset.des jouset.proc"
&highlight = "jouset.drtype jouset.crtype jouset.natcur jouset.des jouset.proc"
&postadd = "jouset.fname = funct.
            update jouset.des with frame fset.

            repeat on endkey undo, next upper:
                update jouset.drtype with frame fset.
                find jounum where jounum.des eq jouset.drtype no-lock no-error.
                    if available jounum then do:
                        jouset.drnum = jounum.num.
                        leave.
                    end.    
                    else undo, retry.
            end.
            repeat on endkey undo, next upper:
                update jouset.crtype with frame fset.
                    if jouset.crtype eq '' then leave.
                find jounum where jounum.des eq jouset.crtype 
                    no-lock no-error.
                    if available jounum then do:
                        jouset.crnum = jounum.num.
                        leave.
                    end.    
                    else undo, retry.
            end.
 
            update jouset.natcur with frame fset. 
            
            find first bjouset where bjouset.drtype eq jouset.drtype and
                bjouset.crtype eq jouset.crtype and bjouset.fname eq funct
                no-lock no-error.
                if available bjouset then do:
                    jouset.proc = bjouset.proc.
                    display jouset.proc with frame fset.
                end.    
                else do:
                    update jouset.proc with frame fset.
                end. "
&prechoose = "message 
'F4-выход; INSERT, CURSOR-DOWN-добавить; F10-удалить; ENTER-редакт.; 
TAB-коды комисс. F8-коды'."


&postkey = "else if keyfunction(lastkey) = 'RETURN' then do:
                update jouset.des with frame fset.
                repeat on endkey undo, next upper:
                    update jouset.drtype with frame fset.
                    find jounum where jounum.des eq jouset.drtype 
                        no-lock no-error.               
                        if available jounum then do:
                            jouset.drnum = jounum.num.
                            leave.
                        end.
                        else undo, retry.
                end.
                repeat on endkey undo, next upper:
                    update jouset.crtype with frame fset.
                        if jouset.crtype eq '' then leave.
                    find jounum where jounum.des eq jouset.crtype 
                        no-lock no-error.
                        if available jounum then do:
                            jouset.crnum = jounum.num.
                            leave.
                        end.    
                        else undo, retry.
                end.
                update jouset.natcur jouset.proc with frame fset. 
                for each bjouset where bjouset.drtype eq jouset.drtype and
                    bjouset.crtype eq jouset.crtype and bjouset.fname eq funct
                    exclusive-lock.
                        bjouset.proc = jouset.proc.
                end.
                next upper.
            end.
            else if keyfunction(lastkey) = 'TAB' then do:
                set_rec = recid (jouset).
                run jcom.
            end.
            else if keyfunction(lastkey) = 'CLEAR' then do:
                run jnum.
                for each jouset exclusive-lock:
                    find jounum where jouset.drnum eq jounum.num 
                        no-lock no-error.
                        if available jounum then jouset.drtype = jounum.des.
                    find jounum where jouset.crnum eq jounum.num 
                        no-lock no-error.
                        if available jounum then jouset.crtype = jounum.des.
                end.
                next upper.
            end.
            "
}


