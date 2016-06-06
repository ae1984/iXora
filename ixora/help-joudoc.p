/* help-joudoc.p
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

/**** help-crc1.p ****/

def var vtype as char.
def var vtim1 as char.
def var vtim2 as char.
def var vsts as inte.
def var dcrccode as char format "x(3)".
def var ccrccode as char format "x(3)".
{global.i}


define temp-table jouhelp like joudoc
   index wt whn tim descending.
  /* index whn whn.*/
          
for each joudoc where joudoc.whn = g-today and joudoc.who = g-ofc no-lock:
    create jouhelp.
    buffer-copy joudoc to jouhelp.
end.

/*
for each jouhelp:
    disp jouhelp.docnum jouhelp.whn string(jouhelp.tim, "hh:mm:ss").
end.    
*/

{jabrw.i

&start     = "view frame joudoc1."
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

