/* corfre.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Free Format Correspondence 799
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
        BANK  COMM
 * CHANGES

*/

{LC.i "new"}
{mainhead.i CORR}

def new shared var v-find     as logi.
def new shared var v-lcsts    as char.
def new shared var s-lcprod   as char.
def new shared var v-lcerrdes as char.
def new shared var s-corsts   like lcswt.sts.
def new shared var s-lccor    like lcswt.lccor.
def new shared var s-ftitle   as char init ' FREE FORMAT CORRESPONDENCE (MT 799) '.
def new shared var s-namef    as char.
def new shared var s-mt       as inte.
def new shared var s-lctype   as char.
def new shared var s-str      as char.
def var v-chose  as logi no-undo.
def var v-chose1 as logi no-undo.
def var v-lang   as char no-undo.
def var v-per    as int  no-undo.
def var v-lim    as deci no-undo.
def var v-numlim as int  no-undo.

find first txb where txb.bank = s-ourbank no-lock no-error.
if avail txb then s-namef =  caps(txb.name).
s-lcprod = 'corr'.
s-mt = 799.
s-lctype = 'I'.
s-str = '944'.

{mainlc.i
 &option     = "COR"
 &head       = "LC"
 &headkey    = "LC"
 &framename  = "frlc"
 &formname   = "COR"
 &lang       = " v-lang = g-lang. g-lang = 'US'. "
 &start      = "on 'end-error' of frame frlc do: g-lang = v-lang. end."
 &langend    = "  "
 &findcon    = "true"
 &addcon     = "true"
 &cond       = " "
 &start      = " "
 &clearframe = " "
 &viewframe  = " "
 &preadd     = " display s-namef with frame frlc.
                 do on error undo,return:
                    message 'Do you want to create a new Correspondence?' VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE ' ATTENTION !'
                    update v-chose.
                 end. "
 &presubprg  = " if v-chose then "
 &postadd    = " assign LC.LCsts  = 'NEW'
                     LC.bank   = s-ourbank
                     LC.LCtype = s-lctype
                     LC.rwho   = g-ofc
                     LC.rwhn   = g-today.
                 find current LC no-lock no-error.
                 v-lcsts = LC.LCsts.
                 display v-lcsts with frame frlc. "
 &prefind    = " assign v-find     = yes
                        v-lcsts    = ''
                        v-lcerrdes = ''
                        s-lc       = 'CORR'.
                  display s-namef with frame frlc.
                  repeat on endkey undo, return:
                      update s-LC with frame frlc.
                      s-lc = caps(s-lc).
                      find first LC where LC.LC = s-lc and lc.bank = s-ourbank and lc.lc begins s-lcprod and lc.lctype = 'E' no-lock no-error.
                      if not avail LC then run lchelp6.
                      find first LC where LC.LC = s-lc no-lock no-error.
                      if avail LC then do:
                          v-lcsts  = LC.LCsts.
                          display s-lc v-lcsts with frame frlc.
                          v-chose = yes.
                          leave.
                      end.
                  end. "
&postfind    = " if avail LC then v-lcsts = LC.LCsts.
                 if v-lcsts = 'Err' then do:
                     find first lch where lch.lc = s-lc and lch.kritcode = 'Errdes' no-lock no-error.
                     if avail lch then v-lcerrdes = lch.value1.
                 end.
                 display v-lcsts v-lcerrdes with frame frlc. "

 &numprg = "imlccre"
 &subprg = "coredt"
 &end = " g-lang = v-lang. "
}