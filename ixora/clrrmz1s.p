/* clrrmz1s.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        отправка ихходящих платежей СМЭП
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
        19/08/2013 galina ТЗ1871
 * BASES
        BANK
 * CHANGES
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
&head = "clrdos"
&headkey = "rem"
&where = "clrdos.rdt = vdat and clrdos.bank = vbank and clrdos.pr = vnumur "
&index = "dtba"
&formname = "clrdos1"
&framename = "clrdos1"
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
&display = "clrdos.rem clrdos.tacc clrdos.amt"
&highlight = "clrdos.rem clrdos.tacc clrdos.amt"
&postcreate = " "
&prevdelete = " find first que where que.remtrz = clrdos.rem exclusive-lock .
         que.pid = '31'. /* orig: LB by Alex */
         que.con = 'W' .
         v-text = que.remtrz +
         ' was deleted from clrdos and returned -> 31 '.
         run lgps.
"
&postdisplay = " "
&postadd = "clrdos.rdt = vdat.
            clrdos.bank = vbank.
            clrdos.pr = vnumur.
            update clrdos.rem clrdos.tacc clrdos.amt with frame clrdos1."
&postkey = "else if keyfunction(lastkey) = '2' then do:
                 run clrprn2(vbank).
            end.
            else if keyfunction(lastkey) = '4' then do:
             s-remtrz = clrdos.rem .
             run rmzhis.
             view frame clrdoc.
             pause 0 .
             view frame clrdos1.
            end.
            else if keyfunction(lastkey) = '3' then do:
                 run aurmz( vdat, vbank, vnumur).
            end."

&end = "hide frame clrdos1.
        release clrdos."
}
