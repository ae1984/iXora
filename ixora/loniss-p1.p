/* loniss-p1.p
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
def output parameter flag as inte.

find lon where lon.lon = s-lon no-lock no-error.
svopnamt = string(lon.opnamt, "z,zzz,zzz,zzz,zz9.99-").

{mainhead.i}

view frame msgp1.

upper:
repeat:

{jjbr.i
&head = "lnscg"
&headkey = "schn"
&where = "lnscg.lng = s-lon and lnscg.flp = 0 and lnscg.fpn = 0 
          and lnscg.f0 > -1"
&index = "lng"
&formname = "loniss-p1"
&framename = "loniss-p1"
&addcon = "false"
&start = " "
&display = "lnscg.mark lnscg.schn lnscg.stdat lnscg.stval lnscg.paid"
&postdisplay = " "
&postadd = " "
&postkey = "else if lastkey = 49 then do:
              flag = 2.
              hide frame msgp1.
              return.
            end.
            else if lastkey = 50 then do:
              flag = 3.
              hide frame msgp1.
              return.
            end."
&end = "hide frame msgp1. leave upper."
}
end. /* upper */

