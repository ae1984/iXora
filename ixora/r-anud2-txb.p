/* r-anud2-txb.p
 * MODULE
        Депозиты
 * DESCRIPTION
        Отчет по депозитам с группировкой по наименованию, валюте и ГК
	Сбор данных по филиалам.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
	{r-branch.i &proc = "r-anud2-txb(<дата остатка>, <признак физ./юр лица, true/false соответсвенно)>)"} 
 * CALLER
        r-anud2.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        10/04/2004 u00121
 * CHANGES
*/

{msg-box.i}

/******************************************************************************/
def input param i-dt    as date no-undo.
def input param i-fl	as log	no-undo.

def shared var v-tm as int no-undo.

def shared temp-table tfl$ no-undo
	field tgl like txb.aaa.gl
	field tacc like txb.aaa.aaa
	field tlgr like txb.aaa.lgr
	field tsum like txb.aaa.cbal
	field tfil as char
	field crc as integer
	field texp like txb.aaa.expdt
	field des like txb.lgr.des
	index main tgl crc tlgr.

def var v-fizgl as char init "221120,221130,221520,221720,221920,222120,222160,222320,221140,220530,222350,222362,220520,220620,220720,220820,220830,220840,220920" no-undo.
def var v-urgl 	as char init "220310,220320,220420,221110,221510,221710,221910,222110,222150,222310,222330,222340,222361" no-undo.
def var v-strgl as char no-undo.

def var v-i 	as int no-undo.
def var v-gl 	like txb.gl.gl no-undo.
/******************************************************************************/

/******************************************************************************/
if i-fl then
	v-strgl = v-fizgl.
else	
	v-strgl = v-urgl.
/******************************************************************************/

/******************************************************************************/
find last txb.cmp no-lock no-error.
if avail txb.cmp then
do:
	if i-fl then
		run SHOW-MSG-BOX ("Физ.Лица - " + txb.cmp.name).
	else
		run SHOW-MSG-BOX ("Юр.Лица - " + txb.cmp.name).
end.
/******************************************************************************/    


/******************************************************************************/
do v-i = 1 to num-entries(v-strgl):

	v-gl = int(entry(v-i,v-strgl)).

	for each txb.aaa where txb.aaa.gl = v-gl no-lock /*break by txb.aaa.gl by txb.aaa.lgr*/:
		displ v-gl label "Г/К" txb.aaa.aaa label "Счет" string(time - v-tm, "HH:MM:SS") label "Время" with frame f centered side-labels. pause 0.
		find last txb.histrxbal where 	txb.histrxbal.sub = "CIF" 
					and 	txb.histrxbal.acc = txb.aaa.aaa 
					and 	txb.histrxbal.lev = 1 
					and 	txb.histrxbal.crc = txb.aaa.crc 
					and 	txb.histrxbal.dt <= i-dt no-lock no-error .

		if available txb.histrxbal and (txb.histrxbal.cam - txb.histrxbal.dam) <> 0 then 
		do:         
			find last txb.crchis where txb.crchis.crc = txb.aaa.crc and txb.crchis.rdt <= i-dt no-lock no-error.
			if not avail txb.crchis then
			do:
				message "Не найдена история для валюты с кодом " txb.aaa.crc skip 
					"дата " i-dt " филиал " txb.cmp.name skip
					"Формирование отчета прекращено!" view-as alert-box.
			 	return.
			end.

			create tfl$.             
			assign 	tfl$.tgl = txb.aaa.gl
				tfl$.tacc = txb.aaa.aaa
				tfl$.tlgr = txb.aaa.lgr
				tfl$.crc = txb.aaa.crc
				tfl$.tsum = (txb.histrxbal.cam - txb.histrxbal.dam) * txb.crchis.rate[1]
				tfl$.tfil = txb.cmp.name
				tfl$.texp = txb.aaa.expdt.

			find last txb.lgr where txb.lgr.lgr = tfl$.tlgr no-lock no-error.
			if avail txb.lgr then
				tfl$.des = txb.lgr.des.
			else
				tfl$.des = "Не найдена запись " + tfl$.tlgr + " в справочнике типов счетов (таблица lgr)".	
		end.    
	end.
end.
/******************************************************************************/
