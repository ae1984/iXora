/* lcpfindet.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        IMLC: Post Finance Details
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        14-1-13
 * AUTHOR
        21/10/2011 id00810
 * BASES
        BANK  COMM
 * CHANGES
        17/01/2012 id00810 - добавлена переменная - наименование филиала
*/

def new shared var v-cif      as char.
def new shared var v-cifname  as char.
def new shared var v-lcsts    as char.
def new shared var v-lcerrdes as char.
def new shared var v-find     as logi.
def new shared var s-event    like lcevent.event init 'pfind'.
def new shared var s-number   like lcevent.number.
def new shared var s-sts      like lcevent.sts.
def new shared var s-ftitle   as char init ' POST FINANCE DETAILS '.
def var v-chose as logi no-undo.
def var v-lang  as char no-undo.
def var v-yes   as logi no-undo.
def var v-per   as int  no-undo.

def new shared var v-lcsumcur as deci.
def new shared var v-lcsumorg as deci.
def new shared var v-lccrc1   as char.
def new shared var v-lccrc2   as char.
def new shared var v-lcdtexp  as date.
def new shared var s-lcprod   as char.
def new shared var s-namef    as char.

{LC.i "new"}
if s-ourbank <> 'TXB00' then do:
    message 'The event Post Finance Details can be created only in Central Office!' view-as alert-box error.
    return.
end.
s-lcprod = 'IMLC'.
{mainheadlc.i &nm=s-lcprod }

find first txb where txb.bank = s-ourbank no-lock no-error.
if avail txb then s-namef =  caps(txb.name).

{mainlc.i
 &option     = "imlc"
 &head       = "LC"
 &headkey    = "LC"
 &framename  = "frevent"
 &formname   = "lcevent"
 &lang       = " v-lang = g-lang. g-lang = 'US'. "
 &start      = "on 'end-error' of frame frevent do: g-lang = v-lang. end."
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
 &prefind    = " assign v-find     = yes
                        v-cif      = ''
                        v-cifname  = ''
                        v-lcsts    = ''
                        s-lc       = ''
                        v-lcsumcur = 0
                        v-lcsumorg = 0.
              display s-namef with frame frevent.
              update v-cif with frame frevent.
              find cif where cif.cif = v-cif no-lock no-error.
              if avail cif then v-cifname = trim(trim(cif.prefix) + ' ' + trim(cif.name)).
              display v-cifname with frame frevent.
              repeat on endkey undo, return:
                  update s-lc with frame frevent.
                  s-lc = caps(s-lc).
                  find first LC where LC.LC = s-lc and LC.bank = s-ourbank and lookup(lc.lcsts,'FIN,CLS,CNL') > 0  no-lock no-error.
                  if not avail LC then run lchelp4('FIN,CLS,CNL','cover','1') /*lchelp3('FIN,CLS,CNL')*/.
                  find first LC where LC.LC = s-lc no-lock no-error.
                  if avail LC then do:
                    find first lch where lch.lc = s-lc and lch.kritcode = 'cover' no-lock no-error.
                    if avail lch and lch.value1 <> '1' then do:
                        message 'This event is avail only for uncovered LC!' view-as alert-box error.
                        undo, retry.
                    end.
                    find first lch where lch.lc = s-lc and lch.kritcode = 'AccPay' no-lock no-error.
                    if not avail lch or (avail lch and lch.value1 = '') then do:
                        message 'There is no deal for ' + s-lc + '!' view-as alert-box error.
                        undo, retry.
                    end.
                    v-cif = LC.cif.
                    v-lcsts = LC.LCsts.
                    find cif where cif.cif = LC.cif no-lock no-error.
                    if avail cif then v-cifname = trim(trim(cif.prefix) + ' ' + trim(cif.name)).
                    display s-lc v-cifname v-cif v-lcsts with frame frevent.
                    leave.
                  end.
              end.
              find first lch where lch.lc = s-lc and lch.kritcode = 'Amount' no-lock no-error.
              if avail lch and trim(lch.value1) <> '' then do:
                 v-lcsumcur = deci(lch.value1).
                 v-lcsumorg = deci(lch.value1).
                 find first lch where lch.lc = lc.lc and lch.kritcode = 'peramt' no-lock no-error.
                 if avail lch and lch.value1 ne '' then do:
                    v-per = int(entry(1,lch.value1, '/')).
                    if v-per > 0 then assign v-lcsumorg = v-lcsumorg + (v-lcsumorg * (v-per / 100))
                                             v-lcsumcur = v-lcsumorg.
                 end.
                 /*учитываем суммы amendment*/
                 for each lcamendres where lcamendres.lc = s-lc and (lcamendres.levC = 23 or lcamendres.levD = 23 or lcamendres.levC = 24 or lcamendres.levD = 24) and lcamendres.jh > 0 no-lock:
                     find first jh where jh.jh = lcamendres.jh no-lock no-error.
                     if not avail jh then next.
                     if lcamendres.levD = 23 or lcamendres.levD = 24 then v-lcsumcur = v-lcsumcur + lcamendres.amt.
                     if lcamendres.levC = 23 or lcamendres.levC = 24 then v-lcsumcur = v-lcsumcur - lcamendres.amt.
                 end.
                 /*учитываем суммы payment*/
                 for each lcpayres where lcpayres.lc = s-lc and (lcpayres.levC = 23 or lcpayres.levC = 24) and lcpayres.jh > 0 no-lock:
                     find first jh where jh.jh = lcpayres.jh no-lock no-error.
                     if avail jh then v-lcsumcur = v-lcsumcur - lcpayres.amt.
                 end.
                 /*учитываем суммы event */
                 for each lceventres where lceventres.lc = s-lc and (lceventres.levC = 23 or lceventres.levC = 24) and lceventres.jh > 0 no-lock:
                     find first jh where jh.jh = lceventres.jh no-lock no-error.
                     if avail jh then v-lcsumcur = v-lcsumcur - lceventres.amt.
                 end.
              end.
              display v-lcsumcur v-lcsumorg with frame frevent.
              v-lccrc1 = ''.
              find first lch where lch.lc = s-lc and lch.kritcode = 'lcCrc' no-lock no-error.
              if avail lch and trim(lch.value1) <> '' then do:
                find first crc where crc.crc = int(trim(lch.value1)) no-lock no-error.
                if avail crc then assign v-lccrc1 = crc.code v-lccrc2 = crc.code.
              end.
              display v-lccrc1 v-lccrc2 with frame frevent.
              find first lch where lch.lc = s-lc and lch.kritcode = 'DtExp' no-lock no-error.
              if avail lch and lch.value1 <> ? then do:
                v-lcdtexp = date(lch.value1).
                find last lcamendh where lcamendh.lc = s-lc and lcamendh.kritcode = 'NewDtEx' and lcamendh.value1 ne '' no-lock no-error.
                if avail lcamendh then v-lcdtexp = date(lcamendh.value1).
                display v-lcdtexp with frame frevent.
              end. "
 &postfind = " if avail LC then v-lcsts = LC.LCsts.
               display v-lcsts with frame frevent.
               do on error undo,return:
                   v-yes = no.
                   if v-lcsts = 'FIN' then
                   message 'Do you want to create a new Event (Post Finance Details)?' VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE ' QUESTION !' update v-yes.
                   if not v-yes then do:
                        s-number = 0.
                        update s-number with frame frevent.
                        find first lcevent where lcevent.lc = s-lc and lcevent.event  = s-event and lcevent.number = s-number no-lock no-error.
                        if avail lcevent then assign s-sts = lcevent.sts v-chose = yes.
                    end.
                    if v-yes then do transaction:
                        s-number = 0.
                        find last lcevent where lcevent.lc = s-lc and lcevent.event = s-event no-lock no-error.
                        if avail lcevent then do:
                            if lcevent.sts <> 'FIN' then do:
                                message 'The status of last event (Post Finance Details number ' + string(lcevent.number) +  ') is not FIN, it is impossible create a new Event!' view-as alert-box error.
                                assign v-yes    = no
                                       s-sts    = lcevent.sts
                                       s-number = lcevent.number.
                            end.
                            else s-number = lcevent.number + 1.
                        end.
                        else s-number = 1.
                        if v-yes then do:
                            create lcevent.
                            assign lcevent.lc     = s-lc
                                   lcevent.event  = s-event
                                   lcevent.number = s-number
                                   lcevent.bank   = s-ourbank
                                   lcevent.sts    = 'NEW'
                                   lcevent.rwho   = g-ofc
                                   lcevent.rwhn   = g-today.
                            s-sts = 'NEW'.
                        end.
                       display s-number s-sts with frame frevent.
                       v-chose = yes.
                    end.
                end.
                if s-sts = 'Err' then do:
                    find first lceventh where lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'Errdes' no-lock no-error.
                    if avail lceventh then v-lcerrdes = lceventh.value1.
                end.
                display  v-lcerrdes with frame frevent. "
 &numprg = "xxx"
 &subprg = "lcpfind"
 &end = " g-lang = v-lang. "
}

