/* r-prod.p
 * MODULE
        Доходы-расходы в разрезе продуктов (депозиты)
 * DESCRIPTION
        Доходы-расходы в разрезе продуктов (депозиты)
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        codsdat.p
 * MENU
        8-7-3-15
 * AUTHOR
        14/06/2006 nataly
 * CHANGES
        17/07/2006 nataly добавлен расчет по кредитам
        19/07/2006 nataly добавлен счет 2240
        31/07/2006 madiyar - кредиты юр.лиц - все в подразделение '205' (кредитный департамент ЦО)
        03/08/2006 madiyar - кредиты физ.лиц в ЦО (которые попадают на операционку) - все в подразделение '207' (ДПК)
        06/09/2006 madiyar - проценты по кредитам = (нач + получ на конец) - (нач + получ на начало)
        08/09/2006 madiyar - подправил мелкие ошибки
        23/10/2006 nataly  - доработали алгоритм по расчету средних остатков за месяц
        10/11/2006 Sergey  - исправил "звёзды"
*/

def var v-bal as decimal no-undo.
def var v-bal-per as decimal no-undo.
def var v-balend as decimal no-undo.
def var v-proc as decimal no-undo.
def var v-proc-per as decimal no-undo.
def var v-proc_st as decimal no-undo.
def var v-proc_end as decimal no-undo.
def var v-percent as decimal no-undo.
def var v-percent-per as decimal no-undo.
def var v-gl as char init ["2215,2217,2219,2223,2206,2207,2208,2240"] no-undo.

def var vdt as date no-undo.
def var v-srok as integer no-undo.
def var v-srok1 as integer no-undo.
def var v-srokname as char extent 4 init ["От 1 мес до 3 мес", "От 3 мес до 6 мес", "От 6 мес до 1 года", "Свыше 1 года"] no-undo.

def var months as char extent 12 init ["январь", "февраль", "март", "апрель", "май", "июнь", "июль", "август", "сентябрь","октябрь", "ноябрь", "декабрь"] no-undo.

def stream vcrpt.
def buffer b-histrxbal for histrxbal.
def var v-day as integer no-undo.
def var v-dep as char no-undo.
def var v-bank as char no-undo.

def var dt_st as date no-undo.
def var dt_st-per as date no-undo.
def var dt_end as date no-undo.

def temp-table temp no-undo
    field crc   like bank.crc.crc
    field gl    like gl.gl
    field srok  as integer
    field lgr   like lgr.lgr
    field priz      as char     /*ЮЛ-ФЛ*/
    field dep   as char
    field depname   as char
    field bal   as decimal
    field balend    as decimal
    field proc      as decimal
    field bal-per   as decimal
    field proc-per      as decimal
    field gr-name like sysc.des
	field mon as integer
index gl is primary gl crc lgr srok dep
index temp-idx1 priz srok lgr dep.

def buffer temp1 for temp.

				/* --------------------------------------------------- */
def temp-table tgl1 no-undo
    field gl like gl.gl
    field dt as date
    field bal as decimal
    field proc as decimal.

def temp-table tgl2 no-undo
    field gl like gl.gl
    field mon as integer
    field bal as decimal
    field proc as decimal.
				/* --------------------------------------------------- */


def var v-gr-name like temp.gr-name.

/*def var sumbal as decimal no-undo.
def var sumbal-per as decimal no-undo.
def var sumbalend as decimal no-undo.
def var sumproc as decimal no-undo.
def var sumproc-per as decimal no-undo.
def var sumpercent as decimal no-undo.
def var sumpercent-per as decimal no-undo.
*/
def var b as logical.
def var i-index as integer.

def stream rpt.

def shared var v-mon as integer no-undo.
def shared var v-god as integer no-undo.
def shared var v-report-type as integer.
def shared var v-des like cods.des label "Наименование".
def shared var v-dep-code as char no-undo.


{getdep.i}


output stream rpt to 'sredn.txt'.

run  mondays(v-mon,v-god,output v-day)  .


displ string(time,('hh:mm:ss')).

find cmp no-lock no-error.
if avail cmp then v-bank = cmp.name.     

/**/

def var i as integer.



for each gl where gl.totlev = 1 and lookup(substr(string(gl.gl),1,4),v-gl) > 0 :
for each aaa no-lock  where aaa.gl = gl.gl  /*and aaa.aaa = '001714140'*/.
    v-bal = 0. v-balend = 0. v-proc = 0. v-srok = 0. v-srok1 = 0. v-dep = ''.

        find last cif where cif.cif = aaa.cif no-lock no-error. /*u00121 last*/
        
	v-dep = getdep(aaa.cif).
	if v-report-type = 2 then 
		v-dep = ''.
	if v-report-type = 3 and v-dep-code <> v-dep then 
	do:
		next.
	end.

        v-srok = round((aaa.expdt - aaa.regdt) * 12 / 365 , 0).
            if v-srok < 3 then v-srok1 = 1.
            else  
                if v-srok >= 3 and v-srok < 6 then v-srok1 = 2.
                else  
                    if v-srok >= 6 and v-srok < 12 then v-srok1 = 3.
                    else  
                        v-srok1 = 4.

	if (v-report-type = 1) then
	    assign 
		dt_st-per = date(v-mon,1,v-god) 
		dt_st = date(v-mon,1,v-god) 
		dt_end = date(v-mon,v-day,v-god).
	else
	    assign 
		dt_st-per = date(1,1,v-god) 
		dt_st = date(v-mon,1,v-god) 
		dt_end = date(v-mon,v-day,v-god).

        do vdt =  dt_st-per to dt_end.
            v-bal = 0. v-balend = 0. v-proc = 0.
            v-proc-per = 0.

              find last histrxbal where histrxbal.acc = aaa.aaa and histrxbal.lev = 1 
                       and histrxbal.subled  = 'cif'  and histrxbal.crc =  aaa.crc and histrxbal.dt <= vdt no-lock no-error.
              if avail histrxbal then do:
	            find last crchis where crchis.crc = aaa.crc and crchis.regdt <= vdt use-index crchis-idx1 no-lock no-error.
			v-bal = (histrxbal.cam - histrxbal.dam) * crchis.rate[1]. /*за каждый день */
                	if vdt = dt_end then
				v-balend = v-bal. /*берем остаток только за последний день*/
              end.

	 if vdt = dt_st then do:
			if v-mon = 1 then
				v-proc_st = 0. /* Для января процентные расходы на начало месяца должны быть равны нулю*/
			else if v-mon <> 1 then
			do:
                                   for each crc where crc.crc = 1 or crc.crc = 2 or crc.crc = 4 or crc.crc = 11.
				find last histrxbal where histrxbal.acc = aaa.aaa and  histrxbal.lev = 11
					and histrxbal.subled  = 'cif' and histrxbal.crc =  crc.crc and histrxbal.dt < vdt no-lock no-error.
				if avail histrxbal then do:
			            find last crchis where crchis.crc = crc.crc and crchis.regdt <= vdt use-index crchis-idx1 no-lock no-error.
					v-proc_st = v-proc_st +  (histrxbal.dam - histrxbal.cam) * crchis.rate[1].
				end.
			    end.
			end.
		end. /*dt_st*/
		else if vdt = dt_end then do:
                                for each crc where crc.crc = 1 or crc.crc = 2 or crc.crc = 4 or crc.crc = 11.
					find last histrxbal where histrxbal.acc = aaa.aaa and  histrxbal.lev = 11
					and histrxbal.subled  = 'cif' and histrxbal.crc =  crc.crc and histrxbal.dt <= vdt no-lock no-error.
				if avail histrxbal then do:
			            find last crchis where crchis.crc = crc.crc and crchis.regdt <= vdt use-index crchis-idx1 no-lock no-error.
					v-proc_end = v-proc_end +  (histrxbal.dam - histrxbal.cam) * crchis.rate[1].
				end.
			end.
/*			v-proc_end = histrxbal.dam - histrxbal.cam.*/
			v-proc = v-proc_end - v-proc_st. /*берём проценты как разницу между начислениями последних дней текущего и прошлого месяцев.*/
			v-proc-per = v-proc_end - 0. /*берём проценты как начисления на последний день периода (так как начало периода - это начало года, т.е. начисления на начало равны нулю).*/
			v-proc_st = 0.                                                                                        
			v-proc_end = 0.

		end. /*dt_end*/

/*            if v-bal = 0 and v-proc = 0 and v-proc-per = 0 then do: /*message 'aaa' aaa.aaa histrxbal.lev vdt v-bal v-proc.*/  next. end.
  */
            


				/* --------------------------------------------------- */
							find last tgl1 where tgl1.gl = aaa.gl and tgl1.dt = vdt no-lock no-error.
							if not avail(tgl1) then do:
								create tgl1.
								assign 
									tgl1.gl = aaa.gl
									tgl1.dt = vdt
									tgl1.bal = v-bal
									tgl1.proc = v-proc-per
								.
							end.
							else do:
								tgl1.bal = tgl1.bal + v-bal.
								tgl1.proc = tgl1.proc + v-proc-per.
							end.
				/* --------------------------------------------------- */



	    v-gr-name = ''.
	    if v-report-type <> 1 then
	    do:
        	if cif.type <> 'b' then /* cif.type is temp.priz */
		do:
			find first sysc no-lock where (sysc.sysc begins  'k-lg').
			b = False.
			repeat while (avail(sysc)) and (not (b)):
				b = (index(sysc.chval, aaa.lgr) > 0).
				if (not (b)) then 
					find next sysc no-lock where (sysc.sysc begins  'k-lg').
			end.
			if (avail(sysc)) then 
				v-gr-name = sysc.des.
	 		else
				v-gr-name = 'Прочие'.
		end.
/*		if v-report-type = 2 then
*/			find last temp where temp.gl = aaa.gl and temp.crc = aaa.crc and temp.gr-name = v-gr-name and temp.srok = v-srok1 and temp.mon = month(vdt) no-error.
/*		else
			find last temp where temp.gl = aaa.gl and temp.crc = aaa.crc and temp.gr-name = v-gr-name and temp.srok = v-srok1 and temp.mon = month(vdt) and temp.dep = v-dep no-error.
*/	    end.
	    else if v-report-type = 1 then
		find last temp where temp.gl = aaa.gl and temp.crc = aaa.crc and temp.lgr = aaa.lgr and temp.srok = v-srok1 and temp.dep = v-dep no-error.

            if not avail temp then do:
                create temp.
                assign 
                    temp.gl   = aaa.gl
                    temp.crc  = aaa.crc
                    temp.gr-name  = v-gr-name
		    temp.lgr = aaa.lgr
                    temp.srok = v-srok1
                    temp.dep  = v-dep 
                    temp.priz = cif.type
		    temp.mon = month(vdt).
		find last codfr where codfr.codfr = 'sdep' and codfr.code = temp.dep no-lock no-error.
		if avail codfr then
			temp.depname = codfr.name[1].
            end.

		temp.proc = temp.proc + v-proc.
		temp.balend = temp.balend + v-balend.
		temp.proc-per = temp.proc-per + v-proc-per.
		temp.bal = temp.bal + v-bal.
		run mondays(month(vdt), v-god, output i).
		temp.bal-per = temp.bal-per + (v-bal / i).
/*		if day(vdt + 1) = 1 then /* Если сейчас конец месяца, то ... */
			temp.bal-per = temp.bal-per + (temp.bal / day(vdt)). /* ...добавляем к данным за период средние данные за месяц */
*/	
/*		/*считаем итого*/	       
		sumproc = sumproc + v-proc.
		sumbalend = sumbalend + v-balend.
		sumproc-per = sumproc-per + v-proc-per.
		if month(vdt) = v-mon then
			sumbal = sumbal + v-bal.
		if day(vdt + 1) = 1 then /* Если сейчас конец месяца, то ... */
		do:
			sumbal-per = sumbal-per + (sumbal / day(vdt)). /* ...добавляем к данным за период средние данные за месяц */
			if month(vdt) <> v-mon then /* Если это не запрошенный месяц, то... */
				sumbal = 0. /* ...обнуляем его */
		end.
*/		       
        end. /*по датам*/
   /* end. /*lookup*/*/
end.  /*aaa*/
end.

				/* --------------------------------------------------- */
do i = 1 to v-mon:
	run mondays(i, v-god, output v-day).
	do vdt = date(i, 1, v-god) to date(i, v-day, v-god):
		for each tgl1 where tgl1.dt = vdt no-lock:
			find last tgl2 where tgl2.gl = tgl1.gl and tgl2.mon = i no-lock no-error.
			if not avail tgl2 then
			do:
				create tgl2.
				assign 
					tgl2.gl = tgl1.gl
					tgl2.mon = i.
			end.
			tgl2.bal = tgl2.bal + (tgl1.bal / v-day).
			tgl2.proc = tgl2.proc + tgl1.proc.
		end.
	end.
end.

for each tgl1 no-lock break by tgl1.gl.
	accum tgl1.bal (total by tgl1.gl).

	put stream rpt  
		tgl1.gl ' ' 
		tgl1.dt ' '
		(tgl1.bal /*  / (dt_end - dt_st + 1) */) format 'zzz,zzz,zzz,zz9.99' ' ' 
		(tgl1.proc /*  / (dt_end - dt_st + 1) */) format 'zzz,zzz,zzz,zz9.99' ' ' 
		skip.

	if last-of(tgl1.gl) then 
	do:
		put stream rpt  
			tgl1.gl ' ' 
			tgl1.dt ' '
			((accum total by tgl1.gl tgl1.bal) / (dt_end - dt_st-per + 1)) format 'zzz,zzz,zzz,zz9.99' ' ' 
			'       итого       '
			skip 
			' ' skip.
	end.
end.

put stream rpt unformatted
	' ' skip
	' -------------------- ' skip
	' ' skip.

for each tgl2 no-lock break by tgl2.gl.
	accum tgl2.bal (total by tgl2.gl).
	accum tgl2.proc (total by tgl2.gl).

	put stream rpt  
		tgl2.gl ' ' 
		'месяц ї' tgl2.mon ' '
		(tgl2.bal) format 'zzz,zzz,zzz,zz9.99' ' ' 
		(tgl2.proc) format 'zzz,zzz,zzz,zz9.99' ' ' 
		skip.

	if last-of(tgl2.gl) then 
	do:
		put stream rpt  
			tgl2.gl ' ' 
			'       итого      '
			((accum total by tgl2.gl tgl2.bal) / v-mon) format 'zzz,zzz,zzz,zz9.99' ' ' 
			(accum total by tgl2.gl tgl2.proc) format 'zzz,zzz,zzz,zz9.99' ' ' 
			skip 
			' ' skip.
	end.
end.
				/* --------------------------------------------------- */


 /* Чтобы остатки получились действительно средними за месяц, разделим их на количество дней в этом месяце. */
/*sumbal-per = sumbal-per / v-mon. /* Делим на количество месяцев, так как здесь сумма средних на каждый месяц */
sumbal = sumbal / (dt_end - dt_st + 1).*/
for each temp.
	temp.bal-per = temp.bal-per / v-mon. /* Здесь то же самое */
	temp.bal = temp.bal / (dt_end - dt_st + 1).
end.

do i = 1 to v-mon - 1:
	for each temp where temp.mon = i no-lock break by temp.priz  by temp.srok by temp.crc by temp.gr-name.
		find last temp1 where temp1.gl = temp.gl and temp1.crc = temp.crc and temp1.gr-name = temp.gr-name and temp1.srok = temp.srok and temp1.mon = v-mon no-error.
		temp1.bal-per = temp1.bal-per + temp.bal-per.
		put stream rpt unformatted
			'temp1.gl = ' temp.gl skip 
			'temp1.crc = ' temp.crc skip 
			'temp1.gr-name = ' temp.gr-name skip 
			'temp1.srok = ' temp.srok skip 
			'temp.mon = ' temp.mon skip
			'temp1.bal-per = ' temp1.bal-per ' + ' temp.bal-per skip
			' ' skip.
	end.
end.


/*-----------------------------------------------------------------*/
/*		put stream rpt unformatted
			' ' skip
			'//------------------------' skip
			' ' skip.*/


output stream vcrpt to 'product.html'. 
{html-title.i &stream = " stream vcrpt " &title = " " &size-add = "xx-"}

put stream vcrpt unformatted 
   "<p><B>"  v-bank  +  ".<br>Отчет о средних остатках"  + " за  " + months[integer(v-mon)]  " " + string(v-god) " года" "</B></p>" skip.


    if v-report-type = 1 then do:
put stream vcrpt unformatted
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" 
   "<TR align=""center"">" 
     "<TD><FONT size=""1""><B>Счет ГК</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Номер группы депозита</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Наименование депозита</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Срок</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Валюта</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Департамент</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Средние остатки за месяц</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Остатки на конец месяца</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Процентные расходы</B></FONT></TD>" skip.
put stream vcrpt unformatted
   "</TR>" skip.

for each temp no-lock break by temp.priz  by temp.srok /*by temp.crc*/ by temp.lgr by temp.dep.

	accum temp.bal (total   by temp.srok /*by temp.crc*/ by temp.lgr by temp.dep).
	accum temp.proc (total  by temp.srok /*by temp.crc*/ by temp.lgr by temp.dep).
	accum temp.balend (total   by temp.srok /*by temp.crc*/ by temp.lgr by temp.dep).


    if first-of(temp.priz) then 
    do: 
        if temp.priz = 'b'  then 
           put stream vcrpt unformatted
             "<TR valign=""top""><TD colspan = 9 align = ""center""><b> Корпоративные клиенты </b></TD></TR>" skip.
        else 
           put stream vcrpt unformatted
             "<TR valign=""top""><TD colspan = 9 align = ""center""><b> Физические лица </b></TD></TR>" skip.
    end.


	if first-of(temp.srok) then 
	do: 
           put stream vcrpt unformatted
             "<TR valign=""top""><TD colspan = 9 align = ""center""><b>" v-srokname[temp.srok]  "</b></TD></TR>" skip.
	end.
	if last-of(temp.dep) then 
	do:
		find last lgr where lgr.lgr = temp.lgr no-lock no-error. /*u00121 last*/
		find crc where crc.crc = temp.crc no-lock no-error.
		put stream vcrpt unformatted
			"<TR valign=""top""><TD>" temp.gl  "</TD>" skip
			"<TD>"  temp.lgr  "</TD>" skip
			"<TD>"  lgr.des  "</TD>" skip
			"<TD>"  v-srokname[temp.srok]  "</TD>" skip
			"<TD>"  crc.code  "</TD>" skip
			"<TD>"  temp.dep "</TD>" skip
			"<TD>" replace(string((accum total by temp.dep temp.bal )/* / v-day*/,"-zzzzzzzzzzzzz9.99"),".",",")  "</TD>" skip
			"<TD>" replace(string((accum total by temp.dep temp.balend )  ,"-zzzzzzzzzzzzz9.99"),".",",")  "</TD>" skip
			"<TD>" replace(string((accum total by temp.dep temp.proc )/*/* / v-day*/*/,"-zzzzzzzzzzzzz9.99"),".",",")   "</TD>" skip.
		put stream vcrpt unformatted
			"</TR>" skip.
	end. /*dep*/

	if last-of(temp.lgr) then 
	do:

	find last lgr where lgr.lgr = temp.lgr no-lock no-error. /*u00121 last*/
		put stream vcrpt unformatted
			"<TR valign=""top""><TD><b>  ИТОГО по группе  </b></TD>" skip
			"<TD><b>"  temp.lgr  "</b></TD>" skip
			"<TD>  &nbsp  </TD>" skip
			"<TD>  &nbsp  </TD>" skip
			"<TD>  &nbsp  </TD>" skip
			"<TD>  &nbsp </TD>" skip
			"<TD><b>"  replace(string((accum total by temp.lgr temp.bal )/* / v-day*/,"-zzzzzzzzzzzzz9.99"),".",",")   "</b></TD>" skip
			"<TD><b>"  replace(string((accum total by temp.lgr temp.balend ) ,"-zzzzzzzzzzzzz9.99"),".",",")       "</b></TD>" skip
			"<TD><b>"  replace(string((accum total by temp.lgr temp.proc )/*/* / v-day*/*/,"-zzzzzzzzzzzzz9.99"),".",",")          "</b></TD>" skip.
		put stream vcrpt unformatted
			"</TR>" skip.
	end.
end. 

/*          put stream vcrpt unformatted
            "<TR valign=""top""><TD><b>  &nbsp  </b></TD>" skip
              "<TD><b>  &nbsp  </b></TD>" skip
              "<TD>  &nbsp  </TD>" skip
              "<TD>  &nbsp  </TD>" skip
              "<TD>  &nbsp  </TD>" skip
              "<TD>  ИТОГО </TD>" skip
              "<TD><b>"  replace(string((sumbal ) / v-day,"-zzzzzzzzzzzzz9.99"),".",",")   "</b></TD>" skip
              "<TD><b>"  replace(string((sumbalend ) ,"-zzzzzzzzzzzzz9.99"),".",",")       "</b></TD>" skip
              "<TD><b>"  replace(string((sumproc )/* / v-day*/,"-zzzzzzzzzzzzz9.99"),".",",")          "</b></TD>" skip.
          put stream vcrpt unformatted
            "</TR>" skip.
*/
    end.
    else if v-report-type = 2 or v-report-type = 3 then do:

put stream vcrpt unformatted
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" 
   "<TR align=""center"">" 
     "<TD rowspan=""2""><FONT size=""1""><B>Счет ГК</B></FONT></TD>" skip
     "<TD rowspan=""2""><FONT size=""1""><B>Номер группы депозита</B></FONT></TD>" skip
     "<TD rowspan=""2""><FONT size=""1""><B>Наименование депозита</B></FONT></TD>" skip.


if v-report-type = 2 then 
do:
	put stream vcrpt unformatted
		"<TD colspan=""7""><FONT size=""1""><B> Сводный отчет по департаментам. </B></FONT></TD>" skip.
end.
else if v-report-type = 3 then
do:
	find first temp no-lock.
	put stream vcrpt unformatted
		"<TD colspan=""7""><FONT size=""1""><B>" temp.dep ' ' temp.depname "</B></FONT></TD>" skip.
end.

  put stream vcrpt unformatted
   "</TR>" skip
   "<TR align=""center"">" skip.

  put stream vcrpt unformatted
     "<TD><FONT size=""1""><B>Средние остатки за месяц</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Процентные расходы за месяц</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>% (за месяц)</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Средние остатки за период с начала года (нарастающим итогом)</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Процентные расходы за период</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>% (за период)</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Остатки на конец месяца</B></FONT></TD>" skip.

  put stream vcrpt unformatted
   "</TR>" skip
   "<TR align=""center"">" skip.

do i-index = 1 to 10.
  put stream vcrpt unformatted
     "<TD><FONT size=""1"">" string(i-index, "zz9") "</FONT></TD>" skip.
end.

put stream vcrpt unformatted
   "</TR>" skip.

for each temp where temp.mon = v-mon no-lock break /*by temp.dep*/ by temp.priz  by temp.srok by temp.crc by temp.gr-name.

	accum temp.bal (total   /*by temp.dep*/ by temp.srok by temp.crc by temp.gr-name).
	accum temp.proc (total  /*by temp.dep*/ by temp.srok by temp.crc by temp.gr-name).
	accum temp.bal-per (total   /*by temp.dep*/ by temp.srok by temp.crc by temp.gr-name).
	accum temp.proc-per (total  /*by temp.dep*/ by temp.srok by temp.crc by temp.gr-name).
	accum temp.balend (total   /*by temp.dep*/ by temp.srok by temp.crc by temp.gr-name).


    if first-of(temp.priz) then 
    do: 
        if temp.priz = 'b'  then 
           put stream vcrpt unformatted
		"<TR valign=""top"">" skip
		"	<TD>   &nbsp;   </TD>" skip
		"	<TD>   &nbsp;   </TD>" skip
		"	<TD align = ""center""><b> Корпоративные клиенты </b></TD>" skip
		"</TR>" skip.
        else 
           put stream vcrpt unformatted
		"<TR valign=""top"">" skip
		"	<TD>   &nbsp;   </TD>" skip
		"	<TD>   &nbsp;   </TD>" skip
		"	<TD align = ""center""><b> Физические лица </b></TD>" skip
		"</TR>" skip.
    end.


	if first-of(temp.srok) then 
	do: 
		put stream vcrpt unformatted
		"<TR valign=""top"">" skip
		"	<TD>   &nbsp;   </TD>" skip
		"	<TD>   &nbsp;   </TD>" skip
		"	<TD align = ""center""><i><b>" v-srokname[temp.srok]  "</b></i></TD>" skip
		"</TR>" skip.
	end.

	if first-of(temp.crc) then 
	do: 
		find crc where crc.crc = temp.crc no-lock no-error.
		put stream vcrpt unformatted
		"<TR valign=""top"">" skip
		"	<TD>   &nbsp;   </TD>" skip
		"	<TD>   &nbsp;   </TD>" skip
		"	<TD align = ""center""><font color=""blue""><i>" crc.code  "</i></TD>" skip
		"</TR>" skip.
	end.

	if last-of(temp.gr-name) then 
	do:
		v-bal = (accum total by temp.gr-name temp.bal )/* / v-day*/.
		v-proc = (accum total by temp.gr-name temp.proc )/*/* / v-day*/*/.
		if v-bal <> 0 then
			v-percent = (v-proc / v-bal) * 12 * 100. /* Проценты считаем здесь, так как аккумулировать их нельзя */
		else 
			v-percent = 0.
		v-bal-per = (accum total by temp.gr-name temp.bal-per )/* / v-day*/.
		v-proc-per = (accum total by temp.gr-name temp.proc-per )/*/* / v-day*/*/.
		if v-bal-per <> 0 then
			v-percent-per = (v-proc-per / v-bal-per) * 12 * 100 / v-mon. /* Проценты считаем здесь, так как аккумулировать их нельзя */
		else 
			v-percent-per = 0.
		v-balend = (accum total by temp.gr-name temp.balend )/* / v-day*/.
		find last lgr where lgr.lgr = temp.lgr no-lock no-error. /*u00121 last*/
		find crc where crc.crc = temp.crc no-lock no-error.
		put stream vcrpt unformatted
			"<TR valign=""top"">" skip
			"	<TD>   &nbsp;   </TD>" skip
			"	<TD>   &nbsp;   </TD>" skip
			"	<TD>"  temp.gr-name  "</TD>" skip
			"	<TD>" replace(string(v-bal,"-zzzzzzzzzzzzz9.99"),".",",")  "</TD>" skip
			"	<TD>" replace(string(v-proc,"-zzzzzzzzzzzzz9.99"),".",",")   "</TD>" skip
			"	<TD>" replace(string(v-percent,"-zzzzzzzzzzzzz9.99"),".",",")   " %</TD>" skip
			"	<TD>" replace(string(v-bal-per,"-zzzzzzzzzzzzz9.99"),".",",")  "</TD>" skip
			"	<TD>" replace(string(v-proc-per,"-zzzzzzzzzzzzz9.99"),".",",")   "</TD>" skip
			"	<TD>" replace(string(v-percent-per,"-zzzzzzzzzzzzz9.99"),".",",")   " %</TD>" skip
			"	<TD>" replace(string(v-balend,"-zzzzzzzzzzzzz9.99"),".",",")  "</TD>" skip
			"</TR>" skip.
	end. /*dep*/
end. 

	v-bal = (accum total temp.bal )/* / v-day*/.
	v-proc = (accum total temp.proc )/*/* / v-day*/*/.
	if v-bal <> 0 then
		v-percent = (v-proc / v-bal) * 12 * 100. /* Проценты считаем здесь, так как аккумулировать их нельзя */
	else 
		v-percent = 0.
	v-bal-per = (accum total temp.bal-per )/* / v-day*/.
	v-proc-per = (accum total temp.proc-per )/*/* / v-day*/*/.
	if v-bal-per <> 0 then
		v-percent-per = (v-proc-per / v-bal-per) * 12 * 100 / v-mon. /* Проценты считаем здесь, так как аккумулировать их нельзя */
	else 
		v-percent-per = 0.
	v-balend = (accum total temp.balend )/* / v-day*/.
	find last lgr where lgr.lgr = temp.lgr no-lock no-error. /*u00121 last*/
	find crc where crc.crc = temp.crc no-lock no-error.
	put stream vcrpt unformatted
		"<TR valign=""top"">" skip
		"	<TD>   &nbsp;   </TD>" skip
		"	<TD>   &nbsp;   </TD>" skip
		"	<TD><b>  ИТОГО </b></TD>" skip
		"	<TD>" replace(string(v-bal,"-zzzzzzzzzzzzz9.99"),".",",")  "</TD>" skip
		"	<TD>" replace(string(v-proc,"-zzzzzzzzzzzzz9.99"),".",",")   "</TD>" skip
		"	<TD>" replace(string(v-percent,"-zzzzzzzzzzzzz9.99"),".",",")   " %</TD>" skip
		"	<TD>" replace(string(v-bal-per,"-zzzzzzzzzzzzz9.99"),".",",")  "</TD>" skip
		"	<TD>" replace(string(v-proc-per,"-zzzzzzzzzzzzz9.99"),".",",")   "</TD>" skip
		"	<TD>" replace(string(v-percent-per,"-zzzzzzzzzzzzz9.99"),".",",")   " %</TD>" skip
		"	<TD>" replace(string(v-balend,"-zzzzzzzzzzzzz9.99"),".",",")  "</TD>" skip
		"</TR>" skip.

/*	if sumbal <> 0 then
		sumpercent = (sumproc / sumbal) * 12 * 100. /* Эти проценты можно было и раньше посчитать, но считаеми здесь для наглядности */
	else 
		sumpercent = 0.
	if sumbal-per <> 0 then
		sumpercent-per = (sumproc-per / sumbal-per) * 12 * 100 / v-mon. /* Эти проценты можно было и раньше посчитать, но считаеми здесь для наглядности */
	else 
		sumpercent-per = 0.

	put stream vcrpt unformatted
		"<TR valign=""top"">" skip
		"	<TD>  &nbsp  </TD>" skip
		"	<TD>  &nbsp  </TD>" skip
		"	<TD><b>  ИТОГО </b></TD>" skip
		"	<TD><b>"  replace(string((sumbal ),"-zzzzzzzzzzzzz9.99"),".",",")     "</b></TD>" skip
		"	<TD><b>"  replace(string((sumproc ),"-zzzzzzzzzzzzz9.99"),".",",")    "</b></TD>" skip
		"	<TD><b>"  replace(string((sumpercent ),"-zzzzzzzzzzzzz9.99"),".",",") " %</b></TD>" skip
		"	<TD><b>"  replace(string((sumbal-per ),"-zzzzzzzzzzzzz9.99"),".",",")     "</b></TD>" skip
		"	<TD><b>"  replace(string((sumproc-per ),"-zzzzzzzzzzzzz9.99"),".",",")    "</b></TD>" skip
		"	<TD><b>"  replace(string((sumpercent-per ),"-zzzzzzzzzzzzz9.99"),".",",") " %</b></TD>" skip
		"	<TD><b>"  replace(string((sumbalend ) ,"-zzzzzzzzzzzzz9.99"),".",",")       "</b></TD>" skip
		"</TR>" skip.
*/    end.



put stream vcrpt unformatted
  "</TABLE><br><br>" skip.


 displ string(time,('hh:mm:ss')). 

{html-end.i " stream vcrpt "}

output stream vcrpt close.
output stream rpt close.

  unix silent value("cptwin product.html excel").

pause 0.
    