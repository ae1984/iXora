/* ujo_sec.p
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
*/

/** ujo_sec.p **/


define button templ_add    label "Добавить".
define button templ_delete label "Удалить".
define button templ_ofcs   label "Список исполнителей".
define button templ_exit   label "Выход".

define button ofc_add      label "Добавить".
define button ofc_delete   label "Удалить".
define button ofc_back     label "Выход".

define temp-table w_ofc
    field ofc  like ofc.ofc
    field name like ofc.name.

define query templ_query for ujosec, trxhead scrolling.
define browse templ_browse query templ_query display
    ujosec.template label "Код шаблона" 
    trxhead.des     label "Наименование шаблона"
    enable ujosec.template
    with 10 down no-assign no-hide.

define frame templ_frame templ_browse
    skip(2)  
    templ_ofcs at 18 templ_add templ_delete templ_exit
    with col 5.


define query ofc_query for w_ofc scrolling.
define browse ofc_browse query ofc_query display
    w_ofc.ofc   label "Исполнитель" 
    w_ofc.name  label "Имя"
    enable w_ofc.ofc
    with row 6 10 down no-assign no-hide.

define frame ofc_frame ofc_browse
    ofc_add at 15 ofc_delete ofc_back
    with row 5 column 31 centered overlay.



define variable var_templ as character format "x(7)". 
define variable v_templ as character format "x(7)".
define variable var_ofc   like ofc.ofc.
 
  
on end-error of frame ofc_frame or endkey of frame ofc_frame anywhere do:
    return no-apply.
end.

on end-error of frame templ_frame or endkey of frame templ_frame anywhere do:
    return no-apply.
end.

on help of ujosec.template in browse templ_browse do:
    run help-trxsys.
end.

on help of w_ofc.ofc in browse ofc_browse do:
    run help-ofc. 
end.

on choose of templ_ofcs in frame templ_frame do:
    run Create_ofc_table.

    v_templ = ujosec.template.
    find first w_ofc no-error.
        if not available w_ofc then do:
            message "Исполнители не обнаружены. Добавить ?" 
                view-as alert-box question buttons yes-no 
                update choise as logical.
            if choise then do:      
                disable all with frame templ_frame.
                open query ofc_query for each w_ofc.
                enable all with  frame ofc_frame.    
                ofc_browse:insert-row("after").
            end.
            else apply "entry" to browse templ_browse.
        end.    
        else do:
            disable all with frame templ_frame.
            open query ofc_query for each w_ofc.
            enable all with  frame ofc_frame.    
            apply "entry" to browse ofc_browse.
        end.
end.

on choose of templ_add in frame templ_frame do:
    templ_browse:insert-row("after").
    message "F2 - Помощь.".
end.

     /*
on choose of templ_exit in frame templ_frame do:
    for each ujosec.
        disp ujosec.
    end. 
end.   */


on row-leave of browse templ_browse do:
    var_templ = ujosec.template:screen-value in browse templ_browse.
    find trxhead where trxhead.system eq substring (var_templ, 1, 3) and
        trxhead.code eq integer (substring (var_templ, 4, 4)) 
                                                            no-lock no-error.
    IF not available trxhead then do:
        message "Шаблон не обнаружен.".
        pause.
        
        if templ_browse:new-row in frame templ_frame then do:
            templ_browse:delete-current-row() in frame templ_frame.
            
            find first ujosec no-error.
                if not available ujosec then templ_browse:insert-row("after").
        end.    
        else ujosec.template:screen-value in browse templ_browse =                                                           ujosec.template.
    END.
    ELSE do:
    if templ_browse:new-row in frame templ_frame then do:
        find ujosec where ujosec.template eq ujosec.template:screen-value 
                                    in browse templ_browse no-lock no-error.
        if available ujosec then do:
            message "Шаблон заведен.".
            templ_browse:delete-current-row() in frame templ_frame.
            undo, return.
        end.
        else do:
            create ujosec.
            assign input browse templ_browse ujosec.template.
        end.

        close query ofc_query.
        open query templ_query for each ujosec, each trxhead where 
            trxhead.system eq substring (ujosec.template, 1, 3) and
            trxhead.code eq integer (substring (ujosec.template, 4, 4)) no-lock.
    end.
    else ujosec.template:screen-value in browse templ_browse = ujosec.template.
    END.
end.

on row-leave of browse ofc_browse do:
    find ofc where ofc.ofc eq w_ofc.ofc:screen-value in browse ofc_browse
                                                    no-lock no-error.
        if not available ofc then do:
            message "Исполнитель не зарегистрирован.".
            pause.
            ofc_browse:delete-current-row() in frame ofc_frame.
            close query ofc_query.
            open query ofc_query for each w_ofc.
        end.
        else do:
            if ofc_browse:new-row in frame ofc_frame then do:
                find first w_ofc where w_ofc.ofc eq 
                    w_ofc.ofc:screen-value in browse ofc_browse no-error.
                
                if available w_ofc then do:
                    message "Этому уже можно.".
                    pause.
                    ofc_browse:delete-current-row() in frame ofc_frame.
                end.
                else do:
                    create w_ofc.
                    assign input browse ofc_browse w_ofc.ofc.
                    w_ofc.name = ofc.name.
                    w_ofc.name:screen-value in browse ofc_browse = w_ofc.name.
                    find ujosec where ujosec.template eq v_templ 
                                                            exclusive-lock.
                    ujosec.officers = ujosec.officers + w_ofc.ofc + ",".
                    close query ofc_query.
                    open query ofc_query for each w_ofc.
                end.
            end.
            else w_ofc.ofc:screen-value in browse ofc_browse = w_ofc.ofc.
        end.
end.

on choose of templ_delete in frame templ_frame do:
    message "Шаблон будет удален. Подтвердите." view-as alert-box question       buttons yes-no update choise as logical.
        
    if not choise then apply "entry" to browse templ_browse.    
    else do:
        find ujosec where ujosec.template eq ujosec.template:screen-value
                                        in browse templ_browse exclusive-lock.
        delete ujosec.
        templ_browse:delete-current-row() in frame templ_frame.
        
        find first ujosec no-error.
            if not available ujosec then 
                            apply "entry" to templ_add in frame templ_frame.
            else apply "entry" to browse templ_browse.
    end.
end.

on choose of ofc_delete in frame ofc_frame do:
    message "Исполнитель будет удален. Подтвердите." view-as alert-box question      buttons yes-no update choise as logical.
        
    if not choise then apply "entry" to browse ofc_browse.    
    else do:
        find first w_ofc where w_ofc.ofc eq w_ofc.ofc:screen-value in
            browse ofc_browse.
        delete w_ofc.
        ofc_browse:delete-current-row() in frame ofc_frame.
        find first w_ofc no-error.
            if not available w_ofc then do:
                apply "entry" to ofc_add in frame ofc_frame.
            end.
            else do:
                apply "entry" to browse ofc_browse.
            end.
    end.
end.

on choose of ofc_back in frame ofc_frame do:
    find ujosec where ujosec.template eq v_templ exclusive-lock.
    ujosec.officers = "".
    for each w_ofc break by w_ofc.ofc:
        ujosec.officers = ujosec.officers + w_ofc.ofc + ",".
    end.
    release ujosec.
    disable all with frame ofc_frame.
    hide frame ofc_frame.
    enable all with frame templ_frame.
    apply "entry" to browse templ_browse.
end.

on choose of ofc_add in frame ofc_frame do:
    ofc_browse:insert-row("after").
    message "F2 - Помощь.".
end.

open query templ_query for each ujosec, 
    each trxhead where trxhead.system eq substring (ujosec.template, 1, 3) and
    trxhead.code eq integer (substring (ujosec.template, 4, 4))
    no-lock.

enable all with  frame templ_frame.

find first ujosec no-error.
    if not avail ujosec then apply "entry" to templ_add in frame templ_frame.
    else apply "value-changed" to browse templ_browse.
    
wait-for window-close of current-window or choose of templ_exit.



Procedure Create_ofc_table.
    define variable i as integer.
    
    for each w_ofc.
        delete w_ofc.
    end.
    
    do i = 1 to num-entries (ujosec.officers):
        if entry (i, ujosec.officers) eq "" then next.

        find ofc where ofc.ofc eq entry (i, ujosec.officers) no-lock no-error.
            if not available ofc then do:
            message substitute 
                ("Неизвестный исполнитель - &1. Удалить ? ", 
                entry (i, ujosec.officers))
                view-as alert-box question buttons yes-no 
                update choise as logical.
                    if choise then next.    
            end.
            
        create w_ofc.
        w_ofc.ofc = entry (i, ujosec.officers).
        w_ofc.name = ofc.name.
    end.
end procedure.
