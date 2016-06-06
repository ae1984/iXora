/* COMPAYDOCEXClass.cls

 * MODULE

 * DESCRIPTION

 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список функций класса

 * MENU
        Перечень пунктов Меню Прагмы
 * BASES
        BANK COMM
 * AUTHOR
        27.10.2009 k.gitalov
 * CHANGES
        15.11.2012 damir - добавил NO-WAIT.
        27.02.2013 damir - Внесены изменения, вступившие в силу 01/02/2013.
*/


CLASS COMPAYDOCEXClass:
  DEFINE private BUFFER b-compaydocex FOR comm.compaydocex.
  DEFINE private VARIABLE LockRecord AS LOG.
  DEFINE private VARIABLE qh AS HANDLE.
  DEFINE private VARIABLE rez AS LOG.
  DEFINE private VARIABLE Positions AS INT.
  DEFINE private VARIABLE GlobalVar AS CLASS GlobalClass.
  DEFINE public  VARIABLE Count AS INT.
/***************************************************************************************************/
   CONSTRUCTOR public COMPAYDOCEXClass():
       GlobalVar = ?.
       LockRecord = false.
       CREATE QUERY qh.
       qh:SET-BUFFERS("b-compaydocex").
       Count = 0.
   END CONSTRUCTOR.
/***************************************************************************************************/
   CONSTRUCTOR public COMPAYDOCEXClass( INPUT std AS CLASS GlobalClass ):
       GlobalVar = std.
       LockRecord = false.
       CREATE QUERY qh.
       qh:SET-BUFFERS("b-compaydocex").
       Count = 0.
   END CONSTRUCTOR.
/***************************************************************************************************/
   DESTRUCTOR  public COMPAYDOCEXClass():
       ClearData().
       DELETE OBJECT qh.
   END DESTRUCTOR.
/***************************************************************************************************/
   define public  variable IdSub AS integer FORMAT "zzzzz9"  .
   define public  variable Invoice AS character FORMAT "x(12)"  .
   define public  variable docno AS integer FORMAT "zzzzzz9"  .
   define public  variable Counter AS integer FORMAT "zzzzz9"  .
   define public  variable NamSub AS character FORMAT "x(20)"  .
   define public  variable Curr AS decimal FORMAT "zzz9.99"  DECIMALS 6.
   define public  variable Prev AS decimal FORMAT "zzz9.99"  DECIMALS 6.
   define public  variable Amount AS decimal FORMAT "zzz9.99"  DECIMALS 6.
   define public  variable Price AS decimal FORMAT "zzz9.99"  DECIMALS 2.
   define public  variable Unit AS character FORMAT "x(6)"  .
   define public  variable Duty AS character FORMAT "x(10)"  .
   define public  variable ForPay AS decimal FORMAT "zzzzz9.99"  DECIMALS 2.
   define public  variable Pay AS decimal FORMAT "zzzzz9.99"  DECIMALS 2.
   define public  variable sortOrder AS integer FORMAT "zzzzz9"  .
   define public  variable parValue AS integer.
   define public  variable tKoef AS decimal.
   define public  variable lossesCount AS decimal.
   define public  variable prevCountDate AS date.
   define public  variable lastCountDate AS date.
   define public  variable minTariffValue AS decimal.
   define public  variable minTariffThreshold AS decimal.
   define public  variable maxTariffValue AS decimal.
   define public  variable middleTariffValue AS decimal.
   define public  variable middleTariffThreshold AS decimal.
/***************************************************************************************************/
/* Стандартные функции класса для перерменных */

/***************************************************************************************************/
/* Стандартные функции класса для работы с данными */

 method public void LoadData():
   if available b-compaydocex then do:
     IdSub = b-compaydocex.IdSub.
     Invoice = b-compaydocex.Invoice.
     docno = b-compaydocex.docno.
     Counter = b-compaydocex.Counter.
     NamSub = b-compaydocex.NamSub.
     Curr = b-compaydocex.Curr.
     Prev = b-compaydocex.Prev.
     Amount = b-compaydocex.Amount.
     Price = b-compaydocex.Price.
     Unit = b-compaydocex.Unit.
     Duty = b-compaydocex.Duty.
     ForPay = b-compaydocex.ForPay.
     Pay = b-compaydocex.Pay.
     sortOrder = b-compaydocex.sortOrder.
     parValue = b-compaydocex.parValue.
     tKoef = b-compaydocex.tKoef.
     lossesCount = b-compaydocex.lossesCount.
     prevCountDate = b-compaydocex.prevCountDate.
     lastCountDate = b-compaydocex.lastCountDate.
     minTariffValue = b-compaydocex.minTariffValue.
     minTariffThreshold = b-compaydocex.minTariffThreshold.
     maxTariffValue = b-compaydocex.maxTariffValue.
     middleTariffValue = b-compaydocex.middleTariffValue.
     middleTariffThreshold = b-compaydocex.middleTariffThreshold.
   end.
 end method.
/***************************************************************************************************/
 method public void ClearData():
     IdSub = ?.
     Invoice = ?.
     docno = ?.
     Counter = ?.
     NamSub = ?.
     Curr = ?.
     Prev = ?.
     Amount = ?.
     Price = ?.
     Unit = ?.
     Duty = ?.
     ForPay = ?.
     Pay = ?.
     sortOrder = ?.
     parValue = ?.
     tKoef = ?.
     lossesCount = ?.
     prevCountDate = ?.
     lastCountDate = ?.
     minTariffValue = ?.
     minTariffThreshold = ?.
     maxTariffValue = ?.
     middleTariffValue = ?.
     middleTariffThreshold = ?.
     LockRecord = false.
     Count = 0.
     Release b-compaydocex.
 end method.
/***************************************************************************************************/
 method public log Find-First(INPUT InPar AS character):
   return FindAll(InPar,1). /* вернуть первую запись */
 end method.
 method public log Find-Last(INPUT InPar AS character):
   return FindAll(InPar,2). /* вернуть последнюю запись */
 end method.
/***************************************************************************************************/
 method private log FindAll(INPUT InPar AS character, INPUT tp AS INT):
   qh:QUERY-CLOSE().
   qh:QUERY-PREPARE("for each b-compaydocex where " + InPar).
   qh:QUERY-OPEN.
    case tp:
     when 1 then do:  qh:GET-NEXT(). end.
     when 2 then do:  qh:GET-LAST(). end.
    end case.
    if avail b-compaydocex then do:
     if LockRecord then find current b-compaydocex exclusive-lock no-error NO-WAIT.
     else find current b-compaydocex no-lock no-error.
        if LockRecord then do:
            if not avail b-compaydocex then do:
                message "Документ занят другим пользователем, попробуйте позднее !!!" view-as alert-box.
                ClearData().
                qh:QUERY-CLOSE().
                Count = 0.
                return false.
            end.
        end.
        LoadData().
        qh:QUERY-CLOSE().
        Count = 1.
        return true.
    end.
    else do:
        ClearData().
        qh:QUERY-CLOSE().
        Count = 0.
        return false.
    end.
 end method.
/***************************************************************************************************/
  method public int Find-All(INPUT InPar AS character):
    Count = 0.
    qh:QUERY-CLOSE().
    qh:QUERY-PREPARE("for each b-compaydocex where " + InPar).
    qh:QUERY-OPEN.
    qh:GET-FIRST().
      if avail b-compaydocex then do:
         REPEAT:
           IF qh:QUERY-OFF-END THEN LEAVE.
           Count = Count + 1.
           qh:GET-NEXT().
         END.
      end.
     return  Count.
  end method.
/***************************************************************************************************/
  method public COMPAYDOCEXClass ElementBy(INPUT InPar AS int):
     Positions = 1.
     qh:GET-FIRST().
      if avail b-compaydocex then do:
        REPEAT:
         if Positions = InPar then do: LoadData(). return THIS-OBJECT. end.
         if qh:QUERY-OFF-END THEN LEAVE.
         Positions = Positions + 1.
         qh:GET-NEXT().
        END.
      end. else return ?.
   end method.
/***************************************************************************************************/
 method public void Free():
   if available b-compaydocex then find current b-compaydocex no-lock no-error.
   LockRecord = false.
 end method.
/***************************************************************************************************/
 method public log Edit():
   if available b-compaydocex then
   do:
     find current b-compaydocex exclusive-lock no-error NO-WAIT.
     if avail b-compaydocex then do:
        LockRecord = true.
        LoadData().
        return true.
     end.
     else do:
        message "Документ занят другим пользователем, попробуйте позднее !!!" view-as alert-box.
        LockRecord = false.
        return false.
     end.
   end.
   else do:
     message "Набор данных не должен быть пустым!" view-as alert-box.
     LockRecord = false.
     return false.
   end.
  end method.
/***************************************************************************************************/
 method public log AddData():
   ClearData().
   LockRecord = true.
 end method.
/***************************************************************************************************/
 method public log DelData():
   rez = false.
   if LockRecord then do:
     do transaction:
       if available b-compaydocex then do:
        find current b-compaydocex exclusive-lock no-error NO-WAIT.
        if avail b-compaydocex then do:
            delete b-compaydocex.
            ClearData().
            rez = true.
        end.
        else do:
            message "Документ занят другим пользователем, попробуйте позднее !!!" view-as alert-box.
            rez = false.
        end.
       end.
       else rez = false.
     end. /* transaction */
   end.
   else message "При изменении данные должны быть заблокированы!" view-as alert-box.
   return rez.
  end method.
/***************************************************************************************************/
 method public log Post():
   rez = false.
   if LockRecord then do:
    do transaction:
      if not available b-compaydocex then
      do:
        create b-compaydocex.
        b-compaydocex.IdSub = IdSub.
        b-compaydocex.Invoice = Invoice.
        b-compaydocex.docno = docno.
        b-compaydocex.Counter = Counter.
        b-compaydocex.NamSub = NamSub.
        b-compaydocex.Curr = Curr.
        b-compaydocex.Prev = Prev.
        b-compaydocex.Amount = Amount.
        b-compaydocex.Price = Price.
        b-compaydocex.Unit = Unit.
        b-compaydocex.Duty = Duty.
        b-compaydocex.ForPay = ForPay.
        b-compaydocex.Pay = Pay.
        b-compaydocex.sortOrder = sortOrder.
        b-compaydocex.parValue = parValue.
        b-compaydocex.tKoef = tKoef.
        b-compaydocex.lossesCount = lossesCount.
        b-compaydocex.prevCountDate = prevCountDate.
        b-compaydocex.lastCountDate = lastCountDate.
        b-compaydocex.minTariffValue = minTariffValue.
        b-compaydocex.minTariffThreshold = minTariffThreshold.
        b-compaydocex.maxTariffValue = maxTariffValue.
        b-compaydocex.middleTariffValue = middleTariffValue.
        b-compaydocex.middleTariffThreshold = middleTariffThreshold.
        rez = true.
      end.
    end. /* transaction */
   end.
   else message "При изменении данные должны быть заблокированы!" view-as alert-box.
   return rez.
 end method.
/***************************************************************************************************/
method public log ChangePar(input p-docno as inte,input p-IdSub as inte,input p-lastCountDate as date,input p-FormulType as logi):
    rez = false.
    if p-FormulType then do:
        for each b-compaydocex where b-compaydocex.docno = p-docno and b-compaydocex.IdSub = p-IdSub exclusive-lock:
            b-compaydocex.lastCountDate = p-lastCountDate.
            rez = true.
        end.
    end.
    return rez.
end method.
/***************************************************************************************************/
END CLASS. /* COMPAYDOCEXClass*/

