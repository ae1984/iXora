/* VIPRATEClass.cls

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
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".

*/




CLASS VIPRATEClass:
  DEFINE private BUFFER b-viprate FOR viprate.
  DEFINE private VARIABLE LockRecord AS LOG.
  DEFINE private VARIABLE qh AS HANDLE.
  DEFINE private VARIABLE rez AS LOG.
  DEFINE private VARIABLE Positions AS INT.
  DEFINE private VARIABLE GlobalVar AS CLASS GlobalClass.
  DEFINE public  VARIABLE Count AS INT.
/***************************************************************************************************/
   CONSTRUCTOR public VIPRATEClass():
       GlobalVar = ?.
       LockRecord = false.
       CREATE QUERY qh.
       qh:SET-BUFFERS("b-viprate").
       Count = 0.
   END CONSTRUCTOR.
/***************************************************************************************************/
   CONSTRUCTOR public VIPRATEClass( INPUT std AS CLASS GlobalClass ):
       GlobalVar = std.
       LockRecord = false.
       CREATE QUERY qh.
       qh:SET-BUFFERS("b-viprate").
       Count = 0.
   END CONSTRUCTOR.
/***************************************************************************************************/
   DESTRUCTOR  public VIPRATEClass():
       ClearData().
       DELETE OBJECT qh.
   END DESTRUCTOR.
/***************************************************************************************************/
   define public  variable rate AS decimal FORMAT "zzz,zzz.9999"  DECIMALS 2.          /* Курс */
   define public  variable cif AS character FORMAT "x(6)"  .                           /* Клиент */
   define public  variable summ AS decimal FORMAT "z,zzz,zzz,zzz,zz9.99-"  DECIMALS 2. /* Сумма на которую предоставляется курс*/
   define public  variable valid_to AS date FORMAT "99/99/99"  .                       /* Дата по которую действует курс*/
   define public  variable dt_cr AS date FORMAT "99/99/99"  .                          /* Дата создания курса*/
   define public  variable tm_cr AS integer FORMAT "zzzzz9"  .                         /* Время создания курса*/
   define public  variable who_cr AS character FORMAT "x(8)"  .                        /* Кто создал запись*/
   define public  variable del AS logical FORMAT "да/нет"  .                           /* Статус курса*/
   define public  variable oper AS character.                                          /* Операция */
   define public  variable idrate AS integer FORMAT "zzzzz9"  .                        /* ID курса*/
/***************************************************************************************************/
/* Стандартные функции класса для работы с данными */

 method public void LoadData():
   if available b-viprate then do:
     rate = b-viprate.rate.
     cif = b-viprate.cif.
     summ = b-viprate.summ.
     valid_to = b-viprate.valid_to.
     dt_cr = b-viprate.dt_cr.
     tm_cr = b-viprate.tm_cr.
     who_cr = b-viprate.who_cr.
     del = b-viprate.del.
     oper = b-viprate.oper.
     idrate = b-viprate.idrate.
   end.
 end method.
/***************************************************************************************************/
 method public void ClearData():
     rate = ?.
     cif = ?.
     summ = ?.
     valid_to = ?.
     dt_cr = ?.
     tm_cr = ?.
     who_cr = ?.
     del = ?.
     oper = ?.
     idrate = ?.
     LockRecord = false.
     Count = 0.
     Release b-viprate.
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
   qh:QUERY-PREPARE("for each b-viprate where " + InPar).
   qh:QUERY-OPEN.
    case tp:
     when 1 then do:  qh:GET-NEXT(). end.
     when 2 then do:  qh:GET-LAST(). end.
    end case.
    if avail b-viprate then do:
     if LockRecord then find current b-viprate exclusive-lock no-error.
     else find current b-viprate no-lock no-error.
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
    qh:QUERY-PREPARE("for each b-viprate where " + InPar).
    qh:QUERY-OPEN.
    qh:GET-FIRST().
      if avail b-viprate then do:
         REPEAT:
           IF qh:QUERY-OFF-END THEN LEAVE.
           Count = Count + 1.
           qh:GET-NEXT().
         END.
      end.
     return  Count.
  end method.
/***************************************************************************************************/
  method public VIPRATEClass ElementBy(INPUT InPar AS int):
     Positions = 1.
     qh:GET-FIRST().
      if avail b-viprate then do:
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
   if available b-viprate then find current b-viprate no-lock no-error.
   LockRecord = false.
 end method.
/***************************************************************************************************/
 method public log Edit():
   if available b-viprate then
   do:
     find current b-viprate exclusive-lock no-error.
     LockRecord = true.
     LoadData().
     who_cr = GlobalVar:g-ofc.
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
   ClearData().
   LockRecord = true.

   del = no. /* по умолчанию тариф активный */
   valid_to = GlobalVar:g-today.
   who_cr = GlobalVar:g-ofc.

 end method.
/***************************************************************************************************/
 method public log DelData():
   rez = false.
   if LockRecord then do:
     do transaction:
       if available b-viprate then do:
        find current b-viprate exclusive-lock no-error.
       /* delete b-viprate.*/
        b-viprate.del = yes.
        b-viprate.who_cr = GlobalVar:g-ofc.
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
      if not available b-viprate then do:
       create b-viprate.
       b-viprate.dt_cr = GlobalVar:g-today.
       b-viprate.tm_cr = time.
       b-viprate.cif = cif.
       b-viprate.del = no.
       b-viprate.idrate = next-value(id_viprate).
      end.

       if b-viprate.rate <> rate then b-viprate.rate = rate.
       if b-viprate.summ <> summ then b-viprate.summ = summ.
       if b-viprate.valid_to <> valid_to then b-viprate.valid_to = valid_to.
       if b-viprate.who_cr <> who_cr then b-viprate.who_cr = who_cr.
       if b-viprate.oper <> oper then b-viprate.oper = oper.
      /* if b-viprate.del <> del then b-viprate.del = del.*/
      rez = true.
    end. /* transaction */
   end.
   else message "При изменении данные должны быть заблокированы!" view-as alert-box.
   return rez.
 end method.
/***************************************************************************************************/

/***************************************************************************************************/

END CLASS. /* VIPRATEClass*/

