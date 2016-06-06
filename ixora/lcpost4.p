/* lcpost4.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Expire - вывод проводок
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
       06/04/2011 id00810
 * BASES
        BANK COMM
 * CHANGES
    29/07/2011 id00810 - счет DepAcc вместо 285521 для покрытого PG (c 01/08/2011)
    04/10/2011 id00810 - учет лимита
    19.06.2012 Lyubov  - добавила проводки по комиссиям, для PG/EXPG создаются 2 проводки 220310 -> 286920 и 286920 -> 4612(20/11)
    10.07.2012 Lyubov  - добавила проводки по списанию несамотризированного остатка
    23.08.2012 Lyubov  - MetroComBank исправила на ForteBank
    20/09/2013 Luiza   - ТЗ 1916 изменение поиска записи в таблице tarif2
 */

{global.i}
define stream m-out.
def shared var s-lc       like lc.lc.
def shared var s-event    like lcevent.event.
def shared var s-number   like lcevent.number.
def shared var s-sts      like lcevent.sts.
def shared var s-type     as   char.
def shared var s-lcprod   as   char.
def shared var v-cif      as   char.
def shared var v-cifname  as   char.
def shared var v-rcacc    as   char.
def shared var s-ourbank as char no-undo.
def var v-lccow   as char no-undo.
def var v-collacc as char no-undo.
def var v-crc     as char no-undo.
def var v-comacc  as char no-undo.
def var v-depacc  as char no-undo.
def var v-dacc    as char no-undo.
def var v-cacc    as char no-undo.
def var v-gl      as int  no-undo.
def var v-sum1    as deci no-undo.
def var v-sum2    as deci no-undo.
def var v-sum3    as deci no-undo.
def var i         as int  no-undo.
def var k         as int  no-undo.
def var v-gar     as logi no-undo.
def var v-levD    as int  no-undo.
def var v-levC    as int  no-undo.
def var v-dlacc   as char no-undo init '612530'.
def var v-clacc   as char no-undo init '662530'.
def var v-text    as char no-undo init 'возобновляемым'.
def var v-limcrc  as int  no-undo.
def buffer b-crc for crc.

find first lc where lc.lc = s-lc no-lock no-error.
if not avail lc then return.
if s-lcprod = 'pg' then v-gar = yes.

find first lch where lch.lc = s-lc and lch.kritcode = 'Cover' no-lock no-error.
if avail lch then v-lccow = lch.value1.
if v-lccow = '' then do:
    message "Field Covered/uncovered is empty!" view-as alert-box error.
    return.
end.

find first lch where lch.lc = s-lc and lch.kritcode = 'lcCrc' no-lock no-error.
if avail lch then do:
   find first crc where crc.crc = int(lch.value1) no-lock no-error.
   if avail crc then v-crc = crc.code.
end.

if v-lccow = '0' then do:
    find first lch where lch.lc = s-lc and lch.kritcode = 'CollACC' no-lock no-error.
    if avail lch then v-collacc = lch.value1.
    if v-collacc = '' then do:
        message "Field CollAcc is empty!" view-as alert-box error.
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
    message "Field ComAcc is empty!" view-as alert-box error.
    return.
end.

find first lceventh where lceventh.bank = lc.bank and lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'OutBal' no-lock no-error.
if avail lceventh then v-sum1 = deci(lceventh.value1).

find first lceventh where lceventh.bank = lc.bank and lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'Claims' no-lock no-error.
if avail lceventh then v-sum2 = deci(lceventh.value1).

find first lceventh where lceventh.bank = lc.bank and lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'Limits' no-lock no-error.
if avail lceventh then v-sum3 = deci(lceventh.value1).

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
    displ wrk.numdis label "№"                          format "x(3)"
          wrk.dc     label "Dt/Ct"                      format "x(2)"
          wrk.acc    label "Client Acc"                 format "x(20)"
          wrk.gl     label "Leger Acc"                  format "999999"
          wrk.gldes  label "Leger Account  Description" format "x(30)"
          wrk.sum    label "Amount"                     format ">>>,>>>,>>9.99"
          wrk.cur    label "CCY"                        format "x(3)"
          wrk.jdt    label "Value Dt"                   format "99/99/99"
          wrk.rem    label "Narrative"                  format "x(30)"
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

if v-sum1 <> 0 then do:
   /*1-st posting*/
   i = 1.
   if not v-gar then find first lceventres where lceventres.lc = s-lc and lceventres.event = s-event and lceventres.number = s-number and lceventres.levD = 22 no-lock no-error.
                else find first lceventres where lceventres.lc = s-lc and lceventres.event = s-event and lceventres.number = s-number and lceventres.levD = 1 and lceventres.dacc = v-depacc no-lock no-error.
   k = k + 1.
   create wrk.
   assign wrk.numdis = string(i)
          wrk.num    = k
          wrk.dc     = 'Dt'
          wrk.acc    = if avail lceventres then lceventres.dacc else if not v-gar then v-collacc else v-depacc
          wrk.cur    = v-crc
          wrk.sum    = v-sum1
          wrk.jdt    = if avail lceventres then lceventres.jdt else g-today
          wrk.rem    = if avail lceventres then lceventres.rem else "Списание покрытия " + s-lc
          v-levD     = if avail lceventres then lceventres.levD else if not v-gar then 22 else 1.


   find first aaa where aaa.aaa = wrk.acc no-lock no-error.
   if avail aaa then do:
      find first trxlev where trxlev.sub = "CIF" and trxlev.lev = v-levD and trxlev.gl = aaa.gl no-lock no-error.
      if avail trxlev then v-gl = trxlev.glr.
   end.

   wrk.gl = v-gl.
   find first gl where gl.gl = wrk.gl no-lock no-error.
   if avail gl then wrk.gldes = trim(gl.des).

   /*Credit*/
   k = k + 1.
   create wrk.
   assign wrk.num = k
          wrk.dc  = 'Ct'
          wrk.acc = if avail lceventres then lceventres.cacc else v-collacc
          wrk.cur    = v-crc
          wrk.sum    = v-sum1
          wrk.jdt    = if avail lceventres then lceventres.jdt else g-today
          wrk.rem    = if avail lceventres then lceventres.rem else "Списание покрытия " + s-lc.
   find first aaa where aaa.aaa = wrk.acc no-lock no-error.
   if avail aaa then do:
       find first trxlev where trxlev.sub = "CIF" and trxlev.lev = 1 and trxlev.gl = aaa.gl no-lock no-error.
       if avail trxlev then do:
           wrk.gl = trxlev.glr.
           find first gl where gl.gl = trxlev.glr no-lock no-error.
           if avail gl then wrk.gldes = trim(gl.des).
       end.
   end.
end.

if v-sum2 <> 0 then do:
   /*2-nd posting*/
   i = i + 1.
   if not v-gar then do:
    assign v-dacc = if v-lccow = '0' then '652000' else '650510'.
    find first lceventres where lceventres.lc = s-lc and lceventres.event = s-event and lceventres.number = s-number and lceventres.levC = (if v-lccow = '0' then 23 else 24) no-lock no-error.
   end.
   else do:
    assign v-dacc = if v-lccow = '0' then '655561' else '655562'.
    find first lceventres where lceventres.lc = s-lc and lceventres.event = s-event and lceventres.number = s-number and  lceventres.levC = 1 and (lceventres.cacc = '605561' or lceventres.cacc = '605562') no-lock no-error.
   end.
   /*debit*/
   k = k + 1.

   create wrk.
   assign wrk.numdis = string(i)
          wrk.num    = k
          wrk.dc     = 'Dt'
          wrk.acc    = if avail lceventres then lceventres.dacc else v-dacc
          wrk.gl     = int(wrk.acc)
          wrk.cur    = v-crc
          wrk.sum    = v-sum2
          wrk.jdt    = if avail lceventres then lceventres.jdt else g-today
          wrk.rem    = if avail lceventres then lceventres.rem else 'Требования/обязательства ' + s-lc.
   find first gl where gl.gl = wrk.gl no-lock no-error.
   if avail gl then wrk.gldes = trim(gl.des).

   /*Credit*/
   k = k + 1.
   if not v-gar then assign v-cacc = if v-lccow = '0' then v-collacc else v-comacc.
   else do:
    if v-lccow = '0' then assign v-cacc = '605561' v-gl = 605561.
                     else assign v-cacc = '605562' v-gl = 605562.
   end.
   create wrk.
   assign wrk.num = k
          wrk.dc  = 'Ct'
          wrk.acc = if avail lceventres then lceventres.cacc else v-cacc
          wrk.cur = v-crc
          wrk.sum = v-sum2
          wrk.jdt = if avail lceventres then lceventres.jdt else g-today
          wrk.rem = if avail lceventres then lceventres.rem else 'Требования/обязательства ' + s-lc.
   if s-lcprod = 'imlc' then do:
    find first aaa where aaa.aaa = wrk.acc no-lock no-error.
    if avail aaa then do:
        find first trxlev where trxlev.sub = "CIF" and trxlev.lev = (if v-lccow = '0' then 23 else 24) and trxlev.gl = aaa.gl no-lock no-error.
        if avail trxlev then v-gl = trxlev.glr.
    end.
   end.
   wrk.gl = v-gl.
   find first gl where gl.gl = wrk.gl no-lock no-error.
   if avail gl then wrk.gldes = trim(gl.des).

end.
if v-sum3 <> 0 then do:
   /* posting - limit*/
    find first lch where lch.lc = s-lc and lch.kritcode = 'NLim' no-lock no-error.
    if not avail lch then return.
    find first lclimith where lclimith.cif = v-cif and lclimith.number = int(lch.value1) and lclimith.kritcode = 'lcCrc' no-lock no-error.
    if avail lclimith then do: v-limcrc = int(lclimith.value1).
        find first b-crc where b-crc.crc = v-limcrc no-lock no-error.
        i = i + 1.
        find first lclimitres where lclimitres.bank = s-ourbank and lclimitres.cif = v-cif and lclimitres.number = int(lch.value1) and lclimitres.lc = s-lc and lclimitres.info[1] = 'expire' no-lock no-error.
        /*debit*/
        k = k + 1.
        create wrk.
        assign wrk.numdis = string(i)
               wrk.num = k
               wrk.dc  = 'Dt'
               wrk.acc = if avail lclimitres then lclimitres.dacc else v-dlacc
               wrk.cur = b-crc.code
               wrk.sum = v-sum3
               wrk.jdt = if avail lclimitres then lclimitres.jdt  else g-today
               wrk.rem = if avail lclimitres then lclimitres.rem  else 'Возобновление доступного остатка по ' + v-text + ' кредитам в рамках ТФ, ' + v-cifname
               wrk.gl  = int(wrk.acc).

            find first gl where gl.gl = wrk.gl no-lock no-error.
            if avail gl then wrk.gldes = trim(gl.des).

        /*Credit*/
        k = k + 1.
        create wrk.
        assign wrk.num = k
               wrk.dc  = 'Ct'
               wrk.acc = if avail lclimitres then lclimitres.cacc else v-clacc
               wrk.gl  = int(wrk.acc)
               wrk.cur = b-crc.code
               wrk.sum = v-sum3
               wrk.jdt = if avail lclimitres then lclimitres.jdt  else g-today
               wrk.rem = if avail lclimitres then lclimitres.rem  else 'Возобновление доступного остатка по ' + v-text + ' кредитам в рамках ТФ, ' + v-cifname.

        find first gl where gl.gl = wrk.gl no-lock no-error.
        if avail gl then wrk.gldes = trim(gl.des).
    end.
end.

if s-event = 'cnl' and v-lccow = '1' then do:
   /* risk commission posting */

    /*debit*/
    find last lc where lc.lc = s-lc no-lock no-error.
    find first lcres where lcres.lc = s-lc and lookup(lcres.comcod,'966,970') > 0 no-lock no-error.
    find first b-crc where b-crc.crc = lcres.crc no-lock no-error.
    i = i + 1.
    k = k + 1.
    create wrk.
    assign wrk.numdis = string(i)
           wrk.num = k
           wrk.dc  = 'Dt'
           wrk.acc = if not v-gar then '285531' else '285532'
           wrk.cur = b-crc.code
           wrk.sum = lc.comsum
           wrk.jdt = g-today
           wrk.rem = if v-rcacc = '1' then 'Возврат суммы излишне уплаченного комиссионного вознаграждения по ' + s-lc
                                      else 'Списание несамортизированного комиссионного вознаграждения по ' + s-lc
           wrk.gl  = int(wrk.acc).

        find first gl where gl.gl = wrk.gl no-lock no-error.
        if avail gl then wrk.gldes = trim(gl.des).

    /*Credit*/
    k = k + 1.
    create wrk.
    assign wrk.num = k
           wrk.dc  = 'Ct'
           wrk.acc = if v-rcacc = '1' then v-comacc else '461220'
           wrk.gl  = if v-rcacc = '1' then 220310 else 461220
           wrk.cur = b-crc.code
           wrk.sum = lc.comsum
           wrk.jdt = g-today
           wrk.rem = if v-rcacc = '1' then 'Возврат суммы излишне уплаченного комиссионного вознаграждения по ' + s-lc
                                      else 'Списание несамортизированного комиссионного вознаграждения по ' + s-lc.

    find first gl where gl.gl = wrk.gl no-lock no-error.
    if avail gl then wrk.gldes = trim(gl.des).
end.

/*Commission posting*/
find first lceventres where lceventres.lc = s-lc no-lock no-error.
if avail lceventres then do:
    for each lceventres where lceventres.lc = s-lc and lceventres.event = s-event and lceventres.number = s-number and lceventres.com and lceventres.amt <> 0 and lookup(lceventres.comcod,'966,970') = 0 no-lock:
        i = i + 1.
        k = k + 1.
        create wrk.
        assign wrk.acc = lceventres.dacc
               wrk.dc  = 'Dt'
               wrk.num = k.
               wrk.numdis = string(i).
        find first aaa where aaa.aaa = lceventres.dacc no-lock no-error.
        if avail aaa then do:
            find first trxlev where trxlev.sub = "CIF" and trxlev.lev = lceventres.levD and trxlev.gl = aaa.gl no-lock no-error.
            if avail trxlev then do:
                wrk.gl = trxlev.glr.
                find first gl where gl.gl = aaa.gl no-lock no-error.
                if avail gl then wrk.gldes = trim(gl.des).
            end.

        end.
        wrk.sum = lceventres.amt.

        find first crc where crc.crc = lceventres.crc no-lock no-error.
        if avail crc then wrk.cur = crc.code.

        if lceventres.jh > 0 then wrk.jdt = lceventres.jdt.
        else wrk.jdt = g-today.
        wrk.rem = if num-entries(lceventres.rem,';') = 2 then entry(1,lceventres.rem,';') else lceventres.rem.

        k = k + 1.
        create wrk.
        assign wrk.dc  = 'Ct'
               wrk.num = k.

            if lceventres.comcode = '9990' then
            assign wrk.gl = int(lceventres.cacc)
                   wrk.acc = lceventres.cacc
                   wrk.gldes = 'Иные комиссии без учета НДС'.

            find first tarif2 where tarif2.str5 = trim(lceventres.comcode) /*tarif2.num  = substr(lceventres.comcode,1,1) and tarif2.kod = substr(lceventres.comcode,2)*/  and tarif2.stat = 'r' no-lock no-error.
            if avail tarif2 then do:

                if lceventres.comcode = '970' then do:
                    assign wrk.gl = 285531
                          wrk.acc = lceventres.cacc
                          wrk.gldes = tarif2.pakal.
                end.

                else if lceventres.comcode = '966' and lceventres.cacc = '285532' then do:
                    find first tarif2 where tarif2.str5 = lceventres.comcode and tarif2.stat = 'r' no-lock no-error.
                    assign wrk.gl = 285532
                           wrk.acc = lceventres.cacc
                           wrk.gldes = if avail tarif2 then tarif2.pakal else ''.
                end.

                else if lookup(s-lcprod,'PG,EXPG') > 0 and lookup(lceventres.comcode,'967,968,969,952,955,956,957,953,954,958,959,941,942,943,944,945,946,947') > 0 then do:
                     assign wrk.gl = 286920.
                            wrk.acc = '286920'.
                            find gl where gl.gl = wrk.gl no-lock no-error.
                            if avail gl then wrk.gldes = gl.des.
                end.

                else do:
                     assign wrk.gl = tarif2.kont
                            wrk.acc = lceventres.cacc
                            wrk.gldes = tarif2.pakal.
                end.
            end.

        wrk.sum = lceventres.amt.
        find first crc where crc.crc = lceventres.crc no-lock no-error.
        if avail crc then wrk.cur = crc.code.

        if lceventres.jh > 0 then wrk.jdt = lceventres.jdt.
        else wrk.jdt = g-today.
        wrk.rem = if num-entries(lceventres.rem,';') = 2 then entry(1,lceventres.rem,';') else lceventres.rem.

        if lookup(s-lcprod,'PG,EXPG') > 0 and lookup(lceventres.comcode,'967,968,969,952,955,956,957,953,954,958,959,941,942,943,944,945,946,947') > 0 then do:
            k = k + 1.
            create wrk.
            assign wrk.dc  = 'Dt'
                   wrk.num = k
                   wrk.gl = 286920
                   wrk.acc = '286920'.
                   find gl where gl.gl = wrk.gl no-lock no-error.
                   if avail gl then wrk.gldes = gl.des.
                   wrk.sum = lceventres.amt.
                   find first crc where crc.crc = lceventres.crc no-lock no-error.
                   if avail crc then wrk.cur = crc.code.
                   if lceventres.jh > 0 then wrk.jdt = lceventres.jdt.
                   else wrk.jdt = g-today.
                   wrk.rem = if num-entries(lceventres.rem,';') = 2 then entry(1,lceventres.rem,';') else lceventres.rem.

            k = k + 1.
            create wrk.
            assign wrk.dc  = 'Ct'
                   wrk.num = k.
                find first tarif2 where tarif2.num  = substr(lceventres.comcode,1,1) and tarif2.kod = substr(lceventres.comcode,2) and tarif2.stat = 'r' no-lock no-error.
                if avail tarif2 then
                   assign
                   wrk.gl = tarif2.kont
                   wrk.acc = string(tarif2.kont)
                   wrk.gldes = tarif2.pakal.
                   wrk.sum = lceventres.amt.
                   find first crc where crc.crc = lceventres.crc no-lock no-error.
                   if avail crc then wrk.cur = crc.code.
                   if lceventres.jh > 0 then wrk.jdt = lceventres.jdt.
                   else wrk.jdt = g-today.
                   wrk.rem = if num-entries(lceventres.rem,';') = 2 then entry(1,lceventres.rem,';') else lceventres.rem.
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
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Leger Account  Number / Балансовый счет</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Leger Account  Description / Наменование Балансового счета</td>"
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