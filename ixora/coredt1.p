/* coredt.p
 * MODULE
        Trade Finance
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
        18.10.2012 Lyubov
 * BASES
        BANK COMM
 * CHANGES
        19.10.2012 Lyubov - перекомпиляция

*/


{mainhead.i}
{LC.i}

def shared var s-corsts   as char.
def shared var v-lcsts    as char.
def shared var v-lcerrdes as char.
def shared var v-find     as logi.
def shared var s-lcprod   as char.
def shared var s-ftitle   as char.
def shared var s-namef    as char.

g-lang = 'RR'.
{LCsub.i
&option = "CORADV"
&start = "on 'end-error' of frame frlc do: g-lang = 'US'. end."
&head = "LC"
&headkey = "LC"
&framename = "frlc"
&formname = "COR"
&where = " "
&updatecon = "false"
&deletecon = "false"
&predelete = " "
&display = " display s-namef s-lc v-lcsts v-lcerrdes with frame frlc. pause 0."
&preupdate = " "
&postupdate = " "
&prerun = " "
&postrun = " "
&end = "g-lang = 'US'."
&mykey = " "
&myproc = " "
}