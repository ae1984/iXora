/* r-30days.p
 * MODULE
        Клиентская база
 * DESCRIPTION
        Список валютных счетов клиентов типа "В", по которым с момента зачисления суммы
	конвертации в иностранной валюте на валютный счет настал 30 день, счета по их создателям
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        8.1.8.5
 * AUTHOR
        14/01/2004 valery
 * CHANGES
        20/04/2004 valery Добавлен список для VIP просмотра, т.е. для определенных лиц видны все счета. Список лиц имеющих доступ в sysc.sysc=VIP30D
*/


{global.i}

def var v-VIP as char.
def var i as int . 
def var file1 as char format "x(20)".
def var file2 as char format "x(20)".
def var v-dat as date label "ДАТА    ".
def var comprt as cha initial "prit  " format "x(10)" .
def var v-new as log  format "создать/продожить"  initial "Создать".
def buffer b-aab for aab . 
def var s-bal like aab.bal .
def var old-bal like aab.bal . 
def var st-bal like aab.bal .
DEF STREAM m-out1.
DEF STREAM m-out2.
DEF var dd AS int .
DEF var mm AS int .
DEF var yy AS int.

def temp-table t-table
  field name like cif.name
  field aaa like aaa.aaa
  field ost30 as decimal format "z,zzz,zzz,zzz,zz9.99-"
  field ostProd as decimal format "z,zzz,zzz,zzz,zz9.99-"
  field ostTek as decimal format "z,zzz,zzz,zzz,zz9.99-"
  field crc like crc.code.



v-dat = g-today .
dd = day(v-dat) .
mm = month(v-dat) .
yy = year(v-dat) .
file1 = "30days" + string(dd,"99") + string(mm,"99") + string(yy,"9999" + ".html") .
display "......Ж Д И Т Е ......."  with row 12 frame ww centered .
pause 0 .


if v-new then do :
    output to value(file1).
end.
else   
    output to value(file1) append .



find first cmp no-lock no-error.
put unformatted
  "<P style=""font-size:x-small"">" cmp.name "</P>" skip
  "<P align=""center"" style=""font:bold;font-size:small"">Отчет по остаткам непроданной за 30 дней валюты за " v-dat " по текущим счетам</P>" skip
  "<TABLE cellspacing=""0"" cellpadding=""5"" align=""center"" border=""1"" width=""100%"">" skip.
put unformatted
      "<TR align=""center"" style=""font:bold;background:deepskyblue "">" skip
	"<TD>N<br>п/п</TD>" skip
        "<TD>КЛИЕНТ</TD>" skip
        "<TD>НОМЕР СЧЕТА</TD>" skip
        "<TD>ОСТАТОК НА "string(v-dat - 30)"</TD>" skip
        "<TD>НЕПРОДАННЫЙ ОСТАТОК НА "string(v-dat)"</TD>" skip
        "<TD>ОСТАТОК НА СЧЕТЕ</TD>" skip
        "<TD>Вал.</TD>" skip
        "</TR>" skip.
find sysc where sysc.sysc = "VIP30D" no-lock no-error.	
if avail sysc then do:
   v-VIP = sysc.chval.
end.

find sysc where sysc.sysc = "VC-AGR" no-lock no-error.

 for each aaa  where aaa.crc <> 1 and lookup(aaa.lgr,sysc.chval) > 0  no-lock . /* выбираем только валютные счета */
  if aaa.sta = "C" or aaa.sta = "С" then next. /* закрытые счета откидываем */
  find cif where cif.cif = aaa.cif no-lock no-error.
  if avail cif then if cif.type <> "B" or (cif.fname <> g-ofc and lookup(g-ofc,v-VIP) = 0) then next.  /* если клиент не юридическое лицо, то берем следующую запись */




 /* отбираем остатки на каждый день по счету за 30 предыдущих дней*/

  find first aab where aab.aaa = aaa.aaa and aab.fdt > v-dat - 30 use-index aab no-lock no-error   .  
   if not avail aab then 
   do:
   	 find last aab where aab.aaa = aaa.aaa use-index aab no-lock no-error.
	 if not avail aab then next . 
   end.
   else 
   do:
	    find prev aab where aab.aaa = aaa.aaa use-index aab no-lock no-error.
	    if not avail aab then next . 
   end.
   old-bal = aab.bal .  
   st-bal = aab.bal .  
   s-bal = aab.bal .   
   repeat:
    		find next aab where aab.aaa = aaa.aaa use-index aab no-lock no-error.   
    		if not avail aab then leave . 
    		if aab.bal < old-bal then  
		do:
      			s-bal = s-bal - ( old-bal - aab.bal ) .
      			
			if s-bal <= 0 then do: 
				 	leave.
		        end. 
   		end. 
    		old-bal = aab.bal .
   end.
   if s-bal > 0 then do:
	find crc where crc.crc = aaa.crc no-lock no-error.
				        create t-table.
					assign t-table.name = cif.name
					       t-table.aaa = aaa.aaa
 						t-table.ost30 = st-bal
						t-table.ostProd = s-bal		
						t-table.ostTek = aaa.cr[1] - aaa.dr[1]
						t-table.crc = crc.code.

   end.

 end. 


for each t-table by t-table.name .
        i = i + 1.
	put unformatted
		"<tr><td>" i "</td>" skip
		"<td>" t-table.name "</td>" skip 
		"<td>" t-table.aaa "</td>" skip
		"<td align=right>" t-table.ost30 "</td>" skip
		"<td align=right>" t-table.ostProd "</td>" skip
		"<td align=right>" t-table.ostTek "</td>" skip
		"<td>" t-table.crc "</td></tr>" skip.
end.

put unformatted "</table>" skip.

put unformatted 
		"<table align=right><tr><td><b>ИТОГО:</td>" skip.


for each t-table break by t-table.crc.
		accumulate t-table.ostTek (SUB-TOTAL by t-table.crc). 
if last-of(t-table.crc) then do:
   put unformatted 
		"<td><b>(" t-table.crc "</td><td><b>" (accum SUB-TOTAL by t-table.crc t-table.ostTek) ")</td>" skip.
end.
end.

put unformatted "</tr><table>" skip.

find first ofc where ofc.ofc = g-ofc no-lock .
put unformatted 
"<P>Дата печати : "string(today)"<br>Время печати: "string(time,"hh:mm:ss") "<br>Исполнитель : " ofc.name "</P>" skip. 
if  lookup (g-ofc, v-VIP) > 0 then 
put unformatted 
	"<P style=color:red;><b>ПРИМЕЧАНИЕ: Вы пользуетесь правами VIP</P>" skip.



{html-end.i " "}



output close . 
hide frame ww . 

unix silent cptwin value(file1) iexplore.