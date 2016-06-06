/* k0-ptyp.p
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


{mainhead.i PTYP} /* "" */          
{ps-prmt.i}                        
display " Справочник типов платежей " with centered .
pause 0.

repeat :
{jabrw.i
&head = "ptyp"
&headkey = "ptype"
&where = " "
&index = "ptype"
&formname = "ptyp"
&framename = "ptyp"
&addcon = "true"
&updatecon = "true"
&deletecon = "true"
&predisplay = " "
&display = "ptyp.ptype ptyp.des ptyp.receiver ptyp.sender"
&postdisplay = " "
&numprg = "prompt"
&preadd = " "
&postadd = " if trim(ptype) = """" then delete ptyp ."
&newpreupdate = " "
&preupdate = " "
&update = "ptype validate(ptype ne ""0"",'') ptyp.des ptyp.receiver ptyp.sender"
&postupdate = " "
&predelete = " "
&postdelete = " "
&highlight = "ptyp.ptype "
&end = "hide all. leave ."
}
end.
