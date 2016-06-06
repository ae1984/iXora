/* lonstl-i2.p
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
find first lnsci where lnsci.lni = s-lon and lnsci.flp = -1 
                                         and lnsci.fpn = 0 no-error.
if available lnsci then vall = lnsci.paid-iv.
svopnamt = string(vall, "z,zzz,zzz,zzz,zz9.99-").

view frame msgi2.
pause 0.

{mainhead.i}

upper:
repeat:

{jjbr.i
&head = "lnsci"
&headkey = "schn"
&where = "lnsci.lni = s-lon and lnsci.flp > 0 and lnsci.fpn = 0"
&index = "lni"
&formname = "lonstl-i2"
&framename = "lonstl-i2"
&addcon = "false"
&start = " "
&display = "lnsci.schn lnsci.idat lnsci.paid-iv lnsci.jh"
&postdisplay = " "
&postadd = " "
&postkey = "else if lastkey = 49 then do:
              flag = 1.
              hide frame msgi2.
              return.
            end.
            else if lastkey = 50 then do:
              flag = 3.
              hide frame msgi2.
              return.
            end.
            else if lastkey = 13 then do:
             {lonstl-i2.i}
            end."
&end = "hide frame msgi2. leave upper."
}
end. /* upper */

