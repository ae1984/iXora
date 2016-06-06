/* loniss-p3.p
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
def var sval     as char format "x(21)".
def var vval like lon.opnamt.
def output parameter flag as inte.

vval = 0.
for each lnscg where lnscg.lng = s-lon and lnscg.flp = 0 
                            and lnscg.fpn = 0 and lnscg.f0 > -1:
 vval = vval + lnscg.paid.
end.
svopnamt = string(vval, "z,zzz,zzz,zzz,zz9.99-").
vval = 0.
for each lnscg where lnscg.lng = s-lon and lnscg.flp > 0 
                                 and lnscg.f0 > -1 and lnscg.fpn = 0:
vval = vval + lnscg.paid.
end.
sval = string(vval, "z,zzz,zzz,zzz,zz9.99-").

view frame msgp3.

{mainhead.i}

upper:
repeat:

{jjbr.i
&head = "lnscg"
&headkey = "schn"
&where = "lnscg.lng = s-lon and lnscg.flp > -1 and lnscg.fpn = 0
          and lnscg.f0 > -1 "
&index = "lng"
&formname = "loniss-p3"
&framename = "loniss-p3"
&addcon = "false"
&start = " "
&display = "lnscg.schn lnscg.schn lnscg.stdat lnscg.stval lnscg.paid lnscg.jh"
&postdisplay = " "
&postadd = " "
&postkey = "else if lastkey = 49 then do:
             flag = 1.
             hide frame msgp3.
             return.
            end.
            else if lastkey = 50 then do:
             flag = 2.
             hide frame msgp3.
             return.
            end.
            else if lastkey = 13 then do:
             {loniss-p3.i}
            end."
&end = "hide frame msgp3. leave upper."
}
end. /* upper */

