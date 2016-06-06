/* form16PB.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Отчет 16 ПБ
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        8-8-2
 * AUTHOR
        09.11.2012 dmitriy
 * BASES
        BANK COMM
 * CHANGES

*/

def temp-table wrk
    field name as char
    field code as int.

def new shared temp-table wrk-br
    field code as int
    field jh as int
    field br_name as char
    field br_code as char
    field docnum as char
    field crc as int
    field gl_dr as int
    field gl_cr as int
    field kass_sim as char
    field rem as char
    field kbe as int
    field kod as int
    field knp as int
    field sum_nom as deci
    field sum_ekv as deci.

def new shared temp-table wrk-ost
    field fil as char
    field gl  as int
    field crc as char
    field nom_beg as deci
    field nom_end as deci
    field ekv_beg as deci
    field ekv_end as deci.

def new shared temp-table wrk-obr
    field fil as char
    field jh  as int
    field glD as int
    field glC as int
    field glDname as char
    field glCname as char
    field dacc as char
    field cacc as char
    field daccname as char
    field caccname as char
    field trx as char
    field crc as char
    field dr1 as deci
    field dr2 as deci
    field cr1 as deci
    field cr2 as deci
    field kas as int
    field kod as int
    field kbe as int
    field knp as int
    field country1 as char
    field country2 as char
    field code as int
    field rem  as char.

def new shared var v-dt1 as date.
def new shared var v-dt2 as date.

def buffer b-wrk for wrk.

def var file1 as char.
def var v-crc as int init 0.
def var v-ost as logi init yes format "Да/Нет".
def var v-obr as logi init yes format "Да/Нет".
def var v-sum as deci.
def var v-str as char.
def var v-tg  as logi.
def var v1000 as int.
def var v-crcrank as char.
def var v-code as char.
def var i as int.

def frame fr1
    v-dt1     format  "99/99/9999"  label  "Начало периода    " skip
    v-dt2     format  "99/99/9999"  label  "Конец периода     " skip
    v-tg      format  "Да/Нет"      label  "В тыс.тенге/тенге "  skip
    v-ost label  "Расшифровка по остаткам " skip
    v-obr label  "Расшифровка по оборотам "
with side-labels centered row 15 title "Форма №16-ПБ".

{global.i}

/*on help of v-crc in frame fr1 do:
    run help-crc1.
end.*/

update v-dt1 v-dt2 v-tg v-ost v-obr with frame fr1.

if v-tg = yes then do: v1000 = 1000. v-crcrank = " в тыс.ед. валюты". end.
if v-tg = no  then do: v1000 = 1.    v-crcrank = " в ед. валюты".     end.

create wrk.  wrk.code = 100. wrk.name = "Ќолма-ќол бар шетел валютасыныѕ кезеѕ басындаєы ќалдыєы <br> Остаток наличной инвалюты на начало периода".
create wrk.  wrk.code = 200. wrk.name = "Ќолма-ќол бар шетел валютасыныѕ тїскені, барлыєы <br> Поступление наличной инвалюты, всего".
create wrk.  wrk.code = 0.   wrk.name = "оныѕ ішінде: <br> в том числе:".
create wrk.  wrk.code = 210. wrk.name = "банктіѕ Ќазаќстанєа јкелгені <br> ввезено банком в Казахстан".
create wrk.  wrk.code = 220. wrk.name = "Ўлттыќ Банкті ќосќанда банктерден сатып алынєаны <br> куплено у банков, включая Национальный Банк".
create wrk.  wrk.code = 230. wrk.name = "валюталыќ есепшоттарєа аудару їшін банктік емес заѕды тўлєалар–резиденттерден тїскені <br> поступление от небанковских юридических лиц-резидентов для зачисления на валютные счета".
create wrk.  wrk.code = 240. wrk.name = "банктік емес заѕды тўлєалар-резидент еместерден ваюталыќ есепшоттарєа тїскені <br> поступление от небанковских юридических лиц-нерезидентов для зачисления на валютные счета".
create wrk.  wrk.code = 250. wrk.name = "банктіѕ айырбастау пунктері арќылы жеке тўлєалардан сатып алынєаны <br> куплено у физических лиц через обменные пункты банка".
create wrk.  wrk.code = 260. wrk.name = "жеке тўлєалар - резиденттерден валюталыќ есепшоттарєа ќабылданєаны <br> принято от физических лиц-резидентов для зачисления на валютные счета".
create wrk.  wrk.code = 270. wrk.name = "жеке тўлєалар - резидент еместерден валюталыќ есепшоттарєа ќабылданєаны <br> принято от физических лиц-нерезидентов для зачисления на валютные счета".
create wrk.  wrk.code = 280. wrk.name = "есепшот ашпай-аќ Ќазаќстан бойынша біржолєы аударым їшін жеке тўлєалар - резиденттерден ќабылданєаны <br> принято от физических лиц-резидентов для разового перевода по Казахстану без открытия счета ".
create wrk.  wrk.code = 290. wrk.name = "есепшот ашпай-аќ шет елге біржолєы аударым їшін жеке тўлєалар-резиденттерден ќабылданєаны <br> принято от физических лиц-резидентов для разового перевода за рубеж без открытия счета".
create wrk.  wrk.code = 0.   wrk.name = "оныѕ ішінде: <br> из них:".
create wrk.  wrk.code = 291. wrk.name = "емделуге жјне білім алуєа <br> на лечение и образование".
create wrk.  wrk.code = 300. wrk.name = "есепшот ашпай-аќ Ќазаќстан бойынша біржолєы аударым їшін жеке тўлєалар резидент еместерден ќабылданєаны <br> принято от физических лиц-нерезидентов для разового перевода по Казахстану без открытия счета".
create wrk.  wrk.code = 310. wrk.name = "есепшот ашпай-аќ шет елге біржолєы аударым їшін жеке тўлєалар – резидент еместерден ќабылданєаны <br> принято от физических лиц-нерезидентов для разового перевода за рубеж без открытия счета ".
create wrk.  wrk.code = 311. wrk.name = "жеке тўлєалар-резиденттерге жол чектерін сатудан тїскені <br> принято от продажи физическим лицам-резидентам дорожных чеков".
create wrk.  wrk.code = 312. wrk.name = "жеке тўлєалар-резидент еместерге жол чектерін сатудан тїскені <br> принято от продажи физическим лицам-нерезидентам дорожных чеков".
create wrk.  wrk.code = 320. wrk.name = "ґзге де тїсімдер <br> прочие поступления".
create wrk.  wrk.code = 400. wrk.name = "Ќолма-ќол шетел валютасыныѕ жўмсалєаны, барлыєы <br> Израсходовано наличной инвалюты, всего".
create wrk.  wrk.code = 0.   wrk.name = "оныѕ ішінде: <br> в том числе:".
create wrk.  wrk.code = 410. wrk.name = "банктіѕ Ќазаќстаннан шетке шыєарєаны <br> вывезено банком из Казахстана".
create wrk.  wrk.code = 420. wrk.name = "Ўлттыќ Банкті ќосќанда банктерге сатылєаны <br> продано банкам, включая Национальный Банк".
create wrk.  wrk.code = 430. wrk.name = "валюталыќ есепшоттардан банктік емес заѕды тўлєалар - резиденттерге берілгені <br> выдано небанковским юридическим лицам - резидентам с валютных счетов".
create wrk.  wrk.code = 0.   wrk.name = "оныѕ ішінде: <br> в том числе:".
create wrk.  wrk.code = 431. wrk.name = "жалаќы тґлеуге <br> на оплату заработной платы".
create wrk.  wrk.code = 432. wrk.name = "іссапар шыєыстарына <br> на командировочные расходы".
create wrk.  wrk.code = 433. wrk.name = "ґзге де маќсаттарєа <br> на прочие цели".
create wrk.  wrk.code = 440. wrk.name = "валюталыќ есепшоттардан банктік емес заѕды тўлєалар - резидент еместерге берілгені <br> выдано небанковским юридическим лицам - нерезидентам с валютных счетов".
create wrk.  wrk.code = 0.   wrk.name = "оныѕ ішінде: <br> в том числе:".
create wrk.  wrk.code = 441. wrk.name = "жалаќы тґлеуге <br> на оплату заработной платы".
create wrk.  wrk.code = 442. wrk.name = "іссапар шыєыстарына <br> на командировочные расходы".
create wrk.  wrk.code = 443. wrk.name = "ґзге де маќсаттарєа <br> на прочие цели".
create wrk.  wrk.code = 450. wrk.name = "жеке тўлєаларєа банктіѕ айырбастау пунктері арќылы сатылєаны <br> продано физическим лицам через обменные пункты банка".
create wrk.  wrk.code = 460. wrk.name = "жеке тўлєалар-резиденттерге валюталыќ есепшоттардан берілгені <br> выдано физическим лицам-резидентам с валютных счетов".
create wrk.  wrk.code = 470. wrk.name = "жеке тўлєалар -резидент еместерге валюталыќ есепшоттардан берілгені <br> выдано физическим лицам-нерезидентам с валютных счетов".
create wrk.  wrk.code = 480. wrk.name = "жеке тўлєалар - резиденттерге есепшот ашпай-аќ Ќазаќстан бойынша біржолєы аударымныѕ  берілгені <br> выдано физическим лицам-резидентам по разовому переводу по Казахстану без открытия счета".
create wrk.  wrk.code = 490. wrk.name = "жеке тўлєалар - резиденттерге есепшот ашпай-аќ шет елден біржолєы аударымныѕ берілгені <br> выдано физическим лицам-резидентам по разовому переводу из-за рубежа без открытия счета".
create wrk.  wrk.code = 0.   wrk.name = "оныѕ ішінде: <br> из них: ".
create wrk.  wrk.code = 491. wrk.name = "емделуге жјне білім алуєа <br> на лечение и образование".
create wrk.  wrk.code = 500. wrk.name = "жеке тўлєалар - резидент еместерге есепшот ашпай-аќ Ќазаќстан бойынша біржолєы аударымныѕ  берілгені <br> выдано физическим лицам-нерезидентам по разовому переводу по Казахстану без открытия счета".
create wrk.  wrk.code = 510. wrk.name = "жеке тўлєалар - резидент еместерге есепшот ашпай-аќ шет елден біржолєы аударымныѕ берілгені <br> выдано физическим лицам-нерезидентам по разовому переводу из-за рубежа без открытия счета".
create wrk.  wrk.code = 511. wrk.name = "жеке тўлєалар-резиденттерге жол чектерін ґтеу/ќабылдау кезінде берілгені <br> выдано физическим лицам-резидентам при погашении/приеме дорожных чеков".
create wrk.  wrk.code = 512. wrk.name = "жеке тўлєалар-резидент еместерге жол чектерін ґтеу/ќабылдау кезінде берілгені <br> дано физическим лицам-нерезидентам при погашении/приеме дорожных чеков".
create wrk.  wrk.code = 520. wrk.name = "ґзге шыєыстар <br> прочие расходования".
create wrk.  wrk.code = 600. wrk.name = "Ќолма-ќол шетел валютасыныѕ кезеѕ аяєындаєы ќалдыєы <br> Остаток наличной инвалюты на конец периода".

{r-brfilial.i &proc = "form16PB-2"}


/* все поступления */
for each crc no-lock:
    v-sum = 0.
    for each wrk-obr where wrk-obr.code >= 210 and wrk-obr.code <= 320 and wrk-obr.crc = crc.code no-lock:
        v-sum = v-sum + wrk-obr.dr1.
    end.
    create wrk-obr.
    wrk-obr.code = 200.
    wrk-obr.crc = crc.code.
    wrk-obr.cr1 = v-sum.
end.

/* все расходы */
for each crc no-lock:
    v-sum = 0.
    for each wrk-obr where wrk-obr.code >= 410 and wrk-obr.code <= 600 and wrk-obr.crc = crc.code and wrk-obr.code <> 430 and wrk-obr.code <> 440 no-lock:
        v-sum = v-sum + wrk-obr.cr1.
    end.
    create wrk-obr.
    wrk-obr.code = 400.
    wrk-obr.crc = crc.code.
    wrk-obr.cr1 = v-sum.
end.

/* 430 */
for each crc no-lock:
    v-sum = 0.
    for each wrk-obr where (wrk-obr.code = 431 or wrk-obr.code = 432 or wrk-obr.code = 433) and wrk-obr.crc = crc.code no-lock:
        v-sum = v-sum + wrk-obr.cr1.
    end.
    if v-sum > 0 then do:
        create wrk-obr.
        wrk-obr.code = 430.
        wrk-obr.crc = crc.code.
        wrk-obr.cr1 = v-sum.
    end.
end.

/* 440 */
for each crc no-lock:
    v-sum = 0.
    for each wrk-obr where (wrk-obr.code = 441 or wrk-obr.code = 442 or wrk-obr.code = 443) and wrk-obr.crc = crc.code no-lock:
        v-sum = v-sum + wrk-obr.cr1.
    end.
    if v-sum > 0 then do:
        create wrk-obr.
        wrk-obr.code = 440.
        wrk-obr.crc = crc.code.
        wrk-obr.cr1 = v-sum.
    end.
end.

v-str = "".
for each crc where crc.crc > 1 no-lock:
    find first wrk-obr where wrk-obr.crc = crc.code and (wrk-obr.cr1 <> 0 or wrk-obr.dr1 <> 0) no-lock no-error.
    if avail wrk-obr then v-str = v-str + crc.code + "|".
end.

run PrintRep.
if v-ost  then run PrintOst.
if v-obr then run PrintObor.


procedure PrintRep:
    file1 = "pb16.html".
    output to value(file1).
    {html-title.i}


    put unformatted
    "<TABLE><tr></tr>"
    "<tr align=""center"" style=""font:bold""><td colspan=""5"">Отчет о движении наличной иностранной валюты, в тысячах единиц валюты</td></tr>"
    "<tr align=""center"" style=""font:bold""><td colspan=""5"">АО ""ForteBank""</td></tr>"
    "<tr align=""center""><td colspan=""5"">c " v-dt1 format "99.99.9999" "  по " v-dt2 format "99.99.9999" "</td></tr>"
    "<tr align=""center""><td colspan=""3"">(отчет сформирован в" v-crcrank ")</td></tr>"
    "<tr></tr><tr></tr>"
    "</table>" skip.
    put unformatted
    "<TABLE cellspacing=""0"" cellpadding=""5"" align=""center"" border=""1"" width=""100%"">" skip.
    put unformatted
    "<TR align=""center"" style=""font:bold;background:#CCCCCC"">"
    "<TD>Наименование показателя</TD>"
    "<TD>шифры</TD>".

    for each crc where crc.crc > 1 no-lock:
        if index(v-str, crc.code) > 0 then do:
            put unformatted
            "<TD>" crc.code "</TD>".
        end.
    end.
    "</TR>".

    put unformatted
    "<TR align=""center"">"
    "<TD>А</TD>"
    "<TD>Б</TD>".


    i = 0.
    for each crc where crc.crc > 1 no-lock:
        if index(v-str, crc.code) > 0 then do:
            i = i + 1.
            put unformatted "<TD>" i "</TD>".
        end.
    end.
    "</TR>".

    for each wrk no-lock:
        put unformatted
        "<TR align=""left"">"
        "<TD>" wrk.name "</TD>".

        if wrk.code <> 0 then put unformatted "<TD>" wrk.code "</TD>".
        if wrk.code  = 0 then put unformatted "<TD></TD>".

        for each crc where crc.crc > 1 no-lock:
            if index(v-str, crc.code) > 0 then do:
                if wrk.code <> 0 then do:
                    v-sum = 0.
                    for each wrk-obr where wrk-obr.code = wrk.code and wrk-obr.crc = crc.code no-lock:
                        if wrk-obr.cr1 > 0 and wrk-obr.dr1 = 0 then  v-sum = v-sum + wrk-obr.cr1.
                        if wrk-obr.dr1 > 0 and wrk-obr.cr1 = 0 then  v-sum = v-sum + wrk-obr.dr1.
                    end.
                    put unformatted "<TD>" replace(string(v-sum / v1000),".",",") "</TD>".
                end.
                else do:
                    put unformatted "<TD></TD>".
                end.
            end.
        end.
    end.
    put unformatted "</TR>".


    {html-end.i " "}
    output close.
    unix silent cptwin value(file1) excel.
    unix silent rm value(file1).
end procedure.

procedure PrintObor:
    file1 = "pb16_obor.html".
    output to value(file1).
    {html-title.i}


    put unformatted
    "<TABLE><tr></tr>"
    "<tr align=""center"" style=""font:bold""><td colspan=""5"">Отчет о движении наличной иностранной валюты, в тысячах единиц валюты</td></tr>"
    "<tr align=""center"" style=""font:bold""><td colspan=""5"">АО ""ForteBank""</td></tr>"
    "<tr align=""center""><td colspan=""5"">c " v-dt1 format "99.99.9999" "  по " v-dt2 format "99.99.9999" "</td></tr>"
    "<tr align=""center""><td colspan=""5"">(расшифровка по оборотам" v-crcrank ")</td></tr>"
    "<tr></tr><tr></tr>"
    "</table>" skip.
    put unformatted
    "<TABLE cellspacing=""0"" cellpadding=""5"" align=""center"" border=""1"" width=""100%"">" skip.
    put unformatted
    "<TR align=""center"" style=""font:bold;background:#CCCCCC"">"
    "<TD>Наименование филиала</TD>"
    "<TD>№ транзакции</TD>"
    "<TD>Шаблон <br> транзакции</TD>"
    "<TD>Валюта</TD>"
    "<TD>Счет ГК по Дебету</TD>"
    "<TD>Счет ГК по Кредиту</TD>"
    "<TD>Счет по Дебету</TD>"
    "<TD>Наименование счета по Дебету</TD>"
    "<TD>Счет по Кредиту</TD>"
    "<TD>Наименование счета по Кредиту</TD>"
    "<TD>Сумма по номиналу <br> по Дт</TD>"
    "<TD>Сумма по эквиваленту <br> по Дт</TD>"
    "<TD>Сумма по номиналу <br> по Кт</TD>"
    "<TD>Сумма по эквиваленту <br> по Кт</TD>"
    "<TD>Кассовый символ</TD>"
    "<TD>КБЕ</TD>"
    "<TD>КОД</TD>"
    "<TD>КНП</TD>"
    "<TD>Страна отправителя</TD>"
    "<TD>Страна получателя</TD>"
    "<TD>Шифр</TD>"
    "<TD>Назначение</TD>"
    "</TR>".


    for each wrk-obr where
    wrk-obr.code <> 100 and wrk-obr.code <> 600 and wrk-obr.code <> 200 and wrk-obr.code <> 400 and wrk-obr.code <> 430 and wrk-obr.code <> 440 no-lock:
        if wrk-obr.code <> 9999 then v-code = string(wrk-obr.code).
        else v-code = "КО".
        put unformatted
        "<TR align=""left"">"
        "<TD>" wrk-obr.fil "</TD>"
        "<TD>" wrk-obr.jh "</TD>"
        "<TD>" wrk-obr.trx "</TD>"
        "<TD>" wrk-obr.crc "</TD>"
        "<TD>" wrk-obr.glD "</TD>"
        "<TD>" wrk-obr.glC "</TD>"
        "<TD>" wrk-obr.dacc "</TD>"
        "<TD>" wrk-obr.daccname "</TD>"
        "<TD>" wrk-obr.cacc "</TD>"
        "<TD>" wrk-obr.caccname "</TD>"
        "<TD>" replace(string(wrk-obr.dr1 / v1000),".",",") "</TD>"
        "<TD>" replace(string(wrk-obr.dr2 / v1000),".",",") "</TD>"
        "<TD>" replace(string(wrk-obr.cr1 / v1000),".",",") "</TD>"
        "<TD>" replace(string(wrk-obr.cr2 / v1000),".",",") "</TD>"
        "<TD>" wrk-obr.kas "</TD>"
        "<TD>" wrk-obr.kbe "</TD>"
        "<TD>" wrk-obr.kod "</TD>"
        "<TD>" wrk-obr.knp "</TD>"
        "<TD>" wrk-obr.country1 "</TD>"
        "<TD>" wrk-obr.country2 "</TD>"
        "<TD>" v-code "</TD>"
        "<TD>" wrk-obr.rem "</TD>"
        "</TR>".
    end.

    {html-end.i " "}
    output close.
    unix silent cptwin value(file1) excel.
    unix silent rm value(file1).
end procedure.

procedure PrintOst:
    file1 = "pb16_ost.html".
    output to value(file1).
    {html-title.i}

    put unformatted
    "<TABLE><tr></tr>"
    "<tr align=""center"" style=""font:bold""><td colspan=""5"">Отчет о движении наличной иностранной валюты, в тысячах единиц валюты</td></tr>"
    "<tr align=""center"" style=""font:bold""><td colspan=""5"">АО ""ForteBank""</td></tr>"
    "<tr align=""center""><td colspan=""5"">c " v-dt1 format "99.99.9999" "  по " v-dt2 format "99.99.9999" "</td></tr>"
    "<tr align=""center""><td colspan=""5"">(расшифровка по остаткам" v-crcrank ")</td></tr>"
    "<tr></tr><tr></tr>"
    "</table>" skip.
    put unformatted
    "<TABLE cellspacing=""0"" cellpadding=""5"" align=""center"" border=""1"" width=""100%"">" skip.
    put unformatted
    "<TR align=""center"" style=""font:bold;background:#CCCCCC"">"
    "<TD>Наименование <br> филиала</TD>"
    "<TD>Балансовый счет</TD>"
    "<TD>Валюта</TD>"
    "<TD>Остаток на <br> начало периода <br> (номинал)</TD>"
    "<TD>Остаток на <br> начало периода <br> (эквивалент)</TD>"
    "<TD>Остаток на <br> конец периода <br> (номинал)</TD>"
    "<TD>Остаток на <br> конец периода <br> (эквивалент)</TD>".


    for each wrk-ost where wrk-ost.nom_beg + wrk-ost.nom_end > 0 no-lock:
        put unformatted
        "<TR align=""left"">"
        "<TD>" wrk-ost.fil "</TD>"
        "<TD>" wrk-ost.gl  "</TD>"
        "<TD>" wrk-ost.crc "</TD>"
        "<TD>" replace(string(wrk-ost.nom_beg / v1000),".",",") "</TD>"
        "<TD>" replace(string(wrk-ost.ekv_beg / v1000),".",",") "</TD>"
        "<TD>" replace(string(wrk-ost.nom_end / v1000),".",",") "</TD>"
        "<TD>" replace(string(wrk-ost.ekv_end / v1000),".",",") "</TD>".
        "</TR>".
    end.

    {html-end.i " "}
    output close.
    unix silent cptwin value(file1) excel.
    unix silent rm value(file1).
end procedure.
