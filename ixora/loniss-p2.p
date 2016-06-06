/* loniss-p2.p
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

/* LOAN PRINCIPAL VALUE RETURN SCHEDULE */
def shared var s-lon like lnsch.lnn.
def new shared var s-f0 like lnsch.f0.
def new shared var s-jh like jh.jh.
def var svopnamt as char format "x(21)".
def var vall like lon.opnamt.
def output parameter flag as inte.
{mainhead.i}
view frame msgp2.
pause 0.
   
upper:
repeat:
   vall = 0.
for each lnscg where lnscg.lng = s-lon and lnscg.flp > 0 
                                    and lnscg.fpn = 0  and lnscg.f0 > -1:
   vall = vall + lnscg.paid.
end.
if svopnamt <> string(vall, "z,zzz,zzz,zzz,zz9.99-") then do:
hide frame loniss-p2.
svopnamt = string(vall, "z,zzz,zzz,zzz,zz9.99-").
end.

{jjbr.i
&head = "lnscg"
&headkey = "schn"
&where = "lnscg.lng = s-lon and lnscg.flp > 0 and lnscg.fpn = 0 
          and lnscg.f0 > -1"
&index = "lng"
&formname = "loniss-p2"
&framename = "loniss-p2"
&addcon = "false"
&start = " "
&display = "lnscg.schn lnscg.stdat lnscg.paid lnscg.jh"
&postdisplay = " "
&postadd = " "
&postkey = "else if lastkey = 49 then do:
              flag = 1.
              hide frame msgp2.
              return.
            end.
            else if lastkey = 50 then do:
              flag = 3.
              hide frame msgp2.
              return.
            end.
            else if lastkey = 13 then do:
               {loniss-p2.i}
            end."
&end = "hide frame msgp2. leave upper."
}
end. /* upper */

