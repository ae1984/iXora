/* lcincor.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Корреспонденция - входящий свифт
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
        10/01/2011 Vera
 * BASES
        BANK  COMM
 * CHANGES
    18/02/2011 id00810 - для всех продуктов
    24/06/2011 id00810 - возможность просмотра события по закрытым LC
    21/11/2011 id00810 - сохраним для истории информацию о пользователе
    17/01/2012 id00810 - добавлена переменная - наименование филиала
 */

def new shared var v-cif      as   char.
def new shared var v-cifname  as   char.
def new shared var v-lcsts    as   char.
def new shared var v-lcerrdes as   char.
def new shared var v-find     as   logi.
def new shared var s-lccor    like lcswt.lccor.
def new shared var s-corsts   like lcswt.sts.
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
{mainheadlc.i &nm=s-lcprod }

find first txb where txb.bank = s-ourbank no-lock no-error.
if avail txb then s-namef =  caps(txb.name).

{mainlc.i
 &option     = "imlc"
 &head       = "LC"
 &headkey    = "LC"
 &framename  = "frcor"
 &formname   = "lccor"
 &lang       = " v-lang = g-lang. g-lang = 'US'. "
 &start      = "on 'end-error' of frame frcor do: g-lang = v-lang. end."
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
                        s-lccor   = 0
                        v-chose   = no.
              display s-namef with frame frcor.
              update v-cif with frame frcor.
              find cif where cif.cif = v-cif no-lock no-error.
              if avail cif then v-cifname = trim(trim(cif.prefix) + ' ' + trim(cif.name)).
              display v-cifname with frame frcor.
              repeat on endkey undo, return:
                  update s-LC with frame frcor.
                  s-lc = caps(s-lc).
                  find first LC where LC.LC = s-lc and lc.lc begins s-lcprod and LC.bank = s-ourbank and lookup(lc.lcsts,'FIN,CLS,CNL') > 0 no-lock no-error.
                  if not avail LC then run LChelp2('FIN,CLS,CNL').
                  find first LC where LC.LC = s-lc no-lock no-error.
                  if avail LC then do:
                       v-cif = LC.cif.
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
                 /*учитываем суммы amendment*/
                 for each lcamendres where lcamendres.lc = s-lc and not com and (lcamendres.levC = 23 or lcamendres.levD = 23 or lcamendres.levC = 24 or lcamendres.levD = 24) and lcamendres.jh > 0 no-lock:
                     find first jh where jh.jh = lcamendres.jh no-lock no-error.
                     if not avail jh then next.
                     if lcamendres.levD = 23 or lcamendres.levD = 24 then v-lcsumcur = v-lcsumcur + lcamendres.amt.
                     if lcamendres.levC = 23 or lcamendres.levC = 24 then v-lcsumcur = v-lcsumcur - lcamendres.amt.
                 end.
                 /*учитываем суммы payment*/
                 for each lcpayres where lcpayres.lc = s-lc and (lcpayres.levC = 23 or lcpayres.levC = 24 or lcpayres.dacc = '655561' or lcpayres.dacc = '655562') and lcpayres.jh > 0 no-lock:
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
                 find last lcamendh where lcamendh.bank = s-ourbank and lcamendh.lc = s-lc and lcamendh.kritcode = 'NewDtEx' and lcamendh.value1 ne '' no-lock no-error.
                 if avail lcamendh then v-lcdtexp = date(lcamendh.value1).
                 display v-lcdtexp with frame frcor.
              end. "
 &postfind = " if avail LC then v-lcsts = LC.LCsts.
               display v-lcsts with frame frcor.
               do on error undo,return on endkey undo, return:
                  find first lcswt where LCswt.lc = s-lc and Lcswt.mt = 'O799' use-index LCmt no-lock no-error.
                  if not avail LCswt
                  then message 'No incoming correspondence for this LC!' view-as alert-box error.
                  else do:
                    if can-find(first LCswt where LCswt.lc = s-lc and Lcswt.mt = 'O799' and LCswt.lccor = 0 and LCswt.sts = 'new')
                    then do:
                        message 'Do you want to see a new Correspondence?' VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE ' QUESTION !' update v-yes.
                        display v-cif v-cifname s-lc v-lcsts v-lcerrdes s-lccor with frame frcor.
                        if v-yes then do:
                            find last LCswt where LCswt.lc = s-lc and Lcswt.mt = 'O799' and LCswt.lccor > 0 use-index LCmtcor no-lock no-error.
                            if avail LCswt then s-lccor = LCswt.lccor + 1.
                            else s-lccor = 1.
                            find first LCswt where LCswt.lc = s-lc and Lcswt.mt = 'O799' and LCswt.lccor = 0 and LCswt.sts = 'new' exclusive-lock no-error.
                            assign LCswt.lccor   = s-lccor
                                   lcswt.info[1] = g-ofc .
                            s-corsts = LCswt.sts.
                            display s-lccor s-corsts with frame frcor.
                            v-chose = yes.
                            find current LCswt no-lock no-error.
                        end.
                    end.
                    update s-lccor with frame frcor.
                    find first LCswt where LCswt.lc = s-lc and Lcswt.mt = 'O799' and LCswt.LCcor = s-lccor no-lock no-error.
                    if avail LCswt then do:
                        assign s-lccor = LCswt.lccor s-corsts = LCswt.sts v-chose = yes.
                        display s-lccor s-corsts with frame frcor.
                    end.
                  end.
                end. "
 &numprg = "xxx"
 &subprg = "lcin799"
 &end = " g-lang = v-lang. "
}

