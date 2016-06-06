/* lcrep3.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Monthly Report
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
        16.07.2012 Lyubov
 * BASES
        BANK COMM
 * CHANGES
        13.08.2012 Lyubov - подправила сумму комиссий
        05.09.2013 Lyubov - ТЗ 2072, ищем последний курс до даты проводки

*/

{global.i}

def var v-ref     as char init '*'.
def var v-appl    as char init '*'.
def var v-bnf     as char init '*'.
def var v-issdt   as date.
def var v-expdt   as date.
def var v-cov     as char init '*'.
def var v-confr   as char init '*'.
def var v-covlct  as char init '*'.
def var v-avw     as char init '*'.
def var v-orgamt  as deci format ">,>>>,>>>,>>>,>>9.99" init 0.
def var v-curamt  as deci format ">,>>>,>>>,>>>,>>9.99" init 0.
def var v-comamt  as deci format ">,>>>,>>>,>>>,>>9.99" init 0.
def var v-sts     as char init '*'.
def var v-sum     as deci.
def var v-per     as inte.
def var vbank     as char.

def temp-table wrk
field ref     as char
field appl    as char
field bnf     as char
field issdt   as char
field expdt   as char
field cov     as char
field confr   as char
field covlct  as char
field avw     as char
field orgamt  as deci
field curamt  as deci
field comamt  as deci
field sts     as char .

def buffer b-lch1 for lch.
def buffer b-lch2 for lch.
def buffer b-lch3 for lch.
def buffer b-lch4 for lch.
def buffer b-lch5 for lch.
def buffer b-lch6 for lch.
def buffer b-lch7 for lch.

form
    v-ref      label 'Reference Number   ' format "x(10)" skip
    v-appl     label 'Applicant code     ' format "x(6)" skip
    v-bnf      label 'Beneficiary        ' format "x(35)" skip
    v-issdt    label 'Issue Date         ' format "99/99/9999" skip
    v-expdt    label 'Expiry Date        ' format "99/99/9999" skip
    v-cov      label 'Cover              ' format "x(15)" skip
    v-confr    label 'Confirmation       ' format "x(15)" skip
    v-covlct   label 'Cover Location     ' format "x(15)" skip
    v-avw      label 'Available with     ' format "x(35)" skip
    v-orgamt   label 'Original Amount    ' format ">,>>>,>>>,999,999.99" skip
    v-curamt   label 'Current Amount     ' format ">,>>>,>>>,999,999.99" skip
    v-comamt   label 'Commission Amount  ' format ">,>>>,>>>,999,999.99" skip
    v-sts      label 'Status             ' format "x(10)" skip
    with width 70 side-label overlay centered row 3 frame frmon.

on help of v-covlct in frame frmon do:
    {itemlist.i
     &file = "codfr"
     &frame = "row 6 centered scroll 1 20 down width 91 overlay "
     &where = " codfr.codfr = 'lccovloc' and codfr.code <> 'msc' "
     &flddisp = " codfr.code label 'Code' format 'x(8)' codfr.name[1] label 'value' format 'x(80)' "
     &chkey = "code"
     &index  = "cdco_idx"
     &end = "if keyfunction(lastkey) = 'end-error' then return."
    }
    v-covlct = codfr.code.
    display v-covlct with frame frmon.
end.
on help of v-cov in frame frmon do:
    {itemlist.i
     &file = "codfr"
     &frame = "row 6 centered scroll 1 20 down width 91 overlay "
     &where = " codfr.codfr = 'lccover' and codfr.code <> 'msc' "
     &flddisp = " codfr.code label 'Code' format 'x(8)' codfr.name[1] label 'value' format 'x(80)' "
     &chkey = "code"
     &index  = "cdco_idx"
     &end = "if keyfunction(lastkey) = 'end-error' then return."
    }
    v-cov = codfr.code + ' - ' + codfr.name[1].
    display v-cov with frame frmon.
end.
on help of v-confr in frame frmon do:
    {itemlist.i
     &file = "codfr"
     &frame = "row 6 centered scroll 1 20 down width 91 overlay "
     &where = " codfr.codfr = 'lcconf' and codfr.code <> 'msc' "
     &flddisp = " codfr.code label 'Code' format 'x(8)' codfr.name[1] label 'value' format 'x(80)' "
     &chkey = "code"
     &index  = "cdco_idx"
     &end = "if keyfunction(lastkey) = 'end-error' then return."
    }
    v-confr = codfr.code + ' - ' + codfr.name[1].
    display v-confr with frame frmon.
end.

update v-ref v-appl v-bnf v-issdt v-expdt v-cov v-confr v-covlct v-avw v-orgamt v-curamt v-comamt v-sts with frame frmon.

hide frame lcmon.

define stream m-out.
output stream m-out to month_rep.htm.
put stream m-out unformatted "<html><head><title>Monthly Report</title>"
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream m-out unformatted "<br><br><h3>FORTEBANK</h3><br>" skip.
put stream m-out unformatted "<h3>Monthly Report</h3><br>" skip.

put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
                        "<tr style=""font:bold"">"
/*1 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Ref-nce</TD>"
/*2 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Appl</TD>"
/*3 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Bnf</TD>"
/*4 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Issue Date</TD>"
/*5 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Expiry Date</TD>"
/*6 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Cover</TD>"
/*7 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Confirm-n</TD>"
/*8 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Cover Locat.</TD>"
/*9 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Avail. with</TD>"
/*10 */                 "<td bgcolor=""#C0C0C0"" align=""center"">Original Amt</TD>"
/*11 */                 "<td bgcolor=""#C0C0C0"" align=""center"">Current Amt</TD>"
/*12 */                 "<td bgcolor=""#C0C0C0"" align=""center"">Commission Amt</TD>"
/*13 */                 "<td bgcolor=""#C0C0C0"" align=""center"">Status</TD>"
                        "</TR>" skip.

FIND FIRST SYSC WHERE SYSC.SYSC = "OURBNK" NO-LOCK NO-ERROR.
IF AVAIL SYSC AND SYSC.CHVAL <> '' THEN DO:
    IF SYSC.CHVAL <> "TXB00" THEN VBANK = SYSC.CHVAL.
    ELSE VBANK = '*'.
END.

for each lc where can-do(v-ref,lc.lc) and can-do(v-appl,lc.cif) and can-do(v-sts,lc.lcsts) and can-do(VBANK,lc.bank) no-lock,
    each b-lch1 of lc where b-lch1.kritcod = 'Cover'   and can-do(substr(v-cov,1,1),  b-lch1.value1) no-lock,
    each b-lch4 of lc where b-lch4.kritcod = 'Benef'  no-lock,
    each b-lch5 of lc where b-lch5.kritcod = 'Dtexp'  no-lock,
    each b-lch6 of lc where b-lch6.kritcod = 'Amount' no-lock:

    if v-issdt = ? or v-issdt = lc.rwhn then do:
    if v-bnf = '*' or (b-lch4.value1 matches '*' + v-bnf + '*') then do:
    if v-covlct = '*' or (b-lch1.value1 = '0' and ((lc.lc begins 'PG' and v-covlct = '224011') or ((lc.lc begins 'IMLC' or lc.lc begins 'SBLC') and v-covlct = '285511'))) then do:
    if v-orgamt = 0 or string(v-orgamt) = b-lch6.value1 then do:

    if v-expdt = ? or v-expdt = date(inte(substr(b-lch5.value1,4,2)), inte(substr(b-lch5.value1,1,2)), inte(substr(b-lch5.value1,7))) then do:

    find first b-lch2 where b-lch2.lc = lc.lc and b-lch2.kritcod = 'Confir' and can-do(substr(v-confr,1,1),b-lch2.value1) no-lock no-error.
    if not avail b-lch2 and v-confr <> '*' then next.
    else do:

    find first b-lch3 where b-lch3.lc = lc.lc and b-lch3.kritcod = 'AvlWith' and can-do(v-avw,b-lch3.value1) no-lock no-error.
    if not avail b-lch3 and v-avw <> '*'  then next.
    else do:

    /*v-sum = deci(b-lch6.value1).
    find first lch where lch.lc = lc.lc and lch.kritcode = 'peramt' no-lock no-error.
    if avail lch and lch.value1 ne '' then do:
        v-per = int(entry(1,lch.value1, '/')).
        if v-per > 0 then do:
            v-sum = v-sum + (v-sum * (v-per / 100)).
        end.
    end.
    if v-curamt = 0 or v-curamt = v-sum then do:*/

    /*find first lch where lch.lc = lc.lc and lch.kritcod = 'peramt' no-lock no-error.
    if not avail lch and v-curamt <> 0 then next.
    else do:*/

      v-sum = 0.
    for each lcres where lcres.lc = lc.lc and lcres.com = yes no-lock:
        v-sum = v-sum + lcres.amt.
    end.
    if v-comamt = 0 or v-comamt = v-sum then do:

        create wrk.
        assign wrk.ref = lc.lc
               wrk.appl = lc.cif
               wrk.issdt = string(lc.rwhn)
               wrk.sts = lc.lcsts.

               wrk.cov = if b-lch1.value1 = '1' then 'Uncovered' else 'Covered'.
               if b-lch1.value1 = '0' then do:
                   if lc.lc begins 'PG' then wrk.covlct = '224011'.
                   else if lc.lc begins 'IMLC' or lc.lc begins 'SBLC' then wrk.covlct = '285511'.
               end.

               find first b-lch2 where b-lch2.lc = lc.lc and b-lch2.kritcod = 'Confir' and can-do(substr(v-confr,1,1),b-lch2.value1) no-lock no-error.
               if avail b-lch2 then wrk.confr = if b-lch2.value1 = '0' then 'Confirmed' else 'Without'.

               find first b-lch3 where b-lch3.lc = lc.lc and b-lch3.kritcod = 'AvlWith' and can-do(v-avw,b-lch3.value1) no-lock no-error.
               if avail b-lch3 then wrk.avw = b-lch3.value1.

               wrk.bnf = b-lch4.value1.
               wrk.expdt = b-lch5.value1.

               if lc.lc begins 'PG' then wrk.covlct = '224011'.
               else if lc.lc begins 'IMLC' or lc.lc begins 'SBLC' then wrk.covlct = '285511'.

               wrk.orgamt = deci(b-lch6.value1).

               v-curamt = deci(b-lch6.value1).
               find first lch where lch.lc = lc.lc and lch.kritcode = 'peramt' no-lock no-error.
               if avail lch and lch.value1 ne '' then do:
                   v-per = int(entry(1,lch.value1, '/')).
                   if v-per > 0 then do:
                       v-curamt = v-curamt + (v-curamt * (v-per / 100)).
                       wrk.curamt = v-curamt.
                   end.
               end.

               wrk.comamt = 0.
               for each lcres where lcres.lc = lc.lc and lcres.com = yes no-lock:
                   find last crchis where crchis.crc = lcres.crc and crchis.rdt <= lcres.jdt no-lock no-error.
                   wrk.comamt = wrk.comamt + lcres.amt.
               end.
               for each lceventres where lceventres.lc = lc.lc and lceventres.com = yes no-lock:
                   find last crchis where crchis.crc = lceventres.crc and crchis.rdt <= lceventres.jdt no-lock no-error.
                   wrk.comamt = wrk.comamt + lceventres.amt * crchis.rate[1].
               end.
               for each lcpayres where lcpayres.lc = lc.lc and lcpayres.com = yes no-lock:
                   find last crchis where crchis.crc = lcpayres.crc and crchis.rdt <= lcpayres.jdt no-lock no-error.
                   wrk.comamt = wrk.comamt + lcpayres.amt * crchis.rate[1].
               end.
               for each lcamendres where lcamendres.lc = lc.lc and lcamendres.com = yes no-lock:
                   find last crchis where crchis.crc = lcamendres.crc and crchis.rdt <= lcamendres.jdt no-lock no-error.
                   wrk.comamt = wrk.comamt + lcamendres.amt * crchis.rate[1].
               end.
    end.
    end.
    end.
    end.
    end.
    end.
    end.
    end.
end.


for each wrk no-lock:

put stream m-out unformatted
                  "<tr>" skip
/*1 */            "<td align=""center"">" wrk.ref "</TD>" skip
/*2 */            "<td>" wrk.appl "</td>" skip
/*3 */            "<td>" wrk.bnf "</td>" skip
/*4 */            "<td>" wrk.issdt "</td>" skip
/*5 */            "<td>" wrk.expdt "</td>" skip
/*6 */            "<td align=""center"">" wrk.cov "</td>" skip
/*7 */            "<td align=""right"">" wrk.confr "</td>" skip
/*8 */            "<td>" wrk.covlct "</td>" skip
/*9 */            "<td>" wrk.avw "</td>" skip
/*10 */           "<td align=""right"">" replace(trim(string(wrk.orgamt,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
/*11 */           "<td align=""right"">" replace(trim(string(wrk.curamt,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
/*12 */           "<td align=""right"">" replace(trim(string(wrk.comamt,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
/*13 */           "<td>" wrk.sts "</td>" skip
                  "</tr>" skip.
end.

put stream m-out "</table></body></html>" skip.
output stream m-out close.
hide message no-pause.

unix silent cptwin month_rep.htm excel.