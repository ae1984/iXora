/* lonstl-p1.p
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

find lon where lon.lon = s-lon no-error.
svopnamt = string(lon.opnamt, "z,zzz,zzz,zzz,zz9.99-").

{mainhead.i}

view frame msgp1.
pause 0.

upper:
repeat:

{jjbr.i
&head = "lnsch"
&headkey = "schn"
&where = "lnsch.lnn = s-lon and lnsch.flp = 0 and lnsch.fpn = 0 
          and lnsch.f0 > 0"
&index = "lnn"
&formname = "lonstl-p1"
&framename = "lonstl-p1"
&addcon = "false"
&start = " "
&display = "lnsch.schn lnsch.stdat lnsch.stval lnsch.paid"
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
/*------------------------------------------------------------------
  #3.
     1.izmai‡a - mainЁts form–ts, lai var apstr–d–t rindas > 100
-------------------------------------------------------------------*/
