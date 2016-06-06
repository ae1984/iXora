/* dcpay.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        DC, ODC - Payment
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
        13/02/2012 id00810
 * BASES
        BANK  COMM
 * CHANGES
*/

def new shared var v-cif      as char.
def new shared var v-cifname  as char.
def new shared var v-lcsts    as char.
def new shared var v-lcerrdes as char.
def new shared var v-find     as logi.
def new shared var s-lcpay    like lcpay.lcpay.
def new shared var s-paysts   like lcpay.sts.
def var v-chose as logi no-undo.
def var v-lang  as char no-undo.
def var v-yes   as logi no-undo.
def new shared var v-lcsumcur as deci.
def new shared var v-lcsumorg as deci.
def new shared var v-lccrc1   as char.
def new shared var v-lccrc2   as char.
def new shared var v-lcdtexp  as date.
def     shared var s-lcprod   as char.
def new shared var s-namef    as char.

{LC.i "new"}
{mainheadlc.i &nm=s-lcprod }

find first txb where txb.bank = s-ourbank no-lock no-error.
if avail txb then s-namef =  caps(txb.name).

{mainlc.i
 &option     = "dc"
 &head       = "LC"
 &headkey    = "LC"
 &framename  = "frpay"
 &formname   = "dcpay"
 &lang       = " v-lang = g-lang. g-lang = 'US'. "
 &start      = "on 'end-error' of frame frpay do: g-lang = v-lang. end."
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
                        s-lc      = ''.
              display s-namef with frame frpay.
              update v-cif with frame frpay.
              find cif where cif.cif = v-cif no-lock no-error.
              if avail cif then v-cifname = trim(trim(cif.prefix) + ' ' + trim(cif.name)).
              display v-cifname with frame frpay.
              repeat on endkey undo, return:
                  update s-lc with frame frpay.
                  s-lc = caps(s-lc).
                  find first lc where lc.lc = s-lc and lc.lc begins s-lcprod and lc.bank = s-ourbank and lookup(LC.LCsts,'FIN,CLS,CNL') > 0 no-lock no-error.
                  if not avail LC then run LChelp2('FIN,CLS,CNL').
                  find first LC where LC.LC = s-lc no-lock no-error.
                  if avail LC then do:
                       assign v-cif   = LC.cif
                              v-lcsts = LC.LCsts.
                       find cif where cif.cif = LC.cif no-lock no-error.
                       if avail cif then v-cifname = trim(trim(cif.prefix) + ' ' + trim(cif.name)).
                       display s-lc v-cifname v-cif v-lcsts with frame frpay.
                       leave.
                  end.
              end.
              v-lcsumcur = 0.
              v-lcsumorg = 0.
              find first lch where lch.lc = s-lc and lch.kritcode = 'Amount' no-lock no-error.
              if avail lch and trim(lch.value1) <> '' then do:
                 v-lcsumcur = deci(lch.value1).
                 v-lcsumorg = deci(lch.value1).
                 /*
                 /*учитываем увеличения и уменьшения суммы amendment*/
                 for each lcamendres where lcamendres.lc = s-lc and (lcamendres.levC = 23 or lcamendres.levD = 23 or lcamendres.levC = 24 or lcamendres.levD = 24) and lcamendres.jh > 0 no-lock:
                     find first jh where jh.jh = lcamendres.jh no-lock no-error.
                     if not avail jh then next.
                     if lcamendres.levD = 23 or lcamendres.levD = 24 then v-lcsumcur = v-lcsumcur + lcamendres.amt.
                     if lcamendres.levC = 23 or lcamendres.levC = 24 then v-lcsumcur = v-lcsumcur - lcamendres.amt.
                 end.
                 /*учитываем суммы payment*/
                 for each lcpayres where lcpayres.lc = s-lc and (lcpayres.levC = 23 or  lcpayres.levC = 24) and lcpayres.jh > 0 no-lock:
                     find first jh where jh.jh = lcpayres.jh no-lock no-error.
                     if avail jh then v-lcsumcur = v-lcsumcur - lcpayres.amt.
                 end.
                 /*учитываем суммы event */
                 for each lceventres where lceventres.lc = s-lc and (lceventres.levC = 23 or lceventres.levC = 24) and lceventres.jh > 0 no-lock:
                     find first jh where jh.jh = lceventres.jh no-lock no-error.
                     if avail jh then v-lcsumcur = v-lcsumcur - lceventres.amt.
                 end.*/
              end.
              display v-lcsumcur v-lcsumorg with frame frpay.
              v-lccrc1 = ''.
              find first lch where lch.lc = s-lc and lch.kritcode = 'lcCrc' no-lock no-error.
              if avail lch and trim(lch.value1) <> '' then do:
                find first crc where crc.crc = int(trim(lch.value1)) no-lock no-error.
                if avail crc then assign v-lccrc1 = crc.code v-lccrc2 = crc.code.
              end.
              display v-lccrc1 v-lccrc2 with frame frpay.
              find first lch where lch.lc = s-lc and lch.kritcode = 'DtExp' no-lock no-error.
              if avail lch and lch.value1 <> ? then do:
                 v-lcdtexp = date(lch.value1).
                 find last lcamendh where lcamendh.lc = s-lc and lcamendh.kritcode = 'NewDtEx' and lcamendh.value1 ne '' no-lock no-error.
                 if avail lcamendh then v-lcdtexp = date(lcamendh.value1).
                 display v-lcdtexp with frame frpay.
              end. "
 &postfind = " if avail LC then v-lcsts = LC.LCsts.
               display v-lcsts with frame frpay.
               do on error undo,return:
                    v-yes = no.
                    if v-lcsts = 'FIN' then
                        message 'Do you want to create a new Payment?' VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE ' QUESTION !' update v-yes.
                    if not v-yes then do:
                        s-lcpay = 0.
                        update s-lcpay with frame frpay.
                        find first LCpay where LCpay.lc = s-lc and LCpay.LCpay = s-lcpay no-lock no-error.
                        if avail LCpay then assign s-paysts = LCpay.sts v-chose = yes.
                    end.
                    if v-yes then do transaction:
                        if deci(v-lcsumcur) = 0 then do:
                            message 'This Letter of credit has been paid!' view-as alert-box.
                            leave.
                        end.
                        s-lcpay = 0.
                        find last lcpay where lcpay.lc = s-lc use-index LC no-lock no-error.
                        if avail lcpay then do:
                            if lcpay.sts <> 'FIN' then do:
                                message 'The status of last payment (number ' + string(lcpay.lcpay) +  ') is not FIN, it is impossible to create new payment!' view-as alert-box error.
                                v-yes = no.
                                leave.
                            end.
                            s-lcpay = lcpay.lcpay + 1.
                        end.
                        else s-lcpay = 1.
                        create LCpay.
                        assign LCpay.lc    = s-lc
                               LCpay.LCpay = s-lcpay
                               LCpay.bank  = s-ourbank
                               LCpay.sts   = 'NEW'
                               LCpay.rwho  = g-ofc
                               LCpay.rwhn  = g-today.
                               s-paysts    = 'NEW'.
                       display s-lcpay s-paysts with frame frpay.
                       v-chose = yes.
                    end.
                end.
                if s-paysts = 'Err' or s-paysts = 'ErrA' then do:
                   find first lcpayh where lcpayh.bank = s-ourbank and lcpayh.lc = s-lc and lcpay.lcpay = s-lcpay and lcpayh.kritcode = 'Errdes' no-lock no-error.
                   if avail lcpayh then v-lcerrdes = lcpayh.value1.
                   display v-lcerrdes with frame frpay.
               end. "
 &numprg = "xxx"
 &subprg = "dcpayedt"
 &end = " g-lang = v-lang. "
}
