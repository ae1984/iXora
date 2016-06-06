/* pkkksogl.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Печать листа согласования для Быстрых денег 
 * RUN
        
 * CALLER
        pkafterank-6.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        4.13.1
 * AUTHOR
        21.10.2003 nadejda
 * CHANGES
        24/12/2004 madiyar - добавил вывод примечаний менеджера к анкете
        27/12/2004 madiyar - косметические изменения
        04/02/2005 madiyar - Члены КК - имена в codfr.name[2]
        05/06/2006 madiyar - логотип с локального компа
        27/04/2007 madiyar - web-анкета
        10/07/07 marinav - для не Алматы ставим менеджера, принявшего анкету
        19.07.09 marinav - состав кредитного комитета
*/


{global.i }
{pk.i}
{pk-sysc.i}

/*
s-credtype = "6".
s-pkankln = 41501.
*/

def var v-datastrkz as char no-undo.

if s-pkankln = 0 then return.

find pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and 
     pkanketa.ln = s-pkankln no-lock no-error.

if not avail pkanketa then do:
  message skip " Анкета N" s-pkankln "не найдена !" skip(1) view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.

def var v-toplogo as char no-undo.
if pkanketa.id_org = "inet" then v-toplogo = "c:\\tmp\\top_logo_bw.jpg".
else v-toplogo = "top_logo_bw.jpg".

def var v-repfile as char init "repkksogl.htm".
def var v-datastr as char.
def var v-ofc as char.

def var v-name as char.
def var v-docnom as char.
def var v-docvyd as char.
def var v-docdt as date.
def var v-rnn as char.

def var v-crccod as char.
def var v-sumq0 as decimal.
def var v-sumq as decimal.
def var v-srok0 as integer.
def var v-srok as integer.

def var v-dohod as decimal.
def var v-rating as integer.
def var v-limit as decimal.
def var v-credname as char.
def var v-comment as char.

def temp-table t-kk
  field ln as integer
  field position as char
  field name as char
  index ln is primary unique ln.

/* подготовка данных для вывода */

/* ФИО заемщика */
v-name = pkanketa.name.

/* документ */
find pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and 
     pkanketh.kritcod = "numpas" no-lock no-error.
v-docnom = trim (pkanketh.value1).

find pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and 
     pkanketh.kritcod = "pkdvyd" no-lock no-error.
     find first bookcod where bookcod.bookcod = 'pkankvyd' and bookcod.code = trim(pkanketh.value1).
     v-docvyd = bookcod.name.

find pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and 
     pkanketh.kritcod = "dtpas" no-lock no-error.
v-docdt = date (pkanketh.value1).

/* РНН */
find pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and 
     pkanketh.kritcod = "rnn" no-lock no-error.
v-rnn = trim (pkanketh.value1).

v-rating = pkanketa.rating.
v-limit = pkanketa.summax.

find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype 
           and  pkanketh.ln = s-pkankln and pkanketh.kritcod = "gcvpsum" no-error.
if avail pkanketh and pkanketh.value1 <> "" then v-dohod = decimal (pkanketh.value1).

/* сведения о запрашиваемом кредите */
find pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and 
     pkanketh.kritcod = "cred-sumq" no-lock no-error.
if avail pkanketh then v-sumq0 = decimal (pkanketh.value1).
                  else v-sumq0 = pkanketa.sumq.

find pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and 
     pkanketh.kritcod = "cred-srok" no-lock no-error.
if avail pkanketh then v-srok0 = integer (pkanketh.value1).
                  else v-srok0 = if pkanketa.sumq > 0 then pkanketa.srok else 0.

/* одобренные условия */
if pkanketa.sumq > 0 then do:
  v-sumq = pkanketa.sumq.
  v-srok = pkanketa.srok.
end.

find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype 
           and pkanketh.ln = s-pkankln and pkanketh.kritcod = "commentary" no-lock no-error.
if avail pkanketh and pkanketh.value1 <> "" then v-comment = trim(pkanketh.value1).

find crc where crc.crc = pkanketa.crc no-lock no-error.
v-crccod = crc.code.

/* оформление */
run pkdefdtstr (today, output v-datastr, output v-datastrkz).

/* наименование кредита */
find bookcod where bookcod.bookcod = "credtype" and bookcod.code = pkanketa.credtype no-lock no-error.
v-credname = replace (caps (bookcod.name), "'", """").

/* Кредитный Комитет для Быстрых Кредитов/Денег */
/********************************8
for each codfr where codfr.codfr = "pkkkbdbk" no-lock:
  create t-kk.
  assign t-kk.ln = integer (codfr.code)
         t-kk.position = trim (codfr.name[1])
         t-kk.name = trim (codfr.name[2]).
end.


if pkanketa.bank = 'TXB05' then do: 
    find last t-kk no-error.
    if not avail t-kk then do:
      create t-kk.
      assign t-kk.ln = 1
             t-kk.position = "Менеджер, оформивший заявку".
    end.
    find ofc where ofc.ofc = pkanketa.rwho no-lock no-error.
    t-kk.name = ofc.name.
end.
**************************************/

  create t-kk.
  assign t-kk.ln = 1
         t-kk.position = 'Председатель Кредитного комитета'
         t-kk.name = 'Ташенова Е.А.'.
  create t-kk.
  assign t-kk.ln = 2
         t-kk.position = 'Зам. Председателя Кредитного комитета'
         t-kk.name = 'Котуков В.А.'.
  create t-kk.
  assign t-kk.ln = 3
         t-kk.position = 'Член Кредитного комитета'
         t-kk.name = 'Карева Ю.А.'.
  create t-kk.
  assign t-kk.ln = 4
         t-kk.position = 'Член Кредитного комитета'
         t-kk.name = 'Успангалиев А.С.'.
  create t-kk.
  assign t-kk.ln = 5
         t-kk.position = 'Член Кредитного комитета'
         t-kk.name = 'Рахимов С.С.'.




output to value(v-repfile).

put unformatted "<!-- мЙУФ УПЗМБУПЧБОЙС -->" skip.


{html-title.i 
 &stream = " "
 &title = "Лист согласования"
 &size-add = "x-"
}

put unformatted 
  "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"" align=""center"">" skip
  "<TR><TD align=""left""><img src=""" + v-toplogo + """></TD></TR>" skip
  "<TR><TD height=""50"">&nbsp;</TD></TR>" skip
  "<TR><TD align=""center""><FONT size=""+2""><B>ЛИСТ СОГЛАСОВАНИЯ<BR>по программе " v-credname "</B></FONT></TD></TR>" skip
  "<TR><TD height=""50"">&nbsp;</TD></TR>" skip
  "<TR><TD>" skip
    "<TABLE width=""90%"" border=""0"" cellspacing=""0"" cellpadding=""0"" align=""center"">" skip
      "<TR><TD align=""right""><U>" v-datastr "г.</U></TD></TR>" skip
    "</TABLE>" skip
  "</TD></TR>" skip.

put unformatted 
  "<TR><TD height=""20"">&nbsp;</TD></TR>" skip
  "<TR><TD>" skip
    "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""5"" align=""center"">" skip
      "<TR valign=""top"" style=""font:bold"">" skip
        "<TD width=""30%""><U>Заемщик:<B></TD>" skip
        "<TD>" v-name "</TD>" skip
      "</TR>" skip
      "<TR valign=""top"">" skip
        "<TD>Уд.личности:</TD>" skip
        "<TD>N&nbsp;" v-docnom ", выдано " v-docvyd "  " string (v-docdt, "99/99/9999") "г.</TD>" skip
      "</TR>" skip
      "<TR valign=""top"">" skip
        "<TD>РНН:</TD>" skip
        "<TD>" v-rnn "</TD>" skip
      "</TR>" skip
      "<TR valign=""top"">" skip
        "<TD>Анкета N:</TD>" skip
        "<TD>" s-pkankln "</TD>" skip
      "</TR>" skip
      "<TR>" skip
        "<TD colspan=""2"">&nbsp;</TD>" skip
      "</TR>" skip
      "<TR valign=""top"">" skip
        "<TD>Заработная плата:</TD>" skip
        "<TD>" replace (string (v-dohod, ">>>,>>>,>>>,>>>,>>9.99"), ",", " ") "</TD>" skip
      "</TR>" skip
      "<TR valign=""top"">" skip
        "<TD>Рейтинг:</TD>" skip
        "<TD>" v-rating "</TD>" skip
      "</TR>" skip
      "<TR valign=""top"">" skip
        "<TD>Лимит:</TD>" skip
        "<TD>" replace (string (v-limit, ">>>,>>>,>>>,>>>,>>9.99"), ",", " ") "</TD>" skip
      "</TR>" skip
      "<TR>" skip
        "<TD colspan=""2"">&nbsp;</TD>" skip
      "</TR>" skip.

put unformatted 
      "<TR valign=""top"" style=""font:bold"">" skip
        "<TD colspan=""2""><U>Запрашиваемые условия :</U></TD>" skip
      "</TR>" skip
      "<TR valign=""top"">" skip
        "<TD>Сумма кредита:</TD>" skip
        "<TD>" if v-sumq0 > 0 then replace (string (v-sumq0, ">>>,>>>,>>>,>>>,>>9.99"), ",", " ") + "&nbsp;" + v-crccod else "&nbsp;" "</TD>" skip
      "</TR>" skip
      "<TR valign=""top"">" skip
        "<TD>Срок кредита:</TD>" skip
        "<TD>" if v-sumq0 > 0 then string(v-srok0) + "&nbsp;мес." else "&nbsp;" "</TD>" skip
      "</TR>" skip
      "<TR>" skip
        "<TD colspan=""2"">&nbsp;</TD>" skip
      "</TR>" skip
      "<TR valign=""top"" style=""font:bold"">" skip
        "<TD colspan=""2""><U>Одобренные условия :</U></TD>" skip
      "</TR>" skip
      "<TR valign=""top"">" skip
        "<TD>Сумма кредита:</TD>" skip
        "<TD>" if v-sumq > 0 then replace (string (v-sumq, ">>>,>>>,>>>,>>>,>>9.99"), ",", " ") + "&nbsp;" + v-crccod else "&nbsp;" "</TD>" skip
      "</TR>" skip
      "<TR valign=""top"">" skip
        "<TD>Срок кредита:</TD>" skip
        "<TD>" if v-sumq > 0 then string(v-srok) + "&nbsp;мес." else "&nbsp;" "</TD>" skip
      "</TR>" skip
      "<TR valign=""top"">" skip
        "<TD>Примечание:</TD>" skip
        "<TD>" if v-comment <> '' then v-comment else "&nbsp;" "</TD>" skip
      "</TR>" skip
    "</TABLE>" skip
  "</TD></TR>" skip.

put unformatted 
  "<TR><TD height=""20"">&nbsp;</TD></TR>" skip
  "<TR><TD>" skip
    "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"" align=""center"">" skip
      "<TR align=""center"" style=""font:bold"">" skip
        "<TD>Должность</TD>" skip
        "<TD width=""20%"">ФИО</TD>" skip
        "<TD width=""13%"">Дата</TD>" skip
        "<TD width=""13%"">Одобрено</TD>" skip
        "<TD width=""13%"">Отклонено</TD>" skip
      "</TR>" skip.

for each t-kk:
  put unformatted 
      "<TR>" skip
        "<TD>" t-kk.position "</TD>" skip
        "<TD>" if t-kk.name = "" then "&nbsp;" else t-kk.name "</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip                
      "</TR>" skip.

end.

put unformatted 
    "</TABLE>" skip
  "</TD></TR>" skip
  "</TABLE>" skip.

{html-end.i " " }

output close.

if pkanketa.id_org = "inet" then do:
   unix silent un-win value(v-repfile) repkksogl.doc.
   unix silent value("mv repkksogl.doc /var/www/html/docs/" + s-credtype + "/" + string(s-pkankln) + "; chmod 666 /var/www/html/docs/" + s-credtype + "/" + string(s-pkankln) + "/repkksogl.doc" ).
end.
else unix silent cptwin value (v-repfile) winword. 

pause 0.

