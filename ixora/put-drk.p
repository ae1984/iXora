/* put-drk.p
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

define shared variable raksts    as character.

define input parameter p-fl1 as character.
define input parameter p-fl2 as character.
define input parameter p-printer as character.
define input parameter p-page   as character.
define        variable rinda    as character.
define        variable rinda1   as character.
define        variable j        as integer.
define        variable lpp      as integer init 1.
define        variable r-nr     as integer init 1.
define        variable viss     as logical init no.
define        variable ja-ne    as logical init yes.
define        variable frm      as character.
define        variable sak      as character init "".
define        variable v-page   as character init "".

define stream s1.
define stream s2.

if p-printer = "LASER"
then sak = chr(27) + "&l8C" + chr(10) +
           chr(27) + "&l70P" + chr(10) +
           chr(27) + "(2X" + 
           chr(10) + chr(12).


input  stream s1 from value(p-fl1).
output stream s2 to value(p-fl2).
import stream s1 raksts.
frm = substring(raksts,1,1).
if frm = "!" or frm = "*"
then do:
     if frm = "*"
     then v-page = substring(raksts,2).
     import stream s1 raksts.
end.
if frm <> "*"
then v-page = string(lpp,"999").
repeat on endkey undo,leave:
   if index(raksts,"^") > 0
   then do:
        import stream s1 raksts.
        next.
   end.
   if raksts = "$$"
   then do:
        import stream s1 raksts.
        next.
   end.
   if raksts = "ЉЄ" or raksts = "ЏЉ"
   then do:
        import stream s1 raksts.
        next.
   end.
   if raksts = "$"
   then do:
        ja-ne = not ja-ne.
        import stream s1 raksts.
        next.
   end.
   if ja-ne
   then do:
        rinda = raksts.
        raksts = "".
        if p-printer = "LASER"
        then do:
             if sak <> ""
             then put stream s2 sak format "x(50)".
             /* rinda = sak + rinda. */
             sak = "".
             j = index(rinda,"Љ“").
             do while j > 0:
                rinda = substring(rinda,1,j - 1) + chr(27) + chr(40) +
                        substring(rinda,j + 2,1) + chr(88) + 
                        substring(rinda,j + 3).
                j = index(rinda,"Љ“").
             end.
             j = index(rinda,"„Љ").
             do while j > 0:
                rinda = substring(rinda,1,j - 1) + chr(27) + chr(40) + 
                        chr(50) + chr(88) +
                        substring(rinda,j + 2).
                j = index(rinda,"„Љ").
             end.
        end.
        else do:
             j = index(rinda,"Љ“").
             do while j > 0:
                rinda = substring(rinda,1,j - 1) + /* chr(27) + "E" + */
                        substring(rinda,j + 3).
                j = index(rinda,"Љ“").
             end.
             j = index(rinda,"„Љ").
             do while j > 0:
                rinda = substring(rinda,1,j - 1) + /* chr(27) + "F" + */
                        substring(rinda,j + 2).
                j = index(rinda,"„Љ").
             end.
        end.
        j = index(rinda,"ђ•") + index(rinda,"•©").
        if j > 0
        then do:
             repeat while j > 0:
                j = minimum(index(rinda,"ђ•"),index(rinda,"•©")).
                if j = 0
                then j = maximum(index(rinda,"ђ•"),index(rinda,"•©")).
                rinda1 = substring(rinda,1,j - 1).
                raksts = raksts + rinda1.
                rinda = substring(rinda,j + 2).
                j = index(rinda,"ђ•") + index(rinda,"•©").
             end.
             raksts = raksts + rinda.
        end.
        else if index(rinda,"[") + index(rinda,"]") > 0
        then do:
             j = index(rinda,"[") + index(rinda,"]").
             repeat while j > 0:
                j = minimum(index(rinda,"["),index(rinda,"]")).
                if j = 0
                then j = maximum(index(rinda,"["),index(rinda,"]")).
                rinda1 = substring(rinda,1,j - 1).
                raksts = raksts + rinda1.
                rinda = substring(rinda,j + 1).
                j = index(rinda,"[") + index(rinda,"]").
             end.
             raksts = raksts + rinda.
        end.
        else if index(rinda,"&") > 0
        then do:
             rinda1 = substring(rinda,1,index(rinda,"&" ) - 1).
             raksts = raksts + rinda1 + " ".
             rinda  = substring(rinda,index(rinda,"&") + 1).
             rinda1 = substring(rinda,1,index(rinda,"&") - 1).
             raksts = raksts + rinda1 + " ".
             rinda  = substring(rinda,index(rinda,"&") + 1).
             raksts = raksts + rinda.
        end.
        else if index(rinda,"<") > 0
        then do:
             rinda1 = substring(rinda,1,index(rinda,"<") - 1).
             raksts = raksts + rinda1 + ":".
             rinda  = substring(rinda,index(rinda,"<") + 1).
             rinda1 = substring(rinda,1,index(rinda,">") - 1).
             raksts = raksts + rinda1 + ":".
             rinda  = substring(rinda,index(rinda,">") + 1).
             raksts = raksts + rinda.
        end.
        else if index(rinda,"#") > 0
        then do:
             rinda1 = substring(rinda,1,index(rinda,"#" ) - 1).
             raksts = raksts + rinda1 + ":".
             rinda  = substring(rinda,index(rinda,"#") + 1).
             rinda1 = substring(rinda,1,index(rinda,"#") - 1).
             raksts = raksts + rinda1 + ":".
             rinda  = substring(rinda,index(rinda,"#") + 1).
             raksts = raksts + rinda.
        end.
        else if index(rinda,"$") > 0
        then do:
             rinda1 = substring(rinda,1,index(rinda,"$" ) - 1).
             raksts = raksts + rinda1 + ":".
             rinda  = substring(rinda,index(rinda,"$") + 1).
             rinda1 = substring(rinda,1,index(rinda,"$") - 1).
             raksts = raksts + rinda1 + ":".
             rinda  = substring(rinda,index(rinda,"$") + 1).
             raksts = raksts + rinda.
        end.
        else if substring(rinda,1,1) = "!"
        then raksts = substring(rinda,2).
        else raksts = rinda.
        if index(raksts,"@") > 0
        then do:
             rinda = raksts.
             raksts = "".
             repeat while index(rinda,"@") > 0:
                rinda1 = substring(rinda,1,index(rinda,"@") - 1).
                raksts = raksts + rinda1 + '"'.
                rinda  = substring(rinda,index(rinda,"@") + 1).
             end.
             raksts = raksts + rinda.
        end.
        if substring(raksts,1,1) = "*" and substring(raksts,1,2) <> "**"
        then do:
             if frm = "*" and (p-page = v-page or p-page = "")
             then r-nr = 225.
             v-page = substring(raksts,2).
        end.
        /* else if raksts = "**"
        then viss = yes. */
        else if index(raksts,"***") = 0 and not viss
        then do:
             repeat while index(raksts,chr(126)) > 0:
                overlay(raksts,index(raksts,chr(126)),1) = "&".
             end.
             j = length(raksts).
             if p-page = "" or p-page = v-page
             then do:
                  put stream s2 unformatted raksts skip.
                  r-nr = r-nr + 1.
             end.
        end.
        if frm <> "!"
        then do:
             if frm <> "*"
             then do:
                  if r-nr >= 60
                  then do:
                       put stream s2 chr(12) skip.
                       lpp = lpp + 1.
                       v-page = string(lpp,"999").
                       put stream s2 skip
                           '-' at 37
                           lpp format 'z9'
                           ' -' skip(1).
                           r-nr = 4.
                  end.
             end.
             else if r-nr >= 200 
             then do:
                  put stream s2 chr(12) skip.
                  r-nr = 0.
             end.
        end.
   end.
   import stream s1 raksts.
end.
if frm <> "*"
then put stream s2 skip chr(12).
input stream s1 close.
output stream s2 close.
