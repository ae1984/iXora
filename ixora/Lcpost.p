/* LCpost.p
 * MODULE
        Аккредитив
 * DESCRIPTION
        Вывод проводок, события create, advise
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        14.1.1
 * AUTHOR
       09/09/2010 aigul
 * BASES
        BANK COMM
 * CHANGES
        23/09/2010 galina - поменяла формат ввода поля 39:A (Percent Credit Amount Tolerance)
        07/10/2010 galina- выводим описание кода комиссии
        11/10/2010 galina - для проверки баланса учитываем только сумму покрытия
        14/10/2010 galina - перекомпиляция
        25/11/2010 galina - проверка баланса только по невыпущенным аккредитивам
        13/12/2010 vera   - назначение платежа
        27/12/2010 Vera   - исправлена ошибка в назначении платежа
        20/01/2011 id00810 - для всех аккредитивов
        27/01/2011 id00810 - для импортной гарантии другие счета
        20/04/2011 id00810 - для резервного аккредитива SBLC
        19/07/2011 id00810 - поле ComAcc для EXPG может быть не заполнено (комиссий нет, постингов нет)
        29/07/2011 id00810 - счет DepAcc вместо 285521 для покрытого PG (c 01/08/2011)
        04/08/2011 id00810 - исправлена ошибка в определении счета ГК
        08/08/2011 id00810 - исправлена ошибка в определениии v-levD для непокрытых аккредитивов
        15/08/2011 id00810 - изменения в связи с MT720
        29/09/2011 id00810 - проводки по лимиту
        12/01/2012 id00810 - не надо заново считать сумму списания лимита, если есть lclimitres
        17/01/2012 id00810 - добавлена новая переменная s-fmt
        30/01/2011 id00810 - изменение в назначении платежа для комиссий
        06/06/2012 Lyubov  - добавила КОД, КБЕ, КНП
        21.06.2012 Lyubov  - проводки по PG\EXPG образуются иначе 220310 -> 286920, 286920 -> 4612(20\11)
        23.08.2012 Lyubov  - MetroComBank исправила на ForteBank
        06.02.2013 dmitriy - Partial Covered
        14.03.2013 Lyubov  - ТЗ №1726, изменила счет для 966 комиссии с 285532 на 286931
*/

{global.i}
define stream m-out.
def shared var s-lc      as char.
def shared var v-lcsts   as char.
def shared var s-lcprod  as char.
def shared var s-ourbank as char no-undo.
def shared var v-cif     as char.
def shared var v-cifname as char.
def shared var s-fmt     as char.

def var v-lccow     as char no-undo.
def var v-collacc   as char no-undo.
def var v-comacc    as char no-undo.
def var v-depacc    as char no-undo.
def var v-crc       as int  no-undo.
def var v-amount    as char no-undo.
def var v-exabout   as char no-undo.
def var v-lc-amount as deci no-undo.
def var v-per       as deci no-undo.
def var v-sum       as deci no-undo.
def var v-sum1      as deci no-undo.
def var v-sum2      as deci no-undo.
def var v-levD      as int  no-undo.
def var v-levC      as int  no-undo.
def var i           as int  no-undo.
def var k           as int  no-undo.
def var v-date      as date no-undo init 08/01/2011.
def var v-yes       as logi no-undo.
def var v-gar       as logi no-undo.
def var v-720       as logi no-undo.
def var v-numlim    as int  no-undo.
def var v-revolv    as char no-undo.
def var v-dacc      as char no-undo init '662530'.
def var v-cacc      as char no-undo init '612530'.
def var v-text      as char no-undo init 'возобновляемым'.
def var v-logsno    as char init "no,n,нет,н,1".
def var v-lim-amount as deci no-undo.
def var v-limcrc     as int  no-undo.
def var v-forcon     as logi no-undo.
def var v-covAmt    as deci no-undo.
def var v-uncovAmt  as deci no-undo.
def buffer b-crc for crc.

find first lc where lc.lc = s-lc no-lock no-error.
if not avail lc then return.
if s-lcprod = 'pg' then do:
    v-gar = yes.
    find first lch where lch.lc = s-lc and lch.kritcode = 'ForCon' and lch.value1 = "yes" no-lock no-error.
    if avail lch and lch.value1 = 'yes' then v-forcon = yes.
end.

if s-lcprod = 'imlc' and s-fmt = '720' then  v-720 = yes.
if not v-720 then do:
    find first lch where lch.lc = s-lc and lch.kritcode = 'Cover' no-lock no-error.
    if avail lch then v-lccow = lch.value1.
    if v-lccow = '' then do:
        message "Field Covered/uncovered is empty!" view-as alert-box.
        return.
    end.

    find first lch where lch.lc = s-lc and lch.kritcode = 'NLim' no-lock no-error.
    if avail lch then v-numlim = int(lch.value1).

    find first lch where lch.lc = s-lc and lch.kritcode = 'CovAmt' no-lock no-error.
    if avail lch then v-covAmt = int(lch.value1).

    find first lch where lch.lc = s-lc and lch.kritcode = 'UncAmt' no-lock no-error.
    if avail lch then v-uncovAmt = int(lch.value1).

    if v-lccow = '0' or v-lccow = '2' then do:
        find first lch where lch.lc = s-lc and lch.kritcode = 'CollACC' no-lock no-error.
        if avail lch then v-collacc = lch.value1.
        if v-collacc = '' then do:
            message "Field CollAcc is empty!" view-as alert-box.
            return.
        end.

        if v-gar then do:
            find first lch where lch.lc = s-lc and lch.kritcode = 'Date' no-lock no-error.
            if avail lch then do:
                if date(lch.value1) < v-date  then v-yes = yes.
                else do:
                    find first lch where lch.lc = s-lc and lch.kritcode = 'DepAcc' no-lock no-error.
                    if avail lch then v-depacc = lch.value1.
                    if v-depacc = '' then do:
                        message "Field Collateral Deposit Accout is empty!" view-as alert-box.
                        return.
                    end.
                end.
            end.
        end.
    end.
end.

find first lch where lch.lc = s-lc and lch.kritcode = 'ComAcc' no-lock no-error.
if avail lch then v-comacc = lch.value1.
if v-comacc = '' then do:
    if s-lcprod <> 'expg' and not v-forcon then do:
        message "Field ComAcc is empty!" view-as alert-box.
        return.
    end.
end.

find first lch where lch.lc = s-lc and lch.kritcode = 'Amount' no-lock no-error.
if avail lch then v-amount = lch.value1.
if v-amount = '' then do:
    message "Field Amount is empty!" view-as alert-box.
    return.
end.
if lc.lctype = 'I' and not v-720 then do:
    find first lch where lch.lc = s-lc and lch.kritcode = 'ExAbout' no-lock no-error.
    if avail lch then v-exabout = lch.value1.
    if v-exabout = '' then do:
        message "Field ExAbout is empty!" view-as alert-box.
        return.
    end.

    if lch.value1 = '1' then do:
        v-per = 0.
        find first lch where lch.lc = s-lc and kritcode = 'PerAmt' no-lock no-error.
        if avail lch and trim(lch.value1) <> '' then do:
            v-per = int(entry(1,lch.value1, '/')).

            if v-per > 0 then do:
                find first lch where lch.lc = s-lc and kritcode = 'Amount' no-lock no-error.
                if avail lch then v-lc-amount = decimal(lch.value1) + (decimal(lch.value1) * (v-per / 100)).
                v-covAmt = v-covAmt + (v-covAmt * (v-per / 100)).
                v-uncovAmt = v-uncovAmt + (v-uncovAmt * (v-per / 100)).
            end.
            if v-per <= 0 then do:
                find first lch where lch.lc = s-lc and kritcode = 'Amount' no-lock no-error.
                if avail lch then v-lc-amount = decimal(lch.value1).
            end.
        end.
        else do:
            message "Field PerAmt is empty!" view-as alert-box.
            return.
        end.
    end.
    if lch.value1 = '0' then do:
        find first lch where lch.lc = s-lc and kritcode = 'Amount' no-lock no-error.
        if avail lch then v-lc-amount = decimal(lch.value1).
    end.
end.
find first lch where lch.lc = s-lc and lch.kritcode = 'lcCrc' no-lock no-error.
v-crc = int(lch.value1).

find first crc where crc.crc = v-crc no-lock no-error.
if not avail crc then return.

def temp-table wrk
    field num    as int
    field numdis as char
    field dc     as char
    field gldes  as char
    field rem    as char
    field jdt    as date
    field acc    as char
    field gl     as int
    field sum    as deci
    field cur    as char
    field kkk    as char
    index ind1 is primary num.

define query qt for wrk.
define browse bt query qt
    displ wrk.numdis label "№"          format "x(3)"
          wrk.dc     label "Dt/Ct"      format "x(2)"
          wrk.acc    label "Client Acc" format "x(20)"
          wrk.gl     label "Ledger Acc" format "999999"
          wrk.gldes  label "Ledger Account  Description" format "x(30)"
          wrk.sum    label "Amount"     format ">>>,>>>,>>9.99"
          wrk.cur    label "CCY"        format "x(3)"
          wrk.jdt    label "Value Dt"   format "99/99/99"
          wrk.rem    label "Narrative"  format "x(30)"
          wrk.kkk    label "KOD,KBE,KNP" format "x(15)"
          with width 115 row 8 15 down overlay no-label title "Postings" NO-ASSIGN SEPARATORS.

def button btn-e   label  " Print in Excel  ".

DEFINE FRAME ft
    bt   SKIP(1)
    btn-e SKIP
    WITH width 115 1 COLUMN SIDE-LABELS
    NO-BOX.

on "end-error" of frame ft do:
    hide frame ft no-pause.
end.
k = 0.

/*Covered*/
if lc.lctype = 'I' and not v-720 then do:
    if v-lccow = '0' then do:
        /*1-st posting*/
        i = 1.
        if v-yes then find first lcres where lcres.LC = s-lc and not lcres.com and lcres.levC = 1 and lcres.cacc = '285521' no-lock no-error.
                 else if v-gar then find first lcres where lcres.LC = s-lc and not lcres.com and lcres.levC = 1 and lcres.cacc = v-depacc no-lock no-error.
                               else find first lcres where lcres.LC = s-lc and not lcres.com and lcres.levC = 22 no-lock no-error.

        k = k + 1.
        /*debit*/
        create wrk.
        assign wrk.numdis = string(i)
               wrk.num    = k
               wrk.dc     = 'Dt'
               wrk.acc    = if avail lcres then lcres.dacc else v-collacc
               wrk.cur    = crc.code
               wrk.sum    = v-lc-amount.
               wrk.jdt    = if avail lcres then lcres.jdt else g-today.
               wrk.rem    = if avail lcres then lcres.rem else 'Списание покрытия ' + s-lc.

        find first aaa where aaa.aaa = wrk.acc no-lock no-error.
        if avail aaa then do:
            wrk.gl = aaa.gl.
            find first gl where gl.gl = aaa.gl no-lock no-error.
            if avail gl then wrk.gldes = trim(gl.des).

            if aaa.gl = 220310 then do:
                find cif where cif.cif = v-cif no-lock no-error.
                if avail cif then wrk.kkk = substr(cif.geo,3,1).
                find first sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = v-cif and sub-cod.d-cod = 'secek' no-lock no-error.
                if avail sub-cod then wrk.kkk = wrk.kkk + sub-cod.ccode + ',14,181'.
            end.
        end.

        /*Credit*/
        k = k + 1.
        create wrk.
        assign wrk.num = k
               wrk.dc  = 'Ct'
               wrk.acc = if avail lcres then lcres.cacc else if (s-lcprod = 'imlc' or s-lcprod = 'sblc') then v-collacc else v-depacc
               wrk.cur = crc.code
               wrk.sum = v-lc-amount
               wrk.jdt = if avail lcres then lcres.jdt  else g-today
               wrk.rem = if avail lcres then lcres.rem  else 'Списание покрытия ' + s-lc
               v-levC  = if avail lcres then lcres.levC else if (s-lcprod = 'imlc' or s-lcprod = 'sblc') then 22 else 1.

        if v-yes then do:
            wrk.gl = int(wrk.acc).
            find first gl where gl.gl = wrk.gl no-lock no-error.
            if avail gl then wrk.gldes = trim(gl.des).
        end.
        else do:
            find first aaa where aaa.aaa = wrk.acc no-lock no-error.
            if avail aaa then do:
                find first trxlev where trxlev.sub = "CIF" and trxlev.lev = v-levC and trxlev.gl = aaa.gl no-lock no-error.
                if avail trxlev then do:
                    wrk.gl = trxlev.glr.
                    find first gl where gl.gl = trxlev.glr no-lock no-error.
                    if avail gl then wrk.gldes = trim(gl.des).
                end.
            end.
        end.

        /*2-nd posting*/
        i = i + 1.
        if s-lcprod <> 'pg' then find first lcres where lcres.LC = s-lc and not lcres.com and lcres.levD = 23 no-lock no-error.
                            else find first lcres where lcres.LC = s-lc and not lcres.com and lcres.levD = 1 and lcres.dacc = '605561' no-lock no-error.
        /*debit*/
        k = k + 1.
        create wrk.
        assign wrk.numdis = string(i)
               wrk.num = k
               wrk.dc  = 'Dt'
               wrk.acc = if avail lcres then lcres.dacc else if not v-gar then v-collacc else '605561'
               wrk.cur = crc.code
               wrk.sum = v-lc-amount
               wrk.jdt = if avail lcres then lcres.jdt  else g-today
               wrk.rem = if avail lcres then lcres.rem  else 'Требования/обязательства ' + s-lc
               v-levD  = if avail lcres then lcres.levD else if not v-gar then 23 else 1.

        if v-levD > 1 then do:
            find first aaa where aaa.aaa = wrk.acc no-lock no-error.
            if avail aaa then do:
                find first trxlev where trxlev.sub = "CIF" and trxlev.lev = v-levD and trxlev.gl = aaa.gl no-lock no-error.
                if avail trxlev then do:
                    wrk.gl = trxlev.glr.
                    find first gl where gl.gl = trxlev.glr no-lock no-error.
                    if avail gl then wrk.gldes = trim(gl.des).
                end.
            end.
        end.
        else do:
            wrk.gl = int(wrk.acc).
            find first gl where gl.gl = wrk.gl no-lock no-error.
            if avail gl then wrk.gldes = trim(gl.des).
        end.

        /*Credit*/
        k = k + 1.
        create wrk.
        assign wrk.num = k
               wrk.dc  = 'Ct'
               wrk.acc = if avail lcres then lcres.cacc else if not v-gar then '652000' else '655561'
               wrk.gl  = int(wrk.acc)
               wrk.cur = crc.code
               wrk.sum = v-lc-amount
               wrk.jdt = if avail lcres then lcres.jdt  else g-today
               wrk.rem = if avail lcres then lcres.rem  else 'Требования/обязательства ' + s-lc.

        find first gl where gl.gl = wrk.gl no-lock no-error.
        if avail gl then wrk.gldes = trim(gl.des).

    end.

/* dmitriy ----------------------------------------------------------------------------------*/

/*Partial Covered*/
else if lc.lctype = 'I' and not v-720 and v-lccow = '2' then do:

    /*1-st posting*/
            i = 1.
            if v-yes then find first lcres where lcres.LC = s-lc and not lcres.com and lcres.levC = 1 and lcres.cacc = '285521' no-lock no-error.
                     else if v-gar then find first lcres where lcres.LC = s-lc and not lcres.com and lcres.levC = 1 and lcres.cacc = v-depacc no-lock no-error.
                                   else find first lcres where lcres.LC = s-lc and not lcres.com and lcres.levC = 22 no-lock no-error.

            k = k + 1.
            /*debit*/
            create wrk.
            assign wrk.numdis = string(i)
                   wrk.num    = k
                   wrk.dc     = 'Dt'
                   wrk.acc    = if avail lcres then lcres.dacc else v-collacc
                   wrk.cur    = crc.code
                   wrk.sum    = /*v-lc-amount*/ v-covAmt
                   wrk.jdt    = if avail lcres then lcres.jdt else g-today.
                   wrk.rem    = if avail lcres then lcres.rem else 'Списание покрытия ' + s-lc.

            find first aaa where aaa.aaa = wrk.acc no-lock no-error.
            if avail aaa then do:
                wrk.gl = aaa.gl.
                find first gl where gl.gl = aaa.gl no-lock no-error.
                if avail gl then wrk.gldes = trim(gl.des).

                if aaa.gl = 220310 then do:
                    find cif where cif.cif = v-cif no-lock no-error.
                    if avail cif then wrk.kkk = substr(cif.geo,3,1).
                    find first sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = v-cif and sub-cod.d-cod = 'secek' no-lock no-error.
                    if avail sub-cod then wrk.kkk = wrk.kkk + sub-cod.ccode + ',14,181'.
                end.
            end.

            /*Credit*/
            k = k + 1.
            create wrk.
            assign wrk.num = k
                   wrk.dc  = 'Ct'
                   wrk.acc = if avail lcres then lcres.cacc else if (s-lcprod = 'imlc' or s-lcprod = 'sblc') then v-collacc else v-depacc
                   wrk.cur = crc.code
                   wrk.sum = /*v-lc-amount*/ v-covAmt
                   wrk.jdt = if avail lcres then lcres.jdt  else g-today
                   wrk.rem = if avail lcres then lcres.rem  else 'Списание покрытия ' + s-lc
                   v-levC  = if avail lcres then lcres.levC else if (s-lcprod = 'imlc' or s-lcprod = 'sblc') then 22 else 1.

            if v-yes then do:
                wrk.gl = int(wrk.acc).
                find first gl where gl.gl = wrk.gl no-lock no-error.
                if avail gl then wrk.gldes = trim(gl.des).
            end.
            else do:
                find first aaa where aaa.aaa = wrk.acc no-lock no-error.
                if avail aaa then do:
                    find first trxlev where trxlev.sub = "CIF" and trxlev.lev = v-levC and trxlev.gl = aaa.gl no-lock no-error.
                    if avail trxlev then do:
                        wrk.gl = trxlev.glr.
                        find first gl where gl.gl = trxlev.glr no-lock no-error.
                        if avail gl then wrk.gldes = trim(gl.des).
                    end.
                end.
            end.

    /*2-nd posting*/
            i = i + 1.
            if s-lcprod <> 'pg' then find first lcres where lcres.LC = s-lc and not lcres.com and lcres.levD = 23 no-lock no-error.
                                else find first lcres where lcres.LC = s-lc and not lcres.com and lcres.levD = 1 and lcres.dacc = '605561' no-lock no-error.
            /*debit*/
            k = k + 1.
            create wrk.
            assign wrk.numdis = string(i)
                   wrk.num = k
                   wrk.dc  = 'Dt'
                   wrk.acc = if avail lcres then lcres.dacc else if not v-gar then v-collacc else '605561'
                   wrk.cur = crc.code
                   wrk.sum = /*v-lc-amount*/ v-covAmt
                   wrk.jdt = if avail lcres then lcres.jdt  else g-today
                   wrk.rem = if avail lcres then lcres.rem  else 'Требования/обязательства ' + s-lc
                   v-levD  = if avail lcres then lcres.levD else if not v-gar then 23 else 1.

            if v-levD > 1 then do:
                find first aaa where aaa.aaa = wrk.acc no-lock no-error.
                if avail aaa then do:
                    find first trxlev where trxlev.sub = "CIF" and trxlev.lev = v-levD and trxlev.gl = aaa.gl no-lock no-error.
                    if avail trxlev then do:
                        wrk.gl = trxlev.glr.
                        find first gl where gl.gl = trxlev.glr no-lock no-error.
                        if avail gl then wrk.gldes = trim(gl.des).
                    end.
                end.
            end.
            else do:
                wrk.gl = int(wrk.acc).
                find first gl where gl.gl = wrk.gl no-lock no-error.
                if avail gl then wrk.gldes = trim(gl.des).
            end.

            /*Credit*/
            k = k + 1.
            create wrk.
            assign wrk.num = k
                   wrk.dc  = 'Ct'
                   wrk.acc = if avail lcres then lcres.cacc else if not v-gar then '652000' else '655561'
                   wrk.gl  = int(wrk.acc)
                   wrk.cur = crc.code
                   wrk.sum = /*v-lc-amount*/ v-covAmt
                   wrk.jdt = if avail lcres then lcres.jdt  else g-today
                   wrk.rem = if avail lcres then lcres.rem  else 'Требования/обязательства ' + s-lc.

            find first gl where gl.gl = wrk.gl no-lock no-error.
            if avail gl then wrk.gldes = trim(gl.des).

    /* 3-d posting */
            i = i + 1.
            if v-gar then find first lcres where lcres.LC = s-lc and not lcres.com and lcres.levD = 1 and lcres.dacc = '605562' no-lock no-error.
                     else find first lcres where lcres.LC = s-lc and not lcres.com and lcres.levD = 24 no-lock no-error.
            /*debit*/
            k = k + 1.
            create wrk.
            assign wrk.numdis = string(i)
                   wrk.num    = k
                   wrk.dc     = 'Dt'
                   wrk.acc    = if avail lcres then lcres.dacc else if not v-gar then v-comacc else '605562'
                   wrk.cur = crc.code
                   wrk.sum = /*v-lc-amount*/ v-uncovAmt
                   wrk.jdt = if avail lcres then lcres.jdt  else g-today
                   wrk.rem = if avail lcres then lcres.rem  else 'Требования/обязательства ' + s-lc
                   v-levD  = if avail lcres then lcres.levD else if not v-gar then 24 else 1.
            if v-levD > 1 then do:
                find first aaa where aaa.aaa = wrk.acc no-lock no-error.
                if avail aaa then do:
                    find first trxlev where trxlev.sub = "CIF" and trxlev.lev = v-levD and trxlev.gl = aaa.gl no-lock no-error.
                    if avail trxlev then do:
                        wrk.gl = trxlev.glr.
                        find first gl where gl.gl = trxlev.glr no-lock no-error.
                        if avail gl then wrk.gldes = trim(gl.des).
                    end.

                    if aaa.gl = 220310 then do:
                        find cif where cif.cif = v-cif no-lock no-error.
                        if avail cif then wrk.kkk = substr(cif.geo,3,1).
                        find first sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = v-cif and sub-cod.d-cod = 'secek' no-lock no-error.
                        if avail sub-cod then wrk.kkk = wrk.kkk + sub-cod.ccode + ',14,181'.
                    end.
                end.
            end.
            else do:
                wrk.gl = int(wrk.acc).
                find first gl where gl.gl = wrk.gl no-lock no-error.
                if avail gl then wrk.gldes = trim(gl.des).
            end.

            /*Credit*/
            k = k + 1.
            create wrk.
            assign wrk.num = k
                   wrk.dc  = 'Ct'
                   wrk.acc = if avail lcres then lcres.cacc else if not v-gar then '650510' else '655562'
                   wrk.gl  = int(wrk.acc)
                   wrk.cur = crc.code
                   wrk.sum = /*v-lc-amount*/ v-uncovAmt
                   wrk.jdt = if avail lcres then lcres.jdt  else g-today
                   wrk.rem = if avail lcres then lcres.rem  else 'Требования/обязательства ' + s-lc.

            find first gl where gl.gl = wrk.gl no-lock no-error.
            if avail gl then wrk.gldes = trim(gl.des).
end.
/*-------------------------------------------------------------------------------------------*/

    else do:  /* uncovered */
        /* 1-st posting */
        i = 1.
        if v-gar then find first lcres where lcres.LC = s-lc and not lcres.com and lcres.levD = 1 and lcres.dacc = '605562' no-lock no-error.
                 else find first lcres where lcres.LC = s-lc and not lcres.com and lcres.levD = 24 no-lock no-error.
        /*debit*/
        k = k + 1.
        create wrk.
        assign wrk.numdis = string(i)
               wrk.num    = k
               wrk.dc     = 'Dt'
               wrk.acc    = if avail lcres then lcres.dacc else if not v-gar then v-comacc else '605562'
               wrk.cur = crc.code
               wrk.sum = v-lc-amount
               wrk.jdt = if avail lcres then lcres.jdt  else g-today
               wrk.rem = if avail lcres then lcres.rem  else 'Требования/обязательства ' + s-lc
               v-levD  = if avail lcres then lcres.levD else if not v-gar then 24 else 1.
        if v-levD > 1 then do:
            find first aaa where aaa.aaa = wrk.acc no-lock no-error.
            if avail aaa then do:
                find first trxlev where trxlev.sub = "CIF" and trxlev.lev = v-levD and trxlev.gl = aaa.gl no-lock no-error.
                if avail trxlev then do:
                    wrk.gl = trxlev.glr.
                    find first gl where gl.gl = trxlev.glr no-lock no-error.
                    if avail gl then wrk.gldes = trim(gl.des).
                end.

                if aaa.gl = 220310 then do:
                    find cif where cif.cif = v-cif no-lock no-error.
                    if avail cif then wrk.kkk = substr(cif.geo,3,1).
                    find first sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = v-cif and sub-cod.d-cod = 'secek' no-lock no-error.
                    if avail sub-cod then wrk.kkk = wrk.kkk + sub-cod.ccode + ',14,181'.
                end.
            end.
        end.
        else do:
            wrk.gl = int(wrk.acc).
            find first gl where gl.gl = wrk.gl no-lock no-error.
            if avail gl then wrk.gldes = trim(gl.des).
        end.

        /*Credit*/
        k = k + 1.
        create wrk.
        assign wrk.num = k
               wrk.dc  = 'Ct'
               wrk.acc = if avail lcres then lcres.cacc else if not v-gar then '650510' else '655562'
               wrk.gl  = int(wrk.acc)
               wrk.cur = crc.code
               wrk.sum = v-lc-amount
               wrk.jdt = if avail lcres then lcres.jdt  else g-today
               wrk.rem = if avail lcres then lcres.rem  else 'Требования/обязательства ' + s-lc.

        find first gl where gl.gl = wrk.gl no-lock no-error.
        if avail gl then wrk.gldes = trim(gl.des).

        /* 2-nd posting */
        i = i + 1.
        if v-gar then do:
            find first lch where lch.lc = s-lc and lch.kritcode = 'ForCon' and lch.value1 = "yes" no-lock no-error.
            if avail lch then do:
                find first lcres where lcres.LC = s-lc and not lcres.com and lcres.levD = 1 and lcres.dacc = '607510' no-lock no-error.

                /* debit */
                k = k + 1.
                create wrk.
                assign wrk.numdis = string(i)
                       wrk.num    = k
                       wrk.dc     = 'Dt'
                       wrk.acc    = if avail lcres then lcres.dacc else '607510'
                       wrk.cur = crc.code
                       wrk.sum = v-lc-amount
                       wrk.jdt = if avail lcres then lcres.jdt  else g-today
                       wrk.rem = if avail lcres then lcres.rem  else 'Требования/обязательства по принятой контр-гарантии' + s-lc
                       v-levD  = if avail lcres then lcres.levD else 1.

                       find first gl where gl.gl = wrk.gl no-lock no-error.
                       if avail gl then wrk.gldes = trim(gl.des).

                       wrk.gl = int(wrk.acc).
                       find first gl where gl.gl = wrk.gl no-lock no-error.
                       if avail gl then wrk.gldes = trim(gl.des).

                /* credit */
                k = k + 1.
                create wrk.
                assign wrk.num = k
                       wrk.dc  = 'Ct'
                       wrk.acc = if avail lcres then lcres.cacc else '657510'
                       wrk.gl  = int(wrk.acc)
                       wrk.cur = crc.code
                       wrk.sum = v-lc-amount
                       wrk.jdt = if avail lcres then lcres.jdt  else g-today
                       wrk.rem = if avail lcres then lcres.rem  else 'Требования/обязательства по принятой контр-гарантии' + s-lc.

                       find first gl where gl.gl = wrk.gl no-lock no-error.
                       if avail gl then wrk.gldes = trim(gl.des).


                /* 3-rd posting */
                i = i + 1.
                if v-gar then find first lcres where lcres.LC = s-lc and not lcres.com and lcres.levD = 1 and lcres.dacc = '733973' no-lock no-error.

                /* debit */
                k = k + 1.
                create wrk.
                assign wrk.numdis = string(i)
                       wrk.num    = k
                       wrk.dc     = 'Dt'
                       wrk.acc    = if avail lcres then lcres.dacc else '733973'
                       wrk.cur = 'KZT'
                       wrk.sum = 1
                       wrk.jdt = if avail lcres then lcres.jdt  else g-today
                       wrk.rem = if avail lcres then lcres.rem  else 'Оприходование контр-гарантии' + s-lc
                       v-levD  = if avail lcres then lcres.levD else 1.

                       find first gl where gl.gl = wrk.gl no-lock no-error.
                       if avail gl then wrk.gldes = trim(gl.des).

                       wrk.gl = int(wrk.acc).
                       find first gl where gl.gl = wrk.gl no-lock no-error.
                       if avail gl then wrk.gldes = trim(gl.des).

                /* credit */
                k = k + 1.
                create wrk.
                assign wrk.num = k
                       wrk.dc  = 'Ct'
                       wrk.acc = if avail lcres then lcres.cacc else '833900'
                       wrk.gl  = int(wrk.acc)
                       wrk.cur = 'KZT'
                       wrk.sum = 1
                       wrk.jdt = if avail lcres then lcres.jdt  else g-today
                       wrk.rem = if avail lcres then lcres.rem  else 'Оприходование контр-гарантии' + s-lc.

                       find first gl where gl.gl = wrk.gl no-lock no-error.
                       if avail gl then wrk.gldes = trim(gl.des).
            end.
        end.
    end.

    if v-numlim > 0 then do:
        /* posting - limit*/
       find first lclimit where lclimit.bank = s-ourbank and lclimit.cif = v-cif and lclimit.number = v-numlim no-lock no-error.
       if avail lclimit then do:
        find first lclimitres where lclimitres.bank = lclimit.bank and lclimitres.cif = lclimit.cif and lclimitres.number = lclimit.number and lclimitres.lc = s-lc and lclimitres.info[1] = 'create' no-lock no-error.
        if avail lclimitres then do:
            find first b-crc where b-crc.crc = lclimitres.crc no-lock no-error.
            /* debit */
            i = i + 1.
            k = k + 1.
            create wrk.
            assign wrk.numdis = string(i)
                   wrk.num = k
                   wrk.dc  = 'Dt'
                   wrk.acc = lclimitres.dacc
                   wrk.cur = b-crc.code
                   wrk.sum = lclimitres.amt
                   wrk.jdt = lclimitres.jdt
                   wrk.rem = lclimitres.rem
                   wrk.gl  = int(wrk.acc).

                find first gl where gl.gl = wrk.gl no-lock no-error.
                if avail gl then wrk.gldes = trim(gl.des).

            /*Credit*/
            k = k + 1.
            create wrk.
            assign wrk.num = k
                   wrk.dc  = 'Ct'
                   wrk.acc = lclimitres.cacc
                   wrk.gl  = int(wrk.acc)
                   wrk.cur = b-crc.code
                   wrk.sum = lclimitres.amt
                   wrk.jdt = lclimitres.jdt
                   wrk.rem = lclimitres.rem.

            find first gl where gl.gl = wrk.gl no-lock no-error.
            if avail gl then wrk.gldes = trim(gl.des).
        end.
        else do:
            find first lclimith where lclimith.cif = lclimit.cif and lclimith.number = lclimit.number  and lclimith.kritcode = 'Revolv' no-lock no-error.
            if avail lclimith then v-revolv = lclimith.value1.
            if lookup(v-revolv,v-logsno) > 0 then assign v-dacc = '662540' v-cacc = '612540' v-text = 'невозобновляемым'.

            find first lclimith where lclimith.cif = lclimit.cif and lclimith.number = lclimit.number and lclimith.kritcode = 'lcCrc' no-lock no-error.
            if avail lclimith then v-limcrc = int(lclimith.value1).
            if v-crc = v-limcrc then v-lim-amount = v-lc-amount.
            else do:
                find first b-crc where b-crc.crc = v-limcrc no-lock no-error.
                if avail b-crc then v-lim-amount = round((v-lc-amount * crc.rate[1]) / b-crc.rate[1],2).
            end.
            i = i + 1.
            find first lclimitres where lclimitres.bank = lclimit.bank and lclimitres.cif = lclimit.cif and lclimitres.number = lclimit.number and lclimitres.lc = s-lc and lclimitres.info[1] = 'create' no-lock no-error.
            /*debit*/
            k = k + 1.
            create wrk.
            assign wrk.numdis = string(i)
                   wrk.num = k
                   wrk.dc  = 'Dt'
                   wrk.acc = if avail lclimitres then lclimitres.dacc else v-dacc
                   wrk.cur = if  v-crc = v-limcrc then crc.code else b-crc.code
                   wrk.sum = if avail lclimitres then lclimitres.amt else v-lim-amount
                   wrk.jdt = if avail lclimitres then lclimitres.jdt else g-today
                   wrk.rem = if avail lclimitres then lclimitres.rem else 'Списание доступного остатка по ' + v-text + ' кредитам в рамках ТФ, ' + s-lc
                   wrk.gl  = int(wrk.acc).

                find first gl where gl.gl = wrk.gl no-lock no-error.
                if avail gl then wrk.gldes = trim(gl.des).

            /*Credit*/
            k = k + 1.
            create wrk.
            assign wrk.num = k
                   wrk.dc  = 'Ct'
                   wrk.acc = if avail lclimitres then lclimitres.cacc else v-cacc
                   wrk.gl  = int(wrk.acc)
                   wrk.cur = if  v-crc = v-limcrc then crc.code else b-crc.code
                   wrk.sum = if avail lclimitres then lclimitres.amt else v-lim-amount
                   wrk.jdt = if avail lclimitres then lclimitres.jdt else g-today
                   wrk.rem = if avail lclimitres then lclimitres.rem else 'Списание доступного остатка по ' + v-text + ' кредитам в рамках ТФ, ' + s-lc.

            find first gl where gl.gl = wrk.gl no-lock no-error.
            if avail gl then wrk.gldes = trim(gl.des).
        end.
       end.
    end.

end.

/*Commission postings*/
find first lcres where lcres.lc = s-lc no-lock no-error.
if avail lcres then do:
    for each lcres where lcres.lc = s-lc and lcres.com and lcres.amt > 0 no-lock:
        i = i + 1.
        k = k + 1.
        create wrk.
        assign wrk.acc = lcres.dacc
               wrk.dc  = 'Dt'
               wrk.num = k
               wrk.numdis = string(i).
        find first aaa where aaa.aaa = lcres.dacc no-lock no-error.
        if avail aaa then do:
            find first trxlev where trxlev.sub = "CIF" and trxlev.lev = lcres.levD and trxlev.gl = aaa.gl no-lock no-error.
            if avail trxlev then do:
                wrk.gl = trxlev.glr.
                find first gl where gl.gl = aaa.gl no-lock no-error.
                if avail gl then wrk.gldes = trim(gl.des).
            end.

            if aaa.gl = 220310 then do:
                find cif where cif.cif = v-cif no-lock no-error.
                if avail cif then wrk.kkk = substr(cif.geo,3,1).
                find first sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = v-cif and sub-cod.d-cod = 'secek' no-lock no-error.
                if avail sub-cod then wrk.kkk = wrk.kkk + sub-cod.ccode + ',14,181'.
            end.
        end.
        wrk.sum = lcres.amt.

        find first crc where crc.crc = lcres.crc no-lock no-error.
        if avail crc then wrk.cur = crc.code.

        if lcres.jh > 0 then wrk.jdt = lcres.jdt.
        else wrk.jdt = g-today.
        wrk.rem = if num-entries(lcres.rem,';') = 2 then entry(1,lcres.rem,';') else lcres.rem.

        k = k + 1.
        create wrk.
        assign wrk.dc  = 'Ct'
               wrk.num = k
               wrk.acc = lcres.cacc.
        find first tarif2 where tarif2.num  = substr(lcres.comcode,1,1) and tarif2.kod = substr(lcres.comcode,2) and tarif2.stat = 'r' no-lock no-error.
        if avail tarif2 then do:
            if tarif2.num + tarif2.kod = '970' then
               assign wrk.gl = 285531.

            else if tarif2.num + tarif2.kod = '966' then
               assign wrk.gl = 286931
                      wrk.acc = '286931'.

            else if lookup(s-lcprod,'PG,EXPG') > 0 and lookup(lcres.comcode,'967,968,969,952,955,956,957,953,954,958,959,941,942,943,944,945,946,947') > 0 then do:
                assign wrk.gl = 286920.
                       wrk.acc = '286920'.
                       find gl where gl.gl = wrk.gl no-lock no-error.
                       if avail gl then wrk.gldes = gl.des.
            end.

            else assign wrk.gl = tarif2.kont.
            wrk.gldes = tarif2.pakal.
        end.
        wrk.sum = lcres.amt.
        find first crc where crc.crc = lcres.crc no-lock no-error.
        if avail crc then wrk.cur = crc.code.

        if lcres.jh > 0 then wrk.jdt = lcres.jdt.
        else wrk.jdt = g-today.
        wrk.rem = if num-entries(lcres.rem,';') = 2 then entry(1,lcres.rem,';') else lcres.rem.

        if lookup(s-lcprod,'PG,EXPG') > 0 and lookup(lcres.comcode,'967,968,969,952,955,956,957,953,954,958,959,941,942,943,944,945,946,947') > 0 then do:
            k = k + 1.
            create wrk.
            assign wrk.dc  = 'Dt'
                   wrk.num = k
                   wrk.gl = 286920
                   wrk.acc = '286920'.
                   find gl where gl.gl = wrk.gl no-lock no-error.
                   if avail gl then wrk.gldes = gl.des.
                   wrk.sum = lcres.amt.
                   find first crc where crc.crc = lcres.crc no-lock no-error.
                   if avail crc then wrk.cur = crc.code.
                   if lcres.jh > 0 then wrk.jdt = lcres.jdt.
                   else wrk.jdt = g-today.
                   wrk.rem = if num-entries(lcres.rem,';') = 2 then entry(1,lcres.rem,';') else lcres.rem.

            k = k + 1.
            create wrk.
            assign wrk.dc  = 'Ct'
                   wrk.num = k.
                find first tarif2 where tarif2.num  = substr(lcres.comcode,1,1) and tarif2.kod = substr(lcres.comcode,2) and tarif2.stat = 'r' no-lock no-error.
                if avail tarif2 then
                   assign
                   wrk.gl = tarif2.kont
                   wrk.acc = string(tarif2.kont)
                   wrk.gldes = tarif2.pakal.
                   wrk.sum = lcres.amt.
                   find first crc where crc.crc = lcres.crc no-lock no-error.
                   if avail crc then wrk.cur = crc.code.
                   if lcres.jh > 0 then wrk.jdt = lcres.jdt.
                   else wrk.jdt = g-today.
                   wrk.rem = if num-entries(lcres.rem,';') = 2 then entry(1,lcres.rem,';') else lcres.rem.
        end.
    end.
end.
if v-lcsts <> 'FIN' and  v-lccow = '0' then do:
    for each wrk where wrk.dc = 'Ct' and (wrk.gl = 285511 or wrk.gl = 224011) no-lock:
        v-sum2 = v-sum2 + wrk.sum.
    end.

    for each lcres where lcres.lc = s-lc and lcres.com = yes no-lock:
        v-sum1 = v-sum1 + lcres.amt.
    end.

    if v-collacc = v-comacc then do:
        v-sum = v-sum1 + v-sum2.
        find first aaa where aaa.aaa = v-collacc no-lock no-error.
        if avail aaa then do:
            if v-sum > aaa.cbal - aaa.hbal then do:
                message "Lack of the balance of the Collateral Debit Account(" + aaa.aaa + ")!" view-as alert-box.
                return.
            end.
        end.
    end.
    else do:
        find first aaa where aaa.aaa = v-collacc no-lock no-error.
        if avail aaa then do:
            if v-sum2 > aaa.cbal - aaa.hbal then do:
                message "Lack of the balance of the Collateral Debit Account(" + aaa.aaa + ")!" view-as alert-box.
                return.
            end.
        end.
        find first aaa where aaa.aaa = v-comacc no-lock no-error.
        if avail aaa then do:
            if v-sum1 > aaa.cbal - aaa.hbal then do:
                message " Lack of the balance Commissions Debit Account(" + aaa.aaa + ")!" view-as alert-box.
                return.
            end.
        end.
    end.
end.
on choose of btn-e do:

    output stream m-out to impl_postings.htm.
    put stream m-out unformatted "<html><head><title>ForteBank</title>"
                                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

    put stream m-out unformatted "<br><br><h3> ForteBank </h3>" skip
    /*put stream m-out unformatted "<h3>Future postings</h3><br>" skip*/
                                 "<p><b>Letter of Credit No / Номер Аккредитива " + s-lc + "</b></p>".
    put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
                                 "<tr style=""font:bold"">"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">№ / Номер строки</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Debit/Credit / Дебет/Кредит</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Client Account Number / Счет </td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Ledger Account  Number / ~n Балансовый счет</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Ledger Account  Description / Наменование Балансового счета</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Amount / Сумма</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Currency / Курс</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Narrative / Комментарии</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">EKNP / ЕКНП</td></tr>" skip.

    for each wrk no-lock:
        put stream m-out unformatted
        "<tr>".
        if wrk.numdis <> '' then put stream m-out unformatted "<td rowspan = 2>" wrk.numdis "</td>".
        put stream m-out unformatted
        "<td>" wrk.dc "</td>"
        "<td>`" string(wrk.acc) "</td>"

        "<td>`" string(wrk.gl) "</td>"
        "<td>" wrk.gldes "</td>"

        "<td>" replace(replace(trim(string(wrk.sum,'>>>,>>>,>>9.99')),',',' '),'.',',') "</td>"
        "<td>" wrk.cur "</td>"
        "<td>" wrk.rem "</td>"
        "<td>" wrk.kkk "</td></tr>" skip.
    end.
    put stream m-out "</table></body></html>" skip.
    output stream m-out close.
    unix silent cptwin impl_postings.htm excel.
end.

OPEN QUERY  qt FOR EACH wrk.
ENABLE ALL WITH FRAME ft.
WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW. /*or choose of btn-e.*/