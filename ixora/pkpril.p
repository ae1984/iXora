/* pkpril.p
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
        28.08.2003 marinav - Замена некоторых пунктов
        28.01.2004 sasco   - Убрал обеспечение для быстрых денег ("6" тип)
        01.02.2004 nadejda - изменен формат вызова pkdefadres для совместимости
        28/04/2007 madiyar - web-анкета
        03/05/2007 madiyar - top_logo_bw.gif -> top_logo_bw.jpg
        06/07/2007 madiyar - ставка по кредитам ИП теперь не делится на 3
        19/01/2010 galina - добавила ИИН
*/

{global.i}
{pk.i}
{pk-sysc.i}

def var v-adres as char extent 2.
def var v-adresdel as char extent 2.
define stream m-out.


find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.ln = s-pkankln no-lock no-error.
if not avail pkanketa then return.

def var v-toplogo as char no-undo.
if pkanketa.id_org = "inet" then v-toplogo = "/images/logo.jpg".
else v-toplogo = "top_logo_bw.jpg".

find first lon where lon.lon = pkanketa.lon no-lock no-error.
find first cif where cif.cif = pkanketa.cif no-lock no-error.
find first crc where crc.crc = lon.crc no-lock no-error.
find bookcod where bookcod.bookcod = "credtype" and bookcod.code = s-credtype no-lock no-error.

find first cmp no-lock no-error.

output stream m-out to pril.html.

put stream m-out unformatted "<!-- Приложение к кредитному досье -->" skip.

{html-title.i &stream = "stream m-out"}

put stream m-out unformatted
       "<table border=""0"" cellpadding=""0"" cellspacing=""3"">" skip
          "<tr><td align=""left""><img src=""" v-toplogo """></td></tr>" skip
          "<tr><td align=""right""><h3>" cmp.name "<br></td></tr>" skip.

put stream m-out unformatted "<tr><td align=""center""><h3>" caps(bookcod.name) format "x(60)" 
                 "</h3><br></td></tr>" skip.

put stream m-out unformatted "<tr align=""center""><td><h1>КРЕДИТНОЕ ДОСЬЕ  N " s-pkankln
                 "<br><br></td></tr>"
                 skip.

       put stream m-out unformatted "<tr style=""font:bold;font-size:small"" align=""left""><td> " caps(trim(cif.name)) format "x(60)" "</td></tr>".
       put stream m-out unformatted "<tr style=""font:bold;font-size:small"" align=""left""><td> " cif.cif "</td></tr>". 
       put stream m-out unformatted "<tr style=""font:bold;font-size:small"" align=""left""><td> Ссудный счет " pkanketa.lon "<br><br><br></td></tr>". 



       put stream m-out unformatted "<tr><td><table border=""1"" cellpadding=""3"" cellspacing=""0"">" skip
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""rigth"">--ИНФОРМАЦИЯ-- </td>"
                  "<td bgcolor=""#C0C0C0"" align=""rigth"">--ПО КРЕДИТУ :</td></tr>" 
                  skip(2).



    put stream m-out unformatted "<tr align=""right"">"
               "<td align=""left""> Сумма кредита</td>"
               "<td align=""left""> " lon.opnamt format ">>>,>>>,>>>,>>9.99" " " crc.code "</td>"
               "</tr>"
               skip.

if s-credtype = '7' then 
    put stream m-out unformatted "<tr align=""right"">"
               "<td align=""left""> Процентная ставка</td>"
               "<td align=""left""> " lon.prem format ">>>,>>>,>>>,>>9.99" "</td>"
               "</tr>"
               skip.
 else  
    put stream m-out unformatted "<tr align=""right"">"
               "<td align=""left""> Процентная ставка</td>"
               "<td align=""left""> " lon.prem format ">>>,>>>,>>>,>>9.99" "</td>"
               "</tr>"
               skip.

    put stream m-out unformatted "<tr align=""right"">"
               "<td align=""left""> Дата выдачи</td>"
               "<td align=""left""> " lon.rdt "</td>"
               "</tr>"
               skip.
    put stream m-out unformatted "<tr align=""right"">"
               "<td align=""left""> Срок погашения</td>"
               "<td align=""left""> " lon.duedt "</td>"
               "</tr>"
               skip.
    put stream m-out unformatted "<tr align=""right"">"
               "<td align=""left""> Кредитное соглашение  </td>"
               "<td align=""left""> " entry(1,pkanketa.rescha[1]) " от " lon.rdt "</td>"
               "</tr>"
               skip.
    put stream m-out unformatted "<tr align=""right"">"
               "<td align=""left""> Цель кредита </td>"
               "<td align=""left""> " get-pksysc-char("pkgoal") " : " pkanketa.goal " </td>"
               "</tr>"
               skip.

   /*
   if s-credtype <> "6" then do:
     put stream m-out unformatted "<tr align=""right"">"
                 "<td align=""left""> Обеспечение</td>"
                 "<td align=""left""> " pkanketa.goal format "x(60)" "</td>"
                 "</tr>"
                 skip.
   end.
   */

   find pksysc where pksysc.credtype = s-credtype and pksysc.sysc = "ratdos" no-lock no-error.
   if not avail pksysc or (avail pksysc and pksysc.loval) then
     put stream m-out unformatted "<tr align=""right"">"
                 "<td align=""left""> Рейтинг</td>"
                 "<td align=""left""> " pkanketa.rating format ">>9" "</td>"
                 "</tr>"
                 skip.


put stream m-out unformatted "</table>" skip.



       put stream m-out unformatted "<br><br><br><br><tr><td><table border=""1"" cellpadding=""3"" cellspacing=""0""
                  style=""border-collapse: collapse"">" skip
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""left"">-----------СВЕДЕНИЯ О ЗАЕМЩИКЕ------------- </td>"
                  "</tr>" 
                  skip(2).


    put stream m-out unformatted "<tr align=""right"">"
               "<td align=""left"">" cif.name format "x(60)" "</td>"
               "</tr>"
               skip.

    
    put stream m-out unformatted "<tr align=""right"">"
               "<td align=""left"">РНН " pkanketa.rnn "</td>"
               "</tr>"
               skip.
    find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "iin" no-lock no-error.
    if avail pkanketh and pkanketh.value1 <> "" then put stream m-out unformatted "<tr align=""right"">"
                                                                                  "<td align=""left"">ИИН " pkanketh.value1 "</td></tr>" skip.                                                                                            
    else put stream m-out unformatted "<tr align=""right""><td align=""left"">ИИН</td></tr>" skip.                                                                                            
                                                                                  

    run pkdefadres (pkanketa.ln, no, output v-adres[1], output v-adres[2], output v-adresdel[1], output v-adresdel[2]).

    put stream m-out unformatted "<tr align=""right"">"
               "<td align=""left"">Прописка : " v-adres[1] format "x(60)" "</td>"
               "</tr>"
               skip.

    put stream m-out unformatted "<tr align=""right"">"
               "<td align=""left"">Факт.проживание : " v-adres[2] format "x(60)" "</td>"
               "</tr>"
               skip.

  find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "tel" no-lock no-error.
  
    put stream m-out unformatted "<tr align=""right""> "
               "<td align=""left"">Телефон дом. : " pkanketh.value1 format "x(20)" "</td>"
               "</tr>"
               skip.

  find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "tel2" no-lock no-error.
  
    put stream m-out unformatted "<tr align=""right""> "
               "<td align=""left"">Телефон раб. : " pkanketh.value1 format "x(20)" "</td>"
               "</tr>"
               skip.

  find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "tel3" no-lock no-error.
  
    put stream m-out unformatted "<tr align=""right""> "
               "<td align=""left"">Телефон сот. : " pkanketh.value1 format "x(20)" "</td>"
               "</tr>"
               skip.

  find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "e-mail" no-lock no-error.
  
    put stream m-out unformatted "<tr align=""right""> "
               "<td align=""left""> E-mail : " pkanketh.value1 format "x(30)" "</td>"
               "</tr>"
               skip.

put stream m-out unformatted "</table></body></html>" skip.

output stream m-out close.

if pkanketa.id_org = "inet" then unix silent value("mv pril.html /var/www/html/docs/" + s-credtype + "/" + string(s-pkankln) + "; chmod 666 /var/www/html/docs/" + s-credtype + "/" + string(s-pkankln) + "/pril.html").
else unix silent cptwin pril.html iexplore.




