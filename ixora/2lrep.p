/* 2l_monitor.p
 * MODULE
	Внутренний аудит
 * DESCRIPTION
	Формирование списка платежей находящихся на полках очереди 2l в текущий момент
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        8-6-3-2 
 * AUTHOR
        31.12.2003 valery
 * CHANGES
        06/10/2005  marinav добавилось время и RMZ
*/

{global.i}

&scoped-define L que.pid begins "2l".

def var v-pol like remtrz.rsub.
def var v-TotalSum like remtrz.amt.
def var v-TotalSumAll like remtrz.amt.
def var v-i as integer initial "1".
def var v-iTotal as integer initial "0".
def var v-bool as logical initial "false".

def var tSh-Pol as character initial "beige".  /*цвет заголовка строки с названием "полочки"*/
def var tSh-Tot as character initial "aliceblue". /*цвет заголовка строки с итоговыми данными*/

def var v-file as char init "2l.htm".

define temp-table t-tmp
field rsub like remtrz.rsub
field amt like remtrz.amt
field racc like remtrz.ba
field NameCif like remtrz.bn
field sts as character
field tim as character
field rmz as character
field remarks as character format "x(200)".


/*******************************************************************************************************************/

for each que where {&L} no-lock.
find remtrz where remtrz.remtrz = que.remtrz.
	if available remtrz then 
	do:
				create t-tmp.
				assign	
				t-tmp.sts = "?".
				find jh where jh.jh = remtrz.jh2 use-index jh no-lock no-error.
			        if available jh then 
				do:
			                t-tmp.sts = string(jh.sts).
				end.
					t-tmp.remarks = trim(remtrz.detpay[1]) + trim(remtrz.detpay[2]) + trim(remtrz.detpay[3]).    	
					t-tmp.rsub = remtrz.rsub.
					t-tmp.amt = remtrz.amt.
					t-tmp.racc = remtrz.ba.
                                        t-tmp.NameCif = remtrz.bn[1].
                                        t-tmp.rmz = remtrz.remtrz.
                                        t-tmp.tim = string(que.tf, "HH:MM:SS") .
	end.
end.

/*******************************************************************************************************************/



/*******************************************************************************************************************/

output to value(v-file).

{html-title.i &stream = " " &title = " " &size-add = "x-"}

find first cmp no-lock no-error.
put unformatted
  "<P style=""font-size:x-small"">" cmp.name "</P>" skip
  "<P align=""center"" style=""font:bold;font-size:small"">Состояние платежей в очереди 2l на " g-today " " string(time,"HH:MM:SS") "</P>" skip
  "<TABLE cellspacing=""0"" cellpadding=""5"" align=""center"" border=""1"" width=""100%"">" skip.
    put unformatted
      "<TR align=""center"" style=""font:bold;background:" tSh-Pol """>" skip
	"<TD>&#147;ПОЛОЧКА&#148;</TD>" skip
	"<TD>N<br>п/п</TD>" skip
        "<TD>СУММА</TD>" skip
        "<TD>НОМЕР СЧЕТА ПО КРЕДИТУ</TD>" skip
        "<TD>НАИМЕНОВАНИЕ ПОЛУЧАТЕЛЯ</TD>" skip
        "<TD>СТАТУС ТРАНЗАКЦИИ</TD>" skip
        "<TD>ВРЕМЯ ПЛАТЕЖА </TD>" skip
        "<TD>НАЗНАЧЕНИЕ ПЛАТЕЖА</TD>" skip
        "<TD>RMZ</TD>" skip
        "</TR>" skip.
v-TotalSum = 0.
v-TotalSumAll = 0.
    for each t-tmp by t-tmp.rsub.
 	if v-pol <> t-tmp.rsub then 
	do:
	   if v-bool then 
	   do:
		put unformatted
		"<TR style=""background:" tSh-Tot """ align=""middle""><TD>Итого по &#147;полочке&#148;</TD>" skip
		"<td style=""background:" tSh-Tot """ align=right> </td>" skip
		"<TD style=""background:" tSh-Tot """ align=right>" v-TotalSum format "z,zzz,zzz,zzz,zz9.99" "</TD>" skip
		"<td style=""background:" tSh-Tot """ > </td>" skip
		"<td style=""background:" tSh-Tot """ > </td>" skip
		"<td style=""background:" tSh-Tot """ > </td>" skip
		"<td style=""background:" tSh-Tot """ > </td>" skip
		"<td style=""background:" tSh-Tot """ > </td>" skip
		"<td style=""background:" tSh-Tot """ > </td></TR>" skip.

	   end.
	   put unformatted 
		"<TR style=""background:" tSh-Pol """><TD><b>" t-tmp.rsub "</b></TD>" skip
		"<td style=""background:" tSh-Pol """> </td>" skip
		"<td style=""background:" tSh-Pol """> </td>" skip
		"<td style=""background:" tSh-Pol """> </td>" skip
		"<td style=""background:" tSh-Pol """> </td>" skip
		"<td style=""background:" tSh-Pol """> </td>" skip
		"<td style=""background:" tSh-Pol """> </td>" skip
		"<td style=""background:" tSh-Pol """> </td>" skip
		"<td style=""background:" tSh-Pol """> </td></TR>" skip.

           v-TotalSum = 0.		
	   v-i = 1.
	   v-pol = t-tmp.rsub.	
	   v-bool = true.	
	end.
	put unformatted
        	"<TR><TD></TD>" skip
		"<TD>" v-i "</TD>" skip
		"<TD align=right>" t-tmp.amt format "z,zzz,zzz,zzz,zz9.99" "</TD>" skip	
		"<TD>" t-tmp.racc "</TD>" skip	
		"<TD>" t-tmp.NameCif[1] "</TD>" skip	
		"<TD>" t-tmp.sts "</TD>" skip	
		"<TD>" t-tmp.tim "</TD>" skip	
		"<TD>" t-tmp.remarks "</TD>" 
		"<TD>" t-tmp.rmz "</TD></TR>" skip.	
	v-i = v-i + 1.
	v-iTotal = v-iTotal + 1.
	v-TotalSum = v-TotalSum + t-tmp.amt.
	v-TotalSumAll = v-TotalSumAll + t-tmp.amt.
    end.
	   if v-bool then 
	   do:
		put unformatted
		"<TR style=""background:" tSh-Tot """ align=""middle""><TD>Итого по &#147;полочке&#148;</TD>" skip
		"<td style=""background:" tSh-Tot """ > </td>" skip
		"<TD align=right>" v-TotalSum format "z,zzz,zzz,zzz,zz9.99" "</TD>" skip
		"<td style=""background:" tSh-Tot """ > </td>" skip
		"<td style=""background:" tSh-Tot """ > </td>" skip
		"<td style=""background:" tSh-Tot """ > </td>" skip
		"<td style=""background:" tSh-Tot """ > </td>" skip
		"<td style=""background:" tSh-Tot """ > </td>" skip
		"<td style=""background:" tSh-Tot """ > </td></TR>" skip
		"<TR><TD><b>ИТОГО В ОЧЕРЕДИ 2L</b></TD>" skip
		"<td>" v-iTotal "</td>" skip
		"<TD align=right><b>" v-TotalSumAll format "z,zzz,zzz,zzz,zz9.99" "</b></TD></TR>" skip.
	   end.

	
{html-end.i " "}

output close.

/**********************************************************************************************************************/


unix silent cptwin value(v-file) iexplore.

pause 0.
