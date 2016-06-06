/* lclimedt.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Limits - редактирование
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        14-7-1-1
 * AUTHOR
        19/09/2011 id00810
 * BASES
        BANK COMM
 * CHANGES
        17/01/2012 id00810 - добавлена переменная - наименование филиала
        07/05/2012 Lyubov - перекомпиляция (изменение в LCsub.i)
*/

{mainhead.i}

def shared var s-number    as int.
def shared var v-cifname   as char.
def shared var v-limsts    as char.
def shared var v-limerrdes as char.
def shared var v-find      as logi.
def shared var v-limsumcur as deci.
def shared var v-limsumorg as deci.
def shared var v-limdtexp  as date.
def shared var v-limcrc1   as char.
def shared var v-limcrc2   as char.
def shared var s-ftitle    as char.
def shared var s-ourbank   as char no-undo.
def shared var s-namef     as char.

g-lang = 'RR'.
{LCsub.i
&option     = "lclimedt"
&start      = "on 'end-error' of frame frlclimit do: g-lang = 'US'. end."
&head       = "lclimit"
&headkey    = "cif"
&framename  = "frlclimit"
&formname   = "lclim"
&where      = " lclimit.number = s-number and "
&updatecon  = "false"
&deletecon  = "false"
&predelete  = " "
&display    = " display s-namef s-cif v-cifname v-limsumorg v-limcrc1 v-limsumcur v-limcrc2 v-limdtexp v-limsts v-limerrdes with frame frlclimit. pause 0."
&preupdate  = " "
&postupdate = " "
&prerun     = " "
&postrun    = " "
&end        = "g-lang = 'US'."
&mykey      = " "
&myproc     = " "
}