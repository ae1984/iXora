/* imlcadvr.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Advice of Refusal
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
        15/03/2011 evseev
 * BASES
        BANK  COMM
 * CHANGES
    21/06/2011 id00810 - возможность просмотра события по закрытым LC
    28/12/2011 id00810 - учет реквизита NewAmt для экспортных аккредитивов
    17/01/2012 id00810 - добавлена переменная - наименование филиала
    09/02/2012 id00810 - исправлена ошибка: обращение не к той форме при выводе v-lcerrdes
 */


def new shared var v-cif        as char.
def new shared var v-cifname    as char.
def new shared var v-lcsts      as char.
def new shared var v-lcerrdes   as char.
def new shared var v-find       as logi.
def new shared var s-countevent as integer.
def new shared var s-event      like lcevent.event init 'advicer'.
def new shared var s-number     like lcevent.number.
def new shared var s-sts        like lcevent.sts.
def var v-chose as logi no-undo.
def var v-lang  as char no-undo.
def var v-yes   as logi no-undo.
def var v-per   as int  no-undo.

def new shared var v-lcsumcur as deci.
def new shared var v-lcsumorg as deci.
def new shared var v-lccrc1   as char.
def new shared var v-lccrc2   as char.
def new shared var v-lcdtexp  as date.
def     shared var s-lcprod   as char.
def new shared var s-namef    as char.

{LC.i "new"}
{mainheadlc.i &nm=s-lcprod}

find first txb where txb.bank = s-ourbank no-lock no-error.
if avail txb then s-namef =  caps(txb.name).

{mainlc.i
 &option     = "imlc"
 &head       = "LCevent"
 &headkey    = "lc"
 &framename  = "frcor"
 &formname   = "advr734"
 &lang       = " v-lang = g-lang. g-lang = 'US'. "
 &start      = "on 'end-error' of frame frcor do: g-lang = v-lang. end."
 &langend    = "  "
 &findcon    = "true"
 &addcon     = "true"
 &cond       = " "
 &start      = " "
 &clearframe = " "
 &viewframe  = " "
 &preadd     = " assign v-find     = yes
                        v-cif      = ''
                        v-cifname  = ''
                        v-lcsts    = ''
                        s-lc       = ''
                        s-number   = 0
                        v-chose    = no
                        v-lcerrdes = ''.
                display s-namef with frame frcor.
              update v-cif with frame frcor.
              find cif where cif.cif = v-cif no-lock no-error.
              if avail cif then v-cifname = trim(trim(cif.prefix) + ' ' + trim(cif.name)).
              repeat on endkey undo, return:
                  update s-LC with frame frcor.
                  s-lc = caps(s-lc).
                  find first LC where LC.LC = s-lc and lc.lc begins s-lcprod and LC.bank = s-ourbank and LC.LCsts = 'FIN' no-lock no-error.
                  if not avail LC then run LChelp2('FIN').
                  find first LC where LC.LC = s-lc no-lock no-error.
                  if avail LC then do:
                       assign v-cif   = LC.cif
                              v-lcsts = LC.LCsts.
                       find cif where cif.cif = LC.cif no-lock no-error.
                       if avail cif then v-cifname = trim(trim(cif.prefix) + ' ' + trim(cif.name)).
                       display s-lc v-cifname v-cif v-lcsts with frame frcor.
                       leave.
                  end.
              end.
              v-lcsumcur = 0.
              v-lcsumorg = 0.
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
                 if lc.lctype = 'E' then do:
                    find last lcamendh where lcamendh.bank = lc.bank and lcamendh.lc = s-lc and lcamendh.kritcode = 'NewAmt' and lcamendh.value1 ne '' no-lock no-error.
                    if avail lcamendh then v-lcsumcur = deci(replace(lcamendh.value1,',','.')).
                 end.
                 /*учитываем увеличения и уменьшения суммы amendment*/
                 for each lcamendres where lcamendres.lc = s-lc and (lcamendres.levC = 23 or lcamendres.levD = 23 or lcamendres.levC = 24 or lcamendres.levD = 24) and lcamendres.jh > 0 no-lock:
                     find first jh where jh.jh = lcamendres.jh no-lock no-error.
                     if not avail jh then next.
                     if lcamendres.levD = 23 or lcamendres.levD = 24 then v-lcsumcur = v-lcsumcur + lcamendres.amt.
                     if lcamendres.levC = 23 or lcamendres.levC = 24 then v-lcsumcur = v-lcsumcur - lcamendres.amt.
                 end.
                 /*учитываем суммы payment*/
                 for each lcpayres where lcpayres.lc = s-lc and (lcpayres.levD = 22 or lcpayres.dacc = '185511' or lcpayres.dacc = '185512') and lcpayres.jh > 0 no-lock:
                     find first jh where jh.jh = lcpayres.jh no-lock no-error.
                     if avail jh then v-lcsumcur = v-lcsumcur - lcpayres.amt.
                 end.
              end.
              display v-lcsumcur v-lcsumorg with frame frcor.
              v-lccrc1 = ''.
              find first lch where lch.lc = s-lc and lch.kritcode = 'lcCrc' no-lock no-error.
              if avail lch and trim(lch.value1) <> '' then do:
                find first crc where crc.crc = int(trim(lch.value1)) no-lock no-error.
                if avail crc then assign v-lccrc1 = crc.code v-lccrc2 = crc.code.
              end.
              display v-lccrc1 v-lccrc2 with frame frcor.
              find first lch where lch.lc = s-lc and lch.kritcode = 'DtExp' no-lock no-error.
              if avail lch and lch.value1 <> ? then do:
                 v-lcdtexp = date(lch.value1).
                 display v-lcdtexp with frame frcor.
              end.
              message 'Do you want to create a new Advice of Refusal?' VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE ' ATTENTION !'
              update v-chose.  "
 &presubprg = "if v-chose then "
 &postadd = " assign LCevent.event  = s-event
                     LCevent.sts    = 'NEW'
                     LCevent.number = s-countevent
                     LCevent.bank   = s-ourbank
                     LCevent.rwho   = g-ofc
                     LCevent.rwhn   = g-today
                     s-number       = s-countevent.

              if avail LC then v-lcsts = LC.LCsts.
               display v-lcsts v-lcerrdes with frame frcor.
               do on error undo,return on endkey undo, return:
                  find first lcevent where LCevent.lc = s-lc and Lcevent.event = s-event and LCevent.number = s-number use-index bank no-lock no-error.
                  if not avail LCevent
                  then message 'No Advice of Refusal for this LC!' view-as alert-box error.
                  else do:
                    update s-number with frame frcor.
                    find first LCevent where LCevent.lc = s-lc and LCevent.event = s-event and LCevent.number = s-number no-lock no-error.
                    if avail LCevent then do:
                        assign s-number = LCevent.number s-sts = LCevent.sts v-chose = yes.
                        display s-number s-sts with frame frcor.
                    end.
                  end.
                end. "
 &prefind = " assign v-find     = yes
                     v-cif      = ''
                     v-cifname  = ''
                     v-lcsts    = ''
                     s-lc       = ''
                     s-number   = 0
                     v-chose    = no
                     v-lcerrdes = ''.
              display s-namef with frame frcor.
              update v-cif with frame frcor.
              find cif where cif.cif = v-cif no-lock no-error.
              if avail cif then v-cifname = trim(trim(cif.prefix) + ' ' + trim(cif.name)).
              display v-cifname with frame frcor.

              repeat on endkey undo, return:
                  update s-LC with frame frcor.
                  s-lc = caps(s-lc).
                  find first LC where LC.LC = s-lc and LC.bank = s-ourbank and LC.LCsts = 'FIN' no-lock no-error.
                  if not avail LC then run LChelp2('FIN').
                  find first LC where LC.LC = s-lc and LC.bank = s-ourbank and LC.LCsts = 'FIN' no-lock no-error.
                  if avail LC then do:
                       v-cif = LC.cif.
                       v-lcsts = LC.LCsts.
                       find cif where cif.cif = LC.cif no-lock no-error.
                       if avail cif then v-cifname = trim(trim(cif.prefix) + ' ' + trim(cif.name)).
                       display s-lc v-cifname v-cif v-lcsts with frame frcor.
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
                 find first lch where lch.lc = lc.lc and lch.kritcode = 'peramt' no-lock no-error.
                 if avail lch and lch.value1 ne '' then do:
                    v-per = int(entry(1,lch.value1, '/')).
                    if v-per > 0 then assign v-lcsumorg = v-lcsumorg + (v-lcsumorg * (v-per / 100))
                                             v-lcsumcur = v-lcsumorg.
                 end.
                 if lc.lctype = 'E' then do:
                    find last lcamendh where lcamendh.bank = lc.bank and lcamendh.lc = s-lc and lcamendh.kritcode = 'NewAmt' and lcamendh.value1 ne '' no-lock no-error.
                    if avail lcamendh then v-lcsumcur = deci(replace(lcamendh.value1,',','.')).
                 end.
                 /*учитываем суммы amendment*/
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
                 end.
              end.
              display v-lcsumcur v-lcsumorg with frame frcor.
              v-lccrc1 = ''.
              find first lch where lch.lc = s-lc and lch.kritcode = 'lcCrc' no-lock no-error.
              if avail lch and trim(lch.value1) <> '' then do:
                find first crc where crc.crc = int(trim(lch.value1)) no-lock no-error.
                if avail crc then assign v-lccrc1 = crc.code v-lccrc2 = crc.code.
              end.
              display v-lccrc1 v-lccrc2 with frame frcor.
              find first lch where lch.lc = s-lc and lch.kritcode = 'DtExp' no-lock no-error.
              if avail lch and lch.value1 <> ? then do:
                 v-lcdtexp = date(lch.value1).
                 find last lcamendh where lcamendh.lc = s-lc and lcamendh.kritcode = 'NewDtEx' and lcamendh.value1 ne '' no-lock no-error.
                 if avail lcamendh then v-lcdtexp = date(lcamendh.value1).
                 display v-lcdtexp with frame frcor.
              end. "
 &postfind = " if avail LC then v-lcsts = LC.LCsts.
               display v-lcsts with frame frcor.
               do on error undo,return on endkey undo, return:
                  find first lcevent where LCevent.lc = s-lc and Lcevent.event = s-event use-index bank no-lock no-error.
                  if not avail LCevent
                  then message 'No Advice of Refusal for this LC!' view-as alert-box error.
                  else do:
                  /*  display v-cif v-cifname s-lc v-lcsts v-lcerrdes s-number with frame frcor.*/
                    find last LCevent where LCevent.lc = s-lc and Lcevent.event = s-event and LCevent.number > 0 use-index bank no-lock no-error.
                    if avail LCevent then s-number = LCevent.number.
                    update s-number with frame frcor.
                    find first LCevent where LCevent.lc = s-lc and Lcevent.event = s-event and LCevent.number = s-number no-lock no-error.
                    if avail LCevent then do:
                        assign s-number = LCevent.number s-sts = LCevent.sts v-chose = yes.
                        display s-number s-sts with frame frcor.
                    end.
                   if s-sts = 'Err' then do:
                    find first lceventh where lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'ErrDes' no-lock no-error.
                    if avail lceventh then v-lcerrdes = lceventh.value1.
                   end.
                   display v-lcerrdes with frame frcor.
                  end.
                end."
 &numprg = "lceventinc"
 &subprg = "advr734"
 &end = " g-lang = v-lang. "
}

