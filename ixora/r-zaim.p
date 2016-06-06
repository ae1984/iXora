/* r-zaim.p
 * MODULE
	Кредитный
 * DESCRIPTION
	отчет по клиентам с крупными ссудами
 * RUN
	        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        4-2-4-6 
 * AUTHOR
        06.01.2004 valery
 * CHANGES
*/

{global.i}                           

def var i as integer initial "0".
def var v-file as char init "vzaim.htm".
def var bilance as decimal.                         
def var sumUSD as decimal.
def var sumTEN as decimal.
def var curUSD as decimal.
def var curEUR as decimal.
def var SumMin as decimal format "z,zzz,zzz,zzz,zz9.99" label "Введите минимальную сумму остатка:".

def temp-table t-table
	field t-cif like cif.cif
	field t-pref like cif.prefix
	field t-name like cif.name
	field t-addr like cif.addr
	field t-tel like cif.tel
	field t-fax like cif.fax
	field t-fio like sub-cod.rcode
	field t-lon like lon.lon
	field t-sum as decimal
	field t-crc like crc.code.
	

set SumMin.

output to value(v-file).
{html-title.i &stream = " " &title = " " &size-add = "x-"}

find crc where crc.crc = 2 use-index crc no-lock no-error.  /*находим курс тенге по отношению к USD*/
curUSD = crc.rate[1].


find crc where crc.crc = 11 use-index crc no-lock no-error.  /*находим курс тенге по отношению к EUR*/
curEUR = crc.rate[1].


find first cmp no-lock no-error.

/*****************************************************************************************************/
put unformatted
  "<P style=""font-size:x-small"">" cmp.name "</P>" 
  "<P align=""right"">1 USD = " curUSD " тнг.<br>1 EUR = " curEUR " тнг.</P>" skip
/*  "<P align=""right"">1 EUR = " curEUR " тнг.</P>" skip*/
  "<P align=""center"" style=""font:bold;font-size:small"">Клиенты, сумма займа которых превышает " SumMin format "z,zzz,zzz,zzz,zz9.99" " долларов США на " g-today " " string(time,"HH:MM:SS") "</P>" skip
  "<TABLE cellspacing=""0"" cellpadding=""5"" align=""center"" border=""1"" width=""100%"">" skip.
/*****************************************************************************************************/

/*****************************************************************************************************/
put unformatted
      "<TR align=""center"" style=""font:bold"">" skip
	"<TD>N<br>п/п</TD>" skip
	"<TD>Наименование</TD>" skip
	"<TD>Юридический адрес</TD>" skip
        "<TD>Фактический адрес</TD>" skip
        "<TD>Телефон</TD>" skip
        "<TD>Факс</TD>" skip
        "<TD>Ф.И.О.<br>руководителя</TD>" skip
        "<TD>N<br>счета</TD>" skip
        "<TD>Остаток<br>на счету</TD>" skip
        "<TD>Валюта<br>счета</TD>" skip
        "</TR>" skip.
/*****************************************************************************************************/


/*****************************************************************************************************/
for each lon no-lock.

	run atl-dat (lon.lon,g-today,output bilance).  /*находим остаток от займа*/
	
	if (bilance >= SumMin) and (lon.crc = 2) then /*доллары*/
	do:
		run add_table(bilance).
	end.

	if lon.crc = 1 then /*тенге*/
	do:
		sumUSD = bilance / curUSD.
		if sumUSD >=SumMin then 
		do:
			run add_table(bilance).				
		end.
	end.

	if lon.crc = 11 then /*евро*/
	do:
		sumTEN = bilance * curEUR. /*сумма в евро умножается на курс тенге(EUR) получаем сумму в тенге*/
		sumUSD = sumTEN / curUSD.  /*сумма в тенге делится на курс тенге(USD) получаем сумму в USD*/
		if sumUSD >= SumMin then 
		do:
                     run add_table(bilance).
		end.
		
	end.
end.
/*****************************************************************************************************/

for each t-table by t-name.
i = i + 1.
		put unformatted
	            "<TR><TD>" i "</TD>" skip
			"<td>" t-table.t-pref + " " + t-table.t-name "</td>" skip
			"<td>" t-table.t-addr[1] "</TD>" skip
			"<td>" t-table.t-addr[2] "</TD>" skip
			"<td>" t-table.t-tel "</td>" skip
			"<td>" t-table.t-fax "</td>"
			"<td>" t-table.t-fio "</td>"
			"<td>" t-table.t-lon "</td>"
			"<td align=""right"">" t-table.t-sum format "z,zzz,zzz,zzz,zz9.99" "</td>"
			"<td>" t-table.t-crc "</td>"
			"</TR>" skip.
end.

procedure add_table.
def input parameter p-sum as decimal.
		find cif where cif.cif = lon.cif use-index cif no-lock no-error.
	 	if available cif then 
		do:
			create t-table.
			assign
				t-table.t-cif = cif.cif
				t-table.t-pref = cif.prefix.
				t-table.t-name = cif.name.
				t-table.t-addr[1] = cif.addr[1].
				t-table.t-addr[2] = cif.addr[2].
				t-table.t-tel = cif.tel.
				t-table.t-fax = cif.fax.
			     find sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = cif.cif and sub-cod.d-cod = 'clnchf' use-index dcod no-lock no-error.  	
				t-table.t-fio = sub-cod.rcode.					
				t-table.t-lon = lon.lon.
				t-table.t-sum = p-sum.
			     find crc where crc.crc = lon.crc use-index crc no-lock no-error.	
				t-table.t-crc = crc.code.
		end.
end procedure .

{html-end.i " "}

output close.

unix silent cptwin value(v-file) excel.
  
pause 0.
