/* rzp-outg.p
 * MODULE
        Платежная система
 * DESCRIPTION
	Создание и отправка платежей по ЗП проектам Народного банка
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        3-outg.p
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        02/10/2006 tsoy
 * CHANGES
*/

{global.i}
{comm-rnn.i}



def shared var s-remtrz like remtrz.remtrz.

def var v-9c as cha format "x(35)"  label "Фамилия, Имя    " .
def var v-9d as cha format "x(35)"  label "Персональный код".
def var v-9e as cha format "x(35)"  label "Номер паспорта  ".
def var v-9f1 as cha format "x(35)" label "Кем выдан       ".
def var v-9f2 as cha format "x(35)" label "                ".
def var v-drg as cha format "99" label    "Срок действия   ".
def var prilist as cha.
def var sublist as cha .
def var lbnstr as cha . 
def var de6 as int .
def var result as int format "9" .
def var v-det as cha . 
def var addrbank as char format "x(80)".
def var cmdk as char format "x(70)".
def var v-bb as  cha  . 
def var Lswtdfb as log format "Да/Нет".
def var Lswbank as log format "Да/Нет".

def new shared var f_title as char format "x(80)". /*title of frame mt100  */
def new shared buffer f57-bank for bankl.           /* nan */
def new shared buffer sw-bank  for bankl.           /* nan */
def new shared var s-sqn as cha .
def new shared var remrem202 as char format "x(16)". /* field 20 of mt202  */
def new shared var F52-L as char format "x(1)".  /* ordering institution*/
def new shared var F53-L as char format "x(1)".  /* sender's corr.      */
def new shared var F54-L as char format "x(1)".             /*rec-r's corr. */
def new shared var F56-L as char format "x(1)".    /*intermediary.  */
def new shared var F53-2L as char format "x(1)".    /*intermediary 202.  */
def new shared var F53-2val as char extent 4 format "x(35)".

/*intermediary 202 .  */
def new shared var F56-2L as char format "x(1)".    /*intermediary 202.  */
def new shared var F56-2val as char extent 4 format "x(35)".

/*intermediary 202 .  */
def new shared var F57-2L as char format "x(1)".    /*intermediary 202.*/
def new shared var F57-2val as char extent 5 format "x(35)".

/*intermediary 202 .*/
def new shared var F58-2L as char format "x(1)".
def new shared var F58-2aval as char extent 5 format "x(35)". /*58- 202.*/ 
def new shared var F58-2bval as char extent 5 format "x(35)".
def new shared var F72-2val as char extent 6 format "x(35)".
def new shared var F72-1val as char extent 6 format "x(35)". /* mt100.*/

/*intermediary 202 .*/
def new shared var F57-L as char format "x(1)".       /*account with inst.  */
def new shared var F57-str4 as char extent 2 format "x(35)".
def new shared var v-58 as char extent 4 format "x(35)".

def  var F71choice as char extent 3 format "x(3)" initial ["BEN", "OUR","NON"].
def var vdep as inte.
def var vpoint as inte.
def  var ootchoice as char extent 4 format "x(35)" initial [" MT 103 ", " MT 200 ", " MT 202 ", " MT 202, MT 103 "].

def new shared var dmt100 as char format "x(12)".
def new shared var v-bn1 like remtrz.ord.
def new shared var v-bn2 like remtrz.ord.
def new shared var v-bn3 like remtrz.ord.
def new shared var v-bn4 like remtrz.ord.
def new shared var v-bb1 like remtrz.ord.
def new shared var v-bb2 like remtrz.ord.
def new shared var v-bb3 like remtrz.ord.
def new shared var v-bb4 like remtrz.ord.

def new shared var v-refernumber as char.
def new shared var v-destnumber as char.
def new shared var v-dest202 as char.

def new shared var v-swinbankb like swbody.content[1].
def new shared var v-swinbankb2 like swbody.content[2].

def var acode like crc.code.
def var bcode like crc.code.
def var c-acc as cha .
def var vv-crc like crc.crc .
def var v-cashgl like gl.gl.
def var vf1-rate like fexp.rate.
def var vfb-rate like fexp.rate.
def var vt1-rate like fexp.rate.
def var vts-rate like fexp.rate.
def shared frame remtrz.
def buffer xaaa for aaa.
def buffer fcrc for crc.
def buffer t-bankl for bankl.
def buffer tcrc for crc.
def var ourbank as cha.
def var clearing as cha.
def var t-pay like remtrz.payment.
def buffer tgl for gl.
def var b as int.
def var s as int.
def var sender   as cha.
def var receiver as cha.
def var s-bankl like remtrz.rbank .
def var v-weekbeg as int.
def var v-weekend as int.
def var  intv as  int.
def new shared var sw as log format "Да/Нет" init yes.
def var brnch as log format "Да/Нет" initial false . 
def new shared var scod as char init "ns" .
def var v-bn like remtrz.bn format "x(35)" label "Получатель" . 
def var v-id as char format "x(12)" label "РНН".

def var v-sub as cha format "x(6)" label "КодБК".

def  var kindchoice as char extent 3 format "x(6)" label "Тип пл." initial ["Норм.", "Налог" , "Пенсия" ].
def var v-inc as cha format "x(10)" label "Код дохода" .
def var t-rcv as int .
def var v-rnn as log.
def var qq as char . 
def var v-o as log.
def var bbcod as char.
def var valcntrl as logical init false.         /*** KOVAL Для валютного контроля ***/
def var logic as logical init false.            /*** KOVAL ***/

def var l-rekviz as logical .  
def new shared var l-doubleswift as logical init False.

def var rnntrue as log init false.

define new shared temp-table tmpswbody like swbody.

define buffer b-bankl for bankl .
/*****************************valery****************************************************************************************************************************************/
def var accs as char.
def var accb1 as char format "x(3)".
def var i as int.
def var j as int.
def var accs2 as char.
def var f1 as logical init false.
def var f2 as logical init false.
def var f3 as logical init false.
def var msg as char init "Счет получателя не соответствует БИКу получателя, повторите, пожалуйста!".

def new shared var val_103_54con1 like swbody.content[1].
def new shared var val_103_54con2 like swbody.content[2].
def new shared var val_103_54con3 like swbody.content[3].
def new shared var val_103_54con4 like swbody.content[4].
def new shared var val_103_54con5 like swbody.content[5].
def new shared var val_103_54con6 like swbody.content[6].
def new shared var val_103_type like swbody.type.

def var v-uni as char.
def frame funi 
    v-uni label "Unicode"  format  "x(16)"
with centered row 3 side-labels.

DEFINE VARIABLE v-longrnn as logical.

v-longrnn = false.

function chk-gosacc returns logical (p-val1 as char, p-val2 as char).
	find b-bankl where b-bankl.crbank = p-val2 no-lock no-error .
	if available b-bankl then 
	do:
		message "Проставьте код филиала: (TXB..)".
		return false.
	end.
	if p-val2 = "190501914" then 
	do:
		message "Внутрений платеж надо делать в 2.1".
		return false.
	end.

	find sysc where sysc = "GOSACC" no-lock no-error.
	if avail sysc then 
		accs = sysc.chval.
	else 
		return true.

	accb1 = substr(p-val1, 4,3). /*вырываем серединку из счета*/
	j = num-entries(accs,"|").
	do i = 1 to j: /*смотрим сколько записей с ограничениями (A,A^A1,A2...An|B,B^B1,B2...Bn)*/ 
		accs2 = entry(i,accs,"|"). /*отделяем каждую запись*/
		if lookup(accb1, entry(1,accs2,"^")) > 0 then f1 = true. /*если вырезанная нами серединка встречается в первой части записи ставим true*/
		if lookup(p-val2, entry(2,accs2,"^")) > 0 then f2 = true. /*если БИК банка встречается во второй части ставим true*/
		if f1 and f2 then 
		do: 
			f1 = false. f2 = false. f3 = false. return false. 
		end. /*если и серединка и БИК есть в записи*/
		else 
		do: 
			f2 = false. f1 = false. f3 = true. 
		end.
	end.
	if f3 then return true.
end.
/*****************************valery****************************************************************************************************************************************/

/*Определим номера дней начала и окончания рабочей недели*******************************************************************************************************************/
find sysc "WKEND" no-lock no-error.
if available sysc then 
	v-weekend = sysc.inval. 
else 
	v-weekend = 6.

find sysc "WKSTRT" no-lock no-error.
if available sysc then 
	v-weekbeg = sysc.inval. 
else 
	v-weekbeg = 2.
/***************************************************************************************************************************************************************************/

/*Найдем Транз.счет ГК для вход.плат. **************************************************************************************************************************************/
find  sysc 'psingl' no-lock no-error.
if avail sysc then 
	intv = sysc.inval.
/***************************************************************************************************************************************************************************/

{lgps.i }
{ps-prmt.i}
{rmz.f}
/*Определим код текущего филиала нашего банка - принятый в Прагме **********************************************************************************************************/
find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then 
do:
	message "Отсутствует запись OURBNK в таблице SYSC!" .
	pause .
	undo .
	return .
end.
ourbank = sysc.chval.
/***************************************************************************************************************************************************************************/

/*Тип срочности платежа ****************************************************************************************************************************************************/
find sysc where sysc.sysc = "PRI_PS" no-lock no-error .
if not avail sysc or sysc.chval = "" then 
do:
	message "Отсутствует запись PRI_PS в таблице SYSC!" .
	pause . 	
	undo .
	return .
end.
prilist = sysc.chval.
/***************************************************************************************************************************************************************************/

/*Полочки для второй проводки **********************************************************************************************************************************************/
find sysc where sysc.sysc = "PS_SUB" no-lock no-error .
if not avail sysc or sysc.chval = "" then 
do:
	message "Отсутствует запись PS_SUB в таблице SYSC!" .
	pause . 	
	undo .
	return .
end.
sublist = sysc.chval.
/***************************************************************************************************************************************************************************/


find sysc where sysc.sysc = "clcen" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
	message "Отсутствует запись CLEARING в таблице SYSC!" .
	pause .
	undo .
	return .
end.
clearing = sysc.chval.


if ourbank = clearing  then brnch = false . else brnch = true . 

/*Найдем Ностро-счет в Центр.Банке  ****************************************************************************************************************************************/
find sysc where sysc.sysc = 'LBNSTR' no-lock  no-error.
if not avail sysc then
do:
	message  "Отсутствует запись LBNSTR в таблице SYSC!".
	pause . 
	return.
end.
lbnstr = sysc.chval . 
/***************************************************************************************************************************************************************************/

do transaction : 

	find first que where que.remtrz = s-remtrz exclusive-lock no-error .
	if avail que then
		v-priory = entry(3 - int(que.pri / 10000 - 0.5 ) ,prilist).
	else
		v-priory = entry(1, prilist).

	display v-priory with frame remtrz. pause 0 .


	find first sysc where sysc.sysc = "RMCASH" no-lock no-error .
	if not avail sysc then 
	do:
		message "Отсутствует запись RMCASH в таблице SYSC!" .
		return.
	end  .
	v-cashgl = sysc.inval .

	find sysc where sysc.sysc = "CLECOD" no-lock no-error.
	if not avail sysc then 
	do:
		v-text = " Записи CLECOD нет в файле sysc  " .  run lgps.
		return .
	end.
	bbcod = substr(trim(sysc.chval),1,6).


	find first remtrz where remtrz.remtrz = s-remtrz exclusive-lock .

	{koval-vlt.i}

	find first tarif2 where trim(tarif2.num) + trim(tarif2.kod) = string(remtrz.svccgr) and tarif2.stat = "r" no-lock no-error .
	if avail tarif2 then 
		pakal = tarif2.pakalp.

	display pakal with frame remtrz .


	/* sasco */
	{rcomm-txb.i}

	/* если это валютный платеж на филиал - то поменяем источник и уберем RKO_VALOUT */
	if remtrz.source = "RKOTXB" and que.pid = "G" then
	do:
		remtrz.source = "O".
		v-text = remtrz.remtrz + " Источник remtrz изменен: RKOTXB -> O".
		run lgps.
		RKO_LOGI = no.
	end.

	if (not RKO_VALOUT()) or QUE_3G or QUE_TXB then 
	do:

		/* mt100_0 :: для всех 3G, всех не-АлматыРКОВалютных                     */
		/*            5.3.1 - "O" - для всех не-АлматыРКОВалюта                  */
		/*            5.3.2 - "G" - для всех не-АлматыРКОВалюта                  */
		/*            5.3.3 - "P" - для всех абсолютно                           */
		/* === 3G or (not RKO_VALOUT)                                            */


		/* mt100_1 :: для ВСЕХ кроме "3G"                                        */
		/* === not QUE_3G                                                        */
	
		/* RECEIVER  */

		do on error undo , retry :
			display remtrz.tcrc with frame remtrz.
			do on error undo , retry :

				/*  06.09.2002 -- Kanat -- Проверка суммы по кредиту для тенговых платежей --------------------*/

				if remtrz.tcrc = 1 and m_pid = "P" and rnntrue = false then 
				do:
					def var temp_cr_amount like remtrz.amt.
					
					update    temp_cr_amount 
						with centered overlay row 5 side-label 
							title "Проверка суммы по кредиту" frame credit_amount_check.  

					if remtrz.amt <> temp_cr_amount then 
					do:
						message "Ошибка! Сумма по кредиту не совпадает с суммой по дебету." view-as alert-box.
						undo, retry.
					end.
				end.
				/* -------------- End credit summ check ---------------------------------------------------------*/


				/* -------  Предварительная проверка РНН получателя для тенговых платежей ----- */

				if remtrz.tcrc = 1 and (m_pid = "P" or m_pid = "3g") and rnntrue = false then 
				do:
					qq = remtrz.bn[1] + remtrz.bn[2] + remtrz.bn[3] .
					if qq ne "" then 
					do:
						v-9d = substr(qq,index(qq,"/RNN/") + 5) .
						qq = substr(qq,1,index(qq,"/RNN/") - 1).
						v-9c = substr(qq,1,35) .
						v-9e = substr(qq,36,35) .
					end.

					if (qq eq "" or v-9d eq "") and remtrz.info[3] ne "" then 
					do:
						v-9c  = substr(entry(3,remtrz.info[3],"^"),4,35) .
						v-9d  = substr(entry(4,remtrz.info[3],"^"),4,35) .
						v-9e  = substr(entry(5,remtrz.info[3],"^"),4,35) .
						v-9f1 = substr(entry(6,remtrz.info[3],"^"),4,35) .
						v-9f2 = substr(entry(6,remtrz.info[3],"^"),39,35) .
						v-drg = substr(entry(2,remtrz.info[3],"^"),4,2) .
					end.

					update 
						v-9d validate( not comm-rnn (v-9d), "Не верный контрольный ключ РНН!") format "x(12)"
							with centered overlay row 5 side-label 
								title " Проверка РНН получателя " frame rnncheck .

					find first taxnk where taxnk.rnn = v-9d use-index rnn no-lock no-error.
					if available taxnk then 
					do:
						v-9c = taxnk.name.
					end.
					else 
					do:
						find first rnnu where rnnu.trn = v-9d use-index rnn no-lock no-error.
						if available rnnu then
							v-9c = caps(rnnu.busname).
					end.

					v-9c = TRIM(v-9c).
		
					if length (v-9c) > 60 then 
						v-longrnn = true.

					v-id = v-9d .
					remtrz.bn[1] = v-9c.
					remtrz.bn[2] = v-9e.
					remtrz.bn[3] = "/RNN/" + v-9d.
					display remtrz.bn[1] remtrz.bn[2] remtrz.bn[3] with frame remtrz .
					if remtrz.info[3] ne "" then
						remtrz.info[3] = "11B^3f:" + v-drg + "^9C:" + v-9c + "^9D:" + v-9D + "^9E:" + v-9E + "^9F:" + v-9f1 + v-9f2 . 

						rnntrue = true.
				end.
				/* -------  END RNN CHECK  ----- */

				if remtrz.rbank = "" and m_pid = "I" then 
					remtrz.rbank = ourbank .

				if remtrz.jh2 eq ? and m_pid <> "S" then
				do:
					update remtrz.rbank validate(chk-gosacc(remtrz.racc, remtrz.rbank), msg) with frame remtrz.   /** valery **/

                                        update remtrz.racc validate(remtrz.racc ne "","") with frame remtrz.

					/* 30/04/2004 kanat - проверка реквизитов НК по соответствия РНН и БИК из справочника налог. комитета --- */

					find first taxnk where taxnk.rnn = v-9d and taxnk.bik <> integer(remtrz.rbank) no-lock no-error.
					if avail taxnk then 
					do:
						message "БИК налогового комитета не соответствует РНН!!" view-as alert-box title "Внимание".
						undo,retry.
					end.

					/*--------------------------------------------------------------------------------------------------------*/

					if remtrz.outcode = 8 and not remtrz.rbank begins "RKB" then undo,retry .

					if  remtrz.rbank eq "" and ( not ( m_pid = 'P' or brnch ) or ( ( m_pid = 'P' or brnch ) and remtrz.tcrc = 1)) then undo,retry.

					if ( m_pid eq "3" or m_pid eq "3g" ) and remtrz.rbank = ourbank then undo,retry .
				end.
				
				if remtrz.rbank = "" and brnch then 
						remtrz.rcbank = clearing .

				display remtrz.rcbank with frame remtrz . pause 0 .  

				if remtrz.rbank ne "" then 
				do:
					find first bankl where bankl.bank = remtrz.rbank no-lock no-error.
					if not avail bankl then
						find first bankl where substr(bankl.bank,7,3)  = remtrz.rbank no-lock no-error .
						if not avail bankl then 
						do: 
							bell . 
							undo,retry .   
						end .
						
						if remtrz.source  = 'SVL' then 
						do:
							disp bankl.name label "Наим"  skip
								bankl.addr[1] label "Адрес" skip bankl.addr[2] label "Адрес"
									with centered row 6 1 col overlay top-only frame rr.
						end.

						if remtrz.rbank ENTERED  or bankl.nu = "u" then 
							remtrz.rcbank = caps(bankl.cbank) .
						
						if remtrz.rbank ENTERED and not ( (( remtrz.source begins "P" or remtrz.source = "A" or brnch or 
									remtrz.source = "IBH" or 
									remtrz.source = "RKO") or 
									remtrz.source begins "SVL") and 
									remtrz.bb[1] + remtrz.bb[2] + remtrz.bb[3] ne "" ) then 
						do:
							s-bankl = remtrz.rbank.
							remtrz.rbank = caps(bankl.bank) .
							remtrz.bb[1] = bankl.name.
							remtrz.bb[2] = bankl.addr[1].
							remtrz.bb[3] = bankl.addr[2] + " " + bankl.addr[3].
						end .
						else 
							remtrz.rbank = caps(bankl.bank) .

						display remtrz.rbank remtrz.rcbank remtrz.bb with frame remtrz .

						/*u00121 23.06.2005 ТЗ ї 47 от 08.06.2005 проверка статуса банка получателя*****************************************************************************/
						if remtrz.rbank begins "19" and bankl.sts <> 0 then 
						do:
								message "По банку " + bankl.name + " (" + bankl.bank + "), закрыты активные операции!" skip "Просим уточнить БИК."  view-as alert-box.
								bell.
								undo, return.
						end.
						/*******************************************************************************************************************************************************/
				end.
				else
					if not ourbank = clearing then 
							remtrz.rcbank = clearing .
			end .
			/* RECEIVER - NOT OUR BANK  */

			if ( remtrz.rbank ne ourbank ) then
				do  on  error  undo , retry :
					find first bankl where bankl.bank = remtrz.rbank no-lock no-error.

					if not brnch and  ( ( avail bankl and bankl.nu ne "u" ) or remtrz.rbank = "" ) and remtrz.jh2 eq ? and m_pid <> "S" then 
					do on error undo,retry :
						update remtrz.rcbank with frame remtrz.
						if remtrz.rcbank ne "" then 
						do:
							find first bankl where bankl.bank  = remtrz.rcbank no-lock no-error .
							if not avail bankl then
								find first bankl where substr(bankl.bank,7,3)  = remtrz.rcbank no-lock no-error .
						end. 
						if not avail bankl and not ( m_pid = 'P' or brnch ) then undo,retry .  

						if remtrz.source  = 'SVL' and remtrz.rbank <> remtrz.rcbank then 
						do:
							disp bankl.name label "Наим" skip
								bankl.addr[1] label "Адрес"  skip bankl.addr[2] label "Адрес"
									with centered row 6 1 col overlay top-only frame rr.
						end.

						if  not (remtrz.rcbank =  ''  and ( m_pid = 'P' or brnch  )) then 
							remtrz.rcbank = caps(bankl.bank).
						
						display remtrz.rcbank with frame remtrz .

					end. 
				end .

				if not (remtrz.rcbank = '' and (m_pid = 'P' or brnch ) ) then 
				do:
					find first crc where crc.crc = remtrz.tcrc no-lock . 
					bcode = crc.code .

					find first bankt where bankt.cbank = remtrz.rcbank and bankt.crc = remtrz.tcrc and bankt.racc = "1" no-lock no-error .
					if not avail bankt then 
					do:
						message "Ошибка! Отсутствует запись в таблице BANKT!".
						pause .
						undo,retry .
					end.

					if remtrz.valdt1 >= g-today then
						remtrz.valdt2 = remtrz.valdt1 + bankt.vdate .
					else
						remtrz.valdt2 = g-today + bankt.vdate .
					
					if remtrz.valdt2 = g-today and bankt.vtime < time then 
						remtrz.valdt2 = remtrz.valdt2 + 1 .

					repeat:
						find hol where hol.hol eq remtrz.valdt2 no-lock no-error.
						if not available hol and weekday(remtrz.valdt2) ge v-weekbeg and weekday(remtrz.valdt2) le v-weekend then leave.
						else remtrz.valdt2 = remtrz.valdt2 + 1.
					end.

					if remtrz.jh2 eq ? and m_pid <> "S" then
						update remtrz.valdt2 validate(remtrz.valdt2 >= remtrz.valdt1, " 2Дата < 1Дата " ) with frame remtrz. pause 0 .

					find first t-bankl where t-bankl.bank = bankt.cbank no-lock .
					if t-bankl.nu = "u" then 
						receiver = "u". 
					else 
						receiver = "n" .

					if receiver  ne 'u' and remtrz.info[10] = string(intv) then
					do:
						message 'Банк не-участник, и номер счета Г/К = ' intv.
						pause.
						undo,retry.
						hide  message.
					end.
					remtrz.raddr = t-bankl.crbank.
					remtrz.cracc = bankt.acc.
				end.
				if remtrz.jh2 eq ? and  not (remtrz.rcbank = '' and (m_pid =  'P' or brnch)) then 
				do on error undo,retry :
					update remtrz.cracc with frame remtrz .
					find first bankt where bankt.acc = remtrz.cracc and bankt.crc = remtrz.tcrc and bankt.cbank = remtrz.rcbank no-lock no-error .
					if not avail bankt then
					do: 
						bell . undo ,retry . 
					end .
				end .
				if not (remtrz.rcbank = '' and (m_pid = 'P' or brnch )) then 
				do:
					if bankt.subl = "dfb" then 
					do:
						find first dfb where dfb.dfb = bankt.acc no-lock.
						remtrz.crgl = dfb.gl.
						find tgl where tgl.gl = remtrz.crgl no-lock.
					end.
					if bankt.subl = "cif" then 
					do:
						find first aaa where aaa.aaa = bankt.acc no-lock.
						remtrz.crgl = aaa.gl.
						find tgl where tgl.gl = remtrz.crgl no-lock.
					end.

					display remtrz.cracc remtrz.crgl tgl.sub remtrz.tcrc bcode with frame remtrz.
				end.

				find first bankl where bankl.bank = rbank no-lock no-error .
				if avail bankl and bankl.nu = "u" then 
				do:
					if not  (remtrz.rcbank  = '' and ( m_pid = 'P' or remtrz.source  = 'SVL')) then
					do:
						if outcode = 8 then 
						do:
							remtrz.rsub = "snip" .
							remtrz.bb[1] = bankl.name.
							remtrz.bb[2] = bankl.addr[1].
							remtrz.bb[3] = bankl.addr[2] + " " + bankl.addr[3].
						end.
						else 
						do:
							do on error undo,retry :
								if remtrz.rsub = "" then 
									remtrz.rsub = 'cif'.
								update remtrz.rsub validate(remtrz.rsub ne "","")  with  frame remtrz .
								if lookup(remtrz.rsub,sublist) = 0 then undo , retry .
							end .
							if remtrz.rsub ne "" then 
							do:
								if remtrz.rsub ne "snip" then 
								do:
									update remtrz.racc validate(remtrz.racc <> "" and chk-gosacc(remtrz.racc, remtrz.rbank), msg) with frame remtrz.
									remtrz.ba = "/" + remtrz.racc .

								end.
								remtrz.bb[1] = bankl.name.
								remtrz.bb[2] = bankl.addr[1].
								remtrz.bb[3] = bankl.addr[2] + " " + bankl.addr[3].
							end .
							else
							do:
								remtrz.rsub = "" . remtrz.ba = "" .
							end .
						end.
					end.
				end .
				else
				do:
					remtrz.rsub = "" .
				end .
				
				display remtrz.bb remtrz.rsub remtrz.ba remtrz.racc with frame remtrz . 
				pause 0 .


				find sw-bank where sw-bank.bank = remtrz.rcbank no-lock no-error. /*nan*/
				if available sw-bank then 
				do:
					if sw-bank.bic eq ? then Lswtdfb = false. else Lswtdfb = true.
				end.

				if Lswtdfb = false then 
				do:
					find aaa where aaa.aaa = remtrz.cracc no-lock no-error.
					if available aaa then 
					do:
						find cif of aaa.
						if available cif and cif.mail <> '' and (cif.geo = '011' or cif.geo = '012' or cif.geo = '013' ) then 
						do: 
							Lswtdfb = true. de6 = 1. 
						end.
					end.
				end.

		end. /* sasco - конец для mt100_0 */

		/*определим как отправлять платеж - клиринг, гросс, свифт******************************************************************************************************************/
		{mesg.i 4823}. /* запрос на клиринг, гросс, свифт и прочее */

		if (Lswtdfb ) and not brnch then remtrz.cover = 4.


		if remtrz.rcbank  = '' and m_pid =  'P' then   
		do:
			remtrz.valdt2  = ?.
			remtrz.racc = ''.
			remtrz.rsub = '' . 
			remtrz.cracc = ''.
			remtrz.crgl = 0.
			disp remtrz.valdt2 remtrz.racc remtrz.rsub remtrz.cracc remtrz.crgl with  frame remtrz.
		end .

		def var l-clr as log init false. /*по умолчанию банк по клирингу не работает*/
		find sysc where sysc.sysc = "netgro" no-lock no-error.
		find first bankl where bankl.bank = remtrz.rcbank no-lock no-error.
		if avail bankl then
		do:		
				/*09.06.2005 u00121 Проверим, работает ли банк-корреспондент банка получателя по клирингу*/
				find last comm.txb where comm.txb.consolid = true and comm.txb.path matches "*alm*"  no-lock no-error. /*"конектимся" к Алмате*/
				if avail comm.txb then
				do:
					if connected ("txb") then disconnect "txb".
					connect value("-H " + comm.txb.host + "  -S " + comm.txb.service + " -db " + comm.txb.path + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).

	        	                run findkorclr (input remtrz.rbank, output l-clr). /*запускаем программу проверки передав БИК банка получателя поле "БанкП", если банк-корреспондент работает по клирингу вернется значение true*/
			
					if connected ("txb") then disconnect "txb".
				end.
		end.

		if remtrz.cracc = lbnstr then 
		do :
			if (remtrz.payment ge sysc.deval or bankl.crbank ne "clear"  ) then 
				remtrz.cover  = 2 .
			else 
			do:

				if l-clr then  /*если банк-корреспондент работает по клирингу - отправляем клирингом*/
						remtrz.cover  = 1.
				else /*если не работает то отправляем Гросом*/
						remtrz.cover  = 2.
			end.
		end.
		else 
			remtrz.cover  = 4.

		if    (not brnch and bankl.nu = "u") or (brnch and remtrz.rbank begins "TXB") then 
			remtrz.cover = 5.
		
		if remtrz.rsub ne "snip" then 
		do :
			update remtrz.cover validate(((remtrz.cover ge 1 and remtrz.cover le 2) or (remtrz.cover eq 4 and Lswtdfb ) or (remtrz.cover eq 5)),  "") with frame remtrz.
			if remtrz.tcrc = 1 and remtrz.cover = 1 and ((remtrz.payment ge sysc.deval or bankl.crbank ne "clear"  ) or not l-clr) then 
			do : /*если платеж в тенге и транспорт клиринг а сумма привышает допустимую по клирингу или банк корреспондент не работает по нему, 
				или в при любой валюте и сумме банк-корреспондент не работает по клирингу (l-clr = false), то не даем отправлять  */
				if remtrz.payment ge sysc.deval then
				do:
					message "Сумма платежа (" + string(remtrz.payment) + ") привышает допустимую по клирингу (" + string(sysc.deval) + ") , можно отправить только по системе GROSS !" VIEW-AS ALERT-BOX TITLE "В Н И М А Н И Е".
					pause.
					undo, retry.
				end.
				else
					if not l-clr or  bankl.crbank ne "clear" then
					do:
						Message "Банк-получатель не работает по клирингу, платеж может быть отправлен только по системе GROSS !" VIEW-AS ALERT-BOX TITLE "В Н И М А Н И Е".
						pause.
						undo, retry.
					end.
			end.                 
		end.
		/*определим как отправлять платеж - клиринг, гросс, свифт******************************************************************************************************************/

		if remtrz.cover eq 4 then 
		do: /* SWIFT */
			/*------------------SWIFT START -----------------------*/
			if de6 = 0 then
				run swiftext(INPUT caps(trim(substr(sw-bank.bic, 3, 12))), INPUT 1, INPUT-OUTPUT result).
			else
				run swiftext(INPUT caps(trim(cif.mail)), INPUT 1, INPUT-OUTPUT result).


			if result ne 0 and not brnch  then 
			do:
				bell.
				undo, retry.
			end.               
			if remtrz.outcode eq 4 then 
				run swin("200").
			else
			do:
				if  m_pid = 'P' or brnch then 
					de6  = 1 .

				if de6 = 0 then 
				do:
					do on error undo,retry:
						form ootchoice with overlay row 10 1 col centered no-labels frame ootfr.
						display ootchoice with frame ootfr.
						choose field ootchoice AUTO-RETURN with frame ootfr.
					end. /* do on error */


					if FRAME-INDEX eq 1 then 
					do: 
                                               /*                    do on error undo,retry:
                                               find first bankl where bankl.bank = remtrz.rbank no-lock no-error. 
                                               if avail bankl then destination = caps(trim(substr(bankl.bic, 3, 12))).

                                               run swiftext2(INPUT destination, INPUT-OUTPUT result, INPUT-OUTPUT addrbank).

                                               if result ne 1 then do:
                                               bell.
                                               message "Не найден в справочнике такой банк корреспондент - " + destination. 
                                               pause.
                                               undo, retry.
                                               end.
                                               end.  do on error */

						dmt100 = "MT103". /* only one mt103 */
						if (not QUE_3G) or ((QUE_3G or QUE_TXB) and (not RKO_OUT)) then 
							run swin("103"). 
						if return-value <> "ok" then undo.
						/*                 realbic=destination.*/
					end.


					if FRAME-INDEX eq 2 then 
					do :

						dmt100 = "MT200".
						run swin("200").
						if return-value <> "ok" then undo.
						/*                 realbic=destination. */
					end.


					if FRAME-INDEX eq 3 then 
					do: 
                                               /*                    do on error undo,retry:
                                               find first bankl where bankl.bank = remtrz.rbank no-lock no-error. 
                                               if avail bankl then destination = caps(trim(substr(bankl.bic, 3, 12))).

                                               run swiftext2(INPUT destination, INPUT-OUTPUT result, INPUT-OUTPUT addrbank).

                                               if result ne 1 then do:
                                               bell.
                                               message "Не найден в справочнике такой банк корреспондент - " + destination. 
                                               pause.
                                               undo, retry.
                                               end.
                                               end.  do on error */

						dmt100 = "MT202".
						run swin("202").
						if return-value <> "ok" then undo.
	
						/*                 realbic=destination.*/
					end.
		
					if FRAME-INDEX eq 4 then 
					do: 
						dmt100 = "MT202MT103".
						l-doubleswift = True.
						run swin1("202").
						if return-value <> "ok" then undo.
						if (not QUE_3G) or ((QUE_3G or QUE_TXB) and (not RKO_OUT)) then 
							run swin1("103").
						if return-value <> "ok" then undo.
					end.


				end.
				else 
				do: 
					dmt100 = "ONE".
					
					/* sasco */
						if (not QUE_3G) or ((QUE_3G or QUE_TXB) and (not RKO_OUT)) then run swin("103").
					
				end.
			end.

			if lastkey eq keycode('pf4') then undo,retry.
			/*------------------SWIFT STOP  -----------------------*/
		end.

		else 
		do: /* remtrz.cover ne 4 */
			if remtrz.cover ne 21 then  /* ja 15/06/01 */ 
			do on error undo,retry:

				if remtrz.source = 'SVL' or (remtrz.rsub eq  "" and  not ( remtrz.cracc eq lbnstr and remtrz.cover = 3 )) then 
				do:
					disp s-bankl label "БанкП"
						remtrz.bb label "Банк получ"
						remtrz.ba label "Счет получ"
						v-sub validate (v-sub = "" or can-find (budcodes where code = inte(v-sub) no-lock), " Неверный код бюджетной классификации")
						with centered row 14 1 col overlay top-only frame bnkx1.

					if remtrz.rsub ne "snip" then 
						update s-bankl with frame bnkx1.
				end.
				if s-bankl ne "" then  
				do:
					find bankl where bankl.bank = trim(s-bankl) no-lock no-error.
					if not avail bankl then 
						find bankl where bankl.bank = bbcod + trim(s-bankl) no-lock no-error.
						if available bankl then 
						do:
							remtrz.bb[1] = bankl.name.
							remtrz.bb[2] = bankl.addr[1].
							remtrz.bb[3] = bankl.addr[2] + " " + bankl.addr[3].
						end.
				end .
				
				if not remtrz.ba begins "/" then 
					remtrz.ba = "/" + remtrz.ba .
				if index(remtrz.ba,"/",2) <> 0 then 
				do :
					v-sub = substr(remtrz.ba,index(remtrz.ba,"/",2) + 1) .
					remtrz.ba = substr(remtrz.ba,1,index(remtrz.ba,"/",2) - 1) .
				end .
				if index(remtrz.rcvinfo[1],"/TAX/") <> 0 then 
				do :
					v-kind = "Налог" .
					substr(remtrz.rcvinfo[1],index(remtrz.rcvinfo[1],"/TAX/"),5) = " " .
				end .
				if index(remtrz.rcvinfo[1],"/PSJ/") <> 0 then 
				do :
					v-kind = "Пенсия" .
				end.
				else 
					v-kind = "Норм." .
				if remtrz.rsub eq  ""  and (remtrz.cracc eq lbnstr or brnch) and remtrz.cover ne 4 then 
				do :

					update remtrz.bb with frame bnkx1.
					/* ----------------------------------------- */
					if (brnch and remtrz.tcrc <> 1 and remtrz.rbank <> clearing) then 
					do: 
						update remtrz.ba validate(chk-gosacc(remtrz.ba, remtrz.rbank), msg) with frame bnkx1.
						update v-sub validate (v-sub = "" or can-find (budcodes where code = inte(v-sub) no-lock), " Неверный код бюджетной классификации") with frame bnkx1.
					end.
					else 
					do:
						do on error undo, retry :
							v-o = no.
							if trim(remtrz.ba) begins "/" then
								remtrz.ba = trim(remtrz.ba,"/").
								update remtrz.ba validate(chk-gosacc(remtrz.ba, remtrz.rbank), msg) with frame bnkx1.
								if length(trim(remtrz.ba)) <> 9 then 
								do:
									message "Счет должен быть 9 цифр !".
									bell. bell.
									undo, retry.
								end.
								/*
								update v-sub validate (v-sub = "" or can-find (budcodes where code = inte(v-sub) no-lock), " Неверный код бюджетной классификации") with frame bnkx1.
								if not (length(v-sub) = 6 or v-sub = "") then 
								do:
									message "Введите 6 цифр !". bell. bell.
									undo, retry.
								end.
								*/

								run acc-ctr(input trim(remtrz.ba),remtrz.rbank, output v-o).
								if not v-o then 
								do :
									message "Введите счет верно ! ". pause.
									undo, retry.
								end.
						end.
					end.       
					/* ----------------------------------------- */
				end.  /*  remtrz.rsub eq  ""  and  ....   */ 
				else 
					if remtrz.rsub ne "snip" then
					do:
						disp s-bankl label "БанкП" remtrz.bb label "Банк получ" remtrz.ba label "Счет получ" v-sub with centered row 14 1 col overlay top-only frame bnkx.
						update remtrz.ba validate(chk-gosacc(remtrz.ba, remtrz.rbank), msg) 
							v-sub validate (v-sub = "" or can-find (budcodes where code = inte(v-sub) no-lock), " Неверный код бюджетной классификации")
								with frame bnkx.
					end . 



				if v-sub <> "" then
					remtrz.ba = remtrz.ba + "/" + v-sub .

					/*
                                remtrz.rcvinfo[1] = "/PSJ/ ".
                                remtrz.source = "PNJ".
                                remtrz.rsub = "cif".


                                if remtrz.rsub eq  ""  and not ( remtrz.cracc eq lbnstr and remtrz.cover = 3 ) or remtrz.rsub ne "snip" then 
				do :
					form kindchoice with overlay top-only row 17 1 col column 66 no-labels frame xxx.
					do on error undo,retry :
						display kindchoice with frame xxx.
						choose field kindchoice keys v-kind no-error with frame xxx .
						v-kind = frame-value .
						if (index(remtrz.rcvinfo[1],"/PSJ/") <> 0 or substr(trim(replace(remtrz.ba,"/"," ")),1,9) matches "...080..." ) and v-kind = "Норм." then 
						do :
							Message "Неверный тип платежа.Счет получателя налоговый. Нажмите F4".
							pause.
							undo,retry .
						end.
                                		if (v-sub = "" or index(remtrz.rcvinfo[1],"/PSJ/") <> 0 ) and v-kind = "Налог" then 
						do :
							Message "Нет субсчета или платеж пенсионный.Нажмите F4".
							pause.
							undo,retry .
						end.
					end .
				end .
				*/

				if v-kind = "Налог" then
					remtrz.rcvinfo[1] = "/TAX/ " + trim(remtrz.rcvinfo[1]) .

				if v-kind = "Пенсия" and trim(remtrz.rcvinfo[1]) ne "/PSJ/ " then
				do :
					Message "Платеж не зарегистрирован как пенсионный.".
					undo, retry.
				end.
			end.  /* do on error */                   

			disp   remtrz.bb remtrz.ba v-kind  with frame remtrz.
			pause 0.

			qq = remtrz.bn[1] + remtrz.bn[2] + remtrz.bn[3].
			if index(qq,"/RNN/") ne 0 then 
			do :
				v-id = substr(qq,index(qq,"/RNN/") + 5,13 ).
				qq = substr(qq,1,index(qq,"/RNN/") - 1).
			end.

			if length(qq) > 60 then v-longrnn = true.

			/* sasco сообщение о длинном наименовании получателя 21/10/04 */
			if v-longrnn then 
				message "~n ~n Длина наименования получателя превышает 60 символов!!!~n ~n " VIEW-AS ALERT-BOX TITLE "В Н И М А Н И Е". 

			v-bn[1] = substr(qq,1,35).
			v-bn[2] = substr(qq,36,35).
			v-bn[3] = substr(qq,71,35).
			t-rcv = index(remtrz.rcvinfo[1],"/COD/") .
			if t-rcv > 0 then 
			do :
				if substr(remtrz.rcvinfo[1],length(remtrz.rcvinfo[1]),1) <> " " then
						remtrz.rcvinfo[1] = remtrz.rcvinfo[1] + " " .
				v-inc = substr(remtrz.rcvinfo[1], t-rcv + 5, index(remtrz.rcvinfo[1]," ",t-rcv) - t-rcv - 4) .
				substr(remtrz.rcvinfo[1], t-rcv , index(remtrz.rcvinfo[1]," ",t-rcv) - t-rcv + 1) = " " .
			end .
			if remtrz.rsub ne "snip" then 
			do on error undo, retry :
				if remtrz.ba = "/" or remtrz.ba = "" then 
				do :
					qq = remtrz.bn[1] + remtrz.bn[2] + remtrz.bn[3] .
					v-9d = substr(qq,index(qq,"/RNN/") + 5) .
					qq = substr(qq,1,index(qq,"/RNN/") - 1).

					/* sasco сообщение о длинном наименовании получателя 21/10/04 */
					if length (qq) > 60 then v-longrnn = true.
					if v-longrnn then 
						message "~n ~n Длина наименования получателя превышает 60 символов!!!~n ~n " VIEW-AS ALERT-BOX TITLE "В Н И М А Н И Е". 

					v-9c = substr(qq,1,35) .
					v-9e = substr(qq,36,35) .
					v-9f1 = substr(qq,71,35) .
					v-9f2 = substr(qq,106,35) .

					update v-9c validate(v-9c ne '',"") v-9d validate( not comm-rnn (v-9d), "Не верный контрольный ключ РНН!") v-9e validate(v-9e ne '',"") v-9f1 v-9f2 with centered 1 column  overlay row 5 side-label frame frmsnip.

					qq = "" .
					substr(qq,1,35) = v-9c .
					substr(qq,36,35) = v-9e .
					substr(qq,71,35) = v-9f1 .
					substr(qq,106,35) = v-9f2 .
					v-id = v-9d .
					v-bn[1] = substr(qq,1,60) .
					v-bn[2] = substr(qq,61,60) .
					v-bn[3] = substr(qq,121,60) .
				end .
				else 
				do :
					/* sasco сообщение о длинном наименовании получателя 21/10/04 */
					displ v-bn v-id with centered row 15 1 col overlay top-only frame frminc. pause 0.

					if v-longrnn then 
						message "~n ~n Длина наименования получателя превышает 60 символов!!!~n ~n " VIEW-AS ALERT-BOX TITLE "В Н И М А Н И Е". 

					update  v-bn with centered row 15 1 col overlay top-only frame frminc.
					if remtrz.tcrc eq 1 then 
					do:
						update v-id validate (length(v-id) eq 12,"РНН должен быть 12 цифр") with centered row 15 1 col overlay top-only frame frminc.
						run rnnchk( input v-id,output v-rnn).
						if v-rnn then 
						do :
							message "Не верный контрольный ключ РНН!". pause.
							undo, retry.
						end.
					end.
					if v-inc <> "" then
						remtrz.rcvinfo[1] = "/COD/" + v-inc + " " + trim(remtrz.rcvinfo[1]) .
				end .
				
				if not ( remtrz.cracc eq lbnstr and remtrz.cover = 3 ) then
					update remtrz.ord with frame remtrz .
				remtrz.bn[1] = v-bn[1].
				remtrz.bn[2] = v-bn[2].
				if trim(v-id) = "" then 
					remtrz.bn[3] = v-bn[3].
				else
					remtrz.bn[3] = v-bn[3] + " " + "/RNN/" + trim(v-id).
			end.  /*   snip   */ 
			else 
			do:
				if remtrz.info[3] ne "" then 
				do:
					v-9c  = substr(entry(3,remtrz.info[3],"^"),4,35) .
					v-9d  = substr(entry(4,remtrz.info[3],"^"),4,35) .
					v-9e  = substr(entry(5,remtrz.info[3],"^"),4,35) .
					v-9f1 = substr(entry(6,remtrz.info[3],"^"),4,35) .
					v-9f2 = substr(entry(6,remtrz.info[3],"^"),39,35) .
					v-drg = substr(entry(2,remtrz.info[3],"^"),4,2) .
				end.
				if v-drg = "" then 
					v-drg = "01" . 
				update v-9c validate(v-9c ne '',"") /* sasco - RNN check */ v-9d validate( not comm-rnn (v-9d), "Не верный контрольный ключ РНН!") v-9f1 v-9f2 v-drg format "99" 
					with centered 1 column  overlay row 5 side-label 
						title " Получатель " frame snip .
				remtrz.info[3] = "11B^3f:" + v-drg + "^9C:" + v-9c + "^9D:" +  v-9D + "^9E:" + v-9E + "^9F:" + v-9f1 + v-9f2 . 
				remtrz.bn[1] = v-9c .
				remtrz.bn[2] = v-9d .
				remtrz.bn[3] = v-9e .
				if entry(2,remtrz.rcvinfo[1]," ") = "days" then
					entry(1,remtrz.rcvinfo[1]," ") = v-drg .
				else
					remtrz.rcvinfo[1] = v-drg + " days " + rcvinfo[1] .
				remtrz.ref =  "single     SNIP payment       " + remtrz.remtrz.
				if remtrz.outcode ne  8 then 
					update remtrz.ord  validate(remtrz.ord ne "","")  with frame remtrz . 
			end.
			remtrz.ben[1] = trim(remtrz.bn[1]) + " " + trim(remtrz.bn[2]) + " " + trim(remtrz.bn[3]).
			remtrz.ordcst[1] = remtrz.ord.
			find bankl where bankl.bank = remtrz.sbank no-lock no-error.
			if available bankl and ( remtrz.ordins[1] = "" or ( remtrz.cracc eq lbnstr and remtrz.cover = 3 )) then 
			do:
				if  m_pid <> 'P' or (m_pid = 'P' and remtrz.tcrc <> 1) then 
				do:
					remtrz.ordins[1] = bankl.name.
					remtrz.ordins[2] = bankl.addr[1].
					remtrz.ordins[3] = bankl.addr[2].
					remtrz.ordins[4] = bankl.addr[3].
				end.
			end.        

			if available bankl and remtrz.tcrc eq 1 and m_pid  = 'P' then 
			do:

				if  ordins[1] = '' then 
				do:
					find ofc where ofc.ofc = g-ofc no-lock no-error.
					vpoint = ofc.regno / 1000 - 0.5.
					vdep   = ofc.regno - vpoint * 1000.
					find point where point.point = vpoint no-lock no-error.
					remtrz.ordins[1] = point.name.
					find ppoint where  ppoint.depart = vdep and ppoint.point = vpoint no-lock no-error.
					remtrz.ordins[2] = ppoint.name.
					remtrz.ordins[3] = point.addr[1].
					find sysc where sysc.sysc = "swadd4" no-lock.
					remtrz.ordins[4] = sysc.chval.
				end.
				if remtrz.cover ne 5 then 
						update remtrz.ordins label "Банк отпр." with overlay top-only row 8 1 col centered frame ads.
			end.

			if not ( remtrz.cracc eq lbnstr and remtrz.cover = 3 ) and m_pid <> 'P' and remtrz.cover ne 5 then
				update remtrz.ordins label "Банк отпр."
			
			with overlay top-only row 8 1 col centered frame ads.
			update text(remtrz.detpay[1] label "Назначение платежа" remtrz.detpay[2] no-label remtrz.detpay[3] no-label remtrz.detpay[4] no-label) with overlay top-only row 8 centered frame adsd.           

			/* Формируем файл и присваиваем тип PSJ */

			run crearpz. 

                        remtrz.rcvinfo[1] = "/PSJ/ ".
                        remtrz.source = "PNJ".

                        def var  pf_file as char.
                        def var  v-result as char.

                        find first bank.sysc where bank.sysc.sysc = "PSJIN" no-lock.
                        if avail bank.sysc then 
                             pf_file = trim(bank.sysc.chval) + trim(remtrz.remtrz).
                        else do:
                             message 'Ошибка настроек для транспортировки зарплатного файла: ' + remtrz.remtrz view-as alert-box  .
                        end.
                        /*
                        if search(remtrz.remtrz) = ? then do: 
                             message   'Ошибка транспортировки исходного зарплатного файла: ' + remtrz.remtrz view-as alert-box.
                        end.
                        */
                        input through value ("cp " + remtrz.remtrz + " " + pf_file + " ;echo $?" ). 
                        repeat:
                          import v-result.
                        end.
                        /*
                        if search(pf_file) = ? then do: 
                             message   'Ошибка транспортировки зарплатного файла: ' + remtrz.remtrz view-as alert-box.
                        end.
                        */

			if not ( remtrz.cracc eq lbnstr and remtrz.cover = 3 ) and remtrz.cover ne 5 then   
			do on error undo,retry:
				if remtrz.rcvinfo[1] = "" then 
					remtrz.rcvinfo[1] = remtrz.dracc .

				display      /* O72 - Sender to receivers information */
					remtrz.rcvinfo[1] format "x(35)"
					remtrz.rcvinfo[2] format "x(35)"
					remtrz.rcvinfo[3] format "x(35)"
					remtrz.rcvinfo[4] format "x(35)"
					remtrz.rcvinfo[5] format "x(35)"
					remtrz.rcvinfo[6] format "x(35)"
						with overlay top-only row 13 column 41 no-labels 1 col title "Межбанковская информация" frame ff72.

				update      /* O72 - Sender to receivers information */
					remtrz.rcvinfo[2] 
					remtrz.rcvinfo[3] 
					remtrz.rcvinfo[4] 
					remtrz.rcvinfo[5] 
					remtrz.rcvinfo[6] 
						with frame ff72.
			end. /* do on error */

			if not ( remtrz.cracc eq lbnstr and remtrz.cover = 3 ) and remtrz.cover ne 5 then          
			do:
				form F71choice with overlay top-only row 17 1 col column 12 no-labels frame x.
				display F71choice with frame x.
				choose field F71choice AUTO-RETURN with frame x.
				remtrz.bi = FRAME-VALUE.
				display remtrz.bi with frame remtrz.
			end.
			else 
			do :
				if remtrz.bi = "" then 
					remtrz.bi = "NON" . 
			end.
		end.        /* cover ne 4  */


		disp remtrz.bb remtrz.ba remtrz.bn remtrz.ord remtrz.bi with frame remtrz.
		if m_pid = "P" then   pause.
/* end of today change  PNP 29/01/96    */
end.
/*          !!!!!!!!!!!!!!!!!!!!!!!        start
else
if  not (  m_pid eq "3"  and remtrz.rbank = "" ) then

/* RECEIVER -  OUR BANK  */

do on error undo ,retry :
remtrz.cover = 9.
display remtrz.cover with frame remtrz. pause 0 .
remtrz.raddr = "".  remtrz.rcbank = "".
display /* remtrz.raddr */ remtrz.rcbank with frame remtrz.
receiver = "o".
if remtrz.jh2 eq ? then
update remtrz.crgl validate(can-find(gl where gl.gl = remtrz.crgl ),"")
with frame remtrz .
find tgl where tgl.gl = remtrz.crgl no-lock.
display remtrz.crgl tgl.sub with frame remtrz.
if tgl.sub ne "" then
do on error undo,retry :
if remtrz.jh2 eq ? then
update remtrz.cracc validate(remtrz.cracc ne "","")
with frame remtrz .
find gl where gl.gl = tgl.gl.
c-acc = remtrz.cracc . {pschk.i} .
if c-acc = "" then do: bell. undo ,retry . end.
else do : remtrz.tcrc = vv-crc .
remtrz.racc = remtrz.cracc .
display remtrz.racc with frame remtrz.
find bank.crc where crc.crc = vv-crc no-lock.  bcode =
crc.code . 
if tgl.sub = "cif" then do:
find first aaa where aaa.aaa = remtrz.cracc no-lock .
find cif of aaa no-lock .
if remtrz.bn[1] = "" then 
remtrz.bn[1] = trim(trim(cif.prefix) + " " + trim(cif.name)).
end.
end.
end.
else do: remtrz.cracc = "" .  remtrz.racc  = string(remtrz.crgl) .
display remtrz.cracc remtrz.racc with frame remtrz.
if remtrz.jh1 eq ? then
update remtrz.tcrc validate( can-find(crc where crc.crc =
remtrz.tcrc no-lock ),"") 
with frame remtrz.
find bank.crc where crc.crc = remtrz.tcrc no-lock. 
bcode = crc.code .             end.
display remtrz.tcrc bcode with frame remtrz .
if remtrz.valdt2 = ? then
remtrz.valdt2 = remtrz.valdt1  .

if remtrz.jh2 eq ? then
update remtrz.valdt2 validate(remtrz.valdt2 >= remtrz.valdt1,
" Valdt2 < valdt1 ")
with frame remtrz. pause 0 .
/*    end.      */

find bankl where bankl.bank = remtrz.rbank no-lock no-error.
if available bankl then do:
/*             message "Изменение remtrz.bb [6]" view-as alert-box. */
remtrz.bb[1] = bankl.name.
remtrz.bb[2] = bankl.addr[1].
remtrz.bb[3] = bankl.addr[2] + " " + bankl.addr[3].
end.
find bankl where bankl.bank = remtrz.sbank  no-lock no-error.
if available bankl and remtrz.ordins[1] = "" then do:
remtrz.ordins[1] = bankl.name.
remtrz.ordins[2] = bankl.addr[1].
remtrz.ordins[3] = bankl.addr[2].
remtrz.ordins[4] = bankl.addr[3].
end.
update
remtrz.ordins label "Банк отпр."
/*  remtrz.ordins[1]  */
with overlay top-only row 8 1 col centered frame ads.
if remtrz.ba = "" then remtrz.ba = remtrz.racc .
update remtrz.ba validate(chk-gosacc(remtrz.ba, remtrz.rbank), msg) remtrz.bn remtrz.ord 
validate(remtrz.ord ne "","Введите наименование")
with frame remtrz.

display      /* O72 - Sender to receivers information */
remtrz.rcvinfo[1] format "x(35)"
remtrz.rcvinfo[2] format "x(35)"
remtrz.rcvinfo[3] format "x(35)"
remtrz.rcvinfo[4] format "x(35)"
remtrz.rcvinfo[5] format "x(35)"
remtrz.rcvinfo[6] format "x(35)"
with overlay top-only row 13 column 41 no-labels 1 col
title "Межбанковская информация"
frame ff72.

update      /* O72 - Sender to receivers information */
remtrz.rcvinfo[2]
remtrz.rcvinfo[3]
remtrz.rcvinfo[4]
remtrz.rcvinfo[5] 
remtrz.rcvinfo[6] 
with frame ff72.

disp remtrz.bb remtrz.ba remtrz.bn remtrz.ord
remtrz.bi with frame remtrz.  pause 0 .
end .
/* end of    receiver = "o" */

!!!!!!!!!!!!!           */
/*
end .

pause 45678 .   */
/*
if m_pid <> "S" then do:
update v-priory validate(lookup(trim(v-priory),prilist) ne 0 ,
prilist) with frame rortrz.
end.    */

/*

do on error undo.
update remtrz.amt validate ( remtrz.amt >= 0 ," " )
with frame remtrz .

if remtrz.amt = 0 then do:
update remtrz.payment validate ( remtrz.payment > 0, "")
with frame remtrz .
end. else remtrz.payment = 0 .
end.
if remtrz.fcrc ne remtrz.tcrc then do on error undo :
/*  FOREIGN EXCANGE */

if remtrz.drgl eq v-cashgl then
b = 2.
else b = 4.

if remtrz.crgl eq v-cashgl then
s = 3.
else s = 5.


find crc where crc.crc = 1 no-lock.
find fcrc where fcrc.crc = remtrz.fcrc no-lock.
vfb-rate = fcrc.rate[b].
vf1-rate = fcrc.rate[1].
find tcrc where tcrc.crc = remtrz.tcrc no-lock.
vts-rate = tcrc.rate[s].
vt1-rate = tcrc.rate[1].


if remtrz.amt eq 0 then do:
remtrz.amt = round( remtrz.payment * vts-rate / tcrc.rate[9] , crc.decpnt).
remtrz.amt = round( remtrz.amt / vfb-rate * fcrc.rate[9] , fcrc.decpnt).
end.
else do:
t-pay = round( remtrz.amt * vfb-rate / fcrc.rate[9] , crc.decpnt).
remtrz.payment = round(t-pay / vts-rate * tcrc.rate[9] , tcrc.decpnt).
end.
t-pay = round( remtrz.amt * vfb-rate / fcrc.rate[9] , crc.decpnt).
remtrz.margb  = round( remtrz.amt * vf1-rate / fcrc.rate[9] , crc.decpnt) -
t-pay.
remtrz.margs = round(
t-pay * ( 1 - vt1-rate / vts-rate ) , crc.decpnt).
t-pay = margb + margs .

/* end of FOREIGN EXCHANGE */
end.
else
do:
if remtrz.amt ne 0 then remtrz.payment = remtrz.amt .
else remtrz.amt = remtrz.payment .
remtrz.margb = 0.
remtrz.margs = 0.
end.

display remtrz.amt remtrz.payment /* remtrz.margb remtrz.margs t-pay */
with frame remtrz .


do on error undo , retry :
if remtrz.svcrc eq ? or remtrz.svcrc = 0  then remtrz.svcrc = remtrz.fcrc .
if m_pid <> "S" then do :
update remtrz.svcrc validate(remtrz.svcrc > 0 ,"" )  with frame remtrz.
update remtrz.svccgr with frame remtrz .
if remtrz.svccgr > 0 then do:
run comiss.
find first tarif2 where trim(tarif2.num) + trim(tarif2.kod) = string(remtrz.svccgr) 
and tarif2.stat = "r" no-lock no-error .
if avail tarif2 then pakal = tarif2.pakalp .
display remtrz.svccgl pakal with frame remtrz .
update remtrz.svca with frame remtrz.
end.
end.

if remtrz.svca > 0 and m_pid <> "S" then do:

if sender = "o" and remtrz.dracc ne "" and remtrz.svcrc = remtrz.fcrc
and remtrz.svcaaa eq "" and
( remtrz.svcgl = 0 or remtrz.svcgl = remtrz.drgl )
then  remtrz.svcaaa = remtrz.dracc .

if receiver = "o" and remtrz.cracc ne "" and remtrz.svcrc = remtrz.tcrc
and remtrz.svcaaa eq "" and
( remtrz.svcgl = 0 or remtrz.svcgl = remtrz.crgl )
then  remtrz.svcaaa = remtrz.cracc .
do on error undo,retry :
update remtrz.svcaaa with frame remtrz.
if remtrz.svcaaa ne "" then do:
find first aaa where aaa.aaa = remtrz.svcaaa and aaa.crc = remtrz.svcrc
no-lock no-error .
if not avail aaa then undo,retry .
end.
end.
if remtrz.svcaaa eq ""
then do:


/*
if remtrz.svcgl = 0 then remtrz.svcgl = remtrz.drgl .
do on error undo , retry :
update remtrz.svcgl with frame remtrz .
find first gl where gl.gl = remtrz.svcgl and gl.sub = "" no-lock
no-error .
if not avail gl then undo , retry .
end .
*/

remtrz.svcgl = v-cashgl.
Message "Комиссионные будут взяты через кассу!" .
pause .
end .
else
do :
find aaa where aaa.aaa = remtrz.svcaaa no-lock .
remtrz.svcgl = aaa.gl .
end.
do on error undo,retry :
update svccgl  with frame remtrz .

find first gl where  gl.gl = remtrz.svccgl and gl.sub eq "" no-lock
no-error .
if not avail gl then undo,retry .
end.
end.
else
do:
remtrz.svcrc = 0 . remtrz.svcgl = 0 . remtrz.svcaaa = "" .
remtrz.svccgl = 0.
end.

display remtrz.svcrc remtrz.svcaaa remtrz.svccgl remtrz.svca with frame remtrz.
end.     /*   undo service charge   */

*/

v-bb = trim(remtrz.bb[1]) + " " 
+ trim(remtrz.bb[2]) + " " + trim(remtrz.bb[3]) .

remtrz.actins[1]  = "/" + substr(v-bb,1,35) .
remtrz.actins[2]  = substr(v-bb,36,35) .
remtrz.actins[3]  = substr(v-bb,71,35) .
remtrz.actins[4]  = substr(v-bb,106,35) .
remtrz.actinsact  = remtrz.rbank .

if remtrz.rcbank = "" then remtrz.rcbank = remtrz.rbank . 
if remtrz.scbank = "" then remtrz.scbank = remtrz.sbank .

find first bankl where bankl.bank = remtrz.scbank  no-lock no-error .
if avail bankl then 
if bankl.nu = "u" then sender  = "u". else sender  = "n" .
find first bankl where bankl.bank = remtrz.rcbank no-lock no-error .
if avail bankl then
if bankl.nu = "u" then receiver  = "u". else receiver  = "n" .

if remtrz.scbank = ourbank then sender = "o" .   
if remtrz.rcbank = ourbank then receiver  = "o" .


find first ptyp where ptyp.sender = sender and
ptyp.receiver = receiver no-lock no-error .
if avail ptyp then
remtrz.ptype = ptyp.ptype.
else remtrz.ptype = "N".


/* ------------ SASCO ******************** */
/* принудительно пишем тип = "6" так как это платеж
типа "Наш Банк -- Не Участник"
(в remtrz нет достаточно информации для автом. определения) */
if RKO_VALOUT() and (not (QUE_3G or QUE_TXB)) then remtrz.ptype = "6".
else do:

if sender = "o" and receiver = "o" then remtrz.ptype = "M".


find first ptyp where ptyp.ptype = remtrz.ptype no-lock .
find first que where que.remtrz = remtrz.remtrz exclusive-lock no-error .
display  remtrz.ptype ptyp.des remtrz.cover with frame remtrz.
end. /* --- sasco ***  */

run rmzque.

v-text = remtrz.remtrz + " тип=" + remtrz.ptype + 
" обработан "   + g-ofc  + ' ' + remtrz.rcbank.
run lgps .
release logfile . 
end . 

do transaction : 
def var yn as log initial false format "Да/Нет".
def var ok as log format "Да/Нет".

if remtrz.ptype eq ""  then do:
Message " Не определен тип платежа! Отправка невозможна." . pause .
return .
end.


yn = false . 


/* sasco */
/* если не 3G или АлматыРКОВалюта */
if not QUE_3G and RKO_VALOUT() then run out-mt100. /* BY SASCO */
if (QUE_3G or QUE_TXB) and remtrz.source = "RKO" then
do:
remtrz.source = "O".
v-text = remtrz.remtrz + " Источник remtrz изменен: RKO -> O".
run lgps.
end.


if ( m_pid = "3g" or m_pid = "G" or (m_pid = "3" and remtrz.source = "SW")) 
and sw then  
Message "Обработать?" update yn .

if yn then do  :
find first que where que.remtrz = s-remtrz exclusive-lock no-error .
if avail que and ( que.pid ne m_pid or que.con eq "F" ) then  do:
Message "Не владелец! Отправка невозможна." . pause .
undo.
release que .
return .
end.

if avail que then do :
find  first  remtrz  where remtrz.remtrz = s-remtrz exclusive-lock .

/* by sasco :  проверка OUTGOING для всех платежей кроме RKO && TXB00
так как у них не вводится банк корр и другие данные :-) */
If (remtrz.valdt2 eq ? or remtrz.cracc eq "" or remtrz.crgl eq 0 or
remtrz.rcbank eq "") and (not RKO_VALOUT() or QUE_3G ) then
do:
message "Вы должны сначала выполнить OUTGOING!" .  pause .
undo .
release que .
release remtrz .
return .
end.

/*  {canbal.i}
{nbal+r.i} */

scod = "ok".  /* by sasco - default value */

if (not brnch) and (not RKO_VALOUT () ) then do:
if remtrz.cover lt 4 then do:
/*
run rmtlxp.
*/
v-text = remtrz.remtrz + " TELEX сообщение сформированно " + g-ofc .
/*
run lgps .
*/
end.
else do:
if remtrz.cover eq 4 /*ja*/ and not brnch /*ja*/ then do:

if remtrz.outcode eq 4 or dmt100  = "MT200" then do :
RUN swmt-cre(s-remtrz,g-today,"send","200",s-sqn,scod).

if scod = "ok" then do : 
v-text = remtrz.remtrz + " MT200 SWIFT " + s-sqn  
+ " сообщение сформированно " + g-ofc .
run lgps .
end.
end.

else case dmt100:
when "MT100" then do:
s-sqn = "" . 
RUN swmt-cre(s-remtrz,g-today,"send","100",s-sqn,scod).

if scod = "ok" then do :
v-text = remtrz.remtrz + " SWIFT " + s-sqn + 
" сообщение сформированно " + g-ofc .   
run lgps .
end.
pause 0.
end.
when "MT202" then do:
RUN swmt-cre(s-remtrz,g-today,"send","202",s-sqn,scod).
if scod = "ok" then do :
v-text = remtrz.remtrz + " MT202 SWIFT " + s-sqn + 
" сообщение сформированно " +   g-ofc.
run lgps .
end.
end.
when "MT103" then do:
s-sqn = "" .
RUN swmt-cre(s-remtrz,g-today,"send","103",s-sqn,scod).
if scod = "ok" then do :
v-text = remtrz.remtrz + " SWIFT " + s-sqn + 
" сообщение сформированно " + g-ofc .   
run lgps .
end.
pause 0.
end.

when "MT202MT103" then do:

RUN swmt-cre1(s-remtrz,g-today,"send","202",s-sqn,scod).
if scod = "ok" then do :
v-text = remtrz.remtrz + " MT202 SWIFT " + s-sqn + 
" сообщение сформированно " +   g-ofc.
run lgps .
end.
s-sqn = "" .
RUN swmt-cre1(s-remtrz,g-today,"send","103",s-sqn,scod).
if scod = "ok" then do :
v-text = remtrz.remtrz + " SWIFT " + s-sqn + 
" сообщение сформированно " + g-ofc .   
run lgps .
end.
pause 0.


end.
end case.

end.
end.
end. 

if (scod ne "ok") and (remtrz.cover = 4) and not brnch then do:
v-text = "Ошибка SWSEND! SWIFT сообщение не было отправлено для " 
+ remtrz.remtrz + "." .
run lgps.
Message v-text . pause .
end.
else 
do:
que.pid = m_pid.

/* sasco -  проверка на РКО и TXB00 */
if RKO_VALOUT() = true then
do:
if remtrz.tcrc = 1 then que.rcod = "0".
else que.rcod = "1".
end.
else que.rcod = "0".

v-text = " Отсылка " + remtrz.remtrz + 
" по маршруту , код возврата = " + que.rcod  .
run lgps.
que.con = "F".
que.dp = today.
que.tp = time.

release que .
remtrz.cwho = g-ofc.

{koval-vsd.i}

end.
end.
pause 0 .
end .
end . 


run zp1-rotrz. 