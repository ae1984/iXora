/* vcrpt13nout.p
 * MODULE
        Валютный контроль 
 * DESCRIPTION
        Приложение 13 - Отчет о движении средств по валютному контролю
        Вывод временной таблицы в WORD
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        10.4.1.12
 * AUTHOR
        10.02.2006 u00600 создан
 * CHANGES
        06/06/2006 u00600 - добавила поле rmztmp_ncrcK в таблицу rmztmp

*/


{vc.i}

{global.i}

def input parameter p-filename as char.
def input parameter p-printbank as logical.
def input parameter p-bankname as char.
def input parameter p-printdep as logical.
def input parameter p-depname as char.
def input parameter p-printall as logical.

def shared temp-table rmztmp 
    field rmztmp_name   as char     /* отправитель */
    field rmztmp_bn     as char     /* бенефициар */
    field rmztmp_dt     as date format "99/99/9999"      /* дата платежа */
    field rmztmp_ncrc   as char     /* валюта платежа */
    field rmztmp_ncrcK  as integer  /* код валюты платежа */
    field rmztmp_summ   as deci     /* сумма платежа */
    field rmztmp_knp    as char     /* назначение платежа */
    field rmztmp_rnn    as char
    field rmztmp_str    as char
    field rmztmp_pr1    as char      /* примечание */
    field rmztmp_pr2    as char
    field rmztmp_pr3    as char
    field rmztmp_pr4    as char
    field rmztmp_pr5    as char.


def shared var v-god as integer format "9999".
def shared var v-month as integer format "99".
def var v-name as char no-undo.
def var i as integer no-undo.

def var v-monthname as char init 
   "январь,февраль,март,апрель,май,июнь,июль,август,сентябрь,октябрь,ноябрь,декабрь".

def stream vcrpt.
/*output stream vcrpt to vcrpt13n.html.*/
output stream vcrpt to value(p-filename).

find first cmp no-lock no-error.

{html-title.i 
 &stream = " stream vcrpt "   /* заголовок файла */
 &size-add = "xx-"
 &title = " Приложение 13 "
}

if p-printall then do:
put stream vcrpt unformatted
     "<B>" skip
          "<P align = ""right""><FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans""><B>"
       "Приложение 13<BR>"
              "к Правилам осуществления<BR>"
       "валютных операций<BR>"
              "в Республике Казахстан<BR>"
       "</I></FONT><B>" skip
              "<P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">" skip
       "Отчет о движении средств по валютному договору</FONT></P>" skip.

put stream vcrpt unformatted
       "</P><P align = ""center"">" skip
         "за " + entry(v-month, v-monthname) + " "
          string(v-god, "9999") + " года</P></FONT></B>" skip.

put stream vcrpt unformatted
	"<B>" skip
	    "<P  align = ""left""><Font size=""3"" face=""Times New Roman Cyr, Verdana, sans"">"
	    "</FONT></P>" skip 
	    "1.____________________________________________________________________________</FONT></P>"             
	    "       (наименование/фамилия, имя, отчество резидента)</FONT></P>" skip
	    "код ОКПО _________________________________  РНН _____________________________</FONT></P>" skip
	    "2.____________________________________________________________________________</FONT></P>" 
	    "       (наименование/фамилия, имя, отчество нерезидента, страна)</FONT></P>" skip 
	    "3. Номер регистрационного свидетельства/свидетельства об уведомлении Национального Банка________________________________________________________________________</FONT></P>"
	    "дата выдачи _________________________________________</FONT></P>" skip
	    "4. Уполномоченный банк и(или) профессиональный участник рынка ценных бумаг, уведомляющий Национальный Банк " CAPS(cmp.name) "</FONT></P>" skip 
	    /*"_____________________________________________________________________________</FONT></P>"
            "(наименование)</FONT></P>" skip*/
            "Национальный идентификационный номер (НИН) либо международный идентификационный номер (ISIN) ценной бумаги_________________________________________________________</FONT></P>" 
	    "_____________________________________________________________________________ </FONT></P>" skip
	    "5. Движение средств по Валютному договору </FONT></P>" skip.             
end.
else
put stream vcrpt unformatted "01." + string(v-month, "99") + "." + string(v-god, "9999") skip.

if p-printall then do:
put stream vcrpt unformatted "<tr>"
   "<TABLE  width=""100%"" border=""1"" cellspacing=""8"" cellpadding=""0"">" skip
   "<TR align=""center"" valign=""center"" style=""font:boldborder-collapse: collapse""><font size=""3"">" skip

	"<td align=""center"">N п/п</td>"
	"<td align=""center"">Отправитель денег</td>"
	"<td align=""center"">Бенефициар</td>"
	"<td align=""center"">Дата платежа</td>"
	"<td align=""center"">Валюта платежа</td>"
	"<td align=""center"">Сумма платежа, тысяч единиц валюты платежа</td>"
	"<td align=""center"">Назначение платежа</td>"
	"<td align=""center"">Примечание</td>"   

	"</FONT></tr>" skip.
end.
else do:
 put stream vcrpt unformatted "<tr>"
   "<TABLE  width=""100%"" border=""1"" cellspacing=""8"" cellpadding=""0"">" skip
   "<TR align=""center"" valign=""center"" style=""font:boldborder-collapse: collapse""><font size=""3"">" skip

	"<td align=""center"">N п/п</td>"
	"<td align=""center"">Отправитель денег</td>"
	"<td align=""center"">Бенефициар</td>"
	"<td align=""center"">Дата платежа</td>"
	"<td align=""center"">Валюта платежа</td>"
	"<td align=""center"">Сумма платежа, тысяч единиц валюты платежа</td>"
	"<td align=""center"">Назначение платежа</td>"
	"<td align=""center"">Примечание</td>"   

	"</FONT></tr>" skip.  

end.

if p-printall then do:
  i = 0.
for each rmztmp no-lock:
  i = i + 1.                                     
  put stream vcrpt  unformatted "<tr align=""center""><font size=""2"">"
	"<td>" i "</td>"
        "<td>" rmztmp.rmztmp_name "</td>" skip
	"<td>" rmztmp.rmztmp_bn   "</td>" skip
	"<td>" string(rmztmp.rmztmp_dt, "99/99/9999") "</td>" skip
	"<td>" rmztmp.rmztmp_ncrc "</td>" skip
        "<td>" replace(trim(string(rmztmp.rmztmp_summ, "->>>>>>>>>>>>>>>>>>>>9.99")),".",",") "</td>" skip
	/*"<td>" rmztmp.rmztmp_summ "</td>" skip*/
	"<td>" rmztmp.rmztmp_knp  "</td>" skip

        "<td align=""left""> 1) Тип операции: <br> 2) Договор: " rmztmp.rmztmp_pr1 "<br> 3) " 
        rmztmp.rmztmp_rnn "<br> 4) Адрес резидента: " rmztmp.rmztmp_pr2 "<br>" 
        "5) Страна нерезидента: " rmztmp.rmztmp_pr3 "<br> 6) Адрес нерезидента: " rmztmp.rmztmp_str 
        "<br> 7) Банк нерезидента: " rmztmp.rmztmp_pr4 
        "<br>" rmztmp.rmztmp_pr5 "<br></td>" skip
"</tr>" skip.	

end.
end.                          

else do:        /*для АИС "Статистика"*/
  i = 0.
for each rmztmp no-lock:
  i = i + 1.                                     
  put stream vcrpt  unformatted "<tr align=""center""><font size=""2"">"
	"<td>" i "</td>"
        "<td>" rmztmp.rmztmp_name "</td>" skip
	"<td>" rmztmp.rmztmp_bn   "</td>" skip
	"<td>" replace(string(rmztmp.rmztmp_dt, "99/99/99"),"/",".") "</td>" skip
	"<td>" rmztmp.rmztmp_ncrcK "</td>" skip
/*        "<td>" entry(1, trim(string(rmztmp.rmztmp_summ, ">>>>>>>>>>>>>>9.99")), ".") + "," + entry(2, trim(string(rmztmp.rmztmp_summ, ">>>>>>>>>>>>>>9.99")), ".") "</td>" skip*/
        "<td>" replace(trim(string(rmztmp.rmztmp_summ, ">>>>>>>>>>>>>>9.99")),",",".") "</td>" skip
	"<td>" rmztmp.rmztmp_knp  "</td>" skip

       "<td align=""left""> 1) Тип операции: 2) Договор: " rmztmp.rmztmp_pr1 "  3) " 
        rmztmp.rmztmp_rnn "  4) Адрес резидента: " rmztmp.rmztmp_pr2 "  " 
        "5) Страна нерезидента: " rmztmp.rmztmp_pr3 "  6) Адрес нерезидента: " rmztmp.rmztmp_str 
        "  7) Банк нерезидента: " rmztmp.rmztmp_pr4 
        " " rmztmp.rmztmp_pr5 "</td>" skip
"</tr>" skip.

end.    	
end.


put stream vcrpt unformatted  "</FONT></table>" skip.

if p-printall then do:
put stream vcrpt unformatted
	"<B>" skip
	    "<P  align = ""left""><Font size=""3"" face=""Times New Roman Cyr, Verdana, sans"">" 
	    "</FONT></P>" skip
	    "6. Наименование базового актива производного финансового инструмента</FONT></P>"
	    " ______________________________________________________________________________</FONT></P>" skip
 	    "7. Справочно: </FONT></P>" 
	    "     Дата полного исполнения обязательств по валютному договору: </FONT></P>" 
	    "        резидентом ______________________________ </FONT></P>" 
	    "        нерезидентом ____________________________ </FONT></P>" skip.



/*if p-printall then do:*/
  find sysc where sysc.sysc = "mainbk" no-lock no-error.
  if avail sysc then v-name = trim(sysc.chval).
  else do:
    message "Нет сведений о главном бухгалтере!". pause 3.
    v-name = "".
  end.

  find ofc where ofc.ofc = g-ofc no-lock no-error.

  put stream vcrpt unformatted
    "<BR><BR>" skip
    "<P><FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans""><B>" +
       "Главный бухгалтер "  "  _________________________     " + v-name + "<BR><BR><BR>" skip 
       "Исполнитель : " + ofc.name + "<BR>" skip
       "тел.  " + string(ofc.tel[2], "999-999") + "<BR><BR>" skip
       string(g-today, "99/99/9999") + "<BR>" skip
     "</B></FONT></P>" skip.
end.

{html-end.i}

output stream vcrpt close.        

if p-printall then
  unix silent value("cptwin " + p-filename + " winword").
else
  unix silent value("cptwin " + p-filename + " excel").

pause 0.