/* h-route.p
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



{global.i}
def var vans as logi.
def var ss as char init "*".
def var v-name as cha.

update ss label " TYPE  " with frame ss centered .

tab :
repeat:

{jabr.i
&start = " "
&head = "route"
&headkey = "ptype"
&where = "ptype matches ss"
&index = "fsp"
&formname = "pstype"
&framename = "ptype"
&addcon = "false"
&deletecon = "true"
&predisplay = " find first fproc where fproc.pid = route.pid no-lock no-error.
              if avail fproc then v-name = fproc.des . else v-name = """" . "
&display = "route.ptype route.pid format 'x(5)' v-name rcod npc format 'x(5)'"
&highlight = "route.ptype"
&postcreate = "if ss <> '*' then route.ptype = ss. "
&postdisplay = " "
&postadd = " if ss = '*' then
            update route.ptype route.pid rcod npc with frame ptype.
            else update route.pid rcod npc with frame ptype."
&postkey = "
            else if keyfunction(lastkey) = 'TAB' then do:
            update ss with frame ss.
            next tab.
            end.
            else if keyfunction(lastkey) = 'end-error' then do:
             return.
            end.
"

&end = "hide all. leave tab."
}
end.
