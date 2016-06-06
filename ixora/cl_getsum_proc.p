/* CLGetSumProc.p
 * MODULE
        Кредитный лимит - скоринг
 * DESCRIPTION
        
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        3.1.1
 * AUTHOR
        20/03/2013 anuar
 * BASES
        COMM TXB
 * CHANGES
				08.04.2013 anuar - Получение суммы платежа в текущем месяце для бизнес-процессов установление/изменение                            кредитного лимита
						               Получение количества просрочек и дней просрочек
													 Получение данных о блокировке ПТП, картотеки

				27.08.2013 anuar - ТЗ 2046 - отправка данных ИИН, номера договора и одобренной суммы из заявки в таблицу pc_lncontr
				12.09.2013 anuar - ТЗ 2060 - отправка номера счета, даты установления лимита в OW, даты начала КД, даты окончания КД, ГЭСВ по КД из заявки в таблицу pc_lncontr
				25.11.2013 anuar - добавил crtype = '4'

*/

{chk12_innbin.i}
def shared var vIsIinExist	as logical			no-undo.
def shared var vIin					as character		no-undo. /* Иин сотрудника*/
def shared var vSum					as character		no-undo. /* Сумма платежа в текущем месяце */
def shared var vDays				as character		no-undo. /* Количество дней просрочек */
def shared var vCounts			as character		no-undo. /* Количество просрочек */ 
def shared var vBlock				as character		no-undo. /* Блокировка ПТП, картотека */  
def shared var vBranch			as character		no-undo. /* Филиал вида TXB## */

def shared var vProcNum     as character		no-undo. /* Номер процесса, он же номер договора */
def shared var vLim			    as character		no-undo. /* Сумма кредитного лимита */

def shared var vAcc					as character		no-undo. /* Дата установления лимита в OW по кредитному договору */
def shared var vOwLimdt			as date					no-undo. /* Дата установления лимита в OW по кредитному договору */
def shared var vStdate			as date     		no-undo. /* Дата начала кредитного договора */
def shared var vEdate 			as date					no-undo. /* Дата окончания кредитного договора */
def shared var vEff_  			as character		no-undo. /* ГЭСВ по кредитному договору, % */

/*-------------------*/

def shared var vErrorsProgress as char no-undo.

def shared var g-today2 as date no-undo.

def temp-table wrk no-undo
 field dt		as date
 field od		as deci
 field prc	as deci
 field prc3	as deci
 field koms as deci
 index idx	is primary dt.

def temp-table wrk2 no-undo
 field lon		as char
 field days		as int
 field counts as int
 index idx		is primary days.

def var v-sum	as deci		init 0.

def var v-bal7	as deci			no-undo init 0.
def var p-coun	as integer	no-undo.
def var fdt			as date			no-undo.
def var dayc1		as integer	no-undo.

vErrorsProgress = "".

if (chk12_innbin(vIin)) = no then
do:
	vSum = "0".
	vDays = "0".
	vCounts = "0".
	vBlock = "false".
	vIsIinExist = false.
	vErrorsProgress = vErrorsProgress + "Неверный формат БИНа,".
end.
else
do:

	if integer(vLim) <> 0 then do:

		do transaction on error undo, return:
			IF ERROR-STATUS:ERROR THEN
				do:
					run WriteError.
					return.
				end.
			create txb.pc_lncontr no-error.
				IF ERROR-STATUS:ERROR THEN
					do:
						run WriteError.
						return.
					end.

					assign	txb.pc_lncontr.acc			= vAcc
									txb.pc_lncontr.iin			= vIin
									txb.pc_lncontr.contr		= vProcNum
									txb.pc_lncontr.stdate		= vStdate
									txb.pc_lncontr.edate		= vEdate
									txb.pc_lncontr.crtype		= '4'
									txb.pc_lncontr.amt			= integer(vLim)
									txb.pc_lncontr.prem			= 24
									txb.pc_lncontr.eff_%		= deci(replace(vEff_, ",", "."))
									txb.pc_lncontr.ow_limdt = vOwLimdt.
		end.

	end.

	find first txb.cif where txb.cif.bin = vIin.
	
	if avail txb.cif then do:
	 
	 /* Получение суммы платежа в текущем месяце */
	 empty temp-table wrk.
	 
	 for each txb.lon where txb.lon.cif = txb.cif.cif no-lock:

	  for each txb.lnsch where txb.lnsch.lnn = txb.lon.lon and txb.lnsch.f0 > 0 and txb.lnsch.flp = 0 no-lock:
			find first wrk where wrk.dt = txb.lnsch.stdat exclusive-lock no-error.
			if not avail wrk then do:
			 create wrk.
			 wrk.dt = txb.lnsch.stdat.
			end.
			wrk.od = wrk.od + txb.lnsch.stval.
	  end.

	  for each txb.lnsci where txb.lnsci.lni = txb.lon.lon and txb.lnsci.flp = 0 and txb.lnsci.f0 > 0 no-lock:
	   find first wrk where wrk.dt = txb.lnsci.idat exclusive-lock no-error.
	   if not avail wrk then do:
	    create wrk.
	    wrk.dt = txb.lnsci.idat.
	   end.
	   wrk.prc = wrk.prc + txb.lnsci.iv-sc.
		 /* lon.grp = 95 - АСТАНА БОНУС, 10% оплачивает Банк */
		 if (lon.grp = 95) then 
			wrk.prc = round (wrk.prc * 3 / 13, 2).
	  end.

	  for each txb.lnscs where txb.lnscs.lon = txb.lon.lon and txb.lnscs.sch no-lock:
	   find first wrk where wrk.dt = txb.lnscs.stdat exclusive-lock no-error.
	   if not avail wrk then do:
	     create wrk.
	   wrk.dt = txb.lnscs.stdat.
	   end.
	   wrk.koms = wrk.koms + txb.lnscs.stval.
	  end.

	  for each wrk where month(wrk.dt) = month(today) and year(wrk.dt) = year(today):
	   v-sum = v-sum + wrk.od + wrk.prc + wrk.koms.
	  end.

	  /* Получение количества дней просрочки */
	  empty temp-table wrk2.

	  fdt = ?.
	  dayc1 = 0.
	  p-coun = 0.

	  for each txb.lonres where txb.lonres.lon = txb.lon.lon no-lock use-index jdt:
	 
		 if txb.lonres.lev <> 7 then next.
			if txb.lonres.dc = 'd' then do:
			 if v-bal7 = 0 and txb.lonres.amt > 0 then do:
				p-coun = p-coun + 1.
				fdt = txb.lonres.jdt.
			 end.
			v-bal7 = v-bal7 + txb.lonres.amt.
			end.
			else do:
			 v-bal7 = v-bal7 - txb.lonres.amt.
			 if v-bal7 <= 0 then do:
				v-bal7 = 0.
				dayc1 = txb.lonres.jdt - fdt.
			 end.
			end.
		 end.

	   create wrk2.
	   assign
		  wrk2.lon = txb.lon.lon
		  wrk2.counts = p-coun
		  wrk2.days = dayc1.

	  end. 

		/* Проверка на наличие блокировки (ПТП, картотека) */
	  find first txb.aas where txb.aas.activ = true and txb.aas.cif = txb.cif.cif no-lock no-error.
	  if avail txb.aas then
		  vBlock = "true".
	  else vBlock = "false".
		
		vSum = string(v-sum).
		vDays = string(wrk2.days).
		vCounts = string(wrk2.counts).
		vIsIinExist = true.
		vErrorsProgress = "".


	end.
  else do:
    vSum = "0".
		vDays = "0".
		vCounts = "0".
		vBlock = "false".
		vIsIinExist = false.
		vErrorsProgress = "".
  end.


end. /* chk12_innbin(vIin) */




procedure WriteError:
def var i as integer no-undo.
if error-status:error then
    do i = 1 to error-status:num-messages:
        vErrorsProgress = vErrorsProgress + string(error-status:get-message(i)) + ",".
    end.
end procedure.