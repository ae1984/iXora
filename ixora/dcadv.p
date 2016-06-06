/* dcadv.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Документарное инкассо
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
        28/12/2011 id00810
 * BASES
        BANK  COMM
 * CHANGES
        08/02/2012 id00810 - для ODC
        06.03.2012 Lyubov  - "dc" изменила на "idc"
*/

def new shared var v-cif      as char.
def new shared var v-cifname  as char.
def new shared var v-lcsts    as char.
def new shared var v-lcerrdes as char.
def new shared var v-find     as logi.
def new shared var v-lcsumcur as deci.
def new shared var v-lcsumorg as deci.
def new shared var v-lccrc1   as char.
def new shared var v-lccrc2   as char.
def new shared var v-lcdtexp  as date.
def new shared var s-lccor    like lcswt.lccor.
def new shared var s-corsts   like lcswt.sts.
def new shared var s-ftitle   as char init ' Inward Documentary Collection '.
def new shared var s-namef    as char.
def new shared var s-fmt      as char.
def     shared var s-lcprod   as char.
def var v-chose  as logi no-undo.
def var v-chose1 as logi no-undo.
def var v-lang   as char no-undo.
def var v-text1  as char no-undo init ' advise'.
def var v-text2  as char no-undo init ' Inward'.

{LC.i "new"}
{mainheadlc.i &nm=s-lcprod }

find first txb where txb.bank = s-ourbank no-lock no-error.
if avail txb then s-namef =  caps(txb.name).
if s-lcprod = 'ODC' then assign s-ftitle = ' Outward Documentary Collection '
                                v-text1  = ' create'
                                v-text2  = ' Outward'.

{mainlc.i
 &option     = "dc"
 &head       = "LC"
 &headkey    = "LC"
 &framename  = "frlc"
 &formname   = "dc"
 &lang       = " v-lang = g-lang. g-lang = 'US'. "
 &start      = "on 'end-error' of frame frlc do: g-lang = v-lang. end."
 &langend    = "  "
 &findcon    = "true"
 &addcon     = "true"
 &cond       = " "
 &start      = " "
 &clearframe = " "
 &viewframe  = " "
 &preadd     = " assign v-cif = ''
                        v-find = no
                        v-lcsumcur = 0
                        v-lcsumorg = 0
                        v-lccrc1   = ''
                        v-lccrc2   = ''
                        v-lcdtexp  = ?.
                display s-namef with frame frlc.
                do on error undo,return:
                    update  v-cif with frame frlc.
                    find cif where cif.cif = v-cif no-lock no-error.
                    if avail cif then v-cifname = trim(trim(cif.prefix) + ' ' + trim(cif.name)).
                    display v-cifname with frame frlc.
                    message 'Do you want to' + v-text1 + ' a new' + v-text2 + ' Documentary Collection?' VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE ' ATTENTION !'
                    update v-chose.
                end. "
 &presubprg  = "if v-chose then "
 &postadd    = " assign LC.cif    = v-cif
                        LC.LCsts  = 'NEW'
                        LC.bank   = s-ourbank
                        LC.LCtype = if s-lcprod = 'idc' then 'E' else 'I'
                        LC.rwho   = g-ofc
                        LC.rwhn   = g-today.
               find current LC no-lock no-error.
               v-lcsts = LC.LCsts.
               display v-lcsts with frame frlc.
               "
 &prefind    = " assign v-find     = yes
                        v-cif      = ''
                        v-cifname  = ''
                        v-lcsts    = ''
                        v-lcerrdes = ''
                        s-lc       = ''.
               display s-namef with frame frlc.
               update v-cif with frame frlc.
               find cif where cif.cif = v-cif no-lock no-error.
               if avail cif then v-cifname = trim(trim(cif.prefix) + ' ' + trim(cif.name)).
               display v-cifname with frame frlc.

               repeat on endkey undo, return:
                update s-LC with frame frlc.
                s-lc = caps(s-lc).
                find first LC where LC.LC = s-lc and lc.bank = s-ourbank and lc.lc begins s-lcprod no-lock no-error.
                if not avail LC then run LChelp.
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
               find first LC where LC.LC = s-lc no-lock no-error.
               assign v-lcsumcur = 0 v-lcsumorg = 0.
               find first lch where lch.lc = s-lc and lch.kritcode = 'Amount' no-lock no-error.
               if avail lch and trim(lch.value1) <> '' then do:
                v-lcsumorg = deci(lch.value1).
                v-lcsumcur = deci(lch.value1).
               end.
               display v-lcsumorg v-lcsumcur with frame frlc.
               v-lccrc1 = ''.
               find first lch where lch.lc = s-lc and lch.kritcode = 'lcCrc' no-lock no-error.
               if avail lch and trim(lch.value1) <> '' then do:
                find first crc where crc.crc = int(lch.value1) no-lock no-error.
                if avail crc then assign v-lccrc1 = crc.code v-lccrc2 = crc.code.
               end.
               display v-lccrc1 v-lccrc2 with frame frlc.

               find first lch where lch.lc = s-lc and lch.kritcode = 'DtExp' no-lock no-error.
               if avail lch and lch.value1 <> ? then do:
                 v-lcdtexp = date(lch.value1).
                 find last lcamendh where lcamendh.lc = s-lc and lcamendh.kritcode = 'NewDtEx' and lcamendh.value1 ne '' no-lock no-error.
                 if avail lcamendh then v-lcdtexp = date(lcamendh.value1).
                 display v-lcdtexp with frame frlc.
               end.
               "
 &postfind = " if avail LC then v-lcsts = LC.LCsts.
               if v-lcsts = 'Err' then do:
                   find first lch where lch.lc = s-lc and lch.kritcode = 'Errdes' no-lock no-error.
                   if avail lch then v-lcerrdes = lch.value1.
               end.
               display v-lcsts v-lcerrdes with frame frlc."
 &numprg   = "imlccre"
 &subprg   = "dcedt"
 &end      = " g-lang = v-lang. "
}