/* help-jnum.p
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

/** help-jnum.p **/


{global.i}

define buffer jjouset for jouset.

/*def var grec as recid.*/

{jabre.i

&start     = " "
&head      = "jounum"
&formname  = "jnum"
&framename = "jnum"
&where     = " "
&addcon    = "false"
&deletecon = "false"
&precreate = " "
&display   = "jounum.num jounum.des" 
&highlight = "jounum.num jounum.des"
&postadd   = " "
&postkey   = "else if keyfunction(lastkey) = 'RETURN' then do 
                    on endkey undo, next upper:
                    frame-value = jounum.des.
                    hide frame jnum.
                    return.
              end.
              /*
              else if keyfunction(lastkey) = 'TAB' then do :
                   /* on endkey undo, next upper:*/
                    update jounum.des with frame jnum.
                    hide frame jnum.
                    return.
              end.*/
              "
&end = "hide frame jnum."
}

