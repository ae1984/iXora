/* casher7.p
 * MODULE
        Отчеты
 * DESCRIPTION
         Отчет по сегодняшним транзакциям офицера
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        5-1-12-1
 * AUTHOR
        31/12/99 pragma
 * BASES
        BANK COMM
 * CHANGES
       	07.03.2004 sasco - поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
	04/06/03 nataly  - показывает отчет по проводкам с кассы и со счета 100200, где фигурирует слово "обмен"
	30/05/06 u00121  - Отчет для Алматинских РКО формируется только по кассе в пути, т.к. они работают только через кассу в пути (ТЗ ї 220 от 17/01/06)
	01/06/06 u00121  - внес проверку на sysc CASOFC и CASSOF
    02.03.12 damir - вывод формы в формате WORD (без возможности редактирования) Т.З. № 1256, добавил menu-prt.
*/

{get-dep.i}
{comm-txb.i}
{keyord.i} /*Переход на новые и старые форматы форм*/

def shared var g-ofc	like ofc.ofc .
def shared var g-today 	as date.

/*u00121 30/05/06 Переменные для определения счета кассы в пути *********************************************************************************************************/
def var v-yn 	as log		no-undo.  /*признак запрещения работы через кассу   false - 100100, true - 100200							*/
def var v-arp 	as char		no-undo.  /*arp-счет кассы в пути если разрешено работать только через кассу в пути							*/
def var v-err 	as log		no-undo.  /*признак возникновения ошибки если true - ошибка имела место, и говорит о том, что желательно прекратить работу программы	*/
/************************************************************************************************************************************************************************/


def var m-aah 		like jh.jh 	no-undo.
def var m-who 		like aal.who 	no-undo.
def var m-ln  		like aal.ln 	no-undo.
def var m-crc 		like crc.crc 	no-undo.
def var m-sumd 		like aal.amt 	no-undo.
def var m-sumk 		like aal.amt 	no-undo.
def var m-amtd 		like aal.amt 	no-undo.
def var m-amtk 		like aal.amt 	no-undo.
def var m-diff 		like aal.amt 	no-undo.
def var m-cashgl 	like jl.gl 	no-undo.
def var m-row 		as integer 	no-undo.
def var m-first 	as logical 	no-undo.
def var m-firsth 	as logical 	no-undo.

def var vappend 	as logical initial false format "Append/Overwrite" 	no-undo.
def var vprint 		as logical 	no-undo.
def var dest 		as char 	no-undo.

def var v-cashtransit 	as log init false no-undo. /*признак, брать проводки по кассе в пути или по кассе, false - касса, true - кассу в пути*/

def stream v-out.
def stream v-out2.

def var v-file  as char init "Rep1.htm".
def var v-file2 as char init "Rep2.htm".
def var v-inputfile as char init "/data/export/report.htm".
def var v-str       as char.

output stream v-out  to value(v-file).
output stream v-out2 to value(v-file2).

input from value(v-inputfile).
repeat:
    import unformatted v-str.
    v-str = trim(v-str).
    put stream v-out unformatted v-str.
end.
input close.

def temp-table cashf 	no-undo
    field crc like crc.crc
    field dam like glbal.dam
    field cam like glbal.cam.

for each crc:
    create cashf.
    cashf.crc = crc.crc.
    cashf.dam = 0.
    cashf.cam = 0.
end.

/********************************************************************************************************************************************/
if v-noord = no then do:
    dest = "prit".
    {image1.f}
    update vappend vprint dest with frame image1.
    if vprint then do:
        if vappend then output to rpt.img append.
        else output to rpt.img.
    end.
    hide frame image1.
end.

output to rpt.img.
/********************************************************************************************************************************************/

/********************************************************************************************************************************************/
run get100200arp(g-ofc, 1, output v-yn, output v-arp, output v-err). /*получим признак разрешения работы только через кассу в пути*/
if not v-yn then /*если разрешено работать через кассу, то работаем по старому*/
	v-cashtransit = false. /*то будем брать проводки только по кассе*/
else
	v-cashtransit = true. /*то будем брать проводки только по кассе в пути*/
/********************************************************************************************************************************************/

find last sysc where sysc.sysc = 'CASOFC' no-lock no-error.
if lookup(string(get-dep(g-ofc, g-today)), sysc.chval) > 0  then v-cashtransit = false.

find last sysc where sysc.sysc = 'CASSOF' no-lock no-error.
if lookup(string(get-dep(g-ofc, g-today)), sysc.chval) > 0  then v-cashtransit = false.

/********************************************************************************************************************************************/
if not v-cashtransit then do: /*если v-cashtransit = false, то значит это Центральный офис Алматы или филиалы*/
	find first sysc where sysc.sysc = "CASHGL" no-lock no-error. /*для них ищем счет кассы*/
	m-cashgl = sysc.inval.
end.
else m-cashgl =  100200. /*иначе - это алматинские РКО, для них только касса в пути*/



m-firsth = no.

if m-firsth then hide frame a.
hide frame d.
/********************************************************************************************************************************************/

/********************************************************************************************************************************************/

put stream v-out unformatted
    "<TABLE width=""100%"" bordercolor=""white"" border=""1"" cellspacing=""0"" cellpadding=""0"">" skip.

find first jl where jl.jdt = g-today no-lock no-error. /*находим первую проводку за текущий операционный день, а то может их и небыло вовсе :) */
if available jl then do: /*если проводки были*/
    for each jl where jl.jdt = g-today no-lock break by jl.teller by jl.crc : /*бежим по всем проводкам текущего опер. дня*/
		if jl.teller = g-ofc  then do: /*если прводка пренадлежит офицеру, запустившему отчет*/ /*то проверяем дальше */
			if first-of(jl.crc) then do: /*проводки сгруппированы по валюте и если это первая запись по валюте*/
				find last crc where crc.crc = jl.crc no-lock no-error. /*ищем последний курс*/
				m-sumd = 0. /*обнуляем суммы*/
				m-sumk = 0.
				m-first = false. /*"говорим", что курс уже нашли*/
                put stream v-out unformatted
                    "<TR align=left>" skip
                    "<TD colspan=5>Отштампованные кассой</TD>" skip
                    "</TR>" skip
                    "<TR align=left>" skip
                    "<TD colspan=5>Исполнитель " + g-ofc + " Дата   " + string(g-today,"99/99/9999") "</TD>" skip
                    "</TR>" skip
                    "<TR align=left>" skip
                    "<TD colspan=5>Дата печати  " string(today,"99/99/9999") + " " + string(time,"HH:MM:SS") "</TD>" skip
                    "</TR>" skip.
                put stream v-out unformatted
                    "<TR align=left>" skip
                    "<TD colspan=5>Валюта " + crc.code + " " + crc.des "</TD>" skip
                    "</TR>" skip.

                put stream v-out unformatted
                    "<TR><FONT size=2>" skip
                    "<TD align=center>Номер проводки</TD>" skip
                    "<TD align=center>Исполн.</TD>" skip
                    "<TD align=center>Линия</TD>" skip
                    "<TD align=center>Дебет</TD>" skip
                    "<TD align=center>Кредит</TD>" skip
                    "</TR></FONT>" skip.
			end.
			if not v-cashtransit then do: /*если = false, то значит это Центральный офис Алматы или филиалы*/
			    /*для них собираем проводки по кассе и обменные операции по кассе в пути (как было до ТЗ 220 от 17/01/06*/
				if jl.gl = m-cashgl or (jl.gl = 100200 and substring(jl.rem[1],1,5) = 'Обмен')  then do : /*если это проводка по кассе или обменные операции по кассе в пути*/
					find last jh where jh.jh = jl.jh and jh.sts >= 6 no-lock no-error. /*ищем заголовок валюты и проверяем статус*/
					if available jh then  /*если проводка отштампована (статус равен 6)*/
					do: /*то, забираем ее в отчет*/
						m-aah = jl.jh.
						m-who = jl.who.
						m-ln = jl.ln.
						m-amtd = 0.
						m-amtk = 0.

						if jl.dc eq "D" then do:
							m-amtd = jl.dam.
							m-sumd = m-sumd + m-amtd.
						end.
						else do:
							m-amtk = jl.cam.
							m-sumk = m-sumk + m-amtk.
						end.

						if not m-first then do:
							if not m-firsth then do:
                                {casher71a.f}
                                view frame aa.
								m-firsth = true.
							end.
                            {casher76a.f}
                            view frame a76a.
                            pause 0.
							m-first = true.
						end.
                        {casher73.f}
                        display m-aah m-who m-ln m-amtd m-amtk with frame c no-box  no-hide overlay.

                        put stream v-out unformatted
                            "<TR><FONT size=2>" skip
                            "<TD align=center>" m-aah  "</TD>" skip
                            "<TD align=center>" m-who  "</TD>" skip
                            "<TD align=center>" m-ln   "</TD>" skip
                            "<TD align=center>" string(m-amtd,"zzz,zzz,zzz,zzz,zzz,zz9.99-") "</TD>" skip
                            "<TD align=center>" string(m-amtk,"zzz,zzz,zzz,zzz,zzz,zz9.99-") "</TD>" skip
                            "</TR></FONT>" skip.
					end.
				end.  /* m-cashgl */
			end.
			else do: /*если v-cashtransit = true, значит это Алматинские РКО, они работают только по кассе в пути, значит и отчет формируем только по проводкам через кассу в пути*/
				if jl.gl = m-cashgl then do: /*если это проводка по кассе в пути*/
					find last jh where jh.jh = jl.jh and jh.sts >= 6 no-lock no-error. /*ищем заголовок валюты и проверяем статус*/
					if available jh then  /*если проводка отштампована (статус равен 6)*/
					do: /*то, забираем ее в отчет*/
						m-aah = jl.jh.
						m-who = jl.who.
						m-ln = jl.ln.
						m-amtd = 0.
						m-amtk = 0.

						if jl.dc eq "D" then do:
							m-amtd = jl.dam.
							m-sumd = m-sumd + m-amtd.
						end.
						else do:
							m-amtk = jl.cam.
							m-sumk = m-sumk + m-amtk.
						end.

						if not m-first then do:
							if not m-firsth then do:
                                {casher71a.f}
                                view frame aa .
                                m-firsth = true.
							end.
                            {casher76a.f}
                            view frame a76a.
                            pause 0.
							m-first = true.
						end.
                        {casher73.f}
                        display m-aah m-who m-ln m-amtd m-amtk with frame c no-box no-hide overlay.

                        put stream v-out unformatted
                            "<TR><FONT size=2>" skip
                            "<TD align=center>" m-aah  "</TD>" skip
                            "<TD align=center>" m-who  "</TD>" skip
                            "<TD align=center>" m-ln   "</TD>" skip
                            "<TD align=center>" string(m-amtd,"zzz,zzz,zzz,zzz,zzz,zz9.99-") "</TD>" skip
                            "<TD align=center>" string(m-amtk,"zzz,zzz,zzz,zzz,zzz,zz9.99-") "</TD>" skip
                            "</TR></FONT>" skip.
                    end.
				end.  /* m-cashgl */
			end.

			if last-of(jl.crc) and m-first then do: /*если это была последняя запись по валюте*/
			/*то кидаем итоговые суммы во временную таблицу*/
				find first cashf where cashf.crc = jl.crc.
				cashf.dam = cashf.dam + m-sumd .
				cashf.cam = cashf.cam + m-sumk .
				m-diff = m-sumd - m-sumk.
                {casher72a.f}
                display m-sumd m-sumk crc.code m-diff with frame ba no-box no-label.
                hide frame ba.
                hide frame a76a.
                if vprint then display skip(2).

                put stream v-out unformatted
                "<TR align=left><FONT size=2>" skip
                "<TD colspan=3>Сумма</TD>" skip
                "<TD align=center>" string(m-sumd,"zzz,zzz,zzz,zzz,zzz,zz9.99-") "</TD>" skip
                "<TD align=center>" string(m-sumk,"zzz,zzz,zzz,zzz,zzz,zz9.99-") "</TD>" skip
                "</FONT></TR>" skip
                "<TR align=left><FONT size=2>" skip
                "<TD colspan=3>Остаток</TD>" skip
                "<TD align=center colspan=2>" string(m-diff,"zzz,zzz,zzz,zzz,zzz,zz9.99-") + " " + crc.code "</TD>" skip
                "</FONT></TR>" skip
                "<TR>" skip
                "<TD colspan=5 height=""30""></TD>" skip
                "</TR>" skip.
            end.
		end. /* g-ofc */
	end.
    put stream v-out unformatted
        "</TABLE>" skip.
end.
/********************************************************************************************************************************************/

/********************************************************************************************************************************************/
if m-firsth then hide frame aa.

hide frame c.

m-first = no.
{casher77.f}
view frame abc1.

put stream v-out unformatted
    "<TABLE width=""100%"" bordercolor=""white"" border=""1"" cellspacing=""0"" cellpadding=""0"">" skip
    "<TR><FONT size=2>" skip
    "<TD align=center>Номинал</TD>" skip
    "<TD align=center>Дебет</TD>" skip
    "<TD align=center>Кредит</TD>" skip
    "<TD align=center>Остаток</TD>" skip
    "</TR></FONT>" skip.

for each cashf:
	if cashf.dam <> 0 or cashf.cam <> 0 then do:
		if not m-first then do:
			m-first = yes.
		end.

		find crc where crc.crc = cashf.crc no-lock no-error.

        display crc.code cashf.dam cashf.cam (cashf.dam - cashf.cam) format "z,zzz,zzz,zz9.99-" with frame abc row 3 11 down no-label no-box.

        put stream v-out unformatted
            "<TR><FONT size=2>" skip
            "<TD align=center>" crc.code "</TD>" skip
            "<TD align=center>" string(cashf.dam,"zzz,zzz,zzz,zzz,zzz,zz9.99-") "</TD>" skip
            "<TD align=center>" string(cashf.cam,"zzz,zzz,zzz,zzz,zzz,zz9.99-") "</TD>" skip
            "<TD align=center>" string(cashf.dam - cashf.cam,"zzz,zzz,zzz,zzz,zzz,zz9.99-") "</TD>" skip
            "</TR></FONT>" skip.
    end.
end.

put stream v-out unformatted
    "</TABLE>" skip.


output stream v-out close.

input from value(v-file).
repeat:
    import unformatted v-str.
    v-str = trim(v-str).
    repeat:
        if v-str matches "*</body>*" then do:
            v-str = replace(v-str,"</body>","").
            next.
        end.
        if v-str matches "*</html>*" then do:
            v-str = replace(v-str,"</html>","").
            next.
        end.
        else v-str = trim(v-str).
        leave.
    end.
    put stream v-out2 unformatted v-str skip.
end.
input close.
output stream v-out2 close.

unix silent cptwin value(v-file2) winword.

output close.
pause 0	before-hide.
run	menu-prt( "rpt.img" ).
pause before-hide.
/********************************************************************************************************************************************/

return.
