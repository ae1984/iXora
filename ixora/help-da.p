/* help-da.p
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
       23.08.2004 sasco добавил поиск пакетов по логину офицера
*/

/** help-da.p **/


{global.i}

define input parameter who_am_I like ofc.ofc.

define variable pakets as character.
run getpakets (who_am_i).
pakets = return-value.

define variable i as integer.

define temp-table da
    field template like ujosec.template
    field des      like trxhead.des.
    
for each ujosec no-lock:

    DO i = 1 to num-entries (ujosec.officers):

/*    if entry (i, ujosec.officers) eq who_am_I then do:     */

    if lookup (entry (i, ujosec.officers), pakets) > 0 then do:     
    
        find da where da.template = ujosec.template no-error.
        if avail da then next. 

        create da.
        da.template = ujosec.template.
        find trxhead where 
            trxhead.system eq substring (ujosec.template, 1, 3) and
            trxhead.code eq integer (substring (ujosec.template, 4, 4))
                                                            no-lock no-error.
        da.des = trxhead.des.                                                       

    end. /* lookup > 0 */

    end. /* i */

end. /* ujosec */


{jabre.i

&start     = " "
&head      = "da"
&formname  = "da"
&framename = "da"
&where     = " "
&addcon    = "false"
&deletecon = "false"
&display   = "da.template da.des" 
&highlight = "da.template da.des"
&prechoose = " /*message
'F4-выход; INSERT, CURSOR-DOWN-добавить.; ENTER-редактировать; '.*/ "
&postkey   = "else if keyfunction(lastkey) = 'RETURN' then do 
                    on endkey undo, return:
                    frame-value = da.template.
                    hide frame da.
                    return.
              end."
&end = "hide frame da."
}
                    
