/* lccpost.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Internal Charges - проводки по комиссиям
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
       15/03/2011 id00810
 * BASES
        BANK COMM
 * CHANGES
        08/04/2011 id00810 - иная комиссия, без тарификатора
        14/04/2011 id00810 - комиссия 997 за счет аппликанта или 997а - за счет бенефициара
        04/05/2011 id00810 - комиссия 996
        11/08/2011 id00810 - новый вид оплаты Chrgs at BNFs expense
        22/08/2011 evseev - убрал проверку ComAcc, если kritcode = 'opt' - NO. стр 47-65
        07/09/2011 id00810 - исправлена ошибка обработки критерия opt
        02/11/2011 id00810 - переменная s-type(тип комиссии)
        14/12/2011 id00810 - 2 критерия: сумма с НДС и без НДС для s-type = '3'
        30/01/2012 id00810 - для всех типов комиссий формирование постингов на основе lceventres
        17/02/2012 id00810 - заполнение даты в постингах комиссий
        11.06.2012 Lyubov  - добавила ЕКНП
        28.06.2012 Lyubov  - для гарантий проводки делаются иначе
        23.08.2012 Lyubov  - MetroComBank исправила на ForteBank
        23.01.2013 Lyubov  - ТЗ № 1274, для DC не проверяем покрытие
        09/08/2013 galina - ТЗ1886 отражаем проводки по комиссии через счета конвертации
        26/08/2013 galina - ТЗ2051 берем курс из crchis если тада проводки меньше текущей
        27/08/2013 galina - перекомпеляция
*/

{global.i}
define stream m-out.
def shared var s-lc     as   char.
def shared var s-event  like lcevent.event.
def shared var s-number like lcevent.number.
def shared var s-sts    like lcevent.sts.
def shared var s-lcprod as   char.
def shared var s-type   as   char.
def shared var v-cif    as   char.

def var v-comacc as char no-undo.
def var v-lccow  as char no-undo.
def var v-amount as char no-undo.
def var v-sum1   as deci no-undo.
def var v-lev    as int  no-undo.
/*def var v-sp     as char no-undo init '996a,997a'.*/
def var j        as int  no-undo.
def var v-tarif  as char no-undo.
def var v-gar    as logi no-undo.
def var v-crc    as int  no-undo.
def var v-crcc   as char no-undo.
def var v-amt    as deci no-undo.
def var v-amt1   as deci no-undo.
def var v-dacc   as char no-undo.
def var v-cacc   as char no-undo.
def var v-levC   as int  no-undo.
def var v-arp    as char no-undo.
def buffer b-lceventres for lceventres.

{LC.i}
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
def var i as int.
def var k as int.

define query qt for wrk.
define browse bt query qt
    displ wrk.numdis label "№"          format "x(3)"
          wrk.dc     label "Dt/Ct"      format "x(2)"
          wrk.acc    label "Client Acc" format "x(20)"
          wrk.gl     label "Ledger Acc" format "999999"
          wrk.gldes  label "Ledger Account Des" format "x(20)"
          wrk.sum    label "Amount"     format ">,>>>,>>9.99"
          wrk.cur    label "CCY"        format "x(3)"
          wrk.jdt    label "Value Dt"   format "99/99/99"
          wrk.rem    label "Narrative"  format "x(20)"
          wrk.kkk    label "KOD/KBE/KNP" format "x(15)"
          with width 115 row 11 15 down overlay no-label title "Postings" NO-ASSIGN SEPARATORS.

def button btn-e   label  " Print in Excel  ".

DEFINE FRAME ft
    bt   SKIP(1)
    btn-e SKIP
    WITH width 115 1 COLUMN SIDE-LABELS
    NO-BOX.

on "end-error" of frame ft do:
    hide frame ft no-pause.
end.

find first lch where lch.lc = s-lc and lch.kritcode = 'LCcrc' no-lock no-error.
if avail lch then v-crc = int(lch.value1).

if s-lcprod = 'pg' then v-gar = yes.
if s-type = '' then do:
    find first LCeventh where lceventh.bank = s-ourbank and LCeventh.LC = s-lc and lceventh.event = s-event and lceventh.number = s-number and LCeventh.kritcode = 'opt' no-lock no-error.
    if avail lceventh then s-type = if lceventh.value1 = 'yes' then '1' else '3'.
    else s-type = '1'.
end.

if lookup (s-type,'1,2,5,e') > 0  then do:
    if s-lcprod <> 'IDC' then do:
        find first lch where lch.lc = s-lc and lch.kritcode = 'Cover' no-lock no-error.
        if avail lch then v-lccow = lch.value1.
        if v-lccow = '' then do:
            message "Field Covered/uncovered is empty!" view-as alert-box error.
            return.
        end.
    end.

    find first lch where lch.lc = s-lc and lch.kritcode = 'ComAcc' no-lock no-error.
    if avail lch then v-comacc = lch.value1.
    if v-comacc = '' then do:
        message "Field ComAcc is empty!" view-as alert-box.
        return.
    end.


end.
    if s-type = '4' then do:
        find first sysc where sysc.sysc = 'LCARP' no-lock no-error.
        if avail sysc then do:
            if num-entries(sysc.chval) >= v-crc then v-arp = entry(v-crc,sysc.chval).
            else do:
                message "The value LCARP in SYSC is empty!" view-as alert-box error.
                return.
            end.
        end.
        if v-arp = '' then do:
            message "The value LCARP in SYSC is empty!" view-as alert-box error.
            return.
        end.
    end.

if lookup(s-type,'1,e') > 0 then do:
    for each lceventres where lceventres.lc = s-lc and lceventres.event = s-event and lceventres.number = s-number and lceventres.com and lceventres.amt <> 0 no-lock:
        i = i + 1.
        k = k + 1.
        create wrk.
        assign wrk.acc    = lceventres.dacc
               wrk.dc     = 'Dt'
               wrk.num    = k
               wrk.numdis = string(i)
               wrk.sum    = lceventres.amt.

        find cif where cif.cif = v-cif no-lock no-error.
        if avail cif then wrk.kkk = substr(cif.geo,3,1).
        find first sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = v-cif and sub-cod.d-cod = 'secek' no-lock no-error.
        if avail sub-cod then wrk.kkk = wrk.kkk + sub-cod.ccode + '/14/840'.

        if lceventres.levD = 25 and lceventres.comcode = '970' then do:
            find first tarif2 where tarif2.str5 = lceventres.comcode and tarif2.stat = 'r' no-lock no-error.
            assign wrk.gl    = 285531
                   wrk.gldes = if avail tarif2 then tarif2.pakal else ''.
        end.
        else if lceventres.comcode = '966' and lceventres.dacc = '285532' then do:
            find first tarif2 where tarif2.str5 = lceventres.comcode and tarif2.stat = 'r' no-lock no-error.
            assign wrk.gl = 285532
                   wrk.gldes = if avail tarif2 then tarif2.pakal else ''.
        end.
        else do:
            find first aaa where aaa.aaa = lceventres.dacc no-lock no-error.
            if avail aaa then do:
                find first trxlev where trxlev.sub = "CIF" and trxlev.lev = lceventres.levD and trxlev.gl = aaa.gl no-lock no-error.
                if avail trxlev then do:
                    wrk.gl = trxlev.glr.
                    find first gl where gl.gl = aaa.gl no-lock no-error.
                    if avail gl then wrk.gldes = trim(gl.des).
                end.
            end.
        end.
        find first crc where crc.crc = lceventres.crc no-lock no-error.
        if avail crc then wrk.cur = crc.code.

        if lceventres.jh > 0 then wrk.jdt = lceventres.jdt.
        else wrk.jdt = g-today.
        wrk.rem = lceventres.rem.

        k = k + 1.
        create wrk.
        assign wrk.dc  = 'Ct'
               wrk.num = k
               wrk.acc = lceventres.cacc
               wrk.sum = lceventres.amt.

        if lceventres.comcode = '970' and lceventres.levC = 25 then do:
            find first tarif2 where tarif2.str5 = lceventres.comcode and tarif2.stat = 'r' no-lock no-error.
            assign wrk.gl    = 285531
                   wrk.gldes = if avail tarif2 then tarif2.pakal else ''.
        end.
        else if lceventres.comcode = '966' and lceventres.cacc = '285532' then do:
            find first tarif2 where tarif2.str5 = lceventres.comcode and tarif2.stat = 'r' no-lock no-error.
            assign wrk.gl = 285532
                   wrk.gldes = if avail tarif2 then tarif2.pakal else ''.
        end.
        else if lookup(s-lcprod,'PG,EXPG') > 0 and lookup(lceventres.comcode,'967,968,969,952,955,956,957,953,954,958,959,941,942,943,944,945,946,947') > 0 then do:
             assign wrk.gl = 286920.
                    wrk.acc = '286920'.
                    find gl where gl.gl = wrk.gl no-lock no-error.
                    if avail gl then wrk.gldes = gl.des.
        end.
        else if lceventres.levC = 1 then do:
            if lceventres.levD = 25 or lceventres.dacc = '285532' then do:
                find first aaa where aaa.aaa = lceventres.cacc no-lock no-error.
                if avail aaa then do:
                    find first trxlev where trxlev.sub = "CIF" and trxlev.lev = lceventres.levC and trxlev.gl = aaa.gl no-lock no-error.
                    if avail trxlev then do:
                        wrk.gl = trxlev.glr.
                        find first gl where gl.gl = aaa.gl no-lock no-error.
                        if avail gl then wrk.gldes = trim(gl.des).
                    end.
                end.
            end.
            else do:
                find first tarif2 where tarif2.str5 = lceventres.comcode and tarif2.stat = 'r' no-lock no-error.
                if avail tarif2 then
                    assign wrk.gl    = tarif2.kont
                           wrk.gldes = tarif2.pakal.
                else if lceventres.comcode = '9990' then assign wrk.gl = int(lceventres.cacc) wrk.gldes = 'Иные комиссии без учета НДС'.

            end.
        end.


        find first crc where crc.crc = lceventres.crc no-lock no-error.
        if avail crc then wrk.cur = crc.code.

        if lceventres.jh > 0 then wrk.jdt = lceventres.jdt.
        else wrk.jdt = g-today.
        wrk.rem = lceventres.rem.

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
    for each lceventres where lceventres.lc = s-lc and lceventres.event = s-event and lceventres.number = s-number and lceventres.com and lceventres.jh = 0 and lceventres.comcode ne '996a' and lceventres.comcode ne '997a' no-lock:
        v-sum1 = v-sum1 + lceventres.amt.
    end.

    find first lch where lch.lc = s-lc and lch.kritcode = 'ComAcc' no-lock no-error.
    if avail lch then do:
        find first aaa where aaa.aaa = lch.value1 no-lock no-error.
        if avail aaa then do:
            if v-sum1 > aaa.cbal - aaa.hbal then do:
                message " Lack of the balance Commissions Debit Account  !" view-as alert-box.
                return.
            end.
        end.
    end.
end.
else do:

    for each lceventres where lceventres.lc = s-lc and lceventres.event = s-event and lceventres.number = s-number and lceventres.com and lceventres.amt > 0 no-lock:
    i = i + 1.
    k = k + 1.
    create wrk.
    assign  wrk.dc     = 'Dt'
            wrk.num    = k
            wrk.numdis = string(i)
            wrk.acc    = lceventres.dacc
            wrk.sum    = lceventres.amt

            wrk.jdt    = if lceventres.jh = 0 then g-today else lceventres.jdt
            wrk.rem    = lceventres.rem .
    find first crc where crc.crc = lceventres.crc no-lock no-error.
    if avail crc then wrk.cur = crc.code.

    if s-type = '2' and not v-gar then do:
        if lceventres.dacc = '185511' or lceventres.dacc = '185512' then wrk.gl = int(wrk.acc).
        else do:
            find first aaa where aaa.aaa = v-comacc no-lock no-error.
            if avail aaa then do:
                find first trxlev where trxlev.sub = "CIF" and trxlev.lev = 25 and trxlev.gl = aaa.gl no-lock no-error.
                if avail trxlev then wrk.gl = trxlev.glr.
            end.
        end.
    end.
    else if s-type = '4' then do:
        find first arp where arp.arp = wrk.acc no-lock no-error.
        if avail arp then wrk.gl = arp.gl.
    end.
    else if s-type = '5' then do:
        find first aaa where aaa.aaa = v-comacc no-lock no-error.
        if avail aaa then wrk.gl = aaa.gl.
        find cif where cif.cif = v-cif no-lock no-error.
        if avail cif then wrk.kkk = substr(cif.geo,3,1).
        find first sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = v-cif and sub-cod.d-cod = 'secek' no-lock no-error.
        if avail sub-cod then wrk.kkk = wrk.kkk + sub-cod.ccode + '/14/840'.
    end.
    else wrk.gl = int(wrk.acc).
    find first gl where gl.gl = wrk.gl no-lock no-error.
    if avail gl then wrk.gldes = trim(gl.des).

    if (s-type = '3' or s-type = '4') and lceventres.crc <> 1 then do:
        k = k + 1.
        create wrk.
        assign wrk.dc     = 'Ct'
               wrk.num    = k
               /*wrk.numdis = string(i)*/
               wrk.acc    = '285800'
               wrk.gl     = 285800
               wrk.sum    = lceventres.amt
               wrk.jdt    = if lceventres.jh = 0 then g-today else lceventres.jdt
               wrk.rem    = lceventres.rem .

        v-amt1 = lceventres.amt.
        find first crc where crc.crc = lceventres.crc no-lock no-error.
        if avail crc then do:
            wrk.cur = crc.code.
            if (lceventres.jh = 0 or (lceventres.jh > 0 and g-today = lceventres.jdt) )and crc.crc <> 1 then v-amt1 = lceventres.amt * crc.rate[1].
        end.
        find first gl where gl.gl = wrk.gl no-lock no-error.
        if avail gl then wrk.gldes = trim(gl.des).

        if lceventres.jh > 0 and g-today > lceventres.jdt then do:
            find first crchis where crchis.rdt = lceventres.jdt and crchis.crc = lceventres.crc no-lock no-error.
            if avail crchis then v-amt1 = lceventres.amt * crchis.rate[1].
        end.
        k = k + 1.
        create wrk.
        assign wrk.dc     = 'Dt'
               wrk.num    = k
               /*wrk.numdis = string(i)*/
               wrk.acc    = '185900'
               wrk.gl     = 185900
               wrk.sum    = v-amt1
               wrk.jdt    = if lceventres.jh = 0 then g-today else lceventres.jdt
               wrk.rem    = lceventres.rem
               wrk.cur    = 'KZT'.
        find first gl where gl.gl = wrk.gl no-lock no-error.
        if avail gl then wrk.gldes = trim(gl.des).

        k = k + 1.
        create wrk.
        assign wrk.dc  = 'Ct'
               wrk.num = k
               wrk.acc = lceventres.cacc
               wrk.sum = v-amt1
               wrk.jdt = if lceventres.jh = 0 then g-today else lceventres.jdt
               wrk.rem = lceventres.rem
               wrk.cur = 'KZT'
               wrk.gl = int(wrk.acc).
        find first gl where gl.gl = wrk.gl no-lock no-error.
        if avail gl then wrk.gldes = trim(gl.des).
    end.
    else do:
        k = k + 1.
        create wrk.
        assign wrk.dc  = 'Ct'
               wrk.num = k
               wrk.acc = lceventres.cacc
               wrk.sum = lceventres.amt
               wrk.jdt = if lceventres.jh = 0 then g-today else lceventres.jdt
               wrk.rem = lceventres.rem.
        find first crc where crc.crc = lceventres.crc no-lock no-error.
        if avail crc then wrk.cur = crc.code.

        if s-type = '2' and not v-gar then do:
            if lceventres.cacc = '185511' or lceventres.cacc = '185512' then wrk.gl = int(wrk.acc).
            else do:
                find first aaa where aaa.aaa = v-comacc no-lock no-error.
                if avail aaa then do:
                    find first trxlev where trxlev.sub = "CIF" and trxlev.lev = 25 and trxlev.gl = aaa.gl no-lock no-error.
                    if avail trxlev then wrk.gl = trxlev.glr.
                end.
            end.
        end.
        else wrk.gl = int(wrk.acc).

        find first gl where gl.gl = wrk.gl no-lock no-error.
        if avail gl then wrk.gldes = trim(gl.des).
        end.
    end.
end.

on choose of btn-e do:

    output stream m-out to impl_postings.htm.
    put stream m-out unformatted "<html><head><title>ForteBank</title>"
                                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

    put stream m-out unformatted "<br><br><h3> ForteBank </h3>" skip
                                 "<p><b>Letter of Credit No / Номер Аккредитива " + s-lc + "</b><br>"
                                 "<b>Event No / Номер события " + string(s-number) + "</b></p>".
    put stream m-out unformatted "<table border=""1"" cellpadding=""11"" cellspacing=""0"" style=""border-collapse: collapse"">"
                                 "<tr style=""font:bold"">"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">№ / Номер строки</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Debit/Credit / Дебет/Кредит</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Client Account Number / Счет </td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Ledger Account  Number / Балансовый счет</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Ledger Account  Description / Наменование Балансового счета</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Amount / Сумма</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Currency / Курс</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Value Date/Дата операции</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Narrative / Комментарии</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">EKNP / ЕКНП</td></tr>" skip.

    for each wrk no-lock:
        put stream m-out unformatted
        "<tr>".
/*        if wrk.numdis <> '' then put stream m-out unformatted "<td rowspan = 2>" wrk.numdis "</td>".*/
        put stream m-out unformatted "<td>" wrk.numdis "</td>".
        put stream m-out unformatted
        "<td>" wrk.dc "</td>"
        "<td>`" string(wrk.acc) "</td>"

        "<td>`" string(wrk.gl) "</td>"
        "<td>" wrk.gldes "</td>"

        "<td>" replace(replace(trim(string(wrk.sum,'>>>,>>>,>>9.99')),',',' '),'.',',') "</td>"
        "<td>" wrk.cur "</td>"
        "<td>" string(wrk.jdt,'99/99/9999') "</td>"
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
