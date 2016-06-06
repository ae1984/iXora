/* chpool.p

 * MODULE

 * DESCRIPTION
        Корпоративное управление счетами филиалов
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
        * 19/03/2013 Luiza ТЗ № 1714
 * CHANGES

*/

{classes.i}
{comm-txb.i}

def var rez as log.

function GetStat returns char(input id as int):
  if id = 0 then return "Активный".
  if id = 1 then return "Блокирован".
end function.

def var ListCod as char init "TXB00,TXB01,TXB02,TXB03,TXB04,TXB05,TXB06,TXB07,TXB08,TXB09,TXB10,TXB11,TXB12,TXB13,TXB14,TXB15,TXB16".
def var ListBank as char format "x(25)" extent 17 init ["Центральный Офис","Актобе","Костанай","Тараз","Уральск","Караганда",
                                                           "Семипалатинск","Кокшетау","Астана","Павлодар","Петропавловск","Атырау",
                                                           "Актау","Жезказган","Усть-Каменогорск","Шымкент","Алматинский филиал"].

def var ComboBank as char format "x(25)"
                           VIEW-AS COMBO-BOX LIST-ITEMS "Центральный Офис","Актобе","Костанай","Тараз","Уральск","Караганда",
                                                           "Семипалатинск","Кокшетау","Астана","Павлодар","Петропавловск","Атырау",
                                                           "Актау","Жезказган","Усть-Каменогорск","Шымкент","Алматинский филиал".


def var CurrTXB as char.
CurrTXB = comm-txb().
/*if CurrTXB <> "TXB00" then do: message "Программа может быть запущена только в ЦО!" view-as alert-box. return. end.*/



 run ShowCorpGrp.


/***********************************************************************************************************/

procedure ShowCorpGrp:
  /* Список корпоративных групп */
   define button bt-add label "Добавить".
   define button bt-del label "Удалить".
   define button bt-close label "Выход".

   define query q_list for comm.cashpool.
   define browse b_list query q_list no-lock
   display comm.cashpool.name label "Наименование" format "x(35)" /* GetStat(comm.cashpool.stat) label "Статус" format "x(10)" */
   ListBank[LOOKUP(comm.cashpool.txb,ListCod)] label "Филиал" format "x(18)" with title "Список корпоративных клиентов" 10 down centered overlay  no-row-markers.

   define frame f1 b_list skip space(16) bt-add bt-del bt-close  with no-labels centered overlay view-as dialog-box.


   /******************************************************************************/

   on choose of bt-add in frame f1
   do:
      define frame f2 /* ComboBank label "Филиал" skip */
                      iCif as char format "x(6)" label  "Код клиента    " skip
                     /* iAcc as char format "x(21)" label "Текущий счет   " skip */
                     /* dAcc as char format "x(21)" label "Депозитный счет"*/
      WITH SIDE-LABELS centered overlay view-as dialog-box title "Введите данные ГО".

      on help of iCif in frame f2 do:
        /* run h-cif.*/
      end.

      set iCif with frame f2.
      if iCif entered then
      do:
         def var GoCif as char init "".
        /* {r-branch.i &proc ="goadd ( CurrTXB , iCif , GoCif , g-ofc )" } */
         run goadd ( CurrTXB , iCif , GoCif , g-ofc ).
         open query q_list for each comm.cashpool where comm.cashpool.txb = CurrTXB and comm.cashpool.isgo = true  By comm.cashpool.txb.
      end.
      else undo.

   end.
   /******************************************************************************/
   on choose of bt-del in frame f1
   do:
     find current comm.cashpool exclusive-lock no-error.
     if avail comm.cashpool then
     do:
      run yn("","Удалить выбранную группу","","", output rez).
      if rez then
      do:
       def var tCif as char.
       find current comm.cashpool exclusive-lock no-error.
       tCif = comm.cashpool.cif.
       delete comm.cashpool.
       for each comm.cashpool where comm.cashpool.isgo = false and comm.cashpool.cifgo = tCif exclusive-lock:
        delete comm.cashpool.
       end.
       open query q_list for each comm.cashpool where comm.cashpool.txb = CurrTXB and comm.cashpool.isgo = true  By comm.cashpool.txb.
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
   on return of b_list in frame f1
   do:
     if avail comm.cashpool then
     do:
      run ShowFillGrp(comm.cashpool.txb , comm.cashpool.cif , comm.cashpool.name , comm.cashpool.acc).
     end.
   end.
   /******************************************************************************/

    open query q_list for each comm.cashpool where comm.cashpool.txb = CurrTXB and comm.cashpool.isgo = true  By comm.cashpool.txb.
    enable all with frame f1.
    apply "value-changed" to b_list in frame f1.
    WAIT-FOR endkey /*, INSERT-MODE*/ of frame f1.
    hide frame f1.


end procedure.

/***********************************************************************************************************/
function GetFillLimit returns decimal ( input IdRec as char ):
  def buffer b-chpoolhis for comm.chpoolhis.
  find first b-chpoolhis where b-chpoolhis.idrec = IdRec and b-chpoolhis.cwho <> "" and b-chpoolhis.stat = 0 no-lock no-error.
  if avail b-chpoolhis then return b-chpoolhis.summ.
  return 0.
end function.
/***********************************************************************************************************/
function GetBal returns decimal ( input IdAcc as char ):
   def var vbal as deci.
   def var vavl as deci.
   def var vhbal as deci.
   def var vfbal as deci.
   def var vcrline as deci.
   def var vcrlused as deci.
   def var vooo as char.
   run aaa-bal777(IdAcc, output vbal, output vavl, output vhbal,
          output vfbal, output vcrline, output vcrlused, output vooo).

   return vbal.
end function.
/***********************************************************************************************************/
function GetOver returns decimal ( input IdAcc as char ):
   def var vbal as deci.
   def var vavl as deci.
   def var vhbal as deci.
   def var vfbal as deci.
   def var vcrline as deci.
   def var vcrlused as deci.
   def var vooo as char.
   run aaa-bal777(IdAcc, output vbal, output vavl, output vhbal,
          output vfbal, output vcrline, output vcrlused, output vooo).

   return vavl. /*vcrline.*/
end function.
/***********************************************************************************************************/
function GetFreeze returns decimal ( input IdAcc as char ):
   def var vbal as deci.
   def var vavl as deci.
   def var vhbal as deci.
   def var vfbal as deci.
   def var vcrline as deci.
   def var vcrlused as deci.
   def var vooo as char.
   run aaa-bal777(IdAcc, output vbal, output vavl, output vhbal,
          output vfbal, output vcrline, output vcrlused, output vooo).

   return vhbal.
end function.

/***********************************************************************************************************/
procedure ShowFillGrp:
   /* Список филиалов */
   def input param GoTxb as char.
   def input param GoCif as char.
   def input param GoName as char format "x(45)".
   def input param GoAcc as char format "x(21)".



   def buffer b-cashpool for comm.cashpool.
   def buffer b-chpoolhis for comm.chpoolhis.
   define button bt-add label "Добавить".
   define button bt-del label "Удалить".
   define button bt-close label "Закрыть".

   define query q_list for comm.cashpool.
   define browse b_list query q_list no-lock
   display comm.cashpool.name label "Наименование" format "x(25)"
          comm.cashpool.acc label "Счет" format "x(21)"
          comm.cashpool.acc4 label "Лимит" format "x(16)"
          /*comm.cashpool.over label "Овердрафт     " format "zzz,zzz,zz9.99" */
          GetOver(comm.cashpool.acc) label "Овердрафт     " format "zzz,zzz,zz9.99"
          GetBal(comm.cashpool.acc) label "Использовано" format "zzz,zzz,zz9.99-"
          with /*title "Состав группы"*/ 10 down centered overlay  no-row-markers.



   define frame f1 "   ГО:" GoName   skip
                   " Cчет:" GoAcc    skip
                    b_list  skip  space(35) bt-add bt-del bt-close
   with  no-labels centered overlay  WIDTH 104 view-as dialog-box title "Состав группы".


   /******************************************************************************/
   on choose of bt-add in frame f1
   do:
      define frame f2 iCif as char format "x(6)" label  "Код клиента    " skip
      WITH SIDE-LABELS centered overlay view-as dialog-box title "Введите данные филиала".

      on help of iCif in frame f2 do:
       /*run help-crc1.*/
       /*run h-cif.*/
      end.

      set iCif with frame f2.
      if iCif entered then
      do:
        /* {r-branch.i &proc ="goadd ( GoTxb , iCif , GoCif , g-ofc )" }   */
        run goadd ( GoTxb , iCif , GoCif , g-ofc ).
      end.

      open query q_list for each comm.cashpool where comm.cashpool.txb = GoTXB and comm.cashpool.isgo = false and comm.cashpool.cifgo = GoCif  By comm.cashpool.txb.
   end.
   /******************************************************************************/
   on choose of bt-del in frame f1
   do:
     find current comm.cashpool exclusive-lock no-error.
     if avail comm.cashpool then
     do:
      run yn("","Удалить выбранный филиал","","", output rez).
      if rez then
      do:
       if comm.cashpool.isgo = false and comm.cashpool.cifgo = GoCif then
       do:
        delete comm.cashpool.
       end.
       open query q_list for each comm.cashpool where comm.cashpool.txb = GoTXB and comm.cashpool.isgo = false and comm.cashpool.cifgo = GoCif  By comm.cashpool.txb.
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
   on return of b_list in frame f1
   do:

     if NUM-RESULTS ("q_list") > 0 then
     do:

       def var Pos as int.
       Pos = b_list:focused-row.

       define frame f3 iSumm as decimal format "zzz,zzz,zz9.99" label "Доступный лимит      "
       WITH SIDE-LABELS centered overlay view-as dialog-box.


       iSumm = GetFillLimit(GoCif + cashpool.cif + cashpool.acc).
       display  iSumm with frame f3.

       set iSumm with frame f3.
       if iSumm entered /* and iSumm > 0*/ then
       do:

       	  find first b-cashpool where b-cashpool.txb = GoTxb and b-cashpool.cifgo = GoCif and b-cashpool.cif = cashpool.cif no-lock no-error.
	      if avail b-cashpool then
	      do:

		        create b-chpoolhis.
		               b-chpoolhis.idrec = b-cashpool.cifgo + b-cashpool.cif + cashpool.acc.
		               b-chpoolhis.who = g-ofc.
		               b-chpoolhis.stat = 1.
		               b-chpoolhis.tim = time.
		               b-chpoolhis.summ = iSumm.

		       find current comm.cashpool exclusive-lock.
		        comm.cashpool.acc4 = "[" + string(iSumm,"zzz,zzz,zz9.99") + "]".
		  end.

       end.

       open query q_list for each comm.cashpool where comm.cashpool.txb = GoTXB and comm.cashpool.isgo = false and comm.cashpool.cifgo = GoCif By comm.cashpool.txb.
       b_list:SELECT-ROW(Pos).
     /*  */

     end.
   end.
   /******************************************************************************/

    open query q_list for each comm.cashpool where comm.cashpool.txb = GoTXB and comm.cashpool.isgo = false and comm.cashpool.cifgo = GoCif By comm.cashpool.txb.
    enable b_list bt-add bt-del bt-close with frame f1.

    display  GoName GoAcc with frame f1.



    apply "value-changed" to b_list in frame f1.
    WAIT-FOR endkey /*, INSERT-MODE*/ of frame f1.
    hide frame f1.

end procedure.
/***********************************************************************************************************/



