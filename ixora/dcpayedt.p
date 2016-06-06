/* dcpayedt.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        IDC, ODC: редактирование платежа по документарному инкассо
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        13/02/2012 id00810
 * BASES
        BANK COMM
 * CHANGES
*/

{mainhead.i}
{LC.i}
def shared var v-cif      as char.
def shared var v-cifname  as char.
def shared var v-lcsts    as char.
def shared var v-lcerrdes as char.
def shared var v-find     as logi.
def shared var s-lc       like lc.lc.
def shared var s-paysts   like lcpay.sts.
def shared var v-lcsumorg as deci.
def shared var v-lcsumcur as deci.
def shared var v-lccrc1   as char.
def shared var v-lccrc2   as char.
def shared var v-lcdtexp  as date.
def shared var s-lcprod   as char.
def shared var s-namef    as char.

g-lang = 'RR'.
{LCsub.i
&option     = "dcpay"
&start      = "on 'end-error' of frame frpay do: g-lang = 'US'. end."
&head       = "lcpay"
&headkey    = "lcpay"
&framename  = "frpay"
&formname   = " dcpay"
&where      = " lcpay.lc = s-lc and "
&updatecon  = "false"
&deletecon  = "false"
&predelete  = " "
&display    = " display s-namef v-cif v-cifname s-lc v-lcsumorg v-lccrc1 v-lcsumcur v-lccrc2 v-lcdtexp v-lcsts s-lcpay s-paysts v-lcerrdes with frame frpay. pause 0."
&preupdate  = " "
&postupdate = " "
&prerun     = " "
&postrun    = " "
&end        = "g-lang = 'US'."
&mykey      = " "
&myproc     = " "
}
