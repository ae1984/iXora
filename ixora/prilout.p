/* prildat.p
 * MODULE
        Отчет по распределению платежного оборота  
 * DESCRIPTION
        Отчет по распределению платежного оборота  
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        pril2.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        8-12-9-12 
 * AUTHOR
        15.04.05 nataly
 * CHANGES
        20.05.05 nataly поменяла наименования областей для удобства закачки в ORACLE
                        добавила деление на 1000
        10/08/06 nataly добавила новые филиалы 
        14.02.08 marina - заменила названия филиалов
*/

{vc.i}
{global.i}

def shared temp-table  temp2
   field acc as char format 'x(9)'
   field jh  as integer
   field crc as integer
   field bank as char format 'x(3)'
   field bal  as decimal
   field jdt as date
   field col1  as integer
   field priz as char.

def temp-table  temp3
   field bank as char format 'x(3)'
   field name as char format 'x(10)'
   field bal  as decimal  extent 13
   field col1  as integer extent 13
   field priz as char.

def input parameter p-filename as char.
def input parameter p-printbank as logical.
def input parameter p-bankname as char.
def input parameter p-printdep as logical.
def input parameter p-depname as char.
def input parameter p-printall as logical.

def shared var v-god as integer format "9999".
def shared var v-month as integer format "99".
def var sum1v as integer.
def var sum2v as decimal.
def var i as integer.
def var j as integer.
def var totcol as integer extent 13.
def var totbal as decimal extent 13.

def var v-monthname as char init 
   "январь,февраль,март,апрель,май,июнь,июль,август,сентябрь,октябрь,ноябрь,декабрь".
def var v-name as char init 
   "плат поруч,плат треб,chek,прям деб,инкасс,платеж ордер,без откр счета,заявл перев,mgram,N/A".

def stream rpt.
output stream rpt to 'rpt.img'.
for each temp2  break by temp2.bank by temp2.priz.
  ACCUMULATE temp2.col1 (count by temp2.bank by temp2.priz ).
  ACCUMULATE temp2.bal (total by temp2.bank by  temp2.priz).

 if first-of(temp2.bank) then put stream rpt skip temp2.bank format 'x(15)'.
  put stream rpt skip temp2.jh format 'zzzzzzzzzz9' ' '  temp2.crc  ' '  temp2.bal format 'z,zzz,zzz,zz9.99' ' '   
       temp2.priz  ' ' temp2.bank  format 'x(12)' ' ' temp2.acc format 'x(45)'.
 if last-of(temp2.priz) then  do:

  sum1v = ACCUMulate count  by (temp2.priz) temp2.col1.   
  sum2v = ACCUMulate total  by (temp2.priz) temp2.bal.   

  find temp3 where temp3.bank = temp2.bank  no-error.
  if not avail temp3 then do:
     create temp3 .
     temp3.bank = temp2.bank.
   case temp2.bank :
   when   'TXB00' then temp3.name = 'ЦО'.
   when   'TXB01' then temp3.name = 'Актобе'.
   when   'TXB02' then temp3.name = 'Костанай'.
   when   'TXB03' then temp3.name = 'Тараз'.
   when   'TXB04' then temp3.name = 'Уральск'.
   when   'TXB05' then temp3.name = 'Караганда'.
   when   'TXB06' then temp3.name = 'Семей'.
   when   'TXB07' then temp3.name = 'Кокчетав'.
   when   'TXB08' then temp3.name = 'Астана'.
   when   'TXB09' then temp3.name = 'Павлодар'.
   when   'TXB10' then temp3.name = 'СКО'.
   when   'TXB11' then temp3.name = 'Атырау'.
   when   'TXB12' then temp3.name = 'Актау'.
   when   'TXB13' then temp3.name = 'Жезказган'.
   when   'TXB14' then temp3.name = 'ВКО Усть-Каменогорск'.
   when   'TXB15' then temp3.name = 'Чимкент'.
   when   'TXB16' then temp3.name = 'Алматы'.

   end.
  end.   
         temp3.col1[lookup(temp2.priz,v-name)] = sum1v.
         temp3.bal[lookup(temp2.priz,v-name)]  = sum2v / 1000. /* 20.05.05 nataly */
  put stream rpt skip   'TOTAL ' sum2v format 'z,zzz,zzz,zz9.99' ' '   sum1v  format 'zzzzzzzz9' ' ' .

 end.
end.
output stream rpt close. pause 0.
run menu-prt('rpt.img'). pause 0.

def stream vcrpt.
output stream vcrpt to value(p-filename).


{html-title.i &stream = " stream vcrpt " &title = " " &size-add = "xx-"}

put stream vcrpt unformatted 
   "<p><B>"  "Отчет по распределению платежного оборота за " + 
        entry(v-month, v-monthname) + " " +
        string(v-god, "9999") + " года </B></p>" skip.

find first cmp no-lock no-error.
if avail cmp then 
put stream vcrpt unformatted 
  "<p><B>" string( today, '99/99/9999' ) + ', ' +  string( time, 'HH:MM:SS' ) + ', ' + 
    trim( cmp.name )   "</B></p>" skip(1).
else 
put stream vcrpt unformatted 
  "<p><B>" string( today, '99/99/9999' ) + ', ' +  string( time, 'HH:MM:SS' ) + ', ' + "</B></p>" skip(1).


 
put stream vcrpt unformatted
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" 
   "<TR align=""center"">" 
     "<TD>&nbsp;</TD>" skip
     "<TD rowspan=2 ><B>Наим-ие       </B></FONT></TD>" skip
     "<TD rowspan=2 colspan=2><B> Плат поруч        </B></TD>" skip
     "<TD rowspan=2 colspan=2><B> Платеж требования </B></TD>" skip
     "<TD rowspan=2 colspan=2><B> Чеки              </B></TD>" skip
     "<TD rowspan=2 colspan=2><B> Прямое дебет-ие   </B></TD>" skip
     "<TD rowspan=2 colspan=2><B> Инкас распор      </B></TD>" skip
     "<TD rowspan=2 colspan=2><B> Платеж ордер      </B></TD>" skip
     "<TD colspan=4> <B> Векселя           </B></TD>" skip
     "<TD rowspan=2 colspan=2><B> Переводы без откр </B></TD>" skip
     "<TD rowspan=2 colspan=2><B> Заявл на перевод  </B></TD>" skip
     "<TD rowspan=2 colspan=2><B> Междун почт переводы </B></TD>" skip
     "<TD colspan=4> <B> Аккредитивы         </B></TD>" skip
     "<TD rowspan=2 colspan=2<B> Тип неопределен         </B></TD>" skip
      "</TR>" skip.


put stream vcrpt unformatted
   "<TR align=""center"">" 
     "<TD>&nbsp;</TD>" skip
     " <TD colspan=2><B> принятые  </B></TD>" skip
     " <TD colspan=2><B> погашенные</B></TD> " skip
     " <TD colspan=2><B> открытые  </B></TD>" skip
     " <TD colspan=2><B> исполненные</B></TD> " skip
      "</TR>" skip.

put stream vcrpt unformatted
   "<TR align=""center"">" 
     "<TD>    &nbsp;           </TD>" skip
     "<TD>    &nbsp;       </TD>" skip
     "<TD><B> К </B></TD>" skip
     "<TD><B> С </B></TD>" skip
     "<TD><B> К </B></TD>" skip
     "<TD><B> С </B></TD>" skip
     "<TD><B> К </B></TD>" skip
     "<TD><B> С </B></TD>" skip
     "<TD><B> К </B></TD>" skip
     "<TD><B> С </B></TD>" skip
     "<TD><B> К </B></TD>" skip
     "<TD><B> С </B></TD>" skip
     "<TD><B> К </B></TD>" skip
     "<TD><B> С </B></TD>" skip
     "<TD><B> К </B></TD>" skip
     "<TD><B> С </B></TD>" skip
     "<TD><B> К </B></TD>" skip
     "<TD><B> С </B></TD>" skip
     "<TD><B> К </B></TD>" skip
     "<TD><B> С </B></TD>" skip
     "<TD><B> К </B></TD>" skip
     "<TD><B> С </B></TD>" skip
     "<TD><B> К </B></TD>" skip
     "<TD><B> С </B></TD>" skip
     "<TD><B> К </B></TD>" skip
     "<TD><B> С </B></TD>" skip
     "<TD><B> К </B></TD>" skip
     "<TD><B> С </B></TD>" skip
     "<TD><B> К </B></TD>" skip
     "<TD><B> С </B></TD>" skip
      "</TR>" skip.

   i = 1.
for each temp3 break by temp3.bank.

  do j = 1 to 13.
    totcol[j] =  totcol[j] + temp3.col1[j].
    totbal[j] =  totbal[j] + temp3.bal[j].
  end.
  put stream vcrpt unformatted
    "<TR valign=""top"">" skip 
      "<TD>" i "</TD>" skip
      "<TD>".
            
  put stream vcrpt unformatted
      temp3.name  "</TD>" skip
      "<TD>" temp3.col1[1]  "</TD>" skip
      "<TD>" round(temp3.bal[1],0)   "</TD>" skip
      "<TD>" temp3.col1[2]  "</TD>" skip
      "<TD>" round(temp3.bal[2],0)   "</TD>" skip
      "<TD>" temp3.col1[3]  "</TD>" skip
      "<TD>" round(temp3.bal[3],0)   "</TD>" skip
      "<TD>" temp3.col1[4]  "</TD>" skip
      "<TD>" round(temp3.bal[4],0)   "</TD>" skip
      "<TD>" temp3.col1[5]  "</TD>" skip
      "<TD>" round(temp3.bal[5],0)   "</TD>" skip
      "<TD>" temp3.col1[6]  "</TD>" skip
      "<TD>" round(temp3.bal[6],0)   "</TD>" skip
      "<TD>    &nbsp;       </TD>" skip
      "<TD>   &nbsp;        </TD>" skip
      "<TD>    &nbsp;       </TD>" skip
      "<TD>   &nbsp;        </TD>" skip
      "<TD>" temp3.col1[7]  "</TD>" skip
      "<TD>" round(temp3.bal[7],0)   "</TD>" skip
      "<TD>" temp3.col1[8]  "</TD>" skip
      "<TD>" round(temp3.bal[8],0)   "</TD>" skip
      "<TD>" temp3.col1[9]  "</TD>" skip
      "<TD>" round(temp3.bal[9],0)   "</TD>" skip
      "<TD>    &nbsp;       </TD>" skip
      "<TD>   &nbsp;        </TD>" skip
      "<TD>    &nbsp;       </TD>" skip
      "<TD>   &nbsp;        </TD>" skip
      "<TD>" temp3.col1[10]  "</TD>" skip
      "<TD>" round(temp3.bal[10],0)   "</TD>" skip
     "</TR>" skip.
       i = i + 1.
  end. 

  put stream vcrpt unformatted
    "<TR valign=""top"">" skip 
      "<TD>"  "</TD>" skip
      "<TD> Всего </TD>" skip
      "<TD>" totcol[1]  "</TD>" skip
      "<TD>" round(totbal[1],0)   "</TD>" skip
      "<TD>" totcol[2]  "</TD>" skip
      "<TD>" round(totbal[2],0)   "</TD>" skip
      "<TD>" totcol[3]  "</TD>" skip
      "<TD>" round(totbal[3],0)   "</TD>" skip
      "<TD>" totcol[4]  "</TD>" skip
      "<TD>" round(totbal[4],0)   "</TD>" skip
      "<TD>" totcol[5]  "</TD>" skip
      "<TD>" round(totbal[5],0)   "</TD>" skip
      "<TD>" totcol[6]  "</TD>" skip
      "<TD>" round(totbal[6],0)   "</TD>" skip
      "<TD>    &nbsp;       </TD>" skip
      "<TD>   &nbsp;        </TD>" skip
      "<TD>    &nbsp;       </TD>" skip
      "<TD>   &nbsp;        </TD>" skip
      "<TD>" totcol[7]  "</TD>" skip
      "<TD>" round(totbal[7],0)   "</TD>" skip
      "<TD>" totcol[8]  "</TD>" skip
      "<TD>" round(totbal[8],0)   "</TD>" skip
      "<TD>" totcol[9]  "</TD>" skip
      "<TD>" round(totbal[9],0)   "</TD>" skip
      "<TD>    &nbsp;       </TD>" skip
      "<TD>   &nbsp;        </TD>" skip
      "<TD>    &nbsp;       </TD>" skip
      "<TD>   &nbsp;        </TD>" skip
      "<TD>" totcol[10]  "</TD>" skip
      "<TD>" round(totbal[10],0)   "</TD>" skip
     "</TR>" skip.


put stream vcrpt unformatted
  "</TABLE>" skip.

  find ofc where ofc.ofc = g-ofc no-lock no-error.
  if avail ofc then 
  put stream vcrpt unformatted
    "<BR><BR>" skip
    "<P><FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans""><B>" +
       "Исполнитель : " + ofc.name + "<BR>" skip
       string(g-today, "99/99/99") + "<BR>" skip
     "</B></FONT></P>" skip.
  else 
  put stream vcrpt unformatted
    "<BR><BR>" skip
    "<P><FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans""><B>" +
       "Исполнитель : "  "<BR>" skip
       string(g-today, "99/99/99") + "<BR>" skip
     "</B></FONT></P>" skip.

{html-end.i " stream vcrpt "}

output stream vcrpt close.

  unix silent value("cptwin " + p-filename + " excel").

pause 0.
