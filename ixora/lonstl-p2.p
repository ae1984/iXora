/* lonstl-p2.p
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

vall = 0.
find first lnsch where lnsch.lnn = s-lon and lnsch.flp = -1 
                                         and lnsch.fpn = 0 no-error.
if available lnsch then vall = lnsch.paid.
svopnamt = string(vall, "z,zzz,zzz,zzz,zz9.99-").

view frame msgp2.
pause 0.

{mainhead.i}

upper:
repeat:

{jjbr.i
&head = "lnsch"
&headkey = "schn"
&where = "lnsch.lnn = s-lon and lnsch.flp > 0 and lnsch.fpn = 0 
          and lnsch.f0 > -1"
&index = "lnn"
&formname = "lonstl-p2"
&framename = "lonstl-p2"
&addcon = "false"
&start = " "
&display = "lnsch.schn lnsch.stdat lnsch.paid lnsch.jh"
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
             {lonstl-p2.i}
            end."
&end = "hide frame msgp2. leave upper."
}
end. /* upper */
/*-----------------------------------------------------------------------
  #3.
     1.izmai‡a - mainЁts form–ts rind–m > 100
------------------------------------------------------------------------*/
