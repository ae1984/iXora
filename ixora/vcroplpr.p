/* vcroplpr.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
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
 * CHANGES
*/

/* vcctrppl.p - Валютный контроль 
Список клиентов с контрактами, по которым были проплаты за указанный период

 01.11.2002 nadejda создан

*/

{vc.i}

{global.i}
{sum2str.i}
{name2sort.i}

def var v-ncrccod like ncrc.code.
def var v-sum as deci.
def var v-sum0 as deci.
def var v-sumcon as deci.
def var v-sumkzt as deci.
def var v-sumstr as char.
def var v-depart as integer.
def var v-dtb as date format "99/99/9999".
def var v-dte as date format "99/99/9999".
def var v-dnvid as char.
def var v-doctypes as char.
def var v-icif as integer.
def var v-icontract as integer.
def var v-idocs as integer.
def var v-koldocs as integer.
def var v-prim as char.
def var v-maxnum like vcdocs.docs.
def var v-sign as char.

def temp-table t-sverka 
  field crc like crc.crc
  field sum as deci init 0
  field sumcon as deci init 0
  field sumkzt as deci init 0
  index crc is primary crc.

def temp-table t-cif
  field nmsort like cif.name
  field cif like cif.cif
  field name like cif.name
  field sumkzt as deci init 0
  field sumtoday as deci init 0
  index main is primary nmsort.

{comm-txb.i}
def var s-vcourbank as char.
s-vcourbank = comm-txb().

def stream vcrpt.
output stream vcrpt to vcrep.htm.

v-dtb = date("01/" + string(month(g-today), "99") + "/" + string(year(g-today), "9999")).
v-dte = g-today.

update skip(1) 
   v-dtb label "Начало периода" skip 
   v-dte label " Конец периода" skip(1) 
   with side-label centered row 5 title " ВВЕДИТЕ ПЕРИОД ОТЧЕТА : ".

message "  Формируется отчет...".

put stream vcrpt unformatted 
   "<HTML>" skip 
   "<HEAD>" skip
   "<TITLE>Список клиентов АО TEXAKABANK, имеющих валютные контракты и проплаты с " + string(v-dtb, "99/99/99") + 
     " по " + string(v-dte, "99/99/99") + "</TITLE>" skip
   "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
   "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
   "<STYLE TYPE=""text/css"" ID=""default""> table " 
      "\{font:Times New Roman Cyr, Verdana, sans; font-size:x-small; 
       border-collapse: collapse\; valign:top}</STYLE>" skip
   "</HEAD>" skip
   "<BODY>" skip
   "<P align = ""center""><FONT size=""4"" face=""Times New Roman Cyr, Verdana, sans"">"
   "<B>Список клиентов АО TEXAKABANK, имеющих валютные контракты," + "<BR></B></FONT></P>" skip
     "<P align = ""center""><B> по которым были сделаны проплаты с " + string(v-dtb, "99/99/99") + 
     " по " + string(v-dte, "99/99/99") + "</B><BR><BR></P>" skip
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip.

for each cif where can-find(first vccontrs where vccontrs.cif = cif.cif and 
       can-find(first vcdocs where vcdocs.contract = vccontrs.contract and vcdocs.dntype = "03" and 
         vcdocs.dndate >= v-dtb and vcdocs.dndate <= v-dte and vcdocs.sum <> 0 no-lock) no-lock) and
       can-find(first lon where (lon.cif = cif.cif) and lon.gua = "lo" and 
         (lon.dam[1] <> lon.cam[1]) no-lock)
    no-lock:
  create t-cif.
  assign t-cif.cif = cif.cif
         t-cif.name = trim(trim(cif.name) + " " + trim(cif.prefix)).
  t-cif.nmsort = name2sort(t-cif.name).
end.


v-icif = 0.

for each t-cif, 
    each vccontrs where vccontrs.cif = t-cif.cif and 
       can-find(first vcdocs where vcdocs.contract = vccontrs.contract and vcdocs.dntype = "03" and 
                vcdocs.dndate >= v-dtb and vcdocs.dndate <= v-dte and vcdocs.sum <> 0 no-lock)
    no-lock
    break by t-cif.nmsort by t-cif.cif by vccontrs.ctdate by vccontrs.ctnum by vccontrs.contract:

  if first-of(t-cif.cif) then do:
    v-icif = v-icif + 1.
    v-icontract = 0.
    put stream vcrpt unformatted
      "<TR valign = ""top"">" skip 
        "<TD align=""right""><B>" + string(v-icif) + "</B></TD>" skip
        "<TD align=""left""><B>" + t-cif.cif + "</B></TD>" skip
        "<TD colspan = ""8""><B>" + t-cif.name + "</B></TD>" skip
      "</TR>" skip

      "<TR valign = ""top"">" skip 
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD align=""center"">Номер ссудного счета</TD>" skip
        "<TD align=""center"">Код вал.</TD>" skip
        "<TD align=""center"">Остаток</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
      "</TR>" skip.

    v-idocs = 0.    
    for each lon where (lon.cif = t-cif.cif) and lon.gua = "lo" and (lon.dam[1] <> lon.cam[1])
         no-lock:
      v-idocs = v-idocs + 1.
      find crc where crc.crc = lon.crc no-lock no-error.
      v-sum = lon.dam[1] - lon.cam[1].
      v-sumstr = sum2str(v-sum).
      put stream vcrpt unformatted
        "<TR valign = ""top"">" skip 
          "<TD>&nbsp;</TD>" skip
          "<TD>&nbsp;</TD>" skip
          "<TD align=""right"">" + string(v-idocs) + "</TD>" skip
          "<TD align=""left"">" + lon.lon + "</TD>" skip
          "<TD align=""center"">" + crc.code + "</TD>" skip
          "<TD align=""right"">" + v-sumstr + "</TD>" skip
          "<TD>&nbsp;</TD>" skip
          "<TD>&nbsp;</TD>" skip
        "</TR>" skip.

    end.
 
  end.

  if first-of(vccontrs.contract) then do:
    v-icontract = v-icontract + 1.
    v-idocs = 0.
    for each t-sverka. delete t-sverka. end.
    v-sumstr = sum2str(vccontrs.ctsum).
    find ncrc where ncrc.crc = vccontrs.ncrc no-lock no-error.
    put stream vcrpt unformatted
      "<TR valign = ""top"">" skip 
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD align=""right"">" +  string(v-icontract) + "</TD>" skip
        "<TD colspan = ""7"" align=""left"">Номер и дата контракта&nbsp;:&nbsp;&nbsp;"
           + trim(vccontrs.ctnum) + " от " + string(vccontrs.ctdate, "99/99/9999") + "</TD>" skip
      "</TR>" skip
      "<TR valign = ""top"">" skip 
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD colspan = ""7"" align=""left"">Сумма и валюта контракта&nbsp;:&nbsp;"
          + v-sumstr + "&nbsp;" + ncrc.code + "</TD>" skip
      "</TR>" skip
      "<TR valign = ""top"">" skip 
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD align=""center"">Код вал.</TD>" skip
        "<TD align=""center"">Сумма</TD>" skip
        "<TD align=""center"">Сумма в валюте контракта</TD>" skip
        "<TD align=""center"">Сумма в KZT по курсу на дату платежа</TD>" skip
        "<TD align=""center"">Сумма в KZT по курсу на сегодня</TD>" skip
      "</TR>" skip.
  end.

  for each vcdocs where vcdocs.contract = vccontrs.contract and 
         vcdocs.dntype = "03" and 
         vcdocs.dndate >= v-dtb and vcdocs.dndate <= v-dte and vcdocs.sum <> 0 no-lock 
         break by vcdocs.pcrc by vcdocs.payret :
    accumulate vcdocs.sum (sub-total by vcdocs.pcrc by vcdocs.payret).
    accumulate vcdocs.sum / vcdocs.cursdoc-con (sub-total by vcdocs.pcrc by vcdocs.payret).

    find last ncrchis where ncrchis.crc = vcdocs.pcrc and ncrchis.rdt <= vcdocs.dndate 
        no-lock no-error.
    v-sum0 = vcdocs.sum * ncrchis.rate[1].
    accumulate v-sum0 (sub-total by vcdocs.pcrc by vcdocs.payret).

    if last-of(vcdocs.payret) then do:
      v-sum = (accum sub-total by vcdocs.payret vcdocs.sum).
      v-sumcon = (accum sub-total by vcdocs.payret vcdocs.sum / vcdocs.cursdoc-con).
      v-sumkzt = (accum sub-total by vcdocs.payret v-sum0).
      if vcdocs.payret then do:
        v-sum = - v-sum.
        v-sumcon = - v-sumcon.
        v-sumkzt = - v-sumkzt.
      end.
      find first t-sverka where t-sverka.crc = vcdocs.pcrc no-error.
      if not avail t-sverka then do:
        create t-sverka.
        t-sverka.crc = vcdocs.pcrc.
      end.
      t-sverka.sum = t-sverka.sum + v-sum.
      t-sverka.sumcon = t-sverka.sumcon + v-sumcon.
      t-sverka.sumkzt = t-sverka.sumkzt + v-sumkzt.
    end.
  end.


  for each t-sverka :
    find ncrc where ncrc.crc = t-sverka.crc no-lock no-error.
    put stream vcrpt unformatted
      "<TR>" skip 
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD align=""center"">" + ncrc.code + "</TD>" skip.

    find ncrc where ncrc.crc = vccontrs.ncrc no-lock no-error.
    put stream vcrpt unformatted
        "<TD align=""right"">" + sum2str(t-sverka.sum) + "</TD>" skip
        "<TD align=""right"">" + sum2str(t-sverka.sumcon) + "</TD>" skip
        "<TD align=""right"">" + sum2str(t-sverka.sumkzt) + "</TD>" skip
        "<TD align=""right"">" + sum2str(t-sverka.sumcon * ncrc.rate[1]) + "</TD>" skip
      "</TR>" skip.
  end.


  if last-of(vccontrs.contract) then do:
    for each t-sverka.  
      accumulate t-sverka.sumcon (total).
      accumulate t-sverka.sumkzt (total).
    end.
    v-sumcon = (accum total t-sverka.sumcon).
    v-sumkzt = (accum total t-sverka.sumkzt).
    t-cif.sumkzt = t-cif.sumkzt + v-sumkzt.
    find ncrc where ncrc.crc = vccontrs.ncrc no-lock no-error.
    t-cif.sumtoday = t-cif.sumtoday + v-sumcon * ncrc.rate[1].
    put stream vcrpt unformatted
      "<TR valign = ""top"">" skip 
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD align=""center"">Итого : </TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD align=""right"">" + sum2str(v-sumcon) + "</TD>" skip
        "<TD align=""right"">" + sum2str(v-sumkzt) + "</TD>" skip
        "<TD align=""right"">" + sum2str(v-sumcon * ncrc.rate[1]) + "</TD>" skip
      "</TR>" skip.
  end.

  if last-of(t-cif.cif) then do:
    put stream vcrpt unformatted
      "<TR valign = ""top"">" skip 
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD align=""center""><B>Итого по клиенту : </B></TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD align=""right""><B>" + sum2str(t-cif.sumkzt) + "</B></TD>" skip
        "<TD align=""right""><B>" + sum2str(t-cif.sumtoday) + "</B></TD>" skip
      "</TR>" skip.
  end.
end.

put stream vcrpt unformatted
  "</TABLE>" skip
  "<BR><BR>" skip(1).


put stream vcrpt unformatted
  "</BODY>" skip
  "</HTML>" skip.


output stream vcrpt close.

hide message no-pause.

unix silent cptwin vcrep.htm iexplore.

pause 0.





