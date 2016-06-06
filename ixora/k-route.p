/* k-route.p
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
        06.10.2003 nadejda  - изменила формат вывода (побольше символов для кода процесса)
*/

{global.i}                                        
{ps-prmt.i}                                         
def var vans as logi.
def var ss as char init "*".
def var v-name as cha.

update ss label " Тип платежа ? " with frame ss centered .

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
&addcon = "true"
&deletecon = "true"
&predisplay = " find first fproc where fproc.pid = route.pid no-lock no-error.
              if avail fproc then v-name = fproc.des . else v-name = '' . "
&display = "route.ptype route.pid v-name rcod npc "
&highlight = "route.ptype"
&postcreate = "if ss <> '*' then route.ptype = caps(ss). v-name = ''. "
&postdisplay = " "
&postadd = "if ss = '*' then update route.ptype with frame ptype.
             v-name = ''.
             update route.pid with frame ptype.
             route.pid = caps(route.pid).
             find first fproc where fproc.pid = route.pid no-lock no-error.
             if avail fproc then v-name = fproc.des .
               display v-name with frame ptype.
             update rcod npc with frame ptype. 
             rcod = caps(rcod).  npc = caps(npc)."
&postkey = "else if keyfunction(lastkey) = 'RETURN' then do:
              if ss = '*' then update route.ptype with frame ptype.
               update route.pid with frame ptype.
               route.pid = caps(route.pid).
               find first fproc where fproc.pid = route.pid no-lock
                           no-error.
               v-name = ''.
               if avail fproc then v-name = fproc.des .
                  display v-name with frame ptype.
               update rcod npc with frame ptype.
               rcod = caps(rcod).  npc = caps(npc).
               next upper. 
             end.
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
