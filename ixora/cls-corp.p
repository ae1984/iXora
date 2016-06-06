/* cls-corp.p

 * MODULE

 * DESCRIPTION
        Погашение отрицательного остатка в закрытии дня
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT

 * MENU
        Перечень пунктов Меню Прагмы
 * BASES
        BANK COMM
 * AUTHOR
        15.07.2010 k.gitalov
 * CHANGES
         29.03.2011 k.gitalov убрал обработку МКО
         06.05.2011 k.gitalov добавил Снятие комиссии за овердрафт со счета ГО
         24.05.2011 k.gitalov учитываются только филиалы в которых были расходные операции
         25/04/2012 evseev  - rebranding. Название банка из sysc или изменил проверку банка или рко
         02/05/2012 evseev - логирование значения aaa.hbal
*/

{global.i}

  def buffer b-cashpool for comm.cashpool.
  def buffer b-cashpoolfill for comm.cashpool.
  def buffer b-chpoolhis for comm.chpoolhis.
  def buffer b-aaa for aaa.
  def buffer b-crc for crc.

  def var GoAcc as char.
  def var FillAcc as char.
  def var Summ as deci.
  def var vparam as char.
  def var vdel as char initial "^".
  def var rcode as inte.
  def var rdes as char.
  def var v-jh as inte.
  def var post_mail as char.
  def var RequiredSumm as deci.
  def var RealSumm as deci.


  find first comm.pksysc where comm.pksysc.sysc = "chpadm" no-lock no-error.
  if avail comm.pksysc then
  do:
    post_mail = comm.pksysc.chval.
  end.
  else do:
    post_mail = "id00205@metrocombank.kz".
    run SendError("Не заполнен справочник 'chpadm' в базе соmm!").
  end.

  /*********************************************************************************************/
  function SetOver returns int ( input sTxb as char, input GoCif as char , input iSumm as deci ):
    def buffer b-cashpool for comm.cashpool.
    def buffer b-chpoolhis for comm.chpoolhis.
    def buffer b-aaa for aaa.
    def var overacc as char.

    for each b-cashpool where b-cashpool.txb = sTxb and b-cashpool.isgo = false and b-cashpool.cifgo = GoCif exclusive-lock:
     /* b-cashpool.acc4 = string(iSumm,"zzz,zzz,zz9.99").*/
      b-cashpool.over = iSumm.

       find first b-aaa where b-aaa.cif = b-cashpool.cif and  b-aaa.aaa = b-cashpool.acc and b-aaa.sta <> "E" and b-aaa.sta <> "C"  no-lock no-error.
	   if avail b-aaa then
	   do:
	     overacc = b-aaa.craccnt.
	     find first b-aaa where b-aaa.aaa = overacc exclusive-lock no-error.
	     if avail b-aaa then
	     do:
	       b-aaa.cbal = iSumm.
	     end.
	     else do: run SendError("Отсутсвтвует овердрафтный счет для " + b-cashpool.acc ). end.
	   end.
	   else do: run SendError("Не найден счет " + b-cashpool.acc ). end.
    end.
    return 0.
  end function.
  /*********************************************************************************************/
  function GetFillLimit returns decimal ( input IdRec as char ):
    def buffer b-chpoolhis for comm.chpoolhis.
    find first b-chpoolhis where b-chpoolhis.idrec = IdRec and b-chpoolhis.cwho <> "" and b-chpoolhis.stat = 0 no-lock no-error.
    if avail b-chpoolhis then return b-chpoolhis.summ.
    else return 0.
  end function.
  /*********************************************************************************************/
  function GetRequiredLimit returns decimal ( input sTxb as char, input GoCif as char ):
    def buffer b-cashpool for comm.cashpool.
    def var summ as deci init 0.
    for each b-cashpool where b-cashpool.txb = sTxb and b-cashpool.isgo = false and b-cashpool.cifgo = GoCif no-lock:
      summ = summ + GetFillLimit(b-cashpool.cifgo + b-cashpool.cif + b-cashpool.acc).
    end.
    return summ.
  end function.
  /*********************************************************************************************/
  function GetBal returns decimal (input Acc as char):
    def buffer b-aaa for aaa.
    def var summ as deci init 0.
    find first b-aaa where b-aaa.aaa = Acc.
	if avail b-aaa then
	do:
		summ =  b-aaa.cr[1] - b-aaa.dr[1].
	end.
	return summ.
  end function.
  /*********************************************************************************************/
  function GetRequiredSumm returns decimal (input sTxb as char, input GoCif as char ):
    def buffer b-cashpool for comm.cashpool.
    def var summ as deci init 0.
    for each b-cashpool where b-cashpool.txb = sTxb and b-cashpool.isgo = false and b-cashpool.cifgo =GoCif no-lock:
      if GetBal(b-cashpool.acc) < 0 then summ = summ + GetBal(b-cashpool.acc).
    end.
    return summ.
  end function.
  /*********************************************************************************************/
  function GetFilialCount returns int (input sTxb as char, input GoCif as char ):
    def buffer b-cashpool for comm.cashpool.
    def var fCount as int init 0.
    for each b-cashpool where b-cashpool.txb = sTxb and b-cashpool.isgo = false and b-cashpool.cifgo =GoCif no-lock:
      fCount = fCount + 1.
    end.
    return fCount.
  end function.
  /*********************************************************************************************/
  function Freeze returns log (input vaaa as char , input vamt as deci):
    def var Rez as log init false.
    def buffer b-aaa for aaa.
    def buffer b-aas for aas.

	do transaction:
	 find b-aaa where b-aaa.aaa = vaaa exclusive-lock no-error.
	 if not available b-aaa then Rez = false.
	 else do:
		 find b-aas where b-aas.aaa = vaaa and b-aas.ln = 1 exclusive-lock no-error.
		 if not available b-aas then create b-aas.
		 b-aas.chkdt = g-today.
		 b-aas.regdt = g-today.
		 b-aas.expdt = b-aaa.expdt.
		 b-aas.whn = today.
		 b-aas.who = "BANKADM".
		 b-aas.tim = time.
		 b-aas.ln = 1.
		 b-aas.aaa = b-aaa.aaa.
		 b-aas.sic = "HB".
		 b-aas.chkamt = vamt.
		 b-aas.payee = "Необходимый неснижаемый остаток".
		 run savelog("aaahbal", "cls-corp ; " + b-aaa.aaa + " ; " + string(b-aaa.hbal) + " ; " + string(vamt) + " ; " + string(vamt)).
         b-aaa.hbal =  vamt.
		 Rez = true.
	 end.
	end. /*transaction*/
	return Rez.
  end function.
  /*********************************************************************************************/



 find first bank.cmp no-lock no-error.
 if not avail bank.cmp then do:
   /* message " Не найдена запись cmp " view-as alert-box error.*/
    run SendError(" Не найдена запись cmp ").
    return.
 end.
 /*мко не обрабатываем!*/
 /*if not bank.cmp.name matches "*ForteBank*" then return.*/
 if bank.cmp.name matches "*МКО*" then return.




   find sysc where sysc.sysc = 'OURBNK' no-lock no-error.
   if avail sysc then
   do:

    /*run mail("id00205@metrocombank.kz" ,"bankadm@metrocombank.kz" , "CASH POOLING" , "обработка филиала " + sysc.chval , "1" , "" ,"" ).*/
    /*********************************************************************************************/

     for each b-cashpool where b-cashpool.txb = sysc.chval and b-cashpool.isgo = true no-lock:
       GoAcc = b-cashpool.acc.
       /* Определим необходимую сумму для покрытия отрицательного остатка для всех филиалов*/
       RequiredSumm =  GetRequiredSumm(b-cashpool.txb,b-cashpool.cif).
       if RequiredSumm < 0 then
       do:  /* Все нормально сумма отрицательная - значит работали*/

        /* run mail("id00205@metrocombank.kz" ,"bankadm@metrocombank.kz" , "CASH POOLING" , "клиенты филиала " + sysc.chval + " работали!" , "1" , "" ,"" ).*/

          RequiredSumm = - RequiredSumm.
          RealSumm = GetBal(GoAcc).

          if RealSumm >= RequiredSumm then
          do:
		      /* message RealSumm " | " RequiredSumm " | надо - " GetRequiredLimit(b-cashpool.txb,b-cashpool.cif) view-as alert-box. */
		       /*Размораживаем средства */
		       if Freeze(GoAcc,0) then
		       do:
		       /*-----------------------------------------------------------------------------------------------------------------*/
			       for each b-cashpoolfill where b-cashpoolfill.txb = b-cashpool.txb and b-cashpoolfill.isgo = false and b-cashpoolfill.cifgo = b-cashpool.cif no-lock:
			         FillAcc = b-cashpoolfill.acc.
			         Summ = GetBal(FillAcc).
			         if Summ < 0 then
			         do:
			           Summ = - Summ.
			           v-jh = 0.
				       rcode = 0.
			           rdes = ''.
				       vparam =  string(Summ) + vdel + "1" + vdel + GoAcc + vdel + "1" + vdel + FillAcc + vdel + "Погашение отрицательного сальдо " + b-cashpoolfill.name .
				       run trxgen("vnb0069", vdel, vparam, "CIF", GoAcc , output rcode, output rdes, input-output v-jh).
				       if rcode = 0 then do:
				          run trxsts(v-jh, 6, output rcode, output rdes).
				       end.
			           else do:  run SendError(rdes). end.
			         end.
			       end.
		       /*-----------------------------------------------------------------------------------------------------------------*/
               /*Снятие комиссии за овердрафт со счета ГО*/
                  find first tarif2 where tarif2.num + tarif2.kod = "103" and tarif2.stat = 'r' no-lock no-error.
                  if avail tarif2 then do:
                     v-jh = 0.
				     rcode = 0.
			         rdes = ''.
				     vparam = " " + vdel + string (RequiredSumm * tarif2.proc / 100 ) + vdel + '1' + vdel + GoAcc + vdel + string(tarif2.kont) + vdel +
                     "Комиссия за предоставление технического овердрафта, использованного по сервису «Cash pooling»".
                     run trxgen ("JOU0026", vdel, vparam, "CIF", GoAcc , output rcode, output rdes, input-output v-jh).
                     if rcode <> 0 then do: run SendError("Ошибка при списании комиссии - " + rdes ).  end.
                     else run trxsts(v-jh, 6, output rcode, output rdes).
                  end.
                  else run SendError("Не найдены данные по тарифу для снятия комиссии!").
               /*-----------------------------------------------------------------------------------------------------------------*/
		       /* Замораживаем */

		           RequiredSumm = GetRequiredLimit(b-cashpool.txb,b-cashpool.cif).
		           RealSumm = GetBal(b-cashpool.acc).
		           if RealSumm >= RequiredSumm then
                   do:
                      if not Freeze(b-cashpool.acc,RequiredSumm) then do: run SendError("Не удалось заморозить средства на счете " + b-cashpool.acc ). end.
                   end.
                   else do:
                     def var Nlimit as deci.
                     Nlimit = RealSumm / GetFilialCount(b-cashpool.txb,b-cashpool.cif).
                     run SendError("Недостаточно средств " + b-cashpool.name + " на счете " + b-cashpool.acc + " для погашения отрицательного сальдо на счетах филиалов \n Доступный лимит для филиалов установлен в размере " + string(Nlimit,"zzz,zzz,zz9.99") ).
		             if not Freeze(b-cashpool.acc,RealSumm) then do: run SendError("Не удалось заморозить средства на счете " + b-cashpool.acc ). end.
		             else do:
		              /*здесь нужно установить овердрафт*/
		              SetOver(b-cashpool.txb , b-cashpool.cif ,Nlimit ).
		             end.
		           end.

		       end.
		       else do: run SendError("Не удалось разморозить средства на счете " + GoAcc ). end.


		  end. /*RealSumm <= RequiredSumm*/
		  else do:
		    run SendError("Недостаточно средств " + b-cashpool.name + " на счете " + GoAcc + " для погашения отрицательного сальдо на счетах филиалов" ).
		  end.
	   end. /*RequiredSumm >= 0*/
       /*else run mail("id00205@metrocombank.kz" ,"bankadm@metrocombank.kz" , "CASH POOLING" , "клиенты филиала " + sysc.chval + " не работали" , "1" , "" ,"" ).*/
     end.
    /*********************************************************************************************/

    /*message "Закрытие опердня произведено!" view-as alert-box.*/
   end.
   else do: message "Отсутствует переменная OURBNK!" view-as alert-box. end.




 /*********************************************************************************************/
 procedure SendError:
    def input param sms as char.
    run mail(post_mail ,"bankadm@metrocombank.kz" , "CASH POOLING" , sms , "1" , "" ,"" ).
 end procedure.
 /*********************************************************************************************/








