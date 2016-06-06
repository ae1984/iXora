/* vcrep7out.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Для Приложения 7 - Отчет о задолжниках по контрактам с ПС, по услугам и фин.займам
 * RUN

 * CALLER
        vcrep1.p
 * SCRIPT

 * INHERIT

 * MENU

 * BASES
         BANK COMM

 * AUTHOR
        16.05.2008 galina
 * CHANGES
        04.04.2011 damir - новые переменные во временной таблице
        28.04.2011 damir - поставлены ключи. процедура chbin.i
        06.12.2011 damir - убрал chbin.i, мелкие корректировки
        */

{vc.i}

{global.i}

def input parameter p-filename  as char.
def input parameter p-printbank as logi.
def input parameter p-bankname  as char.
def input parameter p-printdep  as logi.
def input parameter p-depname   as char.
def input parameter p-printall  as logi.

def shared temp-table t-docs
  field clcif       like cif.cif
  field clname      like cif.name
  field okpo        as char format "999999999999"
  field rnn         as char format "999999999999"
  field clntype     as char
  field address     as char
  field region      as char
  field psnum       as char
  field psdate      as date
  field bankokpo    as char
  field ctexpimp    as char
  field ctnum       as char
  field ctdate      as date
  field ctsum       as char
  field ctncrc      as char
  field partner     like vcpartners.name
  field countryben  as char
  field ctterm      as char
  field dolgsum     as char
  field dolgsum_usd as char
  field cardsend    like vccontrs.cardsend
  field valterm     as integer
  field prefix      as char
  field bnkbin      as char
  field bin         as char
  field iin         as char
  index main is primary clcif ctdate ctsum.

def shared var v-god as integer format "9999".
def shared var v-month as integer format "99".
def var i as integer no-undo.
def var v-monthname as char init
   "январь,февраль,март,апрель,май,июнь,июль,август,сентябрь,октябрь,ноябрь,декабрь".

def stream vcrpt.
output stream vcrpt to value(p-filename).


find first cmp no-lock no-error.

{html-title.i
 &stream = " stream vcrpt "
 &size-add = "xx-"
 &title = "Отчет для Приложения 7 "
}

if p-printall then do:
  put stream vcrpt unformatted
     "<B>" skip
     "<P align = ""right""><FONT size=""1"" face=""Times New Roman Cyr, Verdana, sans""><I>"
       "Отчет для ПРИЛОЖЕНИЕ 7<BR>"
       "к Правилам осуществления экспортно-импортного валютного контроля в РК<BR>"
       "</I></FONT></P>" skip
       "<P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">" skip
       "Отчет о задолжниках по контрактам с ПС, по услугам и фин.займам </FONT></P>"
       "<FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans""><P align = ""left"">" skip
       "Наименование банка: <U>"  cmp.name "</U>" skip.
   /*    "код ОКПО: <U>" substr (cmp.addr[3], 1, 8) "</U>" skip.*/

  if p-printbank then
    put stream vcrpt unformatted
         "<BR>" + p-bankname skip.
  if p-printdep then
    put stream vcrpt unformatted
         ",&nbsp;" + p-depname.

  put stream vcrpt unformatted
       "</P><P align = ""center"">" skip
         "за " + entry(v-month, v-monthname) + " "
          string(v-god, "9999") + " года</P></FONT></B>" skip.
end.
else
  put stream vcrpt unformatted "01." + string(v-month, "99") + "." + string(v-god, "9999") skip.


  put stream vcrpt unformatted
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip
   "<TR align=""center"" valign=""center"" style=""font:bold"">" skip
     "<TD colspan=""2"">Информация по экспортеру/импортеру</TD>" skip
     "<TD colspan=""2"">Реквизиты паспорта сделки</TD>" skip
     "<TD colspan=""5"">Реквизиты контракта</TD>" skip
     "<TD rowspan=""2"">Срок движения<br>капитала</TD>" skip
     "<TD colspan=""2"">Неисполнение нерезидентом  обязательств</TD>" skip.



  put stream vcrpt unformatted
   "</TR>" skip
   "<TR align=""center"" style=""font:bold"">" skip
     "<TD>Наименование</TD>" skip
     "<TD>Код клиента</TD>" skip
     "<TD>№</TD>" skip
     "<TD>Дата</TD>" skip
     "<TD>№</TD>" skip
     "<TD>Дата</TD>" skip
     "<TD>Сумма<BR>в тысячах единиц</TD>" skip
     "<TD>Валюта<BR>контракта</TD>" skip
     "<TD>Ориентировочный срок<br>поступления валюты</TD>" skip
     "<TD>В валюте контракта</TD>" skip
     "<TD>В долларах США</TD>" skip
   "</TR>" skip.



i = 0.

for each t-docs no-lock:
  i = i + 1.

  put stream vcrpt unformatted
    "<TR valign=""top"">" skip
      "<TD>" t-docs.clname "</TD>"  skip
      "<TD>" t-docs.clcif "</TD>" skip
      "<TD>" t-docs.psnum "</TD>"  skip.
      if t-docs.psdate <> ? then do:
        put stream vcrpt unformatted
        "<TD>" string(t-docs.psdate, "99/99/99") "</TD>"  skip.
      end.
      else do:
        put stream vcrpt unformatted
        "<TD>&nbsp;" "</TD>"  skip.
      end.
      put stream vcrpt unformatted
      "<TD>" t-docs.ctnum "</TD>" skip
      "<TD>" string(t-docs.ctdate, "99/99/99") "</TD>"  skip
      "<TD>"replace(t-docs.ctsum,'.',',')"</TD>" skip
      "<TD>" t-docs.ctncrc "</TD>"  skip
      "<TD>" string(t-docs.ctterm, '999.99') "</TD>"  skip
      "<TD>" t-docs.valterm "</TD>"  skip
      "<TD>"replace(t-docs.dolgsum,'.',',')"</TD>" skip
      "<TD>"replace(t-docs.dolgsum_usd,'.',',')"</TD>" skip.

      put stream vcrpt unformatted
    "</TR>" skip.
end.

put stream vcrpt unformatted
  "</TABLE>" skip.

{html-end.i}


output stream vcrpt close.

unix silent value("cptwin " + p-filename + " iexplore").

pause 0.
