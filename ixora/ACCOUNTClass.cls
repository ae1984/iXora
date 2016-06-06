/* ACCOUNTClass.cls

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
        24.02.2009 k.gitalov
 * CHANGES
        14.11.2012 damir - Добавил function AddStr, variable - type_pay,code_reg. Добавление к изменению 07.11.2012.
        29.01.2013 damir - Добавил COMM для секвенции accid.
*/




CLASS ACCOUNTClass:
  DEFINE private BUFFER b-account FOR comm.account.
  DEFINE private VARIABLE LockRecord AS LOG.
  DEFINE private VARIABLE qh AS HANDLE.
  DEFINE private VARIABLE rez AS LOG.
  DEFINE private VARIABLE Positions AS INT.
  DEFINE private VARIABLE GlobalVar AS CLASS GlobalClass.
  DEFINE public  VARIABLE Count AS INT.
/***************************************************************************************************/
   define public  variable acc_id AS integer FORMAT "zzzzzzz9"  .
   define public  variable rnn AS char FORMAT "x(12)"  .
   define public  variable supp_id AS integer FORMAT "zzzzzzz9"  .
   define public  variable acc AS character FORMAT "x(21)"  .
   define public  variable phone AS character FORMAT "x(21)"  .
   define public  variable addr AS character FORMAT "x(45)"  .
   define public  variable who_cr AS character FORMAT "x(8)"  .
   define public  variable payname AS character FORMAT "x(25)"  .
   define public  variable type_pay AS character.                                    /*Код платежа*/
   define public  variable code_reg AS character.                                    /*Код региона*/

   /* Вычисляемые поля */
   define public  variable name AS character FORMAT "x(45)"  . /*Ф.И.О. плательщика*/
/***************************************************************************************************/
   CONSTRUCTOR public ACCOUNTClass( INPUT std AS CLASS GlobalClass ,input supp as int ):
       if supp = ? or supp = 0 then
       do:
        message "Не указан поставщик услуг!" view-as alert-box.
        return.
       end.
       supp_id = supp.
       GlobalVar = std.
       LockRecord = false.
       CREATE QUERY qh.
       qh:SET-BUFFERS("b-account").
       Count = 0.
   END CONSTRUCTOR.
/***************************************************************************************************/
   DESTRUCTOR  public ACCOUNTClass():
       ClearData().
       DELETE OBJECT qh.
   END DESTRUCTOR.
/***************************************************************************************************/
/* Стандартные функции класса для работы с данными */

 method public void LoadData():
   if available b-account then do:
     acc_id = b-account.acc_id.
     rnn = b-account.trn.
     supp_id = b-account.supp_id.
     acc = b-account.acc.
     phone = b-account.phone.
     addr = b-account.addr.
     who_cr = b-account.who_cr.
     payname = b-account.payname.
   end.
 end method.
/***************************************************************************************************/
 method public void ClearData():
     acc_id = ?.
     rnn = "".
     acc = "".
     phone = "".
     addr = "".
     who_cr = ?.
     payname = "".
     LockRecord = false.
     Count = 0.
     Release b-account.
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
   qh:QUERY-PREPARE("for each b-account where " + InPar).
   qh:QUERY-OPEN.
    case tp:
     when 1 then do:  qh:GET-NEXT(). end.
     when 2 then do:  qh:GET-LAST(). end.
    end case.
    if avail b-account then do:
     if LockRecord then find current b-account exclusive-lock no-error.
     else find current b-account no-lock no-error.
        LoadData().
        qh:QUERY-CLOSE().
        Count = 1.
        return true.    end.
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
    qh:QUERY-PREPARE("for each b-account where " + InPar).
    qh:QUERY-OPEN.
    qh:GET-FIRST().
      if avail b-account then do:
         REPEAT:
           IF qh:QUERY-OFF-END THEN LEAVE.
           Count = Count + 1.
           qh:GET-NEXT().
         END.
      end.
     return  Count.
  end method.
/***************************************************************************************************/
  method public ACCOUNTClass ElementBy(INPUT InPar AS int):
     Positions = 1.
     qh:GET-FIRST().
      if avail b-account then do:
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
   if available b-account then find current b-account no-lock no-error.
   LockRecord = false.
 end method.
/***************************************************************************************************/
 method public log Edit():
   if available b-account then
   do:
     find current b-account exclusive-lock no-error.
     LockRecord = true.
     LoadData().
     return true.
   end.
   else do:
     message "Набор данных не должен быть пустым!" view-as alert-box.
     LockRecord = false.
     return false.
   end.
  end method.
/***************************************************************************************************/
 method public log AddData():
  /* ClearData().*/
   Count = 0.
   Release b-account.
   LockRecord = true.
 end method.
/***************************************************************************************************/
 method public log DelData():
   rez = false.
   if LockRecord then do:
     do transaction:
       if available b-account then do:
        find current b-account exclusive-lock no-error.
        delete b-account.
        ClearData().
        rez = true.
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
      if not available b-account then
      do:
        if rnn = ? or rnn = "" or supp_id = ? or supp_id = 0 then do: rez = false. leave. end.
        create b-account.
        acc_id = next-value(accid,comm).
        b-account.acc_id  = acc_id.
        b-account.trn     = rnn.
        b-account.supp_id = supp_id.
        b-account.acc     = acc.
        b-account.phone   = phone.
        b-account.addr    = addr.
        b-account.payname = payname.
        b-account.who_cr  = GlobalVar:g-ofc.
        rez = true.
      end.
      else do:
        if b-account.trn <> trn then b-account.trn = rnn.
        if b-account.payname <> payname then b-account.payname = payname.
        if b-account.supp_id <> supp_id then b-account.supp_id = supp_id.
        if b-account.acc <> acc then b-account.acc = acc.
        if b-account.phone <> phone then b-account.phone = phone.
        if b-account.addr <> addr then b-account.addr = addr.
        if b-account.who_cr <> GlobalVar:g-ofc then b-account.who_cr = GlobalVar:g-ofc.
        rez = true.
      end.
    end. /* transaction */
   end.
   else message "При изменении данные должны быть заблокированы!" view-as alert-box.
   return rez.
 end method.
/***************************************************************************************************/
/* Поиск плательщика в rnn по номеру лицевого счета */
 method public log FindAcc(INPUT InPar AS character):
   if find-first("acc = '" + InPar + "' and supp_id = " + string(supp_id)) then
   do:
    /* Нашли такой номер счета в сохраненных данных*/
    if rnn = "000000000000" then
    do: /*база рнн не используется */
       name = payname.
       return true.
    end.
    else do:
       /* используется наша база рнн*/
       find first comm.rnn where comm.rnn.trn = rnn.
       if avail comm.rnn then
       do:
        name   = trim(comm.rnn.lname) + " " + trim(comm.rnn.fname) + " " + trim(comm.rnn.mname).
        return true.
       end.
       else do:
       message "Ошибка в базе! Нет записи в RNN!" view-as alert-box.
        return false.
       end.
    end.
   end.
   else return false.
 end method.
/***************************************************************************************************/
/* Поиск плательщика в rnn по номеру лицевого счета */
 method public log FindUser(INPUT InPar AS character , INPUT ParName AS character , INPUT ParAddr AS character):
   if find-first("acc = '" + InPar + "' and payname = '" + ParName + "' and addr = '" + ParAddr + "' and supp_id = " + string(supp_id)) then
   do:
    /* Нашли такой номер счета в сохраненных данных*/
      name = payname.
      return true.
   end.
   else return false.
 end method.
/***************************************************************************************************/
method public log AddStr(input p-add as char):
    if p-add ne '' then acc = p-add + ";" + acc.
    return true.
end method.
/***************************************************************************************************/

END CLASS. /* ACCOUNTClass*/

