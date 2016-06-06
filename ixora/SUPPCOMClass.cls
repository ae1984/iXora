/* SUPPCOMClass.cls

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
        11.11.2009 k.gitalov supcod изменеен на decimal
 * CHANGES
        14.11.2012 damir - добавил variable - typepay,codereg. Добавление к изменению 07.11.2012.

*/




CLASS SUPPCOMClass:
  DEFINE private BUFFER b-suppcom FOR comm.suppcom.
  DEFINE private VARIABLE LockRecord AS LOG.
  DEFINE private VARIABLE qh AS HANDLE.
  DEFINE private VARIABLE rez AS LOG.
  DEFINE private VARIABLE Positions AS INT.
  DEFINE private VARIABLE GlobalVar AS CLASS GlobalClass.
  DEFINE public  VARIABLE Count AS INT.
/***************************************************************************************************/
   CONSTRUCTOR public SUPPCOMClass():
       GlobalVar = ?.
       LockRecord = false.
       CREATE QUERY qh.
       qh:SET-BUFFERS("b-suppcom").
       Count = 0.
   END CONSTRUCTOR.
/***************************************************************************************************/
   DESTRUCTOR  public SUPPCOMClass():
       ClearData().
       DELETE OBJECT qh.
   END DESTRUCTOR.
/***************************************************************************************************/
   define public  variable supp_id AS integer FORMAT "zzzzz9"  .
   define public  variable txb AS character FORMAT "x(6)"  .
   define public  variable name AS character FORMAT "x(30)"  .
   define public  variable bname AS character FORMAT "x(30)"  .
   define public  variable iik AS character FORMAT "x(21)"  .
   define public  variable bik AS character FORMAT "x(21)"  .
   define public  variable rnn AS character FORMAT "x(12)"  .
   define public  variable nds-cer AS character FORMAT "x(6)"  .
   define public  variable nds-no AS character FORMAT "x(12)"  .
   define public  variable nds-date AS date FORMAT "99/99/99"  .
   define public  variable knp AS character FORMAT "x(3)"  .
   define public  variable paycod AS character FORMAT "x(3)"  .
   define public  variable supcod AS decimal  FORMAT "->>,>>9.99"  .
   define public  variable cod AS integer FORMAT "zzzzz9"  . /* не используется */
   define public  variable arp AS character FORMAT "x(21)"  .
   define public  variable type AS integer FORMAT "zzzzz9"  .
   define public  variable ap_code AS integer FORMAT "->,>>>,>>9"  .
   define public  variable ap_type AS integer FORMAT "->,>>>,>>9"  .
   define public  variable ap_tc AS character FORMAT "x(12)"  .
   define public  variable minsum AS decimal FORMAT "->>,>>9.99"  DECIMALS 2.
   define public  variable minlen AS integer FORMAT "->,>>>,>>9"  .
   define public  variable maxlen AS integer FORMAT "->,>>>,>>9"  .
   define public  variable ap_check AS integer FORMAT "->,>>>,>>9"  .
   define public  variable typepay AS character  .
   define public  variable codereg AS character  .
/***************************************************************************************************/
   CONSTRUCTOR public SUPPCOMClass( INPUT std AS CLASS GlobalClass ):
       GlobalVar = std.
       LockRecord = false.
       CREATE QUERY qh.
       qh:SET-BUFFERS("b-suppcom").
       Count = 0.

       txb     = GlobalVar:b-txb.
       supp_id = ?.
   END CONSTRUCTOR.
/***************************************************************************************************/
/* Стандартные функции класса для перерменных */

/***************************************************************************************************/
/* Стандартные функции класса для работы с данными */

 method public void LoadData():
   if available b-suppcom then do:
     supp_id = b-suppcom.supp_id.
     txb = b-suppcom.txb.
     name = b-suppcom.name.
     bname = b-suppcom.bname.
     iik = b-suppcom.iik.
     bik = b-suppcom.bik.
     rnn = b-suppcom.rnn.
     nds-cer = b-suppcom.nds-cer.
     nds-no = b-suppcom.nds-no.
     nds-date = b-suppcom.nds-date.
     knp = b-suppcom.knp.
     paycod = b-suppcom.paycod.
     supcod = b-suppcom.supcod.
     cod = b-suppcom.cod.
     arp = b-suppcom.arp.
     type = b-suppcom.type.
     ap_code = b-suppcom.ap_code.
     ap_type = b-suppcom.ap_type.
     ap_tc = b-suppcom.ap_tc.
     minsum = b-suppcom.minsum.
     minlen = b-suppcom.minlen.
     maxlen = b-suppcom.maxlen.
     ap_check = b-suppcom.ap_check.
     typepay = b-suppcom.typepay.
     codereg = b-suppcom.codereg.
   end.
 end method.
/***************************************************************************************************/
 method public void ClearData():
     supp_id = ?.
     txb = ?.
     name = ?.
     bname = ?.
     iik = ?.
     bik = ?.
     rnn = ?.
     nds-cer = ?.
     nds-no = ?.
     nds-date = ?.
     knp = ?.
     paycod = ?.
     supcod = ?.
     cod = ?.
     arp = ?.
     type = ?.
     ap_code = 0.
     ap_type = 0.
     ap_tc = "".
     minsum = 0.
     minlen = 0.
     maxlen = 0.
     ap_check = 0.
     typepay = "".
     codereg = "".
     LockRecord = false.
     Count = 0.
     Release b-suppcom.
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
   qh:QUERY-PREPARE("for each b-suppcom where " + InPar).
   qh:QUERY-OPEN.
    case tp:
     when 1 then do:  qh:GET-NEXT(). end.
     when 2 then do:  qh:GET-LAST(). end.
    end case.
    if avail b-suppcom then do:
     if LockRecord then find current b-suppcom exclusive-lock no-error.
     else find current b-suppcom no-lock no-error.
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
    qh:QUERY-PREPARE("for each b-suppcom where " + InPar).
    qh:QUERY-OPEN.
    qh:GET-FIRST().
      if avail b-suppcom then do:
         REPEAT:
           IF qh:QUERY-OFF-END THEN LEAVE.
           Count = Count + 1.
           qh:GET-NEXT().
         END.
      end.
     return  Count.
  end method.
/***************************************************************************************************/
  method public SUPPCOMClass ElementBy(INPUT InPar AS int):
     Positions = 1.
     qh:GET-FIRST().
      if avail b-suppcom then do:
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
   if available b-suppcom then find current b-suppcom no-lock no-error.
   LockRecord = false.
 end method.
/***************************************************************************************************/
 method public log Edit():
   if available b-suppcom then
   do:
     find current b-suppcom exclusive-lock no-error.
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
   ClearData().
   LockRecord = true.
 end method.
/***************************************************************************************************/
 method public log DelData():
   rez = false.
   if LockRecord then do:
     do transaction:
       if available b-suppcom then do:
        find current b-suppcom exclusive-lock no-error.
        delete b-suppcom.
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
      if not available b-suppcom then
      do:
       create b-suppcom.
       b-suppcom.supp_id = next-value(suppid).

      end.
      /* if b-suppcom.supp_id <> supp_id then b-suppcom.supp_id = supp_id.*/
       if b-suppcom.txb <> txb then b-suppcom.txb = txb.
       if b-suppcom.name <> name then b-suppcom.name = name.
       if b-suppcom.bname <> bname then b-suppcom.bname = bname.
       if b-suppcom.iik <> iik then b-suppcom.iik = iik.
       if b-suppcom.bik <> bik then b-suppcom.bik = bik.
       if b-suppcom.rnn <> rnn then b-suppcom.rnn = rnn.
       if b-suppcom.nds-cer <> nds-cer then b-suppcom.nds-cer = nds-cer.
       if b-suppcom.nds-no <> nds-no then b-suppcom.nds-no = nds-no.
       if b-suppcom.nds-date <> nds-date then b-suppcom.nds-date = nds-date.
       if b-suppcom.knp <> knp then b-suppcom.knp = knp.
       if b-suppcom.paycod <> paycod then b-suppcom.paycod = paycod.
       if b-suppcom.supcod <> supcod then b-suppcom.supcod = supcod.
       if b-suppcom.cod <> cod then b-suppcom.cod = cod.
       if b-suppcom.arp <> arp then b-suppcom.arp = arp.
       if b-suppcom.type <> type then b-suppcom.type = type.
       if b-suppcom.ap_code <> ap_code then b-suppcom.ap_code = ap_code.
       if b-suppcom.ap_type <> ap_type then b-suppcom.ap_type = ap_type.
       if b-suppcom.ap_tc <> ap_tc then b-suppcom.ap_tc = ap_tc.
       if b-suppcom.minsum <> minsum then b-suppcom.minsum = minsum.
       if b-suppcom.minlen <> minlen then b-suppcom.minlen = minlen.
       if b-suppcom.maxlen <> maxlen then b-suppcom.maxlen = maxlen.
       if b-suppcom.ap_check <> ap_check then b-suppcom.ap_check = ap_check.
      rez = true.
    end. /* transaction */
   end.
   else message "При изменении данные должны быть заблокированы!" view-as alert-box.
   return rez.
 end method.
/***************************************************************************************************/

/***************************************************************************************************/

END CLASS. /* SUPPCOMClass*/

