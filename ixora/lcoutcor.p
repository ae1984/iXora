/* lcoutcor.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Корреспонденция - исходящий свифт
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
        31/01/2011 evseev
 * BASES
        BANK  COMM
 * CHANGES
    18/02/2011 id00810 - для всех продуктов
    13/05/2011 id00810 - изменение в учете сумм, DtExp
    24/06/2011 id00810 - возможность просмотра события по закрытым LC
    21/11/2011 id00810 - сохраним для истории информацию о пользователе
    28/12/2011 id00810 - учет реквизита NewAmt для экспортных аккредитивов,
                         запрет на создание нового сообщения, если статус пред.сообщения не окончательный
    17/01/2012 id00810 - добавлена переменная - наименование филиала
    05.03.2012 Lyubov  - убрана кнопка Add, переделаны функции поиска и создания записи, добавлена обработка разных форматов сообщений
    12.03.2012 Lyubov  - добавлен формат 499, параметры при вызове поиска
    15.03.2012 Lyubov  - убрала переменную s-countO799

 */
/* стр 252 - учитываем увеличение и уменьшение суммы amendment
   стр 266 - учитываем суммы payment
   стр 271 - учитываем суммы event */

def new shared var v-cif       as char.
def new shared var v-cifname   as char.
def new shared var v-lcsts     as char.
def new shared var v-lcerrdes  as char.
def new shared var v-find      as logi.
def new shared var s-lccor     like lcswt.lccor.
def new shared var s-corsts    like lcswt.sts.
def new shared var s-lcamend   like lcamend.lcamend.
def var v-chose as logi no-undo.
def var v-lang  as char no-undo.
def var v-yes   as logi no-undo.
def var v-per   as int  no-undo.
def var v-sp    as char no-undo.
def new shared var v-lcsumcur as deci.
def new shared var v-lcsumorg as deci.
def new shared var v-lccrc1   as char.
def new shared var v-lccrc2   as char.
def new shared var v-lcdtexp  as date.
def     shared var s-lcprod   as char.
def new shared var s-namef    as char.
def     shared var s-mt       as inte.

def var v-str as char.
v-str = 'I' + string(s-mt).
v-sp = if s-mt = 499 then 'idc.odc' else '*'.
{LC.i "new"}
{mainheadlc.i &nm=s-lcprod}

find first txb where txb.bank = s-ourbank no-lock no-error.
if avail txb then s-namef =  caps(txb.name).

{mainlc.i
 &option     = "imlc"
 &head       = "LCswt"
 &headkey    = "LC"
 &framename  = "frcor"
 &formname   = "LCoutcor"
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
 &prefind = " assign v-find    = yes
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
                  if s-lcprod ne '' then
                  find first LC where LC.LC = s-lc and lc.lc begins s-lcprod and LC.bank = s-ourbank and lookup(lc.lcsts,'FIN,CLS,CNL') > 0 no-lock no-error.
                  else find first LC where LC.LC = s-lc and can-do(v-sp,substr(lc.lc,1,index(lc.lc,'0') - 1)) and LC.bank = s-ourbank and lookup(lc.lcsts,'FIN,CLS,CNL') > 0 no-lock no-error.
                  if not avail LC then do:
                        s-lc = ''.
                       if s-mt = 799 then run LChelp2('FIN,CLS,CNL').
                       else do: if s-mt = 999 then run lchelp5('FIN,CLS,CNL','*').
                                else run lchelp5('FIN,CLS,CNL','idc,odc').
                       end.
                  end.
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
              s-lcprod = substr(lc.lc,1,index(lc.lc,'0') - 1).
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
                 for each lcpayres where lcpayres.lc = s-lc and (lcpayres.levC = 23 or lcpayres.levC = 24 or lcpayres.dacc = '655561' or lcpayres.dacc = '655562') and lcpayres.jh > 0 no-lock:
                     find first jh where jh.jh = lcpayres.jh no-lock no-error.
                     if avail jh then v-lcsumcur = v-lcsumcur - lcpayres.amt.
                 end.
                 for each lceventres where lceventres.lc = s-lc and (lceventres.levC = 23 or lceventres.levC = 24 or lceventres.dacc = '655561' or lceventres.dacc = '655562') and lceventres.jh > 0 no-lock:
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
               do on error undo,return:
                    v-yes = no.
                    if v-lcsts = 'FIN' then
                    message 'Do you want to create a new Correspondence?' VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE ' QUESTION !' update v-yes.
                    display v-cif v-cifname s-lc v-lcsts s-lccor with frame frcor.
                    if not v-yes then do:
                        find last LCswt where LCswt.lc = s-lc and Lcswt.mt = v-str no-lock no-error.
                        if not avail lcswt then do:
                            message 'There is no outgoing correspondence for ' + s-lc + '!' view-as alert-box error.
                            leave.
                        end.
                        s-lccor = lcswt.lccor.
                        update s-lccor with frame frcor.
                        find first LCswt where LCswt.lc = s-lc and Lcswt.mt = v-str and LCswt.LCcor = s-lccor no-lock no-error.
                        if avail LCswt then assign s-lccor = LCswt.lccor s-corsts = LCswt.sts v-chose = yes.
                    end.
                    if v-yes then do transaction:
                        s-lccor = 0.
                        find last LCswt where LCswt.LC = s-LC and LCswt.mt = v-str no-lock no-error.
                        if avail lcswt then do:
                            if lcswt.sts ne 'fin' then do:
                                message 'The status of last outgoing correspondence (number ' + string(lcswt.lccor) +  ') is not FIN, it is impossible to create new correspondence!' view-as alert-box error.
                                v-yes = no.
                                s-lccor = lcswt.lccor.
                                update s-lccor with frame frcor.
                                find first LCswt where LCswt.lc = s-lc and Lcswt.mt = v-str and LCswt.LCcor = s-lccor no-lock no-error.
                                if avail LCswt then assign s-lccor = LCswt.lccor s-corsts = LCswt.sts v-chose = yes.
                            end.
                            else s-lccor = lcswt.lccor + 1.
                        end.
                        else s-lccor = 1.
                        if v-yes then do:
                            s-corsts = 'NEW'.
                            create lcswt.
                            assign lcswt.lc = s-lc
                                   LCswt.LCtype = LC.LCtype
                                   LCswt.ref    = s-LC
                                   LCswt.sts    = 'NEW'
                                   LCswt.fname2 = v-str + replace(trim(s-LC),'/','-') + '_' + string(s-lccor,'99999')
                                   LCswt.mt     = v-str
                                   LCswt.rdt    = g-today
                                   LCswt.LCcor  = s-lccor
                                   lcswt.info[1]= g-ofc.
                            display s-lccor s-corsts with frame frcor.
                           v-chose = yes.
                       end.
                    end.
                end. "
 &numprg = "xxx"
 &subprg = "lcout799"
 &end = " g-lang = v-lang. "
}
