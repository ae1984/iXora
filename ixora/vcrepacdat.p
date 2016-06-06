/* vcrepacdat.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
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
        --/--/2011 damir
 * BASES
        BANK COMM TXB
 * CHANGES
*/
def input parameter p-bank as char.
def input parameter p-dtb  as date.
def input parameter p-dte  as date.

def shared temp-table t-docsa
    field filial    as char
    field txb       as char
    field viddoc    as inte
    field depart    as inte
    field codcl     as char
    field clname    as char
    field cnum      as char
    field ctype     as char
    field conttype  as char
    field cdat      as date
    field dnum      as char
    field dtype     as char
    field documtype as char
    field ddat      as date
    field orig      as char
    field rdate     as date
    field rwho      as char.

def shared var v-option as char.

{defperem.i}.

def var v-filial as char.
def var v-txb    as char.
def var v-mail   as char init "@metrocombank.kz".
def var j        as inte.
def var i        as inte init 0.

def buffer b-t-docsa for t-docsa.

find first txb.cmp no-lock no-error.
if avail txb.cmp then v-filial = trim(txb.cmp.name).

find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if avail txb.sysc then v-txb = trim(txb.sysc.chval).

/*Собираем менеджеров,директоров,начальников ОО,гл.бухгалтеров по пакетам доступа*/
/*---------------*/
if v-option = "mail" then do:
    {ofcdost.i}
end.
/*---------------*/

for each vccontrs where vccontrs.rdt >= p-dtb and vccontrs.rdt <= p-dte and vccontrs.cdt = ? and vccontrs.bank = trim(p-bank) no-lock:
    for each txb.cif where txb.cif.cif = vccontrs.cif no-lock:
        if not (vccontrs.sts begins "C") then do:
            create t-docsa.
            assign
            t-docsa.filial  = trim(v-filial)
            t-docsa.txb     = trim(v-txb)
            t-docsa.viddoc  = 1
            t-docsa.depart  = integer(txb.cif.jame) mod 1000
            t-docsa.codcl   = txb.cif.cif
            t-docsa.clname  = txb.cif.name
            t-docsa.cnum    = vccontrs.ctnum
            t-docsa.ctype   = vccontrs.cttype
            t-docsa.cdat    = vccontrs.ctdate
            t-docsa.dnum    = ""
            t-docsa.dtype   = ""
            t-docsa.ddat    = ?
            t-docsa.orig    = ""
            t-docsa.rdate   = vccontrs.rdt
            t-docsa.rwho    = vccontrs.rwho.
            if t-docsa.ctype <> "" then do:
                find first txb.codfr where txb.codfr.codfr = "vccontr" and txb.codfr.code = trim(t-docsa.ctype) no-lock no-error.
                t-docsa.conttype = trim(txb.codfr.name[1]).
            end.
        end.
    end.
end.

/*  Паспорта сделок и доп.листы. */
for each vcps where vcps.rdt >= p-dtb and vcps.rdt <= p-dte no-lock:
    if vcps.cdt <> ? then next.
    for each vccontrs where vccontrs.contract = vcps.contract and vccontrs.bank = trim(p-bank) no-lock:
        for each txb.cif where txb.cif.cif = vccontrs.cif no-lock:
            if not (vccontrs.sts begins "C") then do:
                create t-docsa.
                assign
                t-docsa.filial  = trim(v-filial)
                t-docsa.txb     = trim(v-txb)
                t-docsa.viddoc  = 2
                t-docsa.depart  = integer(txb.cif.jame) mod 1000
                t-docsa.codcl   = txb.cif.cif
                t-docsa.clname  = txb.cif.name
                t-docsa.cnum    = vccontrs.ctnum
                t-docsa.ctype   = vccontrs.cttype
                t-docsa.cdat    = vccontrs.ctdate
                t-docsa.dnum    = vcps.dnnum
                t-docsa.dtype   = vcps.dntype
                t-docsa.ddat    = vcps.dndate
                t-docsa.orig    = ""
                t-docsa.rdate   = vcps.rdt
                t-docsa.rwho    = vcps.rwho.
                if t-docsa.dtype <> "" then do:
                    find first txb.codfr where txb.codfr.codfr = "vcdoc" and txb.codfr.code = trim(t-docsa.dtype) no-lock no-error.
                    t-docsa.documtype = trim(txb.codfr.name[1]).
                end.
                if t-docsa.ctype <> "" then do:
                    find first txb.codfr where txb.codfr.codfr = "vccontr" and txb.codfr.code = trim(t-docsa.ctype) no-lock no-error.
                    t-docsa.conttype = trim(txb.codfr.name[1]).
                end.
            end.
        end.
    end.
end.

/* Инвойсы, платежи, ГТД, акты */
for each vcdocs where vcdocs.rdt >= p-dtb and vcdocs.rdt <= p-dte and vcdocs.dntype <> "28" no-lock:
    if vcdocs.cdt <> ? then next.
    for each vccontrs where vccontrs.contract = vcdocs.contract and vccontrs.bank = trim(p-bank) no-lock:
        for each txb.cif where txb.cif.cif = vccontrs.cif no-lock:
            if not (vccontrs.sts begins "C") then do:
                create t-docsa.
                assign
                t-docsa.filial  = trim(v-filial)
                t-docsa.txb     = trim(v-txb)
                t-docsa.viddoc  = 2
                t-docsa.depart  = integer(txb.cif.jame) mod 1000
                t-docsa.codcl   = txb.cif.cif
                t-docsa.clname  = txb.cif.name
                t-docsa.cnum    = vccontrs.ctnum
                t-docsa.ctype   = vccontrs.cttype
                t-docsa.cdat    = vccontrs.ctdate
                t-docsa.dnum    = vcdocs.dnnum
                t-docsa.dtype   = vcdocs.dntype
                t-docsa.ddat    = vcdocs.dndate
                t-docsa.orig    = string(vcdocs.origin)
                t-docsa.rdate   = vcdocs.rdt
                t-docsa.rwho    = vcdocs.rwho.
                if t-docsa.dtype <> "" then do:
                    find first txb.codfr where txb.codfr.codfr = "vcdoc" and txb.codfr.code = trim(t-docsa.dtype) no-lock no-error.
                    t-docsa.documtype = trim(txb.codfr.name[1]).
                end.
                if t-docsa.ctype <> "" then do:
                    find first txb.codfr where txb.codfr.codfr = "vccontr" and txb.codfr.code = trim(t-docsa.ctype) no-lock no-error.
                    t-docsa.conttype = trim(txb.codfr.name[1]).
                end.
            end.
        end.
    end.
end.

/* Регистрационные свидетельства и Лицензии */
for each vcrslc where vcrslc.cdt = ? and vcrslc.rdt >= p-dtb and vcrslc.rdt <= p-dte no-lock:
    for each vccontrs where vccontrs.contract = vcrslc.contract and vccontrs.bank = trim(p-bank) no-lock:
        for each txb.cif where txb.cif.cif = vccontrs.cif no-lock:
            if not (vccontrs.sts begins "C") then do:
                create t-docsa.
                assign
                t-docsa.filial  = trim(v-filial)
                t-docsa.txb     = trim(v-txb)
                t-docsa.viddoc  = 2
                t-docsa.depart  = integer(txb.cif.jame) mod 1000
                t-docsa.codcl   = txb.cif.cif
                t-docsa.clname  = txb.cif.name
                t-docsa.cnum    = vccontrs.ctnum
                t-docsa.ctype   = vccontrs.cttype
                t-docsa.cdat    = vccontrs.ctdate
                t-docsa.dnum    = vcrslc.dnnum
                t-docsa.dtype   = vcrslc.dntype
                t-docsa.ddat    = vcrslc.dndate
                t-docsa.orig    = ""
                t-docsa.rdate   = vcrslc.rdt
                t-docsa.rwho    = vcrslc.rwho.
                if t-docsa.dtype <> "" then do:
                    find first txb.codfr where txb.codfr.codfr = "vcdoc" and txb.codfr.code = trim(t-docsa.dtype) no-lock no-error.
                    t-docsa.documtype = trim(txb.codfr.name[1]).
                end.
                if t-docsa.ctype <> "" then do:
                    find first txb.codfr where txb.codfr.codfr = "vccontr" and txb.codfr.code = trim(t-docsa.ctype) no-lock no-error.
                    t-docsa.conttype = trim(txb.codfr.name[1]).
                end.
            end.
        end.
    end.
end.

if v-option = "mail" then do:
    if v-txb = "TXB01" then do:
        find first t-docsa where t-docsa.txb = "TXB01" no-lock no-error.
        if avail t-docsa then do:
            v-yesno1 = yes.
            output to value(vfname1).
        end.
    end.
    else if v-txb = "TXB02" then do:
        find first t-docsa where t-docsa.txb = "TXB02" no-lock no-error.
        if avail t-docsa then do:
            v-yesno2 = yes.
            output to value(vfname2).
        end.
    end.
    else if v-txb = "TXB03" then do:
        find first t-docsa where t-docsa.txb = "TXB03" no-lock no-error.
        if avail t-docsa then do:
            v-yesno3 = yes.
            output to value(vfname3).
        end.
    end.
    else if v-txb = "TXB04" then do:
        find first t-docsa where t-docsa.txb = "TXB04" no-lock no-error.
        if avail t-docsa then do:
            v-yesno4 = yes.
            output to value(vfname4).
        end.
    end.
    else if v-txb = "TXB05" then do:
        find first t-docsa where t-docsa.txb = "TXB05" no-lock no-error.
        if avail t-docsa then do:
            v-yesno5 = yes.
            output to value(vfname5).
        end.
    end.
    else if v-txb = "TXB06" then do:
        find first t-docsa where t-docsa.txb = "TXB06" no-lock no-error.
        if avail t-docsa then do:
            v-yesno6 = yes.
            output to value(vfname6).
        end.
    end.
    else if v-txb = "TXB07" then do:
        find first t-docsa where t-docsa.txb = "TXB07" no-lock no-error.
        if avail t-docsa then do:
            v-yesno7 = yes.
            output to value(vfname7).
        end.
    end.
    else if v-txb = "TXB08" then do:
        find first t-docsa where t-docsa.txb = "TXB08" no-lock no-error.
        if avail t-docsa then do:
            v-yesno8 = yes.
            output to value(vfname8).
        end.
    end.
    else if v-txb = "TXB09" then do:
        find first t-docsa where t-docsa.txb = "TXB09" no-lock no-error.
        if avail t-docsa then do:
            v-yesno9 = yes.
            output to value(vfname9).
        end.
    end.
    else if v-txb = "TXB10" then do:
        find first t-docsa where t-docsa.txb = "TXB10" no-lock no-error.
        if avail t-docsa then do:
            v-yesno10 = yes.
            output to value(vfname10).
        end.
    end.
    else if v-txb = "TXB11" then do:
        find first t-docsa where t-docsa.txb = "TXB11" no-lock no-error.
        if avail t-docsa then do:
            v-yesno11 = yes.
            output to value(vfname11).
        end.
    end.
    else if v-txb = "TXB12" then do:
        find first t-docsa where t-docsa.txb = "TXB12" no-lock no-error.
        if avail t-docsa then do:
            v-yesno12 = yes.
            output to value(vfname12).
        end.
    end.
    else if v-txb = "TXB13" then do:
        find first t-docsa where t-docsa.txb = "TXB13" no-lock no-error.
        if avail t-docsa then do:
            v-yesno13 = yes.
            output to value(vfname13).
        end.
    end.
    else if v-txb = "TXB14" then do:
        find first t-docsa where t-docsa.txb = "TXB14" no-lock no-error.
        if avail t-docsa then do:
            v-yesno14 = yes.
            output to value(vfname14).
        end.
    end.
    else if v-txb = "TXB15" then do:
        find first t-docsa where t-docsa.txb = "TXB15" no-lock no-error.
        if avail t-docsa then do:
            v-yesno15 = yes.
            output to value(vfname15).
        end.
    end.
    else if v-txb = "TXB16" then do:
        find first t-docsa where t-docsa.txb = "TXB16" no-lock no-error.
        if avail t-docsa then do:
            v-yesno16 = yes.
            output to value(vfname16).
        end.
    end.


    {html-title.i
     &stream = " "
     &title = "Реестр неакцептованных документов"
     &size-add = "xx-"
    }

    put unformatted
        "<P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">"
        "<B>РЕЕСТР НЕАКЦЕПТОВАННЫХ ДОКУМЕНТОВ<BR>за период с " + string(p-dtb, "99/99/9999") +
        " по " + string(p-dte, "99/99/9999") + "</B></FONT></P>" skip
        "<P align = ""center""><FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans"">"
        "<B>Неакцептованные контракты</B></FONT></P>" skip
        "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"">" skip.

    /* Вывод в отчет неакцептованных контрактов */

    put unformatted
        "<TR align=""center"">" skip
        "<TD><FONT size=""2""><B>№</B></FONT></TD>" skip
        "<TD><FONT size=""2""><B>Код клиента</B></FONT></TD>" skip
        "<TD><FONT size=""2""><B>Наименование клиента</B></FONT></TD>" skip
        "<TD><FONT size=""2""><B>Номер контракта</B></FONT></TD>" skip
        "<TD><FONT size=""2""><B>Тип контракта</B></FONT></TD>" skip
        "<TD><FONT size=""2""><B>Дата контракта</B></FONT></TD>" skip
        "<TD><FONT size=""2""><B>Дата регистрации</B></FONT></TD>" skip
        "<TD><FONT size=""2""><B>Регистрировал</B></FONT></TD>" skip
        "</TR>" skip.

    for each t-docsa where t-docsa.viddoc = 1 and t-docsa.txb = trim(v-txb) no-lock break by t-docsa.txb:
        if first-of(t-docsa.txb) then do:
            i = 0.
            put unformatted
                "<TR align=""center"">" skip
                "<TD colspan=""7""><FONT size=""2""><B>" t-docsa.filial "</B></FONT></TD>" skip
                "</TR>" skip.
            for each b-t-docsa where b-t-docsa.txb = t-docsa.txb and b-t-docsa.viddoc = 1 no-lock:
                i = i + 1.
                put unformatted
                    "<TR align=""center"">" skip
                    "<TD><FONT size=""2"">" string(i) "</FONT></TD>" skip
                    "<TD><FONT size=""2"">" b-t-docsa.codcl  "</FONT></TD>" skip
                    "<TD><FONT size=""2"">" b-t-docsa.clname  "</FONT></TD>" skip
                    "<TD><FONT size=""2"">" b-t-docsa.cnum  "</FONT></TD>" skip
                    "<TD><FONT size=""2"">" b-t-docsa.conttype "</FONT></TD>" skip
                    "<TD><FONT size=""2"">" string(b-t-docsa.cdat, "99/99/99")  "</FONT></TD>" skip
                    "<TD><FONT size=""2"">" string(b-t-docsa.rdate, "99/99/99")  "</FONT></TD>" skip
                    "<TD><FONT size=""2"">" b-t-docsa.rwho  "</FONT></TD>" skip
                    "</TR>" skip.
            end.
        end.
    end.

    put unformatted
        "</TABLE>" skip.

    /* Вывод в отчет неакцептованных документов */

    put unformatted
       "<P align = ""center""><FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans"">"
       "<B>Неакцептованные документы</B></FONT></P>" skip
       "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"">" skip.

    put unformatted
        "<TR align=""center"">" skip
        "<TD><FONT size=""2""><B>№</B></FONT></TD>" skip
        "<TD><FONT size=""2""><B>Код клиента</B></FONT></TD>" skip
        "<TD><FONT size=""2""><B>Наименование клиента</B></FONT></TD>" skip
        "<TD><FONT size=""2""><B>Номер контракта</B></FONT></TD>" skip
        "<TD><FONT size=""2""><B>Тип контракта</B></FONT></TD>" skip
        "<TD><FONT size=""2""><B>Дата контракта</B></FONT></TD>" skip
        "<TD><FONT size=""2""><B>Номер документа</B></FONT></TD>" skip
        "<TD><FONT size=""2""><B>Тип документа</B></FONT></TD>" skip
        "<TD><FONT size=""2""><B>Дата документа</B></FONT></TD>" skip
        "<TD><FONT size=""2""><B>Оригинал</B></FONT></TD>" skip
        "<TD><FONT size=""2""><B>Дата регистрации</B></FONT></TD>" skip
        "<TD><FONT size=""2""><B>Регистрировал</B></FONT></TD>" skip
        "</TR>" skip.

    for each t-docsa where t-docsa.viddoc = 2 and t-docsa.txb = trim(v-txb) no-lock break by t-docsa.txb:
        if first-of(t-docsa.txb) then do:
            i = 0.
            put unformatted
               "<TR align=""center"">" skip
                "<TD colspan=""11""><FONT size=""2""><B>" t-docsa.filial "</B></FONT></TD>" skip
               "</TR>" skip.
            for each b-t-docsa where b-t-docsa.txb = t-docsa.txb and b-t-docsa.viddoc = 2 no-lock:
                i = i + 1.
                put unformatted
                    "<TR align=""center"">" skip
                    "<TD><FONT size=""2"">" string(i) "</FONT></TD>" skip
                    "<TD><FONT size=""2"">" b-t-docsa.codcl "</FONT></TD>" skip
                    "<TD><FONT size=""2"">" b-t-docsa.clname "</FONT></TD>" skip
                    "<TD><FONT size=""2"">" b-t-docsa.cnum "</FONT></TD>" skip
                    "<TD><FONT size=""2"">" b-t-docsa.conttype "</FONT></TD>" skip
                    "<TD><FONT size=""2"">" string(b-t-docsa.cdat, "99/99/99") "</FONT></TD>" skip
                    "<TD><FONT size=""2"">" b-t-docsa.dnum "</FONT></TD>" skip
                    "<TD><FONT size=""2"">" b-t-docsa.documtype "</FONT></TD>" skip
                    "<TD><FONT size=""2"">" if b-t-docsa.ddat = ? then "" else string(b-t-docsa.ddat, "99/99/99") "</FONT></TD>" skip
                    "<TD><FONT size=""2"">" b-t-docsa.orig "</FONT></TD>" skip
                    "<TD><FONT size=""2"">" string(b-t-docsa.rdate, "99/99/99") "</FONT></TD>" skip
                    "<TD><FONT size=""2"">" b-t-docsa.rwho "</FONT></TD>" skip
                    "</TR>" skip.
            end.
        end.
    end.

    put unformatted
    "</TABLE>" skip.

    {html-end.i " " }

    output close.
end.