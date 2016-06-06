/* compay2.p
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
        13.10.2010 k.gitalov перекомпиляция
        25.10.2010 k.gitalov проверка на доступность сервиса
        13.01.2012 damir - добавил keyord.i, printord.p
        07.03.2012 damir - добавил входной параметр в printord.p.
        27.04.2012 k.gitalov добавил [diji] АСТАНА [diji] АКТАУ [diji] КАРАГАНДА [diji] ТАРАЗ [diji] УРАЛЬСК
        23.05.2012 damir - убрал входной строковый параметр, передаваемый в printord.p,поставил пусто.
        14.11.2012 damir - Оптимизация.Контроль отправки платежей (вручную или автоматически).
        15.11.2012 damir - добавил pause 0,поставил Doc:Free() перед сообщением о закрытии документа.
        27.02.2013 damir - Внесены изменения, вступившие в силу 01/02/2013.
*/


/*
Тип провайдера  (Асибо):
 Во временной таблице wrk может вернуться несколько номеров счетов с соответствующими начальными цифрами введенного счета
 записи wrk содержат номера счетов ФИО и адрес
 Менеджеру дается возможность выбрать необходимый счет

Тип провайдера  (Отис):
 Во временной таблице wrk может вернуться несколько инвойсов
 записи wrk содержат номер инвойса, номер договора, дату выставления счета, сумму к оплате
 Менеджеру дается возможность выбрать необходимый инвойс

*/

{classes.i}
{keyord.i} /*Переход на новые и старые форматы ордеров*/


def input param  Doc as class COMPAYDOCClass.  /* Класс документов коммунальных платежей*/
define input parameter v-arp as character no-undo.
def output param iRez as log init no.

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

def var CurInvoice  as char.
def var SMess       as char format "x(70)"  .
def var tmpname     as char.
def var tmpacc      as char.
def var ntmess      as char.

{compayshared.i "new"}

DEFINE FRAME MainFrame
         skip (1)
         docNo as char label  "Номер документа   "         space(12)  docJH as char label  "Номер проводки" skip
         suppname as char label  "Получатель платежа" FORMAT "x(30)" knp AS char FORMAT "x(3)" label "КНП" skip
        "_____________________________________________________________________________" skip(1)
         payname AS character FORMAT "x(34)" label "Плательщик    "
         payrnn AS character FORMAT "x(12)"  label "РНН" skip
         payaddr AS character FORMAT "x(45)" label "Дополнительно " skip
         "_____________________________________________________________________________" skip(1)


         payacc as char format "x(12)" label "№ телефона/счета   " space(8)
         summ AS decimal FORMAT "zzz,zzz,zz9.99-" label      "Сумма платежа" skip(1)
         /* State AS character FORMAT "x(55)" label "Статус платежа     " space*/
         State AS character VIEW-AS EDITOR  INNER-CHARS 55 INNER-LINES 2 label "Статус платежа     " space
         "_____________________________________________________________________________" skip(1)
         comm_summ AS decimal FORMAT "zzz,zzz,zz9.99-" label "Комиссия банка     " skip
         summall AS decimal FORMAT   "zzz,zzz,zz9.99-" label   "Общая сумма платежа" skip
         "_____________________________________________________________________________" skip(1)
         space(4) SMess no-label

 WITH SIDE-LABELS centered overlay row 8 WIDTH 80 TITLE "Прием коммунальных платежей".


  def shared var s-jh      like jh.jh .

  def var rez as log init no.
  def var pos as int init 1.
  def var err as integer no-undo.
  def var errdes as char no-undo.
  def var Usr as class ACCOUNTClass.    /* Класс данных плательщиков */

     if Doc:docno = ? then
     do:
      Usr = NEW ACCOUNTClass(Base,Doc:supp_id).
      pos = 1.
     end.
     else pos = 5.

 ON GO OF summ in  frame MainFrame
 DO:
    if summ > 0 and summ >= Doc:minsum then
    do:
     pos = 4.
     hide message no-pause.
    end.
 END.

/***********************************************************************************************************/
/* возвращает список аккаунтов найденных в темп таблице */
function ListInvoice returns char ():
  def var InList as char init "".
  for each wrk no-lock:
    if LENGTH(InList) = 0 then InList = wrk.Invoice + " " + wrk.NamSub + " " + wrk.Unit.
    else do:
      if LOOKUP(wrk.Invoice,InList,"|") = 0 then InList = InList + "|" + wrk.Invoice + " " + wrk.NamSub + " " + wrk.Unit.
    end.
  end.
 return InList.
end function.
/***********************************************************************************************************/
/* возвращает кол-во аккаунтов найденных в темп таблице */
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

/***********************************************************************************************************/

      REPEAT on  ENDKEY UNDO  , leave :
        run ShowFrame(Doc).
        CASE pos:

          WHEN 1 THEN
          DO:
                /* Ввод лицевого счета и поиск владельца в базе */
                 set payacc with frame MainFrame.
                 if payacc entered then
                 do:
                   /*Проверка правильности введенного счета */
                   if not Doc:CheckAcc(payacc) then undo.
                   /*********************************************/
                   if Doc:ap_check > 0 then
                   do: /*Наличие онлайн проверки по авангард плат*/
                     if not Usr:FindAcc(payacc) then Usr:acc = payacc.

                     empty temp-table wrk.

                     run ap_check( Usr ,output err, output errdes).
                     if err <> 0 then do: message errdes view-as alert-box. undo. end.

                     if Doc:ap_code = 185 or Doc:ap_code = 186 or Doc:ap_code = 5 or Doc:ap_code = 526 or Doc:ap_code = 545 or Doc:ap_code = 546 or Doc:ap_code = 547 or Doc:ap_code = 548 or Doc:ap_code = 549 then do: /*AKTIV KCELL */
                         if Usr:FindAcc(payacc) then Doc:SetUsrData(Usr).
                         else do:
                           Doc:payacc  = payacc.
                           Doc:payrnn  = "000000000000".
                           Doc:payaddr = "NO ADDRESS".
                           Doc:payname = "NO NAME".
                         end.
                      pos = 3.
                     end.
                     else do:
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
                           if avail wrk then CurInvoice = wrk.Invoice + " " + wrk.NamSub + " " + wrk.Unit.
                           else do: message "Ошибка при получении данных платежа!". undo. end.
                         end.

                         if CurInvoice = "" or CurInvoice = ? then
                         do:
                           message "Ошибка при получении инвойса!" view-as alert-box.
                           undo.
                         end.
                         /*CurInvoice выбрали*/
                        end.
                        else do: message "Нет данных по этому номеру счета!". undo. end.
                        pos = 2.
                     end.

                   end.
                   else do: /* проверки по авангардплат - нет*/
                     if Usr:FindAcc(payacc) then Doc:SetUsrData(Usr).
                     else do:
                       Doc:payacc  = payacc.
                       Doc:payrnn  = "000000000000".
                       Doc:payaddr = "NO ADDRESS".
                       Doc:payname = "NO NAME".
                     end.
                      pos = 3.
                   end.
                   /*********************************************/
                 end.
                 else do: Usr:ClearData(). undo. end.

                pause 0.
          END.
          WHEN 2 THEN
          DO:
                  /*Провайдеры возвращающие данные в TEMP таблицу*/

                     find first wrk where (wrk.Invoice + " " + wrk.NamSub + " " + wrk.Unit) = CurInvoice.
                     if avail wrk then
                     do:

                         if INDEX(wrk.Invoice,Usr:acc) > 0 then /*если в инвойсе присутствует номер счета то...*/
                         do:
                          /*
                            Тип провайдера  (Асибо):
                            Во временной таблице wrk может вернуться несколько номеров счетов с соответствующими начальными цифрами введенного счета
                            записи wrk содержат номера счетов ФИО и адрес
                          */
                          if not Usr:FindUser(wrk.Invoice,wrk.NamSub,wrk.Unit) then
                          do: /*не нашли... новенький*/
                            Doc:payacc = wrk.Invoice.
                            Doc:payname = CAPS(wrk.NamSub).
                            Doc:payaddr = CAPS(wrk.Unit).
                            Doc:payrnn = "000000000000".
                          end.
                          else do:
                            /*нашли в базе*/
                            if Usr:payname <> wrk.NamSub or Usr:addr <> wrk.Unit then
                            do: /*еще и не соответствуют данные 0_o*/
                              message "Данные полученные от сервиса не соответствуют локальным! \n"
                                   "Будет создана новая запись!" view-as alert-box.
                              Usr:acc_id = ?.
                              Doc:payacc =  wrk.Invoice.
                              Doc:payname = CAPS(wrk.NamSub).
                              Doc:payaddr = CAPS(wrk.Unit).
                              Doc:payrnn  = "000000000000".
                            end.
                            else  Doc:SetUsrData(Usr).
                            /*все ок...*/
                          end.
                         end.
                         else do:
                          /*
                            Тип провайдера  (Отис):
                            Во временной таблице wrk может вернуться несколько инвойсов
                            записи wrk содержат номер инвойса, номер договора, дату выставления счета, сумму к оплате
                          */
                          tmpname = Usr:name.
                          tmpacc =  Usr:acc.
                          if not Usr:FindUser(Usr:acc,Usr:name,wrk.NamSub) then
                          do: /*не нашли... новенький*/
                            Doc:payacc = tmpacc.
                            Doc:payname = CAPS(Usr:name).
                            Doc:payaddr = CAPS(wrk.NamSub). /*номер договора */
                            Doc:payrnn = "000000000000".
                          end.
                          else do:
                            /*нашли в базе*/
                            if Usr:payname <> tmpname or Usr:addr <> CAPS(wrk.NamSub) then
                            do: /*еще и не соответствуют данные 0_o*/
                              message "Данные полученные от сервиса не соответствуют локальным! \n"
                                   "Будет создана новая запись!" view-as alert-box.
                              Usr:acc_id = ?.
                              Doc:payacc  = Usr:acc.
                              Doc:payname = tmpname.
                              Doc:payaddr = CAPS(wrk.NamSub). /*номер договора*/
                              Doc:payrnn  = "000000000000".
                            end.
                            else  Doc:SetUsrData(Usr).
                            /*все ок...*/
                          end.
                          /* Doc:summ = wrk.ForPay.*/
                         end.

                         if wrk.ForPay <> 0 and wrk.ForPay <> ? then Doc:summ = wrk.ForPay.

                         pos = 3.

                     end.
                     else do:
                       message "Ошибка при инициализации аккаунта!" view-as alert-box.
                       undo.
                     end.
                    /**************************************************************/
                    pause 0.
          END.
          WHEN 3 THEN
          DO:
                   /* Ввод суммы платежа , сохранение плательщика если новый*/
                   if summ > 0 and summ >= Doc:minsum then do: SMess = "                [F1]-выполнить транзакцию, [F4]-отмена". run ShowFrame(Doc). pos = 4. end.
                   else do:
                       SMess =  "                           [F4]-отмена".

                       run ShowFrame(Doc).

                       set summ with frame MainFrame.

                       if summ = 0 or summ < Doc:minsum then
                       do:
                        if summ = 0 then  message "Сумма платежа не может быть = 0 !" view-as alert-box.
                        else message "Минимальная сумма платежа - " + string(Doc:minsum) + " тенге" view-as alert-box.
                        pos = 3.
                        undo.
                       end.
                       else  Doc:summ = summ.
                   end.

                   if Usr:acc_id = ? then
                   do:
                       SMess = "                  Добавление нового плательщика... ".
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

                   if CurInvoice <> "" and CurInvoice <> ? then Doc:note1 = CurInvoice.


                  hide message no-pause.

          END.
          WHEN 4 THEN
          DO:
                    IF keyfunction(lastkey) = "END-ERROR" then do: LEAVE. end.
                   /* Сохранение документа*/
                   /********************************************************************************/
                   if Doc:docno = ? then
                   do:
                     if not Doc:Post() then
                     do:
                       message "Ошибка при сохранении документа!" view-as alert-box.
                       pos = 9.
                       undo.
                     end.
                     else do:

                       SMess = "                         Документ сохранен... ".
                       run ShowFrame(Doc).
                       pause 1.

                       pos = 6.
                     end.
                   end.
                   /********************************************************************************/

                   hide message no-pause.

          END.
          WHEN 5 THEN
          DO:

                   /* Просмотр или проведение существующего документа*/


                   case Doc:state:
                     when  -3 then
                     do:
                        SMess =  "                           [F4]-Закрыть".
                        run ShowFrame(Doc).
                        READKEY.
                     end.
                     when -1 then
                     do:
                        /* SMess =  "                [Delete]-Заявка на отмену, [F4]-Закрыть         ". */
                           SMess =  "                [F1]-перепровести, [F4]-Закрыть                 ".

                        run ShowFrame(Doc).
                        READKEY.

/*
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
*/

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
                         SMess = "                [F1]-выполнить отправку, [F4]-Закрыть".
                        end.
                        else do:
                         SMess = "                   [F1]-Штамповать, [F4]-Закрыть".
                        end.

                        run ShowFrame(Doc).
                        READKEY.
                        if KEYFUNCTION(LASTKEY) = "GO" then do: if GetState(Doc:jh) > 0 then pos = 7. else pos = 8.  undo. end.

                     end.
                     when  1 then
                     do:
                        SMess =  "                           [F4]-Закрыть".
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
                        SMess =  "                     [F6]-Печать, [F4]-Закрыть                  ".
                       /*
                        SMess =  "        [Delete]-Заявка на отмену, [F6]-Печать, [F4]-Закрыть".*/
                        run ShowFrame(Doc).
                        READKEY.
                        IF LASTKEY = KEYCODE("F6") then do:  Doc:PrintPKO().  undo. end.
/*
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
*/
                     end.
                     when  3 then
                     do:
                        SMess =  "                           [F4]-Закрыть".
                        run ShowFrame(Doc).
                        READKEY.
                     end.
                     when  4 then
                     do:
                        SMess =  "                    [F1]-Сторно, [F4]-Закрыть".
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
                        SMess =  "                    [F1]-Сторно, [F4]-Закрыть".
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
                        SMess =  "                           [F4]-Закрыть".
                        run ShowFrame(Doc).
                        READKEY.
                     end.
                     when  7 then
                     do:
                        SMess =  "                           [F4]-Закрыть".
                        run ShowFrame(Doc).
                        READKEY.
                     end.
                     when  8 then
                     do:
                        /*SMess =  "                           [F4]-Закрыть".*/
                        /*run ShowFrame(Doc).*/
                        pos = 8.
                        hide message no-pause.
                     end.
                   end case.


                   IF keyfunction(lastkey) = "END-ERROR" then do: LEAVE. end.
          END.
          WHEN 6 THEN
          DO:
             /* Формирование проводки */
             SMess =  "  Ждите... идет формирование проводки и печать приходного ордера.".
             run ShowFrame(Doc).

             rez = no.
             run compay_trx100500(Doc,v-arp,output rez).
             if rez then
             do:
               Doc:PrintPKO().
             /*  message "PrintPKO" view-as alert-box.*/
               pos = 8.
               pause 1.

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
                      SMess =  "                 Ждите... идет отправка платежа.".
                      run ShowFrame(Doc).

                      err = 0.
                      run ap_trx( Doc ,output err, output errdes).

                      if err <> 0 then
                      do:
                         message "При отправке документа в Авангард-Plat произошла ошибка ! \n" errdes view-as alert-box.

                      end.
                      else do:
                         SMess =  "                       Платеж отправлен...".
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
          DO:   /* Штамп проводки */
            run ShowFrame(Doc).

            run yn("","Штамповать?","","", output rez).
            if rez then
            do:
              if Doc:TrxSts() then
              do:
                Doc:PrintPKO2().
                pos = 7.
                iRez = Yes.
              end.
              else do:
                message "Ошибка при штамповке проводки!" view-as alert-box.
                pos = 8.
                iRez = No.
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
                   SMess =  "                        Проводка удалена...".
                   run ShowFrame(Doc).
                   pause 1.

                   if Doc:DeleteDoc() then
                   do:
                     SMess =  "                        Документ удален...".
                     run ShowFrame(Doc).
                     pause 1.
                     LEAVE.
                   end.
                   else do:
                     SMess =  "                    Ошибка удаления документа...".
                     run ShowFrame(Doc).
                     pause 1.
                   end.

                   pos = 9.
                 end.
                 iRez = No.
              end.
              else pos = 8.

            end.

            hide message no-pause.

          END.
          WHEN 9 THEN
          DO:
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
           knp       = Doc:knp.
           payname   = Doc:payname.
           payrnn    = Doc:payrnn.
           payacc    = Doc:payacc.
           payaddr   = Doc:payaddr.
           summ      = Doc:summ.
           comm_summ = Doc:comm_summ.
           if Doc:summ = 0 then summall = 0.
           else summall   = Doc:summ + Doc:comm_summ.

           DISPLAY docNo docJH suppname  knp
                       payname payrnn  payaddr
                       payacc summ State
                       comm_summ summall SMess WITH  FRAME MainFrame.

end procedure.
