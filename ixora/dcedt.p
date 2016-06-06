/* dcedt.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        редактирование документарного инкассо
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        14-8-1
 * AUTHOR
        29/12/2011 id00810
 * BASES
        BANK COMM
 * CHANGES
        07/05/2012 Lyubov - перекомпиляция (изменение в LCsub.i)
*/


{mainhead.i}
{LC.i}

def shared var v-cif      as char.
def shared var v-cifname  as char.
def shared var v-lcsts    as char.
def shared var v-lcerrdes as char.
def shared var v-find     as logi.
def shared var v-lcsumcur as deci.
def shared var v-lcsumorg as deci.
def shared var v-lccrc1   as char.
def shared var v-lccrc2   as char.
def shared var v-lcdtexp  as date.
def shared var s-lcprod   as char.
def shared var s-ftitle   as char.
def shared var s-namef    as char.

g-lang = 'RR'.
{LCsub.i
&option     = "DCedt"
&start      = "on 'end-error' of frame frlc do: g-lang = 'US'. end."
&head       = "LC"
&headkey    = "LC"
&framename  = "frlc"
&formname   = "dc"
&where      = " "
&updatecon  = "false"
&deletecon  = "false"
&predelete  = " "
&display    = " display s-namef v-cif v-cifname s-lc v-lcsumorg v-lccrc1 v-lcsumcur v-lccrc2 v-lcdtexp v-lcsts v-lcerrdes with frame frlc. pause 0."
&preupdate  = " "
&postupdate = " "
&prerun     = " "
&postrun    = " "
&end        = "g-lang = 'US'."
&mykey      = " "
&myproc     = " "
}