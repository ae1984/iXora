/* callcurm.p
 * MODULE
        Call-Center
 * DESCRIPTION
        Предоставление операционистам справочной службы курсов
        валют НацБанка, ТэксакаБанка и курса на Фондовой бирже
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        call.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        
 * AUTHOR
      torbaev
        
 * CHANGES
      16-07-2004  torbaev - Первый набросок (ошибки в курсах покупки-продажи Тэксака)
      19-07-2004  torbaev - исправил эту ошибку в курсах покупки-продажи Тэксака
      20-07-2004  torbaev - исправил ошибку в работе фреймов
      10.08.2004  saltanat - полностью изменила. 
      11.08.2004  saltanat - по просьбе изменила последовательность вывода валют.
*/

def var i as inte.
def var k as inte.
def var j as inte.

def var datk as date extent 5.
def var datn as date extent 5.
def var datt as date extent 5.

def var dk as deci extent 5.
def var dn as deci extent 5.
def var dt as deci extent 10.

def temp-table kasehis
    field cur as char label 'KASE'
    field d1 as deci  label 'Rate' format "zzzz9.99"
    field d2 as deci  label 'Rate' format "zzzz9.99"
    field d3 as deci  label 'Rate' format "zzzz9.99"
    field d4 as deci  label 'Rate'  format "zzzz9.99"
    field d5 as deci  label 'Rate'  format "zzzz9.99".

def temp-table nbhis
    field cur as char label 'NBRK'
    field d1 as deci  label 'Rate'  format "zzzz9.99"
    field d2 as deci  label 'Rate'  format "zzzz9.99"
    field d3 as deci  label 'Rate'  format "zzzz9.99"
    field d4 as deci  label 'Rate'  format "zzzz9.99"
    field d5 as deci  label 'Rate'  format "zzzz9.99".

def temp-table txhis
    field cur as char label 'TEXAKABANK'
    field d1 as deci label 'buy'  format "zzzz9.99"
    field d2 as deci label 'sell' format "zzzz9.99"
    field d3 as deci label 'buy'  format "zzzz9.99"
    field d4 as deci label 'sell' format "zzzz9.99"
    field d5 as deci label 'buy'  format "zzzz9.99"
    field d6 as deci label 'sell' format "zzzz9.99"
    field d7 as deci label 'buy'  format "zzzz9.99"
    field d8 as deci label 'sell' format "zzzz9.99"
    field d9 as deci label 'buy'  format "zzzz9.99"
    field d10 as deci label 'sell' format "zzzz9.99".

def var curname as char extent 3 init ['USD','EUR','RUB'].
def var curnum as integer extent 3 init [2,11,4].

do j = 1 to 3:

/* For KASE */
if j = 1 then do:

    do i = 1 to 5:
    if i = 1 then do:
       find last kasecrchis where kasecrchis.crc = curnum[j].
       dk[i] = kasecrchis.rate[1].
       datk[i] = kasecrchis.regdt.
    end.
    else do:
       k = i - 1.
       find last kasecrchis where kasecrchis.crc = curnum[j] and kasecrchis.regdt < datk[k].
       dk[i] = kasecrchis.rate[1].
       datk[i] = kasecrchis.regdt.
    end.
    end.

    create kasehis.
    assign
         kasehis.cur = curname[j]
         kasehis.d1 = dk[1]
         kasehis.d2 = dk[2]
         kasehis.d3 = dk[3]
         kasehis.d4 = dk[4]
         kasehis.d5 = dk[5].

end.
/* For KASE */

/* For NB */
  do i = 1 to 5:
     if i = 1 then do:
     find last ncrchis where ncrchis.crc = curnum[j].
     dn[i] = ncrchis.rate[1].
     datn[i] = ncrchis.regdt.
     end.
     else do:
     k = i - 1.
     find last ncrchis where ncrchis.crc = curnum[j] and ncrchis.regdt < datn[k].
     dn[i] = ncrchis.rate[1].
     datn[i] = ncrchis.regdt.
     end.
  end.

     create nbhis.
     assign
            nbhis.cur = curname[j]
            nbhis.d1 = dn[1]
            nbhis.d2 = dn[2]
            nbhis.d3 = dn[3]
            nbhis.d4 = dn[4]
            nbhis.d5 = dn[5].

/* For NB*/

/* For TEXAKABANK */
if (j = 1) or (j = 2) then do:

   do i = 1 to 5:
   if i = 1 then do:
   find last crchis where crchis.crc = curnum[j].
   dt[i] = crchis.rate[2].
   datt[i] = crchis.regdt.
   k = i + 1.
   dt[k] = crchis.rate[3].
   end.
   else do:
   k = (i - 1).
   find last crchis where crchis.crc = curnum[j] and crchis.regdt < datt[k].
   datt[i] = crchis.regdt.
   k = i * 2 - 1.
   dt[k] = crchis.rate[2].
   k = k + 1.
   dt[k] = crchis.rate[3].
   end.
   end.

   create txhis.
   assign
        txhis.cur = curname[j]
        txhis.d1 = dt[1]
        txhis.d2 = dt[2]
        txhis.d3 = dt[3]
        txhis.d4 = dt[4]
        txhis.d5 = dt[5]
        txhis.d6 = dt[6]
        txhis.d7 = dt[7]
        txhis.d8 = dt[8]
        txhis.d9 = dt[9]
        txhis.d10 = dt[10].

end.
/* For TEXAKABANK */

end.


/* вывод отчета в HTML */
def stream vcrpt.
output stream vcrpt to allrate.htm.

{html-title.i 
 &stream = " stream vcrpt "
 &title = "Текущие курсы валют"
 &size-add = "xx-"
}

put stream vcrpt unformatted 
   "<P align = ""center""><FONT size=""4"" face=""Times New Roman Cyr, Verdana, sans"">"
   "<B>Текущие курсы валют</B></FONT></P>" skip
   "<TABLE width=""100%"" border=""2"" cellspacing=""0"" cellpadding=""3"" bordercolor=""black"">" skip.


put stream vcrpt unformatted 
   "<TR align=""center"">" skip
     "<TD bgcolor=#ECF1F7><FONT size=""2""><B> Курс KASE </B></FONT></TD>" skip
     "<TD bgcolor=#ECF1F7 colspan = ""2""><FONT size=""2""><B>"string(datk[1])"</B></FONT></TD>" skip
     "<TD bgcolor=#ECF1F7 colspan = ""2""><FONT size=""2""><B>"string(datk[2])"</B></FONT></TD>" skip
     "<TD bgcolor=#ECF1F7 colspan = ""2""><FONT size=""2""><B>"string(datk[3])"</B></FONT></TD>" skip
     "<TD bgcolor=#ECF1F7 colspan = ""2""><FONT size=""2""><B>"string(datk[4])"</B></FONT></TD>" skip
     "<TD bgcolor=#ECF1F7 colspan = ""2""><FONT size=""2""><B>"string(datk[5])"</B></FONT></TD>" skip
   "</TR>" skip.

for each kasehis.
  put stream vcrpt unformatted 
   "<TR align=""center"">" skip
     "<TD><FONT size=""2""><B>" kasehis.cur "</B></FONT></TD>" skip
     "<TD bgcolor=#ECF1F7 colspan = ""2""><FONT size=""2"">"string(kasehis.d1,"zzzz9.99")"</FONT></TD>" skip
     "<TD colspan = ""2""><FONT size=""2"">"string(kasehis.d2,"zzzz9.99")"</FONT></TD>" skip
     "<TD colspan = ""2""><FONT size=""2"">"string(kasehis.d3,"zzzz9.99")"</FONT></TD>" skip
     "<TD colspan = ""2""><FONT size=""2"">"string(kasehis.d4,"zzzz9.99")"</FONT></TD>" skip
     "<TD colspan = ""2""><FONT size=""2"">"string(kasehis.d5,"zzzz9.99")"</FONT></TD>" skip
   "</TR>" skip.
end.

put stream vcrpt unformatted 
   "<TR align=""left"">" skip
     "<TD colspan = ""11""> . </TD>" skip
   "</TR>" skip.

put stream vcrpt unformatted 
   "<TR align=""center"">" skip
     "<TD bgcolor=#ECF1F7><FONT size=""2""><B> Курс НБРК </B></FONT></TD>" skip
     "<TD bgcolor=#ECF1F7 colspan = ""2""><FONT size=""2""><B>"string(datn[1])"</B></FONT></TD>" skip
     "<TD bgcolor=#ECF1F7 colspan = ""2""><FONT size=""2""><B>"string(datn[2])"</B></FONT></TD>" skip
     "<TD bgcolor=#ECF1F7 colspan = ""2""><FONT size=""2""><B>"string(datn[3])"</B></FONT></TD>" skip
     "<TD bgcolor=#ECF1F7 colspan = ""2""><FONT size=""2""><B>"string(datn[4])"</B></FONT></TD>" skip
     "<TD bgcolor=#ECF1F7 colspan = ""2""><FONT size=""2""><B>"string(datn[5])"</B></FONT></TD>" skip
   "</TR>" skip.

for each nbhis.
  put stream vcrpt unformatted 
   "<TR align=""center"">" skip
     "<TD><FONT size=""2""><B>" nbhis.cur "</B></FONT></TD>" skip
     "<TD bgcolor=#ECF1F7 colspan = ""2""><FONT size=""2"">"string(nbhis.d1,"zzzz9.99")"</FONT></TD>" skip
     "<TD colspan = ""2""><FONT size=""2"">"string(nbhis.d2,"zzzz9.99")"</FONT></TD>" skip
     "<TD colspan = ""2""><FONT size=""2"">"string(nbhis.d3,"zzzz9.99")"</FONT></TD>" skip
     "<TD colspan = ""2""><FONT size=""2"">"string(nbhis.d4,"zzzz9.99")"</FONT></TD>" skip
     "<TD colspan = ""2""><FONT size=""2"">"string(nbhis.d5,"zzzz9.99")"</FONT></TD>" skip
   "</TR>" skip.
end.

put stream vcrpt unformatted 
   "<TR align=""left"">" skip
     "<TD colspan = ""11""> . </TD>" skip
   "</TR>" skip.

put stream vcrpt unformatted 
   "<TR align=""center"">" skip
     "<TD bgcolor=#ECF1F7 rowspan = ""2""><FONT size=""2""><B> Курс TEXAKABANK <B></FONT></TD>" skip
     "<TD bgcolor=#ECF1F7 colspan = ""2""><FONT size=""2""><B>"string(datt[1])"</B></FONT></TD>" skip
     "<TD bgcolor=#ECF1F7 colspan = ""2""><FONT size=""2""><B>"string(datt[2])"</B></FONT></TD>" skip
     "<TD bgcolor=#ECF1F7 colspan = ""2""><FONT size=""2""><B>"string(datt[3])"</B></FONT></TD>" skip
     "<TD bgcolor=#ECF1F7 colspan = ""2""><FONT size=""2""><B>"string(datt[4])"</B></FONT></TD>" skip
     "<TD bgcolor=#ECF1F7 colspan = ""2""><FONT size=""2""><B>"string(datt[5])"</B></FONT></TD>" skip
   "</TR>" skip.

put stream vcrpt unformatted 
   "<TR align=""center"">" skip
     "<TD bgcolor=#ECF1F7><FONT size=""2""><B> покупка </B></FONT></TD>" skip
     "<TD bgcolor=#ECF1F7><FONT size=""2""><B> продажа </B></FONT></TD>" skip
     "<TD bgcolor=#ECF1F7><FONT size=""2""><B> покупка </B></FONT></TD>" skip
     "<TD bgcolor=#ECF1F7><FONT size=""2""><B> продажа </B></FONT></TD>" skip
     "<TD bgcolor=#ECF1F7><FONT size=""2""><B> покупка </B></FONT></TD>" skip
     "<TD bgcolor=#ECF1F7><FONT size=""2""><B> продажа </B></FONT></TD>" skip
     "<TD bgcolor=#ECF1F7><FONT size=""2""><B> покупка </B></FONT></TD>" skip
     "<TD bgcolor=#ECF1F7><FONT size=""2""><B> продажа </B></FONT></TD>" skip
     "<TD bgcolor=#ECF1F7><FONT size=""2""><B> покупка </B></FONT></TD>" skip
     "<TD bgcolor=#ECF1F7><FONT size=""2""><B> продажа </B></FONT></TD>" skip
   "</TR>" skip.

for each txhis.
  put stream vcrpt unformatted 
   "<TR align=""center"">" skip
     "<TD><FONT size=""2""><B>" txhis.cur "</B></FONT></TD>" skip
     "<TD bgcolor=#ECF1F7><FONT size=""2"">"string(txhis.d1,"zzzz9.99")"</FONT></TD>" skip
     "<TD bgcolor=#ECF1F7><FONT size=""2"">"string(txhis.d2,"zzzz9.99")"</FONT></TD>" skip
     "<TD><FONT size=""2"">"string(txhis.d3,"zzzz9.99")"</FONT></TD>" skip
     "<TD><FONT size=""2"">"string(txhis.d4,"zzzz9.99")"</FONT></TD>" skip
     "<TD><FONT size=""2"">"string(txhis.d5,"zzzz9.99")"</FONT></TD>" skip
     "<TD><FONT size=""2"">"string(txhis.d6,"zzzz9.99")"</FONT></TD>" skip
     "<TD><FONT size=""2"">"string(txhis.d7,"zzzz9.99")"</FONT></TD>" skip
     "<TD><FONT size=""2"">"string(txhis.d8,"zzzz9.99")"</FONT></TD>" skip
     "<TD><FONT size=""2"">"string(txhis.d9,"zzzz9.99")"</FONT></TD>" skip
     "<TD><FONT size=""2"">"string(txhis.d10,"zzzz9.99")"</FONT></TD>" skip
   "</TR>" skip.
end.

put stream vcrpt unformatted  
"</TABLE>" skip.

{html-end.i "stream vcrpt" }

output stream vcrpt close.

unix silent value("cptwin allrate.htm iexplore").

pause 0.
