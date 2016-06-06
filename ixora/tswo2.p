/* tswo2.p
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
	18/01/2005 u00121 возможность получения отчета на филиалах
*/

/* 06/06/03 nataly 
   Отчет по внешним валютным платежам с комиссией */

{functions-def.i}
{comm-swt.i}

def temp-table trmz
 field rmz like remtrz.remtrz
 field c as char format "x(4)"
/* field ur as integer 
 field fiz as integer 
 field urfiz as integer */
 field priz as char
 field crc like crc.crc
 field amt like remtrz.payment
 field svca like remtrz.svca
 field dt like remtrz.valdt2
 field saaa like remtrz.sacc
 field raaa like remtrz.racc
 field actins like remtrz.actins
 field rbank like remtrz.rbank
 field svcrc like  remtrz.svcrc
index rmz  IS PRIMARY rmz.

def var v-d1 as date.
def var v-d2 as date.
def var fdt as date.
def var v-bank as char.

def stream rpt.
output stream rpt to rpt.html.

update "Укажите период с " v-d1 no-label " по " v-d2 no-label.
def var l as logical init false.

find first sysc where sysc = 'OURBNK' no-lock no-error.

for each remtrz where valdt2 >= v-d1 and valdt2 <= v-d2 and 
                      tcrc<>1 and 
		      if sbank = 'TXB00' then (ptyp='6' or ptyp='2') else (sbank = sysc.chval and rcbank = 'TXB00') no-lock. /*18/01/2005 u00121*/
 

 find first bankl where bankl.cbank = remtrz.rbank no-lock no-error .
 if avail bankl then v-bank = bankl.name. else v-bank = remtrz.rbank.

   find arp where arp.arp = remtrz.sacc no-lock no-error.
    if avail arp then next.

    find aaa where aaa.aaa = remtrz.sacc no-lock no-error.
/*    if not avail aaa then next.*/


if remtrz.svcrc <> 0 then 
  find last crchis where crchis.crc = remtrz.svcrc and crchis.rdt <=  remtrz.valdt2 no-lock no-error. 

 create trmz.
 assign trmz.rmz = remtrz.remtrz
        trmz.crc = remtrz.tcrc
        trmz.amt = remtrz.payment
        trmz.dt  = remtrz.valdt2
        trmz.saaa = remtrz.sacc 
        trmz.raaa = remtrz.cracc
        trmz.rbank = v-bank
        trmz.svcrc = remtrz.svcrc.

/* if remtrz.ptype = '6'  then do:*/
 if remtrz.sacc <> ""  then do:
   /* отбираем только клиентские платежи */
   find cif  where cif.cif = aaa.cif no-lock no-error.

    /* определим тип клиента ... */
    find first sub-cod where 
    sub-cod.d-cod = 'clnsts' and
    sub-cod.sub   = 'cln'    and
    sub-cod.acc   = string(cif.cif) 
    no-lock no-error.

    if not avail sub-cod then  do:
      trmz.priz = "не задан".
      message 'Не задан признак ФЛ/ЮЛ для клиента со счетом ' remtrz.sacc remtrz.remtrz
     view-as alert-box.
    end.

    if sub-cod.ccode = '0'  then trmz.priz = "ЮЛ".
    else if sub-cod.ccode = '1' then trmz.priz = "ФЛ".
    else do:
      trmz.priz = "не задан".
      message 'Не задан признак ФЛ/ЮЛ для клиента со счетом ' remtrz.sacc remtrz.remtrz
     view-as alert-box.
    end.

  end.   /* remtrz.sacc <> "" */
  else     trmz.priz = "ФЛ".
/* end. /*ptype*/*/

   if avail crchis then  trmz.svca = remtrz.svca  * crchis.rate[1].
   else  trmz.svca = remtrz.svca.
                              

end.

{html-title.i &stream = " stream rpt " &title = " " &size-add = "xx-"}

put stream rpt  unformatted 
   "<p><B> Отчет по внешним платежам. Период: " 
     string(v-d1,"99/99/99") " - " string(v-d2,"99/99/99")  skip. 

put stream rpt unformatted
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip
   "<TR align=""center"">" skip
     "<TD><FONT size=""1""><B>RMZ</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Тип клиента </B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Дебет </B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Кредит</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Валюта платежа</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Банк-корресп</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Сумма в валюте платежа</B></FONT></TD>" skip
/*     "<TD><FONT size=""1""><B>Вал комм</B></FONT></TD>" skip*/
     "<TD><FONT size=""1""><B>Комиссия в тенге</B></FONT></TD>" skip.

put stream rpt  unformatted
   "</TR>" skip.


for each trmz no-lock break  by trmz.crc by trmz.rbank  by trmz.priz  .

    find first crc no-lock where crc.crc = trmz.crc no-error.
/*   if trmz.ur = 1 then  v-type  = "ЮЛ". 
   else if  trmz.fiz = 1 then  v-type  = "ФЛ".
   else if  trmz.urfiz = 1 then  v-type  = "не задан".
  */
  put stream rpt unformatted
      "<TD>"  trmz.rmz  "</TD>" skip
      "<TD>"  trmz.priz  "</TD>" skip
      "<TD>"  trmz.saaa  "</TD>" skip
      "<TD>"  trmz.raaa  "</TD>" skip
      "<TD>"  crc.code  "</TD>" skip
      "<TD>"  trmz.rbank  "</TD>" skip
      "<TD>" replace(string(trmz.amt,'zzzzzzzzzzzzz9.99'),".",",")   "</TD>" skip
/*      "<TD>"  trmz.svcrc  "</TD>" skip*/
      "<TD>" replace(string(trmz.svca,'zzzzzzzzzzzzz9.99'),".",",")  "</TD>" skip.
  put stream rpt unformatted
    "</TR>" skip.
  
 accumulate trmz.amt (count).
 accumulate trmz.amt (sub-count sub-total by trmz.crc by trmz.rbank ).
 accumulate trmz.svca (sub-total by trmz.crc by trmz.rbank ).
 accumulate trmz.amt (sub-count sub-total by trmz.crc by trmz.priz ).
 accumulate trmz.svca (sub-total by trmz.crc by trmz.priz ).
/* accumulate trmz.ur (sub-count sub-total by trmz.crc by trmz.rbank ).
 accumulate trmz.fiz (sub-count sub-total by trmz.crc by trmz.rbank ).
 accumulate trmz.urfiz (sub-count sub-total by trmz.crc by trmz.rbank ).
  */
 if last-of(trmz.priz) then do:
  put stream rpt unformatted
      "<TD>  &nbsp;  </TD>" skip
      "<TD>  &nbsp;  </TD>" skip
      "<TD>  &nbsp;  </TD>" skip
      "<TD><b>  TOTAL   </b></TD>" skip
      "<TD><b>" (accum sub-count by trmz.priz trmz.amt) " </B></TD>" skip
      "<TD><b>"  trmz.priz  "</b></TD>" skip
      "<TD><b>" replace(string((accum sub-total by trmz.priz trmz.amt),'zzzzzzzzzzzzz9.99'),".",",")   "</B></TD>" skip
      "<TD><b>"  replace(string((accum sub-total by trmz.priz trmz.svca),'zzzzzzzzzzzzz9.99'),".",",") "</b></TD>" skip.
  put stream rpt unformatted
    "</TR>" skip.
end.

 if last-of(trmz.rbank) then do:

  put stream rpt unformatted
      "<TD>  &nbsp;  </TD>" skip
      "<TD>  &nbsp;  </TD>" skip
      "<TD>  &nbsp;  </TD>" skip
      "<TD><b>  TOTAL   </b></TD>" skip
      "<TD><b>" (accum sub-count by trmz.rbank trmz.amt) " </B></TD>" skip
      "<TD><b>"  trmz.rbank  "</b></TD>" skip
      "<TD><b>" replace(string((accum sub-total by trmz.rbank trmz.amt),'zzzzzzzzzzzzz9.99'),".",",")   "</B></TD>" skip
      "<TD><b>"  replace(string((accum sub-total by trmz.rbank trmz.svca),'zzzzzzzzzzzzz9.99'),".",",") "</b></TD>" skip.
  put stream rpt unformatted
    "</TR>" skip.
end.

 if last-of(trmz.crc) then do:
    find first crc no-lock where crc.crc=trmz.crc no-error.

  put stream rpt unformatted
      "<TD>  &nbsp;  </TD>" skip
      "<TD>  &nbsp;  </TD>" skip
      "<TD>  &nbsp;  </TD>" skip
      "<TD><b> TOTAL  </b></TD>" skip
      "<TD><b>" (accum sub-count by trmz.crc trmz.amt) "</B></TD>" skip
      "<TD><b>"  crc.code  "</b></TD>" skip
      "<TD><b>" replace(string((accum sub-total by trmz.crc trmz.amt),'zzzzzzzzzzzzz9.99'),".",",")   "</B></TD>" skip
      "<TD><b>"  replace(string((accum sub-total by trmz.crc trmz.svca),'zzzzzzzzzzzzz9.99'),".",",") "</b></TD>" skip.
  put stream rpt unformatted
    "</TR>" skip.

/*    put space(28) skip  crc.code "    "
    (accum sub-count by trmz.crc trmz.amt) format ">>>>>9" 
    " "
    (accum sub-total by trmz.crc trmz.amt) format ">>>,>>>,>>>,>>>,>>9.99"
    skip. */
 end.

end. /*trmz*/
{html-end.i " stream rpt "}

output stream rpt close.

unix silent cptwin rpt.html excel.
pause 0.
