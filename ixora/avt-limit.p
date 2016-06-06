/* avt-limit.p

 * MODULE

 * DESCRIPTION
        Авторизация лимитов для корпоративных клиентов
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

*/

{classes.i}
{comm-txb.i}


def var CurrTXB as char.
CurrTXB = comm-txb().

def var ListCod as char init "TXB00,TXB01,TXB02,TXB03,TXB04,TXB05,TXB06,TXB07,TXB08,TXB09,TXB10,TXB11,TXB12,TXB13,TXB14,TXB15,TXB16".
def var ListBank as char format "x(25)" extent 17 init ["Центральный Офис","Актобе","Костанай","Тараз","Уральск","Караганда",
                                                           "Семипалатинск","Кокшетау","Астана","Павлодар","Петропавловск","Атырау",
                                                           "Актау","Жезказган","Усть-Каменогорск","Шымкент","Алматинский филиал"].

 define temp-table wrk
                     field a1 as char
                     field a2 as char
                     field a3 as char
                     field a4 as char
                     field a5 as char
                     field d1 as deci
                     index i1 a1 ASCENDING.


/***********************************************************************************************************/
 run AkceptLimit.
/***********************************************************************************************************/


/***********************************************************************************************************/
function LoadWrk returns log:
  def buffer b-cashpool for comm.cashpool.
  def buffer b-chpoolhis for comm.chpoolhis.
  def var rez as log init false.
   empty temp-table wrk.
   for each b-chpoolhis where b-chpoolhis.cwho = "" and b-chpoolhis.stat = 1 no-lock :

     find first b-cashpool where b-cashpool.cifgo = substring(b-chpoolhis.idrec,1,6) and
                                 b-cashpool.cif = substring(b-chpoolhis.idrec,7,6) and
                                 b-cashpool.acc = substring(b-chpoolhis.idrec,13,length(b-chpoolhis.idrec)) and
                                 b-cashpool.txb = CurrTXB no-lock no-error. /* убрать если нужно видеть все филиалы!*/
     if avail b-cashpool then
     do:
        create wrk.
               wrk.a1 = b-cashpool.txb.
               wrk.a2 = b-cashpool.name.
               wrk.a3 = b-cashpool.acc.
               wrk.a4 = b-cashpool.cifgo.
               wrk.a5 = b-cashpool.cif.
               wrk.d1 = b-chpoolhis.summ.
        rez = true.
     end.
    /* else do: message "Не найдены данные для клиента " b-chpoolhis.idrec view-as alert-box.  end.*/

   end.

   return rez.
end function.
/***********************************************************************************************************/
procedure AkceptLimit:
   /* Акцепт установленных лимитов */

   if not LoadWrk() then
   do:
     message "Нет данных для акцепта!" view-as alert-box title "Сообщение".
     leave.
   end.

   def buffer b-aaa for bank.aaa.
   def buffer b-cashpool for comm.cashpool.
   def buffer b-chpoolhis for comm.chpoolhis.
   def var rez as log init false.
   define button bt-close label "Выход".
   def var iTXB as char.
   def var iCif as char.
   def var iAcc as char.
   def var iSumm as deci.


   define query q_list for wrk.
   define browse b_list query q_list no-lock
   display ListBank[LOOKUP(wrk.a1,ListCod)] label "Филиал" format "x(18)"
          wrk.a2 label "Наименование" format "x(25)"
          wrk.a3 label "Счет" format "x(21)"
          wrk.d1 label "Лимит" format "zzz,zzz,zz9.99"
          with  10 down centered overlay  no-row-markers.


   define frame f1  b_list skip  space(40)  bt-close  with  no-labels centered overlay  WIDTH 89 title "Не акцептованные лимиты"  view-as dialog-box.

   on return of b_list in frame f1
   do:

     if NUM-RESULTS ("q_list") > 0 then
     do:

        run yn("","Акцептовать запись?","Счет: " + wrk.a3,"Лимит: " + string(wrk.d1,"zzz,zzz,zz9.99"), output rez).
        if rez then
        do: /* Акцепт*/
          do transaction:
           find first b-chpoolhis where b-chpoolhis.idrec = wrk.a4 + wrk.a5 + wrk.a3 and b-chpoolhis.stat = 1 and b-chpoolhis.summ = wrk.d1 exclusive-lock no-error.
           b-chpoolhis.stat = 0.
           b-chpoolhis.cwho = g-ofc.
           find first b-cashpool where b-cashpool.cifgo = wrk.a4 and b-cashpool.cif = wrk.a5 and  b-cashpool.acc = wrk.a3 exclusive-lock no-error.
           b-cashpool.acc4 = string(b-chpoolhis.summ,"zzz,zzz,zz9.99").
           iTXB = wrk.a1.
           iCif = wrk.a5.
           iAcc = wrk.a3.
           iSumm = wrk.d1.
           b-cashpool.over = iSumm.
          end. /*transaction*/

          {r-branch.i &proc ="set-limit ( iTXB , iCif , iAcc , iSumm )" } /*первоночально планировалось что будет управление только из ЦО*/

        end.
        else do: /*Отказ*/
          do transaction:
           find first b-chpoolhis where b-chpoolhis.idrec = wrk.a4 + wrk.a5 + wrk.a3 and b-chpoolhis.stat = 1 and b-chpoolhis.summ = wrk.d1  exclusive-lock no-error.
           b-chpoolhis.stat = 2.
           b-chpoolhis.cwho = g-ofc.
           find first b-chpoolhis where b-chpoolhis.idrec = wrk.a4 + wrk.a5 + wrk.a3 and b-chpoolhis.stat = 0  no-lock no-error.
           find first b-cashpool where b-cashpool.cifgo = wrk.a4 and b-cashpool.cif = wrk.a5 and  b-cashpool.acc = wrk.a3 exclusive-lock no-error.
           b-cashpool.acc4 = string(b-chpoolhis.summ,"zzz,zzz,zz9.99").
          end. /*transaction*/
        end.
       LoadWrk().
       open query q_list for each wrk.
     end.
   end.

   on choose of bt-close in frame f1
   do:
     apply "endkey" to frame f1.
   end.


   open query q_list for each wrk.
   enable b_list  bt-close with frame f1.
   apply "value-changed" to b_list in frame f1.
   WAIT-FOR endkey  of frame f1.
   hide frame f1.


end procedure.
/***********************************************************************************************************/