/* lccancel.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Cancel - аннулирование
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
        15/04/2011 id00810
 * BASES
        BANK  COMM
 * CHANGES
        27/06/2011 id00810 - возможность просмотра события по закрытым LC
        17/01/2012 id00810 - добавлена переменная - наименование филиала
        07/03/2012 id00810 - учет лимита
        19.06.2012 Lyubov  - для списания комиссий при закрытии указала тип 1(все комиссии)
        10.07.2012 Lyubov  - добавила выбор счетов для списания несамортизированного остатка
 */

def new shared var v-cif      as   char.
def new shared var v-cifname  as   char.
def new shared var v-lcsts    as   char.
def new shared var v-lcerrdes as   char.
def new shared var v-find     as   logi.
def new shared var s-type     as   char.
def new shared var s-event    like lcevent.event init 'cnl'.
def new shared var s-number   like lcevent.number.
def new shared var s-sts      like lcevent.sts.
def var v-chose  as logi.
def var v-lang   as char.
def var v-yes    as logi.
def var v-cov    as char.
def var v-per    as int  no-undo.
def var v-numlim as int  no-undo.
def var v-revolv as logi no-undo.
def var v-limsum as deci no-undo.
def var v-limcrc as char no-undo.
def var v-crc    as int  no-undo.
def new shared var v-rcacc    as char.
def new shared var v-rcaname  as char.
def new shared var v-lcsum1   as deci.
def new shared var v-lcsum2   as deci.
def new shared var v-lccrc1   as char.
def new shared var v-lccrc2   as char.
def new shared var v-lcdtexp  as date.
def new shared var s-ftitle   as char init ' CANCEL '.
def     shared var s-lcprod   as char.
def new shared var s-namef    as char.

{LC.i "new"}
{mainheadlc.i &nm=s-lcprod }
find first txb where txb.bank = s-ourbank no-lock no-error.
if avail txb then s-namef =  caps(txb.name).

s-type = '1'.

{mainlc.i
 &option     = "imlc"
 &head       = "LC"
 &headkey    = "LC"
 &framename  = "frcnl"
 &formname   = "lccnl"
 &lang       = " v-lang = g-lang. g-lang = 'US'. "
 &start      = "on 'end-error' of frame frcnl do: g-lang = v-lang. end."
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
                        v-chose   = no
                        s-number  = 1.
              display s-namef with frame frcnl.
              update v-cif with frame frcnl.
              find cif where cif.cif = v-cif no-lock no-error.
              if avail cif then v-cifname = trim(trim(cif.prefix) + ' ' + trim(cif.name)).
              display v-cifname with frame frcnl.

              repeat on endkey undo, return:
                  update s-LC with frame frcnl.
                  s-lc = caps(s-lc).
                  find first LC where LC.LC = s-lc and LC.bank = s-ourbank and lookup(lc.lcsts,'FIN,CLS,CNL') > 0 no-lock no-error.
                  if not avail LC then run lchelp3('FIN,CLS,CLN').
                  find first LC where LC.LC = s-lc no-lock no-error.
                  if avail LC then do:
                       assign v-cif   = LC.cif
                              v-lcsts = LC.LCsts.
                       find cif where cif.cif = LC.cif no-lock no-error.
                       if avail cif then v-cifname = trim(trim(cif.prefix) + ' ' + trim(cif.name)).
                       display s-lc v-cifname v-cif v-lcsts with frame frcnl.
                       leave.
                  end.
              end.
              assign v-lcsum1 = 0 v-lcsum2 = 0 .
              find first lch where lch.lc = s-lc and lch.kritcode = 'cover' no-lock no-error.
              if not avail lch then return.
              else v-cov = lch.value1.
              find first lch where lch.lc = s-lc and lch.kritcode = 'Amount' no-lock no-error.
              if avail lch and trim(lch.value1) <> '' then do:
                 v-lcsum2 = deci(lch.value1).
                 find first lch where lch.lc = lc.lc and lch.kritcode = 'peramt' no-lock no-error.
                 if avail lch and lch.value1 ne '' then do:
                    v-per = int(entry(1,lch.value1, '/')).
                    if v-per > 0 then v-lcsum2 = v-lcsum2 + (v-lcsum2 * (v-per / 100)).
                 end.
                /*учитываем суммы amendment*/
                 if s-lcprod <> 'pg' then
                 for each lcamendres where lcamendres.lc = s-lc and (lcamendres.levC = 23 or lcamendres.levD = 23 or lcamendres.levC = 24 or lcamendres.levD = 24) and lcamendres.jh > 0 no-lock:
                     find first jh where jh.jh = lcamendres.jh no-lock no-error.
                     if not avail jh then next.
                     if lcamendres.levD = 23 or lcamendres.levD = 24 then v-lcsum2 = v-lcsum2 + lcamendres.amt.
                     if lcamendres.levC = 23 or lcamendres.levC = 24 then v-lcsum2 = v-lcsum2 - lcamendres.amt.
                 end.
                 else
                 for each lcamendres where lcamendres.lc = lc.lc and (lcamendres.dacc = '605561' or  lcamendres.dacc = '655561' or lcamendres.dacc = '605562' or  lcamendres.dacc = '655562') and lcamendres.jh > 0 no-lock:
                    find first jh where jh.jh = lcamendres.jh no-lock no-error.
                    if not avail jh then next.
                    if lcamendres.dacc = '605561' or lcamendres.dacc = '605562' then v-lcsum2 = v-lcsum2  + lcamendres.amt.
                    else v-lcsum2 = v-lcsum2  - lcamendres.amt.
                 end.
                 /*учитываем суммы payment*/
                 for each lcpayres where lcpayres.lc = s-lc and (lcpayres.levC = 23 or lcpayres.levC = 24 or lcpayres.dacc = '655561' or lcpayres.dacc = '655562') and lcpayres.jh > 0 no-lock:
                     find first jh where jh.jh = lcpayres.jh no-lock no-error.
                     if avail jh then v-lcsum2 = v-lcsum2 - lcpayres.amt.
                 end.
                 /*учитываем суммы event */
                 for each lceventres where lceventres.lc = s-lc and (lceventres.levC = 23 or lceventres.levC = 24 or lceventres.dacc = '655561' or lceventres.dacc = '655562') and lceventres.jh > 0 no-lock:
                     find first jh where jh.jh = lceventres.jh no-lock no-error.
                     if avail jh then v-lcsum2 = v-lcsum2 - lceventres.amt.
                 end.
              end.
              v-lcsum1 = if v-cov = '0' then v-lcsum2 else 0.
              display v-lcsum1 v-lcsum2 with frame frcnl.
              v-lccrc1 = ''.
              find first lch where lch.lc = s-lc and lch.kritcode = 'lcCrc' no-lock no-error.
              if avail lch and trim(lch.value1) <> '' then do:
                find first crc where crc.crc = int(trim(lch.value1)) no-lock no-error.
                if avail crc then assign v-lccrc1 = crc.code v-lccrc2 = crc.code.
              end.
              display v-lccrc1 v-lccrc2 with frame frcnl.
              find first lch where lch.lc = s-lc and lch.kritcode = 'DtExp' no-lock no-error.
              if avail lch and lch.value1 <> ? then do:
                 v-lcdtexp = date(lch.value1).
                 find last lcamendh where lcamendh.bank = lc.bank and lcamendh.lc = s-lc and lcamendh.kritcode = 'NewDtEx' and lcamendh.value1 ne '' no-lock no-error.
                 if avail lcamendh then v-lcdtexp = date(lcamendh.value1).
                 display v-lcdtexp with frame frcnl.
              end.
              find first lch where lch.lc = s-lc and lch.kritcode = 'NLim' no-lock no-error.
              if avail lch then do:
                find first lclimit where lclimit.bank = s-ourbank and lclimit.cif = v-cif and lclimit.number = int(lch.value1) no-lock no-error.
                if avail lclimit then if lclimit.sts = 'FIN' then do:
                    v-numlim = int(lch.value1).
                    find first lclimith where lclimith.bank = s-ourbank and lclimith.cif = v-cif and lclimith.number = v-numlim and lclimith.kritcode = 'revolv' no-lock no-error.
                    if avail lclimith then if lclimith.value1 = 'yes' then v-revolv = yes.
                end.
              end. "
 &postfind = " if avail LC then v-lcsts = LC.LCsts.
               display v-lcsts with frame frcnl.
               if v-lcsts ne 'FIN' then do:
                    find first lcevent where lcevent.bank = s-ourbank and lcevent.lc = s-lc and lcevent.event = 'cnl' and lcevent.number = s-number no-lock no-error.
                    if avail lcevent then do:
                        s-sts = lcevent.sts.
                        display s-sts with frame frcnl. v-chose = yes.
                    end.
               end.
               else do:
                if (v-lcsum1 = 0) and (v-lcsum2 = 0) then do:
                    message 'Nothing is to write off for this LC! Do you want to change Credit status?' VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE ' QUESTION !' update v-yes.
                    if v-yes then do:
                        if not v-revolv then do:
                            run LCsts(v-lcsts,'CLS').
                            find first lcevent where lcevent.bank = s-ourbank and lcevent.lc = s-lc and lcevent.event = 'cnl' and lcevent.number = s-number no-lock no-error.
                            if avail lcevent and lcevent.sts ne 'FIN' then do:
                                find current lcevent exclusive-lock no-error.
                                delete lcevent.
                            end.
                            v-chose = no.
                        end.
                        else do:
                            find first lcevent where lcevent.bank = s-ourbank and lcevent.lc = s-lc and lcevent.event = 'cnl' and lcevent.number = s-number no-lock no-error.
                            if not avail lcevent then do:
                                create lcevent.
                                assign  lcevent.lc     = s-lc
                                        lcevent.event  = 'cnl'
                                        lcevent.number = s-number
                                        lcevent.bank   = s-ourbank
                                        lcevent.sts    = 'NEW'
                                        lcevent.rwho   = g-ofc
                                        lcevent.rwhn   = g-today.
                            end.
                            s-sts = lcevent.sts.
                            display s-sts with frame frcnl.
                            v-chose = yes.
                            find current lcevent no-lock no-error.
                        end.
                    end.
                end.
                else do:
                    message 'Do you want to write off this closing balance?' VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE ' QUESTION !' update v-yes.
                    display v-cif v-cifname s-lc v-lcsts v-lcerrdes s-sts with frame frcnl.
                    if v-yes then do:
                        find first lcevent where lcevent.bank = s-ourbank and lcevent.lc = s-lc and lcevent.event = 'cnl' and lcevent.number = s-number no-lock no-error.
                        if not avail lcevent then do:
                            create lcevent.
                            assign  lcevent.lc     = s-lc
                                    lcevent.event  = 'cnl'
                                    lcevent.number = s-number
                                    lcevent.bank   = s-ourbank
                                    lcevent.sts    = 'NEW'
                                    lcevent.rwho   = g-ofc
                                    lcevent.rwhn   = g-today.
                        end.
                        s-sts = lcevent.sts.
                        display s-sts with frame frcnl.
                        if v-cov = '1' then update v-rcacc with frame frcnl. v-chose = yes.
                        find current lcevent no-lock no-error.
                    end.
                end.
                if v-chose then do:
                        if v-lcsum1 > 0 then do:
                            find first lceventh where lceventh.bank = s-ourbank and lceventh.lc = s-lc and lceventh.event = 'cnl' and lceventh.number = s-number and lceventh.kritcode = 'OutBal' no-lock no-error.
                            if not avail lceventh then do:
                                create lceventh.
                                assign  lceventh.lc       = s-lc
                                        lceventh.event    = 'cnl'
                                        lceventh.number   = s-number
                                        lceventh.bank     = s-ourbank
                                        lceventh.kritcode = 'OutBal'.
                            end.
                            find current lceventh exclusive-lock no-error.
                            lceventh.value1 = string(v-lcsum1).
                            find current lceventh no-lock no-error.
                        end.
                        if v-lcsum2 > 0 then do:
                            find first lceventh where lceventh.bank = s-ourbank and lceventh.lc = s-lc and lceventh.event = 'cnl' and lceventh.number = s-number and lceventh.kritcode = 'Claims' no-lock no-error.
                            if not avail lceventh then do:
                                create lceventh.
                                assign  lceventh.lc       = s-lc
                                        lceventh.event    = 'cnl'
                                        lceventh.number   = s-number
                                        lceventh.bank     = s-ourbank
                                        lceventh.kritcode = 'Claims'.
                            end.
                            find current lceventh exclusive-lock no-error.
                            lceventh.value1 = string(v-lcsum2).
                            find current lceventh no-lock no-error.
                        end.
                        if v-revolv then do:
                            find first lclimitres where lclimitres.bank = lclimit.bank and lclimitres.cif = lclimit.cif and lclimitres.number = lclimit.number and lclimitres.lc = s-lc and lclimitres.info[1] = 'create' and lclimitres.jh > 0 no-lock no-error.
                            if avail lclimitres then find first jh where jh.jh = lclimitres.jh no-lock no-error.
                            if avail jh then assign v-limsum = lclimitres.amt v-limcrc = string(lclimitres.crc).
                            for each lclimitres where lclimitres.bank = lclimit.bank and lclimitres.cif = lclimit.cif and lclimitres.number = lclimit.number and lclimitres.lc = s-lc and lookup(lclimitres.info[1],'append,pay') > 0 and lclimitres.jh > 0 no-lock:
                                find first jh where jh.jh = lclimitres.jh no-lock no-error.
                                if not avail jh then next.
                                if substr(lclimitres.dacc,1,2) = '66' then v-limsum = v-limsum + lclimitres.amt. else v-limsum = v-limsum - lclimitres.amt.
                            end.
                            find first lceventh where lceventh.bank = s-ourbank and lceventh.lc = s-lc and lceventh.event = 'cnl' and lceventh.number = s-number and lceventh.kritcode = 'Limits' no-lock no-error.
                            if not avail lceventh then do:
                                create lceventh.
                                assign  lceventh.lc       = s-lc
                                        lceventh.event    = 'cnl'
                                        lceventh.number   = s-number
                                        lceventh.bank     = s-ourbank
                                        lceventh.kritcode = 'Limits'.
                            end.
                            find current lceventh exclusive-lock no-error.
                            lceventh.value1 = string(v-limsum).
                            find current lceventh no-lock no-error.
                        end.
                 end.
               end.
               if s-sts = 'Err' then do:
                find first lceventh where lceventh.bank = s-ourbank and lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'Errdes' no-lock no-error.
                if avail lceventh then v-lcerrdes = lceventh.value1. display v-lcerrdes with frame frcnl.
               end. "
 &numprg = "xxx"
 &subprg = "lccnl"
 &end = " g-lang = v-lang. "
}
