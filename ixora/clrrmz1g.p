/* clrrmz1g.p
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
*/

def input parameter vbank as char format "x(3)".
def input parameter vdat as date.
def input parameter vnumur like clrdoc.pr. 
def var bankhead as char format "x(30)".
def shared var s-datt as date.
def shared var s-num like clrdoc.pr.
def new shared var s-remtrz like remtrz.remtrz. 
def shared var vvsum as deci.
def shared var nnsum as int.
find bank where bank.bank = vbank no-lock no-error.
if available bank then bankhead = bank.name.
def shared temp-table ree
    field npk as inte format "zz9"
    field bank as char format "x(9)"
    field bbic like bankl.bic
    field quo as inte format "zzzzz9"
    field kopa as deci format "zzz,zzz,zzz,zzz.99".
{global.i}
{lgps.i}
{clrdoc.f}
{jabra.i
&start = " "
&head = "clrdog"
&headkey = "rem"
&where = "clrdog.rdt = vdat and clrdog.bank = vbank and clrdog.pr = vnumur "
&index = "dtba"
&formname = "clrdog1"
&framename = "clrdog1"
&frameparm = "new" 
&addcon = "false"
&deletecon = "true"
&prechoose = "
message 
'F10-удалить;2-печать плат.поруч.;3-печать отчета;4-истормя;F4-выход'. "
&predelete = "/* if can-find(remtrz where remtrz.remtrz = clrdoc.rem)
                 then do: 
                 bell.
                 next inner.
              end.*/ "
&predisplay = " "
&display = "clrdog.rem clrdog.tacc clrdog.amt"
&highlight = "clrdog.rem clrdog.tacc clrdog.amt"
&postcreate = " "
&prevdelete = " find first que where que.remtrz = clrdog.rem exclusive-lock .
         que.pid = '31'. /* orig: LB by Alex */
         que.con = 'W' .
         v-text = que.remtrz + 
         ' was deleted from clrdog and returned -> 31 '.
         run lgps.              
"
&postdisplay = " "
&postadd = "clrdog.rdt = vdat.
            clrdog.bank = vbank.
            clrdog.pr = vnumur.
            update clrdog.rem clrdog.tacc clrdog.amt with frame clrdog1."
&postkey = "else if keyfunction(lastkey) = '2' then do:
                 run clrprn2(vbank).
            end.
            else if keyfunction(lastkey) = '4' then do:
             s-remtrz = clrdog.rem .
             run rmzhis.
             view frame clrdoc.
             pause 0 .
             view frame clrdog1.
            end.
            else if keyfunction(lastkey) = '3' then do:
                 run aurmz( vdat, vbank, vnumur).
            end."

&end = "hide frame clrdog1.
        release clrdog."
}
