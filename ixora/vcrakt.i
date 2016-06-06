/* vcrakt.i
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

/* vcrakt.i  Валютный контроль
   Акт сверки
   Вывод временной таблицы в HTML

   24.01.2003 nadejda - вырезан кусок из vcraktpa.p
*/


{comm-txb.i}

def temp-table t-sverka 
  field dgtd like vcdocs.docs init 0
  field dplat like vcdocs.docs init 0
  index doc is primary dgtd dplat.

def var v-sum like vcdocs.sum.
def var v-dnvid as char.
def var v-doctypes as char.
def var v-icif as integer.
def var v-icontract as integer.
def var v-idocs as integer.
def var v-prim as char.
def var v-maxnum like vcdocs.docs.
def var v-sign as char.
def var v-ourbank as char.
def var v-checkcif as logical.
def var v-god as integer format "9999" init 2000.
def var v-rnnfind as char format "x(12)" init "".
def var v-dtbcontrs as date.
def var v-dtecontrs as date.

def temp-table t-contrs like vccontrs.

for each vccontrs no-lock:
  accumulate vccontrs.rdt (minimum).
end.
v-dtbcontrs = accum minimum vccontrs.rdt.
v-dtecontrs = g-today.

update skip(1) 
   v-god      label " ГОД СВЕРКИ " "  " skip(1) 
   v-rnnfind  label " НАЧАЛО РНН " "  " skip(1) 

   " ИЗМЕНЕНИЯ В КОНТРАКТЕ ЗА ПЕРИОД " skip
   v-dtbcontrs label "          С " skip
   v-dtecontrs label "         ПО " skip
   with side-label centered row 5 title " ВВЕДИТЕ ГОД ОТЧЕТА : ".

v-rnnfind = trim(v-rnnfind).
v-ourbank = comm-txb().

for each vccontrs where vccontrs.bank = v-ourbank and vccontrs.cttype = "1" 
         no-lock break by vccontrs.cif:
  if first-of (vccontrs.cif) then do:
    v-checkcif = no.

    find cif where cif.cif = vccontrs.cif no-lock no-error.
    if avail cif then v-checkcif = (v-rnnfind = "" or trim(cif.jss) begins v-rnnfind) and {&depart}.
  end.

  if v-checkcif then do:
    if ({&usl}) or year(vccontrs.ctdate) <> v-god then next.

    /* есть ли вообще паспорт сделки? */
    find first vcps where vcps.contract = vccontrs.contract and vcps.dntype = "01" no-lock no-error.
    if not avail vcps then next.

    /* проверим внесенные документы по контракту за указанный период */
    /* контракт зарегистрирован в этот период? */
    if not (vccontrs.rdt >= v-dtbcontrs and vccontrs.rdt <= v-dtecontrs) then do: 
      /* а может, были паспорт/доплисты? */
      find first vcps where vcps.contract = vccontrs.contract and (vcps.rdt >= v-dtbcontrs and vcps.rdt <= v-dtecontrs) no-lock no-error.
      if not avail vcps then do:
        /* а может, были лицензии/рег.свид-ва? */
        find first vcrslc where vcrslc.contract = vccontrs.contract and (vcrslc.rdt >= v-dtbcontrs and vcrslc.rdt <= v-dtecontrs) no-lock no-error.
        if not avail vcrslc then do:
          /* ну может документы какие были? */
          find first vcdocs where vcdocs.contract = vccontrs.contract and (vcdocs.rdt >= v-dtbcontrs and vcdocs.rdt <= v-dtecontrs) no-lock no-error.
          if not avail vcdocs then next.  /* ну ничего не было внесено! переходим к следующему контракту */
        end.
      end.
    end.

    find t-cif where t-cif.cif = vccontrs.cif no-error.
    if not avail t-cif then do:
      find cif where cif.cif = vccontrs.cif no-lock no-error.

      create t-cif.
      assign t-cif.cif = cif.cif
             t-cif.name = trim(trim(cif.name) + " " + trim(cif.prefix)).
      if not trim(cif.ssn) begins "999" and not trim(cif.ssn) begins "000" then
             t-cif.okpo = trim(cif.ssn).
      t-cif.rnn = trim(cif.jss).
      t-cif.nmsort = name2sort(t-cif.name).
    end.
    

    create t-contrs.
    buffer-copy vccontrs to t-contrs.
  end.
end.

def stream vcrpt.
output stream vcrpt to vcakt.htm.

put stream vcrpt unformatted 
   "<HTML>" skip 
   "<HEAD>" skip
   "<TITLE>Акт сверки по паспортам сделок между ОВК ТУ по г.Алматы и АО ""TEXAKABANK"" за " + string(v-god, "9999") + " год</TITLE>" skip
   "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
   "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
   "<STYLE TYPE=""text/css"" ID=""default""> table " 
      "\{font:Times New Roman Cyr, Verdana, sans; font-size:x-small; 
       border-collapse: collapse\; valign:top}</STYLE>" skip
   "</HEAD>" skip
   "<BODY>" skip
   "<P align = ""center""><FONT size=""4"" face=""Times New Roman Cyr, Verdana, sans"">"
   "<B>АКТ СВЕРКИ ПО ПАСПОРТАМ СДЕЛОК МЕЖДУ ОВК ТУ ПО Г.АЛМАТЫ<BR>" skip
     "И АО ""TEXAKABANK""<BR></B></FONT></P>" skip
     "<P align = ""center""><B>за " + string(v-god, "9999") + " год</B><BR><BR></P>" skip
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip
   "<TR align=""center"">" skip
     "<TD colspan=""3"">&nbsp;</TD>" skip
     "<TD align=""left""><FONT size=""3""><B>N ГТД</B></FONT></TD>" skip
     "<TD><FONT size=""3""><B>Сумма получ. / отправл. товара</B></FONT></TD>" skip
     "<TD><FONT size=""3""><B>Код вал.</B></FONT></TD>" skip
     "<TD><FONT size=""3""><B>Дата оплаты</B></FONT></TD>" skip
     "<TD><FONT size=""3""><B>Сумма проплач. / получ. ден. средств</B></FONT></TD>" skip
     "<TD><FONT size=""3""><B>Код вал.</B></FONT></TD>" skip
     "<TD><FONT size=""3""><B>Примечание</B></FONT></TD>" skip
   "</TR>" skip.

v-icif = 0.

for each t-cif, each t-contrs where t-contrs.cif = t-cif.cif
    break by {&fldsort} by t-cif.cif by t-contrs.ctdate by t-contrs.ctnum by t-contrs.contract:

  if first-of(t-cif.cif) then do:
    v-icif = v-icif + 1.
    v-icontract = 0.
    put stream vcrpt unformatted
        "<TR valign = ""top"">" skip 
          "<TD align=""right""><B>" + string(v-icif) + "</B></TD>" skip
          "<TD colspan = ""9""><B>" + t-cif.name + "</B></TD>" skip
        "</TR>" skip
        "<TR>" skip 
          "<TD align=""right"">&nbsp;</TD>" skip
          "<TD>ОКПО</TD>" skip
          "<TD colspan = ""8"">" + t-cif.okpo + "</TD>" skip
        "</TR>" skip
        "<TR>" skip
          "<TD align=""right"">&nbsp;</TD>" skip
          "<TD>РНН</TD>" skip
          "<TD colspan = ""8"">" + t-cif.rnn + "</TD>" skip
        "</TR>" skip.
  end.

  if first-of(t-contrs.contract) then do:
    for each t-sverka. delete t-sverka. end.
  end.


  /* все ГТД */
  v-dnvid = "g". v-doctypes = "".
  for each codfr where codfr.codfr = "vcdoc" and index(v-dnvid, codfr.name[5]) > 0 no-lock:
    v-doctypes = v-doctypes + codfr.code + ",".
  end.
  for each vcdocs where vcdocs.contract = t-contrs.contract and 
      lookup(vcdocs.dntype, v-doctypes) > 0 use-index main:
    create t-sverka.
    assign /*t-sverka.contract=t-contrs.contract*/
           t-sverka.dgtd = vcdocs.docs.
  end.

  /* все платежные */
  v-dnvid = "p". v-doctypes = "".
  for each codfr where codfr.codfr = "vcdoc" and index(v-dnvid, codfr.name[5]) > 0 no-lock:
    v-doctypes = v-doctypes + codfr.code + ",".
  end.
  for each vcdocs where vcdocs.contract = t-contrs.contract and 
      lookup(vcdocs.dntype, v-doctypes) > 0 use-index main:
    find first t-sverka where t-sverka.dplat = 0 no-error.
    if not avail t-sverka then do:
      create t-sverka.
    end.
    t-sverka.dplat = vcdocs.docs.
  end.

  /* для сортировки - присвоить несуществующий большой номер ГТД пустым строчкам */
  if can-find(first t-sverka where t-sverka.dgtd = 0 no-lock) then do:
    v-maxnum = current-value(vc-docs) + 1000.
    for each t-sverka where t-sverka.dgtd = 0 :
      t-sverka.dgtd = v-maxnum.
    end.
  end.
  
  if first-of(t-contrs.contract) then do:
    v-icontract = v-icontract + 1.
    v-idocs = 0.
    find first vcps where vcps.contract = t-contrs.contract and vcps.dntype = "01" no-lock no-error.
    put stream vcrpt unformatted
      "<TR valign = ""top"">" skip 
        "<TD>&nbsp;</TD>" skip
        "<TD align=""right"">" +  string(v-icontract) + "</TD>" skip
        "<TD colspan = ""8"" align=""left"">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            Паспорт сделки&nbsp;:&nbsp;&nbsp;" + trim(vcps.dnnum) + "</TD>" skip
      "</TR>" skip
      "<TR>" skip 
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD colspan = ""8"" align=""left"">Номер и дата контракта&nbsp;:&nbsp;&nbsp;"
        + trim(t-contrs.ctnum) + " от " + string(t-contrs.ctdate, "99/99/9999") + "</TD>" skip
      "</TR>" skip.
  end.


  for each t-sverka :
    v-idocs = v-idocs + 1.
    put stream vcrpt unformatted
      "<TR>" skip 
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD align=""right"">" + string(v-idocs) + "</TD>" skip.

    find vcdocs where vcdocs.docs = t-sverka.dgtd no-lock no-error.
    if avail vcdocs then do:
      v-sum = vcdocs.sum.
      if vcdocs.payret then v-sign = "-". else v-sign = "".
      v-prim = trim(vcdocs.info[1]).
      find ncrc where ncrc.crc = vcdocs.pcrc no-lock no-error.
      put stream vcrpt unformatted
        "<TD align=""left"">" + trim(vcdocs.dnnum) + "</TD>" skip
        "<TD align=""right"">" + v-sign + trim(string(v-sum, ">>>>>>>>>>>>>>9.99")) + "</TD>" skip
        "<TD align=""center"">" + ncrc.code + "</TD>" skip.
    end.
    else do:
      put stream vcrpt unformatted
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip.
      v-prim = "".
    end.

    find vcdocs where vcdocs.docs = t-sverka.dplat no-lock no-error.
    if avail vcdocs then do:
      v-sum = vcdocs.sum.
      if vcdocs.payret then v-sign = "-". else v-sign = "".
      if v-prim <> "" and trim(vcdocs.info[1]) <> "" then v-prim = v-prim + ", ".
      v-prim = v-prim + trim(vcdocs.info[1]).
      find ncrc where ncrc.crc = vcdocs.pcrc no-lock no-error.
      put stream vcrpt unformatted
        "<TD align=""center"">" + string(vcdocs.dndate, "99/99/9999") + "</TD>" skip
        "<TD align=""right"">" + v-sign + trim(string(v-sum, ">>>>>>>>>>>>>>9.99")) + "</TD>" skip 
        "<TD align=""center"">" + ncrc.code + "</TD>" skip.
    end.
    else do:
      put stream vcrpt unformatted
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip.
    end.

    put stream vcrpt unformatted
        "<TD align=""left"">" + trim(v-prim) + "</TD>" skip 
      "</TR>" skip.
  end.
end.

find first cmp no-lock no-error.

put stream vcrpt unformatted
  "</TABLE>" skip
  "<BR><BR>" skip
  "<TABLE width=""100%"" align=""center"" border=""0"" cellpadding=""0"" cellspacing=""0"">" skip
    "<TR>" skip
      "<TD width=""50%"">Департамент валютного контроля</TD>" skip
      "<TD width=""50%"">ОВК ТУ по г.Алматы</TD>" skip
    "</TR>" skip
    "<TR>" skip
      "<TD>" cmp.name "</TD>" skip
      "<TD>&nbsp;</TD>" skip
    "</TR>" skip
    "<TR><TD colspan=""2"">&nbsp;</TD></TR>" skip
    "<TR>" skip
      "<TD>______________________________</TD>" skip
      "<TD>______________________________</TD>" skip
    "</TR>" skip
  "</TABLE><BR>" skip.


put stream vcrpt unformatted
  "</BODY>" skip
  "</HTML>" skip.


output stream vcrpt close.

unix silent cptwin vcakt.htm winword.

pause 0.





