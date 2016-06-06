/* jfun.p
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

/** jfun.p **/
 
{mainhead.i}

define new shared variable funct as character.

define variable ask as logical format "Да/Нет".
define variable vfname as character format "x(30)".
define variable mess as character initial
    "F2 - ПОМОЩЬ, INSERT - ДОБАВИТЬ, F10 - УДАЛИТЬ, F4 - ВЫХОД ".

define frame ffunct
    space(2)
    funct label "НАЗВАНИЕ ФУНКЦИИ " 
    jouset.fundes label "ОПИСАНИЕ"
    space(5)
    with row 3 side-labels.

define frame ffunct1 
    space(2)
    funct label "НАЗВАНИЕ ФУНКЦИИ " 
    jouset.fundes label "ОПИСАНИЕ"
    space(5)
    with row 3 side-labels.


repeat on endkey undo, return:
    on help of funct in frame ffunct do:
        run help-fun.
    end.

    on delete-line of funct in frame ffunct do:
        find first jouset where jouset.fname eq funct no-lock no-error.
            if not available jouset then do:
                message "ФУНКЦИЯ НЕ УКАЗАНА".
                pause 3.
                undo, return.
            end.

        display jouset.fname @ funct jouset.fundes with frame ffunct1.
        
        ask = false.
        message "УДАЛИТЬ ФУНКЦИЮ ?" update ask.
            if not ask then do:
                message mess.
                undo, return.
            end.    

        for each jouset where jouset.fname eq funct exclusive-lock transaction:
            delete jouset.
        end.    
        release jouset.
    end.

    on insert of funct in frame ffunct do:
        hide message.
        message "ДОБАВИТЬ НОВУЮ ФУНКЦИЮ ?" update ask.
            if not ask then do:
                message mess.
                undo, return.
            end.    
        
        funct = "".
        display funct with frame ffunct1.
        update funct with frame ffunct1.
        find first nmdes where nmdes.fname eq funct no-lock no-error.
            if not available nmdes then do:
                message "ФУНКЦИЯ НЕ НАЙДЕНА... ".
                pause 3.
                undo, retry.
            end.
        find first jouset where jouset.fname eq funct no-lock no-error.
            if available jouset then do:
                message "ФУНКЦИЯ В НАСТРОЙКАХ УЖЕ ОПИСАНА... ".
                pause 3.
                undo, retry.
            end.
            
        create jouset.
        jouset.fname = funct.
        jouset.fundes = nmdes.des.
        display jouset.fundes with frame ffunct1.

        run jset.
    end.                   
   
    message mess.
    display vfname @ jouset.fundes with frame ffunct.
    update funct with frame ffunct.
    find first jouset where jouset.fname eq funct no-lock no-error.
        if not available jouset then do:
            hide message.
            message "ФУНКЦИЯ НЕ НАЙДЕНА... ".
            undo, retry.
        end.
    
    vfname = jouset.fundes.                           
    display jouset.fundes with frame ffunct.
    run jset.          
end.               
