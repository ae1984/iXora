/* jnum.p
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

/** jnum.p **/


{global.i}

{jabre.i

&start     = " "
&head      = "jounum"
&formname  = "jnum"
&framename = "jnum"
&where     = " "
&addcon    = "true"
&deletecon = "false"
&precreate = " "
&display   = "jounum.num jounum.des" 
&highlight = "jounum.num jounum.des"
&postadd   = "update jounum.num jounum.des with frame jnum."
&prechoose = "message
'F4-выход; INSERT, CURSOR-DOWN-добавить.; ENTER-редактировать; '."
&postkey   = "else if keyfunction(lastkey) = 'RETURN' then do 
                    on endkey undo, next upper:
                    update jounum.des with frame jnum.
              end."
&end = "hide frame jnum."
}
                    
