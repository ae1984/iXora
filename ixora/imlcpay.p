/* imlcpay.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        оплата импортного аккредитива
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
        24/11/2010 galina
 * BASES
        BANK  COMM
 * CHANGES
    25/11/2010 galina - учитываем увеличения и уменьшения суммы amendment
    09/12/2010 galina - выводим номер аккредитива заглавными буквами
    22/12/2010 Vera   - изменился frame frpay (добавлено 1 новое поле)
    06/01/2011 Vera   - изменение в учете платежей
    17/01/2011 id00810 - перекомпиляция (изменения в mainlc.i)
    25/02/2011 id00810 - для  SBLC
    30/05/2011 id00810 - проверка наличия незаконченных событий (payment)
    21/06/2011 id00810 - возможность просмотра платежей по закрытым LC
    03/08/2011 id00810 - обработка статуса ErrA
    17/01/2012 id00810 - добавлена переменная - наименование филиала
    09/04/2012 id00810 - изменение в расчете текущей суммы для PG (изменились счета)
    22.11.2012 Lyubov  - исправлено вычисление текущей суммы
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
def var v-per    as int  no-undo.

{LC.i "new"}
{mainheadlc.i &nm=s-lcprod }

find first txb where txb.bank = s-ourbank no-lock no-error.
if avail txb then s-namef =  caps(txb.name).

{mainlc.i
 &option     = "imlc"
 &head       = "LC"
 &headkey    = "LC"
 &framename  = "frpay"
 &formname   = "LCpay"
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
                  update s-LC with frame frpay.
                  s-lc = caps(s-lc).
                  find first LC where LC.LC = s-lc and lc.lc begins s-lcprod and LC.bank = s-ourbank and lookup(LC.LCsts,'FIN,CLS,CNL') > 0 no-lock no-error.
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
                 if s-lcprod = 'pg' then do:
                     find first lch where lch.lc = lc.lc and lch.kritcode = 'peramt' no-lock no-error.
                     if avail lch and lch.value1 ne '' then do:
                        v-per = int(entry(1,lch.value1, '/')).
                        if v-per > 0 then assign v-lcsumorg = v-lcsumorg + (v-lcsumorg * (v-per / 100))
                                                 v-lcsumcur = v-lcsumorg.
                     end.
                     for each lcamendres where lcamendres.lc = s-lc and not lcamendres.com and lcamendres.levD = 1 and can-do('605561,655561,605562,655562',lcamendres.dacc) and lcamendres.jh > 0 no-lock:
                         find first jh where jh.jh = lcamendres.jh no-lock no-error.
                         if not avail jh then next.
                         if lcamendres.dacc = '605561' or lcamendres.dacc = '605562' then v-lcsumcur = v-lcsumcur + lcamendres.amt.
                         else v-lcsumcur = v-lcsumcur - lcamendres.amt.
                     end.
                     for each lcpayres where lcpayres.lc = s-lc and not lcpayres.com and lcpayres.levC = 1 and can-do('605561,605562',lcpayres.cacc) and lcpayres.jh > 0 no-lock:
                         find first jh where jh.jh = lcpayres.jh no-lock no-error.
                         if not avail jh then next.
                         v-lcsumcur = v-lcsumcur - lcpayres.amt.
                     end.
                     for each lceventres where lceventres.lc = s-lc and not lceventres.com and lceventres.levC = 1 and can-do('605561,605562',lceventres.cacc) and lceventres.jh > 0 no-lock:
                         find first jh where jh.jh = lceventres.jh no-lock no-error.
                         if not avail jh then next.
                         v-lcsumcur = v-lcsumcur - lceventres.amt.
                     end.
                end.
                else do:
                     find first lch where lch.lc = lc.lc and lch.kritcode = 'peramt' no-lock no-error.
                     if avail lch and lch.value1 ne '' then do:
                        v-per = int(entry(1,lch.value1, '/')).
                        if v-per > 0 then assign v-lcsumorg = v-lcsumorg + (v-lcsumorg * (v-per / 100))
                                                 v-lcsumcur = v-lcsumorg.
                     end.
                     for each lcamendres where lcamendres.lc = s-lc and not lcamendres.com and lcamendres.levC = 1 and can-do('652000,650510',lcamendres.cacc) and lcamendres.jh > 0 no-lock:
                         find first jh where jh.jh = lcamendres.jh no-lock no-error.
                         if not avail jh then next.
                         v-lcsumcur = v-lcsumcur + lcamendres.amt.
                     end.
                     for each lcamendres where lcamendres.lc = s-lc and not lcamendres.com and lcamendres.levD = 1 and can-do('652000,650510',lcamendres.dacc) and lcamendres.jh > 0 no-lock:
                         find first jh where jh.jh = lcamendres.jh no-lock no-error.
                         if not avail jh then next.
                         v-lcsumcur = v-lcsumcur - lcamendres.amt.
                     end.
                     for each lcpayres where lcpayres.lc = s-lc and not lcpayres.com and lcpayres.levD = 1 and can-do('652000,650510',lcpayres.dacc) and lcpayres.jh > 0 no-lock:
                         find first jh where jh.jh = lcpayres.jh no-lock no-error.
                         if not avail jh then next.
                         v-lcsumcur = v-lcsumcur - lcpayres.amt.
                     end.
                    for each lceventres where lceventres.lc = s-lc and not lceventres.com and lceventres.levD = 1 and can-do('652000,650510',lceventres.dacc) and lceventres.jh > 0 no-lock:
                        find first jh where jh.jh = lceventres.jh no-lock no-error.
                        if not avail jh then next.
                        v-lcsumcur = v-lcsumcur - lceventres.amt.
                    end.
                end.
                 /*учитываем увеличения и уменьшения суммы amendment*/
                /* for each lcamendres where lcamendres.lc = s-lc and (lcamendres.levC = 23 or lcamendres.levD = 23 or lcamendres.levC = 24 or lcamendres.levD = 24) and lcamendres.jh > 0 no-lock:
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
 &subprg = "imlcpayedt"
 &end = " g-lang = v-lang. "
}
