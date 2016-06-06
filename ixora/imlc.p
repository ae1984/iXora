/* imlc.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        импортный аккредитив
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
        09/09/2010 galina
 * BASES
        BANK  COMM
 * CHANGES
        25/11/2010 galina - перекомпиляция
        26/11/2010 galina - не открываем новый аккредитива без клиента
        02/12/2010 galina - выводим только аккредитивы открытые в данном филиале
        09/12/2010 galina - выводим номер аккредитива заглавными буквами
        14/12/2010 Vera   - перекомпиляция (изменен mainlc.i)
        21/12/2010 Vera   - изменился frame frlc (добавлено 3 новых поля)
        05/01/2011 Vera   - обновление переменных фрейма
        06/01/2011 Vera   - изменение в учете платежей
        17/01/2011 id00810 - перекомпиляция (изменения в mainlc.i)
        19/01/2011 id00810 - вид продукта s-lcprod
        20/04/2011 id00810 - добавлено объявление 2-х переменных s-lccor,s-corsts, изменение в учете платежей, в учете Expiry Date
        19/07/2011 id00810 - учет параметра 'PerAmt', изменение в заголовке формы (s-ftitle)
        15/08/2011 id00810 - добавлено MT720
        14/09/2011 id00810 - добавлено в &prefind: v-lcerrdes = ''
        28/09/2011 id00810 - проверка лимита
        17/01/2012 id00810 - добавлены переменные: наименование филиала, формат сообщения
        18.11.2013 Lyubov  - ТЗ 2125, добавила obligation validity
*/

{LC.i "new"}
{mainhead.i IMLC}

def new shared var v-cif      as char.
def new shared var v-cifname  as char.
def new shared var v-lcsts    as char.
def new shared var v-lcerrdes as char.
def new shared var v-find     as logi.
def new shared var v-lcsumcur as deci.
def new shared var v-lcsumorg as deci.
def new shared var v-lccrc1   as char.
def new shared var v-lccrc2   as char.
def new shared var v-lcdtexp  as date.
def new shared var v-oblval   as date.
def new shared var s-lcprod   as char.
def new shared var s-lccor    like lcswt.lccor.
def new shared var s-corsts   like lcswt.sts.
def new shared var s-ftitle   as char init ' LETTER OF CREDIT '.
def new shared var s-namef    as char.
def new shared var s-fmt      as char.
def var v-chose  as logi no-undo.
def var v-chose1 as logi no-undo.
def var v-lang   as char no-undo.
def var v-per    as int  no-undo.
def var v-lim    as deci no-undo.
def var v-numlim as int  no-undo.

find first txb where txb.bank = s-ourbank no-lock no-error.
if avail txb then s-namef =  caps(txb.name).
s-lcprod = 'imlc'.

{mainlc.i
 &option     = "imlc"
 &head       = "LC"
 &headkey    = "LC"
 &framename  = "frlc"
 &formname   = "LC1"
 &lang       = " v-lang = g-lang. g-lang = 'US'. "
 &start      = "on 'end-error' of frame frlc do: g-lang = v-lang. end."
 &langend    = "  "
 &findcon    = "true"
 &addcon     = "true"
 &cond       = " "
 &start      = " "
 &clearframe = " "
 &viewframe  = " "
 &preadd     = " assign v-cif      = ''
                        v-find     = no
                        v-lcsumcur = 0
                        v-lcsumorg = 0
                        v-lccrc1   = ''
                        v-lccrc2   = ''
                        v-lcdtexp  = ?
                        v-oblval   = ?
                        v-numlim   = 0
                        s-fmt      = ''.
                display s-namef with frame frlc.
                do on error undo,return:
                    update  v-cif with frame frlc.
                    find cif where cif.cif = v-cif no-lock no-error.
                    if avail cif then v-cifname = trim(trim(cif.prefix) + ' ' + trim(cif.name)).
                    display v-cifname with frame frlc.
                    message 'Do you want to create a new Letter of Credit?' VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE ' ATTENTION !'
                    update v-chose.
                end. "
 &presubprg = "if v-chose then "
 &postadd = " assign LC.cif    = v-cif
                     LC.LCsts  = 'NEW'
                     LC.bank   = s-ourbank
                     LC.LCtype = 'I'
                     LC.rwho   = g-ofc
                     LC.rwhn   = g-today.
              find current LC no-lock no-error.
              v-lcsts = LC.LCsts.
              display v-lcsts with frame frlc.
              update s-fmt with frame frlc.
              find first codfr where codfr.codfr = 'lc' + s-lcprod + 'f' and codfr.code = s-fmt no-lock no-error.
              if avail codfr then do:
                s-fmt = codfr.code.
                display s-fmt with frame frlc.
                create lch.
                assign lch.lc       = s-lc
                       lch.bank     = s-ourbank
                       lch.kritcode = 'fmt'
                       lch.value1   = s-fmt.
              end. "
 &prefind = " assign v-find     = yes
                     v-cif      = ''
                     v-cifname  = ''
                     v-lcsts    = ''
                     v-lcerrdes = ''
                     s-lc       = ''
                     s-fmt      = ''.
              display s-namef with frame frlc.
              update v-cif with frame frlc.
              find cif where cif.cif = v-cif no-lock no-error.
              if avail cif then v-cifname = trim(trim(cif.prefix) + ' ' + trim(cif.name)).
              display v-cifname with frame frlc.

              repeat on endkey undo, return:
               update s-LC with frame frlc.
               s-lc = caps(s-lc).
               find first LC where LC.LC = s-lc and lc.bank = s-ourbank and lc.lc begins s-lcprod no-lock no-error.
               if not avail LC then run LChelp.
               find first LC where LC.LC = s-lc no-lock no-error.
               if avail LC then do:
                   assign v-cif   = LC.cif
                          v-lcsts = LC.LCsts.
                   find cif where cif.cif = LC.cif no-lock no-error.
                   if avail cif then v-cifname = trim(trim(cif.prefix) + ' ' + trim(cif.name)).
                   display s-lc v-cifname v-cif v-lcsts with frame frlc.
                   v-chose = yes.
                   leave.
               end.
              end.
              find first LC where LC.LC = s-lc no-lock no-error.
              v-lcsumcur = 0.
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
                 /*учитываем суммы amendment*/
                 for each lcamendres where lcamendres.lc = s-lc and (lcamendres.levC = 23 or lcamendres.levD = 23 or lcamendres.levC = 24 or lcamendres.levD = 24) and lcamendres.jh > 0 no-lock:
                     find first jh where jh.jh = lcamendres.jh no-lock no-error.
                     if not avail jh then next.

                     if lcamendres.levD = 23 or lcamendres.levD = 24 then v-lcsumcur = v-lcsumcur + lcamendres.amt.
                     if lcamendres.levC = 23 or lcamendres.levC = 24 then v-lcsumcur = v-lcsumcur - lcamendres.amt.
                 end.
                  if lc.lcsts = 'cls' or lc.lcsts = 'cnl' then v-lcsumcur = 0.
                 else do:
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
                 find last lcamendh where lcamendh.lc = s-lc and lcamendh.kritcode = 'NewDtEx' and lcamendh.value1 ne '' no-lock no-error.
                 if avail lcamendh then v-lcdtexp = date(lcamendh.value1).
                 display v-lcdtexp with frame frlc.
              end.
              find first lch where lch.lc = s-lc and lch.kritcode = 'OblValid' no-lock no-error.
              if avail lch and lch.value1 <> ? then do:
                 v-oblval = date(lch.value1).
                 display v-oblval with frame frlc.
              end.
                "
 &postfind = " if avail LC then v-lcsts = LC.LCsts.
               if v-lcsts = 'Err' then do:
                   find first lch where lch.lc = s-lc and lch.kritcode = 'Errdes' no-lock no-error.
                   if avail lch then v-lcerrdes = lch.value1.
               end.
               find first lch where lch.lc = s-lc and lch.kritcode = 'fmt' no-lock no-error.
               if avail lch then s-fmt = lch.value1.
               display v-lcsts s-fmt v-lcerrdes with frame frlc."

 &numprg = "imlccre"
 &subprg = "imlcedt"
 &end = " g-lang = v-lang. "
}