/* minnine.p
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
        26/08/05 ten
 * CHANGES
        30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
*/

def var stime as date label "В период с".
def new shared var endtime as date label "по".

def new shared var v-vvv as dec. 
def var v-in as int.

def var fff as dec.

def var v-day as date.

def var i as int.
def var v-date as date.
def new shared var v-date1 as date.
def var v-date2 as date.
def var v-nuch as int.
def var v-kon as int.
def var v-date3 as date.
def new shared var vdt as date.
def new shared var vdt1 as date.
def new shared var out1 as dec.
def new shared var pr as dec.
def new shared var v-out1 as dec.
def new shared var pr1 as dec.
def new shared var pr2 as dec.
def new shared var inp as dec.
def new shared var inp1 as dec.
def new shared var inp2 as dec.
def new shared var a1 as dec.

def var c as char.
def var d as char.

def var v-gl as char.
def var b as int.


def var tday as char extent 10 initial [
                                         "(пятница)", "(понедельник)", "(вторник)" , "(среда)", "(четверг)", "(пятница)" ].

def new shared temp-table temp
    field dday as char
    field ddate as date
    field out as dec
    field summ as dec
    field raz as dec
    field adate as char
    field oui as dec
    field outi as dec
    field prim as dec
    field teng as decimal
    field nrt as dec
    field nra as dec
    field gold as decimal
    field aweek as char
    field obz as dec
    field forf as dec
    field dumpi as dec
    field dumpd as dec
    field dumpdi as dec
    field vali as dec
    field vald as dec
    field valdi as dec
    field tr as dec
    field fr as dec
    field fv as dec
    field nn as dec
    field el as dec
    field tn as dec
    field week as int.


/*run comm-con.   */

update stime label 'Введите отчетную дату c'  with row 8 centered side-label frame pot.
update endtime label 'по ' with frame pot.



if endtime > today then do:
   hide frame pot.
   message " Дата не может быть больше текущей даты! ".
   leave.
end.
   hide frame pot.
   display '  Ждите...  ' with row 5 frame www centered.

/* первый вторник */
if weekday(stime) > 3 then do:
   v-nuch =  7 - weekday(stime).
   stime = stime + v-nuch + 3.
   v-date1 = stime.
   v-date2 = v-date1 + 15.
end.

else do:
     if weekday(stime) < 3 then do:
        v-nuch = 7 - weekday(stime) - 4.
        stime = stime + v-nuch.
        v-date1 = stime.
        v-date2 = v-date1 + 15.
     end.

else do:
     if weekday(stime) = 3 then do:
        v-date1 = stime.
        v-date2 = v-date1 + 15.
     end.
end.
end.

/* последний понедельник */
if weekday(endtime) <> 2 then do:
   v-nuch = 7 - weekday(endtime).
   v-kon = 7 - v-nuch.
   /*endtime = endtime - v-kon + 2.*/
   v-date = endtime.
end. else 
     v-date = endtime.

if v-date2 <=endtime then
endtime = v-date2.




do v-day = v-date1 to endtime:
  i= weekday(v-day).
     v-in = v-in + 1.
  if v-in < 15 then do:
     create temp.
            temp.dday = tday[i].
            temp.aweek = tday[i].
            temp.ddate = v-day.
            temp.week = weekday(v-day).
  end. 
else do:
     create temp.
            temp.ddate = v-day.
            temp.aweek = tday[i].
            temp.week = weekday(v-day).
end.
end.
          

           
     find first temp where temp.week = 5 no-lock no-error.
     if avail temp then do:
              v-date3 = temp.ddate.
        for each temp where temp.ddate >= v-date3 and temp.adate = " " no-lock.
              temp.adate = temp.aweek.

        end.
     end.

for each temp where (temp.week = 7 or temp.week = 1) no-lock.
delete temp.
end.



vdt = v-date1 + 1.
vdt1 = endtime - 1.

if not connected ("comm") then run comm-con.

for each txb where txb.consolid = true no-lock:
    if connected ("ast") then disconnect "ast".
    connect value(" -db " + txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld ast -U " + txb.login + " -P " + txb.password). 
    run minnine1 (v-date1, endtime).
end.
if connected ("ast")  then disconnect "ast".
/*
find last bank.nine where bank.nine.znach <> 0 no-lock no-error.
     if avail bank.nine then  a1 = bank.nine.znach.

for each  temp where (temp.ddate = endtime or temp.ddate = vdt1) no-lock. 
          temp.obz = 0.
end.
*/
     

i = 0. 
fff = 0.  

for each temp where temp.ddate >= v-date1 and temp.ddate <= endtime   no-lock.
/*if temp.obz <> 0 then do:*/
      run nine.p (temp.ddate, output pr).
          inp = pr.

      temp.obz = /*temp.obz +*/ (inp * 100).
/*end.*/
      run over.p (temp.ddate, output v-out1).
          out1 = v-out1.

          temp.out = temp.out + out1.
   /*   run gold.p (temp.ddate, output pr1).
          inp1 = pr1.
      run tenge.p (temp.ddate, output pr2).
          inp2 = pr2.
      temp.gold = inp1.
      temp.teng = inp2.
      temp.nra = temp.out + temp.gold + (inp2 * 1000).
      i = i + 1.     
      fff = fff + temp.obz.
      temp.forf = (fff / i) * a1.
      temp.raz = temp.nra - (fff / i) * a1.
      temp.nrt = temp.obz * a1.       */
    
end.

for each temp where (temp.ddate = v-date1 or temp.ddate = vdt) no-lock.
         temp.gold = 0. 
         temp.nra = 0. 
         temp.out = 0. 
         temp.oui = 0. 
         temp.teng = 0.
end.

for each temp where temp.ddate >= v-date1 and temp.ddate <= endtime no-lock.
    find bank.hol where bank.hol.hol = temp.ddate no-lock no-error.
      if avail bank.hol then do:
         temp.obz = 0.
         temp.out = 0.
         temp.oui = 0.
         temp.teng = 0.
         temp.gold = 0.
         temp.nra = 0.
         temp.out = 0.
      end.
end.
/*
for each temp where temp.obz <> 0 no-lock. 

    ACCUMULATE temp.obz  (average).
    temp.prim = accumulate average (temp.obz). 
    temp.prim  = temp.prim * a1.
end.

for each temp where temp.nra <> 0 no-lock. 
    ACCUMULATE temp.nra (average).
    v-vvv  =  ACCUMulate average  (temp.nra).
end.
*/

hide frame www.


output  to txt1.htm.

put unformatted  "<html xmlns:o=""urn:schemas-microsoft-com:office:office"" xmlns:x=""urn:schemas-microsoft-com:office:excel"">"   skip
                 "<head><title>TEXAKABANK</title>" skip
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru"">"  skip
                 "<xml>" skip
                 "<x:ExcelWorkbook>" skip
                 "<x:ExcelWorksheets>" skip
                 "<x:ExcelWorksheet>" skip
                 "<x:Name>xxx</x:Name>" skip
                 "<x:WorksheetOptions>" skip
                 "<x:Selected/>" skip
                 "<x:Panes>" skip
                 "<x:Pane>" skip
                 "<x:Number>3</x:Number>" skip
                 "<x:ActiveRow>29</x:ActiveRow>" skip
                 "<x:ActiveCol>4</x:ActiveCol>" skip
                 "</x:Pane>" skip
                 "</x:Panes>" skip
                 "<x:ProtectContents>False</x:ProtectContents>" skip
                 "<x:ProtectObjects>False</x:ProtectObjects>" skip
                 "<x:ProtectScenarios>False</x:ProtectScenarios>" skip
                 "</x:WorksheetOptions>" skip
                 "</x:ExcelWorksheet>" skip
                 "</x:ExcelWorksheets>" skip
                 "</x:ExcelWorkbook>" skip
                 "</xml>" skip
                        " </head><body>" skip.
put unformatted 
   "<table valign=""top""  width=""100%"">"   skip
   "<td colspan = ""6""> </td>"   skip
   "    <td colspan = ""3"" align = ""left"" valign= ""top""> Приложение N 1 <br>"   skip
   "к правилам о минимальных резервных требованиях,<br> утвержденных постановлением Правления <br>Национального Банка Республики Казахстан"
   "<br> от ""03"" августа N 300 <br>""Об утверждении Правил о минимальных<br> резервных требований"" </td></tr> " skip
   "</table>"    skip
   "<B><P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr"">" skip
   "<b> АО ""TEXAKABANK"" </b> <br>"    skip
   " Отчет о выполнении минимальных резервных требований </FONT>" skip
   "<TABLE width=""100%"" border=""1"" cellspacing=""1"" cellpadding=""3"">" skip.
put unformatted        	
     "<TD  rowspan=3 bgcolor=""#95B2D1"" valign = ""top""><B>Дата</B></FONT></TD>" skip
     "<TD  rowspan=3 bgcolor=""#95B2D1""><B>Период <br>определения <br>минимальных <br>резервных <br>требований</B></FONT></TD>" skip
     "<TD  rowspan=3 bgcolor=""#95B2D1"" valign = ""top""><B>Обязательства</B></FONT></TD>" skip
     "<TD  rowspan=3 bgcolor=""#95B2D1""><B>Период <br>формирования <br>резервных <br>активов</B></FONT></TD>" skip

     "<td  colspan=5 rowspan =1 bgcolor=""#95B2D1"" align = ""center"" valign = ""top""><B>Резервные активы</B></FONT></td>" skip
     "<tr><th colspan=2 bgcolor=""#95B2D1""><b>  остатки денег на<b><br> корреспнонденсих<br> счетах, депозитах <br>в Национальном Банке, кредиты <br>овернайт (на одну ночь) <br>Национальному Банку</B></FONT></td>" skip
     "<td rowspan=2 bgcolor=""#95B2D1""> наличные<br> тенге </FONT></td>" skip
     "<td rowspan=2 bgcolor=""#95B2D1""> афинированое <br>золото</FONT></td>" skip 
     "<td rowspan=2 bgcolor=""#95B2D1""> итого <br>резервные <br>активы</FONT></td></tr>" skip 
     "<td size=1 bgcolor=""#95B2D1""> в тенге </FONT></td>" skip
     "<td bgcolor=""#95B2D1""> в ин.валюте </FONT></td>" skip.
    
i=0.
b=0.

for each temp   no-lock.
if string(temp.ddate) <> " " then 
   i = i + 1.
   c = string(i).
if i >= 11 then  c = " " .
if string(temp.adate) <> " " then                     
   b = b + 1.
   d = string(b).
if b <= 0 then d = " ".
SESSION:DATE-FORMAT = "mdy".
put unformatted           "<tr><td>"  temp.ddate "</td>" skip
                          "<td><b>" c " " + temp.dday "</b></td>" skip
                          "<td align = ""center"">" (temp.obz / 10000) * 100 format "->>>,>>>,>>>,>>>,>>>"  "</td>" skip
                          "<td><b>" d " " + temp.adate "</b></td>" skip
                          "<td align = ""center"">" (temp.out / 1000) * 1 format "->>>,>>>,>>>,>>>,>>>" "</td>" skip
                          "<td align = ""center"">" (round((temp.oui / 100),00) * 100) format "->>>,>>>,>>>,99" "</td>" skip
                          "<td align = ""center"">" /*(round((temp.teng ),00) * 100) format "->>>,>>>,>>>,99"*/ 0 "</td>"skip
                          "<td align = ""center"">" (round((temp.gold / 1000),00) * 100) format "->>>,>>>,>>>,99" "</td>" skip
                          "<td align = ""center"">" /*(round((temp.nra / 1000),00) * 100) format "->>>,>>>,>>>,99"*/ 0  "</td>" skip.
                      
                          
end. 
put unformatted "</TABLE>" skip.

/*unix silent cptwin txt1.htm excel. */
unix silent value("cat txt1.htm | /pragma/bin9/koi2win > txt2.htm;rm txt1.htm").
unix silent rcp .//txt2.htm `askhost`:c://pragma.htm.

SESSION:DATE-FORMAT = "dmy".

