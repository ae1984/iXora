/* vcrepaas.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Отчет по блокированным средствам - журнал регистрации уведомлений
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        15-3-10
 * AUTHOR
        29.11.2002 nadejda
 * CHANGES
*/


{mainhead.i}
{comm-txb.i}

def temp-table t-aas
  field cif like cif.cif
  field dt as date
  field tim as integer
  field aaa like aaa.aaa
  field ln like aas_hist.ln
  field sum as decimal
  field ofc like ofc.ofc
  index main is primary dt tim aaa ln.

def var s-vcourbank as char.
def var v-dtb as date.
def var v-dte as date.
def var v-chcrc as integer init 3.
def var v-num as integer.
def var v-local as integer init 1.
def var v-valcon as logical.
def var v-filename as char init "hb-journal.htm".

function sum2str returns char (p-value as decimal).
  def var vp-str as char.
  if p-value = 0 then vp-str = "&nbsp;".
  else vp-str = trim(string(p-value, "->>>,>>>,>>>,>>>,>>9.99")).
  return vp-str.
end.


form 
  skip(1)
  v-dtb   label "      Начало периода" format "99/99/9999" help " Введите дату начала периода" "   " skip
  v-dte   label "       Конец периода" format "99/99/9999" help " Введите дату конца периода" "   " skip(1)
  v-chcrc label " 1) в валюте, 2) в KZT, 3) все валюты" format "9" help "Выберите вариант отчета" " " skip
  with centered side-label row 5 title " ПЕРИОД ОТЧЕТА : " frame f-dt.


v-dtb = date("01/" + string(month(g-today), "99") + "/" + string(year(g-today))).
v-dte = g-today.

update v-dtb v-dte v-chcrc with frame f-dt.

/* нацвалюта */
find crchs where crchs.Hs = "L" no-lock no-error.
if avail crcHs then v-local = crchs.crc.

/* сборка наложенных специнструкций */
for each aas_hist where aas_hist.sic = 'hb' and 
         aas_hist.chgdat >= v-dtb and aas_hist.chgdat <= v-dte and 
         aas_hist.chgoper = "a" 
         no-lock use-index aasreport:

  find last ofcprofit where ofcprofit.ofc = aas_hist.who and 
       ofcprofit.regdt <= aas_hist.chgdat no-lock no-error.
  if avail ofcprofit then do:
    v-valcon = (ofcprofit.profitcn = "506").
  end.
  else do:
    find ofc where ofc.ofc = aas_hist.who no-lock no-error.
    v-valcon = (avail ofc and ofc.titcd = "506").
  end.

  if v-valcon then do:
    create t-aas.
    assign t-aas.cif = aas_hist.cif
           t-aas.dt = aas_hist.chgdat
           t-aas.tim = aas_hist.chgtime
           t-aas.aaa = aas_hist.aaa
           t-aas.ln = aas_hist.ln
           t-aas.sum = aas_hist.chkamt
           t-aas.ofc = aas_hist.who.
  end.
end.

/* вывод отчета */
def stream vcrpt.
output stream vcrpt to value(v-filename).

{html-title.i 
 &stream = "stream vcrpt"
 &title = "АО ""TEXAKABANK"". Журнал регистрации уведомлений"
 &size-add = "x-"
}

put stream vcrpt unformatted 
   "<P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">"
   "<B>ЖУРНАЛ РЕГИСТРАЦИИ УВЕДОМЛЕНИЙ<BR>" skip
   "о заблокированных суммах на текущих счетах клиентов" skip
   "<BR><BR>с " + string(v-dtb, "99/99/9999") + 
   " по " + string(v-dte, "99/99/9999") + "</B></FONT></P>" skip
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip
   "<TR align=""center"">" skip
     "<TD><FONT size=""2""><B>N</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Наименование организации-клиента банка</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Текущий счет</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Сумма</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Код валюты</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Дата выписки<BR>уведомления</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Блокировавший<BR>офицер</B></FONT></TD>" skip
   "</TR>" skip.

v-num = 0.

for each t-aas :
  find aaa where aaa.aaa = t-aas.aaa no-lock no-error.

  if (v-chcrc = 1 and aaa.crc <> v-local) or (v-chcrc = 2 and aaa.crc = v-local) or
      (v-chcrc = 3) then do:
    v-num = v-num + 1.
    find cif where cif.cif = t-aas.cif no-lock no-error.
    find crc where crc.crc = aaa.crc no-lock no-error.
    put stream vcrpt unformatted
      "<TR valign=""top"">" skip 
        "<TD align=""left"">" + string(v-num) + "</TD>" skip
        "<TD align=""left"">" + trim(trim(cif.prefix) + " " + trim(cif.name)) + "</TD>" skip
        "<TD align=""center"">" + t-aas.aaa + "</TD>" skip
        "<TD align=""right"">" + sum2str(t-aas.sum) + "</TD>" skip
        "<TD align=""center"">" + crc.code + "</TD>" skip
        "<TD align=""center"">" + string(t-aas.dt, "99/99/9999") + "</TD>" skip
        "<TD align=""center"">" + t-aas.ofc + "</TD>" skip
      "</TR>" skip.
  end.
end.

put stream vcrpt unformatted
    "</TABLE>" skip
    "<BR><BR>" skip.

s-vcourbank = comm-txb().
find bankl where bankl.bank = s-vcourbank no-lock no-error.

put stream vcrpt unformatted
  "<P><FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans""><B>" skip
    bankl.name skip.

find sysc where sysc.sysc = "vc-dep" no-lock no-error.
if avail sysc then
  put stream vcrpt unformatted
    "<BR><BR>" + entry(1, sysc.chval) + "<BR>" + entry(2, sysc.chval) skip.

put stream vcrpt unformatted
   "</B></FONT></P>" skip.

{html-end.i}

output stream vcrpt close.

unix silent value("cptwin " + v-filename + " iexplore").

pause 0.

