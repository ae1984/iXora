/* pkprtzayav.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Вывод на экран заявления о переводе денег на счет магазина
 * RUN
        
 * CALLER

 * SCRIPT
        
 * INHERIT
        
 * MENU
        
 * AUTHOR
        11.02.2003 nadejda
 * CHANGES
        28.05.2003 nadejda - изменено формирование полного имени - теперь вызывается процедура pkdeffio, 
                             формирует с учетом казахских букв
        28.01.2004 sasco   - обработка партнеров для быстрых денег
        14/12/2004 madiar  - изменения по тексту заявления
        13/06/2005 madiar  - орган выдачи документа - из переменной
*/


{global.i}
{pk.i}
{pkcifnew.i}

/**
{pk.i "new"}
s-pkankln = 3.
**/

if s-pkankln = 0 then return.

find pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and 
     pkanketa.ln = s-pkankln no-lock no-error.

if not avail pkanketa then do:
  message skip " Анкета N" s-pkankln "не найдена !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.

if pkanketa.sts < '40' then do:
  message skip " Не пополнен текущий счет !~n Заявление на снятие денег с текущего счета не может быть сформировано !" skip(1)
    view-as alert-box buttons ok .
  return.
end.

{pk-sysc.i}

/* заявление */
def var v-ofile as char.
def stream v-out.
def var v-bankkomupos as char.
def var v-bankkomufio as char.
def var v-nameshort as char.
def var v-docnum as char.
def var v-docdt as char.
def var v-docvyd as char.
def var v-aaa as char.
def var v-bankname as char.
def var v-sumq as char.
def var v-sumqwrd as char.
def var v-goal as char.
def var v-billnom as char.
def var v-partnername as char.
def var v-datastr as char.
def var v-namefull as char.
def var v-crccode as char.
def var v-credgoal as char.
def var n as integer.
def var v-comsumstr as char.
def var v-comsumwrd as char.
def var v-datastrkz as char no-undo.

def var v-bspr as char.

v-ofile = "zayav.htm".

{sysc.i}
find bookcod where bookcod.bookcod = "credtype" and bookcod.code = s-credtype no-lock no-error.
v-bankkomupos = entry(1, get-sysc-cha (bookcod.info[1] + "komu")) + " " + v-bankname.
v-bankkomufio = entry(2, get-sysc-cha (bookcod.info[1] + "komu")).
v-docnum = pkanketa.docnum.
v-aaa = pkanketa.aaa.
v-goal = pkanketa.goal.
v-billnom = pkanketa.billnom.

run pkdefsfio (pkanketa.ln, output v-nameshort).

find pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "dtpas" no-lock no-error.
if avail pkanketh then v-docdt = string(pkanketh.value1, "99/99/9999").

find first cmp no-lock no-error.
if avail cmp then v-bankname = cmp.name.

v-sumq = replace(string(pkanketa.sumout, ">>>,>>>,>>9.99"), ",", " ").
run Sm-vrd(pkanketa.sumout, output v-sumqwrd).

v-docvyd = "МВД РК".
find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and
     pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "pkdvyd" no-lock no-error.
if avail pkanketh and trim(pkanketh.value1) <> '' then do:
  find first pkkrit where pkkrit.kritcod = pkanketh.kritcod no-lock no-error.
  if avail pkkrit then do:
    if num-entries(pkkrit.kritspr) > 1 then v-bspr = entry(integer(s-credtype),pkkrit.kritspr).
    else v-bspr = pkkrit.kritspr.
    find first bookcod where bookcod.bookcod = v-bspr and bookcod.code = pkanketh.value1 no-lock no-error.
    if avail bookcod then v-docvyd = trim(bookcod.name).
  end.
end.


find codfr where codfr.codfr = "pkpartn" and codfr.code = pkanketa.partner no-lock no-error.
if avail codfr then v-partnername = codfr.name[1].

v-credgoal = get-pksysc-char("pkgoal").
/*find crc where crc.crc = pkanketa.crc no-lock no-error. валюта всегда ТЕНГЕ 
v-crccode = crc.code.*/
v-crccode = "тенге".

run pkdefdtstr (pkanketa.docdt, output v-datastr, output v-datastrkz).

if pkanketa.sumcom > 0 then do:
  v-comsumstr = replace(string(pkanketa.sumcom, ">>>,>>>,>>9.99"), ",", " ").
  run Sm-vrd(pkanketa.sumcom, output v-comsumwrd).
end.

output stream v-out to value(v-ofile).
{html-title.i 
 &stream = " stream v-out "
 &title = " "
 &size-add = " "
}              

put stream v-out unformatted 
"<TABLE width=""98%"" border=""0"" cellspacing=""0"" cellpadding=""1"" align=""center"">" skip
"<TR><TD>" skip 
  "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">" skip
    "<TR align=""left""><TD width=""60%"">&nbsp;</TD><TD>" skip
      v-bankkomupos + "<BR>" + v-bankname + "<BR>" + v-bankkomufio skip
      "<BR> от <U><I>" skip
      v-nameshort skip
      "</I></U><BR>" skip 
    "удостоверение N <U><I>" skip
      v-docnum skip
      "</I></U><BR>" skip 
    "выдано <U><I>" skip
      v-docdt skip
      " " v-docvyd "</I></U></TD></TR>" skip
  "</TABLE>" skip.

put stream v-out unformatted 
  "<P>&nbsp;</P>" skip
  "<P align=""center""><B>ЗАЯВЛЕНИЕ</B></P>" skip

  "<P align=""justify"">" skip
"Прошу перечислить с моего текущего счета N <U><I>" skip
v-aaa skip 
"</I></U>, открытого в " skip
v-bankname skip
" (далее Банк), " skip.

/* sasco - обработка цели и партнера */
if s-credtype <> "6" or v-partnername <> "" then do:
      put stream v-out unformatted
          "сумму в размере <U><I><NOBR>" skip
          v-sumq skip
          "</NOBR></I></U> (<U><I>" skip
          v-sumqwrd skip
          "</I></U>)&nbsp;" v-crccode " на приобретение товара согласно счету-фактуры в пользу магазина <U><I>"
          v-partnername skip
          "</I></U>" skip.
      
      if pkanketa.sumcom > 0 then 
          put stream v-out unformatted
              ", а также сумму комиссии в размере <U><I><NOBR>"
              v-comsumstr skip
              "</NOBR></I></U> (<U><I>" skip
              v-comsumwrd skip
              "</I></U>)&nbsp;" v-crccode " согласно действующим тарифам Банка в пользу Банка." skip.
      else put stream v-out unformatted ".".
end.
else do:
      if pkanketa.sumcom > 0 then 
           put stream v-out unformatted
               "сумму комиссии в размере <U><I><NOBR>"
               v-comsumstr skip
               "</NOBR></I></U> (<U><I>" skip
               v-comsumwrd skip
               "</I></U>)&nbsp;" v-crccode " согласно действующим тарифам Банка в пользу Банка.".
end.

put stream v-out unformatted
  ".</P>" skip
  "<P>&nbsp;</P>" skip.

put stream v-out unformatted 
  "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"" align=""right"">" skip
    "<TR align=""left""><TD width=""60%"">&nbsp;</TD>" skip
      "<TD><U><I>" skip
      v-datastr skip
      "</I></U> г.</TD></TR>" skip
    "<TR><TD colspan=""2"">&nbsp;</TD></TR>" skip
    "<TR><TD>&nbsp;</TD><TD align=""left"">подпись <U>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" skip
      "</U></TD></TR>" skip
  "</TABLE>" skip.


put stream v-out unformatted 
"</TD></TR>"
"</TABLE>" skip.

{html-end.i "stream v-out" }

output stream v-out close.
unix silent value("cptwin " + v-ofile + " winword").

