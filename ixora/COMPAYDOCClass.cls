/* COMPAYDOCClass.cls

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
        06.11.2009 k.gitalov Добавил функцию CopyData
        06.12.2010 k.gitalov Изменил метод Post
        29.12.2010 k.gitalov Заменил today на jl.jdt
 * CHANGES
        04.04.2012 Lyubov     - добавила проставление символа кассплана
        12.04.2012 k.gitalov  - перепроведение документов
        23.05.2012 damir      - отменил печать БКС на матричный (v-noord = yes), добавил printord.p (печать кассовых ордеров WORD),
        отменил печать старых форматов Приходных кассовых ордеров на матричный и Извещение, Квитанцию на матричный (v-noord = no),
        добавил формирование Квитанции в WORD.
        24.05.2012 damir      - добавил printord.p в PrintPKO..., перекомпиляция.
        28.05.2012 damir      - корректировка в method FindDocJH.
        07.11.2012 damir      - Внедрено Т.З. № 1365,1481,1538.
        14.11.2012 damir      - добавил function AddStr, variable - type_pay,code_reg. Добавление к изменению 07.11.2012.
        15.11.2012 damir      - добавил NO-WAIT.

*/



CLASS COMPAYDOCClass:
  /*Стандартные переменные класса*/
  DEFINE private BUFFER b-compaydoc FOR comm.compaydoc.
  DEFINE private VARIABLE LockRecord AS LOG.
  DEFINE private VARIABLE qh AS HANDLE.
  DEFINE private VARIABLE rez AS LOG.
  DEFINE private VARIABLE Positions AS INT.
  DEFINE private VARIABLE GlobalVar AS CLASS GlobalClass.
  DEFINE public  VARIABLE Count AS INT.

  define public  variable ExData  as class COMPAYDOCEXClass.  /* Расширенные данные платежа (используется при работе с существующим платежем)*/
/***************************************************************************************************/
   DESTRUCTOR  public COMPAYDOCClass():
       ClearData().
       DELETE OBJECT qh.
       if VALID-OBJECT(ExData)  then DELETE OBJECT ExData NO-ERROR .
   END DESTRUCTOR.
/***************************************************************************************************/
   /* Табличные переменные */
   define public  variable docno AS integer FORMAT "zzzzzz9"  .                        /*"Номер документа"*/
   define public  variable who_cr AS character FORMAT "x(8)"  .                        /*"Кто создал документ"*/
   define public  variable whn_cr AS date FORMAT "99/99/99"  .                         /*"Дата создания документа"*/
   define public  variable time_cr AS integer FORMAT "zzzzz9"  .                       /*"Время создания документа"*/
   define public  variable acc_id AS integer FORMAT "zzzzzzz9"  .                      /*индекс аккаунта*/
   define public  variable supp_id AS integer FORMAT "zzzzzzz9"  .                     /*индекс поставщика*/
   define public  variable summ AS decimal FORMAT "z,zzz,zzz,zzz,zz9.99-"  DECIMALS 2. /*"Сумма оплаты"*/
   define public  variable comm_summ AS decimal FORMAT "->>,>>9.99"  DECIMALS 2.       /*"Комиссия банка с физ лиц"*/
   define public  variable jh AS integer FORMAT "zzzzzzz9"  .                          /*"Номер проводки"*/
   define public  variable note AS character FORMAT "x(21)"  .                         /*"описание ошибки"*/
   define public  variable note1 AS character FORMAT "x(21)"  .                        /*"Инвойс"*/
   define public  variable note2 AS character FORMAT "x(50)"  .                        /*"кто разрешил сторно"*/
   define public  variable prev_docno AS integer FORMAT "zzzzzz9"  .                   /* номер транзакции при сторно */
   define public  variable state AS integer FORMAT "zzzzzz9"  .                        /*Статус документа */
   define public  variable ap_whn AS date FORMAT "99/99/99"  .                         /*"Дата проведения документа"*/
   define public  variable ap_time AS integer FORMAT "zzzzz9"  .                       /*"Время проведения документа"*/
/***************************************************************************************************/
   /* Вычисляемые переменные */
   define public  variable payname AS character FORMAT "x(45)"  .                      /*"Ф.И.О плательщика"*/
   define public  variable payacc AS character FORMAT "x(8)"  .                        /*"Лицевой счет плательщика"*/
   define public  variable payphone AS character FORMAT "x(8)"  .                      /*"Номер телефона плательщика"*/
   define public  variable payrnn AS character FORMAT "x(12)"  .                       /*"РНН плательщика"*/
   define public  variable payaddr AS character FORMAT "x(45)"  .                      /*"Адрес плательщика"*/
   define public  variable suppname AS character FORMAT "x(30)"  .                     /*"Наименование поставщика услуг"*/
   define public  variable suppbname AS character FORMAT "x(30)"  .                    /*"Наименование банка поставщика услуг"*/
   define public  variable suppiik AS character FORMAT "x(21)"  .                      /*"ИИК поставщика услуг"*/
   define public  variable suppbik AS character FORMAT "x(10)"  .                      /*"БИК поставщика услуг"*/
   define public  variable supprnn AS character FORMAT "x(12)"  .                      /*"РНН поставщика услуг"*/
   define public  variable knp AS character FORMAT "x(3)"  .                           /*"Код назначения платежа"*/
   define public  variable arp AS character FORMAT "x(21)"  .                          /*"АРП счет для зачисления средств"*/
   define public  variable incom AS character .                                        /*"Доходный счет для зачисления комиссии"*/
   define public  variable paycod AS character .                                       /*Код комиссии с физических лиц*/


   define public  variable ap_code AS integer FORMAT "->,>>>,>>9"  .                   /*"Код провайдера в системе Авангард-Плат"*/
   define public  variable ap_type AS integer FORMAT "->,>>>,>>9"  .                   /*"Тип провайдера в системе Авангард-Плат"*/
   define public  variable ap_tc AS character FORMAT "x(12)"  .                        /*"Телефонные кода провайдеров"*/
   define public  variable minsum AS decimal  FORMAT "->>,>>9.99"  DECIMALS 2.         /*"Минимальная сумма платежа"*/
   define public  variable minlen AS integer  FORMAT "->,>>>,>>9"  .                   /*"Минимальная длина номера лицевого счета"*/
   define public  variable maxlen AS integer  FORMAT "->,>>>,>>9"  .                   /*"Максимальная длина номера лицевого счета"*/
   define public  variable ap_check AS integer FORMAT "->,>>>,>>9"  .                  /*"Наличие онлайн проверки по авангард плат"*/


   define public  variable type AS integer.                                            /* Тип поставщика*/
   /* type = 1 ключевое поле поставщика номер лицевого счета требуются данные адреса*/
   /* type = 2 ключевое поле поставщика номер сотового телефона или номер контракта */
   /* type = 3 ключевое поле поставщика номер контракта (дополнительно используется класс COMPAYDOCEXClass)*/
   define public  variable b-txb        as char format "x(6)".                               /* Код филиала банка*/
   define public  variable b-name       as char format "x(30)".                              /* Название филиала*/
   define public  variable b-addr       as char format "x(30)".                              /* Адрес филиала*/
   define public  variable ofcname      as char format "x(30)".                             /* Фамилия who_cr*/
   define public  variable supp_proc    AS decimal FORMAT "->>,>>9.99"  DECIMALS 2.      /*процент комиссии с поставщика услуг*/
   define public  variable v-noord      as logi format "да/нет" init no.
   define public  variable v-bin        as logi init no.
   define public  variable v-file       as char init "Repttt1.htm".
   define public  variable v-file2      as char init "Repttt2.htm".
   define public  variable payiin       as character FORMAT "x(12)".                     /*"ИИН плательщика"*/
   define public  variable typepay      as character.                                    /*Типы платежей*/
   define public  variable codereg      as character.                                    /*Регионы*/
   define public  variable type_pay     as character.                                    /*Код платежа*/
   define public  variable code_reg     as character.                                    /*Код региона*/

   define private stream v-out.
   define private stream v-out2.
   define private stream m-out.                                                      /*Поток для вывода данных на печать*/
/***************************************************************************************************/
/***************************************************************************************************/
   CONSTRUCTOR public COMPAYDOCClass( INPUT std AS CLASS GlobalClass ):
       GlobalVar = std.
       LockRecord = false.
       CREATE QUERY qh.
       qh:SET-BUFFERS("b-compaydoc").
       Count = 0.

       /*
       if LENGTH(GlobalVar:g-comp, "RAW") > 30 then b-name = "Филиал АО \"МЕТРОКОМБАНК\"".
       else b-name = GlobalVar:g-comp.
       */

       b-name = GlobalVar:g-comp.

       b-txb    = GlobalVar:b-txb.
       b-addr   = GlobalVar:b-addr. /*GlobalVar:g-comp*/
       ofcname  = GlobalVar:ofcname.

       ExData = NEW COMPAYDOCEXClass(std).

       find first sysc where sysc.sysc eq "noorder" no-lock no-error.
       if avail sysc then v-noord = sysc.loval.

       find first sysc where sysc.sysc = 'bin' no-lock no-error.
       if avail sysc then v-bin = sysc.loval.
   END CONSTRUCTOR.
/***************************************************************************************************/
 method public log CancelDoc():

  def var s-jh as int init 0.
  def var rcode as int init 0.
  def var rdes as char init "".




  do transaction:


   run trxstor(input jh, input 5, output s-jh, output rcode, output rdes).


   if rcode ne 0 then
   do:
    message rdes view-as alert-box.
    return false.
   end.
   else do:

      find first jl where jl.jh = s-jh and jl.crc = 1 and jl.gl = 100100 no-lock no-error.
      if avail jl then do:
          create jlsach .
          jlsach.jh = s-jh.
          if jl.dc = "c" then jlsach.amt = jl.cam .
          else jlsach.amt = jl.dam .
          jlsach.ln = jl.ln .
          jlsach.lnln = 1.
          jlsach.sim = 300.
      end.

      find first b-compaydoc where b-compaydoc.docno = docno exclusive-lock no-error NO-WAIT.
      if available b-compaydoc then
      do:
        b-compaydoc.prev_docno = s-jh.
        if b-compaydoc.state = 4 then b-compaydoc.state = 6.
        if b-compaydoc.state = 5 then b-compaydoc.state = 7.
        b-compaydoc.note = " Сторно[ " + string(s-jh) + " ]".
        find current b-compaydoc no-lock.

        FindDocNo(string(docno)).
        return true.
      end.
      else do:
        message "Документ не найден либо занят другим пользователем, попробуйте позднее !!!" view-as alert-box.
        return false.
      end.

   end.

  end. /*transaction*/

 end method.
/***************************************************************************************************/
 method public log DeleteDoc( ):

   find first b-compaydoc where b-compaydoc.docno = docno exclusive-lock no-error NO-WAIT.
   if available b-compaydoc then
   do:
     find first jh where jh.jh = b-compaydoc.jh no-lock no-error.
     if avail jh then
     do:
      if jh.sts = 6 then do:
        message "Нельзя удалить отштампованную проводку!" view-as alert-box.
        return false.
      end.
     end.

     if b-compaydoc.note <> ? then  b-compaydoc.note = b-compaydoc.note + " Транзакция удалена без штампа - " + GlobalVar:g-ofc.
     else b-compaydoc.note = " Транзакция удалена без штампа - " + GlobalVar:g-ofc.
     b-compaydoc.state = -2.

   end.
   else do:
     message "Документ не найден либо занят другим пользователем, попробуйте позднее !!!" view-as alert-box.
     return false.
   end.

  return true.
 end method.
/***************************************************************************************************/
 method public log SetState( input Cod as int , input note as char):
       find first b-compaydoc where b-compaydoc.docno = docno exclusive-lock no-error NO-WAIT.
       if available b-compaydoc then do:
          b-compaydoc.state = Cod.
          if note <> "" then b-compaydoc.note2 = note.
          if Cod = 2 then b-compaydoc.note = note.
          LoadData().

       end.
       else do:
           message "Документ не найден либо занят другим пользователем, попробуйте позднее !!!" view-as alert-box.
           return false.
       end.

 end method.
/***************************************************************************************************/

 method public log SetState( input Cod as int,input dt as date,input tm as int):

   if state = Cod then return true.

   def var state_init as integer no-undo.
   state_init = state.
   def var v-errcode as integer no-undo init 0.
   def var v-errdes as char no-undo init ''.

   case state:
     when 0 then do:
        if Cod = 1 then state = Cod.
        else do:
            message "Попытка некорректного изменения статуса (0->" + string(Cod) + ")!" view-as alert-box.
            return false.
        end.
     end.
     when 1 then do:
        case Cod:
            when 2 then do:
                state = Cod.
                ap_whn = dt.
                ap_time = tm.
                if prev_docno <> ? then do:
                 note = "  ( Перепроведен [" + string(prev_docno) + "] )".
                end.
            end.
            when -1 then do:
                state = Cod.
                v-errcode = 1440 - round(tm / 60,0).
                find first comm.aperrlist where comm.aperrlist.errcode = v-errcode no-lock no-error.
                if avail comm.aperrlist then v-errdes = "(" + string(v-errcode) + ") " + comm.aperrlist.errdes.
                else v-errdes = "(" + string(v-errcode) + "): неизвестная ошибка".
                note = v-errdes.
            end.
            otherwise do:
                message "Попытка некорректного изменения статуса (1->" + string(Cod) + ")!" view-as alert-box.
                return false.
            end.
        end case.
     end.
     otherwise do:
        message "Статус документа не может быть изменен!" view-as alert-box.
        return false.
     end.
   end case.

   if state <> state_init then do:
       find first b-compaydoc where b-compaydoc.docno = docno exclusive-lock no-error NO-WAIT.
       if available b-compaydoc then do:
           b-compaydoc.state = state.
           if state = 2 then do:
                b-compaydoc.ap_whn = ap_whn.
                b-compaydoc.ap_time = ap_time.
                b-compaydoc.note = note.
           end.
           if state = -1 then do:
                b-compaydoc.note = note.
               /* message "Документ не проведен!~n" + v-errdes view-as alert-box.*/
           end.
           find current b-compaydoc no-lock.
       end.
       else do:
           message "Документ не найден либо занят другим пользователем, попробуйте позднее !!!" view-as alert-box.
           return false.
       end.
   end.

 end method.

/***************************************************************************************************/
 method public log FindPayTarif( input TarCod as char):
   /* Поиск тарифов по физ лицам */
   def buffer b-tarif2 for tarif2.
   find first b-tarif2 where b-tarif2.num + b-tarif2.kod = TarCod and b-tarif2.stat = 'r' no-lock no-error.
   if avail b-tarif2 then do:

     if jh = ? then comm_summ = b-tarif2.ost.

     incom = string(b-tarif2.kont).
     if incom = "100100" or incom = "100200" or incom = "100300" then
     do:
      message "Неверно указан счет для зачисления комиссии - " + incom + " !" skip "      Не настроен тарификатор!" view-as alert-box.
      return false.
     end.
     return true.
   end.
   else do:
    message "Нет записей в тарификаторе с кодом " + TarCod + " !" view-as alert-box.
    return false.
   end.
 end method.
/***************************************************************************************************/
 method public void LoadData():
   if available b-compaydoc then do:
     docno = b-compaydoc.docno.
     prev_docno = b-compaydoc.prev_docno.
     who_cr = b-compaydoc.who_cr.
     whn_cr = b-compaydoc.whn_cr.
     time_cr = b-compaydoc.time_cr.
     acc_id = b-compaydoc.acc_id.
     supp_id = b-compaydoc.supp_id.
     summ = b-compaydoc.summ.
     comm_summ = b-compaydoc.comm_summ.
     jh = b-compaydoc.jh.
     note = b-compaydoc.note.
     note1 = b-compaydoc.note1.
     note2 = b-compaydoc.note2.
     state = b-compaydoc.state.
     ap_whn = b-compaydoc.ap_whn.
     ap_time = b-compaydoc.ap_time.
     type_pay = trim(b-compaydoc.typepay).
     code_reg = trim(b-compaydoc.codereg).
   end.
 end method.
/***************************************************************************************************/
 method public void ClearData():
     docno = ?.
     prev_docno = ?.
     who_cr = ?.
     whn_cr = ?.
     time_cr = ?.
     acc_id = ?.
     supp_id = ?.
     summ = 0.
     comm_summ = 0.
     jh = ?.
     note = ?.
     note1 = ?.
     note2 = ?.
     state = 0.
     ap_whn = ?.
     ap_time = ?.
     type_pay = "".
     code_reg = "".

     LockRecord = false.
     Count = 0.
     Release b-compaydoc.

     ExData:ClearData().
 end method.
/***************************************************************************************************/
 method public void ExClearData():
      payname  = "".
      payacc   = "".
      payphone = "".
      payrnn   = "".
      payaddr  = "".
      suppname = "".
      suppbname  = "".
      suppiik = "".
      suppbik = "".
      supprnn = "".
      knp     = "".
      arp     = "".
      incom   = "".
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
   qh:QUERY-PREPARE("for each b-compaydoc where " + InPar + " no-lock").
   qh:QUERY-OPEN.
    case tp:
     when 1 then do:  qh:GET-NEXT(). end.
     when 2 then do:  qh:GET-LAST(). end.
    end case.
    if avail b-compaydoc then do:
     if LockRecord then find current b-compaydoc exclusive-lock no-error NO-WAIT.
     else find current b-compaydoc no-lock no-error.
        if LockRecord then do:
            if not avail b-compaydoc then do:
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
    qh:QUERY-PREPARE("for each b-compaydoc where " + InPar ).
    qh:QUERY-OPEN.
    qh:GET-FIRST().
      if avail b-compaydoc then do:
         REPEAT:
           IF qh:QUERY-OFF-END THEN LEAVE.
           Count = Count + 1.
           qh:GET-NEXT().
         END.
      end.
     return  Count.
  end method.
/***************************************************************************************************/
  method public COMPAYDOCClass ElementBy(INPUT InPar AS int):
     Positions = 1.
     qh:GET-FIRST().
      if avail b-compaydoc then do:
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
   if available b-compaydoc then find current b-compaydoc no-lock no-error.
   LockRecord = false.
 end method.
/***************************************************************************************************/
 method public log Edit():
   if available b-compaydoc then
   do:
     find current b-compaydoc exclusive-lock no-error NO-WAIT.
     if avail b-compaydoc then do:
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
   who_cr = GlobalVar:g-ofc.
   whn_cr = GlobalVar:g-today.
 end method.
/***************************************************************************************************/
 method public log CopyData():
   message "Метод CopyData не используется!" view-as alert-box.
   return false.

  /* if note <> ?  then do: message "Документ уже был перепроведен! \n  Документом № " + note view-as alert-box. return false. end.*/
   if docno = ? then do: message "Документ не имеет номера!" view-as alert-box. return false. end.
   prev_docno = docno.
   docno = ?.


   /*
   summ = 0.
   comm_summ = 0.
   jh = ?.
   */
   Count = 0.
   Release b-compaydoc.
   ExData:ClearData().
   LockRecord = true.
   who_cr = GlobalVar:g-ofc.
   whn_cr = GlobalVar:g-today.

   return true.
 end method.
/***************************************************************************************************/
 method public log DelData():
   rez = false.
   if LockRecord then do:
     do transaction:
       if available b-compaydoc then do:
        find current b-compaydoc exclusive-lock no-error NO-WAIT.
        if avail b-compaydoc then do:
            delete b-compaydoc.
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
method public log ReSend(input OldDoc as COMPAYDOCClass):
   AddData().
   if not VALID-OBJECT(OldDoc) then do:
     message "Объект не инициализирован!" view-as alert-box.
     return false.
   end.

    supp_id = OldDoc:supp_id.
    acc_id = OldDoc:acc_id.
    summ = OldDoc:summ.
    comm_summ = OldDoc:comm_summ.
    note = "Перепроведение документа [" + string(OldDoc:docno) + "]".
    prev_docno = OldDoc:docno.
    state = -2.


    if not Post() then do:
      message "Ошибка сохранения нового документа!" view-as alert-box.
      return false.
    end.

    OldDoc:Edit().
    OldDoc:prev_docno = docno.
    OldDoc:state = 0.
    if not OldDoc:Post() then do:
      message "Ошибка сохранения перепроводимого документа!" view-as alert-box.
      return false.
    end.


  return true.
 end method.
/***************************************************************************************************/

 method public log Post():
   rez = false.
   if LockRecord then do:
    do transaction:
      if not available b-compaydoc then
      do:

       if acc_id = ? or supp_id = ? then
       do:
          message "Невозможно определить плательщика или поставщика!" view-as alert-box.
          message "acc_id=" string(acc_id) view-as alert-box.
          message "supp_id=" string(supp_id) view-as alert-box.
          rez = false.
       end.
       else do:
         create b-compaydoc.
         time_cr = time.
         docno =  next-value(paydoc,comm).
         b-compaydoc.docno = docno.
         b-compaydoc.prev_docno = prev_docno.
         b-compaydoc.who_cr = who_cr.
         b-compaydoc.whn_cr = whn_cr.
         b-compaydoc.time_cr = time_cr.
         b-compaydoc.acc_id = acc_id.
         b-compaydoc.supp_id = supp_id.
         b-compaydoc.summ = summ.
         b-compaydoc.comm_summ = comm_summ.
         b-compaydoc.note = note.
         b-compaydoc.note1 = note1.
         b-compaydoc.note2 = note2.
         b-compaydoc.state = state.
         b-compaydoc.jh = jh.
         b-compaydoc.txb = b-txb.
         b-compaydoc.typepay = trim(type_pay).
         b-compaydoc.codereg = trim(code_reg).
         rez = true.
       end.

      end.
      else do:
       if b-compaydoc.jh = ? or b-compaydoc.jh = 0 then
       do:
        b-compaydoc.jh = jh.
        rez = true.
       end.

       if prev_docno <> ? then
       do:
        b-compaydoc.prev_docno = prev_docno.
        b-compaydoc.state = state.
        rez = true.
       end.

      end.

    end. /* transaction */
   end.
   else message "При изменении данные должны быть заблокированы!" view-as alert-box.
   return rez.
 end method.
/***************************************************************************************************/
 method public void SetUsrData(input Usr as ACCOUNTClass):
        if supp_id  <> Usr:supp_id then do: message "Ошибка! Несоответствие ID поставщика" view-as alert-box. return. end.
        acc_id   = Usr:acc_id.
        payacc   = Usr:acc.
        payname  = Usr:name.
        payrnn   = Usr:rnn.
        payphone = Usr:phone.
        payaddr  = Usr:addr.
 end method.
/***************************************************************************************************/
 method public void SetSuppData(input SP AS SUPPCOMClass):
        if not VALID-OBJECT(SP) then do: message "Объект не инициализирован!" view-as alert-box. return. end.

        if not FindPayTarif(SP:paycod) then return .

        supp_proc  = SP:supcod.
        suppname   = SP:name.
        suppbname  = SP:bname.
        suppiik    = SP:iik.
        suppbik    = SP:bik.
        supprnn    = SP:rnn.
        knp        = SP:knp.
        arp        = SP:arp.
        type       = SP:type.
        b-txb      = SP:txb.
        supp_id    = SP:supp_id.
        ap_code    = SP:ap_code.
        ap_type    = SP:ap_type.
        ap_tc      = SP:ap_tc.
        minsum     = SP:minsum.
        minlen     = SP:minlen.
        maxlen     = SP:maxlen.
        ap_check   = SP:ap_check.
        paycod     = SP:paycod.
        typepay    = SP:typepay.
        codereg    = SP:codereg.
 end method.
/***************************************************************************************************/
 method public log TrxSts():
 /*штамповка проводки*/

  def var stsno as int init 0.
  if prev_docno <> ? then stsno = prev_docno.
  else do:
   if jh <> ? then stsno = jh.
  end.
  if stsno = 0 then do: message "Нет номера проводки (TrxSts)" view-as alert-box. return false. end.


  find jh where jh.jh = stsno no-lock no-error.
  if avail jh then
  do:
   if jh.sts > 5 then do: message "Проводка не может быть отштампована! (>5)" view-as alert-box. return false. end.
   /* if jh.sts <> 5 then do: message "Проводка не может быть отштампована!" view-as alert-box. return false. end.*/
  end.

  do transaction:

    find jh where jh.jh = stsno exclusive-lock.
    jh.sts = 6.
    for each jl where jl.jh = stsno exclusive-lock:
        jl.sts = 6.
        jl.teller = GlobalVar:g-ofc.
    end.

    for each jl where jl.jh = stsno and jl.sts = 6 and ( jl.gl = 100100 or jl.gl = 100200 ) no-lock:
     find first cashofc where cashofc.whn eq jl.jdt and cashofc.sts eq 2 and cashofc.ofc eq GlobalVar:g-ofc and cashofc.crc eq jl.crc exclusive-lock no-error.
     if avail cashofc then
     do:
        cashofc.amt = cashofc.amt + jl.dam - jl.cam .
     end.
     else do:
        create cashofc.
        cashofc.whn = jl.jdt.
        cashofc.ofc = who_cr. /*GlobalVar:g-ofc. */
        cashofc.crc = jl.crc.
        cashofc.sts = 2.
        cashofc.amt = jl.dam - jl.cam.
        cashofc.who = GlobalVar:g-ofc.
     end.
     release cashofc.


    end.  /* each jl */

    PrintBKS(stsno).
  /* message "PrintBKS" view-as alert-box.*/

  end. /* transaction */
  return true.
 end method.
/***************************************************************************************************/
 method public log CheckAcc(input acc as char):
   /*Проверка формата введенного значения в зависимости от типа провайдера */
     if LENGTH(acc, "RAW") > maxlen then
     do:
        message "Максимальная длина номера должна быть " + string(maxlen) + " символов"  view-as alert-box.
        return false.
     end.

     if LENGTH(acc, "RAW") < minlen then
     do:
       message "Минимальная длина номера должна быть " + string(minlen) + " символов" view-as alert-box.
       return false.
     end.

     if ap_tc <> "" and ap_tc <> ? then
     do:
      if LOOKUP( SUBSTRING(acc,1,3,"CHARACTER") , ap_tc, "|") = 0 then
      do:
       message "Номер должен начинаться с " ap_tc view-as alert-box.
       return false.
      end.
     end.

   /*Если до этого не вернули ничего плохого то - ОК */
   return true.
 end method.
/***************************************************************************************************/
/* Поиск документа по номеру проводки */
method public log FindDocJH(input jh as char):
    if Find-First("jh = " + jh + " and txb = '" + b-txb + "'") then return LoadFindDoc().
    else return false.
end method.
/***************************************************************************************************/
/* Поиск документа по номеру документа */
 method public log FindDocNo(input docno as char):
   if Find-First("docno = " + docno) then return LoadFindDoc().
   else return false.
 end method.
/***************************************************************************************************/
/* Загрузка данных найденного документа */
 method private log LoadFindDoc():
      /*Поиск данных поставщика */
      DEF VAR SP AS Class SUPPCOMClass.
      SP = new SUPPCOMClass(GlobalVar).
      if SP:Find-First("supp_id = " + string(supp_id) ) then do: SetSuppData(SP). DELETE OBJECT SP NO-ERROR . end.
      else do:
        DELETE OBJECT SP NO-ERROR .
        message "Не найден поставщик услуг с кодом - " string(supp_id) view-as alert-box.
        return false.
      end.
      /*Поиск данных плательщика*/
      DEF VAR Usr AS class ACCOUNTClass.
      Usr = NEW ACCOUNTClass(GlobalVar,supp_id).
      if Usr:Find-First("acc_id = " + string(acc_id) ) then
      do:
       Usr:FindAcc(Usr:acc).
       SetUsrData(Usr).
       DELETE OBJECT Usr NO-ERROR.
       /*return true. */
      end.
      else do: message "Не найден плательщик с кодом - " string(acc_id) view-as alert-box. return false. end.

      if docno <> ? then ExData:Find-All("docno = " + string(docno) + " no-lock BY sortOrder" ).
      return true.
 end method.
/***************************************************************************************************/
 /* Печать чека БКС для данного документа */
 method private void PrintBKS(input z-jh as integer):
   /* */
   if z-jh <> ? and v-noord = no then run bks (string(z-jh,"zzzzzzz9") + "#" + "Платежи " + suppname + "#" + string(summ) + "#" + string(comm_summ) + "#1#KZT","COM#" + string(docno,"99999999")).
 end method.
/***************************************************************************************************/
/* Печать приходного кассового ордера или квитанции-извещения  для данного документа */
method public void PrintPKO():
    if jh = ? then do: /*message "Нет проводки для документа!"  skip "Печать приходного ордера невозможна" view-as alert-box.*/ return. end.
    find jh where jh.jh = jh no-lock no-error.
    if not avail jh then do: message "Не найдена запись в таблице jh!" view-as alert-box. return. end.
    find ofc where ofc.ofc = jh.who no-lock no-error.
    if not avail ofc then do: message "Не найдена запись в таблице ofc" view-as alert-box. return. end.
    find joudoc where joudoc.docnum eq jh.party no-lock no-error.
    if not avail joudoc then do: message "Не найдена запись в таблице joudoc" view-as alert-box. return. end.

    def var decAmount as deci.
    def var strAmount as char format "x(80)".
    def var temp as char.
    def var strTemp as char.
    def var str1 as char format "x(80)".
    def var str2 as char format "x(80)".

    if v-noord = yes then run printord(jh,"").
    else do:
        output stream m-out to pkso.tmp.
        if type = 3 then
        do:
        /**/
        /***********************************************************************************/
        put stream m-out unformatted "---------------------------------------------------------------------------" skip(1).
        put stream m-out unformatted space(30) "ИЗВЕЩЕНИЕ" skip(1).

        /* put stream m-out unformatted "Dok.Nr. " + string(docno,"99999999") + "/" + joudoc.docnum + "/" + trim(joudoc.num) + "/" + trim(ofc.name) +
        "              " + string(joudoc.whn, "99/99/9999") skip.*/
        put stream m-out unformatted string (jh) + "/" + joudoc.docnum + "/" + "Dok.Nr." + string(docno,"99999999") + "/" + trim(joudoc.num) + "/" +
        trim(ofc.name) +  "              " + string(joudoc.whn, "99/99/9999") skip.

        /*put "x1E Приход -" sumin[cc] format ">>>>>>>>9.99" "  " GetCodeCrc(cc) "x0F"skip.*/
        put stream m-out unformatted "===========================================================================" skip.
        put stream m-out unformatted "Платежи " + suppname skip.
        put stream m-out unformatted "Лицевой счет x1E" + payacc  + "x0F" skip.
        put stream m-out unformatted "Плательщик " + payname skip.
        if payname <> payaddr then put stream m-out unformatted  payaddr skip.

        put stream m-out unformatted "===========================================================================" skip.
        put stream m-out unformatted "Наименование сервиса                               к оплате       оплачиваю" skip.
        put stream m-out unformatted "---------------------------------------------------------------------------" skip.
        def var y as int.
        REPEAT y = 1 to ExData:Count:
        put stream m-out unformatted string(ExData:ElementBy(y):NamSub,"x(47)") +
                               string(ExData:ElementBy(y):ForPay,"z,zzz,zz9.99") + "   "
                               string(ExData:ElementBy(y):Pay,"z,zzz,zz9.99") skip.
        END.
        put stream m-out unformatted "---------------------------------------------------------------------------" skip.

        put stream m-out unformatted "                                               Сумма платежа: " + string(summ,"z,zzz,zz9.99") skip.
        if comm_summ > 0 then do:
        put stream m-out unformatted "                                              Комиссия банка: " + string(comm_summ,"z,zzz,zz9.99") skip.
        end.
        put stream m-out unformatted   "                                                     x1E  ИТОГО: " +  string(summ + comm_summ,"z,zzz,zz9.99") + "x0F" skip.
        put stream m-out unformatted "---------------------------------------------------------------------------" skip.

        /* Печать суммы прописью - Взято из jl-prcd.p*/
        decAmount =  summ + comm_summ.
        put stream m-out unformatted "Сумма прописью: ".
        temp = string (decAmount).

        if num-entries(temp,".") = 2 then /*если равно, то в сумме есть тиыны*/
        do:
        temp = substring(temp, length(temp) - 1, 2).
        if num-entries(temp,".") = 2 then temp = substring(temp,2,1) + "0".
        end.
        else temp = "00".

        strTemp = string(truncate(decAmount,0)).

        run Sm-vrd(input decAmount, output strAmount).
        run sm-wrdcrc(input strTemp,input temp,input 1,output str1,output str2).
        strAmount = strAmount + " " + str1 + " " + temp + " " + str2.

        if length(strAmount) > 80 then
        do:
        str1 = substring(strAmount,1,80).
        str2 = substring(strAmount,81,length(strAmount,"CHARACTER") - 80).
        put stream m-out unformatted str1 skip str2 skip(1).
        end.
        else  put stream m-out unformatted strAmount skip(1).
        /*------------------------------------------------------------------------------*/


        /* put stream m-out unformatted "Кассир  : " skip(1).*/


        put stream m-out unformatted "Подпись вносителя :                                      Кассир  : " skip(1).

        put stream m-out unformatted "===========================================================================" skip.


        /*put "x1E Приход -" sumin[cc] format ">>>>>>>>9.99" "  " GetCodeCrc(cc) "x0F"skip.*/



        /**/
        end.
        else do:
        /***********************************************************************************/
        put stream m-out unformatted "---------------------------------------------------------------------------" skip(1).
        put stream m-out unformatted space(20) "ПРИХОДНЫЙ КАССОВЫЙ ОРДЕР" skip(1).
        /* put stream m-out unformatted "---------------------------------------------------------------------------" skip(1).*/
        /*put stream m-out unformatted "Dok.Nr. " + string (jh) + "/" + joudoc.docnum + "/" + trim(joudoc.num) + "/" + trim(ofc.name) + */
        /*  put stream m-out unformatted "Dok.Nr. " + string(docno,"99999999") + "/" + joudoc.docnum + "/" + trim(joudoc.num) + "/" + trim(ofc.name) + */
        put stream m-out unformatted string (jh) + "/" + joudoc.docnum + "/" + "Dok.Nr." + string(docno,"99999999") + "/" + trim(joudoc.num) + "/" +
        trim(ofc.name) +  "              " + string(joudoc.whn, "99/99/9999") skip.
        put stream m-out unformatted "===========================================================================" skip.
        put stream m-out unformatted "ВАЛЮТА                                      ПРИХОД                РАСХОД" skip.
        put stream m-out unformatted "---------------------------------------------------------------------------" skip.
        put stream m-out unformatted "Тенге                            " + string(summ,"z,zzz,zzz,zz9.99") +
        "     " + string(0,"z,zzz,zzz,zz9.99") skip.

        if comm_summ > 0 then do:
        put stream m-out unformatted "Тенге                            " + string(comm_summ,"z,zzz,zzz,zz9.99") +
        "     " + string(0,"z,zzz,zzz,zz9.99") skip.
        end.

        put stream m-out unformatted skip(2) space(21) " x1E ИТОГО: " string(summ + comm_summ,"z,zzz,zzz,zz9.99") + "x0F" skip(2).


        /*----------------------------------------------------------------------------*/
        /* Печать суммы прописью - Взято из jl-prcd.p*/

        decAmount =  summ + comm_summ.
        put stream m-out unformatted "Сумма прописью: ".
        temp = string (decAmount).

        if num-entries(temp,".") = 2 then /*если равно, то в сумме есть тиыны*/
        do:
        temp = substring(temp, length(temp) - 1, 2).
        if num-entries(temp,".") = 2 then temp = substring(temp,2,1) + "0".
        end.
        else temp = "00".

        strTemp = string(truncate(decAmount,0)).

        run Sm-vrd(input decAmount, output strAmount).
        run sm-wrdcrc(input strTemp,input temp,input 1,output str1,output str2).
        strAmount = strAmount + " " + str1 + " " + temp + " " + str2.

        if length(strAmount) > 80 then
        do:
        str1 = substring(strAmount,1,80).
        str2 = substring(strAmount,81,length(strAmount,"CHARACTER") - 80).
        put stream m-out unformatted str1 skip str2 skip(1).
        end.
        else  put stream m-out unformatted strAmount skip(1).
        /*------------------------------------------------------------------------------*/

        /*
        put stream m-out unformatted "Кассир  : " skip(1).

        if joudoc.info = "NO NAME" then put stream m-out unformatted "Внес    : " skip(1).
        else put stream m-out unformatted "Внес    : " + joudoc.info skip(1).
        */

        /* put stream m-out unformatted "Внес    : " + joudoc.info skip(1).*/

        put stream m-out unformatted "---------------------------------------------------------------------------" skip(1).
        if joudoc.perkod <> "000000000000" then  put stream m-out unformatted "PHH               : " + joudoc.perkod skip(1).

        /* put stream m-out unformatted "Подпись : " skip(1).*/

        put stream m-out unformatted "Подпись вносителя :                                      Кассир  : " skip(1).

        put stream m-out unformatted "===========================================================================" skip.
        put stream m-out unformatted "Примечание : /" + arp + "/ Платежи " + suppname + "/#".

        put stream m-out unformatted "x1E" + payacc  + "x0F" skip.
        put stream m-out unformatted "===========================================================================" skip(1).

        end.
        /***********************************************************************************/
        put stream m-out  unformatted skip(1) chr(27) chr(64).
        output stream m-out close.

        unix silent prit pkso.tmp.
    end.
 end method.
/***************************************************************************************************/
/* Печать приходного кассового ордера или квитанции после штампа */
method public void PrintPKO2():
    def var v-inputfile as char init "/data/export/report.htm".
    def var v-str       as char.

    if jh = ? then do: /*message "Нет проводки для документа!"  skip "Печать приходного ордера невозможна" view-as alert-box.*/ return. end.
    find jh where jh.jh = jh no-lock no-error.
    if not avail jh then do: message "Не найдена запись в таблице jh!" view-as alert-box. return. end.
    find ofc where ofc.ofc = jh.who no-lock no-error.
    if not avail ofc then do: message "Не найдена запись в таблице ofc" view-as alert-box. return. end.
    find joudoc where joudoc.docnum eq jh.party no-lock no-error.
    if not avail joudoc then do: message "Не найдена запись в таблице joudoc" view-as alert-box. return. end.

    def var decAmount as deci.
    def var strAmount as char format "x(80)".
    def var temp as char.
    def var strTemp as char.
    def var str1 as char format "x(80)".
    def var str2 as char format "x(80)".

    if v-noord = yes then run printord(jh,"").
    else do:
        output stream m-out to pkso.tmp.
        if type = 3 then
        do:
        /**/
        /***********************************************************************************/

        /* Квитанция*/
        put stream m-out unformatted "---------------------------------------------------------------------------" skip(1).
        put stream m-out unformatted space(30) "КВИТАНЦИЯ" skip(1).

        put stream m-out unformatted string (jh) + "/" + joudoc.docnum + "/" + "Dok.Nr." + string(docno,"99999999") + "/" + trim(joudoc.num) + "/" +
        trim(ofc.name) +  "              " + string(joudoc.whn, "99/99/9999") skip.
        put stream m-out unformatted "===========================================================================" skip.
        put stream m-out unformatted "Платежи " + suppname skip.
        put stream m-out unformatted "Лицевой счет x1E" + payacc  + "x0F" skip.
        put stream m-out unformatted "Плательщик " + payname skip.
        if payname <> payaddr then put stream m-out unformatted  payaddr skip.
        put stream m-out unformatted "===========================================================================" skip.
        put stream m-out unformatted "Наименование сервиса                               к оплате       оплачиваю" skip.
        put stream m-out unformatted "---------------------------------------------------------------------------" skip.
        def var y as int.
        REPEAT y = 1 to ExData:Count:
        put stream m-out unformatted string(ExData:ElementBy(y):NamSub,"x(47)") +
                               string(ExData:ElementBy(y):ForPay,"z,zzz,zz9.99") + "   "
                               string(ExData:ElementBy(y):Pay,"z,zzz,zz9.99") skip.
        END.
        put stream m-out unformatted "---------------------------------------------------------------------------" skip.
        put stream m-out unformatted "                                               Сумма платежа: " + string(summ,"z,zzz,zz9.99") skip.
        if comm_summ > 0 then do:
        put stream m-out unformatted "                                              Комиссия банка: " + string(comm_summ,"z,zzz,zz9.99") skip.
        end.
        put stream m-out unformatted  "                                                     x1E  ИТОГО: " +  string(summ + comm_summ,"z,zzz,zz9.99") + "x0F" skip.
        put stream m-out unformatted "---------------------------------------------------------------------------" skip.

        /* Печать суммы прописью - Взято из jl-prcd.p*/
        decAmount =  summ + comm_summ.
        put stream m-out unformatted "Сумма прописью: ".
        temp = string (decAmount).

        if num-entries(temp,".") = 2 then /*если равно, то в сумме есть тиыны*/
        do:
        temp = substring(temp, length(temp) - 1, 2).
        if num-entries(temp,".") = 2 then temp = substring(temp,2,1) + "0".
        end.
        else temp = "00".

        strTemp = string(truncate(decAmount,0)).

        run Sm-vrd(input decAmount, output strAmount).
        run sm-wrdcrc(input strTemp,input temp,input 1,output str1,output str2).
        strAmount = strAmount + " " + str1 + " " + temp + " " + str2.

        if length(strAmount) > 80 then
        do:
        str1 = substring(strAmount,1,80).
        str2 = substring(strAmount,81,length(strAmount,"CHARACTER") - 80).
        put stream m-out unformatted str1 skip str2 skip(1).
        end.
        else  put stream m-out unformatted strAmount skip(1).
        /*------------------------------------------------------------------------------*/
        put stream m-out unformatted "Подпись вносителя :                                      Кассир  : " skip(1).

        put stream m-out unformatted "===========================================================================" skip.




        /**/
        end.
        else do:
        /***********************************************************************************/
        put stream m-out unformatted "---------------------------------------------------------------------------" skip(1).
        put stream m-out unformatted space(20) "ПРИХОДНЫЙ КАССОВЫЙ ОРДЕР" skip(1).
        put stream m-out unformatted string (jh) + "/" + joudoc.docnum + "/" + "Dok.Nr." + string(docno,"99999999") + "/" + trim(joudoc.num) + "/" +
        trim(ofc.name) +  "              " + string(joudoc.whn, "99/99/9999") skip.
        put stream m-out unformatted "===========================================================================" skip.
        put stream m-out unformatted "ВАЛЮТА                                      ПРИХОД                РАСХОД" skip.
        put stream m-out unformatted "---------------------------------------------------------------------------" skip.
        put stream m-out unformatted "Тенге                            " + string(summ,"z,zzz,zzz,zz9.99") +
        "     " + string(0,"z,zzz,zzz,zz9.99") skip.

        if comm_summ > 0 then do:
        put stream m-out unformatted "Тенге                            " + string(comm_summ,"z,zzz,zzz,zz9.99") +
        "     " + string(0,"z,zzz,zzz,zz9.99") skip.
        end.

        put stream m-out unformatted skip(2) space(21) " x1E ИТОГО: " string(summ + comm_summ,"z,zzz,zzz,zz9.99") + "x0F" skip(2).


        /*----------------------------------------------------------------------------*/
        /* Печать суммы прописью - Взято из jl-prcd.p*/

        decAmount =  summ + comm_summ.
        put stream m-out unformatted "Сумма прописью: ".
        temp = string (decAmount).

        if num-entries(temp,".") = 2 then /*если равно, то в сумме есть тиыны*/
        do:
        temp = substring(temp, length(temp) - 1, 2).
        if num-entries(temp,".") = 2 then temp = substring(temp,2,1) + "0".
        end.
        else temp = "00".

        strTemp = string(truncate(decAmount,0)).

        run Sm-vrd(input decAmount, output strAmount).
        run sm-wrdcrc(input strTemp,input temp,input 1,output str1,output str2).
        strAmount = strAmount + " " + str1 + " " + temp + " " + str2.

        if length(strAmount) > 80 then
        do:
        str1 = substring(strAmount,1,80).
        str2 = substring(strAmount,81,length(strAmount,"CHARACTER") - 80).
        put stream m-out unformatted str1 skip str2 skip(1).
        end.
        else  put stream m-out unformatted strAmount skip(1).
        /*------------------------------------------------------------------------------*/


        put stream m-out unformatted "---------------------------------------------------------------------------" skip(1).
        if joudoc.perkod <> "000000000000" then  put stream m-out unformatted "PHH               : " + joudoc.perkod skip(1).

        /* put stream m-out unformatted "Подпись : " skip(1).*/

        put stream m-out unformatted "Подпись вносителя :                                      Кассир  : " skip(1).

        put stream m-out unformatted "===========================================================================" skip.
        put stream m-out unformatted "Примечание : /" + arp + "/ Платежи " + suppname + "/#".

        put stream m-out unformatted "x1E" + payacc  + "x0F" skip.
        put stream m-out unformatted "===========================================================================" skip(1).

        end.
        /***********************************************************************************/
        put stream m-out  unformatted skip(1) chr(27) chr(64).
        output stream m-out close.

        unix silent prit pkso.tmp.
    end.
    if v-noord = yes then do:
        if type = 3 then do:
            output stream v-out to value(v-file).
            output stream v-out2 to value(v-file2).

            input from value(v-inputfile).
            repeat:
                import unformatted v-str.
                v-str = trim(v-str).
                put stream v-out unformatted v-str.
            end.
            input close.

            put stream v-out unformatted
                "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">" skip.
            put stream v-out unformatted
                "<TR><TD align=center><FONT size=3>КВИТАНЦИЯ</FONT></TD></TR>" skip
                "<TR><TD height=""30""></TD></TR>" skip
                "<TR><TD align=left><FONT size=2>" string(jh.jh) + "/" + joudoc.docnum + "/" + "Dok.Nr." + string(docno,"99999999") + "/" +
                trim(joudoc.num) + "/" + trim(ofc.name) +  "        " + string(joudoc.whn, "99/99/9999") "</FONT></TD></TR>" skip
                "<TR><TD align=left><FONT size=2>Платежи  " suppname "</FONT></TD></TR>" skip
                "<TR><TD align=left><FONT size=2>Лицевой счет  " payacc "</FONT></TD></TR>" skip
                "<TR><TD align=left><FONT size=2>Плательщик  " payname "</FONT></TD></TR>" skip
                "<TR><TD align=left><FONT size=2>Квитанция</FONT></TD></TR>" skip.
                if payname <> payaddr then put stream v-out unformatted
                    "<TR><TD align=left><FONT size=2>" payaddr "</FONT></TD></TR>" skip.
                else put stream v-out unformatted
                    "<TR><TD align=left><FONT size=2></FONT></TD></TR>" skip.
            put stream v-out unformatted
                "</TABLE>" skip.

            put stream v-out unformatted
                "<TABLE width=""100%"" bordercolor=""white"" border=""0"" cellspacing=""0"" cellpadding=""0"">" skip.

            put stream v-out unformatted
                "<TR><FONT size=2>" skip
                "<TD colspan=3>============================================================================================</TD>" skip
                "</FONT></TR>" skip
                "<TR><FONT size=2>" skip
                "<TD align=left>Наименование сервиса</TD>" skip
                "<TD width=15% align=center>к оплате</TD>" skip
                "<TD width=15% align=center>оплачиваю</TD>" skip
                "</FONT></TR>" skip
                "<TR><FONT size=2>" skip
                "<TD colspan=3>-----------------------------------------------------------------------------------------------
                ------------------------------------------------------------</TD>" skip
                "</FONT></TR>" skip.

            REPEAT y = 1 to ExData:Count:
                put stream v-out unformatted
                    "<TR><FONT size=2>" skip
                    "<TD align=left>" string(ExData:ElementBy(y):NamSub,"x(47)") "</TD>" skip
                    "<TD align=center>" string(ExData:ElementBy(y):ForPay,"z,zzz,zz9.99") "</TD>" skip
                    "<TD align=center>" string(ExData:ElementBy(y):Pay,"z,zzz,zz9.99") "</TD>" skip
                    "</FONT></TR>" skip.
            end.
            put stream v-out unformatted
                "<TR><FONT size=2>" skip
                "<TD colspan=3>-----------------------------------------------------------------------------------------------
                ------------------------------------------------------------</TD>" skip
                "</FONT></TR>" skip
                "<TR><FONT size=2>" skip
                "<TD colspan=3 align=right>Сумма платежа:          " string(summ,"z,zzz,zz9.99") "</TD>" skip
                "</FONT></TR>" skip
                "<TR><FONT size=2>" skip
                "<TD colspan=3 align=right>Комиссия банка:          " string(comm_summ,"z,zzz,zz9.99") "</TD>" skip
                "</FONT></TR>" skip
                "<TR><FONT size=2>" skip
                "<TD colspan=3 align=right>ИТОГО:          " string(summ + comm_summ,"z,zzz,zz9.99") "</TD>" skip
                "</FONT></TR>" skip
                "<TR><FONT size=2>" skip
                "<TD colspan=3>-----------------------------------------------------------------------------------------------
                ------------------------------------------------------------</TD>" skip
                "</FONT></TR>" skip.
            if length(strAmount) > 80 then do:
                put stream v-out unformatted
                    "<TR><FONT size=2>" skip
                    "<TD colspan=3 align=left>Сумма прописью:" str1 + "  " + str2 "</TD>" skip
                    "</FONT></TR>" skip.
            end.
            else do:
                put stream v-out unformatted
                    "<TR><FONT size=2>" skip
                    "<TD colspan=3 align=left>Сумма прописью:" strAmount "</TD>" skip
                    "</FONT></TR>" skip.
            end.
            put stream v-out unformatted
                "<TR><FONT size=2>" skip
                "<TD align=left>Подпись вносителя :</TD>" skip
                "<TD colspan=2 align=center>Кассир  :</TD>" skip
                "</FONT></TR>" skip
                "<TR><FONT size=2>" skip
                "<TD colspan=3>============================================================================================</TD>" skip
                "</FONT></TR>" skip.
            put stream v-out unformatted
                "</TABLE>" skip.

            {html-end.i " stream v-out "}

            output stream v-out close.

            input from value(v-file).
            repeat:
                import unformatted v-str.
                v-str = trim(v-str).
                repeat:
                    if v-str matches "*</body>*" then do:
                        v-str = replace(v-str,"</body>","").
                        next.
                    end.
                    if v-str matches "*</html>*" then do:
                        v-str = replace(v-str,"</html>","").
                        next.
                    end.
                    else v-str = trim(v-str).
                    leave.
                end.
                put stream v-out2 unformatted v-str skip.
            end.
            input close.
            output stream v-out2 close.

            unix silent cptwin value(v-file2) winword.

            unix silent value("rm Repttt1.htm").
            unix silent value("rm Repttt2.htm").
        end.
    end.
end method.
/***************************************************************************************************/
 /*Печать клише на счете извещении */
 method public void PrintCLS():
     if jh = ? then do: /* message "Нет проводки для документа!"  skip "Печать клише невозможна" view-as alert-box.*/ return. end.
     def var v-text as char.
     def var dl as char init "\t".
     output stream m-out to clsh.tmp.

      /*чтобы печатался сжатый файл. типа междустрочный интервал - минимальный.*/
       put stream m-out unformatted chr(27) chr(64) chr(27) 'P' chr(27) 's0' chr(27) chr(15) chr(27) chr(48) chr(27) chr(120) '0' chr(10).
       v-text = b-name. /*"АО 'МЕТРОКОМБАНК' г.Павлодар" .*/
       put stream m-out unformatted  v-text + dl + v-text skip.
       v-text = b-addr. /*"СПФ-2 На Айманова */
       put stream m-out unformatted  v-text + dl + v-text skip.
       v-text = "Касса(" + who_cr + ")              ".
       put stream m-out unformatted  v-text + dl + v-text skip.
       /*
       v-text = "Кассир:" + ofcname .
       put stream m-out unformatted  v-text + dl + v-text skip.
       */
       v-text = string(whn_cr) + ", " + string(time_cr,"HH:MM:SS") + "           ".
       put stream m-out unformatted  v-text + dl + v-text skip.
       /*v-text = "Док.:N" + string(jh,"999999") + "            ". */
       v-text = "Док.:N" + string(docno,"99999999") + "          ".
       put stream m-out unformatted  v-text + dl + v-text skip.
       v-text = "т/с : " +    arp + "               ".
       put stream m-out unformatted  v-text + dl + v-text skip.
       v-text = "л/с : " + payacc + "               ".
       put stream m-out unformatted  v-text + dl + v-text skip.
       if v-bin then v-text = "ИИН: " + payiin + "          ".
       else v-text = "РНН: " + payrnn + "          ".
       put stream m-out unformatted  v-text + dl + v-text skip.
       v-text = "Сумма   : " + string(summ,"99999999.99") + " тенге".
       put stream m-out unformatted  v-text + dl + v-text skip.
       v-text = "Комиссия: " + string(comm_summ,"99999999.99") + " тенге".
       put stream m-out unformatted  v-text + dl + v-text skip.
       v-text = "КНП " + knp + "                   ".
       put stream m-out unformatted  v-text + dl + v-text skip.

       put stream m-out unformatted chr(27) chr(64).

   output stream m-out close.

  unix silent prit clsh.tmp.

 end method.
/***************************************************************************************************/
method public log AddStr(input p-add as char):
    if p-add ne '' then payacc = p-add + ";" + payacc.
    return true.
end method.
/***************************************************************************************************/

END CLASS. /* COMPAYDOCClass*/

