/* vcrptpl.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Отчет о ГТД и платежах по контракту
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
        30.10.2002 nadejda создан
        10.12.2002 nadejda добавлен тип документа "Займ", переведен на HTML
        09.10.2013 damir - Внедрено Т.З. № 1670.
*/
{vc.i}

{global.i}
{functions-def.i}
{sum2strd.i}


def shared var s-contract like vccontrs.contract.
def shared var v-cifname as char.

def var v-ncrccod like ncrc.code.
def var v-sum as deci.
def var v-sum0 as deci.
def var v-sum1 as deci.
def var v-sumgtd as deci.
def var v-sumpl as deci.
def var v-contrnum as char.
def var v-psnum as char.
def var v-form2 as char.

def temp-table t-dntype
  field dntype as char
  field dnvid as char
  field name as char format "x(60)"
  index dntype is primary dntype.

def temp-table t-docs
  field docs like vcdocs.docs
  field dntype like vcdocs.dntype
  field dnvid as char
  field dndate like vcdocs.dndate
  field dnnum like vcdocs.dnnum
  field sum like vcdocs.sum
  field pcrc like vcdocs.pcrc
  field cursdoc-con like vcdocs.cursdoc-con
  index main is primary dnvid dntype dndate dnnum sum docs.

def stream vcrpt.
output stream vcrpt to vcrptpl.htm.

find vccontrs where vccontrs.contract = s-contract no-lock no-error.
find cif where cif.cif = vccontrs.cif no-lock no-error.
find vcps where vcps.contract = s-contract and vcps.dntype = "01" no-lock no-error.
if avail vcps then v-psnum = vcps.dnnum + string(vcps.num).
find ofc where ofc.ofc = g-ofc no-lock no-error.
find ncrc where ncrc.crc = vccontrs.ncrc no-lock no-error.
if avail ncrc then v-ncrccod = ncrc.code. else v-ncrccod = "".

if vccontrs.expimp = "i" then
  v-contrnum = "ПО ИМПОРТУ".
else
  v-contrnum = "ПО ЭКСПОРТУ".

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
  "</TABLE>" skip
  "<P>&nbsp;</P>" skip
  "<TABLE width=""90%"" border=""1"" cellspacing=""0"" cellpadding=""3"">" skip
    "<TR align=""center"">" skip
      "<TD width=""10%"">&nbsp;</TD>" skip
      "<TD><FONT size=""1""><B>Дата платежа</B></FONT></TD>" skip
      "<TD><FONT size=""1""><B>Номер документа</B></FONT></TD>" skip
      "<TD><FONT size=""1""><B>Сумма платежа</B></FONT></TD>" skip
      "<TD><FONT size=""1""><B>Валюта платежа</B></FONT></TD>" skip
      "<TD><FONT size=""1""><B>Курс к валюте контракта</B></FONT></TD>" skip
      "<TD><FONT size=""1""><B>Сумма в валюте контракта</B></FONT></TD>" skip
      "<TD><FONT size=""1""><B>Валюта контракта</B></FONT></TD>" skip
    "</TR>" skip.


for each codfr where codfr.codfr = "vcdoc" and index("p",trim(codfr.name[5])) > 0 no-lock:
    create t-dntype.
    assign
    t-dntype.dntype = codfr.code
    t-dntype.dnvid = codfr.name[5]
    t-dntype.name = codfr.name[1].
end.

for each vcdocs where vcdocs.contract = s-contract and can-find(t-dntype where t-dntype.dntype = vcdocs.dntype) no-lock :
    create t-docs.
    buffer-copy vcdocs to t-docs.
    if vcdocs.payret then t-docs.sum = - t-docs.sum.
    find t-dntype where t-dntype.dntype = vcdocs.dntype no-lock no-error.
    t-docs.dnvid = t-dntype.dnvid.
end.

v-sumgtd = 0.
v-sumpl = 0.

for each t-docs break by t-docs.dnvid by t-docs.dntype by t-docs.dndate
      by t-docs.dnnum by t-docs.sum by t-docs.docs:
  if first-of(t-docs.dntype) then do:
    find t-dntype where t-dntype.dntype = t-docs.dntype no-lock.
    put stream vcrpt unformatted
      "<TR align=""left""><TD colspan=""8""><B>" + t-dntype.name + "</B></TD></TR>" skip.
  end.

  accumulate t-docs.sum / t-docs.cursdoc-con (sub-total by t-docs.dntype).

  find ncrc where ncrc.crc = t-docs.pcrc no-lock no-error.

  put stream vcrpt unformatted
    "<TR>" skip
      "<TD>&nbsp;</TD>" skip
      "<TD align=""center"">" + string(t-docs.dndate, "99/99/9999") + "</TD>" skip
      "<TD align=""left"">" + t-docs.dnnum + "</TD>" skip
      "<TD align=""right"">" + sum2strd(t-docs.sum, 2) + "</TD>" skip
      "<TD align=""center"">" + ncrc.code + "</TD>" skip
      "<TD align=""right"">" + sum2strd(t-docs.cursdoc-con, 4) + "</TD>" skip
      "<TD align=""right"">" + sum2strd(t-docs.sum / t-docs.cursdoc-con, 2) + "</TD>" skip
      "<TD align=""center"">" + v-ncrccod + "</TD>" skip
    "</TR>" skip.


  if last-of(t-docs.dntype) then do:
    v-sum1 = (accum sub-total by t-docs.dntype t-docs.sum / t-docs.cursdoc-con).
    put stream vcrpt unformatted
      "<TR>" skip
        "<TD colspan=""6"" align=""right""><B>ИТОГО : </B></TD>" skip
        "<TD align=""right""><B>" + sum2strd(v-sum1, 2) + "</B></TD>" skip
        "<TD align=""center""><B>" + v-ncrccod + "</B></TD>" skip
      "</TR>" skip
      "<TR><TD colspan=""8"">&nbsp;</TD></TR>" skip.

    case t-docs.dnvid :
      when "g" then v-sumgtd = v-sumgtd + v-sum1.
      when "p" then v-sumpl = v-sumpl + v-sum1.
    end case.
  end.
end.

if lookup(vccontrs.cttype, "1,2") > 0 then do:
  put stream vcrpt unformatted
    "<TR><TD colspan=""8"">&nbsp;</TD></TR>" skip
    "<TR><TD colspan=""8"">&nbsp;</TD></TR>" skip.

  if lookup("00",vccontrs.ctformrs) > 0 then do:
    v-sum = v-sumgtd - v-sumpl.
    if lookup("30",vccontrs.ctformrs) = 0 then v-sum = - v-sum.
    put stream vcrpt unformatted
      "<TD align=""right""><B>" + sum2strd(v-sum, 2) + "</B></TD>" skip
      "<TD align=""center""><B>" + v-ncrccod + "</B></TD>" skip.
  end.
  else
    put stream vcrpt unformatted
      "<TD colspan=""2"">&nbsp;</TD>" skip.

  put stream vcrpt unformatted
    "</TR>" skip.
end.

put stream vcrpt unformatted
  "</TABLE>" skip.

{html-end.i "stream vcrpt" }

output stream vcrpt close.

unix silent value("cptwin vcrptpl.htm iexplore").
