/* lcadv.p
 * MODULE
        EXLC, EXPG -  редактирование изменений
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
        06/05/2011 id00810
 * BASES
        BANK COMM
 * CHANGES
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
def shared var s-amdsts   like lcamend.sts.

def shared var v-lcsumorg as deci.
def shared var v-lcsumcur as deci.
def shared var v-lccrc1   as char.
def shared var v-lccrc2   as char.
def shared var v-lcdtexp  as date.
def shared var s-lcprod   as char.
def shared var s-namef    as char.

g-lang = 'RR'.
{LCsub.i
&option     = "lcadvamd"
&start      = "on 'end-error' of frame framd do: g-lang = 'US'. end."
&head       = "LCamend"
&headkey    = "LCamend"
&framename  = "framd"
&formname   = " LCamd"
&where      = " lcamend.lc = s-lc and "
&updatecon  = "false"
&deletecon  = "false"
&predelete  = " "
&display    = " display s-namef v-cif v-cifname s-lc v-lcsumorg v-lccrc1 v-lcsumcur v-lccrc2 v-lcdtexp v-lcsts s-lcamend s-amdsts v-lcerrdes  with frame framd. pause 0."
&preupdate  = " "
&postupdate = " "
&prerun     = " "
&postrun    = " "
&end        = "g-lang = 'US'."
&mykey      = " "
&myproc     = " "
}
