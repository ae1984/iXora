/* accremai.p
 * MODULE
        Название Программного Модуля
	PRAGMA
 * DESCRIPTION
        Назначение программы, описание процедур и функций
		Повторное открытие счета клиент
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
	1-6-6
 * AUTHOR
        31/12/99 pragma
 * CHANGES
  03.03.1997 - AGA   - повтоpное откpытие закpытых счетов при повторном открытии изменяется признак ccode в таблице sub-cod
  12.02.2002         - при повторном открытии счета добавлена процедура взятия комисси (cod -101) 
  15.07.2003 nadejda - добавлена печать уведомления в налоговый комитет о переоткрытии счета
  25.08.2003 nadejda - сделан запрос на номер счета без всяких условий
  14.12.2004 u00121  - run prit_sch(aaa.aaa, 3), в этой вызываемой программке, кто-то определил "шаровые" переменные, эта программка вызывается из многих мест,
		       естесно, наш "создатель" не позаботился проверить, откуда еще может вызываться она, а только в свою - cif-new2.p определил "нью шару".
		       пока до меня дошло, почему вызов prit_sch игнорируется... ух как я зол :E.
*/


{mainhead.i}  /*  statuss mai‡a  */

def new shared var ch_date as date . /*14.12.2004 u00121*/
def new shared var ch_KS as char .   /*14.12.2004 u00121*/

DEF buffer b-aa FOR aaa.
DEFINE buffer b-aaa FOR aaa.

def var s_aaa  like aaa.aaa.
DEF var grobal LIKE aas.chkamt DECIMALS 2.
DEF var avabal LIKE aas.chkamt DECIMALS 2.
DEF var crline LIKE aas.chkamt DECIMALS 2.
DEF var crused LIKE aas.chkamt DECIMALS 2.
DEF var mtddb  LIKE aas.chkamt DECIMALS 2.
DEF var mtdcr  LIKE aas.chkamt DECIMALS 2.
DEF var ytdint LIKE aas.chkamt DECIMALS 2.
def var s-aaa  like aaa.aaa.

DEF var vdet       AS log.
DEF var vrel       AS log.
DEF var vstop      AS log.
DEF var vans       AS log.
DEF var sstop      AS char FORMAT "x(15)" .
DEF var spnum      AS int FORMAT "zz9".
DEF var shold      AS char FORMAT "x(15)" .
DEF var shnum  	   AS int FORMAT "zz9".
def var V-sel      As Integer FORMAT "9" init 1.
def var in_command as decimal .
def var v-rate     as decimal.

{accmaint.f}

outer:
REPEAT:
	CLEAR FRAME aaa.
	PAUSE 0.
	crline = 0.
	crused = 0.
	IF KEYFUNCTION(LASTKEY) eq "end-error" THEN RETURN.

/* 25.08.2003 nadejda
IF g-aaa eq "" THEN
PROMPT-FOR aaa.aaa WITH FRAME aaa.
ELSE
DISPLAY g-aaa @ aaa.aaa WITH FRAME aaa.
*/

	PROMPT-FOR aaa.aaa WITH FRAME aaa.

	FIND aaa USING aaa.aaa exclusive-lock no-error.
	FIND cif OF aaa no-lock no-error.
	FIND lgr WHERE lgr.lgr eq aaa.lgr no-lock no-error.
	IF aaa.loa ne "" AND lgr.led eq "DDA" THEN
	DO:
		FIND b-aaa WHERE b-aaa.aaa eq aaa.loa no-lock no-error.
		crline = b-aaa.dr[5] - b-aaa.cr[5].
		crused = b-aaa.dr[1] - b-aaa.cr[1].
	END.

	if lgr.led eq "DDA" or lgr.lgr eq "151" then s_aaa = aaa.craccnt.

	grobal = aaa.cr[1] - aaa.dr[1].
	avabal = aaa.cbal + crline - crused.
	ytdint = (aaa.dr[2] - aaa.idr[2]) - (aaa.cr[2] - aaa.icr[2]).
	mtddb = aaa.dr[1] - aaa.mdr[1].
	mtdcr = aaa.cr[1] - aaa.mcr[1].
	spnum = 0.
	shnum = 0.

	FOR EACH aas WHERE aas.aaa eq aaa.aaa NO-LOCK :
		IF aas.sic = "SP" THEN spnum = spnum + 1.
		ELSE
			IF aas.sic = "HB" THEN shnum = shnum + 1.
	END.

	IF spnum > 0 THEN
		sstop = string(spnum) + " STOP PAYMENT".
	ELSE
		sstop = "NO STOP PAYMENT".

	IF shnum > 0 THEN
		shold = string(shnum) + " HOLD BALANCE".
	ELSE
		shold = "NO HOLD BALANCE".

	DISPLAY
		cif.cif
		trim(trim(cif.prefix) + " " + trim(cif.sname)) @ cif.sname aaa.aaa s_aaa
		cif.tel aaa.sta
		grobal shold aaa.hbal
		avabal aaa.accrued
		crline ytdint
		crused
		cif.pss
		aaa.lstdb aaa.ddt
		aaa.lstcr aaa.cdt
		aaa.regdt
		aaa.fbal
		sstop
			WITH FRAME aaa.

	IF shnum > 0   THEN
		COLOR DISPLAY  messages  shold WITH FRAME aaa.
	ELSE
		COLOR DISPLAY  INPUT  shold WITH FRAME aaa.

	IF spnum > 0   THEN
	DO:
		COLOR DISPLAY  messages  sstop WITH FRAME aaa.
		PAUSE 1.
		FOR EACH aas WHERE aas.aaa eq aaa.aaa NO-LOCK:
			FIND sic OF aas no-lock no-error.
			DISPLAY aas.sic sic.des LABEL "DESCRIPTION"  aas.regdt aas.chkdt aas.chkno aas.chkamt WITH row 9  9 DOWN  OVERLAY  CENTERED 
						TITLE " Special Instructions for (" + string(aas.aaa) + ")" FRAME aas.
		END.
		IF aaa.sta EQ "C" THEN
		DO:
			COLOR DISPLAY  INPUT  sstop WITH FRAME aaa.
			BELL.
			{mesg.i 0832} UPDATE vans.
			IF vans THEN
			DO:
				aaa.cdt = g-today.
				aaa.who = g-ofc.
				aaa.whn = g-today.
			END.
		END.
		ELSE
		DO:
			PAUSE.
		END.
	END.
	ELSE
	DO:
		IF aaa.sta EQ "C" THEN
		DO:
			COLOR DISPLAY  INPUT  sstop WITH FRAME aaa.
			BELL.           	
			{mesg.i 0832} UPDATE vans.
			IF vans THEN
			DO:
				s-aaa = aaa.aaa.
				aaa.sta = "A".
				aaa.cdt = g-today.
				aaa.who = g-ofc.
				aaa.whn = g-today.
				for each sub-cod where sub eq 'cif' and  acc eq aaa.aaa   and  d-cod eq 'clsa':
					update sub-cod.ccode = 'msc'. 
				end.
				{print-dolg.i}
				{print-dolg2.i}
				aaa.penny = in_command.   /*Величина Комиссии*/
				aaa.vip = V-sel.      /*  код выбранного пункта меню  */

				if aaa.lgr = '397' or aaa.lgr = '396' or aaa.lgr = '422' or aaa.lgr = '431' or aaa.lgr = '402' 
						   or aaa.lgr = '400' or aaa.lgr = '401' or aaa.lgr = '403' or aaa.lgr = '437' or aaa.lgr = '427' 
				then 
					run prit_gar(aaa.aaa, 3).

				if aaa.lgr begins '1' or aaa.lgr = '320' or aaa.lgr = '392' or aaa.lgr = '393' or aaa.lgr = '410' 
						      or aaa.lgr = '411' or aaa.lgr = '412' or aaa.lgr = '420' 
				then 
					run prit_sch(aaa.aaa, 3).

			END.
		END.                              
		ELSE
		DO:
			PAUSE.
		END.
	END.
END.

find current aaa no-lock.

