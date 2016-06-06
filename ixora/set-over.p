/* set-over.p

 * MODULE

 * DESCRIPTION
        Установка овердрафта согласно лимиту
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
        02/05/2012 evseev - логирование значения aaa.hbal

*/

{global.i}
{comm-txb.i}


def var RequiredSumm as deci.
def var RealSumm as deci.
def var rez as log.

def var ListCod as char init "TXB00,TXB01,TXB02,TXB03,TXB04,TXB05,TXB06,TXB07,TXB08,TXB09,TXB10,TXB11,TXB12,TXB13,TXB14,TXB15,TXB16".
def var ListBank as char format "x(25)" extent 17 init ["Центральный Офис","Актобе","Костанай","Тараз","Уральск","Караганда",
                                                           "Семипалатинск","Кокшетау","Астана","Павлодар","Петропавловск","Атырау",
                                                           "Актау","Жезказган","Усть-Каменогорск","Шымкент","Алматинский филиал"].

def var CurrTXB as char.
CurrTXB = comm-txb().

  /*********************************************************************************************/
  function SetOver returns int ( input sTxb as char, input GoCif as char  ):
    def buffer b-cashpool for comm.cashpool.
    def buffer b-chpoolhis for comm.chpoolhis.
    def buffer b-aaa for aaa.
    def var overacc as char.

    for each b-cashpool where b-cashpool.txb = sTxb and b-cashpool.isgo = false and b-cashpool.cifgo = GoCif exclusive-lock:
     /* b-cashpool.acc4 = string(iSumm,"zzz,zzz,zz9.99").*/
      find first b-chpoolhis where b-chpoolhis.idrec = b-cashpool.cifgo + b-cashpool.cif + b-cashpool.acc and b-chpoolhis.cwho <> "" and b-chpoolhis.stat = 0 no-lock no-error.
       b-cashpool.over = b-chpoolhis.summ.


       find first b-aaa where b-aaa.cif = b-cashpool.cif and  b-aaa.aaa = b-cashpool.acc and b-aaa.sta <> "E" and b-aaa.sta <> "C"  no-lock no-error.
	   if avail b-aaa then
	   do:
	     overacc = b-aaa.craccnt.
	     find first b-aaa where b-aaa.aaa = overacc exclusive-lock no-error.
	     if avail b-aaa then
	     do:
	       b-aaa.cbal = b-cashpool.over.
	     end.
	     else message "Отсутсвтвует овердрафтный счет для "  b-cashpool.acc view-as alert-box.
	   end.
	   else message "Не найден счет "  b-cashpool.acc view-as alert-box.
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
      summ = summ + GetBal(b-cashpool.acc).
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
		 b-aas.who = g-ofc.
		 b-aas.tim = time.
		 b-aas.ln = 1.
		 b-aas.aaa = b-aaa.aaa.
		 b-aas.sic = "HB".
		 b-aas.chkamt = vamt.
		 b-aas.payee = "Необходимый неснижаемый остаток".
		 run savelog("aaahbal", "set-over ; " + b-aaa.aaa + " ; " + string(b-aaa.hbal) + " ; " + string(vamt) + " ; " + string(vamt)).
         b-aaa.hbal =  vamt.
		 Rez = true.
	 end.
	end. /*transaction*/
	return Rez.
  end function.
  /*********************************************************************************************/

procedure ShowCorpGrp:
  /* Список корпоративных групп */
   define button bt-add label "Установить овердрафт".
   define button bt-close label "Выход".

   define query q_list for comm.cashpool.
   define browse b_list query q_list no-lock
   display comm.cashpool.name label "Наименование" format "x(35)" /* GetStat(comm.cashpool.stat) label "Статус" format "x(10)" */
   ListBank[LOOKUP(comm.cashpool.txb,ListCod)] label "Филиал" format "x(18)" with title "Список корпоративных клиентов" 10 down centered overlay  no-row-markers.

   define frame f1 b_list skip space(16) bt-add bt-close  with no-labels centered overlay view-as dialog-box.


   /******************************************************************************/

   on choose of bt-add in frame f1
   do:

     find current comm.cashpool exclusive-lock no-error.
     if avail comm.cashpool then
     do:

      run yn(comm.cashpool.name,"Установить овердрафт для группы равный лимиту?","","", output rez).
      if rez then
      do:

                   RequiredSumm = GetRequiredLimit(comm.cashpool.txb,comm.cashpool.cif).
		           RealSumm = GetBal(comm.cashpool.acc).
		           if RealSumm >= RequiredSumm then
                   do:
                      if not Freeze(comm.cashpool.acc,RequiredSumm) then do: message "Не удалось зморозить средства на счете " + comm.cashpool.acc  view-as alert-box. end.
                      else do:
                         SetOver(comm.cashpool.txb , comm.cashpool.cif ).
                      end.
                   end.
                   else do:
                       message "Недостаточно средств на счете " + comm.cashpool.acc + " для погашения отрицательного сальдо на счетах филиалов" view-as alert-box.
		           end.

      end.
     end.
     else release comm.cashpool.

   end.
   /******************************************************************************/
   on choose of bt-close in frame f1
   do:

     apply "endkey" to frame f1.
   end.
   /******************************************************************************/

    open query q_list for each comm.cashpool where comm.cashpool.txb = CurrTXB and comm.cashpool.isgo = true  By comm.cashpool.txb.
    enable all with frame f1.
    apply "value-changed" to b_list in frame f1.
    WAIT-FOR endkey /*, INSERT-MODE*/ of frame f1.
    hide frame f1.


end procedure.

/***********************************************************************************************************/



run ShowCorpGrp.




