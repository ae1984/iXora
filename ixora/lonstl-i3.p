/* lonstl-i3.p
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
def shared var marked like lnsci.paid-iv.
def output parameter flag as inte.

vval = 0.
for each lnsci where lnsci.lni = s-lon and lnsci.flp = 0 and lnsci.fpn = 0:
 vval = vval + lnsci.paid-iv.
end.
svopnamt = string(vval, "z,zzz,zzz,zzz,zz9.99-").
vval = 0.
find first lnsci where lnsci.lni = s-lon and lnsci.flp = -1 
                                         and lnsci.fpn = 0 no-error.
if available lnsci then vval = vval + lnsci.paid-iv.
sval = string(vval, "z,zzz,zzz,zzz,zz9.99-").

view frame msgi3.
pause 0.

{mainhead.i}

upper:
repeat:

{jjbr.i
&start = "if marked > 0 then disp marked with frame marked."
&head = "lnsci"
&headkey = "schn"
&where = "lnsci.lni = s-lon and lnsci.flp > -1 and lnsci.fpn = 0"

&index = "lni"
&formname = "lonstl-i3"
&framename = "lonstl-i3"
&addcon = "false"
&start = " "
&display = "lnsci.mark lnsci.schn lnsci.idat lnsci.iv lnsci.paid-iv lnsci.jh"
&postdisplay = " "
&postadd = " "
&postkey = "else if lastkey = 510 then do:
             if lnsci.flp > 0 then do: bell. next inner. end.
             if lnsci.paid-iv = 0 then do: bell. next inner. end.
             if lnsci.mark = """" then do:
                /*lnsci.mark = "">"".*/
                marked = marked + lnsci.paid-iv.
             end.
             else if lnsci.mark = "">"" then do:
                /*lnsci.mark = """".*/
                marked = marked - lnsci.paid-iv.
             end.
                disp lnsci.mark with frame lonstl-i3.
                if marked = 0 then hide frame marked.
                else if marked > 0 then disp marked with frame marked.
            end.
            else if lastkey = 401 then do:
                flag = 0. leave outer.
            end.       
            else if lastkey = 49 then do:
             flag = 1.
             hide frame msgi3.
             return.
            end.
            else if lastkey = 50 then do:
             flag = 2.
             hide frame msgi3.
             return.
            end.
            else if lastkey = 13 then do:
              {lonstl-i3.i}
              else if lnsci.paid-iv = 0 then do:
                bell. next inner.
              end.
              else do:
                marked = lnsci.paid-iv. flag = 0. leave outer.
              end.
            end."
&end = "hide frame msgi3. hide frame marked. leave upper."
}
end. /* upper */

