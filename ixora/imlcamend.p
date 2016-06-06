/* imlcamend.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        изменения по импортным аккредитивам
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
        26/11/2010 galina
 * BASES
        BANK  COMM
 * CHANGES
        02/12/2010 galina - выводим только аккредитивы открытые в данном филиале
        09/12/2010 galina - выводим номер аккредитива заглавными буквами
        22/12/2010 Vera   - изменился frame framd (добавлено 1 новое поле)
        06/01/2011 Vera   - изменение в учете платежей
        17/01/2011 id00810 - перекомпиляция (изменения в mainlc.i)
        25/02/2011 id00810 - для всех импортных аккредитивов и гарантии
        12/05/2011 id00810 - изменения в учете сумм и Expiry Date
        24/05/2011 id00810 - изменение в определении v-lcerrdes
        28/06/2011 id00810 - возможность просмотра изменений по закрытым LC
        03/10/2011 id00810 - проверка лимита
        17/01/2012 id00810 - добавлена переменная - наименование филиала
        02/03/2012 id00810 - закомментирована проверка суммы лимита
*/
def new shared var v-cif      as char.
def new shared var v-cifname  as char.
def new shared var v-lcsts    as char.
def new shared var v-lcerrdes as char.
def new shared var v-find     as logi.
def new shared var s-lcamend  like lcamend.lcamend.
def new shared var s-amdsts   like lcamend.sts.
def new shared var v-lcsumcur as deci.
def new shared var v-lcsumorg as deci.
def new shared var v-lccrc1   as char.
def new shared var v-lccrc2   as char.
def new shared var v-lcdtexp  as date.
def new shared var s-namef    as char.
def     shared var s-lcprod   as char.

def var v-chose  as logi no-undo.
def var v-lang   as char no-undo.
def var v-yes    as logi no-undo.
def var v-lim    as deci no-undo.
def var v-numlim as int  no-undo.

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
                  find first LC where LC.LC = s-lc and LC.bank = s-ourbank and lookup(lc.lcsts,'FIN,CLS,CNL') > 0 no-lock no-error.
                  if not avail LC then run LChelp2('FIN,CLS,CLN').
                  find first LC where LC.LC = s-lc no-lock no-error.
                  if avail LC then do:
                       assign v-cif   = LC.cif
                              v-lcsts = LC.LCsts.
                       find cif where cif.cif = LC.cif no-lock no-error.
                       if avail cif then v-cifname = trim(trim(cif.prefix) + ' ' + trim(cif.name)).
                       display s-lc v-cifname v-cif v-lcsts with frame framd.
                       leave.
                  end.
              end.
              v-lcsumcur = 0.
              v-lcsumorg = 0.
              find first lch where lch.lc = s-lc and lch.kritcode = 'Amount' no-lock no-error.
              if avail lch and trim(lch.value1) <> '' then do:
                 v-lcsumcur = deci(lch.value1).
                 v-lcsumorg = deci(lch.value1).
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
                 /*учитываем суммы payment*/
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
              display v-lcsumcur v-lcsumorg with frame framd.
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
                 find last lcamendh where lcamendh.lc = s-lc and lcamendh.kritcode = 'NewDtEx' and lcamendh.value1 ne '' no-lock no-error.
                 if avail lcamendh then v-lcdtexp = date(lcamendh.value1).
                 display v-lcdtexp with frame framd.
              end. "
 &postfind = " if avail LC then v-lcsts = LC.LCsts.
               display v-lcsts with frame framd.
               do on error undo,return:
                    v-yes = no.
                    if v-lcsts = 'FIN' then
                    message 'Do you want to create a new Amendment?' VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE ' QUESTION !' update v-yes.
                    if not v-yes then do:
                        s-lcamend = 0.
                        update s-lcamend with frame framd.
                        find first LCamend where LCamend.lc = s-lc and LCamend.LCamend = s-lcamend no-lock no-error.
                        if avail LCamend then assign s-amdsts = LCamend.sts v-chose = yes.
                    end.
                    if v-yes then do transaction:
                        s-lcamend = 0.
                        find last lcamend where lcamend.lc = s-lc use-index LC no-lock no-error.
                        if avail lcamend then do:
                            if lcamend.sts <> 'FIN' then do:
                                message 'The status of last amendment (number ' + string(lcamend.lcamend) +  ') is not FIN, it is impossible to create new amendment!' view-as alert-box error.
                                v-yes = no.
                                s-lcamend = 0.
                                update s-lcamend with frame framd.
                                find first LCamend where LCamend.lc = s-lc and LCamend.LCamend = s-lcamend no-lock no-error.
                                if avail LCamend then assign s-amdsts = LCamend.sts v-chose = yes.
                            end.
                            else s-lcamend = lcamend.lcamend + 1.
                        end.
                        else  s-lcamend = 1.
                        /*if v-yes then do:
                            v-lim = 0.
                            find first lch where lch.lc = s-lc and lch.kritcode = 'NLim' no-lock no-error.
                            if avail lch and lch.value1 ne '' then do:
                                for each lclimitres where lclimitres.bank = s-ourbank and lclimitres.cif = v-cif and lclimitres.number = int(lch.value1) and lclimitres.jh > 0 no-lock.
                                    if substr(lclimitres.dacc,1,2) = '61' then v-lim = v-lim + lclimitres.amt.
                                    else v-lim = v-lim - lclimitres.amt.
                                end.
                                if v-lim  = 0 then do:
                                    message 'It is impossible to create a new Amendment! No limit available!' view-as alert-box error.
                                    v-yes = no.
                                end.
                            end.
                        end.*/
                        if v-yes then do:
                            create lcamend.
                            assign lcamend.lc = s-lc
                                   lcamend.lcamend = s-lcamend
                                   lcamend.bank = s-ourbank
                                   lcamend.sts = 'NEW'
                                   lcamend.rwho = g-ofc
                                   lcamend.rwhn = g-today.
                                   s-amdsts = 'NEW'.
                            display s-lcamend s-amdsts with frame framd.
                            v-chose = yes.
                       end.
                    end.
                end.
                if s-amdsts = 'Err' then do:
                   find first lcamendh where lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'Errdes' no-lock no-error.
                   if avail lcamendh then v-lcerrdes = lcamendh.value1.
                 end.
                 display  v-lcerrdes with frame framd.
            "
 &numprg = "xxx"
 &subprg = "imlcamd"
 &end = " g-lang = v-lang. "
}

