/* lonstl-p3.p
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
for each lnsch where lnsch.lnn = s-lon and lnsch.flp = 0 
          and lnsch.fpn = 0 and lnsch.f0 > 0:
 vval = vval + lnsch.paid.
end.
svopnamt = string(vval, "z,zzz,zzz,zzz,zz9.99-").
vval = 0.
find first lnsch where lnsch.lnn = s-lon and lnsch.flp = -1 
                                         and lnsch.fpn = 0 no-error.
if available lnsch then vval = vval + lnsch.paid.
sval = string(vval, "z,zzz,zzz,zzz,zz9.99-").

view frame msgp3.

{mainhead.i}

upper:
repeat:

{jjbr.i
&head = "lnsch"
&headkey = "schn"
&where = "lnsch.lnn = s-lon and lnsch.flp > -1 and lnsch.fpn = 0 
          and lnsch.f0 > -1"
&index = "lnn"
&formname = "lonstl-p3"
&framename = "lonstl-p3"
&addcon = "false"
&start = " "
&display = "lnsch.mark lnsch.schn lnsch.stdat lnsch.stval lnsch.paid lnsch.jh"
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
             {lonstl-p3.i}
            end."
&end = "hide frame msgp3. leave upper."
}
end. /* upper */
/*--------------------------------------------------------------------
  #3.
     1.izmai‡a - mainЁts form–ts rind–m > 100
---------------------------------------------------------------------*/
