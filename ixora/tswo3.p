/* tswo3.p
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
        13/01/05 sasco убрал проверку на валюту
        17/01/05 sasco исправил ошибку в счете Г/К
        28/10/2013 galina - ТЗ1746 добавила платежи типа 4 (ptyp = '4') и наименование банка берем из наименования dfb
*/

/*   07/06/03 nataly
     отчет по входящим  - исходящим платежам по счетам НОСТРО
     (105210,105220) в разрезе банков-корреспондентов */

{functions-def.i}
{comm-swt.i}

def temp-table trmz
 field rmz like remtrz.remtrz
 field c as char format "x(4)"
 field crc like crc.crc
 field dam like remtrz.payment
 field cam like remtrz.payment
 field svca like remtrz.svca
 field dt like remtrz.valdt2
 field coldr as integer
 field colcr as integer
 field actins like remtrz.actins
 field rbank like remtrz.rbank
 field svcrc like  remtrz.svcrc
index rmz  IS PRIMARY rmz.

def var v-d1 as date.
def var v-d2 as date.
def var fdt as date.
def var v-bank as char.
DEFINE VARIABLE months  AS char EXTENT 12 INITIAL ["январь","февраль","март","апрель","май","июнь","июль","август","сентябрь","октябрь","ноябрь","декабрь"].
def stream rpt.
output stream rpt to rpt.html.

update "Укажите период с " v-d1 no-label " по " v-d2 no-label.
def var l as logical init false.

if v-d2 < v-d1 then do :
   message 'Вторая дата не может быть меньше начальной !!!' view-as alert-box.
  return.
end.
if v-d2 - v-d1 > 365 then do :
   message 'Нельзя задать период бальше 1 года !!!' view-as alert-box.
  return.
end.

for each remtrz where valdt2 >= v-d1 and valdt2 <= v-d2 and
    /* tcrc<>1 and */ (ptyp='6' or ptyp='2' or ptyp='7' or ptyp='4') no-lock.

   if  not (crgl = 105210) and not (crgl = 105220)  and
       not (drgl = 105210) and not (drgl = 105220) then next.


 create trmz.

if ptyp='6' or ptyp='2' then do:
   /*find first bankl where bankl.cbank = remtrz.rbank no-lock no-error .
   if avail bankl then v-bank = bankl.name. else v-bank = remtrz.rbank.*/
    find first dfb where dfb.dfb = remtrz.cracc no-lock no-error.
    v-bank = dfb.name.
end.
else if ptyp='7' or ptyp='4' then do:
   /*find first bankl where bankl.cbank = remtrz.sbank no-lock no-error .
   if avail bankl then v-bank = bankl.name. else v-bank = remtrz.sbank.*/
    find first dfb where dfb.dfb = remtrz.dracc no-lock no-error.
    v-bank = dfb.name.
end.

if remtrz.svcrc <> 0 then find last crchis where crchis.crc = remtrz.svcrc and crchis.rdt <=  remtrz.valdt2 no-lock no-error.

 assign trmz.rmz = remtrz.remtrz
        trmz.crc = remtrz.tcrc
        trmz.dt  = remtrz.valdt2
        trmz.rbank = v-bank .

   if remtrz.drgl = 105210 or  remtrz.drgl = 105220 then trmz.dam = remtrz.payment.
   if remtrz.crgl = 105210 or  remtrz.crgl = 105220 then trmz.cam = remtrz.payment.

   if remtrz.drgl = 105210 or  remtrz.drgl = 105220 then trmz.coldr = 1.
   if remtrz.crgl = 105210 or  remtrz.crgl = 105220 then trmz.colcr = 1.

end. /*remtrz*/

{html-title.i &stream = " stream rpt " &title = " " &size-add = "xx-"}

put stream rpt  unformatted
   "<p><B> Отчет по входящим и исходящим платежам по счетам НОСТРО (105210/105220). Период: "
     string(v-d1,"99/99/99") " - " string(v-d2,"99/99/99")  skip.

for each trmz no-lock break by month(trmz.dt) by trmz.rbank by trmz.crc  .

    find first crc no-lock where crc.crc = trmz.crc no-error.

 accumulate trmz.dam   ( sub-total by month(trmz.dt) by trmz.rbank by trmz.crc   ).
 accumulate trmz.cam   ( sub-total by month(trmz.dt) by trmz.rbank by trmz.crc   ).
 accumulate trmz.coldr ( sub-total by month(trmz.dt) by trmz.rbank by trmz.crc   ).
 accumulate trmz.colcr ( sub-total by month(trmz.dt) by trmz.rbank by trmz.crc   ).


  if first-of(month(trmz.dt)) then do:
put stream rpt unformatted
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip
   "<TR align=""center"">" skip
     "<TD><FONT size=""1""><B>Месяц</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Банк-корреспондент </B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Валюта платежа </B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Кол-во/Дебет</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Кол-во/Кредит</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Объем/Дебет  </B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Объем/Кредит  </B></FONT></TD>" skip.

put stream rpt  unformatted
   "</TR>" skip.
end.

  if first-of(trmz.rbank) then do:
  put stream rpt unformatted
      "<TD>"  months[month(trmz.dt)]  "</TD>" skip
      "<TD><b>" trmz.rbank "</b></TD>" skip
      "<TD><b>&nbsp;</b></TD>" skip
     "<TD><B>&nbsp;  </B></TD>" skip
     "<TD><B>&nbsp; </B></TD>" skip
     "<TD><B>&nbsp;  </B></TD>" skip
     "<TD><B>&nbsp; </B></TD>" skip.

  put stream rpt unformatted
    "</TR>" skip.
   end.

/* вывод промежуточых данных
 put stream rpt unformatted
      "<TD>"  trmz.rmz  "</TD>" skip
      "<TD>  &nbsp;    </TD>" skip
      "<TD>"  crc.code  "</TD>" skip
      "<TD>"  trmz.rbank  "</TD>" skip
      "<TD>" replace(string(trmz.dam,'zzzzzzzzzzzzz9.99'),".",",")   "</TD>" skip
      "<TD>" replace(string(trmz.cam,'zzzzzzzzzzzzz9.99'),".",",")   "</TD>" skip
      "<TD>" month(trmz.dt)  "</TD>" skip.
  put stream rpt unformatted
    "</TR>" skip.
 */

 if last-of(trmz.crc) then do:
    find first crc no-lock where crc.crc=trmz.crc no-error.
  put stream rpt unformatted
      "<TD>  &nbsp;  </TD>" skip
      "<TD>&nbsp;</TD>" skip
      "<TD><b>"  crc.code  "</b></TD>" skip
      "<TD>" (accum sub-total by trmz.crc trmz.coldr)  "</TD>" skip
      "<TD>" (accum sub-total by trmz.crc trmz.colcr) "</TD>" skip
      "<TD>" replace(string((accum sub-total by trmz.crc trmz.dam),'zzzzzzzzzzzzz9.99'),".",",")   "</TD>" skip
      "<TD>"  replace(string((accum sub-total by trmz.crc trmz.cam),'zzzzzzzzzzzzz9.99'),".",",") "</TD>" skip.
  put stream rpt unformatted
    "</TR>" skip.
 end.


end. /*trmz*/
{html-end.i " stream rpt "}

output stream rpt close.

unix silent cptwin rpt.html excel.
pause 0.
