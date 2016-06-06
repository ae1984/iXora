/* a_help-joudoc.p
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
                05/09/2012 Luiza - изменила для remtrz
*/

define input parameter d as char format "x(4)".
def var vtype as char.
def var vtim1 as char.
def var vtim2 as char.
def var vsts as inte.
def var dcrccode as char format "x(3)".
def var ccrccode as char format "x(3)".
{global.i}


define temp-table jouhelp like joudoc index wt whn tim descending.

for each joudop where joudop.whn = g-today and joudop.who = g-ofc and joudop.type = d no-lock.
    find first remtrz where remtrz.remtrz = joudop.docnum no-lock no-error.
    if avail remtrz then do:
        create jouhelp.
        jouhelp.docnum    = joudop.docnum.
        jouhelp.drcur     = remtrz.fcrc.
        jouhelp.crcur     = remtrz.fcrc.
        jouhelp.dracctype = "4".
        jouhelp.cracctype = "4".
        jouhelp.dracc     = remtrz.dracc.
        jouhelp.cracc     = remtrz.cracc.
        jouhelp.dramt     = remtrz.amt.
        jouhelp.cramt     = remtrz.amt.
        jouhelp.jh        = remtrz.jh1.
        jouhelp.tim       = remtrz.rtim.
        jouhelp.who       = remtrz.rwho.
        jouhelp.whn       = remtrz.rdt.
    end.
end.

{jabrw.i

&start     = "view frame jouhelp1."
&head      = "jouhelp"
&headkey   = "docnum"
&index     = "wt"
&formname  = "jouhelp"
&framename = "jouhelp"
&where     = "jouhelp.whn = g-today and jouhelp.who = g-ofc"
&addcon    = "false"
&deletecon = "false"
&precreate = " "
&prechoose = " dcrccode = "". ccrccode = "".
               find crc where crc.crc = jouhelp.drcur no-lock no-error.
               if available crc then dcrccode = crc.code.
               find crc where crc.crc = jouhelp.crcur no-lock no-error.
               if available crc then ccrccode = crc.code.
               disp jouhelp.dracctype jouhelp.cracctype with frame jouhelp1.
               disp jouhelp.dracc jouhelp.dramt dcrccode
                    jouhelp.cracc jouhelp.cramt ccrccode
               with frame jouhelp1."
&predisplay = "vtim1 = ''. vtim2 = ''.
               find first jl where jl.jh = jouhelp.jh no-lock no-error.
               if not available jl then vsts = 0.
               else do:
                 find jh where jh.jh = jouhelp.jh no-lock no-error.
                 vtim2 = string(jh.tim,'HH:MM:SS').
                 vsts = jl.sts.
               end.
               vtim1 = string(jouhelp.tim,'HH:MM:SS').
               if jouhelp.dramt ne 0 then p-amt = jouhelp.dramt .
               else  p-amt = jouhelp.comamt . "

&display   = "jouhelp.docnum vtim1 jouhelp.jh vsts vtim2
              p-amt /*jouhelp.cramt jouhelp.comamt*/"
&highlight = "jouhelp.docnum vtim1 jouhelp.jh vsts vtim2
              p-amt /*jouhelp.cramt jouhelp.comamt*/"
&postadd   = " "
&postkey   = "else if keyfunction(lastkey) = 'RETURN' then do
                    on endkey undo, leave:
                    frame-value = jouhelp.docnum.
                    hide frame jouhelp.
                    hide frame jouhelp1.
                    return.
              end."
&end = "hide frame jouhelp.
        hide frame jouhelp1."
}

