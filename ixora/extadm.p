/* extadm.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание программы
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        19.05.2011 k.gitalov
 * BASES
        BANK COMM
 * CHANGES
*/

{classes.i}



define button bt-add label "Добавить".
define button bt-del label "Удалить".
define button bt-close label "Выход".
def var rez as log.
define query q_list for extract.
define browse b_list query q_list no-lock
display extract.payname label "Наименование" format "x(20)" extract.acc label "Номер счета" format "x(21)"  extract.note label "Тип" format "x(5)" with title "Автоматические выписки по счетам" 10 down centered overlay  no-row-markers.
define frame f1 b_list skip space(12) bt-add bt-del bt-close  with no-labels  centered overlay view-as dialog-box.
define frame f2 iCif as char format "x(6)" label  "Код клиента    " skip
                iAcc as char format "x(21)" label "Текущий счет   " skip
                iType as char format "x(5)" label "Тип   " skip
                WITH SIDE-LABELS centered overlay row 8 TITLE "Введите данные".



run ShowCorpGrp.

/*******************************************************************************************/
procedure ShowCorpGrp:

   on choose of bt-add in frame f1
   do:
      hide frame f1.
      run cif_add.
      open query q_list for each extract no-lock.
      hide frame f2.
      display b_list with frame f1.
   end.
    /******************************************************************************/
   on choose of bt-del in frame f1
   do:
     find current extract exclusive-lock no-error.
     if avail extract then
     do:
      run yn("","Удалить выбранного клиента?","","", output rez).
      if rez then delete extract.
      open query q_list for each extract no-lock.
     end.
     else release extract.
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

       run sel1("Изменить тип выписки","MT940|DBF|ALL").
       iType = return-value.
       if iType = "" then leave.

       find current extract exclusive-lock.
       extract.note = iType.
       extract.who_cr = g-ofc.

       open query q_list for each extract no-lock.
       b_list:SELECT-ROW(Pos).

      end.
    end.
    /******************************************************************************/

    open query q_list for each extract no-lock.
    enable all with frame f1.
    apply "value-changed" to b_list in frame f1.
    WAIT-FOR endkey /*, INSERT-MODE*/ of frame f1.
    hide frame f1.
end procedure.
/*******************************************************************************************/
procedure cif_add:
     DEFINE VARIABLE phand AS handle.
     DEFINE VARIABLE acclist AS char.

     on help of iCif in frame f2 do:
       run h-cif PERSISTENT SET phand.
       hide frame xf.
       iCif = frame-value.
       displ  iCif with frame f2.
       DELETE PROCEDURE phand.
     end.


    repeat on ENDKEY UNDO  , leave :
      hide frame f-help.
      update iCif with frame f2.

      def var Client as class ClientClass.
      Client = new ClientClass(Base).
      Client:FindClientNo(iCif).
      acclist =  Client:FindAcc().


      if acclist = "" then do: undo. end.
      run sel1("Выберите счет для добавления",acclist).
      iAcc = return-value.
      if iAcc = "" then do: iCif = "".  displ  iCif with frame f2. undo. end.
      displ  iAcc with frame f2.


      run sel1("Выберите тип выписки","MT940|DBF|ALL").
      iType = return-value.
      if index("MT940|DBF|ALL",iType) = 0 then do: iCif = "". iAcc = "". iType = "". displ  iCif iAcc iType with frame f2. undo. end.
      else do:
         iCif = caps(iCif).
         iAcc = caps(iAcc).
         create extract.
                 extract.cif = iCif.
                 extract.acc = iAcc.
                 extract.payname = Client:clientname.
                 extract.who_cr = g-ofc.
                 extract.note = iType.

         /*support@metrocombank.kz   id00205@metrocombank.kz*/
         run mail("support@metrocombank.kz", "info@metrocombank.kz", "Формирование промежуточных и итоговых выписок на внешний сервер", " В сервис добавлен клиент " + Client:clientname + "\n Необходимо добавить пользователя " + iCif + "\n Счет " + iAcc + "\n Пользователь " + g-ofc , "", "", "").
      end.

      if valid-object(Client) then delete object Client no-error.
      clear frame f2  no-pause.
      hide frame f2  no-pause.
      leave.

    end.

end procedure.
/*******************************************************************************************/

