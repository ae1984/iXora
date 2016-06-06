/* acc_setup.f
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

form
    tree.account    label "Account" 
    tree.prefix     label "Prefix"  
    tree.def_prefix label "DefPref"
    tree.ancestor   label "Ancestor"
    tree.old_acc    label "Old Account"
    tree.name 	    label "Name"
with 15 down title "Accounts Structure Setup" overlay row 4 column 2 frame acc_setup.	
