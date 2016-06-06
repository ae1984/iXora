/* compay3.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
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
 * BASES
        BANK COMM
 * AUTHOR
        26/03/09 id00205
 * CHANGES
        06/01/10 id00205 убрал возможность перепроведения документа
        13.10.2010 k.gitalov перекомпиляция
        25.10.2010 k.gitalov проверка на доступность сервиса
        13.01.2012 damir - добавил keyord.i, printord.p
        07.03.2012 damir - добавил входной параметр в printord.p.
        23.05.2012 damir - убрал входной строковый параметр, передаваемый в printord.p,поставил пусто.
        06.06.2012 k.gitalov - изменил формат номера проводки
        14.11.2012 damir - Оптимизация.Контроль отправки платежей (вручную или автоматически).
        15.11.2012 damir - добавил pause 0,поставил Doc:Free() перед сообщением о закрытии документа.
        27.02.2013 damir - Внесены изменения, вступившие в силу 01/02/2013.
*/


/*Алсеко ИВЦ
Ключевое поле Лицевой счет
данные по платежу и плательщику возвращает авангардплат
обязательное поле - Лицевой счет
*/

{classes.i}
{keyord.i} /*Переход на новые и старые форматы ордеров*/


def input param  Doc as class COMPAYDOCClass.  /* Класс документов коммунальных платежей*/
def output param iRez as log init no.          /**/


/************************************************************************************/
find first comm.pksysc where comm.pksysc.sysc = "comadm" no-lock no-error.
if avail comm.pksysc then
do:
  if comm.pksysc.loval = no then
  do:
    message "Прием платежей Авангард-Plat в данное время недоступен!" view-as alert-box title "Внимание".
    return.
  end.
end.
else do:
  message "Не найден адрес старшего кассира Авангард-Plat!" view-as alert-box.
  return.
end.
/************************************************************************************/

  def shared var s-jh      like jh.jh .

  def var rez as log init no.
  def var pos as int init 1.
  def var err as integer no-undo.
  def var errdes as char no-undo.
  def var CurInvoice as char init "" format "x(12)". /*Текущий выбранный инвойс*/
  def var Usr as class ACCOUNTClass.                 /* Класс данных плательщиков */
  def var SDuty as char format "x(60)"  .
  def var SMess as char format "x(100)"  .
  def var PrevDocSumm as deci init 0.
  def var ntmess      as char.
  def var v-FormulType as logi.
  def var v-ForPay as deci.
  def var v-Suppcom as char.
  def var v-prevCountDate as date.
  def var v-lastCountDate as date.

  {compayshared.i "new"}
  {CompayFunc.i}

  def buffer b-wrk for wrk.

  define query q_list for wrk .
  define browse b_list query q_list no-lock
  display wrk.NamSub label "Наименование сервиса"  FORMAT "x(23)"
          wrk.Curr   label "Последнее " format "zzzzzz9.99"
          wrk.Prev   label "Пред.(опл)" format "zzzzzz9.99"
          wrk.Amount label "Кол-во."    format "zzzzzz9.99"
          wrk.Price  label "Цена "
          wrk.Unit   label "Ед.изм" format "x(10)"
         /* wrk.Duty   label "Долг/перепл."*/
          wrk.ForPay label "К оплате" format "zzzzzzz9.99"
          wrk.Pay    label "Оплачиваю" format "zzzzzzz9.99"
          with  14  DOWN  NO-ASSIGN  SEPARATORS  no-row-markers .

  DEFINE FRAME MainFrame
         skip (1)
         payacc as char format "x(12)" label "Лицевой счет      "  space(29)   docNo as char label  "Номер документа" skip
         suppname as char label  "Получатель платежа" FORMAT "x(40)"  docJH as char label  "Номер проводки " skip
         payname AS character FORMAT "x(40)" label "Плательщик        "   CurInvoice label "Инвойс         " skip
         address as char  format "x(60)" no-label   skip

         b_list skip
         SDuty label " Подробности" skip
         "____________________________________________________________________________________________________________" skip(1)

         State AS character format "x(80)" label " Статус платежа     "  skip
         summ AS decimal FORMAT "z,zzz,zzz,zzz,zz9.99-" label      " Сумма платежа      "
         comm_summ AS decimal FORMAT "z,zz9.99-" label "Комиссия банка" skip
         summall AS decimal FORMAT "z,zzz,zzz,zzz,zz9.99-" label   " Общая сумма платежа" skip
         "____________________________________________________________________________________________________________" skip(1)
         space(16) SMess no-label

  WITH SIDE-LABELS centered overlay row 3 WIDTH 110 TITLE "Прием коммунальных платежей" .




/***********************************************************************************************************/
/* возвращает список инвойсов найденных в темп таблице */
function ListInvoice returns char ():
  def var InList as char init "".
  for each wrk no-lock:
    if LENGTH(InList) = 0 then InList = wrk.Invoice.
    else do:
      if LOOKUP(wrk.Invoice,InList,"|") = 0 then InList = InList + "|" + wrk.Invoice.
    end.
  end.
 return InList.
end function.
/***********************************************************************************************************/
/* возвращает кол-во инвойсов найденных в темп таблице */
function InvoiceCount returns int ():
  def var InList as char init "".
  def var Count as int init 0.
  for each wrk no-lock:
    if LENGTH(InList) = 0 then do: InList = wrk.Invoice. Count = 1. end.
    else do:
      if LOOKUP(wrk.Invoice,InList,"|") = 0 then do: InList = InList + "|" + wrk.Invoice. Count = Count + 1. end.
    end.
  end.
 return Count.
end function.
/***********************************************************************************************************/
/* возвращает общую сумму документа */
function CalcSumm returns decimal(input CurInvoice as char):
  def var Summ as deci init 0.
    for each wrk no-lock where wrk.Invoice = CurInvoice :
      Summ = Summ + wrk.Pay.
    end.
  return Summ.
end function.
/***********************************************************************************************************/
/* возвращает статус проводки */
function GetState returns int(input p-jh as int):
 def var p-stat as int.
 find first jh where jh.jh = p-jh no-lock no-error.
 if avail jh then
 do:
   p-stat = jh.sts.
 end.
 else p-stat = -1.
 return p-stat.
end function.
/***********************************************************************************************************/


    ON CURSOR-UP OF b_list in  frame MainFrame
    DO:
      GET PREV q_list.
      if avail wrk then SDuty = wrk.Duty.
      run ShowFrame(Doc).
    END.

    ON CURSOR-DOWN OF b_list in  frame MainFrame
    DO:
      GET NEXT q_list.
      if avail wrk then SDuty = wrk.Duty.
      run ShowFrame(Doc).
    END.

    ON END-ERROR OF b_list in  frame MainFrame
    DO:
      pos = 9.
    END.

/***********************************************************************************************************/
    /* Нажали ENTER на строке */
    ON RETURN OF b_list  in  frame MainFrame
    DO:
     if Doc:docno = ? then
     do:

       def var Pos as int.
       Pos = b_list:focused-row.

       displ
       wrk.Curr format "zzzzzz9.99"  wrk.Prev format "zzzzzz9.99" wrk.Amount format "zzzzzz9.99" wrk.Price wrk.Unit format "x(10)"
       wrk.ForPay format "zzzzzzz9.99" wrk.Pay format "zzzzzzz9.99"  view-as fill-in size 11 by 1
       with no-label overlay row b_list:focused-row + 11 column 29 no-box frame EditFrame width 79.

       def var OldCurr as deci.
       def var OldPay as deci.

       /* оплата по счетчику */
       if wrk.Counter = 1 then do:
          OldCurr = wrk.Curr.
          set wrk.Curr with frame EditFrame.

          v-Suppcom = "229,8".
          if lookup(string(Doc:ap_code),trim(v-Suppcom)) > 0 then do:
              /************************/
              if lookup(string(wrk.IdSub),"13,23") > 0 then do:
                v-FormulType = false. v-ForPay = 0. v-prevCountDate = ?. v-lastCountDate = ?.
                if lookup(string(wrk.IdSub),"13") > 0 then do:
                  find first b-wrk where b-wrk.Invoice = wrk.Invoice and lookup(string(b-wrk.IdSub),"23") > 0 no-lock no-error.
                  if avail b-wrk then v-FormulType = true.
                end.
                if lookup(string(wrk.IdSub),"23") > 0 then do:
                  find first b-wrk where b-wrk.Invoice = wrk.Invoice and lookup(string(b-wrk.IdSub),"13") > 0 no-lock no-error.
                  if avail b-wrk then v-FormulType = true.
                end.

                v-prevCountDate = date(01,month(today),year(today)).
                if wrk.prevCountDate = ? then
                update v-prevCountDate format "99/99/9999" with column 35 row 6 no-label overlay title "Дата пред.показ." frame SetDate1.
                else v-prevCountDate = wrk.prevCountDate.
                hide frame SetDate1.

                v-lastCountDate = today.
                update v-lastCountDate format "99/99/9999" with column 35 row 6 no-label overlay title "Дата послед.показ." frame SetDate2.
                hide frame SetDate2.

                if v-lastCountDate <> ? then do:
                    run AddCalcProv(
                    v-FormulType, /*1*/
                    wrk.IdSub, /*2*/
                    wrk.Curr, /*3*/
                    wrk.Prev, /*4*/
                    wrk.tKoef, /*5*/
                    wrk.lossesCount, /*6*/
                    wrk.minTariffValue, /*7*/
                    wrk.middleTariffValue, /*8*/
                    wrk.maxTariffValue, /*9*/
                    wrk.minTariffThreshold, /*10*/
                    wrk.middleTariffThreshold, /*11*/
                    v-prevCountDate, /*12*/
                    v-lastCountDate, /*13*/
                    wrk.parValue, /*14*/
                    "13,23", /*15*/
                    output v-ForPay).

                    update wrk.ForPay = v-ForPay with frame EditFrame.
                    update wrk.Pay = wrk.ForPay with frame EditFrame.
                end.
                wrk.lastCountDate = v-lastCountDate.
                wrk.FormulType = v-FormulType.
              end.
              /************************/
          end.
          if wrk.Curr entered then do:
            if wrk.Curr < wrk.Prev then do:
               message "Последнее значение меньше предыдущего " view-as alert-box.
               wrk.Curr = OldCurr.
               undo.
            end.
            else do:
               wrk.Amount = wrk.Curr - wrk.Prev.
               wrk.ForPay = wrk.Amount * wrk.Price.
               wrk.Pay = wrk.ForPay.

               displ
               wrk.Curr format "zzzzzz9.99"  wrk.Prev format "zzzzzz9.99" wrk.Amount format "zzzzzz9.99" wrk.Price wrk.Unit format "x(10)"
               wrk.ForPay format "zzzzzzz9.99" wrk.Pay format "zzzzzzz9.99" view-as fill-in size 11 by 1
               with  no-label overlay row b_list:focused-row + 11  column 29 no-box  frame EditFrame width 79.
            end.
          end.
          update wrk.Pay with frame EditFrame.
       end.
       else do:
          /*без счетчика*/
          set wrk.Pay with frame EditFrame.
       end.

       /******************************************************************/
       hide frame EditFrame.
       open query q_list for each wrk where wrk.Invoice = CurInvoice BY wrk.sortOrder.

       Doc:summ = CalcSumm(CurInvoice).
       run ShowFrame(Doc).
       b_list:SELECT-ROW(Pos).
     end.
    END.

/***********************************************************************************************************/

     if Doc:docno = ? then
     do:
      Usr = NEW ACCOUNTClass(Base,Doc:supp_id).
      pos = 1.
     end.
     else pos = 5.
/***********************************************************************************************************/

      REPEAT on  ENDKEY UNDO  , leave :

        CASE pos:

          WHEN 1 THEN
          DO:  /* Ввод лицевого счета получение инвойса и поиск владельца в базе */
                 SMess = "                                   Введите номер лицевого счета".
                 run ShowFrame(Doc).
                 set payacc with frame MainFrame.
                 if payacc entered then
                 do:
                   if not Doc:CheckAcc(payacc) then undo. /*Проверка правильности введенного счета */
                   /*********************************************/
                   if Doc:ap_check > 0 then
                   do: /*Наличие онлайн проверки по авангард плат*/
                     if not Usr:FindAcc(payacc) then Usr:acc = payacc.

                     SMess = "                                         Ждите... Идет проверка".
                     run ShowFrame(Doc).

                     empty temp-table wrk.

                     run ap_check( Usr ,output err, output errdes).
                     if err <> 0 then do: SMess ="". message errdes view-as alert-box. undo. end.
                     else SMess = "                                [F1]-выполнить транзакцию, [F4]-отмена".

                     if Usr:acc_id = ? then
                     do: /* Клиент у нас первый раз */
                         Doc:payacc = Usr:acc. /*payacc. */
                         Doc:payname = CAPS(Usr:name).
                         Doc:payaddr = CAPS(Usr:addr).
                         if Usr:rnn = "" then Doc:payrnn = "000000000000".
                         else Doc:payrnn = Usr:rnn.

                     end.
                     else do: /* клиент уже был у нас*/
                        if Usr:payname <> Usr:name then
                        do:
                          message "Данные полученные от сервиса не соответствуют локальным! \n"
                                  "Используются локальные данные" view-as alert-box.
                          Usr:name = Usr:payname.
                        end.

                         Doc:SetUsrData(Usr).
                     end.
                   end.
                   else do: /* проверки по авангардплат - нет*/
                     message "Данный тип провайдера не работает без онлайн проверки!" view-as alert-box.
                     undo.
                   end.



                 /*   {test_data.i}*/
                   find first wrk no-lock no-error.
                   if avail wrk then
                   do:
                     /**************************************************************/
                     if InvoiceCount() > 1 then do:
                        run sel1("Выберите инвойс", ListInvoice()).
                        CurInvoice = return-value.
                     end.
                     else do:
                       find first wrk no-lock no-error.
                       if avail wrk then CurInvoice = wrk.Invoice.
                       else do: message "Ошибка при получении данных платежа!". undo. end.
                     end.

                     if CurInvoice = "" or CurInvoice = ? then
                     do:
                       message "Ошибка при получении инвойса!" view-as alert-box.
                       undo.
                     end.

                     open query q_list for each wrk where wrk.Invoice = CurInvoice BY wrk.sortOrder.
                     /**************************************************************/
                   end.
                   else do: message "Нет данных по этому номеру счета!". undo. end.


                     pos = 2.
                 end.
                 else do: Usr:ClearData(). undo. end.

                 pause 0.
          END.
          WHEN 2 THEN
          DO: /* Редактирование данных платежа */

                 Doc:summ = CalcSumm(CurInvoice).
                 find first wrk no-lock no-wait no-error.
                 SDuty = wrk.Duty.
                 run ShowFrame(Doc).

                 set b_list with frame MainFrame.

                 Doc:summ = CalcSumm(CurInvoice).

                 if Doc:minsum > 0 then
                 do:
                   if Doc:summ < Doc:minsum then
                   do:
                     message "Минимальная сумма платежа - " + string(Doc:minsum) + " тенге" view-as alert-box.
                     pos = 2.
                     undo.
                   end.
                 end.


              pos = 3.
              pause 0.
          END.
          WHEN 3 THEN
          DO: /* при добавлении нового плательщика в локальную базу */

                   if Usr:acc_id = ? then
                   do:
                       SMess = "                                  Добавление нового плательщика... ".
                       run ShowFrame(Doc).
                       pause 1.

                       Usr:AddData().
                       Usr:payname = Doc:payname.
                       Usr:acc     = Doc:payacc.
                       Usr:phone   = Doc:payphone.
                       Usr:addr    = Doc:payaddr.
                       Usr:rnn     = Doc:payrnn.
                       if Usr:Post() then
                       do:
                         Usr:FindAcc(Doc:payacc).
                         Doc:SetUsrData(Usr).
                       end.
                       else do: message "Ошибка при добавлении счета!" view-as alert-box. Usr:ClearData(). undo. end.
                   end.
                   pos = 4.
               pause 0.
           END.
           WHEN 4 THEN
           DO:
               /* Сохранение документа */
                if Doc:docno = ? then
                do:
                   if Doc:Post() then
                   do:
                     /******************************************************************************************/
                     for each wrk where wrk.Invoice = CurInvoice:
                       Doc:ExData:AddData().
                       Doc:ExData:IdSub = wrk.IdSub.
                       Doc:ExData:Invoice = wrk.Invoice.
                       Doc:ExData:docno = Doc:docno.
                       Doc:ExData:Counter = wrk.Counter.
                       Doc:ExData:NamSub = wrk.NamSub.
                       Doc:ExData:Curr = wrk.Curr.
                       Doc:ExData:Prev = wrk.Prev.
                       Doc:ExData:Amount = wrk.Amount.
                       Doc:ExData:Price = wrk.Price.
                       Doc:ExData:Unit = wrk.Unit.
                       Doc:ExData:Duty = wrk.Duty.
                       Doc:ExData:ForPay = wrk.ForPay.
                       Doc:ExData:Pay = wrk.Pay.
                       Doc:ExData:sortOrder = wrk.sortOrder.
                       Doc:ExData:parValue = wrk.parValue.
                       Doc:ExData:tKoef = wrk.tKoef.
                       Doc:ExData:lossesCount = wrk.lossesCount.
                       Doc:ExData:prevCountDate = wrk.prevCountDate.
                       Doc:ExData:lastCountDate = wrk.lastCountDate.
                       Doc:ExData:minTariffValue = wrk.minTariffValue.
                       Doc:ExData:minTariffThreshold = wrk.minTariffThreshold.
                       Doc:ExData:maxTariffValue = wrk.maxTariffValue.
                       Doc:ExData:middleTariffValue = wrk.middleTariffValue.
                       Doc:ExData:middleTariffThreshold = wrk.middleTariffThreshold.
                       /*-------------------------------------------------------------------------*/
                       Doc:ExData:ChangePar(wrk.docno,wrk.IdSub,wrk.lastCountDate,wrk.FormulType).
                       /*-------------------------------------------------------------------------*/
                       if not Doc:ExData:Post() then
                       do:
                         message "Ошибка при добавлении расширенных данных платежа!" view-as alert-box.
                         LEAVE.
                       end.
                     end.
                     /******************************************************************************************/
                      SMess = "                                        Документ сохранен... ".

                      Doc:FindDocNo(string(Doc:docno)).

                      run ShowFrame(Doc).
                      pause 1.

                      pos = 6.

                   end.
                   else do:
                     message "Ошибка при сохранении документа!" view-as alert-box.
                     pos = 9.
                     undo.
                   end.
                end.
                else do:
                  message "Ошибка, документ уже имеет номер!" view-as alert-box.
                  undo.
                end.

                hide message no-pause.
           END.
          WHEN 5 THEN
          DO: /* Просмотр или проведение существующего документа*/
                for each wrk: delete wrk. end.
                def var y as int.
                REPEAT y = 1 to Doc:ExData:Count:
                    create wrk.
                    wrk.IdSub = Doc:ExData:ElementBy(y):IdSub.
                    wrk.Invoice = Doc:ExData:ElementBy(y):Invoice.
                    wrk.docno = Doc:ExData:ElementBy(y):docno.
                    wrk.Counter = Doc:ExData:ElementBy(y):Counter.
                    wrk.NamSub = Doc:ExData:ElementBy(y):NamSub.
                    wrk.Curr = Doc:ExData:ElementBy(y):Curr.
                    wrk.Prev = Doc:ExData:ElementBy(y):Prev.
                    wrk.Amount = Doc:ExData:ElementBy(y):Amount.
                    wrk.Price = Doc:ExData:ElementBy(y):Price.
                    wrk.Unit = Doc:ExData:ElementBy(y):Unit.
                    wrk.Duty = Doc:ExData:ElementBy(y):Duty .
                    wrk.ForPay = Doc:ExData:ElementBy(y):ForPay.
                    wrk.Pay = Doc:ExData:ElementBy(y):Pay.
                    wrk.sortOrder = Doc:ExData:ElementBy(y):sortOrder.
                    wrk.parValue = Doc:ExData:ElementBy(y):parValue.
                    wrk.tKoef = Doc:ExData:ElementBy(y):tKoef.
                    wrk.lossesCount = Doc:ExData:ElementBy(y):lossesCount.
                    wrk.prevCountDate = Doc:ExData:ElementBy(y):prevCountDate.
                    wrk.lastCountDate = Doc:ExData:ElementBy(y):lastCountDate.
                    wrk.minTariffValue = Doc:ExData:ElementBy(y):minTariffValue.
                    wrk.minTariffThreshold = Doc:ExData:ElementBy(y):minTariffThreshold.
                    wrk.maxTariffValue = Doc:ExData:ElementBy(y):maxTariffValue.
                    wrk.middleTariffValue = Doc:ExData:ElementBy(y):middleTariffValue.
                    wrk.middleTariffThreshold = Doc:ExData:ElementBy(y):middleTariffThreshold.
                END.
                open query q_list for each wrk BY wrk.sortOrder.
                CurInvoice = wrk.Invoice.

                 run ShowFrame(Doc).



                   case Doc:state:
                     when  -3 then
                     do:
                        SMess =  "                                          [F4]-Закрыть".
                        run ShowFrame(Doc).
                        READKEY.
                     end.
                     when -1 then
                     do:
                        SMess =  "                     [F1]-перепровести, [Delete]-Заявка на отмену, [F4]-Закрыть".
                        run ShowFrame(Doc).
                        READKEY.

                        IF KEYFUNCTION(LASTKEY) = "DELETE-CHARACTER" then
                        do:
                          run yn("","Вы уверены?","Подтвердите отмену документа","", output rez).
                          if rez then
                          do:
                            run delpay(Doc).
                            pos = 9.
                          end.
                          else undo.
                        end.

                        if KEYFUNCTION(LASTKEY) = "GO" then do:
                          def var NewDoc as class COMPAYDOCClass.
                          NewDoc = NEW COMPAYDOCClass(Base).
                          Doc:FindDocNo(string(Doc:docno)).
                          if not NewDoc:ReSend(Doc) then do:
                            pos = 9.
                            pause 0.
                          end.
                          else do:
                            pos = 7.

                            pause 0.
                          end.
                          DELETE OBJECT NewDoc NO-ERROR.
                        end.
                     end.
                     when  0 then
                     do:

                        if GetState(Doc:jh) > 0 then
                        do:
                          SMess = "                               [F1]-выполнить отправку, [F4]-Закрыть".
                        end.
                        else do:
                          SMess = "                                   [F1]-Штамповать, [F4]-Закрыть".
                        end.

                        run ShowFrame(Doc).
                        READKEY.
                        if KEYFUNCTION(LASTKEY) = "GO" then do: if GetState(Doc:jh) > 0 then pos = 7. else pos = 8.  undo. end.

                     end.
                     when  1 then
                     do:

                        SMess =  "                                          [F4]-Закрыть".
                        run ap_trxsts(Doc, output err, output errdes).
                        if err <> 0 then
                        do:
                           message errdes view-as alert-box.
                        end.
                        if Doc:state <> 1 then do: pos = 5. undo. end.
                        else do:
                          run ShowFrame(Doc).
                          READKEY.
                        end.
                     end.
                     when  2 then
                     do:
                        SMess =  "                       [Delete]-Заявка на отмену, [F6]-Печать, [F4]-Закрыть".
                        run ShowFrame(Doc).
                        READKEY.
                        IF LASTKEY = KEYCODE("F6") then do:  Doc:PrintPKO().  undo. end.

                        IF KEYFUNCTION(LASTKEY) = "DELETE-CHARACTER" then
                        do:
                          run yn("","Вы уверены?","Подтвердите отмену документа","", output rez).
                          if rez then
                          do:
                            run delpay(Doc).
                            pos = 9.
                          end.
                          else undo.
                        end.

                     end.
                     when  3 then
                     do:

                        SMess =  "                                          [F4]-Закрыть".
                        run ShowFrame(Doc).
                        READKEY.
                     end.
                     when  4 then
                     do:
                        SMess =  "                                   [F1]-Сторно, [F4]-Закрыть".
                        run ShowFrame(Doc).
                        READKEY.

                        if KEYFUNCTION(LASTKEY) = "GO" then
                        do:
                          run yn("","Вы уверены?","Подтвердите сторнирование документа","", output rez).
                          if rez then
                          do:
                            if Doc:CancelDoc() then
                            do:
                             Doc:TrxSts().
                             s-jh = Doc:prev_docno.
                             if v-noord = no then run vou_bank(0).
                             else run printord(s-jh,"").
                            end.
                            pos = 9.
                          end.
                          else undo.
                        end.

                     end.
                     when  5 then
                     do:
                        SMess =  "                                   [F1]-Сторно, [F4]-Закрыть".
                        run ShowFrame(Doc).
                        READKEY.

                        if KEYFUNCTION(LASTKEY) = "GO" then
                        do:
                          run yn("","Вы уверены?","Подтвердите сторнирование документа","", output rez).
                          if rez then
                          do:
                            if Doc:CancelDoc() then
                            do:
                             Doc:TrxSts().
                             s-jh = Doc:prev_docno.
                             if v-noord = no then run vou_bank(0).
                             else run printord(s-jh,"").
                             /*  Для автоматического сторнирования в АП
                             run ap_stor( Doc ,output err, output errdes).
                             if err <> 0 then
                             do:
                                 message "При сторнировании документа в Авангард-Plat произошла ошибка ! \n" errdes view-as alert-box.

                             end.
                             else do:
                               SMess =  "                       Платеж сторнирован...".
                               run ShowFrame(Doc).
                               pause 1.
                             end.
                            */
                            end.
                            pos = 9.
                          end.
                          else undo.
                        end.

                     end.
                     when  6 then
                     do:
                        SMess =  "                                          [F4]-Закрыть".
                        run ShowFrame(Doc).
                        READKEY.
                     end.
                     when  7 then
                     do:
                        SMess =  "                                          [F4]-Закрыть".
                        run ShowFrame(Doc).
                        READKEY.
                     end.
                   end case.


                   IF keyfunction(lastkey) = "END-ERROR" then do: LEAVE. end.
          END.
          WHEN 6 THEN
          DO: /* Формирование проводки */
             SMess =  "                   Ждите... идет формирование проводки и печать приходного ордера.".
             run ShowFrame(Doc).

             rez = no.
             run compay_trx(Doc,output rez).
             if rez then
             do:
                Doc:PrintPKO().
              /*  message "PrintPKO" view-as alert-box.*/

               pos = 8.
               pause 1.
               iRez = Yes.
             end.
             else do: /* Ошибка при формировании проводки */
                message "Ошибка при формировании проводки" view-as alert-box.
                iRez = No.
                LEAVE.
             end.

             hide message no-pause.
          END.
          WHEN 7 THEN
          DO:
            if avail comm.pksysc then do:
              if comm.pksysc.inval = 1 then do: /*1 - разрешено, 2 - запрещено*/
                /* Отправка платежа в Авангард-Plat*/
                   if Doc:state = 0 then
                   do:
                     SMess =  "                                   Ждите... идет отправка платежа.".
                      run ShowFrame(Doc).

                      err = 0.
                      run ap_trx( Doc ,output err, output errdes).

                      if err <> 0 then
                      do:
                         message "При отправке документа в Авангард-Plat произошла ошибка ! \n" errdes view-as alert-box.

                      end.
                      else do:
                        SMess =  "                                         Платеж отправлен...".
                         run ShowFrame(Doc).
                         pause 1.

                      end.

                      pos = 9.

                   end.
                   else do:
                     message "Статус документа - "  + string(Doc:state) view-as alert-box.
                     pos = 9.
                   end.

                 hide message no-pause.
              end.
              else do:
                pause 0.
                pos = 9.
              end.
            end.
          END.
          WHEN 8 THEN
          DO: /* Штамп проводки */
            run ShowFrame(Doc).
            run yn("","Штамповать?","","", output rez).
            if rez then
            do:
              if Doc:TrxSts() then
              do:
                Doc:PrintPKO2().
                pos = 7.
              end.
              else do:
                message "Ошибка при штамповке проводки!" view-as alert-box.
                pos = 8.
              end.
            end.
            else do:

              run yn("","Вы уверены?","Подтвердите удаление документа","", output rez).
              if rez then
              do:

                 find first compaydoc where compaydoc.docno = Doc:docno no-lock no-error.
                 if avail compaydoc and compaydoc.state <> 0 then do:
                    run mail("id00205@metrocombank.kz", g-ofc + "@metrocombank.kz" , "Удаление", "Попытка удалить документ!", "", "", "").
                    message "Ждите...".
                    pause 60.
                    LEAVE.
                 end.

                 run trxdel(Doc:jh,input false,output err,output errdes).
                 if err <> 0 then
                 do:
                    message errdes view-as alert-box.
                    LEAVE.
                 end.
                 else do:

                     SMess =  "                                         Проводка удалена...".
                   run ShowFrame(Doc).
                   pause 1.

                   if Doc:DeleteDoc() then
                   do:
                     SMess =  "                                         Документ удален...".
                     run ShowFrame(Doc).
                     pause 1.
                     LEAVE.
                   end.
                   else do:
                     SMess =  "                                    Ошибка удаления документа...".
                     run ShowFrame(Doc).
                     pause 1.
                   end.

                   pos = 9.
                 end.
              end.
              else pos = 8.

            end.

            hide message no-pause.
          END.
          WHEN 9 THEN
          DO: /* Выход */
            pause 0.
            Doc:Free().
            SMess =  "".
            run ShowFrame(Doc).
            run yn("","Закрыть текущий документ?","","", output rez).
            if rez then do: /*Doc:Free().*/ LEAVE. end.
            else do:
             pos = 5.
            end.
          END.
        END CASE.

        hide message no-pause.
      END. /*REPEAT*/

/***********************************************************************************************************/
  if VALID-OBJECT(Usr)  then DELETE OBJECT Usr NO-ERROR .
  HIDE FRAME MainFrame.
/***********************************************************************************************************/
procedure ShowFrame:
           def input param Doc as COMPAYDOCClass.

           if Doc:docNo = ? then docNo = "00000000".
           else docNo = string(Doc:docNo,"99999999").

           if Doc:jh = ? then docJH = "0000000".
           else docJH = string(Doc:jh,"9999999").

           if Doc:note <> ? then ntmess = Doc:note.
           else ntmess = "".

           case Doc:state:
             when -3 then do: State = "НЕ ПРОВЕДЕН (ПОМЕЧЕН НА ОТМЕНУ)". end.
             when -1 then do: State = "НЕ ПРОВЕДЕН " + Doc:note .  end.
             when  0 then do: State = "НЕ ОТПРАВЛЕН". end.
             when  1 then do: State = "ОТПРАВЛЕН В ОБРАБОТКУ".  end.
             when  2 then do: State = "ПРОВЕДЕН - " + string(Doc:ap_whn) + " " + string(Doc:ap_time,"HH:MM:SS") +  ntmess.  end.
             when  3 then do: State = "ПРОВЕДЕН (ПОМЕЧЕН НА ОТМЕНУ)". end.
             when  4 then do: State = "ОТМЕНЕН (СТОРНИРОВАНИЕ)". end.
             when  5 then do: State = "ОТМЕНЕН (СТОРНИРОВАНИЕ)". end.
             when  6 then do: State = "ПРОВЕДЕН СТОРНИРОВАН" + Doc:note. end.
             when  7 then do: State = "НЕ ПРОВЕДЕН СТОРНИРОВАН" + Doc:note. end.
           end case.


           suppname  = Doc:suppname.
           if Doc:payname <> Doc:payaddr then payname   = CAPS(Doc:payname).
           else payname = "".
           payacc    = Doc:payacc.
           summ      = Doc:summ.
           comm_summ = Doc:comm_summ.
           address   = Doc:payaddr.
           if Doc:summ = 0 then summall = 0.
           else summall   = Doc:summ + Doc:comm_summ.
           DISPLAY docNo docJH suppname payname payacc CurInvoice
                   address b_list State summ comm_summ summall SDuty SMess  WITH  FRAME MainFrame.

end procedure.
/***********************************************************************************************************/

