/* ink12.p
 * MODULE
        Клиенты и их счета
 * DESCRIPTION
        Остатки на внебалансовых счетах
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        8.9.5.12
 * AUTHOR
        27/09/2005 dpuchkov
 * CHANGES
	29.03.2006 u00121 - 	Оптимизировал запросы для отчета "По Менеджеру счета", 
				как результат, тест формирования отчета за год показал 40 сек., против нескольких часов по предыдущему алгоритму , 
				НАРОД, СРАЗУ ОПТИМИЗИРУЙТЕ СВОИ ПРОГРАММЫ!!! :))
*/

{global.i}

def var v-dp 	as integer init 0	no-undo.
def var v-dp1 	as integer init 0	no-undo.
def var v-dp2 	as integer init 0	no-undo.
def var v-gl 	as char			no-undo.
def var bal1 	as decimal		no-undo.
def var vlog 	as log init false	no-undo.
def var vst  	like jl.dam		no-undo.
def var ven  	like jl.dam		no-undo.
def var ven1  	like jl.dam		no-undo.
def var v-rem 	as char			no-undo. 
def var v-valut as char			no-undo. 
def var d_date1 as date			no-undo.
def var d_date2 as date			no-undo.
def var alsum 	as decimal		no-undo.
def var v1 	as decimal		no-undo.
def var v2 	as decimal		no-undo.
def var US 	as decimal		no-undo.
def var RR 	as decimal		no-undo.
def var EU 	as decimal		no-undo.
def var KZ	as decimal		no-undo.


def var list_manager as char		no-undo.
def stream vcrpt.


define temp-table user_vnebal	no-undo
       field  name as char
       field  acc as char
       field  dt1 as char
       field  sm1 as char
       field  dt2 as char
       field  sm2 as char
       field  crc as integer              
       field  ost as char.
 

d_date1 = g-today.
d_date2 = g-today.


run sel2 (" Параметры поиска", " По Менеджеру счета | По Центральному офису | ПО СПФ | По г.Алматы", output v-dp).
if v-dp = 0  then return.
if v-dp = 1 or v-dp = 3 then 
do:
	update d_date1 label "Дата с" with centered side-label row 10.
	update d_date2 label "по" with centered side-label row 10.
end.
else
do:
	update d_date1 label "Дата" with frame z2 centered side-label row 10.
end.

if v-dp = 1 then 
do:
	for each vnebal where usr begins "u" no-lock :
		list_manager = list_manager + string(vnebal.k2, "x(20)" ) + " " + trim(vnebal.gl) + "|".
	end.
	run sel2 ("Параметры поиска", list_manager, output v-dp1).
	for each vnebal where usr begins "u" no-lock :
		v-dp2 = v-dp2 + 1.
		if v-dp2 = v-dp1 then 
		do:
			v-gl = vnebal.gl.
			leave.
		end.
	end.
	displ "Ждите идет поиск...  " with frame z1 centered side-label row 11 no-box . 
end.



if v-dp = 3 then 
do: /*По СПФ*/
	for each vnebal where not usr begins "u" and not usr begins "T"  no-lock :
		list_manager = list_manager + string(vnebal.k2, "x(20)" ) + " " + trim(vnebal.gl) + "|".
	end.
	run sel2 ("Параметры поиска", list_manager, output v-dp1).
	for each vnebal where not usr begins "u" and not usr begins "T"  no-lock :
		v-dp2 = v-dp2 + 1.
		if v-dp2 = v-dp1 then 
		do:
			v-gl = vnebal.gl.
			leave.
		end.
	end.
	displ "Ждите идет поиск...  " with frame z1 centered side-label row 11 no-box.
end.



if v-dp = 2 or v-dp = 4 then 
do:
	if v-dp = 2 then 
	do:
		alsum = 0.
		for each vnebal where vnebal.usr begins "u" no-lock :
			for each crc no-lock where crc.sts ne 9 break by crc.crc: 
				find last glday where glday.gl eq integer(vnebal.gl)  and  glday.crc eq crc.crc and glday.gdt le d_date2 no-lock no-error.
				if avail glday then alsum = alsum + (glday.bal * crc.rate[1]).
			end.
		end.
		output stream vcrpt to vcreestr.htm.
			{html-title.i &stream   = " stream vcrpt " &title    = "Cпецинструкции" &size-add = "xx-"}
			put stream vcrpt unformatted
				"<P align = ""left""><img src=""http://www.texakabank.kz/images/top_logo_bw.gif""></P>"
				"<P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans""><B>Электронная ленточка по счетам Ц.О на " d_date1 "</B></FONT></P>" skip
				"<br>"
				"<br>"
				"<P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">Остаток на внебалансовых счетах Ц.О. составляет   " string(alsum, 'zzz,zzz,zzz,zz9.99') " тенге. </B></FONT></P>" skip.
				{html-end.i "stream vcrpt" }
		output stream vcrpt close.
	unix silent cptwin vcreestr.htm excel.
	end.

	if v-dp = 4 then 
	do:
		alsum = 0.
		for each vnebal where not vnebal.usr begins "TXB" no-lock :
			for each crc no-lock where crc.sts ne 9 break by crc.crc: 
				find last glday where  glday.gl eq integer(vnebal.gl) and glday.crc eq crc.crc and glday.gdt le d_date2 no-lock no-error.
				if avail glday then alsum = alsum + (glday.bal * crc.rate[1]).
			end.
		end.
		output stream vcrpt to vcreestr.htm.
			{html-title.i &stream   = " stream vcrpt " &title    = "Cпецинструкции" &size-add = "xx-"}
			put stream vcrpt unformatted
				"<P align = ""left""><img src=""http://www.texakabank.kz/images/top_logo_bw.gif""></P>"
				"<P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans""><B>Электронная ленточка по счетам г.Алматы на " d_date1 "</B></FONT></P>" skip
				"<br>"
				"<br>"
				"<P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">Остаток на внебалансовых счетах г.Алматы составляет   " string(alsum, 'zzz,zzz,zzz,zz9.99') " тенге. </B></FONT></P>" skip.
				{html-end.i "stream vcrpt" }
		output stream vcrpt close.
		unix silent cptwin vcreestr.htm excel.
	end.
end.




/* По менеджеру или по СПФ */
if v-dp = 1 or v-dp = 3 then 
do:
	if v-gl <> "" then 
	do:
		output stream vcrpt to vcreestr.htm.
			{html-title.i
			&stream   = " stream vcrpt "
			&title    = "Cпецинструкции"
			&size-add = "xx-"
			}
			put stream vcrpt unformatted
				"<P align = ""left""><img src=""http://www.texakabank.kz/images/top_logo_bw.gif""></P>"
				"<P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans""><B>Электронная ленточка по счету   " v-gl " с " d_date1 " по " d_date2 " </B></FONT></P>" skip
				"<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"" bordercolor=#000000>" skip.
			put stream vcrpt unformatted                                               
				"<TR align=""center"" valign=""bottom"" bordercolor=#000000 bgcolor=#FFFFE0>"                skip
				"<TD rowspan=2 ><FONT size=""2""><B>Наименование клиента</B></FONT></TD>"                    skip
				"<TD rowspan=2 ><FONT size=""2""><B>Счет клиента</B></FONT></TD>"                            skip
				"<TD colspan=2 ><FONT size=""2""><B>Дебет</B></FONT></TD>"                                   skip
				"<TD colspan=2 ><FONT size=""2""><B>Кредит</B></FONT></TD>"                                  skip
				"<TD rowspan=2 ><FONT size=""2""><B>ОСТАТОК</B></FONT></TD></TR>"                            skip
				"<TD bordercolor=#000000 bgcolor=#FFFFE0><FONT size=""2""><B>дата</B></FONT></TD>"           skip
				"<TD bordercolor=#000000 bgcolor=#FFFFE0><FONT size=""2""><B>сумма</B></FONT></TD>"          skip
				"<TD bordercolor=#000000 bgcolor=#FFFFE0><FONT size=""2""><B>дата</B></FONT></TD>"           skip
				"<TD bordercolor=#000000 bgcolor=#FFFFE0><FONT size=""2""><B>сумм</B></FONT></TD>"           skip
				"</TR>" skip.

			def var v-dt as date no-undo.
			find last gl where gl.gl eq integer(v-gl) no-lock no-error.
			if not avail gl then 
			do:
				message "Внебалансовый счет " v-gl " не найден в таблице счетов Г/К (gl)!" view-as alert-box.
				return.
			end.
			do v-dt = d_date1 to  d_date2:
				for each crc no-lock where crc.sts ne 9 break by crc.crc:
					displ v-dt string(v-gl) crc.code format "x(28)"  with frame z3 centered no-label row 12 no-box. pause 0.
					for each jl where jl.jdt eq v-dt and jl.gl = integer(v-gl) and jl.crc eq crc.crc no-lock break by jl.gl by jl.jdt .

						if jl.rem[1] matches '*внебалансовый ордер*' then  
							v-rem = jl.rem[2].  
						else 
							v-rem = jl.rem[1].
						accumulate jl.dam (total by jl.jdt) jl.cam (total by jl.jdt).

						find last aaa where aaa.aaa = jl.rem[1] no-lock no-error.
						if avail aaa then 
						do: 
							find last cif where cif.cif = aaa.cif no-lock no-error.
						end.


						create user_vnebal.
							user_vnebal.crc = jl.crc.
							if avail aaa and avail cif then 
							do:
								user_vnebal.name = cif.name.
								user_vnebal.acc = aaa.aaa.
							end. 
							else 
							do:
								user_vnebal.name = "".
								user_vnebal.acc = "".
							end.
							if jl.dam <> 0 then 
							do:
								user_vnebal.dt1 = string(jl.jdt).
								user_vnebal.sm1 = string(jl.dam).
								user_vnebal.dt2 = "".
								user_vnebal.sm2 = "".
							end. 
							else
							do:
								user_vnebal.dt1 = "".
								user_vnebal.sm1 = "".
								user_vnebal.dt2 = string(jl.jdt).
								user_vnebal.sm2 = string(jl.cam).
							end.
					end. /* for each jl */

					if gl.type eq "A" or gl.type eq "E" then 
						vlog = true.
					else 
						vlog = false.
					find last glday where glday.gdt lt d_date2 and glday.gl eq gl.gl and glday.crc eq crc.crc no-lock no-error.
					if available glday then 
					do:
						if (gl.type eq "R" or gl.type eq "E") and year(d_date1) ne year(glday.gdt) then 
							vst = 0.
						else 
						do.
							if vlog eq true then 
								vst = glday.dam - glday.cam.
							else 
								vst = glday.cam - glday.dam.
						end.
					end.
					ven = vst.
					if crc.crc = 1 then KZ = ven. 
						else
						if crc.crc = 2 then US = ven. 
						else
							if crc.crc = 4 then RR = ven. 
							else
								if crc.crc = 11 then EU = ven.
				end. /*for each crc*/
			end. /*do v-dt*/ 

			def var vac as char init "" no-undo.

			for each crc no-lock where crc.sts ne 9 break by crc.crc:
				find last user_vnebal where user_vnebal.crc = crc.crc no-lock no-error.
				if not avail user_vnebal then next.
				put stream vcrpt unformatted                                        
					"<TR align=""center"" valign=""bottom"" bordercolor=#d8e4f8 bgcolor=#808080>"   skip
					"<TD><FONT size=""2""><b>" + crc.des + "</b></FONT></TD>"       skip
					"<TD><FONT size=""2"">" + string(" ") + "</FONT></TD>"       skip
					"<TD><FONT size=""2"">" + string(" ") + "</FONT></TD>"       skip
					"<TD><FONT size=""2"">" + string(" ") + "</FONT></TD>"       skip
					"<TD><FONT size=""2"">" + string(" ") + "</FONT></TD>"       skip
					"<TD><FONT size=""2"">" + string(" ") + "</FONT></TD>"       skip
					"<TD><FONT size=""2"">" + string(" ") + "</FONT></TD>"       skip.
				vac = "".
				v1 = 0.
				for each user_vnebal where user_vnebal.crc = crc no-lock break by user_vnebal.name by user_vnebal.acc:
					if vac <> "" and vac <> user_vnebal.acc then 
					do:
						put stream vcrpt unformatted
							"<TR align=""center"" valign=""bottom"" bordercolor=#d8e4f8>" skip
							"<TD><FONT size=""2""><B>" + string("ИТОГО ОБОРОТЫ") + "</B></FONT></TD>"    skip
							"<TD><FONT size=""2"">" + string(" ") + "</FONT></TD>"        skip
							"<TD><FONT size=""2"">" + string(" ") + "</FONT></TD>"        skip
							"<TD><FONT size=""2"">" + string(" ") + "</FONT></TD>"        skip
							"<TD><FONT size=""2"">" + string(" ") + "</FONT></TD>"        skip
							"<TD><FONT size=""2"">" + string(" ") + "</FONT></TD>"        skip
							"<TD align=right><FONT size=""2""><B>" + replace(trim(string(dec(v1), "->>>>>>>>>>9.99")), ".", ",") + "</B></FONT></TD>" skip.
						v1 = 0.
					end. 
					v1 = v1 + (decimal(user_vnebal.sm1) - decimal(user_vnebal.sm2)).
					put stream vcrpt unformatted
						"<TR align=""center"" valign=""bottom"" bordercolor=#d8e4f8>"    skip.
					if user_vnebal.acc <> "" then 
					do:
						put stream vcrpt unformatted
							"<TD align=left><FONT size=""2"">" + user_vnebal.name + "</FONT></TD>" skip
							"<TD align=left><FONT size=""2"">" + "'" + user_vnebal.acc + "</FONT></TD>" skip.
					end.
					else
					do:
						put stream vcrpt unformatted
							"<TD><FONT size=""2"">" + string(" ") + "</FONT></TD>"  skip
							"<TD><FONT size=""2"">" + string(" ") + "</FONT></TD>"  skip.
					end.
					put stream vcrpt unformatted
						"<TD><FONT size=""2"">" + string(user_vnebal.dt1) + "</FONT></TD>"       skip
						"<TD align=right><FONT size=""2"">" + replace(trim(string(dec(user_vnebal.sm1), "->>>>>>>>>>9.99")), ".", ",") + "</FONT></TD>"       skip
						"<TD><FONT size=""2"">" + string(user_vnebal.dt2) + "</FONT></TD>"   skip
						"<TD align=right><FONT size=""2"">" + replace(trim(string(dec(user_vnebal.sm2), "->>>>>>>>>>9.99")), ".", ",") + "</FONT></TD>"      skip.
					put stream vcrpt unformatted
						"<TD><FONT size=""2"">" + string(" ") + "</FONT></TD>"  skip.
					vac = user_vnebal.acc.
				end.
				if vac <> "" then 
				do:
					put stream vcrpt unformatted
						"<TR align=""center"" valign=""bottom"" bordercolor=#d8e4f8>" skip
						"<TD><FONT size=""2""><B>" + string("ИТОГО ОБОРОТЫ") + "</B></FONT></TD>"    skip
						"<TD><FONT size=""2"">" + string(" ") + "</FONT></TD>"        skip
						"<TD><FONT size=""2"">" + string(" ") + "</FONT></TD>"        skip
						"<TD><FONT size=""2"">" + string(" ") + "</FONT></TD>"        skip
						"<TD><FONT size=""2"">" + string(" ") + "</FONT></TD>"        skip
						"<TD><FONT size=""2"">" + string(" ") + "</FONT></TD>"        skip
						"<TD align=right><FONT size=""2""><B>" + replace(trim(string(dec(v1), "->>>>>>>>>>9.99")), ".", ",") + "</B></FONT></TD>" skip.
					v1 = 0.
				end.
				put stream vcrpt unformatted                        
					"<TR align=""center"" valign=""bottom"" bordercolor=#d8e4f8>"   skip.
				if crc.crc = 1 then 
					put stream vcrpt unformatted
						"<TD><FONT size=""2""><B>" + string("ИТОГО ПО ТЕНГЕ") + "</B></FONT></TD>"       skip.
				if crc.crc = 2 then 
					put stream vcrpt unformatted
						"<TD><FONT size=""2""><B>" + string("ИТОГО ПО ДОЛЛАРАМ США") + "</B></FONT></TD>"       skip.
				if crc.crc = 4 then 
					put stream vcrpt unformatted
						"<TD><FONT size=""2""><B>" + string("ИТОГО ПО РОССИЙСКИМ РУБЛЯМ") + "</B></FONT></TD>"       skip.
				if crc.crc = 11 then 
					put stream vcrpt unformatted
						"<TD><FONT size=""2""><B>" + string("ИТОГО ПО ЕВРО") + "</B></FONT></TD>"       skip.
				put stream vcrpt unformatted
					"<TD><FONT size=""2"">" + string(" ") + "</FONT></TD>"       skip
					"<TD><FONT size=""2"">" + string(" ") + "</FONT></TD>"       skip
					"<TD><FONT size=""2"">" + string(" ") + "</FONT></TD>"       skip
					"<TD><FONT size=""2"">" + string(" ") + "</FONT></TD>"       skip
					"<TD><FONT size=""2"">" + string(" ") + "</FONT></TD>"       skip.
				if crc.crc = 1 then 
					put stream vcrpt unformatted
						"<TD align=right><FONT size=""2""><B>" + replace(trim(string(dec(KZ), "->>>>>>>>>>9.99")), ".", ",") + "</B></FONT></TD>"       skip.
				if crc.crc = 2 then 
					put stream vcrpt unformatted
						"<TD align=right><FONT size=""2""><B>" + replace(trim(string(dec(US), "->>>>>>>>>>9.99")), ".", ",") + "</B></FONT></TD>"       skip.
				if crc.crc = 4 then 
					put stream vcrpt unformatted
						"<TD align=right><FONT size=""2""><B>" + replace(trim(string(dec(RR), "->>>>>>>>>>9.99")), ".", ",") + "</B></FONT></TD>"       skip.
				if crc.crc = 11 then 
					put stream vcrpt unformatted
						"<TD align=right><FONT size=""2""><B>" + replace(trim(string(dec(EU), "->>>>>>>>>>9.99")), ".", ",") + "</B></FONT></TD>"       skip.
			end.

			for each crc no-lock:
				if crc.crc = 2 then   US = US * crc.rate[1].
				if crc.crc = 4 then   RR = RR * crc.rate[1].
				if crc.crc = 11 then  EU = EU * crc.rate[1].
			end.

			v2 = KZ + US + EU + RR.

			put stream vcrpt unformatted
				"<TR align=""center"" valign=""bottom"" bordercolor=#d8e4f8>"   skip
				"<TD><FONT size=""2""><B>" + string("ИТОГО ПО СЧЕТУ ") + "</B></FONT></TD>"       skip
				"<TD><FONT size=""2"">" + string(" ") + "</FONT></TD>"       skip
				"<TD><FONT size=""2"">" + string(" ") + "</FONT></TD>"       skip
				"<TD><FONT size=""2"">" + string(" ") + "</FONT></TD>"       skip
				"<TD><FONT size=""2"">" + string(" ") + "</FONT></TD>"       skip
				"<TD><FONT size=""2"">" + string(" ") + "</FONT></TD>"       skip
				"<TD align=right><FONT size=""2""><B>" + replace(trim(string(dec(v2), "->>>>>>>>>>9.99")), ".", ",")  + "</B></FONT></TD>"       skip.

			{html-end.i "stream vcrpt" }
		output stream vcrpt close.
		unix silent cptwin vcreestr.htm excel.
	end.
end.














