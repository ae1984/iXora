/* rtzcon.p
 * MODULE
        Платежная система
 * DESCRIPTION
        Контроль исходящих платежей в KZT
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        5.3.4
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        16.01.2002 sasco   - для счета 150904507 (т.е. sts='baa') не пускать без контроля
        17.05.2001         - добавлен контроль счета получателя по полю remtrz.ba
                           - если платеж налоговый, то проверяется КБК
        21.11.2001 sasco   - добавлена проверка на статус bac, bap из-за контроля
                             в 2.7 для больших сумм
        02.05.2002         - пошаговый набор
                             контроль  РНН
                             номер пачки
       30.10.2002 nadejda  - наименование клиента заменено на форма собств + наименование
       04.11.2003 nadejda  - закомментарила проверку на пункт, у нас все равно только один пункт и используются
                             разделение по филиалам и департаментам
                             проверяем только на тенговую исходящую очередь - P, PRR и т.п.

        04/06/04 valery если в codfr.name[2] (по департаменту) указать через запятую код других департаментов, то текущий департамент сможет контролировать только эти департаменты, и другие деп. не могут контролировать указанные департаменты
                        если в codfr.name[2] ни чего не указано, то можно контролировать любой другой департамент.
        21/09/04 dpuchkov  - добавил вторичный контроль если резидент 2
        18/11/04 suchkov   - добавлена обработка отсканированных платежей
        27/04/05 saltanat  - изменила имя переменной для Код БК-а с v-kbk на v-kbud, для вывода на экран справочника.
        25.05.05 nataly    - добавила проверку на дублирование платежей с одинаковыми реквизитами
        17.06.05 suchkov   - добавил контроль КНП и КБЕ
        23.11.05 suсhkov   - Детали платежа 412 символов
        21/02/06 marinav -   Дополнительный контроль по РНН
        19/05/06 suchkov   - сделано исключение для контроля сканированых платежей
        31/07/2007 madiyar - убрал упоминание удаленной таблицы sta
        30/06/08 marinav - изменила ссылки на пункты для контроля
        06/10/2008 galina - добавила валютный контроль платежей нерезидента;
                            валютный контроль платежей нерезидента в каждом филиале свой
        20.04.2009 galina - валютный конроль по субботам не включать
        03.12.2010 evseev - запрет контроля свои же созданых платежей
        25.01.2011 marinav - изменения в связи с переходом на БИН/ИИН
        24.05.2011 ruslan - изменил help для v-rmz
        06/10/2011 Luiza  - добавила проверку акцепта кассира на поступление денег на арп счет.
        15/08/2012 id00810 - заполнение таблицы pcpay для платежей по пополнению счетов по ПК
*/

{comm-txb.i}
{chk12_innbin.i}
def new shared var s-remtrz like remtrz.remtrz .
def new shared var s-amt like remtrz.amt .
def new shared var s-sta as char format "x(2)" label "State".
def var v-rbank like remtrz.rbank .
def var vasa as char no-undo.
def var sava as char no-undo.
def var v-brem2 like remtrz.remtrz no-undo.
def var mam like remtrz.payment no-undo.
def var v-ans as log format "Да/Нет" no-undo.
def var v-actinsact like remtrz.actinsact no-undo.
def var v-valdt like remtrz.valdt1 no-undo.
def var v-weekbeg as int no-undo.
def var v-weekend as int no-undo.
def var s-target as date no-undo.
def var acode like crc.code no-undo.
def var bcode like crc.code no-undo.
def var v-kods like crc.crc no-undo.
def var v-cover like remtrz.cover no-undo. /* by Alex */
def var b-aaa like aaa.aaa no-undo.
def var b-cif like cif.cif no-undo.
def var b-name like cif.name no-undo.
def var b-name1 like cif.name no-undo.
def var b-crc like crc.code no-undo.
def var c-aaa like aaa.aaa no-undo.
def var c-cif like cif.cif no-undo.
def var c-name like cif.name no-undo.
def var c-code like crc.code no-undo.
define variable vknp as character no-undo.
define variable vkbe as character no-undo.
def var v-comgl as inte no-undo.
def var comdes as char no-undo.
def var vovo as char no-undo.
def var branch like sysc.chval no-undo.
def var ourbank like sysc.chval no-undo.
def new shared var s-date as date no-undo.
def new shared var s-dstr as cha format "x(20)".
def new shared var F52-L as char format "x(1)" .    /* ordering institution*/
def new shared var F53-L as char format "x(1)" .    /* sender's corr.      */
def new shared var F54-L as char format "x(1)" .    /* sender's corr.      */
def new shared var F56-L as char format "x(1)" .    /*intermediary.  */
def new shared var F57-L as char format "x(1)" .    /*account with inst.   */
def new shared var realbic as char format "x(12)" . /* real bic code    */
def var v-t1 as int no-undo.
def var v-rmz as char no-undo.
def var v-nst like sysc.chval no-undo.
def var ben1 as char no-undo.
def var ben2 as char no-undo.
def var ben3 as char no-undo.
def var ben4 as char no-undo.
def var v-cashgl as integer no-undo.
def var v-sacc like remtrz.sacc no-undo.
def var v-racc like remtrz.racc no-undo.
def var v-kbud  as char no-undo.
def var v-kbk1 as char no-undo.
def var v-rnn as char no-undo.
def var v-rnn-out as char no-undo.
def var v-info as char no-undo.
define variable v-detpay as character no-undo.
def buffer b-remtrz for remtrz.

/* для использования BIN */
def var v-mesout as char.
def var v-mes as char.
{chbin.i}
if v-bin = no then do:
   v-mesout = "Некорректный РНН плательщика!".
   v-mes    = "Некорректный РНН получателя!" .
end.
else do:
   v-mesout = "Некорректный БИН/ИИН плательщика!".
   v-mes    = "Некорректный БИН/ИИН получателя!" .
end.



  find first sysc where sysc.sysc = "RMCASH" no-lock no-error .
   if not avail sysc then do:
     message "Отсутствует запись RMCASH в таблице SYSC!" .
     return.
   end  .
  v-cashgl = sysc.inval .

  find sysc where sysc.sysc = 'LBNSTR' no-lock  no-error.
  if avail sysc then v-nst = sysc.chval.
  else do:
   message 'Отсутствует запись LBNSTR в таблице SYSC!'.
   pause 3.
   return.
   end.


  find sysc where sysc.sysc = "ourbnk" no-lock no-error .
  if not avail sysc or sysc.chval = "" then do:
   message " There isn't record OURBNK in sysc file !! " view-as alert-box.
   return .
  end.
  ourbank = sysc.chval.


    display "Номер партии документов " with no-label row 3 centered frame rrr.
    update v-info with frame rrr.

{lgps.i "new"}
m_pid = "P" .
u_pid = "rtzcon".

{mainhead.i }
{contrz.f}


/***********04/06/04**valery***********************************************************************************************************************************************/
def var depwho1 as char. /*кто штампует*/
def var depwho2 as char. /*кого штампует*/
def var f3 as logical init false.
def var jhrem like jh.jh.
function chk-gosacc returns logical (p-val1 as char).

/* Luiza ----для тех платежей у которыx  retrz.jh3 > 0 -------------------------------------------*/
    find remtrz where remtrz.remtrz = p-val1 no-lock no-error.
    if avail remtrz then do:
        if remtrz.jh3 > 0 then do:
            find last jl where jl.jh = remtrz.jh3 no-lock no-error.
            if not avail jl then do:
                message "Проводка поступления денег на арп счет не найдена! ~n№ транзакции "  + string(remtrz.jh3) view-as alert-box.
                return false.
            end.
            if jl.sts <> 6 then do:
                message "Проводка поступления денег на арп счет не акцептована кассиром! ~n№ транзакции "  + string(remtrz.jh3) view-as alert-box.
                return false.
            end.
        end.
    end.
    else do :
        message "Платеж с таким номером отсутствует!".
        pause 3.
        return false.
     end.
/*--------------------------------------------------------------------------------*/
        /*---------------------------------------------------------------------------------------*/
        find remtrz where remtrz.remtrz = p-val1 no-lock no-error.
        if avail remtrz then
        do:
                find last jl where jl.jh = remtrz.jh1 no-lock no-error.
                if avail jl then jhrem = remtrz.jh1.
                else do:
                        message "Не сформирована 1-ая проводка, платеж: " p-val1.
                        pause 2.
                        return false.
                     end.
                /*евсеев 03/12/2010*/
                if remtrz.rwho = g-ofc then do:
                        message g-ofc "не может контролировать свои платежи".
                        pause 10.
                        return false.
                end.
                /*евсеев*/

        end.
        else do :
                message "Платеж с таким номером отсутствует!".
                pause 2.
                return false.
             end.
        /*---------------------------------------------------------------------------------------*/

        /*---------------------------------------------------------------------------------------*/
        f3 = true. /*по умолчанию контроль разрешен*/
        /*---------------------------------------------------------------------------------------*/

        /*---------------------------------------------------------------------------------------*/
                find gl where gl.gl = remtrz.drgl and gl.sub = 'CIF' no-lock no-error.
        if not avail gl then
        do:
            return true.
        end.
        /*---------------------------------------------------------------------------------------*/

        /*---------------------------------------------------------------------------------------*/
        find ofc where ofc = remtrz.rwho no-lock no-error. /*находи код департамента того, кого контролируем*/
        if avail ofc then depwho2 = ofc.titcd. /*сохраняем код деп. контролируемого*/
        else do: message "Офицер (" remtrz.rwho ") контролируемого документа не найден в базе данных!". pause 10. undo, retry. end.
        /*---------------------------------------------------------------------------------------*/

        /*--если по кредиту указан клиентский счет, то проверяем контролирует ли его конкретный деп-нт или нет--*/
        /*---------------------------------------------------------------------------------------*/
        find ofc where ofc = g-ofc no-lock no-error. /*находим код департамента контролирующего*/
        if avail ofc then depwho1 = ofc.titcd. /*сохраняем код деп. контролирующего*/
        /*---------------------------------------------------------------------------------------*/


        /*---------------------------------------------------------------------------------------*/
        for each codfr where codfr.codfr = 'sproftcn' and codfr.code <> 'msc' no-lock.
                if codfr.name[2] <> '' then do: /*ищем все записи, у которых в поле name[2] прописаны подконтрольные департаменты*/
                        if lookup(depwho2,codfr.name[2]) > 0  then do: /*контролируемый деп-т входит в их число*/
                                if codfr.code = depwho1 then /* и является ли текущий деп-т, деп-ом контролируемого?*/
                                        return true.    /*если условия совпадают то разрешаем контроль*/
                                else f3 = false. /*если контролирующий не принадлежит департаменту, которому разрешено контролировать то ругаемся :)*/
                        end.
                end.
        end.
        /*---------------------------------------------------------------------------------------*/

        if not f3 then do:
                        find codfr where codfr.codfr = 'sproftcn' and codfr.code matches depwho2 and codfr.code <> 'msc' no-lock .
                        message "Вы не можете штамповать документы " codfr.name[1]. pause 10. return false.
        end.
        else return true.

end.
/**********04/06/04*********************************************************************************************************************************************************/


/*v-brem2 = "".
v-rmz = ''.*/
m1: repeat :
b-aaa = ''.
b-cif = ''.
DEFINE VARIABLE v-rmzz AS char.
define frame rrr1
   v-rmz label "Платеж " format "x(10)"
with side-labels centered row 3.
DEFINE VARIABLE phand AS handle.

   on help of v-rmz in frame rrr1 do:
    v-rmzz = "".
    run h-rmz222 PERSISTENT SET phand.
    v-rmzz = frame-value.
    if trim(v-rmzz) <> "" then do:
        find first remtrz where remtrz.remtrz = v-rmzz no-lock no-error.
        if available remtrz then do:
            v-rmz = remtrz.remtrz.
        end.
        else do:
            v-rmz = "".
            MESSAGE "Платеж не найден.".
        end.
        displ  v-rmz with frame rrr1.
    end.
    DELETE PROCEDURE phand.
end.

   message "F2 - помощь ".

   update v-rmz validate(chk-gosacc(v-rmz),'') with frame rrr1.  /*********04/06/04 valery*****************/
   v-brem2 = v-rmz.

/*---------------------------- 20.11.2001, sasco ----------------------->>> */


/*  ------------- suchkov - проставление типа платежей со сканера -------------------
    ------------- Этот блок вынесен в отдельную p-шку, чтобы не лочило всех --------- */
/*        run scan_update (v-rmz).
    --------------- А так как это не помогло, 11.04.2005 бло был перенесен в putrmz.p ------------- */

      find remtrz where remtrz.remtrz = v-rmz no-lock .
      if remtrz.source = "SCN" then message "Внимание! Платеж получен с помощью сканера!" view-as alert-box.
/*
          if remtrz.sbank = ourbank and remtrz.scbank = ourbank and not remtrz.rbank begins "TXB" then remtrz.ptype = "6".
                                                                                                  else remtrz.ptype = "4".
          find que where que.remtrz = remtrz.remtrz exclusive-lock .
          que.ptype = remtrz.ptype.

          find sysc where sysc.sysc = "clrscn" no-lock no-error .
          if not available sysc then message "Не настроено время перехода на гросс!" view-as alert-box.
          if time >= sysc.inval then remtrz.cover = 2.

          release que.
      end.
      release remtrz.

      find first remtrz where remtrz.remtrz = v-rmz no-lock .
      find que where que.remtrz = remtrz.remtrz no-lock .

*/
/*29.10.2008 galina надо убрать проверку на ЦО при окончание тестирования или нет?*/
       if g-today = today then do:
              find first sub-cod where sub-cod.acc = remtrz.remtrz and sub-cod.sub = "rmz" and sub-cod.d-cod = "eknp" use-index dcod no-lock no-error .
              if avail sub-cod then do:
               /*find last rmzkbe where rmzkbe.remtrz = remtrz.remtrz exclusive-lock no-error.  */
                 if /*((avail rmzkbe and rmzkbe.sta = False) or not avail rmzkbe)*/ remtrz.vcact = "" and (remtrz.fcrc = 1 and (substr(sub-cod.rcode, 4, 1) = "2" or substr(sub-cod.rcode, 1, 1) = "2")) then
                 do:

                      find cursts where cursts.acc = v-rmz and cursts.sub = "rmz" no-lock no-error.
                      if avail cursts then
                      do:
                        if cursts.sts = "bac" or cursts.sts = "bap" then do:
                          /*message "Документ должен проконтролировать старший менеджер (в 2.4.1.1 и 2.4.1.2)". */
                          message "Документ должен проконтролировать валютный контроль (в 9.11) ~n" + "и старший менеджер (в 2.4.1.1)".
                          pause 7.
                          undo.
                        end.
                      end.

                      /*Message "Документ должен пройти контроль в 2.4.1.2!". pause .*/
                      message "Документ должен проконтролировать валютный контроль (в 9.11)".
                      undo.
                 end.
              end.

      end.


                find cursts where cursts.acc = v-rmz and cursts.sub = "rmz"
                     no-lock no-error.
                if avail cursts then
                do:
                  if cursts.sts = "bac" or cursts.sts = "bap" then do:
                    message "Документ должен проконтролировать старший менеджер (в 2.4.1.1)".
                    pause 7.
                    undo.
                  end.

 /*---------------------------- 16.01.2002, sasco ----------------------->>> */

                  if cursts.sts = "baa" then do:
                    message "Документ должен пройти контроль (в 5.3.10)!".
                    pause 7.
                    undo.
                  end.
  /*---------------------------- 16.01.2002, sasco -----------------------<<< */

                end.
/* <<<<<---------------------- 20.11.2001        -------------------------- */
     repeat:

            mam = 0.
            form " СУММА      : " mam
                 " ТРАНСПОРТ  : " v-cover /* by Alex */
              /* " ВАЛЮТА     : " v-kods */ /* by Alex */
            with no-label row 6 centered frame mmm.
            update mam v-cover /* v-kods */ with frame mmm.

            s-remtrz = v-brem2.
            find remtrz where remtrz.remtrz eq v-brem2 and remtrz.payment eq mam and remtrz.cover = v-cover no-lock no-error.

              if not available remtrz then do:
              message "Платеж с такой суммой и транспортом отсутствует!".
              pause 2.
              undo, retry.
              end.
              if available remtrz then leave.
      end.

      if keyfunction(lastkey) = "end-error" then next m1.

      if available remtrz then do:

/* suchkov - Контроль КНП и КБЕ */
         if remtrz.source <> "SCN" then do:
            find sub-cod where sub-cod.sub = "RMZ" and d-cod = "eknp" and sub-cod.acc = remtrz.remtrz no-lock no-error .
            if not available sub-cod then do:
                    message "Не заполнен ЕКНП!".
                    pause 2.
                    undo, retry.
            end.
            update "КБЕ: " vkbe format "x(2)"
                   "КНП: " vknp format "x(3)"
               with no-label row 9 centered .
            if vkbe <> substring(sub-cod.rcod,4,2) then do:
                    message "Некорректный КБЕ!".
                    pause 2.
                    undo, retry.
            end.
            if vknp <> substring(sub-cod.rcod,7,3) then do:
                    message "Некорректный КНП!".
                    pause 2.
                    undo, retry.
            end.
         end.
/* suchkov - конец контроля КНП и КБЕ */

                v-sacc = "".
                v-racc = "".
                v-rnn-out = "".
/*iban */
  /*БИН*/
               form  v-sacc format 'x(20)'    label " Счет плательщика " skip
                     v-racc format 'x(20)'    label " Счет получателя  "
               with side-label row 12 col 10 frame rbb.

               form  v-rnn-out format 'x(12)' label " РНН плательщика  "  skip
                     v-rnn format 'x(12)'     label " РНН получателя   "
               with side-label row 12 col 60 width 110  overlay frame rbbr.

               form  v-rnn-out format 'x(12)' label " БИН/ИИН плательщика  "  validate((chk12_innbin(v-rnn-out)),'Неправильно введён БИН/ИИН') skip
                     v-rnn format 'x(12)'     label " БИН/ИИН получателя   " validate((chk12_innbin(v-rnn)),'Неправильно введён БИН/ИИН')
               with side-label row 12 col 60 width 110 overlay frame rbbb.

            if remtrz.sacc ne "" and remtrz.source <> "SCN" then do :
              repeat:
                update v-sacc with frame rbb.
                if trim(remtrz.sacc) ne trim(v-sacc) then do:
                  message "Некорректный счет плательщика!" .
                  pause 3 .
                  undo .
                end.
                else leave.
              end.
              if keyfunction(lastkey) = "end-error" then next m1.
            end.

             if remtrz.racc ne "" or remtrz.ba ne "" then do :
             repeat:
                if remtrz.source = "SCN" then leave .
                update v-racc with frame rbb.

                if remtrz.racc ne "" then do.
                   if trim(remtrz.racc) ne trim(v-racc)
                   then do.
                          message "Некорректный счет получателя!" .
                          pause 3 .
                          undo .
                   end.
                end.
                else do.
/*ja 08/07/2001 */
                  if remtrz.cover = 4 then do:
                   if substr(remtrz.ba,2) <> trim(v-racc) then do:
                          message "Некорректный счет получателя!" .
                          pause 3 .
                          undo .
                   end.
                  end.
/* ja */
                  else do:
                   if (remtrz.ba  ne "" and substr(remtrz.ba,1,20) ne trim(v-racc))
                     then do:
                          message "Некорректный счет получателя!" .
                          pause 3 .
                          undo .
                     end.
                  end.
                end.
              leave.
             end.
         if keyfunction(lastkey) = "end-error" then next m1.

/* 21/02/2006 marinav - проверка на РНН плательщика */
  /*БИН*/
            if index(remtrz.ord,"/RNN/") ne 0 then do:
              repeat:
                if remtrz.source = "SCN" then leave .
                if v-bin = no then update v-rnn-out with frame rbbr.
                              else update v-rnn-out with frame rbbb.
                if trim(substr(remtrz.ord, index(remtrz.ord,"/RNN/") + 5, 12)) ne trim(v-rnn-out) then do:
                  message v-mesout .
                  pause 3 .
                  undo .
                end.
                else leave.
              end.
              if keyfunction(lastkey) = "end-error" then next m1.
            end.
/* 21/02/06 marinav */
        /*marinav*/
  /*БИН*/

         if index(remtrz.bn[3],"/RNN/") <> 0 and remtrz.source <> "SCN" then do:
                repeat:
                   if v-bin = no then update v-rnn with frame rbbr.
                                 else update v-rnn with frame rbbb.
                   if substring(remtrz.bn[3],index(remtrz.bn[3],"/RNN/") + 5, 12) <> v-rnn then do :
                          message v-mes.
                          pause 3 .
                          undo .
                   end .
                   else leave.
                end.
             if keyfunction(lastkey) = "end-error" then next m1.
         end.

/*marinav*/

         if index(remtrz.rcvinfo[1],"/TAX/") <> 0 and remtrz.source <> "SCN" then do.
                repeat:
                 form  v-kbud format 'x(6)'    label " Код БК           "
                 with side-label row 19 centered frame rbb2.
                 update v-kbud with frame rbb2.
                 v-kbk1 = trim(remtrz.ba) .
                 if substr(v-kbk1,1,1) = "/" then
                    v-kbk1 = trim(substr(v-kbk1,2)).
                 if index(v-kbk1,"/") ne 0 then do.
                    v-kbk1 = substr(v-kbk1,index(v-kbk1,"/") + 1,6) .
                    if v-kbud ne v-kbk1 then do.
                       message "Некорректный код БК!" .
                       pause 3 .
                       undo .
                    end.
                    else leave.
                 end.
                end.
               if keyfunction(lastkey) = "end-error" then next m1.
              end.
        end.
         find first sysc where sysc.sysc = "lbnstr" no-lock no-error .
                if not avail sysc then do :
                 message "Отсутствует запись LBNSTR в таблице SYSC!" .
                 pause 3 .
                 undo .
                end .
         if remtrz.cracc = sysc.chval and remtrz.source <> "SCN" then do :
               repeat:
                 update " БАНК ПОЛУЧАТЕЛЬ : " v-rbank
                    validate(length(v-rbank) = 8 or (v-rbank begins "TXB"),
                     "Введите МФО полностью или код банка-участника!")
                    with no-label row 16 centered frame rbb1.

                 /* проверка на 3 последних цифры
                 find first bankl where substr(bankl.bank,7,3) = v-rbank no-lock no-error.
                  if avail bankl and v-rbank <> "190" then
                  v-rbank = bankl.bank .*/

                 if remtrz.rbank <> v-rbank then do :
                    message "Некорректный банк получателя!" .
                    pause 3 .
                    undo .
                 end .
                 else leave.
               end.
             if keyfunction(lastkey) = "end-error" then next m1.
         end .

                if remtrz.jh1 eq ? then do:
                    message "Отсутствует проводка!".
                    pause 3.
                    undo.
                end.
                else do:
                 find jh where jh.jh eq remtrz.jh1 no-lock.
                 if jh.sts ne 6 then do:
                    message "Проводка не акцептованна!".
                    pause 3.
                    undo.
                 end.
                 else do :
                  if remtrz.drgl = v-cashgl then do :
                    find first jl where jl.jh = jh.jh no-lock.
                    v-text = "1-ую проводку акцептовал " + jl.teller + " для " + remtrz.remtrz .
                    run lgps.
                  end.

           find aaa where aaa.aaa = remtrz.cracc no-lock  no-error.
           if  avail aaa then  do:
               if aaa.crc ne remtrz.tcrc then do:
                 message "Валюта LORO счета не совпадает с валютой платежа!".
                 pause 3.
                 undo.
               end.
           end.

          else do:
          find dfb where dfb.dfb = remtrz.cracc no-lock  no-error.
             if  avail dfb then  do:
               if dfb.crc ne remtrz.tcrc then
               do:
                message "Валюта NOSTRO счета не совпадает с валютой платежа!".
                pause 3.
                undo.
               end.

             end.
          end.
           hide message.

      find first que where que.remtrz = remtrz.remtrz no-lock no-error .
       if avail que then do:
       if ( que.con ne "W" or que.pid ne  m_pid  ) and m_pid ne "PS_"
         then do:
         Message "Невозможно обработать!" . pause .
         return.
         end.
       end.

                disp remtrz.remtrz
                    with overlay frame rembo.
                    color disp messages remtrz.remtrz with overlay frame rembo.
                disp remtrz.ordins[1] with overlay frame rembo.
                    color disp messages remtrz.ordins[1] with overlay frame rembo.                 /* no konta */
                if remtrz.dracc ne "" then do:
                    find aaa where aaa.aaa eq remtrz.dracc no-lock no-error.
                        if available aaa then do:
                            b-aaa = aaa.aaa.
                            b-cif = aaa.cif.
                        end.
                  /*  find cif where cif.cif eq b-cif no-lock no-error.
                        if available cif then b-name = trim(trim(cif.prefix) + " " + trim(cif.name)). */
                end.
                b-name = substr(remtrz.ord,1,41).
                b-name1 = substr(remtrz.ord,42).
                ben1 = remtrz.ben[1] + ' '  + remtrz.ben[2] + ' ' + remtrz.ben[3] + ' ' + remtrz.ben[4].

                ben2 = substr(ben1,36,35).
                ben3 = substr(ben1,71,35).
                ben4 = substr(ben1,106,35).
                ben1 = substr(ben1,1,35).
                disp b-aaa b-cif b-name b-name1 remtrz.rbank remtrz.rcbank with overlay frame rembo.
                    color disp messages b-aaa b-cif b-name b-name1
                    remtrz.rbank remtrz.rcbank with overlay frame rembo.
                disp remtrz.actins remtrz.ba
                    with overlay frame rembo.
                    color disp messages remtrz.actins  remtrz.ba
                    with overlay frame rembo.
                disp ben1 ben2 ben3 ben4
                    with overlay frame rembo.
                    color disp messages ben1 ben2
                    ben3 ben4 with overlay
                    frame rembo.

                message "Нажмите пробел для просмотра деталей платежа" .
                v-detpay = remtrz.detpay[1] + remtrz.detpay[2] + remtrz.detpay[3] + remtrz.detpay[4] .
                pause .
                display v-detpay VIEW-AS EDITOR SIZE 70 BY 8 with no-label overlay top-only centered title "Назначение платежа" frame adsd .
                color display messages v-detpay VIEW-AS EDITOR SIZE 70 BY 8 with no-label overlay top-only centered title "Назначение платежа" frame adsd .
                pause .
                hide frame adad .
/*                disp remtrz.detpay[1] remtrz.detpay[2]
                    remtrz.detpay[3] remtrz.detpay[4]
                    with overlay frame rembo.
                    color disp messages remtrz.detpay[1] remtrz.detpay[2]
                    remtrz.detpay[3] remtrz.detpay[4] with overlay frame rembo. */

                disp remtrz.payment with overlay frame rembo.
                    color disp messages remtrz.payment with overlay frame rembo.
                find crc where crc.crc eq remtrz.tcrc no-lock no-error.
                    if available crc then b-crc = crc.code.
                disp b-crc remtrz.jh1 remtrz.valdt2 with overlay frame rembo.
                    color disp messages b-crc remtrz.jh1 remtrz.valdt2
                    with overlay frame rembo.

                  v-comgl = remtrz.drgl.
                  find gl where gl.gl = v-comgl no-lock no-error.
                  if available gl then comdes = gl.des.
                  disp v-comgl comdes with overlay frame rembo.
                  color disp messages v-comgl comdes with overlay frame rembo.

                if remtrz.svcaaa ne "" then do:
                    find aaa where aaa.aaa eq remtrz.svcaaa no-lock no-error.
                        if available aaa then do:
                            c-aaa = aaa.aaa.
                            c-cif = aaa.cif.
                        end.
                    find cif where cif.cif eq c-cif no-lock no-error.
                        if available cif then
                           c-name = trim(trim(cif.prefix) + " " + trim(cif.name)).
                end.
                find crc where crc.crc = remtrz.svcrc no-lock no-error.
                if avail crc then c-code = crc.code.
                disp remtrz.svca c-code c-aaa c-cif c-name
                    with overlay frame rembo.
                color disp messages remtrz.svca c-code c-aaa c-cif c-name
                    with overlay frame rembo.
                    end.
                end.
            end. /*repeat*/

/*********************/
/* 04.11.2003 nadejda - закомментарила проверку на пункт, у нас все равно только один пункт и используются
                        разделение по филиалам и департаментам
              проверяем только на тенговую исходящую очередь - P, PRR и т.п.

            find ofc where ofc.ofc eq g-ofc no-lock.
            sava = string(integer(truncate(ofc.regno / 1000 , 0)),"9999").
            if not (remtrz.source begins ("P" + substr(sava,3,2))) then do:
*/
            if not remtrz.source begins "P" and remtrz.source <> "SCN" then do: /* suchkov - Добавил обработку SCN */
                Message "Вы не офицер этого пункта!".
                pause .
                return.
            end.
    v-t1 = time.


    if remtrz.valdt2 ne ? and remtrz.cracc ne ""  then do:
             if  remtrz.tcrc = 1 then do:
        if not(  (remtrz.ord ne "")  and
        (remtrz.actinsact ne "")  and
        (remtrz.actins[1] ne "" or
        remtrz.actins[2] ne "" or
        remtrz.actins[3] ne "" or
        remtrz.actins[4] ne "")
         and
        (remtrz.detpay[1] ne "" or
        remtrz.detpay[2] ne "" or
        remtrz.detpay[3] ne "" or
        remtrz.detpay[4] ne "" ))
            then do:
            message "Неполная информация.".
            pause 10.
            undo.
            end.
        end.
        else do:
        if not(  (remtrz.ord ne "")  and
        (remtrz.actins[1] ne "" or
        remtrz.actins[2] ne "" or
        remtrz.actins[3] ne "" or
        remtrz.actins[4] ne "")
         and
        (remtrz.detpay[1] ne "" or
        remtrz.detpay[2] ne "" or
        remtrz.detpay[3] ne "" or
        remtrz.detpay[4] ne "" ))
          then do:
            message "Неполная информация.".
            pause 10.
            undo.
            end.
        end.
    end.
        if ( remtrz.rbank ne "" or remtrz.rcbank ne "" )
           and (remtrz.crgl = 0 or remtrz.cracc = "" or remtrz.valdt2 = ? )
          then do:
            message "Неполная информация.".
            pause 10.
            undo.
         end.

               /*25.05.05 nataly */
    find first b-remtrz where b-remtrz.rdt = remtrz.rdt and substr(b-remtrz.sqn,19) =  substr(remtrz.sqn,19)
    and b-remtrz.sacc = remtrz.sacc  and b-remtrz.racc = remtrz.racc  and b-remtrz.rbank = remtrz.rbank
    and substr(remtrz.BEN[1],INDEX(remtrz.BEN[1],"/RNN/") + 5) =  substr(b-remtrz.BEN[1],INDEX(b-remtrz.BEN[1],"/RNN/") + 5)
    and b-remtrz.payment = remtrz.payment and b-remtrz.remtrz <> remtrz.remtrz no-lock no-error.
     if avail b-remtrz then do:
        message 'Такой платеж  уже существует, проконтролировать платеж?' view-as alert-box
          question buttons yes-no update v-ans.
      if not v-ans then do:
       hide frame rbb.
       hide frame rbb1.
       hide frame rbb2.
       undo.
     end.
    end.
               /*25.05.05 nataly */

    v-ans = no.
    {mesg.i 0943} update v-ans.
    if not v-ans then undo .
    if v-ans then do:
       v-text  = remtrz.remtrz + ' проверил ' + g-ofc + ' для пункта ' + substr(remtrz.ref,1,6).
       run lgps.
       do transaction:
       find current remtrz exclusive-lock.
       remtrz.cwho = g-ofc.
       remtrz.info[5] = v-info.
       find current remtrz no-lock.
       if remtrz.rcvinfo[1] = '/PC/' then do:
        find first pcpay where pcpay.ref = remtrz.remtrz no-lock no-error.
        if not avail pcpay then do:
            create pcpay.
            assign pcpay.bank = remtrz.rbank
                   pcpay.aaa  = remtrz.ben[2]
                   pcpay.crc  = remtrz.fcrc
                   pcpay.amt  = remtrz.amt
                   pcpay.ref  = remtrz.remtrz
                   pcpay.jh   = remtrz.jh1
                   pcpay.sts  = 'new'
                   pcpay.who  = g-ofc
                   pcpay.whn  = g-today.
        end.
       end.
       find first que where  que.remtrz  = remtrz.remtrz
                      exclusive-lock no-error.
       if avail que then do:
          if remtrz.cracc = v-nst  then que.rcod = '0'.
          else que.rcod = '1'.
          que.pid  = 'P'.
          que.dp = today.
          que.tp = time.
          que.con = 'F'.
          release que.
       end.

       end.
    end.
end.

