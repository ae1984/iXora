/* LCin799.p
 * MODULE
        Корреспонденция - входящий свифт
 * DESCRIPTION
        Описание
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
        10/01/2011 Vera
 * BASES
        BANK COMM
 * CHANGES
        23/02/2011 id00810 - для всех продуктов
        13/05/2011 id00810 - перекомпиляция (изменение в LCsub.i)
        28/06/2011 id00810 - переставила v-lcerrdes
        17/01/2012 id00810 - добавлена переменная - наименование филиала
        07/05/2012 Lyubov - перекомпиляция (изменение в LCsub.i)
*/

{mainhead.i}
{LC.i}

def shared var v-cif      as char.
def shared var v-cifname  as char.
def shared var v-lcsts    as char.
def shared var v-lcerrdes as char.
def shared var v-find     as logi.
def shared var s-lc       like lc.lc.
def shared var s-corsts   like lcswt.sts.

def shared var v-lcsumorg as deci.
def shared var v-lcsumcur as deci.
def shared var v-lccrc1   as char.
def shared var v-lccrc2   as char.
def shared var v-lcdtexp  as date.
def shared var s-lcprod   as char.
def shared var s-namef    as char.

g-lang = 'RR'.

{LCsub.i
&option     = "lcin799"
&start      = "on 'end-error' of frame frcor do: g-lang = 'US'. end."
&head       = "LCswt"
&headkey    = "LCcor"
&framename  = "frcor"
&formname   = " lccor"
&where      = " LCswt.lc = s-lc and LCswt.mt = 'O799' and"
&updatecon  = "false"
&deletecon  = "false"
&predelete  = " "
&display    = " display s-namef v-cif v-cifname s-lc v-lcsumorg v-lccrc1 v-lcsumcur v-lccrc2 v-lcdtexp v-lcsts s-lccor s-corsts v-lcerrdes with frame frcor. pause 0."
&preupdate  = " "
&postupdate = " "
&prerun     = " "
&postrun    = " "
&end        = "g-lang = 'US'."
&mykey      = " "
&myproc     = " "
}
