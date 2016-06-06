/* LCpost2.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Вывод проводок
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU

 * AUTHOR
       26/11/2010 galina
 * BASES
        BANK COMM
 * CHANGES
        06/12/2010 galina - поправила вывод проводки по уменьшению комиссии 970
        28/02/2011 id00810 - для всех импортных аккредитивов и гарантии
        29/07/2011 id00810 - счет DepAcc вместо 285521 для покрытого PG (c 01/08/2011)
        29/09/2011 id00810 - проводки по лимиту
        23/01/2012 id00810 - проверка суммы ддя проводок по лимиту
        06/02/2012 id00810 - добавлены комиссии
        28.06.2012 Lyubov  - проводки по PG\EXPG образуются иначе 220310 -> 286920, 286920 -> 4612(20\11)
        17.07.2012 Lyubov  - исправила ошибку, не было одной проверки v-gar
        23.08.2012 Lyubov  - MetroComBank исправила на ForteBank
        20/09/2013 Luiza   - ТЗ 1916 изменение поиска записи в таблице tarif2
*/

{global.i}
def stream m-out.
def shared var s-lc       as char.
def shared var s-lcamend  like lcamend.lcamend.
def shared var s-lcprod   as char.
def shared var v-cif      as char.
def shared var v-cifname  as char.

def var v-lccow     as char no-undo.
def var v-collacc   as char no-undo.
def var v-comacc    as char no-undo.
def var v-depacc    as char no-undo.
def var v-amount    as char no-undo.
def var v-incdec    as int  no-undo.
def var v-lc-amount as deci no-undo.
def var v-per       as deci no-undo.
def var v-sum       as deci no-undo.
def var v-sum1      as deci no-undo.
def var v-sum2      as deci no-undo.
def var v-dacc      as char no-undo.
def var v-cacc      as char no-undo.
def var v-levD      as int  no-undo.
def var v-levC      as int  no-undo.
def var v-crc       as int  no-undo.
def var v-gar       as logi no-undo.
def var i           as int  no-undo.
def var k           as int  no-undo.
def var v-numlim    as int  no-undo.
def var v-revolv    as char no-undo.
def var v-text      as char no-undo init 'возобновляемым'.
def var v-logsno    as char init "no,n,нет,н,1".
def var v-lim-amount as deci no-undo.
def var v-limcrc     as int  no-undo.
def var v-nazn       as char no-undo.
def buffer b-crc for crc.


find first lc where lc.lc = s-lc no-lock no-error.
if not avail lc then return.
if s-lcprod = 'pg' then v-gar = yes.

find first lch where lch.lc = s-lc and lch.kritcode = 'Cover' no-lock no-error.
if avail lch then v-lccow = lch.value1.
if v-lccow = '' then do:
    message "Field Covered/uncovered is empty!" view-as alert-box.
    return.
end.

find first lch where lch.lc = s-lc and lch.kritcode = 'NLim' no-lock no-error.
if avail lch then v-numlim = int(lch.value1).

if v-lccow = '0' then do:
    find first lch where lch.lc = s-lc and lch.kritcode = 'CollACC' no-lock no-error.
    if avail lch then v-collacc = lch.value1.
    if v-collacc = '' then do:
        message "Field CollAcc is empty!" view-as alert-box.
        return.
    end.
    if v-gar then do:
        find first lch where lch.lc = s-lc and lch.kritcode = 'DepAcc' no-lock no-error.
        if avail lch then v-depacc = lch.value1.
        if v-depacc = '' then do:
            message "Field Collateral Deposit Accout is empty!" view-as alert-box.
            return.
        end.
    end.
end.

find first lch where lch.lc = s-lc and lch.kritcode = 'ComAcc' no-lock no-error.
if avail lch then v-comacc = lch.value1.
if v-comacc = '' then do:
    message "Field ComAcc is empty!" view-as alert-box.
    return.
end.

find first lcamendh where lcamendh.bank = lc.bank and lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'IncAmt' no-lock no-error.
if avail lcamendh and lcamendh.value1 <> '' then assign v-incdec = 1 v-amount = lcamendh.value1.
else do:
    find first lcamendh where lcamendh.bank = lc.bank and lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'DecAmt' no-lock no-error.
    if avail lcamendh and lcamendh.value1 <> '' then assign v-incdec = -1 v-amount = lcamendh.value1.
end.

find first lcamendh where lcamendh.bank = lc.bank and lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'PerAmtT' no-lock no-error.
if avail lcamendh and lcamendh.value1 <> '' then do:
    v-per = int(entry(1,lcamendh.value1, '/')).
    if v-per > 0 then v-lc-amount = (decimal(v-amount) + (decimal(v-amount) * (v-per / 100))).
    if v-per <= 0 then v-lc-amount = decimal(v-amount).
end.
else v-lc-amount = decimal(v-amount).

find first lch where lch.lc = s-lc and lch.kritcode = 'lcCrc' no-lock no-error.
v-crc = int(lch.value1).

find first crc where crc.crc = v-crc no-lock no-error.
if not avail crc then return.

def temp-table wrk no-undo
    field num    as int
    field numdis as char
    field dc     as char
    field gldes  as char
    field rem    as char
    field jdt    as date
    FIELD acc    AS CHAR
    FIELD gl     AS integer
    field sum    as decimal
    field cur    as char
    index ind1 is primary num.

define query qt for wrk.
define browse bt query qt
    displ wrk.numdis label "№"          format "x(3)"
          wrk.dc     label "Dt/Ct"      format "x(2)"
          wrk.acc    label "Client Acc" format "x(20)"
          wrk.gl     label "Ledger Acc" format "999999"
          wrk.gldes  label "Ledger Account Description" format "x(30)"
          wrk.sum    label "Amount"     format ">>>,>>>,>>9.99"
          wrk.cur    label "CCY"        format "x(3)"
          wrk.jdt    label "Value Dt"   format "99/99/99"
          wrk.rem    label "Narrative"  format "x(30)"
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

if deci(v-amount) > 0 then do:
    k = 0.
    if v-lccow = '0' then do:
        /*1-st posting*/
        i = 1.
        if not v-gar then do:
            assign v-dacc = v-collacc
                   v-cacc = v-collacc.
            if v-incdec = 1 then do:
                assign v-levD = 1
                       v-levC = 22.
                find first lcamendres where lcamendres.LC = s-lc and lcamendres.lcamend = s-lcamend and not lcamendres.com and lcamendres.levC = v-levC no-lock no-error.
            end.
            else do:
                assign v-levD = 22
                       v-levC = 1.
                find first lcamendres where lcamendres.LC = s-lc and lcamendres.lcamend = s-lcamend and not lcamendres.com and lcamendres.levD = v-levD no-lock no-error.
            end.
        end.
        else do:
            assign v-levD = 1
                   v-levC = 1.
            if v-incdec = 1  then do:
                assign v-dacc = v-collacc
                       v-cacc = v-depacc.
                find first lcamendres where lcamendres.LC = s-lc and lcamendres.lcamend = s-lcamend and not lcamendres.com and lcamendres.levC = 1 and lcamendres.cacc = v-cacc no-lock no-error.
            end.
            else do:
                assign v-dacc = v-depacc
                       v-cacc = v-collacc.
                find first lcamendres where lcamendres.LC = s-lc and lcamendres.lcamend = s-lcamend and not lcamendres.com and lcamendres.levD = 1 and lcamendres.dacc = v-dacc no-lock no-error.
            end.
        end.

        /*debit*/
        k = k + 1.
        create wrk.
        assign wrk.numdis = string(i)
               wrk.num    = k
               wrk.dc     = 'Dt'
               wrk.acc    = if avail lcamendres then lcamendres.dacc else v-dacc
               wrk.cur    = crc.code
               wrk.sum    = v-lc-amount.
               wrk.jdt    = if avail lcamendres then lcamendres.jdt else g-today.
               wrk.rem    = if avail lcamendres then lcamendres.rem else 'Покрытие ' + s-lc.

         find first aaa where aaa.aaa = wrk.acc no-lock no-error.
            if avail aaa then do:
                find first trxlev where trxlev.sub = "CIF" and trxlev.lev = v-levD and trxlev.gl = aaa.gl no-lock no-error.
                if avail trxlev then do:
                    wrk.gl = trxlev.glr.
                    find first gl where gl.gl = trxlev.glr no-lock no-error.
                    if avail gl then wrk.gldes = trim(gl.des).
                end.
            end.

        /*Credit*/
        k = k + 1.

        create wrk.
        assign wrk.num = k
               wrk.dc  = 'Ct'
               wrk.acc = if avail lcamendres then lcamendres.cacc else v-cacc
               wrk.cur = crc.code
               wrk.sum = v-lc-amount
               wrk.jdt = if avail lcamendres then lcamendres.jdt  else g-today
               wrk.rem = if avail lcamendres then lcamendres.rem  else 'Покрытие ' + s-lc.

        find first aaa where aaa.aaa = wrk.acc no-lock no-error.
        if avail aaa then do:
            find first trxlev where trxlev.sub = "CIF" and trxlev.lev = v-levC and trxlev.gl = aaa.gl no-lock no-error.
            if avail trxlev then do:
                wrk.gl = trxlev.glr.
                find first gl where gl.gl = trxlev.glr no-lock no-error.
                if avail gl then wrk.gldes = trim(gl.des).
            end.
        end.

        /*2-nd posting*/
        i = i + 1.
        if not v-gar then do:
            if v-incdec = 1 then do:
                assign v-dacc = v-collacc
                       v-cacc = '652000'
                       v-levD = 23
                       v-levC = 1.
                find first lcamendres where lcamendres.LC = s-lc and lcamendres.lcamend = s-lcamend and not lcamendres.com and lcamendres.levD = v-levD no-lock no-error.
            end.
            else do:
                assign v-dacc = '652000'
                       v-cacc = v-collacc
                       v-levD = 1
                       v-levC = 23.
                find first lcamendres where lcamendres.LC = s-lc and lcamendres.lcamend = s-lcamend and not lcamendres.com and lcamendres.levC = v-levC no-lock no-error.
            end.
        end.
        else do:
            assign v-levD = 1
                   v-levC = 1.
            if v-incdec = 1  then do:
                assign v-dacc = '605561'
                       v-cacc = '655561'.
                find first lcamendres where lcamendres.LC = s-lc and lcamendres.lcamend = s-lcamend and not lcamendres.com and lcamendres.levC = 1 and lcamendres.cacc = v-cacc no-lock no-error.
            end.
            else do:
                assign v-dacc = '655561'
                       v-cacc = '605561'.
                find first lcamendres where lcamendres.LC = s-lc and lcamendres.lcamend = s-lcamend and not lcamendres.com and lcamendres.levD = 1 and lcamendres.dacc = v-dacc no-lock no-error.
            end.
        end.

        /*debit*/
        k = k + 1.
        create wrk.
        assign wrk.numdis = string(i)
               wrk.num = k
               wrk.dc  = 'Dt'
               wrk.acc = if avail lcamendres then lcamendres.dacc else v-dacc
               wrk.cur = crc.code
               wrk.sum = v-lc-amount
               wrk.jdt = if avail lcamendres then lcamendres.jdt  else g-today
               wrk.rem = if avail lcamendres then lcamendres.rem  else 'Требования/обязательства ' + s-lc
               v-levD  = if avail lcamendres then lcamendres.levD else v-levD.

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
               wrk.acc = if avail lcamendres then lcamendres.cacc else v-cacc
               wrk.cur = crc.code
               wrk.sum = v-lc-amount
               wrk.jdt = if avail lcamendres then lcamendres.jdt  else g-today
               wrk.rem = if avail lcamendres then lcamendres.rem  else 'Требования/обязательства ' + s-lc
               v-levC  = if avail lcamendres then lcamendres.levC else v-levC.
        if v-levC > 1 then do:
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
        else do:
            wrk.gl = int(wrk.acc).
            find first gl where gl.gl = wrk.gl no-lock no-error.
            if avail gl then wrk.gldes = trim(gl.des).
        end.
    end.

    if v-lccow = '1' then do:
        if not v-gar then do:
            if v-incdec = 1 then do:
                assign v-dacc = v-comacc
                       v-cacc = '650510'
                       v-levD = 24
                       v-levC = 1.
                find first lcamendres where lcamendres.LC = s-lc and lcamendres.lcamend = s-lcamend and not lcamendres.com and lcamendres.levD = v-levD no-lock no-error.
            end.
            else do:
                assign v-dacc = '650510'
                       v-cacc = v-comacc
                       v-levD = 1
                       v-levC = 24.
                find first lcamendres where lcamendres.LC = s-lc and lcamendres.lcamend = s-lcamend and not lcamendres.com and lcamendres.levC = v-levC no-lock no-error.
            end.
        end.
        else do:
            assign v-levD = 1
                   v-levC = 1.
            if v-incdec = 1  then do:
                assign v-dacc = '605562'
                       v-cacc = '655562'.
                find first lcamendres where lcamendres.LC = s-lc and lcamendres.lcamend = s-lcamend and not lcamendres.com and lcamendres.levC = 1 and lcamendres.cacc = v-cacc no-lock no-error.
            end.
            else do:
                assign v-dacc = '655562'
                       v-cacc = '605562'.
                find first lcamendres where lcamendres.LC = s-lc and lcamendres.lcamend = s-lcamend and not lcamendres.com and lcamendres.levD = 1 and lcamendres.dacc = v-dacc no-lock no-error.
            end.
        end.

        /*debit*/
        k = k + 1.
        create wrk.
        assign wrk.numdis = string(i)
               wrk.num = k
               wrk.dc  = 'Dt'
               wrk.acc = if avail lcamendres then lcamendres.dacc else v-dacc
               wrk.cur = crc.code
               wrk.sum = v-lc-amount
               wrk.jdt = if avail lcamendres then lcamendres.jdt  else g-today
               wrk.rem = if avail lcamendres then lcamendres.rem  else 'Требования/обязательства ' + s-lc
               v-levD  = if avail lcamendres then lcamendres.levD else v-levD.

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
               wrk.acc = if avail lcamendres then lcamendres.cacc else v-cacc
               wrk.cur = crc.code
               wrk.sum = v-lc-amount
               wrk.jdt = if avail lcamendres then lcamendres.jdt  else g-today
               wrk.rem = if avail lcamendres then lcamendres.rem  else 'Требования/обязательства ' + s-lc
               v-levC  = if avail lcamendres then lcamendres.levC else v-levC.
        if v-levC > 1 then do:
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
        else do:
            wrk.gl = int(wrk.acc).
            find first gl where gl.gl = wrk.gl no-lock no-error.
            if avail gl then wrk.gldes = trim(gl.des).
        end.
    end.
/*end.*/
    if v-numlim > 0 then do:
        /* posting - limit*/
       find first lclimit where lclimit.bank = lc.bank and lclimit.cif = lc.cif and lclimit.number = v-numlim no-lock no-error.
       if avail lclimit then do:
        find first lclimith where lclimith.cif = lclimit.cif and lclimith.number = lclimit.number  and lclimith.kritcode = 'Revolv' no-lock no-error.
        if avail lclimith then v-revolv = lclimith.value1.
        if lookup(v-revolv,v-logsno) > 0 then assign v-dacc = '662540' v-cacc = '612540' v-text = 'невозобновляемым'.
        else assign v-dacc = '662530' v-cacc = '612530'.
        find first lclimith where lclimith.cif = lclimit.cif and lclimith.number = lclimit.number and lclimith.kritcode = 'lcCrc' no-lock no-error.
        if avail lclimith then v-limcrc = int(lclimith.value1).
        if v-crc = v-limcrc then v-lim-amount = v-lc-amount.
        else do:
            find first b-crc where b-crc.crc = v-limcrc no-lock no-error.
            if avail b-crc then v-lim-amount = round((v-lc-amount * crc.rate[1]) / b-crc.rate[1],2).
        end.
        i = i + 1.
        /*if s-lcprod <> 'pg' then find first lcres where lcres.LC = s-lc and not lcres.com and lcres.levD = 23 no-lock no-error.
                            else find first lcres where lcres.LC = s-lc and not lcres.com and lcres.levD = 1 and lcres.dacc = '605561' no-lock no-error.*/
        find first lclimitres where lclimitres.bank = lclimit.bank and lclimitres.cif = lclimit.cif and lclimitres.number = lclimit.number and lclimitres.lc = s-lc and lclimitres.info[1] = 'amend' no-lock no-error.
        /*debit*/
        if v-incdec = 1 then v-nazn = 'Списание доступного остатка по ' + v-text + ' кредитам в рамках ТФ, ' + v-cifname.
        else   v-nazn = 'Увеличение доступного остатка по ' + v-text + ' кредитам в рамках ТФ, ' + v-cifname.
        k = k + 1.
        create wrk.
        assign wrk.numdis = string(i)
               wrk.num = k
               wrk.dc  = 'Dt'
               wrk.acc = if avail lclimitres then lclimitres.dacc else if v-incdec = 1 then v-dacc else v-cacc
               wrk.cur = if  v-crc = v-limcrc then crc.code else b-crc.code
               wrk.sum = v-lim-amount
               wrk.jdt = if avail lclimitres then lclimitres.jdt  else g-today
               wrk.rem = if avail lclimitres then lclimitres.rem  else v-nazn
               wrk.gl  = int(wrk.acc).

            find first gl where gl.gl = wrk.gl no-lock no-error.
            if avail gl then wrk.gldes = trim(gl.des).

        /*Credit*/
        k = k + 1.
        create wrk.
        assign wrk.num = k
               wrk.dc  = 'Ct'
               wrk.acc = if avail lclimitres then lclimitres.cacc else if v-incdec = 1 then v-cacc else v-dacc
               wrk.gl  = int(wrk.acc)
               wrk.cur = if  v-crc = v-limcrc then crc.code else b-crc.code
               wrk.sum = v-lim-amount
               wrk.jdt = if avail lclimitres then lclimitres.jdt  else g-today
               wrk.rem = if avail lclimitres then lclimitres.rem  else v-nazn.

        find first gl where gl.gl = wrk.gl no-lock no-error.
        if avail gl then wrk.gldes = trim(gl.des).
       end.
    end.
end.

/* commissions */
for each lcamendres where lcamendres.lc = s-lc and lcamendres.lcamend = s-lcamend and lcamendres.com and lcamendres.amt <> 0 no-lock:
    i = i + 1.
    k = k + 1.
    create wrk.
    assign wrk.acc    = lcamendres.dacc
           wrk.dc     = 'Dt'
           wrk.num    = k
           wrk.numdis = string(i)
           wrk.sum    = lcamendres.amt.
    find first aaa where aaa.aaa = lcamendres.dacc no-lock no-error.
    if avail aaa then do:
        find first trxlev where trxlev.sub = "CIF" and trxlev.lev = lcamendres.levD and trxlev.gl = aaa.gl no-lock no-error.
        if avail trxlev then do:
            wrk.gl = trxlev.glr.
            find first gl where gl.gl = aaa.gl no-lock no-error.
            if avail gl then wrk.gldes = trim(gl.des).
        end.
    end.
    find first crc where crc.crc = lcamendres.crc no-lock no-error.
    if avail crc then wrk.cur = crc.code.

    if lcamendres.jh > 0 then wrk.jdt = lcamendres.jdt.
    else wrk.jdt = g-today.
    wrk.rem = lcamendres.rem.

    k = k + 1.
    create wrk.
    assign wrk.dc   = 'Ct'
           wrk.num  = k
           wrk.acc  = if not v-gar then lcamendres.cacc else '286920'
           wrk.sum  = lcamendres.amt.
           wrk.gl   = int(wrk.acc).
   find first gl where gl.gl = wrk.gl no-lock no-error.
          wrk.gldes = trim(gl.des).
   find first crc where crc.crc = lcamendres.crc no-lock no-error.
   if avail crc then wrk.cur = crc.code.

   if lcamendres.jh > 0 then wrk.jdt = lcamendres.jdt.
   else wrk.jdt = g-today.
   wrk.rem = lcamendres.rem.

    if v-gar then do:
    k = k + 1.
    create wrk.
    assign wrk.dc  = 'Dt'
           wrk.num = k
           wrk.gl = 286920
           wrk.acc = '286920'.
           find gl where gl.gl = wrk.gl no-lock no-error.
           if avail gl then wrk.gldes = gl.des.
           wrk.sum = lcamendres.amt.
           find first crc where crc.crc = lcamendres.crc no-lock no-error.
           if avail crc then wrk.cur = crc.code.
           if lcamendres.jh > 0 then wrk.jdt = lcamendres.jdt.
           else wrk.jdt = g-today.
           wrk.rem = if num-entries(lcamendres.rem,';') = 2 then entry(1,lcamendres.rem,';') else lcamendres.rem.

    k = k + 1.
    create wrk.
    assign wrk.dc  = 'Ct'
           wrk.num = k.
        find first tarif2 where tarif2.str5 = trim(lcamendres.comcode) /*tarif2.num  = substr(lcamendres.comcode,1,1) and tarif2.kod = substr(lcamendres.comcode,2)*/ and tarif2.stat = 'r' no-lock no-error.
        if avail tarif2 then
           assign
           wrk.gl = tarif2.kont
           wrk.acc = string(tarif2.kont)
           wrk.gldes = tarif2.pakal.
           wrk.sum = lcamendres.amt.
           find first crc where crc.crc = lcamendres.crc no-lock no-error.
           if avail crc then wrk.cur = crc.code.
           if lcamendres.jh > 0 then wrk.jdt = lcamendres.jdt.
           else wrk.jdt = g-today.
           wrk.rem = if num-entries(lcamendres.rem,';') = 2 then entry(1,lcamendres.rem,';') else lcamendres.rem.
   end.

end.

for each wrk where wrk.dc = 'Ct' and (wrk.gl = 285511 or wrk.gl = 224011) no-lock:
    v-sum2 = v-sum2 + wrk.sum.
end.

for each lcamendres where lcamendres.lc = s-lc and lcamendres.lcamend = s-lcamend and lcamendres.com = yes no-lock:
    v-sum1 = v-sum1 + lcamendres.amt.
end.

if v-collacc = v-comacc  then do:
    v-sum = v-sum1 + v-sum2.
    find first aaa where aaa.aaa = v-collacc no-lock no-error.
    if avail aaa then do:
        if v-sum > aaa.cbal - aaa.hbal then do:
            message "Lack of the balance!" view-as alert-box.
            return.
        end.
    end.
end.
else do:
    find first aaa where aaa.aaa = v-collacc no-lock no-error.
    if avail aaa then do:
        if v-sum2 > aaa.cbal - aaa.hbal then do:
            message "Lack of the balance of the Collateral Debit Account!" view-as alert-box.
            return.
        end.
    end.
    find first aaa where aaa.aaa = v-comacc no-lock no-error.
    if avail aaa then do:
        if v-sum1 > aaa.cbal - aaa.hbal then do:
            message " Lack of the balance Commissions Debit Account  !" view-as alert-box.
            return.
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
                                 "<p><b>Letter of Credit No / Номер Аккредитива " + s-lc + "</b><br>"
                                 "<b>Amendment No / Номер изменения " + string(s-lcamend) + "</b></p>".
    put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
                                 "<tr style=""font:bold"">"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">№ / Номер строки</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Debit/Credit / Дебет/Кредит</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Client Account Number / Счет </td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Ledger Account Number / Балансовый счет</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Ledger Account Description / Наменование Балансового счета</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Amount / Сумма</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Currency / Курс</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Value Date/Дата операции</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Narrative / Комментарии</td></tr>" skip.

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
        "<td>" string(wrk.jdt,'99/99/9999') "</td>"
        "<td>" wrk.rem "</td></tr>" skip.
    end.
    put stream m-out "</table></body></html>" skip.
    output stream m-out close.
    unix silent cptwin impl_postings.htm excel.
end.

OPEN QUERY  qt FOR EACH wrk.
ENABLE ALL WITH FRAME ft.
WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW. /*or choose of btn-e.*/
