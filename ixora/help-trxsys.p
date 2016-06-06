/* help-trxsys.p
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

/**  help-trxsys.p  **/


{global.i}
                 
define new shared variable v_system as character.

repeat:
    run help-system.
    if keyfunction(lastkey) eq "end-error" then return. 

    {aapbra.i

    &start     = " "
    &head      = "trxhead"
    &index     = "syscode no-lock "
    &formname  = "sys"
    &framename = "sys"
    &where = " (( trxhead.system  matches ""*"" + v_system + ""*"" ) or
        ( v_system = """" )) "
    &addcon    = "false"
    &deletecon = "false"
    &precreate = " "
    &display   = "trxhead.system trxhead.code trxhead.des" 
    &highlight = "trxhead.system trxhead.code trxhead.des"
    &postadd   = " "
    &postkey   = "else if keyfunction(lastkey) = 'RETURN' then do 
                    on endkey undo, leave:
                    
                    frame-value = 
                        trxhead.system + string(trxhead.code,""9999"").
                    hide frame sys.
                    return.
                end."
    &end = "hide frame sys."
}
end.
