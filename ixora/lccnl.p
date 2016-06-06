/* lccnl.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Cancel - редактирование
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
        15/04/2011 id00810
 * BASES
        BANK COMM
 * CHANGES
        13/05/2011 id00810 - перекомпиляция (изменение в LCsub.i)
        27/06/2011 id00810 - переставила v-lcerrdes
        17/01/2012 id00810 - добавлена переменная - наименование филиала
        07/05/2012 Lyubov - перекомпиляция (изменение в LCsub.i)
        10.07.2012 Lyubov - создала отдельную форму для события cancel
*/

{mainhead.i}
{LC.i}

def shared var v-cif      as char.
def shared var v-cifname  as char.
def shared var v-lcsts    as char.
def shared var v-lcerrdes as char.
def shared var v-find     as logi.
def shared var s-number   like lcevent.number.
def shared var s-sts      like lcevent.sts.

def shared var v-lcsum1  as deci.
def shared var v-lcsum2  as deci.
def shared var v-lcsum3  as deci.
def shared var v-lccrc1  as char.
def shared var v-lccrc2  as char.
def shared var v-lccrc3  as char.
def shared var v-lcdtexp as date.
def shared var s-ftitle  as char.
def shared var s-lcprod  as char.
def shared var s-namef   as char.
def shared var v-rcacc   as char.
def shared var v-rcaname as char.

g-lang = 'RR'.
{LCsub.i
&option     = "lccnl"
&start      = "on 'end-error' of frame frcnl do: g-lang = 'US'. end."
&head       = "lc"
&headkey    = "lc"
&framename  = "frcnl"
&formname   = "lccnl"
&where      = " "
&updatecon  = "false"
&deletecon  = "false"
&predelete  = " "
&display    = " display s-namef v-cif v-cifname s-lc v-lcsum1 v-lccrc1 v-lcsum2 v-lccrc2 v-lcdtexp v-lcsts s-sts v-lcerrdes with frame frcnl. pause 0."
&preupdate  = " "
&postupdate = " "
&prerun     = " "
&postrun    = " "
&end        = "g-lang = 'US'."
&mykey      = " "
&myproc     = " "
}