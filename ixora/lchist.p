/* lchist.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        History - история "жизни" продукта
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        14-7-1-2
 * AUTHOR
        31/10/2011 id00810
 * BASES
        BANK  COMM
 * CHANGES
        17/01/2012 id00810 - добавлена переменная - наименование филиала
        12.03.2012 Lyubov  - в lchelp5 передается параметр '*'
 */

def new shared var v-cif      as   char.
def new shared var v-cifname  as   char.
def new shared var v-lcsts    as   char.
def new shared var v-lcerrdes as   char.
def new shared var v-find     as   logi.
def new shared var s-sts      like lc.lcsts.
def var v-chose  as logi no-undo.
def var v-lang   as char no-undo.
def var v-yes    as logi no-undo.
def var v-cov    as char no-undo.
def var v-per    as int  no-undo.

def new shared var v-lcsumorg as deci.
def new shared var v-lcsumcur as deci.
def new shared var v-lccrc1   as char.
def new shared var v-lccrc2   as char.
def new shared var v-lcdtexp  as date.
def new shared var s-ftitle   as char init ' HISTORY '.
def new shared var s-lcprod   as char.
def new shared var s-namef    as char.

{LC.i "new"}
{mainheadlc.i &nm=s-lcprod }

find first txb where txb.bank = s-ourbank no-lock no-error.
if avail txb then s-namef =  caps(txb.name).

{mainlc.i
 &option     = "imlc"
 &head       = "LC"
 &headkey    = "LC"
 &framename  = "frlc"
 &formname   = "lchist"
 &lang       = " v-lang = g-lang. g-lang = 'US'. "
 &start      = "on 'end-error' of frame frlc do: g-lang = v-lang. end."
 &langend    = "  "
 &findcon    = "true"
 &addcon     = "false"
 &cond       = " "
 &start      = " "
 &clearframe = " "
 &viewframe  = " "
 &preadd     = " "
 &presubprg  = "if v-chose then "
 &postadd    = " "
 &prefind    = " assign v-find    = yes
                        v-cif     = ''
                        v-cifname = ''
                        v-lcsts   = ''
                        s-lc      = ''
                        s-lcprod  = ''.
              display s-namef with frame frlc.
              update v-cif with frame frlc.
              find cif where cif.cif = v-cif no-lock no-error.
              if avail cif then v-cifname = trim(trim(cif.prefix) + ' ' + trim(cif.name)).
              display v-cifname with frame frlc.
              repeat on endkey undo, return:
                  update s-LC with frame frlc.
                  s-lc = caps(s-lc).
                  find first LC where LC.LC = s-lc and LC.bank = s-ourbank and lookup(lc.lcsts,'FIN,CLS,CNL') > 0 no-lock no-error.
                  if not avail LC then run lchelp5('FIN,CLS,CLN','*').
                  find first LC where LC.LC = s-lc no-lock no-error.
                  if avail LC then do:
                       v-cif = LC.cif.
                       v-lcsts = LC.LCsts.
                       find cif where cif.cif = LC.cif no-lock no-error.
                       if avail cif then v-cifname = trim(trim(cif.prefix) + ' ' + trim(cif.name)).
                       display s-lc v-cifname v-cif v-lcsts with frame frlc.
                       leave.
                  end.
              end.
              if s-lc begins 'pg' then s-lcprod = 'pg'.
              else if s-lc begins 'exsblc' then s-lcprod = 'exsblc'.
              else  s-lcprod = substr(s-lc,1,4).
              assign v-lcsumcur = 0
                     v-lcsumorg = 0.
              find first lch where lch.lc = s-lc and lch.kritcode = 'Amount' no-lock no-error.
              if avail lch and trim(lch.value1) <> '' then do:
                 v-lcsumorg = deci(lch.value1).
                 v-lcsumcur = deci(lch.value1).
                 find first lch where lch.lc = lc.lc and lch.kritcode = 'peramt' no-lock no-error.
                 if avail lch and lch.value1 ne '' then do:
                    v-per = int(entry(1,lch.value1, '/')).
                    if v-per > 0 then assign v-lcsumorg = v-lcsumorg + (v-lcsumorg * (v-per / 100))
                                             v-lcsumcur = v-lcsumorg.
                 end.
                 if s-lcprod <> 'pg' then
                 for each lcamendres where lcamendres.lc = s-lc and (lcamendres.levC = 23 or lcamendres.levD = 23 or lcamendres.levC = 24 or lcamendres.levD = 24) and lcamendres.jh > 0 no-lock:
                     find first jh where jh.jh = lcamendres.jh no-lock no-error.
                     if not avail jh then next.
                     if lcamendres.levD = 23 or lcamendres.levD = 24 then v-lcsumcur = v-lcsumcur + lcamendres.amt.
                     if lcamendres.levC = 23 or lcamendres.levC = 24 then v-lcsumcur = v-lcsumcur - lcamendres.amt.
                 end.
                 else
                 for each lcamendres where lcamendres.lc = lc.lc and (lcamendres.dacc = '605561' or  lcamendres.dacc = '655561' or lcamendres.dacc = '605562' or  lcamendres.dacc = '655562') and lcamendres.jh > 0 no-lock:
                    find first jh where jh.jh = lcamendres.jh no-lock no-error.
                    if not avail jh then next.
                    if lcamendres.dacc = '605561' or lcamendres.dacc = '605562' then v-lcsumcur = v-lcsumcur  + lcamendres.amt.
                    else v-lcsumcur = v-lcsumcur  - lcamendres.amt.
                 end.
                 /*учитываем суммы payment */
                 for each lcpayres where lcpayres.lc = s-lc and (lcpayres.levC = 23 or lcpayres.levC = 24 or lcpayres.dacc = '655561' or lcpayres.dacc = '655562') and lcpayres.jh > 0 no-lock:
                     find first jh where jh.jh = lcpayres.jh no-lock no-error.
                     if avail jh then v-lcsumcur = v-lcsumcur - lcpayres.amt.
                 end.
                 /*учитываем суммы event */
                 for each lceventres where lceventres.lc = s-lc and (lceventres.levC = 23 or lceventres.levC = 24 or lceventres.dacc = '655561' or lceventres.dacc = '655562') and lceventres.jh > 0 no-lock:
                     find first jh where jh.jh = lceventres.jh no-lock no-error.
                     if avail jh then v-lcsumcur = v-lcsumcur - lceventres.amt.
                 end.
              end.
              display v-lcsumorg v-lcsumcur with frame frlc.
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
                 find last lcamendh where lcamendh.bank = lc.bank and lcamendh.lc = s-lc and lcamendh.kritcode = 'NewDtEx' and lcamendh.value1 ne '' no-lock no-error.
                 if avail lcamendh then v-lcdtexp = date(lcamendh.value1).
                 display v-lcdtexp with frame frlc.
              end. "
 &postfind = " if avail LC then v-lcsts = LC.LCsts.
               display v-lcsts with frame frlc.
               v-chose = yes.
               if s-sts = 'Err' then do:
                find first lch where lch.bank = s-ourbank and lch.lc = s-lc and lch.kritcode = 'Errdes' no-lock no-error.
                if avail lch then v-lcerrdes = lch.value1.
                display v-lcerrdes with frame frlc.
               end. "
 &numprg = "xxx"
 &subprg = "lchistedt"
 &end = " g-lang = v-lang. "
}
