/* r-dep12.p
 * MODULE
        Клиентская база
 * DESCRIPTION
       список депозитов срок которых превышает 12 месяцев
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        2.4.12
 * BASES
        BANK COMM
 * AUTHOR
        12.01.2004 valery
* CHANGES
*/

{global.i}
def var v-ost as decimal format "z,zzz,zzz,zzz,zzz.99".
def var v-file as char init "1.htm".
def var i as int initial "0".
def var v-dt as date format "99/99/99" label "Дата отбора".

def var v-i as int.

def var v-M1 as int.
def var v-M2 as int.
def var v-Y1 as int.
def var v-Y2 as int.
def var v-D1 as int.
def var v-D2 as int.

def temp-table t-table
  field name like cif.name
  field aaa like aaa.aaa
  field rate like aaa.rate
  field regdt like aaa.regdt
  field expdt like aaa.expdt
  field ost like v-ost
  field sta like aaa.sta
  field crc like crc.code.

update v-dt help "Введите дату на которую необходимо проводить отбор".

output to value(v-file).
find first cmp no-lock no-error.
put unformatted
  "<P style=""font-size:x-small"">" cmp.name "</P>" skip
  "<P align=""center"" style=""font:bold;font-size:small"">Список депозитов по которым со дня регистрации прошло 12 месяцев, либо срок которых истек.<br>На дату: " v-dt "</P>" skip
  "<TABLE cellspacing=""0"" cellpadding=""5"" align=""center"" border=""1"" width=""100%"">" skip.
    put unformatted
      "<TR align=""center"" style=""font:bold;background:yellow "">" skip
	"<TD>N<br>п/п</TD>" skip
        "<TD>КЛИЕНТ</TD>" skip
        "<TD>НОМЕР СЧЕТА</TD>" skip
        "<TD>%</TD>" skip
        "<TD>ДАТА РЕГИСТРАЦИИ</TD>" skip
        "<TD>ДАТА ОКОНЧАНИЯ СРОКА</TD>" skip
        "<TD>ОСТАТОК</TD>" skip
        "<TD>ВАЛЮТА</TD>" skip
        "<TD>СТАТУС</TD>" skip
        "</TR>" skip.


for each lgr where lgr.led = "CDA" or lgr.led = "TDA" no-lock.
    for each aaa where aaa.lgr = lgr.lgr  use-index lgr no-lock.
 	if aaa.sta <> "c" and (aaa.expdt - aaa.regdt) >= 365 then do:
	   v-M1 = month(aaa.regdt).
	   v-M2 = month(v-dt).
	   v-Y1 = Year(aaa.regdt).
	   v-Y2 = Year(v-dt).	
	   v-D1 = Day(aaa.regdt).
	   v-D2 = Day(v-dt).
	   if (v-D1 = v-D2 and v-M1 = v-M2 and v-Y2 > v-Y1) or (aaa.expdt <= v-dt) then do:
		v-ost = aaa.cr[1] - aaa.dr[1].
 		if v-ost <> 0 then do:
        		for each cif  where cif.cif = aaa.cif  /* and cif.type = "p" */ no-lock by name.
				find crc where crc.crc = aaa.crc no-lock no-error.
				if avail crc then do:
						        create t-table.
							assign t-table.name = cif.name
							       t-table.aaa = aaa.aaa
								t-table.rate = aaa.rate
								t-table.regdt = aaa.regdt		
								t-table.expdt = aaa.expdt
								t-table.ost = v-ost
								t-table.sta = aaa.sta
								t-table.crc = crc.code.
				end.	
	        	end.
		end.
	   end.
	end.
    end.
end.

v-i = 1.

for each t-table by t-table.expdt:
i = i + 1.

put  unformatted "<tr valign=top style=""background:" if v-i < 0 then "lightyellow" else "white" """>" skip.

	put unformatted
		"<td>" i "</td>" skip
		"<td>" t-table.name "</td>" skip 
		"<td>" t-table.aaa "</td>" skip
		"<td align=right>" t-table.rate format "zzz.99" "</td>" skip
		"<td>" t-table.regdt "</td>" skip
		"<td>" t-table.expdt "</td>" skip
		"<td align=right>" t-table.ost format "z,zzz,zzz,zzz,zzz.99" "</td>" skip
		"<td>" t-table.crc "</td>" skip
                "<td>" t-table.sta "</td></tr>" skip.
v-i = v-i * -1.
end.
{html-end.i " "}
output close.
unix silent cptwin value(v-file) iexplore.

pause 0.


