/* ConvDocClass.cls (шаблон DEALING_DOCClass.cls)

 * MODULE

 * DESCRIPTION

 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список расширенных функций класса

 * MENU
        Перечень пунктов Меню Прагмы
 * BASES
        BANK
 * AUTHOR
        24.02.2009 k.gitalov
        22.12.2010 k.gitalov для кредитного департамента - без комиссии
 * CHANGES
        30.05.2012 damir - добавил FindDocJH.
        21.05.2012 evseev - добавил поле purpose цель покупки/продажи
*/




CLASS ConvDocClass:
  DEFINE private BUFFER b-dealing_doc FOR dealing_doc.
  DEFINE private VARIABLE LockRecord AS LOG.
  DEFINE private VARIABLE qh AS HANDLE.
  DEFINE private VARIABLE rez AS LOG.
  DEFINE private VARIABLE Positions AS INT.
  DEFINE private VARIABLE GlobalVar AS CLASS GlobalClass.
  DEFINE public  VARIABLE Count AS INT.

  def public   var Client AS CLASS ClientClass.      /* Данные по клиенту            */
  def public   var Tarif  AS CLASS TariffsClass.     /* Данные по тарифам клиента    */
  def public   var CRCC   AS CLASS CurrencyClass.    /* Функции по работе с валютами */
  def public   var ACC    AS CLASS TransAccClass.    /* Транзитные и АРП счета       */

 /******************************************************************************************************/
  def public var  cur_rate     as decimal format "zzz,zzz.9999".                              /* Курс валюты на момент расчета  */
  def private var cur_time     as integer no-undo.                                            /* Текущее время при сохранении документа */
 /******************************************************************************************************/
   define public  variable DocNo AS character FORMAT "x(8)"  .                                /* Номер документа */
   define public  variable DocType AS integer FORMAT "->,>>>,>>9"  .                          /* Тип документа */
   define public  variable jh AS integer FORMAT "zzzzzzz9"  .                                 /* Номер 1 первой проводки */
   define public  variable jh2 AS integer FORMAT "zzzzzzz9"  .                                /* Номер 2 проводки при обычной конвертации */
   define public  variable who_cr AS character FORMAT "x(8)"  .                               /* Создатель документа */
   define public  variable whn_cr AS date FORMAT "99/99/99"  .                                /* Дата создания документа */
   define public  variable who_mod AS character FORMAT "x(8)"  .                              /* Кто изменил документ */
   define public  variable whn_mod AS date FORMAT "99/99/99"  .                               /* Дата изменения документа */
   define public  variable time_cr AS integer FORMAT "zzzzz9"  .                              /* Время создания документа */
   define public  variable time_mod AS integer FORMAT "zzzzz9"  .                             /* Время изменения документа */

   define public  variable crc AS integer FORMAT ">9"  .                                      /* Валюта в которую конвертируем     */
   define public  variable input_crc AS integer FORMAT ">9"  .                                /* Валюта в которой вводилась сумма на конвертацию */

   define public  variable v_amount AS decimal FORMAT "z,zzz,zzz,zzz,zz9.99-"  DECIMALS 2.    /* Cумма в валюте */
   define public  variable t_amount AS decimal FORMAT "z,zzz,zzz,zzz,zz9.99-"  DECIMALS 2.    /* Cумма в тенге */

   define public  variable tclientaccno AS character FORMAT "x(21)"  .                        /* Cчет клиента в тенге */
   define public  variable vclientaccno AS character FORMAT "x(21)"  .                        /* Cчет клиента в валюте */
   define public  variable com_accno AS character FORMAT "x(21)"  .                           /* Счет для снятия комиссии */

   define public  variable rate AS decimal FORMAT "zzz,zzz.9999"  DECIMALS 4.                 /* Курс */
   define public  variable rate2 AS decimal FORMAT "zzz,zzz.9999"  DECIMALS 4.                /* Курс на момент зачисления при 2 проводке */

  /* define public  variable TngToVal AS logical FORMAT "true/false". */                          /* true - была введена сумма в тенге false - в валюте */

   define public  variable f_amount AS decimal FORMAT "z,zzz,zzz,zzz,zz9.99-"  DECIMALS 2.    /* Первоначально введенная сумма в валюте input_crc */
   define public  variable com_conv AS decimal FORMAT "->>,>>9.99"  DECIMALS 2.               /* комиссия за конвертацию */
   define public  variable conv_int AS decimal FORMAT "->>,>>9.99"  DECIMALS 2.               /* Процент комиссии за конвертацию */
   define public  variable conv_int_min AS decimal FORMAT "->>,>>9.99"  DECIMALS 2.           /* Минимальная сумма за конвертацию  */
   define public  variable conv_int_max AS decimal FORMAT "->>,>>9.99"  DECIMALS 2.           /* Максимальная сумма за конвертацию */
   define public  variable acc_com AS character FORMAT "x(8)"  .                              /* Номер счета для зачисления комиссии (из тарификатора) */

   define public  variable sts AS integer FORMAT "9".                                         /* Не используется */
   define public  variable com_expr AS decimal FORMAT "->>,>>9.99"  DECIMALS 2.               /* Не используется */
   define public  variable com_bourse AS decimal FORMAT "->>,>>9.99"  DECIMALS 2.             /* Не используется */
   define public  variable t_amt_coms AS decimal FORMAT "z,zzz,zzz,zzz,zz9.99-"  DECIMALS 2.  /* Не используется */

   define public variable id_viprate AS int init 0.                                           /* ID vip курса валюты для клиента если он установлен*/
   define public variable summ_vip AS decimal FORMAT "z,zzz,zzz,zzz,zz9.99-" init 0.          /* Сумма на которую установлен vip курс валюты */
   define public variable Mess as char.
   define public variable purpose as char.                                                    /* цель покупки/продажи */
/***************************************************************************************************/
/***************************************************************************************************/
   CONSTRUCTOR public ConvDocClass( INPUT dType As int , INPUT std AS CLASS GlobalClass ):
       ClearData().
       GlobalVar = std.
       DocType = dType.
       LockRecord = false.
       CREATE QUERY qh.
       qh:SET-BUFFERS("b-dealing_doc").
       Count = 0.
       if NOT VALID-OBJECT(ACC)    then ACC    = NEW TransAccClass().
       if NOT VALID-OBJECT(CRCC)   then CRCC   = NEW CurrencyClass(std).
       if NOT VALID-OBJECT(Client) then Client = NEW ClientClass().
       if NOT VALID-OBJECT(Tarif)  then Tarif  = NEW TariffsClass( THIS-OBJECT ).
   END CONSTRUCTOR.
/***************************************************************************************************/
   DESTRUCTOR  public ConvDocClass():
       ClearData().
       DELETE OBJECT qh.
       if VALID-OBJECT ( ACC )     then DELETE OBJECT ACC    NO-ERROR .
       if VALID-OBJECT ( CRCC )    then DELETE OBJECT CRCC   NO-ERROR .
       if VALID-OBJECT ( Client )  then DELETE OBJECT Client NO-ERROR .
       if VALID-OBJECT ( Tarif )   then DELETE OBJECT Tarif  NO-ERROR .
   END DESTRUCTOR.
/***************************************************************************************************/
/* Полный расчет и сохранение документа */
 method public log CalcDoc():

          if jh = 0 or jh = ? then
          do:
              Edit().
              if FindTarif() = false then return false.
              if FindRate()  = false then return false.
              if CheckDoc()  = false then return false.
              if SaveDoc() = false then return false.
              /* Все ОК*/
              return true.
          end.
          else do:
           if DocType = 2 or DocType = 4 then
           do:
            if  jh2 = 0 or jh2 = ?  then
            do:
                Edit().
                if FindTarif() = false then return false.
                if FindRate()  = false then return false.
                if CheckDoc2() = false then return false.
                if SaveDoc2() = false then return false.
                /* Все ОК*/
                return true.
            end.
           end.
          end.

     return true.
 end method.
 /********************************************************************************************************/

 /* Поиск документа по номеру */
 method public log FindDoc(input DN as char):
 /*при нахождении документа с номером DN инициализирует объект, возвращает true. иначе false*/
   find  b-dealing_doc where b-dealing_doc.docno = DN and b-dealing_doc.doctype = DocType no-lock no-error.
   if available (b-dealing_doc) then
   do:
       if b-dealing_doc.who_mod <> GlobalVar:g-ofc and b-dealing_doc.who_cr <> "inbank" then
       do:
          message "Вы не можете просматривать документы принадлежащие" skip b-dealing_doc.who_mod view-as alert-box.
          return false.
       end.

       LoadData().
       if not Client:FindClient(tclientaccno) then return false.

       return true.

   /*  Сказали что не надо учитывать кто контролирующий офицер o_0
       if  Client:ofc = GlobalVar:g-ofc then
       do:

        return true.
       end.
       else do:
          message "Контролирующий офицер для клиента " Client:ofc  view-as alert-box.
          return false.
       end.
     */

   end.
   else do:
      message "Документ с номером" DN "не найден !" view-as alert-box.
      return false.
   end.

 end method.

 /********************************************************************************************************/
 /* Поиск клиента по номеру счета + проверка правильности валюты счета в зависимости от типа документа*/
  method public log FindClient(INPUT AccNo as char):

    if Client:FindClient(AccNo) then
    do:
       if DocType = 0 then do: message "Не определен тип документа!" view-as alert-box. return false. end.
       CASE DocType:
          WHEN 1 THEN DO: if CRCC:get-crc(AccNo)  = 1 then return true. else message "Введите счет в тенге!"  view-as alert-box. return false. END.
          WHEN 2 THEN DO: if CRCC:get-crc(AccNo)  = 1 then return true. else message "Введите счет в тенге!"  view-as alert-box. return false. END.
          WHEN 3 THEN DO: if CRCC:get-crc(AccNo) <> 1 then return true. else message "Введите счет в валюте!" view-as alert-box. return false. END.
          WHEN 4 THEN DO: if CRCC:get-crc(AccNo) <> 1 then return true. else message "Введите счет в валюте!" view-as alert-box. return false. END.
          WHEN 6 THEN DO: if CRCC:get-crc(AccNo) <> 1 then return true. else message "Введите счет в валюте!" view-as alert-box. return false. END.
       END CASE.
    end.
    else do:
     message "Не найден владелец счета !" AccNo  view-as alert-box.
     return false.
    end.

 end method.
 /********************************************************************************************************/
 /*Поиск тарифов по ID Клиента*/
 method public log FindTarif():

        if Tarif:FindTarif() = false then return false.
        acc_com      = Tarif:comacc.
        conv_int     = Tarif:conv_int.
        conv_int_min = Tarif:conv_int_min.
        conv_int_max = Tarif:conv_int_max.
        com_conv     = conv_int_min.

        if acc_com  =  "" then
        do:
          message "Не найден счет для зачисления комиссии в тарификаторе!" view-as alert-box.
          return false.
        end.

        return true.

 end method.

 /********************************************************************************************************/
 /*Поиск курса валюты по ID Клиента и ID валюты*/
  method public log FindRate():

        if DocType = 1 or DocType = 2 then
        do:
          cur_rate = CRCC:get-vip-sale-rate(Client:clientno,crc,id_viprate).
          if DocType = 1 and cur_rate = -1 then cur_rate  = CRCC:get-exp-sale-rate(crc).
          if DocType = 2 and cur_rate = -1 then cur_rate  = CRCC:get-std-sale-rate(crc).
        end.

        if DocType = 3 or DocType = 4 then
        do:
          cur_rate = CRCC:get-vip-purch-rate(Client:clientno,crc,id_viprate).
          if DocType = 3 and cur_rate = -1 then cur_rate  = CRCC:get-exp-purch-rate(crc).
          if DocType = 4 and cur_rate = -1 then cur_rate  = CRCC:get-std-purch-rate(crc).
        end.

        if DocType = 6 then
        do:
          cur_rate  = CRCC:get-vip-cross-rate(Client:clientno,CRCC:get-crc(tclientaccno),crc,id_viprate).
          if cur_rate = -1 then cur_rate  = CRCC:get-cross-rate(CRCC:get-crc(tclientaccno),crc).
        end.

        /************************************************************************************************/
        /*Если установлен льготный курс - берем максимальную сумму*/
        if id_viprate <> 0 then
        do:
         find first viprate where viprate.idrate = id_viprate no-lock no-error.
         if avail viprate then
         do:
            summ_vip = viprate.summ.
         end.
        end.
        /************************************************************************************************/
        if cur_rate <> -1 then return true.
        else return false.
  end method.

 /********************************************************************************************************/
 /* Полный расчет документа ( начальный, для всех типов документов )*/
 method public log CheckDoc():

        if jh <> 0 and jh <> ? then
        do:
          message "Данный документ уже имеет транзакцию!" view-as alert-box.
          return false.
        end.
        else rate = cur_rate.

        if f_amount = 0 then
        do:
          message "Первоначально введенная сумма не может быть равна нулю!" view-as alert-box.
          return false.
        end.


        /* Определение сумм в тенге и валюте в зависимости от валюты ввода суммы на конвертацию */
        if DocType = 6 then
        do:  /* Для кросс конвертации другой принцип!!! */
           if crc = input_crc then do: v_amount = f_amount.  t_amount = f_amount / rate. /* TngToVal = false.*/ end.
           else do: t_amount = f_amount. v_amount = f_amount * rate. /* TngToVal = true.*/ end.
        end.
        else do:
           if crc = input_crc then do: v_amount = f_amount.  t_amount = f_amount * rate. /* TngToVal = false.*/ end.
           else do: t_amount = f_amount. v_amount = f_amount / rate. /* TngToVal = true.*/ end.
        end.



        if t_amount = 0 or v_amount = 0 then
        do:
         message "Сумма в тенге или валюте не может быть нулевой!" view-as alert-box.
         return false.
        end.

        if id_viprate <> 0 then
        do:
          Mess = "Для клиента установлен льготный курс!".
          if v_amount > summ_vip then
          do:
            Mess =  "Превышена максимальная сумма конвертации по льготному курсу!".
            return false.
          end.
        end.


        /*Для кредитного администрирования без комиссии*/
        if GlobalVar:g-fname = "DILDKA1" or GlobalVar:g-fname = "DILDKA3" then
        do:
          conv_int     = 0.
          conv_int_min = 0.
          conv_int_max = 0.
          com_conv     = 0.
        end.
        else do:
          /* Определение суммы комиссии. При покупке валюты и кросс конвертации сумма комиссии расчитывается
           по сумме конечной валюты, при продаже валюты сумма комиссии расчитывается на сумму продаваемой валюты */
          com_conv = CRCC:crc-crc(CRCC:GetPercent(conv_int,v_amount), CRCC:get-crc(vclientaccno) , CRCC:get-crc(com_accno) ).
          com_conv = round(com_conv,2).

          /* Проверка на минимальную и максимальную сумму комиссии */
          if com_conv < conv_int_min then com_conv = conv_int_min.
          if conv_int_max > 0 then do:
            if com_conv > conv_int_max then com_conv = conv_int_max.
          end.
        end.

       /* Проверка на достаточность средств на счетах клиента */
       if DocType = 1 or DocType = 2 or DocType = 6 then
       do:
         /* Если счет снятия средств совпадает со счетом снятия комиссии */
         if com_accno = tclientaccno then if Client:check-sum(tclientaccno, com_conv + t_amount) = false then return false.
         /* Счета для снятия средств и комиссии разные */
         if Client:check-sum(tclientaccno,t_amount) = false then return false.
         /* Если счет для снятия комиссии совпадает со счетом для зачисления и валюта документа равна валюте ввода суммы */
         if com_accno = vclientaccno and crc = input_crc then if Client:check-sum(vclientaccno,com_conv) = false then return false.
         /* Комиссия снимается со счета не участвующего в конвертации */
         if Client:check-sum(com_accno,com_conv) = false then return false.

       end.

       if DocType = 3 or DocType = 4 then
       do:
         /* Если счет снятия средств совпадает со счетом снятия комиссии */
         if com_accno = vclientaccno then if Client:check-sum(vclientaccno, com_conv + v_amount) = false then return false.
         /* Счета для снятия средств и комиссии разные */
         if Client:check-sum(vclientaccno,v_amount) = false then return false.
         /* Если счет для снятия комиссии совпадает со счетом для зачисления и валюта ввода суммы - тенге*/
         if com_accno = tclientaccno and input_crc = 1 then if Client:check-sum(tclientaccno,com_conv) = false then return false.
         /* Комиссия снимается со счета не участвующего в конвертации */
         if Client:check-sum(com_accno,com_conv) = false then return false.

       end.
       /********************************************************************************************************/
    return true.
 end method.

 /***************************************************************************************************************/
  /* Полный расчет документа ( конечный, только для обычной конвертации )*/
 method public log CheckDoc2():
        if DocType = 1 or DocType = 3 or DocType = 6 then
        do:
          message "функция CheckDoc2 не может вызываться для документов с типом 1,3,6 !" view-as alert-box.
          return false.
        end.

        if jh2 <> 0 and jh2 <> ? then
        do:
          message "Данный документ уже имеет 2-ю транзакцию!" view-as alert-box.
          return false.
        end.
        else rate2 = rate. /* cur_rate. Вторая транзакция берется по курсу снятия */

        /* Определение сумм в тенге и валюте в зависимости от валюты ввода суммы на конвертацию */
        if crc = input_crc then do: v_amount = f_amount.  t_amount = f_amount * rate2. end.
        else do: t_amount = f_amount. v_amount  = f_amount / rate2. end.

        if t_amount = 0 or v_amount = 0 then return false.

        /* Определение суммы комиссии. При покупке валюты и кросс конвертации сумма комиссии расчитывается
           по сумме конечной валюты, при продаже валюты сумма комиссии расчитывается на сумму продаваемой валюты */

        com_conv = CRCC:crc-crc(CRCC:GetPercent(conv_int,v_amount), CRCC:get-crc(vclientaccno) , CRCC:get-crc(com_accno) ).
        com_conv = round(com_conv,2).

        /* Проверка на минимальную и максимальную сумму комиссии */
        if com_conv < conv_int_min then com_conv = conv_int_min.
        if conv_int_max > 0 then do:
          if com_conv > conv_int_max then com_conv = conv_int_max.
        end.


        return true.
 end method.
 /***************************************************************************************************************/
 /* Сохранение нового документа */
 method public log NewDoc():
    rez = false.
    do transaction:

        cur_time = time.
        DocNo    = string(next-value(d_journal),"999999").

        create b-dealing_doc.
        b-dealing_doc.DocNo        = DocNo.
        b-dealing_doc.whn_cr       = GlobalVar:g-today.
        b-dealing_doc.who_cr       = GlobalVar:g-ofc.
        b-dealing_doc.whn_mod      = GlobalVar:g-today.
        b-dealing_doc.who_mod      = GlobalVar:g-ofc.
        b-dealing_doc.time_cr      = cur_time.
        b-dealing_doc.time_mod     = cur_time.
        b-dealing_doc.crc          = crc.
        b-dealing_doc.DocType      = DocType.
        b-dealing_doc.tclientaccno = tclientaccno.
        b-dealing_doc.vclientaccno = vclientaccno.
        b-dealing_doc.com_accno    = com_accno.
        b-dealing_doc.f_amount     = f_amount.
        b-dealing_doc.input_crc    = input_crc.
        b-dealing_doc.purpose      = purpose.
        rez = true.

    end. /* transaction */


  if rez then message "Документ сохранен!".
  pause 1.
  message "".

  return rez.
 end method.

 /***************************************************************************************************************/
 /* Сохранение изменений в документе после расчета */
 method public log SaveDoc():
  rez = false.
    if LockRecord then
    do:
     if available b-dealing_doc then
     do:
       do transaction:
        cur_time     = time.

        b-dealing_doc.whn_mod      = GlobalVar:g-today.
        b-dealing_doc.who_mod      = GlobalVar:g-ofc.
        b-dealing_doc.time_mod     = cur_time.
        b-dealing_doc.v_amount     = v_amount.
        b-dealing_doc.t_amount     = t_amount.
        b-dealing_doc.rate         = rate.
        b-dealing_doc.acc_com      = acc_com.
        b-dealing_doc.com_conv     = com_conv.
        b-dealing_doc.conv_int     = conv_int.
        b-dealing_doc.conv_int_min = conv_int_min.
        b-dealing_doc.conv_int_max = conv_int_max.
        b-dealing_doc.purpose      = purpose.
        rez = true.
       end. /* transaction */
     end.
     else do:
       message "Набор данных не должен быть пустым!" view-as alert-box.
     end.
    end.
    else message "При изменении данные должны быть заблокированы!" view-as alert-box.
  return rez.
 end method.

 /***************************************************************************************************************/
  /* Сохранение изменений в документе после расчета */
 method public log SaveDoc2():
  rez = false.
    if LockRecord then
    do:
     if available b-dealing_doc then
     do:
       do transaction:
        cur_time     = time.

        b-dealing_doc.whn_mod      = GlobalVar:g-today.
        b-dealing_doc.who_mod      = GlobalVar:g-ofc.
        b-dealing_doc.time_mod     = cur_time.
        b-dealing_doc.v_amount     = v_amount.
        b-dealing_doc.t_amount     = t_amount.
        b-dealing_doc.rate2        = rate2.
        b-dealing_doc.acc_com      = acc_com.
        b-dealing_doc.com_conv     = com_conv.
        b-dealing_doc.conv_int     = conv_int.
        b-dealing_doc.conv_int_min = conv_int_min.
        b-dealing_doc.conv_int_max = conv_int_max.
        b-dealing_doc.purpose      = purpose.
        rez = true.
       end. /* transaction */
     end.
     else do:
       message "Набор данных не должен быть пустым!" view-as alert-box.
     end.
    end.
    else message "При изменении данные должны быть заблокированы!" view-as alert-box.
  return rez.
 end method.

 /***************************************************************************************************************/

  /* Удаляет документ с номером DocNo */
 method public log DeleteDoc():
  if DocNo = '' then do: message "Не найден номер документа!" view-as alert-box. return false. end.
  find b-dealing_doc where b-dealing_doc.docNo = DocNo no-lock no-error.
   if available (b-dealing_doc) then
     do:
       if b-dealing_doc.who_mod <> GlobalVar:g-ofc  then do:
          message "Вы не можете удалять документы принадлежащие" b-dealing_doc.who_mod view-as alert-box.
          return false.
       end.
       if (b-dealing_doc.jh <> 0) and (b-dealing_doc.jh <> ?) then do:
           message "Вы не можете удалить документ с существующей транзакцией" skip "Удалите сначала транзакцию" view-as alert-box.
           return false.
       end.
       find current b-dealing_doc exclusive-lock no-error.
       delete b-dealing_doc.
       return true.
     end.
     else do: message "Документа с таким номером не существует" view-as alert-box. undo. return false. end.
 end method.
 /***************************************************************************************************************/
 method public void LoadData():
   if available b-dealing_doc then do:
     DocNo = b-dealing_doc.DocNo.
     jh = b-dealing_doc.jh.
     who_cr = b-dealing_doc.who_cr.
     whn_cr = b-dealing_doc.whn_cr.
     who_mod = b-dealing_doc.who_mod.
     whn_mod = b-dealing_doc.whn_mod.
     crc = b-dealing_doc.crc.
     input_crc = b-dealing_doc.input_crc.
     DocType = b-dealing_doc.DocType.
     v_amount = b-dealing_doc.v_amount.
     t_amount = b-dealing_doc.t_amount.
     sts = b-dealing_doc.sts.
     tclientaccno = b-dealing_doc.tclientaccno.
     vclientaccno = b-dealing_doc.vclientaccno.
     com_expr = b-dealing_doc.com_expr.
     com_conv = b-dealing_doc.com_conv.
     com_bourse = b-dealing_doc.com_bourse.
     time_cr = b-dealing_doc.time_cr.
     time_mod = b-dealing_doc.time_mod.
     rate = b-dealing_doc.rate.
     t_amt_coms = b-dealing_doc.t_amt_coms.
     jh2 = b-dealing_doc.jh2.
     rate2 = b-dealing_doc.rate2.
     com_accno = b-dealing_doc.com_accno.
     f_amount = b-dealing_doc.f_amount.
     acc_com = b-dealing_doc.acc_com.
     conv_int = b-dealing_doc.conv_int.
     conv_int_min = b-dealing_doc.conv_int_min.
     conv_int_max = b-dealing_doc.conv_int_max.
     purpose = b-dealing_doc.purpose.
   end.
   else do: message "Нет данных!" view-as alert-box. end.
 end method.
/***************************************************************************************************/
 method public void ClearData():
     DocNo = "".
     jh = ?.
     who_cr = ?.
     whn_cr = ?.
     who_mod = ?.
     whn_mod = ?.
     crc = 0.
     v_amount = 0.
     t_amount = 0.
     sts = ?.
     tclientaccno = "".
     vclientaccno = "".
     com_expr = 0.
     com_conv = 0.
     com_bourse = 0.
     time_cr = ?.
     time_mod = ?.
     rate = 0.
     t_amt_coms = ?.
     jh2 = ?.
     rate2 = 0.
     com_accno = "".
     f_amount = 0.
     acc_com = ?.
     input_crc = 0.
     conv_int = 0.
     conv_int_min = 0.
     conv_int_max = 0.
     purpose = "".
     LockRecord = false.
     Count = 0.
     Release b-dealing_doc.
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
   qh:QUERY-PREPARE("for each b-dealing_doc where " + InPar).
   qh:QUERY-OPEN.
    case tp:
     when 1 then do:  qh:GET-NEXT(). end.
     when 2 then do:  qh:GET-LAST(). end.
    end case.
    if avail b-dealing_doc then do:
     if LockRecord then find current b-dealing_doc exclusive-lock no-error.
     else find current b-dealing_doc no-lock no-error.
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

/* Поиск документа по номеру проводки */
method public log FindDocJH(input jh as char):
    if Find-First("jh = " + jh)  then return true.
    else return false.
end method.

/***************************************************************************************************/
  method public int Find-All(INPUT InPar AS character):
    Count = 0.
    qh:QUERY-CLOSE().
    qh:QUERY-PREPARE("for each b-dealing_doc where " + InPar).
    qh:QUERY-OPEN.
    qh:GET-FIRST().
      if avail b-dealing_doc then do:
         REPEAT:
           IF qh:QUERY-OFF-END THEN LEAVE.
           Count = Count + 1.
           qh:GET-NEXT().
         END.
      end.
     return  Count.
  end method.
/***************************************************************************************************/
  method public ConvDocClass ElementBy(INPUT InPar AS int):
     Positions = 1.
     qh:GET-FIRST().
      if avail b-dealing_doc then do:
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
   if available b-dealing_doc then find current b-dealing_doc no-lock no-error.
   LockRecord = false.
 end method.
/***************************************************************************************************/
 method public log Edit():
   if available b-dealing_doc then
   do:
     find current b-dealing_doc exclusive-lock no-error.
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
   release b-dealing_doc.
   LockRecord = true.

   whn_cr       = GlobalVar:g-today.
   who_cr       = GlobalVar:g-ofc.
   whn_mod      = GlobalVar:g-today.
   who_mod      = GlobalVar:g-ofc.

 end method.
/***************************************************************************************************/

/***************************************************************************************************/

END CLASS. /* ConvDocClass */

