/* tltrxzch.p
 * MODULE
        Отчеты
 * DESCRIPTION
	Мои сегодняшние операции 
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
        13/10/03 sasco Запрос на дату отчета
        13/10/03 sasco Вывод отчета по коммунальным платежам
        11/11/03 sasco Вызов tltrxcomm с выводом комиссии
	08/11/2005 u00121 описал формат вывода чисел format "zzz,zzz,zz9.99-"
	30/05/00 u00121  - Отчет для Алматинских РКО формируется только по кассе в пути, т.к. они работают только через кассу в пути (ТЗ ї 220 от 17/01/06)
*/

{global.i}
{get-dep.i}
{comm-txb.i}

DEF var m-fun AS char no-undo.
DEF var dest AS char no-undo.
DEF var v-copy AS int no-undo.
DEF VAR sts1 AS LOGICAL no-undo.
DEF VAR sts2 AS LOGICAL no-undo.

/*u00121 30/05/06 Переменные для определения счета кассы в пути *********************************************************************************************************/
def var v-yn 	as log		no-undo.  /*признак запрещения работы через кассу   false - 100100, true - 100200							*/
def var v-arp 	as char		no-undo.  /*arp-счет кассы в пути если разрешено работать только через кассу в пути							*/
def var v-err 	as log		no-undo.  /*признак возникновения ошибки если true - ошибка имела место, и говорит о том, что желательно прекратить работу программы	*/
/************************************************************************************************************************************************************************/


DEF STREAM m-out1.
DEF STREAM m-out2.
DEF STREAM m-out3.
DEF var m-count AS integer initial 0 no-undo.
DEF var m-cashgl AS integer no-undo.
DEF var m-first1 AS logical no-undo.
DEF var m-var1 AS logical no-undo.
DEF var m-first2 AS logical no-undo.
DEF var m-var2 AS logical no-undo.
DEF var m-amtd as dec decimals 2 format "zzz,zzz,zz9.99-" no-undo.
DEF var m-amtk as dec decimals 2 format "zzz,zzz,zz9.99-" no-undo.
DEF var m-sumdk1 as dec decimals 2 format "zzz,zzz,zz9.99-" no-undo.
DEF var m-sumkk1 as dec decimals 2 format "zzz,zzz,zz9.99-" no-undo.
DEF var m-sumd1 as dec decimals 2 format "zzz,zzz,zz9.99-" no-undo.
DEF var m-sumk1 as dec decimals 2 format "zzz,zzz,zz9.99-" no-undo.
DEF var m-sumdk2 as dec decimals 2 format "zzz,zzz,zz9.99-" no-undo.
DEF var m-sumkk2 as dec decimals 2 format "zzz,zzz,zz9.99-" no-undo.
DEF var m-sumd2 as dec decimals 2 format "zzz,zzz,zz9.99-" no-undo.
DEF var m-sumk2 as dec decimals 2 format "zzz,zzz,zz9.99-" no-undo.

DEF var m-diff as dec decimals 2 format "zzz,zzz,zz9.99-" no-undo.
DEF var m-stn as int no-undo.
DEF var m-sts LIKE jh.sts no-undo.
DEF var m-title AS char no-undo.
DEF var m-stsstr AS char no-undo.
DEF var m-char AS char no-undo.
DEF var i AS int no-undo.
DEF var j AS int no-undo.
DEF var m-keyofcjl AS log no-undo.
DEF var m-keyofc AS log no-undo.
DEF var vtitle AS char FORMAT "x(132)" no-undo.
DEF var vtoday AS date no-undo.
DEF var vtime AS char no-undo.

DEF var v-nbabeg LIKE gl.gl no-undo.
DEF var v-nbaend LIKE gl.gl no-undo.
DEF var v-nbpbeg LIKE gl.gl no-undo.
DEF var v-nbpend LIKE gl.gl no-undo.
DEF var m-str AS char.

def var v-cashtransit 	as log init false no-undo. /*признак, брать проводки по кассе в пути или по кассе, false - касса, true - кассу в пути*/

/*----------------------sasco----*/
DEF var count like jl.dam no-undo.
def var report-date as date no-undo.
def var report-title as char no-undo.

report-date = g-today.
report-title = ''.
/*-------------------------------*/


m-fun = "TLTRX".
dest = "prit".
v-copy = 1.
{tlimage10.f}
VIEW FRAME image1.
UPDATE report-date with frame image1.
UPDATE dest WITH FRAME image1 no-box.
UPDATE v-copy validate(v-copy ge 1,"") WITH FRAME image1 no-box.
HIDE FRAME image1.


FIND last sysc WHERE sysc.sysc eq "GLARPB" NO-LOCK.
IF AVAILABLE sysc THEN
DO:
	m-str = chval.
	v-nbabeg = integer(substring(m-str,1,INDEX(m-str,',') - 1)).
	m-str = substring(m-str,INDEX(m-str,',') + 1).
	v-nbaend = integer(substring(m-str,1,INDEX(m-str,',') - 1)).
	m-str = substring(m-str,INDEX(m-str,',') + 1).
	v-nbpbeg = integer(substring(m-str,1,INDEX(m-str,',') - 1)).
	m-str = substring(m-str,INDEX(m-str,',') + 1).
	v-nbpend = integer(substring(m-str,1,INDEX(m-str,',') - 1)).
end.
ELSE
DO:
	v-nbabeg = 300000.
	v-nbaend = 400000.
	v-nbpbeg = 600000.
	v-nbpend = 700000.
end.


DEF temp-table otl no-undo
	FIELD gl LIKE gl.gl
	FIELD cam LIKE jl.cam
	FIELD dam LIKE jl.cam
	FIELD ncam AS int
	FIELD ndam AS int.


/********************************************************************************************************************************************/
run get100200arp(g-ofc, 1, output v-yn, output v-arp, output v-err). /*получим признак разрешения работы только через кассу в пути*/
if not v-yn then /*если разрешено работать через кассу, то работатем по старому*/
	v-cashtransit = false. /*то будем брать проводки только по кассе*/
else
	v-cashtransit = true. /*то будем брать проводки только по кассе в пути*/
/********************************************************************************************************************************************/
if not v-cashtransit then /*если v-cashtransit = false, то значит это Центральный офис Алматы или филиалы*/
do:
	FIND last sysc WHERE sysc.sysc eq "cashgl" NO-LOCK NO-ERROR .
	IF AVAILABLE sysc then
		m-cashgl = sysc.inval.
end.
else /*иначе - это алматинские РКО, для них только касса в пути*/
	m-cashgl =  100200.
/********************************************************************************************************************************************/

FOR EACH otl.
	DELETE otl.
end.



OUTPUT STREAM m-out1 TO VALUE (lc(TRIM(g-ofc)) + "msos.txt").
OUTPUT STREAM m-out2 TO VALUE ( lc(TRIM(g-ofc)) + "mson.txt").


sts1 = FALSE.
sts2 = FALSE.


/***************************************************************************************************************************************************************************/

FIND FIRST jl WHERE jl.who = g-ofc AND jl.jdt = g-today USE-INDEX jlwho NO-LOCK NO-ERROR.
IF AVAILABLE jl then
DO:

	PUT STREAM m-out1 CHR(15).
	{tltrx01.f}
	HIDE FRAME tltrxh1.

	PUT STREAM m-out2 CHR(15).
	{tltrx02.f}
	HIDE FRAME tltrxh2.

	m-var1 = FALSE.
	m-var2 = FALSE.


	FOR EACH jl WHERE jl.who = g-ofc AND jl.jdt = report-date USE-INDEX jlwho NO-LOCK  BREAK BY jl.crc BY jl.jh BY jl.ln:

		IF FIRST-OF(jl.crc) then
		DO:
			FIND last crc WHERE crc.crc = jl.crc NO-LOCK NO-ERROR.
			if not avail crc then 
				message "Не определена валюта " jl.crc " для проводки N " jl.jh " линия " jl.ln " !!!"  view-as alert-box.
			{tltrx0.f}
			m-first1 = NO.
			m-first2 = NO.
			m-sumk1 = 0.
			m-sumd1 = 0.
			m-sumkk1 = 0.
			m-sumdk1 = 0.
			m-sumk2 = 0.
			m-sumd2 = 0.
			m-sumkk2 = 0.
			m-sumdk2 = 0.

		end.
		FIND last jh WHERE jh.jh = jl.jh NO-LOCK NO-ERROR.
		IF AVAILABLE jh then
			m-sts = jh.sts.
		else
			m-sts = 1.

		IF NOT m-first1 AND m-sts >= 6 then
		DO:
			m-first1 = TRUE.
			VIEW STREAM m-out1 FRAME crc.
			HIDE FRAME crc.
		end.

		IF NOT m-first2 AND m-sts < 6 then
		DO:
			m-first2 = TRUE.
			VIEW STREAM m-out2 FRAME crc.
			HIDE FRAME crc.
		end.


		/* ================================================< 15.10.2001, sasco <=== */
		if first-of (jl.crc) then run vyp_ofc_1 (jl.crc).
		/* ======================================================================== */

			
		m-amtk = 0.
		m-amtd = 0.

		IF jl.dc eq "D"  then
		DO:
			IF m-sts >= 6 then
			DO:
				IF jl.gl = m-cashgl then
					m-sumdk1 = m-sumdk1 + jl.dam.
				m-sumd1 = m-sumd1 + jl.dam.
			end.
			else
			DO:
				IF jl.gl = m-cashgl then
					m-sumdk2 = m-sumdk2 + jl.dam.
				m-sumd2 = m-sumd2 + jl.dam.
			end.
			m-amtd = jl.dam.
		end.
		else
		DO:
			IF m-sts >= 6 then
			DO:
				IF jl.gl = m-cashgl then
					m-sumkk1 = m-sumkk1 + jl.cam.
				m-sumk1 = m-sumk1 + jl.cam.
			end.
			else
			DO:
				IF jl.gl = m-cashgl then
					m-sumkk2 = m-sumkk2 + jl.cam.
				m-sumk2 = m-sumk2 + jl.cam.
			end.
			m-amtk = jl.cam.
		end.

		m-char = string(jl.tim,"HH:MM:SS").
		IF m-sts = 1  then
			m-stsstr = "Err".
		else
			m-stsstr = "   ".
		{tltrx2.f}

		IF  m-sts >= 6 then
			DISPLAY STREAM m-out1 m-char jl.jh jl.ln jl.gl jl.acc m-amtd m-amtk jl.teller m-sts m-stsstr WITH FRAME jltl .
		else
			DISPLAY STREAM m-out2 m-char jl.jh jl.ln jl.gl jl.acc m-amtd m-amtk jl.teller m-sts m-stsstr WITH FRAME jltl .

		FIND FIRST otl WHERE otl.gl = jl.gl  EXCLUSIVE-LOCK NO-ERROR.
		IF NOT AVAILABLE otl then
		DO:
			CREATE otl.
				otl.gl = jl.gl.
		end.

		IF jl.dc eq "D" then
		DO:
			otl.dam = otl.dam + jl.dam.
			otl.ndam = otl.ndam + 1.
		end.
		else
		DO:
			otl.cam = otl.cam + jl.cam.
			otl.ncam = otl.ncam + 1.
		end.

		IF LAST-OF ( jl.crc ) then
		DO:
			IF m-first1 then
			DO:
				HIDE FRAME jltl.
				m-var1 = TRUE.
				{tltrx41.f}
				DISPLAY STREAM m-out1 m-sumd1 m-sumk1 WITH FRAME tl1total1.
				HIDE FRAME tl1total1.
				{tltrx31.f}
				m-diff = m-sumdk1 - m-sumkk1.
				DISPLAY STREAM m-out1 m-sumdk1 m-sumkk1 m-diff WITH FRAME tltotal1.
				HIDE FRAME tltotal1.
				/* ============================================ 16.10.2001, sasco >>>====== */
				run vyp_ost_1 (jl.crc).
				/* ============================================ 16.10.2001, sasco >>>====== */

			end.
			IF m-first2 then
			DO:
				m-var2 = TRUE.
				{tltrx42.f}
				DISPLAY STREAM m-out2 m-sumd2 m-sumk2 WITH  FRAME tl1total2.
				HIDE FRAME tl1total2.
				HIDE FRAME jltl.
				{tltrx32.f}
				m-diff = m-sumdk2 - m-sumkk2.
				DISPLAY STREAM m-out2 m-sumdk2 m-sumkk2 m-diff WITH FRAME tltotal2.
				HIDE FRAME tltotal2.
			end.
		end.
	end.  /* for each jl */
end.
/***************************************************************************************************************************************************************************/



IF m-var1 THEN
	sts1 = TRUE.

IF m-var2 THEN
	sts2 = TRUE.


/***************************************************************************************************************************************************************************/
OUTPUT STREAM m-out3 TO VALUE ( lc(TRIM(g-ofc)) + "sum.txt")  page-size 59.
	IF NOT sts1 AND NOT sts2 then
	DO:
		PUT STREAM m-out1 CHR(15).
		PUT STREAM m-out2 CHR(15).
		{tltrx011.f}
		{tltrx021.f}
		HIDE FRAME tltrxh11.
		HIDE FRAME tltrxh21.
	end.



	{tltrx5.f}
	
	IF NOT sts1 THEN
		VIEW STREAM m-out1 FRAME navvar.
	IF NOT sts2 THEN
		VIEW STREAM m-out2 FRAME navvar.

	DISPLAY STREAM m-out1 SKIP(3).
	DISPLAY STREAM m-out2 SKIP(3).

	put stream m-out1 skip(10).
	put stream m-out2 skip(10).

	OUTPUT STREAM m-out1 close.
	OUTPUT STREAM m-out2 close.

	FIND last ofc WHERE ofc.ofc = g-ofc NO-LOCK.
	vtitle = {ofcsumt.f} .
	vtoday = g-today.
	vtime = string(TIME,"HH:MM:SS").



	FORM HEADER
		SKIP(3)
		g-comp vtoday vtime "BY" caps(g-ofc)
		"Page: " + string(PAGE-NUMBER, "zzz9") FORMAT "x(10)" TO 132 SKIP
		g-fname g-mdes SKIP
		vtitle FORMAT "x(132)" SKIP
		FILL("=",132) FORMAT "x(132)" SKIP
		WITH width 132 PAGE-TOP no-box NO-LABEL FRAME rpthead.
	
	VIEW STREAM m-out3 FRAME rpthead.


	FOR EACH otl WHERE NOT ((otl.gl ge v-nbabeg AND otl.gl lt v-nbaend) OR (otl.gl ge v-nbpbeg AND otl.gl lt v-nbpend))  BREAK BY otl.gl.


		FIND last gl WHERE otl.gl = gl.gl NO-LOCK.
			{ofcsum.f "stream m-out3" }
	end.

	FOR EACH otl WHERE ((otl.gl ge v-nbabeg AND otl.gl lt v-nbaend) OR (otl.gl ge v-nbpbeg AND otl.gl lt v-nbpend))  BREAK BY otl.gl.

		FIND last gl WHERE otl.gl = gl.gl NO-LOCK.
		{ofcsum.f "stream m-out3" }
	end.

	put stream m-out3 skip(10).
OUTPUT STREAM m-out3 close.
/***************************************************************************************************************************************************************************/


/***************************************************************************************************************************************************************************/
/* sasco вывод коммунальных */
UNIX silent rm -f value( lc(trim(g-ofc)) + "comm.txt").

run tltrxcomm (lc(trim(g-ofc)) + "comm.txt", report-date, g-ofc, yes).

REPEAT WHILE v-copy gt 0 :
	UNIX  value(dest) value( lc(trim(g-ofc)) + "msos.txt").
	PAUSE 0.
	UNIX  value(dest) value( lc(trim(g-ofc)) + "mson.txt").
	PAUSE 0.
	UNIX  value(dest) value( lc(trim(g-ofc)) + "sum.txt").
	PAUSE 0.
	UNIX  value(dest) value( lc(trim(g-ofc)) + "comm.txt").
	PAUSE 0.
	v-copy = v-copy - 1.
end.

UNIX silent rm -f value( lc(trim(g-ofc)) + "msos.txt").
UNIX silent rm -f value( lc(trim(g-ofc)) + "mson.txt").
UNIX silent rm -f value( lc(trim(g-ofc)) + "sum.txt").
UNIX silent rm -f value( lc(trim(g-ofc)) + "comm.txt").

hide all.
/***************************************************************************************************************************************************************************/


/***************************************************************************************************************************************************************************/
/*Далее - описание процедур...*********************************************************************************************************************************************/
/***************************************************************************************************************************************************************************/

/* ================================================> 15.10.2001, sasco >=== */
/*========================= Выписка авансов, подкреплений и расходов ======*/
procedure vyp_ofc_1.
	def input parameter incrc like jl.crc.

	put stream m-out1 fill ("-", 70) format "x(70)" skip.
	put stream m-out1 "Аванс на начало дня" format "x(30)".

	find last cashofc where cashofc.whn eq report-date and cashofc.ofc eq g-ofc and cashofc.sts eq 1 /* avans */ and cashofc.crc eq incrc no-lock no-error.
	if not avail cashofc then
	do:
		create cashofc.
			cashofc.whn = report-date.
			cashofc.ofc = g-ofc.
			cashofc.sts = 1.
			cashofc.crc = incrc.
			cashofc.amt = 0.
	end.


	put stream m-out1 cashofc.amt format "zzz,zzz,zz9.99-" skip.
	put stream m-out1 skip "Подкрепления в течение дня (общая сумма)".

	count = 0.0.
	for each cashofc where cashofc.whn eq report-date and cashofc.ofc eq g-ofc and cashofc.sts eq 3 /* podkr */ and cashofc.crc eq incrc no-lock:
		if avail cashofc then
			count = count + cashofc.amt.
	end.

	if count ne 0.0 then
		put stream m-out1 count skip.

	put stream m-out1 skip "Расходы (общая сумма)".
	count = 0.0.

	for each cashofc where cashofc.whn eq report-date and cashofc.ofc eq g-ofc and cashofc.sts eq 4 /* return */ and cashofc.crc eq incrc no-lock:
		if avail cashofc then 
			count = count + cashofc.amt.
	end.

	if count ne 0.0 then
		put stream m-out1 count skip.

end procedure.
/*========================= Выписка авансов, подкреплений и расходов2 ======*/

/***************************************************************************************************************************************************************************/
procedure vyp_ofc_2.
	def input parameter incrc like jl.crc.

	put stream m-out2 fill ("-", 70) format "x(70)" skip.
	put stream m-out2 "Аванс на начало дня" format "x(30)".

	find last cashofc where cashofc.whn eq report-date and cashofc.ofc eq g-ofc and cashofc.sts eq 1 /* avans */ and cashofc.crc eq incrc no-lock no-error.
	if not avail cashofc then
	do:
		create cashofc.
			cashofc.whn = report-date.
			cashofc.ofc = g-ofc.
			cashofc.sts = 1.
			cashofc.crc = incrc.
			cashofc.amt = 0.
	end.

	put stream m-out1 cashofc.amt format "zzz,zzz,zz9.99-" skip.
	
	put stream m-out2 skip "Подкрепления в течение дня (общая сумма)".

	count = 0.0.
	for each cashofc where cashofc.whn eq report-date and cashofc.ofc eq g-ofc and cashofc.sts eq 3 /* podkr */ and cashofc.crc eq incrc no-lock:
		if avail cashofc then
			count = count + cashofc.amt.
	end.

	if count ne 0.0 then
		put stream m-out2 count skip.

	put stream m-out2 skip "Расходы (общая сумма)".
	count = 0.0.
	for each cashofc where cashofc.whn eq report-date and cashofc.ofc eq g-ofc and cashofc.sts eq 4 /* return */ and cashofc.crc eq incrc no-lock:
		if avail cashofc then 
			count = count + cashofc.amt.
	end.

	if count ne 0.0 then
		put stream m-out2 count skip.
end procedure.
/***************************************************************************************************************************************************************************/


/***************************************************************************************************************************************************************************/
procedure vyp_ost_1.
	def input parameter incrc like jl.crc.

	find last cashofc where cashofc.ofc eq g-ofc and cashofc.whn eq report-date and cashofc.sts eq 2 and cashofc.crc eq incrc no-lock no-error.
	if not avail cashofc then
	do:
		create cashofc.
			cashofc.whn = report-date.
			cashofc.ofc = g-ofc.
			cashofc.sts = 2.
			cashofc.crc = incrc.
			cashofc.amt = 0.
	end.

	if avail cashofc then
	do:
		put stream m-out1 "Остаток наличной валюты в кассе: ".
		put stream m-out1 cashofc.amt format "zzz,zzz,zz9.99-" skip.
	end.
end procedure.
/***************************************************************************************************************************************************************************/