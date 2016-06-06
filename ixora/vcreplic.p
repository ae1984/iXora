/* vcreplic.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Отчет по контрактам с лицензями
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        15-3-14
 * AUTHOR
        29.09.2003 nadejda
 * CHANGES
        29/12/2005 nataly  - добавила наименование РКО и ФИО директоров
*/


{mainhead.i}
{vc.i}
{comm-txb.i}

def var s-vcourbank as char.
def var v-regim as integer format "9".
def var v-filename as char init "vclic.htm".
def var v-dtrep as date.
def var v-num as integer.
def var v-dep2 as char.

def temp-table t-lic
  field licid like vcrslc.rslc
  field licdt as date
  field licnum as char
  field cif like cif.cif
  field name as char
  field depart as char
  field contract like vccontrs.contract
  field ctdate as date format "99/99/9999"
  field ctnum as char
  index main is primary unique name cif ctdate ctnum contract licdt licnum licid.

function sum2str returns char (p-value as decimal).
  def var vp-str as char.
  if p-value = 0 then vp-str = "0".
  else vp-str = trim(string(p-value, "->>>,>>>,>>>,>>>,>>9.99")).
  return vp-str.
end.


form 
  skip(1)
  v-regim label " 1) Все лицензии  2) Рабочие  3) Завершенные" " " skip(1)
  with centered side-label row 5 title " ПАРАМЕТРЫ ОТЧЕТА : " frame f-param.

v-regim = 1.

update v-regim with frame f-param.

s-vcourbank = comm-txb().
v-dtrep = g-today.

for each vcrslc no-lock where vcrslc.dntype = "22":
  if not (v-regim = 1 or (v-regim = 2 and vcrslc.info[1] = "R") or (v-regim = 3 and vcrslc.info[1] = "Z")) then next.

  find vccontrs where vccontrs.contract = vcrslc.contract no-lock no-error.
  if vccontrs.bank <> s-vcourbank then next.
  if vccontrs.sts begins "C" then next.

  find cif where cif.cif = vccontrs.cif no-lock no-error.
  find ppoint where ppoint.depart = (integer(cif.jame) mod 1000) no-lock no-error.

  create t-lic.
  assign t-lic.licid = vcrslc.rslc
         t-lic.cif = vccontrs.cif
         t-lic.name = trim(trim(cif.prefix) + " " + trim(cif.name))
         t-lic.depart = ppoint.name
         t-lic.contract = vcrslc.contract
         t-lic.ctdate = vccontrs.ctdate
         t-lic.ctnum = vccontrs.ctnum.

end.


/* вывод отчета */
def stream vcrpt.
output stream vcrpt to value(v-filename).

{html-title.i 
 &stream = "stream vcrpt"
 &title = "АО ""TEXAKABANK"". Отчет о контрактах с лицензиями"
 &size-add = "x-"
}

put stream vcrpt unformatted 
   "<P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">"
   "<B>ЛИЦЕНЗИИ<BR>" skip
   "по валютным экспортно-импортным контрактам" skip
   "<BR><BR>на " + string(v-dtrep, "99/99/9999") + "</B></FONT></P>" skip
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip
   "<TR align=""center"" style=""font-size:xx-small;font:bold"">" skip
     "<TD>N</TD>" skip
     "<TD>Наименование организации-клиента банка</TD>" skip
     "<TD>Код клиента</TD>" skip
     "<TD>Обслуж.департамент</TD>" skip
     "<TD>Дата контракта</TD>" skip
     "<TD>Номер контракта</TD>" skip
     "<TD>Дата<BR>лицензии</TD>" skip
     "<TD>Номер лицензии</TD>" skip
     "<TD>Сумма лицензии</TD>" skip
     "<TD>Срок действия<BR>лицензии</TD>" skip
     "<TD>Статус лицензии</TD>" skip
     "<TD>Дней просрочки</TD>" skip
   "</TR>" skip.

v-num = 0.

for each t-lic :
  find vcrslc where vcrslc.rslc = t-lic.licid no-lock no-error.
  v-num = v-num + 1.

  put stream vcrpt unformatted
      "<TR valign=""top"">" skip 
        "<TD align=""left"">" string(v-num) "</TD>" skip
        "<TD align=""left"">" t-lic.name "</TD>" skip
        "<TD align=""center"">" t-lic.cif "</TD>" skip
        "<TD align=""left""><FONT size=""-2"">" t-lic.depart "</FONT></TD>" skip
        "<TD align=""center"">" t-lic.ctdate "</TD>" skip
        "<TD align=""left"">" t-lic.ctnum "</TD>" skip
        "<TD align=""center"">" vcrslc.dndate "</TD>" skip
        "<TD align=""left"">" vcrslc.dnnum "</TD>" skip
        "<TD align=""right"">" sum2str(vcrslc.sum) "</TD>" skip      
        "<TD align=""center"">" vcrslc.lastdate "</TD>" skip
        "<TD align=""center"">" if vcrslc.info[1] = "Z" then "<B>" else "" vcrslc.info[1] if vcrslc.info[1] = "Z" then "</B>" else "" "</TD>" skip
        "<TD align=""center"">" if vcrslc.info[1] <> "Z" and vcrslc.lastdate <> ? and vcrslc.lastdate < v-dtrep then string(v-dtrep - vcrslc.lastdate, ">>>>>>>>>9") else "" "</TD>" skip
      "</TR>" skip.
end.

put stream vcrpt unformatted
    "</TABLE>" skip
    "<BR><BR>" skip.

find bankl where bankl.bank = s-vcourbank no-lock no-error.

put stream vcrpt unformatted
  "<P><FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans""><B>" skip
    bankl.name skip.

/*find sysc where sysc.sysc = "vc-dep" no-lock no-error.
if avail sysc then
  put stream vcrpt unformatted
    "<BR><BR>" + entry(1, sysc.chval) + "<BR>" + entry(2, sysc.chval) skip.*/

  v-dep2 = string(int(cif.jame) - 1000) .
  find first codfr where codfr = 'vchead' and codfr.code = v-dep2 no-lock no-error .
  if avail codfr and codfr.name[1] <> "" then  
  put stream vcrpt unformatted
    "<BR><BR>" + entry(2, trim(codfr.name[1])) + "<BR>" + entry(1, trim(codfr.name[1])) skip.


put stream vcrpt unformatted
   "</B></FONT></P>" skip.

{html-end.i}

output stream vcrpt close.

unix silent value("cptwin " + v-filename + " iexplore").

pause 0.

