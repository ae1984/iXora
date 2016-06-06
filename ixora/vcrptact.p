/* vcrptact.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Отчет по актам
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
        25.08.2009 galina
 * BASES
        BANK COMM
 * CHANGES
        09.10.2013 damir - Внедрено Т.З. № 1670.
*/
{vc.i}
{global.i}
{functions-def.i}
{sum2strd.i}

def shared var s-contract like vccontrs.contract.
def shared var v-cifname as char.

def var v-ncrccod like ncrc.code.
def var v-sum1 as deci.
def var v-sum2 as deci.
def var v-contrnum as char.
def var v-psnum as char.
def var v-form2 as char.
def var s-dnvid as char init "g,o".
def var s-vcdoctypes as char.

def temp-table t-dntype
  field dntype as char
  field dnvid as char
  field name as char format "x(60)"
  index dntype is primary dntype.

def temp-table t-docs
  field docs like vcdocs.docs
  field dntype like vcdocs.dntype
  field dndate like vcdocs.dndate
  field dnnum like vcdocs.dnnum
  field sum like vcdocs.sum
  field pcrc like vcdocs.pcrc
  field cursdoc-con like vcdocs.cursdoc-con
  index main is primary dntype dndate dnnum sum docs.

def stream vcrpt.
output stream vcrpt to vcrptpl.htm.

find vccontrs where vccontrs.contract = s-contract no-lock no-error.
find cif where cif.cif = vccontrs.cif no-lock no-error.
find vcps where vcps.contract = s-contract and vcps.dntype = "01" no-lock no-error.
if avail vcps then v-psnum = vcps.dnnum + string(vcps.num).
find ofc where ofc.ofc = g-ofc no-lock no-error.
find ncrc where ncrc.crc = vccontrs.ncrc no-lock no-error.
if avail ncrc then v-ncrccod = ncrc.code. else v-ncrccod = "".

if vccontrs.expimp = "i" then v-contrnum = "ПО ИМПОРТУ".
else v-contrnum = "ПО ЭКСПОРТУ".

s-vcdoctypes = "".
for each codfr where codfr.codfr = "vcdoc" and lookup(trim(codfr.name[5]),s-dnvid) > 0 no-lock:
    s-vcdoctypes = s-vcdoctypes + codfr.code + ",".
end.

{html-title.i
 &stream = " stream vcrpt "
 &title = " "
 &size-add = "x-"
}

put stream vcrpt unformatted
    "<P><FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans"">" + FirstLine(1, 1) + "<BR>" skip
    " Исполнитель : " + ofc.name + "<BR></FONT></P>" skip
    "<P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">" skip
    "<B>ОПЕРАТИВНАЯ ИНФОРМАЦИЯ ПО КОНТРАКТУ " + v-contrnum + "<BR><BR>" skip
    trim(vccontrs.ctnum) + " от " + string(vccontrs.ctdate, "99/99/9999") + "<BR><BR>" skip
    "</B></FONT></P>" skip
    "<TABLE width=""90%"" border=""0"" cellspacing=""0"" cellpadding=""3"">" skip
    "<TR valign=""top"">" skip
    "<TD width=""20%"" align=""right"">КЛИЕНТ : </TD>" skip
    "<TD width=""80%"">" + v-cifname + "</TD></TR>" skip
    "<TR valign=""top"">" skip
    "<TD width=""20%"" align=""right"">ПАСПОРТ/УНК : </TD>" skip
    "<TD width=""80%"">" + v-psnum + "</TD></TR>" skip
    "<TR valign=""top"">" skip
    "<TD width=""20%"" align=""right"">ФОРМА ОПЛ : </TD>" skip
    "<TD width=""80%"">" + vccontrs.ctformrs + "</TD></TR>" skip
    "<TR valign=""top"">" skip
    "<TD width=""20%"" align=""right"">ПОСЛ. ДАТА : </TD>" skip
    "<TD width=""80%"">" + string(vccontrs.lastdate, "99/99/9999") + "</TD></TR>" skip
    "</TABLE>" skip.

empty temp-table t-docs.
for each vcdocs where vcdocs.contract = s-contract and lookup(vcdocs.dntype,s-vcdoctypes) > 0 no-lock:
    create t-docs.
    buffer-copy vcdocs to t-docs.
    if vcdocs.payret then t-docs.sum = - t-docs.sum.
end.

v-sum2 = 0.
for each t-docs no-lock break by t-docs.dntype:
    if first-of(t-docs.dntype) then do:
        find first codfr where codfr.codfr = "vcdoc" and codfr.code = t-docs.dntype no-lock no-error.
        put stream vcrpt unformatted
            "<P align=center style='font-size:14pt;font:bold'>" if avail codfr then codfr.name[1] else "Тип документа в справочнике не найден" "</P>" skip
            "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""0"">" skip
            "<TR align=""center"" style='font-size:10pt;font:bold'>" skip
            "<TD>Дата</TD>" skip
            "<TD>Номер документа</TD>" skip
            "<TD>Сумма</TD>" skip
            "<TD>Валюта</TD>" skip
            "<TD>Курс к валюте контракта</TD>" skip
            "<TD>Сумма в валюте контракта</TD>" skip
            "<TD>Валюта контракта</TD>" skip
            "</TR>" skip.

        v-sum1 = 0.
    end.

    v-sum1 = v-sum1 + t-docs.sum / t-docs.cursdoc-con.

    find ncrc where ncrc.crc = t-docs.pcrc no-lock no-error.

    put stream vcrpt unformatted
        "<TR style='font-size:10pt'>" skip
        "<TD align=""center"">" + string(t-docs.dndate, "99/99/9999") + "</TD>" skip
        "<TD align=""left"">" + t-docs.dnnum + "</TD>" skip
        "<TD align=""right"">" + sum2strd(t-docs.sum, 2) + "</TD>" skip
        "<TD align=""center"">" + ncrc.code + "</TD>" skip
        "<TD align=""right"">" + sum2strd(t-docs.cursdoc-con, 4) + "</TD>" skip
        "<TD align=""right"">" + sum2strd(t-docs.sum / t-docs.cursdoc-con, 2) + "</TD>" skip
        "<TD align=""center"">" + v-ncrccod + "</TD>" skip
        "</TR>" skip.
    if last-of(t-docs.dntype) then do:
        put stream vcrpt unformatted
            "<TR style='font-size:10pt'>" skip
            "<TD colspan=""5"" align=""right""><B>ИТОГО : </B></TD>" skip
            "<TD align=""right""><B>" + sum2strd(v-sum1, 2) + "</B></TD>" skip
            "<TD align=""center""><B>" + v-ncrccod + "</B></TD>" skip
            "</TR>" skip
            "<TR><TD colspan=""7"">&nbsp;</TD></TR>" skip
            "</TABLE>" skip.
        v-sum2 = v-sum2 + v-sum1.
    end.
end.

put stream vcrpt unformatted
    "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""0"">" skip
    "<TR align=""center"" style='font-size:10pt;font:bold'>" skip
    "<TD>ИТОГО ПО ДОКУМЕНТАМ :</TD>" skip
    "<TD>" + sum2strd(v-sum2, 2) + "</TD>" skip
    "</TR>" skip
    "</TABLE>" skip.

{html-end.i "stream vcrpt" }

output stream vcrpt close.

unix silent value("cptwin vcrptpl.htm iexplore").
