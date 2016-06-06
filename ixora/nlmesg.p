/* nlmesg.p
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

/* nlmesg.p
*/

{mainhead.i NLMSG}
def buffer t-msg for msg.
{listedit.i
&type = "integer"
&head = "msg"
&headkey = "ln"
&where = "msg.lang eq s-lang"
&index = "msg"
&addcon = "false"
&deletecon = "true"
&updatecon = "true"
&form = "msg.ln msg.msg"
&predisplay = " if available t-msg then
 find msg where t-msg.ln = msg.ln and t-msg.lang = msg.lang. "
&display = " msg.ln msg.msg "
&startupdate = "find t-msg where t-msg.ln = msg.ln and t-msg.lang = msg.lang. "
&update = " msg.msg "
&frame = "row 4 down centered no-box"
&variable = "define new shared variable s-lang like lang.lang."
&start = "update s-lang with no-box side-label centered frame xyz."
}
