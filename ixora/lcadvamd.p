/* lcadvamd.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Advise of Amendment (EXLC,EXPG)
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
        06/05/2011 id00810
 * BASES
        BANK  COMM
 * CHANGES
    23/06/2011 id00810 - возможность просмотра событий по закрытым LC
    28/12/2011 id00810 - учет реквизита NewAmt
    17/01/2012 id00810 - добавлена переменная - наименование филиала
 */

def new shared var v-cif      as char.
def new shared var v-cifname  as char.
def new shared var v-lcsts    as char.
def new shared var v-lcerrdes as char.
def new shared var v-find     as logi.
def new shared var s-lcamend  like lcamend.lcamend.
def new shared var s-amdsts   like lcamend.sts.
def var v-chose as logi no-undo.
def var v-lang  as char no-undo.
def var v-yes   as logi no-undo.
def var v-fmt   as char no-undo.
def new shared var v-lcsumcur as deci.
def new shared var v-lcsumorg as deci.
def new shared var v-lccrc1   as char.
def new shared var v-lccrc2   as char.
def new shared var v-lcdtexp  as date.
def     shared var s-lcprod   as char.
def new shared var s-namef    as char.
def new shared var s-lccor    like lcswt.lccor.
def new shared var s-corsts   like lcswt.sts.
def var i        as int.
def var id-lcswt as recid.

def new shared temp-table t-mt700 no-undo
    field fname  as char
    field fvalue as char extent 100.

{LC.i "new"}
{mainheadlc.i &nm=s-lcprod }

find first txb where txb.bank = s-ourbank no-lock no-error.
if avail txb then s-namef =  caps(txb.name).

{mainlc.i
 &option     = "imlc"
 &head       = "LC"
 &headkey    = "LC"
 &framename  = "framd"
 &formname   = "LCamd"
 &lang       = " v-lang = g-lang. g-lang = 'US'. "
 &start      = "on 'end-error' of frame framd do: g-lang = v-lang. end."
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
              display s-namef with frame framd.
              update v-cif with frame framd.
              find cif where cif.cif = v-cif no-lock no-error.
              if avail cif then v-cifname = trim(trim(cif.prefix) + ' ' + trim(cif.name)).
              display v-cifname with frame framd.
              repeat on endkey undo, return:
                  update s-LC with frame framd.
                  s-lc = caps(s-lc).
                  find first LC where LC.LC = s-lc and LC.bank = s-ourbank and lookup(LC.LCsts,'FIN,CLS,CLN') > 0 no-lock no-error.
                  if not avail LC then run LChelp2('FIN,CLS,CLN').
                  find first LC where LC.LC = s-lc and LC.bank = s-ourbank no-lock no-error.
                  if avail LC then do:
                       v-cif = LC.cif.
                       v-lcsts = LC.LCsts.
                       find cif where cif.cif = LC.cif no-lock no-error.
                       if avail cif then v-cifname = trim(trim(cif.prefix) + ' ' + trim(cif.name)).
                       display s-lc v-cifname v-cif v-lcsts with frame framd.
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
                 find last lcamendh where lcamendh.bank = lc.bank and lcamendh.lc = s-lc and lcamendh.kritcode = 'NewAmt' and lcamendh.value1 ne '' no-lock no-error.
                 if avail lcamendh then v-lcsumcur = deci(replace(lcamendh.value1,',','.')).
              end.
              display v-lcsumorg v-lcsumcur with frame framd.
              v-lccrc1 = ''.
              find first lch where lch.lc = s-lc and lch.kritcode = 'lcCrc' no-lock no-error.
              if avail lch and trim(lch.value1) <> '' then do:
                find first crc where crc.crc = int(trim(lch.value1)) no-lock no-error.
                if avail crc then assign v-lccrc1 = crc.code v-lccrc2 = crc.code.
              end.
              display v-lccrc1 v-lccrc2 with frame framd.
              find first lch where lch.lc = s-lc and lch.kritcode = 'DtExp' no-lock no-error.
              if avail lch and lch.value1 <> ? then do:
                 v-lcdtexp = date(lch.value1).
                 find last lcamendh where lcamendh.bank = lc.bank and lcamendh.lc = s-lc and lcamendh.kritcode = 'NewDtEx' and lcamendh.value1 ne '' no-lock no-error.
                 if avail lcamendh then v-lcdtexp = date(lcamendh.value1).
                 display v-lcdtexp with frame framd.
              end. "
 &postfind = " if avail LC then v-lcsts = LC.LCsts.
               display v-lcsts  with frame framd.
               v-fmt = if s-lcprod = 'exlc' then '707' else '767'.
               v-yes = no.
               if v-lcsts = 'FIN' then
               message 'Do you want to advise a new Amendment?' VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE ' QUESTION !' update v-yes.
               if v-yes then do on error undo,return:
                  find first lcswt where LCswt.lc = s-lc and Lcswt.mt = 'O' + v-fmt and lcswt.lccor = 0 and lcswt.sts = 'new' no-lock no-error.
                  if not avail lcswt then message 'You have no new ' + v-fmt  + '. Do you want to advice new Amendment without MT?' VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE ' QUESTION !' update v-yes.
                  if v-yes then do transaction:
                      s-lcamend = 0.
                      find last lcamend where lcamend.lc = s-lc use-index LC no-lock no-error.
                      if avail lcamend then do:
                        if lcamend.sts <> 'FIN' then do:
                            message 'The status of last amendment (number ' + string(lcamend.lcamend) +  ') is not FIN, it is impossible to advice new amendment!' view-as alert-box error.
                            v-yes = no.
                            leave.
                        end.
                        s-lcamend = lcamend.lcamend + 1.
                      end.
                      else s-lcamend = 1.
                      create lcamend.
                      assign lcamend.lc      = s-lc
                             lcamend.lcamend = s-lcamend
                             lcamend.bank    = s-ourbank
                             lcamend.sts     = 'NEW'
                             lcamend.rwho    = g-ofc
                             lcamend.rwhn    = g-today.
                             s-amdsts = 'NEW'.
                      if avail lcswt then do:
                          find current lcswt exclusive-lock.
                          lcswt.lccor = s-lcamend.
                          find current lcswt no-lock no-error.
                          id-lcswt = recid(LCswt).
                          run i-mt700.p (id-lcswt).
                          for each t-mt700 no-lock:
                              create lcamendh.
                              assign lcamendh.lc       = lc.lc
                                     lcamendh.lcamend  = s-lcamend
                                     lcamendh.kritcode = t-mt700.fname
                                     lcamendh.bank     = s-ourbank.
                              i = 1.
                              do while t-mt700.fvalue[i] ne ''.
                                  lcamendh.value1   = lcamendh.value1 + t-mt700.fvalue[i] + ' ' + chr(1).
                                  i = i + 1.
                              end.
                              lcamendh.value1 = substr(lcamendh.value1,1,length(lcamendh.value1) - 2).
                          end.
                          find first lcamendh where lcamendh.bank = lc.bank and lcamendh.lc = lc.lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'fname2' no-lock no-error.
                          if avail lcamendh then do:
                              find first LCswt where recid(lcswt) = id-lcswt exclusive-lock no-error.
                              if avail LCswt then do:
                                  assign  lcswt.sts = 'FIN'
                                          lcswt.dt  = g-today.
                                  find current LCswt no-lock no-error.
                              end.
                          end.
                      end.
                     display s-lcamend s-amdsts with frame framd.
                     v-chose = yes.
                  end.
               end.
               if not v-yes then do:
                   s-lcamend = 0.
                   update s-lcamend with frame framd.
                   find first LCamend where LCamend.lc = s-lc and LCamend.LCamend = s-lcamend no-lock no-error.
                   if avail LCamend then assign s-amdsts = LCamend.sts v-chose = yes.
                end.
                find first lcamendh where lcamendh.bank = lc.bank and lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'lccor' no-lock no-error.
                if not avail lcamendh then do:
                    find last LCswt where LCswt.LC = s-LC and LCswt.mt = 'I799' and lcswt.sts = 'fin' no-lock no-error.
                    if avail lcswt then s-lccor = lcswt.lccor + 1.
                    else s-lccor = 1.
                    s-corsts = 'new'.
                end.
                else do:
                    s-lccor = int(lcamendh.value1).
                    find first LCswt where LCswt.LC = s-LC and LCswt.mt = 'I799' and lcswt.lccor = s-lccor no-lock no-error.
                    if avail lcswt then s-corsts = lcswt.sts.
                end.
                if s-amdsts = 'Err' then do:
                    find first lcamendh where lcamendh.bank = lc.bank and lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'Errdes' no-lock no-error.
                    if avail lcamendh then v-lcerrdes = lcamendh.value1.
                end.
                display  v-lcerrdes with frame framd. "
 &numprg = "xxx"
 &subprg = "lcadv"
 &end = " g-lang = v-lang. "
}

