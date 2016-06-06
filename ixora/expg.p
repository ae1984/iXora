/* expg.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Экспортная гарантия
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
        13/12/2010 id00810
 * BASES
        BANK  COMM
 * CHANGES
        19/07/2011 id00810 - изменение в заголовке формы (s-ftitle)
        17/01/2012 id00810 - добавлены переменные: наименование филиала, формат сообщения
*/

{LC.i "new"}
{mainhead.i EXPG}

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
def new shared var v-find     as logi.
def new shared var s-ftitle   as char init ' LETTER OF GUARANTEE '.
def new shared var s-namef    as char.
def new shared var s-fmt      as char init '760'.

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
s-lcprod = 'expg'.

{mainlc.i
 &option     = "expg"
 &head       = "LC"
 &headkey    = "LC"
 &framename  = "frlc"
 &formname   = "LC"
 &lang       = " v-lang = g-lang. g-lang = 'US'. "
 &start      = "on 'end-error' of frame frlc do: g-lang = v-lang. end."
 &langend    = "  "
 &findcon    = "true"
 &addcon     = "true"
 &cond       = " "
 &start      = " "
 &clearframe = " "
 &viewframe  = " "
 &preadd     = " assign v-cif      = ''
                        v-find     = no
                        v-lcsumcur = 0
                        v-lcsumorg = 0
                        v-lccrc1   = ''
                        v-lccrc2   = ''
                        v-lcdtexp  = ?
                        v-chose    = no
                        v-chose1   = no.
                display s-namef with frame frlc.
                do on error undo,return:
                    message 'Do you want to advise a new Export Guarantee?' VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE ' ATTENTION! '
                    update v-chose.
                    if v-chose then do:
                        if s-ourbank <> 'TXB00' then do:
                            message 'New Export Guarantee can be advised only in Central Office!' view-as alert-box error.
                            v-chose = no.
                        end.
                        else do:
                            find first LCswt where LCswt.lc = '' and LCswt.mt = 'O760' and LCswt.sts = 'new' no-lock no-error.
                            if avail LCswt then do:
                                run sel2 (' You have new MT760: ' + LCswt.ref + ' ', ' 1. Accept | 2. Forward | 3. Reject | Exit ', output v-sel).
                                case v-sel:
                                    when 1 then run i-mt760.
                                    when 2 then undo.
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
 &postadd   = " assign LC.cif    = v-cif
                       LC.LCsts  = 'NEW'
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
                               lcswt.lctype = lc.lctype
                               lcswt.sts    = 'FIN'
                               lcswt.dt     = g-today.
                        find current LCswt no-lock no-error.
                    end.
                end.
                display v-lcsts s-fmt with frame frlc.
                "
 &prefind = " assign v-find    = yes
                     v-cif     = ''
                     v-cifname = ''
                     v-lcsts   = ''
                     s-lc      = 'EXPG'.
              display s-namef with frame frlc.
              update v-cif with frame frlc.
              find cif where cif.cif = v-cif no-lock no-error.
              if avail cif then v-cifname = trim(trim(cif.prefix) + ' ' + trim(cif.name)).
              display v-cifname with frame frlc.
              repeat on endkey undo, return:
                update s-LC with frame frlc.
                s-lc = caps(s-lc).
                find first LC where LC.LC = s-lc and lc.bank = s-ourbank and lc.lc begins s-lcprod no-lock no-error.
                if not avail LC or not LC.LC begins s-lcprod then run LChelp.
                find first LC where LC.LC = s-lc no-lock no-error.
                if avail LC then do:
                    assign v-cif   = LC.cif
                           v-lcsts = LC.LCsts.
                    find cif where cif.cif = LC.cif no-lock no-error.
                    if avail cif then v-cifname = trim(trim(cif.prefix) + ' ' + trim(cif.name)).
                    display s-lc v-cifname v-cif v-lcsts with frame frlc.
                    v-chose = yes.
                    leave.
                end.
              end.
              find first LC where LC.LC = s-lc and LC.cif = v-cif no-lock no-error.
              v-lcsumcur = 0.
              v-lcsumorg = 0.
              find first lch where lch.lc = s-lc and lch.kritcode = 'Amount' no-lock no-error.
              if avail lch and trim(lch.value1) <> '' then do:
                 v-lcsumcur = deci(lch.value1).
                 v-lcsumorg = deci(lch.value1).
              end.
              display v-lcsumcur v-lcsumorg with frame frlc.
              v-lccrc1 = ''.
              find first lch where lch.lc = s-lc and lch.kritcode = 'lcCrc' no-lock no-error.
              if avail lch and trim(lch.value1) <> '' then do:
                find first crc where crc.crc = int(trim(lch.value1)) no-lock no-error.
                if avail crc then assign v-lccrc1 = crc.code v-lccrc2 = crc.code.
              end.
              display v-lccrc1 v-lccrc2 with frame frlc.
              find first lch where lch.lc = s-lc and lch.kritcode = 'DtExp' no-lock no-error.
              if avail lch and lch.value1 <> ? then do:
                 v-lcdtexp = date(lch.value1).
                 display v-lcdtexp with frame frlc.
              end."
 &postfind = " if avail LC then v-lcsts = LC.LCsts.
               if v-lcsts = 'Err' then do:
                   find first lch where lch.lc = s-lc and lch.kritcode = 'Errdes' no-lock no-error.
                   if avail lch then v-lcerrdes = lch.value1.
               end.
               display v-lcsts s-fmt v-lcerrdes with frame frlc."
 &numprg = "imlccre"
 &subprg = "expgedt"
 &end = " g-lang = v-lang. "
}
