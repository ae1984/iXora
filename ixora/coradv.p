/* coradv.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Авизосание гарантии для 3-го банка
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
{mainhead.i GTEADV}

def new shared var v-cif      as char.
def new shared var v-cifname  as char.
def new shared var v-lcsts    as char.
def new shared var v-lcerrdes as char.
def new shared var v-lcsumcur as deci.
def new shared var v-lcsumorg as deci.
def new shared var v-lccrc1   as char.
def new shared var v-lccrc2   as char.
def new shared var v-lcdtexp  as date.
def new shared var s-lcprod   as char.
def new shared var s-lctype   as char.
def new shared var v-find     as logi.
def new shared var s-lccor    like lcswt.lccor.
def new shared var s-ftitle   as char init ' ADVISE GUARANTEE TO 3-rd BANK '.
def new shared var s-namef    as char.
def new shared var s-fmt      as char init '760'.
def new shared var s-str      as char.
def new shared var s-mt       as inte.

def var v-chose  as logi no-undo.
def var v-chose1 as logi no-undo.
def var v-chose2 as logi no-undo.
def var v-lang   as char no-undo.
def var i        as int  no-undo.
def var v-sel    as int  no-undo.

def new shared temp-table t-mt760 no-undo
    field fname  as char
    field fvalue as char extent 150.

find first txb where txb.bank = s-ourbank no-lock no-error.
if avail txb then s-namef =  caps(txb.name).
s-lctype = 'E'.
s-lcprod = 'GTEADV'.
s-str = '944,955'.
s-mt = 799.

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
                    message 'Do you want to advise a new Guarantee to 3d Bank?' VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE ' ATTENTION! '
                    update v-chose.
                    if v-chose then do:
                        if s-ourbank <> 'TXB00' then do:
                            message 'New Guarantee to 3d Bank can be advised only in Central Office!' view-as alert-box error.
                            v-chose = no.
                        end.
                        else do:
                            find first LCswt where LCswt.lc = '' and LCswt.mt = 'O760' and LCswt.sts = 'new' no-lock no-error.
                            if avail lcswt then do:
                                run sel2 (' You have new MT760: ' + LCswt.ref + ' ', ' 1. Accept | 2. Forward | 3. Reject | Exit ', output v-sel).
                                case v-sel:
                                    when 1 then undo.
                                    when 2 then run i-mt760.
                                    when 3 then do:
                                        find current lcswt exclusive-lock no-error.
                                        lcswt.sts = 'Err'.
                                        return.
                                    end.
                                    when 4 then leave.
                                end.
                            end.
                            else do:
                                message 'You have no any new MT760! Do you want to advise a new Export Guarantee without MT??' view-as alert-box question buttons yes-no title ' ATTENTION! '
                                update v-chose2.
                                if not v-chose2 then v-chose = no.
                            end.
                        end.
                    end.
                end. "
 &presubprg = "if v-chose then "
 &postadd   = " assign LC.LCsts  = 'NEW'
                       LC.bank   = s-ourbank
                       LC.LCtype = 'E'
                       LC.rwho   = g-ofc
                       LC.rwhn   = g-today.
                find current LC no-lock.
                v-lcsts = LC.LCsts.
                for each t-mt760 no-lock:
                    create lch.
                    assign lch.lc       = lc.lc
                           lch.kritcode = t-mt760.fname.
                    i = 1.
                    do while t-mt760.fvalue[i] ne ''.
                        lch.value1   = lch.value1 + t-mt760.fvalue[i] + ' ' + chr(1).
                        i = i + 1.
                    end.
                    lch.value1 = substr(lch.value1,1,length(lch.value1) - 2).
                end.
                find first lch where lch.lc = lc.lc and lch.kritcode = 'fname2' no-lock no-error.
                if avail lch then do:
                    find first LCswt where LCswt.lc = '' and LCswt.mt = 'O760' and LCswt.sts = 'new' and LCswt.fname2 = lch.value1 exclusive-lock no-error.
                    if avail LCswt then do:
                        assign lcswt.lc     = lc.lc
                               lcswt.lctype = 'E'
                               lcswt.sts    = 'NEW'
                               lcswt.dt     = g-today.
                        find current LCswt no-lock no-error.
                    end.
                end.
                display v-lcsts with frame frlc.
                "
 &prefind = " assign v-find    = yes
                     v-cif     = ''
                     v-cifname = ''
                     v-lcsts   = ''
                     s-lc      = 'GTEADV'.
              display s-namef with frame frlc.
              repeat on endkey undo, return:
                update s-LC with frame frlc.
                s-lc = caps(s-lc).
                find first LC where LC.LC = s-lc and lc.bank = s-ourbank and lc.lc begins s-lcprod and lc.lctype = s-lctype no-lock no-error.
                if not avail LC or not LC.LC begins s-lcprod then run lchelp6.
                find first LC where LC.LC = s-lc no-lock no-error.
                if avail LC then do:
                    assign v-lcsts = LC.LCsts.
                    display s-lc v-lcsts with frame frlc.
                    v-chose = yes.
                    leave.
                end.
              end. "
 &postfind = " if avail LC then v-lcsts = LC.LCsts.
               if v-lcsts = 'Err' then do:
                   find first lch where lch.lc = s-lc and lch.kritcode = 'Errdes' no-lock no-error.
                   if avail lch then v-lcerrdes = lch.value1.
               end.
               display v-lcsts v-lcerrdes with frame frlc."
 &numprg = "gtecre"
 &subprg = "coredt1"
 &end = " g-lang = v-lang. "
}
