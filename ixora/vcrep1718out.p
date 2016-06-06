/* vcrep1718out.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Приложение 17 и 18 - все платежи за месяц по контрактам типа 2
        Вывод временной таблицы в Excel
 * RUN

 * CALLER
        vcrep1718.p
 * SCRIPT

 * INHERIT

 * MENU
        15-5-4, 15-4-x-5, 15-4-x-6
 * AUTHOR
        19.11.2002 nadejda
 * BASES
         BANK COMM
 * CHANGES
        18.01.2004 nadejda  - добавлены код региона, адрес и вид платежа в соответствии с новым форматом сообщения МТ-106
        07.06.2004 nadejda  - изменен заголовок - сумма ограничения берется из параметра
        08.04.2008 galina   - добавлено поле cursdoc-usd в таблицу t-docs
        05.04.2011 damir    - добавлены во временной t-docs bin,iin,bnkbin
        28.04.2011 damir    - поставлены ключи. процедура chbin.i
        15.05.2012 damir    - перекомпиляция.
*/


{vc.i}

{global.i}

{chbin.i} /*переход на БИН и ИИН*/

def input parameter p-expimp as char.
def input parameter p-filename as char.
def input parameter p-printbank as logical.
def input parameter p-bankname as char.
def input parameter p-printdep as logical.
def input parameter p-depname as char.
def input parameter p-printall as logical.

def shared temp-table t-docs
    field dndate        as date
    field sum           as deci
    field payret        as logi
    field docs          as inte
    field paykind       as char
    field cif           as char
    field prefix        as char
    field name          as char
    field okpo          as char
    field clnsts        as char
    field region        as char
    field addr          as char
    field ctnum         as char
    field ctdate        as date
    field cttype        as char
    field partnprefix   as char
    field partner       as char
    field codval        as char
    field info          as char
    field strsum        as char
    field bank          as char
    field depart        as char
    field cursdoc-usd   as deci
    field bnkbin        as char
    field bin           as char
    field iin           as char
    index main is primary cttype dndate payret sum docs.

def shared var v-god as integer format "9999".
def shared var v-month as integer format "99".
def var v-name as char.
def var v-stroka as char.
def var v-client as char.
def var v-partner as char.
def var v-numstr as integer.
def var v-kurname as char.
def var v-kurpos as char.
def var v-depname as char.
def var v-deppos as char.
def var v-monthname as char init
   "январь,февраль,март,апрель,май,июнь,июль,август,сентябрь,октябрь,ноябрь,декабрь".

def var v-minpassp as decimal.
find vcparams where vcparams.parcode = "minpassp" no-lock no-error.
if avail vcparams then v-minpassp = vcparams.valdeci. else v-minpassp = 5000.


def stream vcrpt.
output stream vcrpt to value(p-filename).

if p-expimp = "e" then v-stroka = "7". else v-stroka = "8".
put stream vcrpt unformatted
   "<HTML>" skip
   "<HEAD>" skip
   "<TITLE>АО ""TEXAKABANK"". Приложение 1" + v-stroka + " за " +
        entry(v-month, v-monthname) + " " +
        string(v-god, "9999") + " г." skip.

if p-printbank then
  put stream vcrpt unformatted
    ", " + p-bankname skip.
if p-printdep then
  put stream vcrpt unformatted
       ", " + p-depname.


put stream vcrpt unformatted
        "</TITLE>" skip
   "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
   "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
   "<STYLE TYPE=""text/css"" ID=""default""> table "
      "\{font:Times New Roman Cyr, Verdana, sans; font-size:xx-small;
       border-collapse: collapse; valign:top\}</STYLE>" skip
   "</HEAD>" skip
   "<BODY>" skip.

if p-printall then do:
  put stream vcrpt unformatted
     "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">" skip
     "<TR><TD colspan=""9"" width=""60%"">&nbsp;</TD><TD colspan=""6"" width=""40%"" align=""left"">" skip
     "<FONT size=""1"" face=""Times New Roman Cyr, Verdana, sans""><I>"
       "ПРИЛОЖЕНИЕ 1" v-stroka "<BR>" skip
       "к Инструкции об организации экспортно-импортного<BR>" skip
       "валютного контроля в Республике Казахстан<BR>" skip
       "Утверждена постановлением Правления<BR>" skip
       "Национального Банка Республики Казахстан N 343 от 25.09.2001г.<BR>" skip
       "</I></FONT></TD></TR>" skip
     "</TABLE>" skip

     "<B><P align = ""center""><FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans"">" skip
     "Информация<BR>" skip.

  if p-expimp = "e" then v-stroka = "о поступлении выручки".
  else v-stroka = "о проведенных платежах".
  put stream vcrpt unformatted
     v-stroka "<BR>по ".

  if p-expimp = "e" then v-stroka = "экс".
  else v-stroka = "им".
  put stream vcrpt unformatted
     v-stroka "портным сделкам на сумму в эквиваленте до " replace(trim(string(v-minpassp, ">>>,>>>,>>9")), ",", " ") " долларов США<BR>"
     "за " entry(v-month, v-monthname) " "
      string(v-god, "9999") " г.</P></FONT></B>" skip.
end.
else
  put stream vcrpt unformatted "01." string(v-month, "99") "." string(v-god, "9999") skip.

if p-expimp = "e" then do:
  v-client = "Экс". v-partner = "Им". v-stroka = "поступления<BR>выручки".
end.
else do:
  v-client = "Им". v-partner = "Экс". v-stroka = "оплаченного<BR>импорта".
end.

put stream vcrpt unformatted
 "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip
 "<TR align=""center"" valign=""top"">" skip
   "<TD rowspan=""2"">N</TD>" skip
   "<TD colspan=""5""><FONT size=""1""><B>" v-client "портер</B></FONT></TD>" skip
   "<TD rowspan=""2""><FONT size=""1""><B>Контракт</B></FONT></TD>" skip
   "<TD rowspan=""2""><FONT size=""1""><B>Дата<BR>платежа</B></FONT></TD>" skip
   "<TD rowspan=""2""><FONT size=""1""><B>Сумма<BR>" v-stroka "</B></FONT></TD>" skip
   "<TD rowspan=""2""><FONT size=""1""><B>Сумма<BR>возврата<BR>авансового<BR>платежа</B></FONT></TD>" skip
   "<TD rowspan=""2""><FONT size=""1""><B>Вид<BR>платежа</B></FONT></TD>" skip
   "<TD colspan=""2""><FONT size=""1""><B>" v-partner "портер</B></FONT></TD>" skip
   "<TD rowspan=""2""><FONT size=""1""><B>Код<BR>вал.</B></FONT></TD>" skip
   "<TD rowspan=""2""><FONT size=""1""><B>Прим.</B></FONT></TD>" skip
 "</TR>" skip
 "<TR align=""center"" valign=""top"">" skip
   "<TD><FONT size=""1""><B>Организа-<BR>ционно-<BR>правовая<BR>форма</B></FONT></TD>" skip
   "<TD><FONT size=""1""><B>Наименование</B></FONT></TD>" skip
   "<TD><FONT size=""1""><B>Код<BR>ОКПО/РНН</B></FONT></TD>" skip
   "<TD><FONT size=""1""><B>Код<BR>региона</B></FONT></TD>" skip
   "<TD><FONT size=""1""><B>Адрес</B></FONT></TD>" skip
   "<TD><FONT size=""1""><B>Организа-<BR>ционно-<BR>правовая<BR>форма</B></FONT></TD>" skip
   "<TD><FONT size=""1""><B>Наименование</B></FONT></TD>" skip
 "</TR>" skip.

v-numstr = 0.

for each t-docs no-lock:
  v-numstr = v-numstr + 1.
  if t-docs.payret then do:
    v-stroka = "&nbsp;". v-name = t-docs.strsum.
  end.
  else do:
    v-name = "&nbsp;". v-stroka = t-docs.strsum.
  end.
  put stream vcrpt unformatted
    "<TR valign=""top"">" skip
      "<TD>" string(v-numstr) "</TD>" skip
      "<TD>" t-docs.prefix "</TD>" skip
      "<TD>" t-docs.name "</TD>" skip
      "<TD align=""center"">&nbsp;" t-docs.okpo "</TD>" skip
      "<TD align=""center"">&nbsp;" t-docs.region "</TD>" skip
      "<TD>" t-docs.addr "</TD>" skip
      "<TD>" t-docs.ctnum " от " string(t-docs.ctdate, "99/99/99") "</TD>" skip
      "<TD align=""center"">" string(t-docs.dndate, "99/99/99") "</TD>" skip
      "<TD align=""right"">" v-stroka "</TD>" skip
      "<TD align=""right"">" v-name "</TD>" skip
      "<TD align=""right"">" if t-docs.paykind = "1" then "б/нал" else "нал" "</TD>" skip
      "<TD>" t-docs.partnprefix "</TD>" skip
      "<TD>" t-docs.partner "</TD>" skip
      "<TD align=""center"">" t-docs.codval "</TD>" skip
      "<TD>" t-docs.info "</TD>" skip
    "</TR>" skip.
end.

find first cmp no-lock no-error.

put stream vcrpt unformatted
  "</TABLE>" skip
  "<BR><BR>" skip
  "<P><B><FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans"">" skip
     cmp.name skip.

if p-printbank then
  put stream vcrpt unformatted
    "<BR>" p-bankname skip.
if p-printdep then
  put stream vcrpt unformatted
    ",&nbsp;" p-depname.
put stream vcrpt unformatted
  "</B></P>" skip.

find sysc where sysc.sysc = "vc-kur" no-lock no-error.
if avail sysc then do:
  v-kurname = entry(1, trim(sysc.chval)).
  v-kurpos = entry(2, trim(sysc.chval)).
end.
else do:
  message "Нет сведений о кураторе Департамента валютного контроля!". pause 3.
  v-kurpos = "".
  v-kurname = "".
end.

find sysc where sysc.sysc = "vc-dep" no-lock no-error.
if avail sysc then do:
  v-depname = entry(1, trim(sysc.chval)).
  v-deppos = entry(2, trim(sysc.chval)).
end.
else do:
  message "Нет сведений об ответственном лице валютного контроля!". pause 3.
  v-deppos = "".
  v-depname = "".
end.

put stream vcrpt unformatted
  "<P><B><FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans"">" +
     v-kurpos " _________________________ " v-kurname "<BR><BR>" skip
     v-deppos " _________________________ " v-depname "<BR><BR>" skip
   "</B></P>" skip.



put stream vcrpt unformatted
  "</BODY>" skip
  "</HTML>" skip.


output stream vcrpt close.

unix silent cptwin value(p-filename) excel.

pause 0.
