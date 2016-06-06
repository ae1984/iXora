/* vcrptuv2.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Уведомление о просроченной задолженности по предоставлению акта выполненных работ по контракту-инвойсу
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        31/12/99 pragma
 * BASES
        BANK COMM
 * CHANGES
        29/12/2005 nataly  - добавила наименование РКО и ФИО директоров
        11.03.2011 damir - перекомпиляция в связи с добавлением нового поля opertyp
        03.05.2013 damir - Внедрено Т.З. № 1107.
*/
{vc.i}
{global.i}

def shared var s-contract like vccontrs.contract.
def shared var s-cif like cif.cif.
def shared var v-sumakt as deci.
def shared var v-sumplat as deci.

def var v-vcourbank as char.
def var v-city as char.
def var v-num as char.
def var v-name as char.
def var v-bankname as char.
def var v-accname as char.
def var v-posname as char.
def var v-i as integer.
def var v-cifname as char.
def var v-datastr as char.
def var v-docsplat as char init "".
def var v-days as integer.
def var v-dt as date.
def var v-sum as deci.
def var v-docs like vcdocs.docs.
def var v-datastrkz as char no-undo.
def var v-dep as char.

def stream vcrpt.

def var v-sel as char.
def var v-head as char init "vcrptuv2".

run sel("ВЫБЕРИТЕ","1.Сформировать уведомление о просрочке актов|2.Просмотр документа|3.Сканировать|4.Выход").
v-sel = trim(return-value).

case v-sel:
    when "1" then run ViewDoc.
    when "2" then run vc-oper("1",trim(string(s-contract)),v-head).
    when "3" then run vc-oper("2",trim(string(s-contract)),v-head).
    when "4" then return.
end case.

procedure ViewDoc:
    /* выяснить, есть ли задолженность в самом деле */
    find vccontrs where vccontrs.contract = s-contract no-lock no-error.
    if vccontrs.cttype <> "3" then do:
        message skip " Только для контрактов по услугам!" skip(1) view-as alert-box button ok title "".
        return.
    end.
    if vccontrs.expimp = "e" then do:
        message skip " Только для контрактов по импорту!" skip(1) view-as alert-box button ok title "".
        return.
    end.
    if v-sumakt >= v-sumplat then do:
        message skip " Нет платежей, не покрытых актами!" skip(1) view-as alert-box button ok title "".
        return.
    end.
    /* ИМПОРТ */
    for each codfr where codfr.codfr = "vcdoc" and index("p", codfr.name[5]) > 0 no-lock:
        v-docsplat = v-docsplat + codfr.code + ",".
    end.
    find vcparams where vcparams.parcode = "dayerror" no-lock no-error.
    if avail vcparams then v-days = vcparams.valinte. else v-days = 120.
    /* есть платежи, не покрытые актами */
    if v-sumakt = 0 then do:
        /* нет актов - берем просто первый платеж */
        find first vcdocs where vcdocs.contract = s-contract and lookup(vcdocs.dntype, v-docsplat) > 0 use-index main no-lock no-error.
        v-dt = vcdocs.dndate.
        v-docs = vcdocs.docs.
    end.
    else do:
        /* идем по платежам минус возвраты, пока их сумма меньше суммы актов */
        for each vcdocs where vcdocs.contract = s-contract and lookup(vcdocs.dntype, v-docsplat) > 0 no-lock use-index main.
            if vcdocs.payret then v-sum = v-sum - vcdocs.sum / vcdocs.cursdoc-con.
            else v-sum = v-sum + vcdocs.sum / vcdocs.cursdoc-con.
            if v-sum > v-sumakt then do:
                v-dt = vcdocs.dndate.
                v-docs = vcdocs.docs.
                leave.
            end.
        end.
    end.
    if g-today <= v-dt + v-days then do:
        message skip
        " Есть платежи, не покрытые актами!" skip(1)
        " " + string(v-days) + " дней наступит через " +
        string(v-dt + v-days - g-today) " дней, " +
        string(v-dt + v-days, "99/99/9999") + "." skip(1)
        " Уведомление не сформировано!"
        view-as alert-box error buttons ok title "".
        return.
    end.
    /* печать уведомления */
    find first cmp no-lock no-error.
    if avail cmp then v-bankname = cmp.name.
    /*find sysc where sysc.sysc = "vc-dep" no-lock no-error.
    if avail sysc then do:
    v-name = entry(1, sysc.chval).
    v-posname = entry(2, sysc.chval).
    end. */
    find cif where cif.cif = s-cif no-lock no-error.
    v-dep = string(int(cif.jame) - 1000) .
    find first codfr where codfr = 'vchead' and codfr.code = v-dep no-lock no-error .
    if avail codfr and codfr.name[1] <> "" then do:
        v-name = entry(1, trim(codfr.name[1])).
        if num-entries(codfr.name[1]) > 1 then v-posname = entry(2, trim(codfr.name[1])).
    end.
    find cif where cif.cif = vccontrs.cif no-lock no-error.
    v-cifname = trim(trim(cif.prefix) + " " + trim(cif.name)).
    find vcdocs where vcdocs.docs = v-docs no-lock no-error.
    find ncrc where ncrc.crc = vcdocs.pcrc no-lock no-error.

    def var v-file as char init "vcuvakt.htm".

    output stream vcrpt to value(v-file).
    {html-title.i &stream = "stream vcrpt"}

    run pkdefdtstr (g-today, output v-datastr, output v-datastrkz).
    put stream vcrpt unformatted
    "<TABLE width=""96%"" cellpadding=""0"" cellspacing=""0"" border=""0"" align=""center"">" skip
    "<TR><TD>" skip
    "<TABLE width=""90%"" border=""0"" cellspacing=""0"" cellpadding=""0"" align=""center"">" skip
    "<TR align=""left""><TD colspan=""3""><IMG border=""0"" src=""http://www.texakabank.kz/images/top_logo_bw.gif""><BR><BR></TD></TR>" skip
    "<TR valign=""top"">" skip
    "<TD width=""40%"" align=""left""><B><U><I>"
    v-datastr
    "</I></U></B></TD>" skip
    "<TD width=""20%"">&nbsp;</TD>"
    "<TD width=""40%"" align=""right""><B><U><I>"
    v-cifname
    "</I></U></B></TD></TR></TABLE><BR><BR><BR>" skip

    "<P align=""center"" style=""font:bold""><FONT size=""3"">УВЕДОМЛЕНИЕ</FONT></P>" skip
    "<P align=""justify"">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
    v-bankname
    " просит принять к сведению, что по Вашему контракту N&nbsp;<B><U><I>"
    vccontrs.ctnum skip
    "</I></U></B> от&nbsp;<B><U><I>"
    string(vccontrs.ctdate, "99/99/9999")
    "</I></U></B>г. валютная операция превысила "
    v-days
    "-дневный срок.<BR>" skip
    "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Вами был произведен платеж <B><U><I>"
    string(vcdocs.dndate, "99/99/9999")
    "</I></U></B>г. на сумму&nbsp;<B><U><I>"
    replace(trim(string(vcdocs.sum, ">>>,>>>,>>>,>>>,>>9.99")), ",", "&nbsp;")
    "&nbsp;"
    ncrc.code
    "</I></U></B>, но к настоящему времени в банк не предъявлен акт выполненных работ на вышеуказанную сумму.<BR>" skip
    "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Если работы не оказаны, то вышеназванный контракт по действующему законодательству подлежит лицензированию в Национальном Банке Республики Казахстан.<BR>" skip
    "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;За дополнительными разъяснениями по вопросу лицензирования Вы можете обратиться в " skip
    if cmp.code = 0 then "Департамент валютного контроля " else "" skip
    v-bankname
    ".<BR>" skip
    "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Просим принять меры для завершения сделки.</P>" skip
    "<P>&nbsp;</P>" skip
    "<TABLE width=""95%"" border=""0"" cellspacing=""0"" cellpadding=""0"" align=""center"">" skip
    "<TR align=""left"" valign=""top""><TD width=""40%"">" skip
    v-posname
    "<BR>"
    v-bankname
    "</TD><TD width=""30%"">&nbsp;</TD><TD width=""30%"">" skip
    v-name
    "</TD></TR></TABLE>" skip
    "</TD></TR></TABLE>" skip.

    {html-end.i "stream vcrpt" }
    output stream vcrpt close.

    unix silent cptwin value(v-file) iexplore.
end procedure.

