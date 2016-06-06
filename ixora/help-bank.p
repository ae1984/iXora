/* help-bank.p
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

/**** help-bank.p ****/

{global.i}

{apbra.i

&start     = " "
&head      = "bankl"
&headkey   = "bank"
&index     = "bank"
&formname  = "hbank"
&framename = "hbank"
&where     = "true"
&addcon    = "false"
&deletecon = "false"
&precreate = " "
&display   = "bankl.bank bankl.name bankl.cbank"
&highlight = "bankl.bank bankl.name bankl.cbank"

&postadd   = " "
&postkey   = "else if keyfunction(lastkey) = 'RETURN' then do 
                    on endkey undo, leave:
                    
                    frame-value = bankl.bank.
                    hide frame hbank.
                    return.
              end."
}


