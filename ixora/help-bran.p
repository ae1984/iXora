/* help-bran.p
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

/**** help-bran.p ****/

{global.i}

{apbra.i

&start     = " "
&head      = "bankl"
&headkey   = "bank"
&index     = "bank"
&formname  = "hbank"
&framename = "hbank"
&where     = "bankl.bank begins ""rkb"" "
&addcon    = "false"
&deletecon = "false"
&precreate = " "
&display   = "bankl.bank bankl.name"
&highlight = "bankl.bank bankl.name"

&postadd   = " "
&postkey   = "else if keyfunction(lastkey) = 'RETURN' then do 
                    on endkey undo, leave:
                    
                    frame-value = bankl.bank.
                    hide frame hbank.
                    return.
              end."
&end = "hide frame hbank."
}


