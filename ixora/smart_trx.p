/* smart_trx.p
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
        30/03/2011 id00205 работа с SmartSafe
 * CHANGES
        20/07/2012 k.gitalov Расширенная информация в лог файл
        22/08/2012 Luiza закомментировала сообщение "Работать с миникассой с валютой " GetCRC(p-crc) " запрещено!"
	    26/09/2012 id00700 Перекомпиляция
        04/10/2012 k.gitalov добавил транзакционные блоки при сохранении данных
        10/12/2012 k.gitalov - изменения по ТЗ 1603

*/

{system.i}
{cm18_abs.i}
{cm18.i "new"}

def input param p-ofc as char.                         /* ID офицера */
def input param p-trx as int.                          /* номер транзакции */
def input param p-type as int.                         /* тип операции 0 - текущий баланс 1 - состояние сейфа 2 - пересчет 3 - выдача 4 - прием 10 - инкассация*/
def input param p-crc as int.                          /* валюта операции */
def input param p-summ as deci.                        /* сумма операции */
def output param p-dispensedAmt as deci.               /* Сумма операции по миникассе*/
def output param p-acceptedAmt as deci.                /* Сумма операции по сейфу*/
def input-output param v-Amount as decimal extent 10.  /* Текущий баланс сейфа, или суммы операций при многовалютных операциях по всем валютам*/
def output param p-rez as log.                         /* результат выполнения */


def var v-recid as int.
def var v-safe as char.
def var v-side as char.
def var rez as log.
def var ClientIP as char.
def var Install as log.
def var R-Data as char.
def var tmp_val as deci extent 4.
def var tmp_mess as char init "".
def var tmp_oper_type as int.
def var i_pos as int.
def new shared var SafeFault as log.
def new shared var OperSumm as deci.
def new shared var AcceptSumm as deci.
def var v-point as int.
def var choice as log.
define variable v-mess as character.
OperSumm = p-summ.

p-dispensedAmt = 0.
p-acceptedAmt = 0.
p-rez = false.
SafeFault = false.

def var s-ourbank as char no-undo.
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
end.
s-ourbank = trim(sysc.chval).

if ClientIP = "" then do:
  input through askhost.
  import ClientIP.
  input close.
end.
run CheckConfig(input p-ofc,input ClientIP,output v-safe, output v-side,output Install, output rez).
if not rez then return.

/**************************************************************************************************************/
if not IsServiceExist(ClientIP,"2012") or Install = true then do:
  run ServiceStart( ClientIP ,"CASHBOXTools","cashboxsvr.exe").
  do transaction:
      find first comm.cslist where comm.cslist.nomer = v-safe exclusive-lock no-error.
      if avail comm.cslist then do:
       if v-side = "L" then comm.cslist.side[1] = "".
       else comm.cslist.side[2] = "".
       release comm.cslist.
      end.
  end.
end.
/**************************************************************************************************************/
function IsFirstOperation returns log ( ).
 def buffer v-sm18data for sm18data.
 find last v-sm18data where v-sm18data.jh = p-trx and v-sm18data.oper_id = p-type and v-sm18data.crc = p-crc and v-sm18data.state = 1 no-lock no-error.
 if avail v-sm18data then do:
   p-acceptedAmt = v-sm18data.sm_summ.
   p-dispensedAmt = v-sm18data.tc_summ.

   return true.
 end.
 else return false.
end function.
/**************************************************************************************************************/

run savelog( "SmartSafe", " " + v-safe + ", Start : ClientIP = " + ClientIP + ", ofc = " + p-ofc + ", trx = " + string(p-trx) + ", p-type = " + string(p-type) + ", p-crc = " + string(p-crc) + ", p-summ = " + string(p-summ) ).
/*******************************************************************************************************/
  if p-type = 3 or p-type = 4 or p-type = 10  then do:

    find first sm18data where sm18data.jh = p-trx and sm18data.state = 1 and sm18data.oper_id = p-type and sm18data.crc = p-crc and (sm18data.dam = p-summ or sm18data.cam = p-summ) no-lock no-error.
    if avail sm18data then do:
       p-acceptedAmt = sm18data.sm_summ.
       p-dispensedAmt = sm18data.tc_summ.
       p-rez = true.
       return.
    end.

      find last sm18data where sm18data.safe = v-safe and (sm18data.state = 0 or sm18data.state = 1) use-index ind no-lock no-error.
      if avail sm18data then do:
        if sm18data.state = 0 and p-ofc <> sm18data.who_cr and sm18data.oper_id <> 10 then do:
           message "Сейф занят пользователем " sm18data.who_cr view-as alert-box.
           return.
        end.
        if sm18data.state = 0 and sm18data.oper_id = 10 and (sm18data.jh = 0 or sm18data.jh = ?) then do:
           message "Сейф в режиме подготовки к инкассации!" view-as alert-box.
           return.
        end.
        if sm18data.state = 0 and sm18data.jh <> p-trx then do:
           message "Необходимо завершить транзакцию № " sm18data.jh  view-as alert-box.
           return.
        end.

        run cm18_info(v-safe,v-side,output R-Data, output v-Amount).
        if SafeFault then return.

        if sm18data.state = 0 then do: /*Новая транзакция, завершившаяся неудачей*/
          if sm18data.before_summ[1] <> v-Amount[1] or
             sm18data.before_summ[2] <> v-Amount[2] or
             sm18data.before_summ[3] <> v-Amount[3] or
             sm18data.before_summ[4] <> v-Amount[4] or
             sm18data.before_summ[5] <> v-Amount[5] or
             sm18data.before_summ[6] <> v-Amount[6] or
             sm18data.before_summ[7] <> v-Amount[7] or
             sm18data.before_summ[8] <> v-Amount[8] or
             sm18data.before_summ[9] <> v-Amount[9] or
             sm18data.before_summ[10] <> v-Amount[10] then do:

                if p-crc <> 0 then do:
                  OperSumm = p-summ  - abs(sm18data.before_summ[p-crc] - v-Amount[p-crc]).
                  if OperSumm = 0 then do:
                    /*Завершение транзакции*/
                     p-rez = true.
                    v-recid = sm18data.docno.
                    run SaveResult.
                    return.
                  end.
                  /*Здесь идем дальше, новая сумма операции OperSumm*/
                  v-recid = sm18data.docno.
                end.
                else do:
                  /*Тут сложнее, незавершенная инкассация*/
                  repeat i_pos = 1 to 4:
                    tmp_val[i_pos] = GetTrxSumm(i_pos,p-trx) - ( sm18data.before_summ[i_pos] - v-Amount[i_pos] ).
                    if tmp_val[i_pos] > 0 then tmp_mess = tmp_mess + string(tmp_val[i_pos]) + " " + GetCRC(i_pos) + "~n".
                  end.
                  if tmp_mess <> "" then do:
                     message "Транзакция не может быть отштампована,~n Необходимо выгрузить из сейфа:~n" +  tmp_mess + "Обратитесь в ДИТ!" view-as alert-box.
                     p-rez = false.
                     return.
                  end.
                  else do:
                    message "Инкассация завершена!" view-as alert-box.
                    p-rez = true.
                    v-recid = sm18data.docno.
                    run SaveResult.
                    return.
                  end.
                end.

          end.
          else do:
            /*статус 0 а баланс сейфа не изменился*/
            v-recid = sm18data.docno.
          end.
        end.
        if sm18data.state = 1 then do: /*Нет незавершенных операций*/

                if IsFirstOperation() then
                do:
                   p-rez = true.
                   return.
                end.

               /*Если операция не 0, значит баланс сейфа изменился, а записи в таблице нет.
                 Видимо обрыв связи, или прибили окно сессии крестиком во время операции...
                 Ну или кривыми ручками напрямую залезли в сейф*/
                 /*Определим какая должна была быть операция*/

                 tmp_oper_type = GetTypeOper(sm18data.after_summ,v-Amount).


                 case tmp_oper_type:
                   when 0 then do:
                     /*абсолютно новая операция*/
                     run SaveData.
                   end.
                   when 3 then do:
                     /*операция выдачи наличных*/
                     if p-type <> 3 then do: message "Должна быть операция выдачи наличных!" view-as alert-box. p-rez = false. return. end.
                     if (sm18data.after_summ[p-crc] - v-Amount[p-crc]) = 0 then do:
                       message "Неверный тип валюты операции выдачи!" view-as alert-box.
                       p-rez = false.
                       return.
                     end.
                     if p-summ = sm18data.after_summ[p-crc] - v-Amount[p-crc] then do:
                          run PostSaveData.
                          p-rez = true.
                          run SaveResult.
                       return.
                     end.
                     else do:
                       MESSAGE "Cумма операции по ЭК не соответствует общей сумме операции!~n   Продолжить?" VIEW-AS ALERT-BOX MESSAGE BUTTONS Yes-No TITLE "Прием наличных" UPDATE choice.
                       if choice = ? or choice = no then do: p-rez = false. return. end.
                       /*временно запретим*/
                       p-rez = false.
                       return.
                       /*******************/

                       OperSumm = p-summ - (sm18data.after_summ[p-crc] - v-Amount[p-crc]).
                       run SaveData.
                     end.
                   end.
                   when 4 then do:
                     /*операция приема наличных*/
                     if p-type <> 4 then do: message "Должна быть операция приема наличных!" view-as alert-box. p-rez = false. return. end.
                     if (sm18data.after_summ[p-crc] - v-Amount[p-crc]) = 0 then do:
                       message "Неверный тип валюты операции приема!" view-as alert-box.
                       p-rez = false.
                       return.
                     end.
                     if p-summ = v-Amount[p-crc] - sm18data.after_summ[p-crc] then do:
                       run PostSaveData.
                       p-rez = true.
                       run SaveResult.
                       return.
                     end.
                     else do:

                       MESSAGE "Cумма операции по ЭК не соответствует общей сумме операции!~n   Продолжить?" VIEW-AS ALERT-BOX MESSAGE BUTTONS Yes-No TITLE "Прием наличных" UPDATE choice.
                       if choice = ? or choice = no then do: p-rez = false. return. end.
                       /*временно запретим*/
                      /* p-rez = false.
                       return.*/
                       /*******************/

                       OperSumm =  p-summ - (v-Amount[p-crc] - sm18data.after_summ[p-crc]) .
                       run SaveData.

                     end.
                   end.
                   when 10 then do:
                     /*операция инкассации*/
                     if p-type <> 10 then do: message "Должна быть операция инкассации!" view-as alert-box. p-rez = false. return. end.

                     repeat i_pos = 1 to 4:
                       tmp_val[i_pos] = GetTrxSumm(i_pos,p-trx) - ( sm18data.after_summ[i_pos] - v-Amount[i_pos] ).
                       if tmp_val[i_pos] > 0 then tmp_mess = tmp_mess + string(tmp_val[i_pos]) + " " + GetCRC(i_pos) + "~n".
                     end.
                     if tmp_mess <> "" then do:
                        message "Транзакция не может быть отштампована,~n Необходимо выгрузить из сейфа:~n" +  tmp_mess + "Обратитесь в ДИТ!" view-as alert-box.
                        p-rez = false.
                        return.
                     end.
                     else do:
                        message "Инкассация завершена!~n Все ОК!" view-as alert-box.
                        p-rez = true.
                        v-recid = sm18data.docno.
                        run SaveResult.
                        return.
                     end.

                   end.
                   otherwise do:
                     message "Неизвестный тип операции!" view-as alert-box.
                     p-rez = false.
                     return.
                   end.
                 end case.

        end.

      end.
      else do:
        /*Программа запущена первый раз*/
        run cm18_info(v-safe,v-side,output R-Data, output v-Amount).
        if SafeFault then return.
        run SaveData.
      end.
  end.

/*******************************************************************************************************/
/*displ "       ЖДИТЕ...    " skip  with side-labels row 18 width 22 centered frame f-mess.*/
        CASE p-type:
          WHEN 0 THEN  /*Текущий баланс*/
          DO:
            run cm18_info(v-safe,v-side,output R-Data, output v-Amount).
          END.
          WHEN 1 THEN  /*Состояние сейфа*/
          DO:
            run cm18_1(v-safe,v-side).
          END.
          WHEN 2 THEN  /*Пересчет*/
          DO:
           rez = true.
            run to_screen("video","").
            do while rez = true:
              run cm18_2(v-safe,v-side, input-output v-Amount).
              v-mess = "".
                if v-Amount[1] > 0 then v-mess = v-mess + string(v-Amount[1],">>>,>>>,>>9.99-") + "KZT ".
                if v-Amount[2] > 0 then v-mess = v-mess + string(v-Amount[2],">>>,>>>,>>9.99-") + "USD ".
                if v-Amount[3] > 0 then v-mess = v-mess + string(v-Amount[3],">>>,>>>,>>9.99-") + "EUR ".
                if v-Amount[4] > 0 then v-mess = v-mess + string(v-Amount[4],">>>,>>>,>>9.99-") + "RUB ".
                run to_screen("video","Пересчет: " + v-mess).
                
                message
                "KZT:" + string(v-Amount[1],">>>,>>>,>>9.99-") + "~n" +
                "USD:" + string(v-Amount[2],">>>,>>>,>>9.99-") + "~n" +
                "EUR:" + string(v-Amount[3],">>>,>>>,>>9.99-") + "~n" +
                "RUB:" + string(v-Amount[4],">>>,>>>,>>9.99-") + "~n"
                view-as alert-box title "Пересчет наличных".
                
                
                MESSAGE "Продолжить пересчет?" VIEW-AS ALERT-BOX MESSAGE BUTTONS Yes-No TITLE "Пересчет наличных" UPDATE choice.
                if choice = ? or choice = no then do: rez = false. leave. end.
            end.
            run to_screen("","").
          END.
          WHEN 3 THEN  /*Выдача наличных*/
          DO:
            do while ((p-acceptedAmt + p-dispensedAmt) <> OperSumm):
             run cm18_3(v-safe, v-side, OperSumm - (p-acceptedAmt + p-dispensedAmt),  GetCRC(p-crc), output p-acceptedAmt, output p-dispensedAmt, output p-rez).
             if p-rez = false then do: leave. end.
            end.
            if p-rez = true then do:
                run to_screen("video","Выдано: " + string(OperSumm,">>>,>>>,>>9.99-") + " " + GetCRC(p-crc) ).
                message "Сумма операции: " + string(OperSumm,">>>,>>>,>>9.99-") + " " + GetCRC(p-crc) + "~n" +
                "          Сейф: " + string(p-acceptedAmt,">>>,>>>,>>9.99-") + " " + GetCRC(p-crc) + "~n" +
                "     Миникасса: " + string(p-dispensedAmt,">>>,>>>,>>9.99-") + " " + GetCRC(p-crc)   view-as alert-box title "Выдача наличных".
            end.
          END.
          WHEN 4 THEN  /*Прием наличных*/
          DO:

            def var v-acceptedTmp as deci init 0.
            def var v-dispensedTmp as deci init 0.
            run SelectEndPoint("","Сумма операции         :" + string(OperSumm,">>>,>>>,>>9.99-") +  " " + GetCRC(p-crc) ,"" , output v-point).
            if v-point = 2 then do:
              /*пока запрет на прием в темпокассу*/
             /* v-point = 1.*/

              choice = no.
              MESSAGE "Вы уверены что хотите принять всю сумму в миникассу?" VIEW-AS ALERT-BOX MESSAGE BUTTONS Yes-No TITLE "Прием наличных" UPDATE choice.
              if choice = yes then do:
               p-dispensedAmt = OperSumm.
               p-acceptedAmt = p-summ - p-dispensedAmt.
               p-rez = true.
              end.
              else do: p-rez = false. v-point = 0. end.

            end.
            if v-point <> 0 and p-rez <> true then do:

                do while ((p-acceptedAmt + p-dispensedAmt) <> OperSumm):
                  v-acceptedTmp = p-acceptedAmt.
                  v-dispensedTmp = p-dispensedAmt.
                  AcceptSumm = p-acceptedAmt + p-dispensedAmt.

                  if ((p-acceptedAmt + p-dispensedAmt ) > OperSumm) then do: /*Выдать сдачу*/
                   run SelectEndPoint("Сумма операции         :" + string(OperSumm,">>>,>>>,>>9.99-") +  " " + GetCRC(p-crc) ,
                                      "Принято                :" + string(p-acceptedAmt + p-dispensedAmt ,">>>,>>>,>>9.99-") + " " + GetCRC(p-crc) ,
                                      "Необходимо выдать сдачу:" + string((p-acceptedAmt + p-dispensedAmt ) - OperSumm , ">>>,>>>,>>9.99-") + " " + GetCRC(p-crc)  ,output v-point).
                   if v-point = 0 then do:
                    p-rez = false.
                   /* SafeFault = false.*/
                   end.
                   if v-point = 2 then do:
                        /*if p-crc <> 1 then do: p-rez = false.  message "Работать с миникассой с валютой " GetCRC(p-crc) " запрещено!" view-as alert-box. end.
                        else do:*/
                         /*Выдали из темпокассы*/
                         p-dispensedAmt = OperSumm - p-acceptedAmt.
                         p-rez = true.
                        /* end. */
                   end.
                   if v-point = 1 then do:
                     run cm18_3(v-safe, v-side, (p-acceptedAmt + p-dispensedAmt ) - OperSumm,  GetCRC(p-crc), output v-acceptedTmp, output v-dispensedTmp, output p-rez).
                     p-acceptedAmt = p-acceptedAmt - v-acceptedTmp.
                     if v-dispensedTmp < 0 then  p-dispensedAmt = p-dispensedAmt + v-dispensedTmp.
                     else p-dispensedAmt = p-dispensedAmt - v-dispensedTmp.
                     
                     /*Сдача*/
                     run to_screen("video","Выдано: " + string(v-acceptedTmp,">>>,>>>,>>9.99-") +  " " + GetCRC(p-crc)).
                   end.
                  end.

                  if ((p-acceptedAmt + p-dispensedAmt ) < OperSumm) then do: /*Положить еще*/
                   if (p-acceptedAmt + p-dispensedAmt ) > 0 then do:
                     run SelectEndPoint("Сумма операции         :" + string(OperSumm,">>>,>>>,>>9.99-") +  " " + GetCRC(p-crc) ,
                                        "Принято                :" + string(p-acceptedAmt,">>>,>>>,>>9.99-") + " " + GetCRC(p-crc) ,
                                        "Необходимо принять еще :" + string( OperSumm - ( p-acceptedAmt ),">>>,>>>,>>9.99-") +  " " + GetCRC(p-crc) , output v-point).
                   end.
                   if v-point = 0 then do:
                     p-rez = false.

                   end.
                   if v-point = 2 then do: /*Приняли в темпокассу*/
                       /*пока не разрешено работать с темпокассой*/

                       p-dispensedAmt = OperSumm - p-acceptedAmt.
                       p-rez = true.

                       /*p-rez = false.*/
                   end.
                   if v-point = 1 then do:
                       run cm18_4(v-safe, v-side, OperSumm - (p-acceptedAmt + p-dispensedAmt), GetCRC(p-crc),output v-acceptedTmp  , output p-rez).
                       p-acceptedAmt = p-acceptedAmt + v-acceptedTmp.
                       if v-acceptedTmp = 0 then v-point = 0.
                       
                       run to_screen("video","Принято: " + string(p-acceptedAmt,">>>,>>>,>>9.99-") +  " " + GetCRC(p-crc)).
                   end.

                  end.

                  if SafeFault = true then leave.

                  if p-rez = false and v-point = 0  then do:
                   if (p-acceptedAmt + p-dispensedAmt) <> 0 then do:
                      MESSAGE "Отменить текущую транзакцию?" VIEW-AS ALERT-BOX MESSAGE BUTTONS Yes-No TITLE "Прием наличных" UPDATE choice.
                      if choice = ? or choice = no then do:  next. end.
                      else do:
                             OperSumm = (p-acceptedAmt + p-dispensedAmt).
                             p-acceptedAmt = 0.
                             p-dispensedAmt = 0.
                             do while ( OperSumm <> (p-acceptedAmt + p-dispensedAmt)) :
                                run cm18_3(v-safe, v-side, OperSumm ,  GetCRC(p-crc), output v-acceptedTmp, output v-dispensedTmp, output p-rez).
                                p-acceptedAmt = p-acceptedAmt + v-acceptedTmp.
                                p-dispensedAmt = p-dispensedAmt + v-dispensedTmp.
                                
                                run to_screen("video","Возврат: " + string(p-acceptedAmt,">>>,>>>,>>9.99-") +  " " + GetCRC(p-crc)).
                                
                                message  "Сумма операции: " + string(OperSumm,">>>,>>>,>>9.99-") + " " + GetCRC(p-crc) + "~n" +
                                "          Сейф: " + string(p-acceptedAmt,">>>,>>>,>>9.99-") + " " + GetCRC(p-crc) + "~n" +
                                "     Миникасса: " + string(p-dispensedAmt,">>>,>>>,>>9.99-") + " " + GetCRC(p-crc)   view-as alert-box title "Возврат принятой суммы".
                                AcceptSumm = p-acceptedAmt + p-dispensedAmt.
                             end.
                             if OperSumm = (p-acceptedAmt + p-dispensedAmt) then do:
                               p-acceptedAmt = 0.
                               p-dispensedAmt = 0.
                             end.
                             p-rez = false.
                             leave.
                      end.

                   end.
                   else leave.
                  end.

                end.

            end.

            if p-rez = true then do:
               run to_screen("video","Принято: " + string(p-acceptedAmt,">>>,>>>,>>9.99-") +  " " + GetCRC(p-crc)).
                
               message  "Сумма операции: " + string(OperSumm,">>>,>>>,>>9.99-") + " " + GetCRC(p-crc) + "~n" +
                        "          Сейф: " + string(p-acceptedAmt,">>>,>>>,>>9.99-") + " " + GetCRC(p-crc) + "~n" +
                        "     Миникасса: " + string(p-dispensedAmt,">>>,>>>,>>9.99-") + " " + GetCRC(p-crc)   view-as alert-box title "Прием наличных".
            end.
          END.
          WHEN 10 THEN  /*Инкассация*/
          DO:

             find first sm18data where sm18data.docno = v-recid and sm18data.state = 0 no-lock no-error.
             if avail sm18data then do:
               p-rez = false.
               do while( p-rez <> true):
                   run to_screen("video","Инкассация ждите...").
                   
                   run cm18_10(v-safe, v-side, sm18data.Request ,  output v-Amount, output p-rez).
                   message
                    "KZT:" + string(v-Amount[1],">>>,>>>,>>9.99-") + "~n" +
                    "USD:" + string(v-Amount[2],">>>,>>>,>>9.99-") + "~n" +
                    "EUR:" + string(v-Amount[3],">>>,>>>,>>9.99-") + "~n" +
                    "RUB:" + string(v-Amount[4],">>>,>>>,>>9.99-") + "~n"
                    view-as alert-box title "Выгрузка сейфа".
               end.
             end.
             else p-rez = false.
          END.
          OTHERWISE DO:
             message "Неизвестная операция " p-type view-as alert-box.

          END.
        END CASE.

/*hide frame f-mess.*/


if SafeFault then run savelog( "SmartSafe", " " + v-safe +  ", F4    : ClientIP = " + ClientIP + ", ofc = " + p-ofc + ", trx = " + string(p-trx) + ", p-acceptedAmt = " + string(p-acceptedAmt) + ", p-dispensedAmt = " + string(p-dispensedAmt)).
run SaveResult.
run savelog("SmartSafe", " " + v-safe +  ", End   : ClientIP = " + ClientIP + ", ofc = " + p-ofc + ", trx = " + string(p-trx) + ", p-acceptedAmt = " + string(p-acceptedAmt) + ", p-dispensedAmt = " + string(p-dispensedAmt) + ", p-rez =" + string(p-rez)).


/**************************************************************************************************************/
procedure SaveData:

    if p-type = 3 or p-type = 4 or p-type = 10 then
    do:
       do transaction:
        create sm18data.
              v-recid = next-value(sm18_id).
              sm18data.docno = v-recid.
              sm18data.who_cr = p-ofc.
              sm18data.whn_cr = today.
              sm18data.time_cr = time.
              sm18data.oper_id = p-type.
              sm18data.crc =  p-crc.
              sm18data.safe = v-safe.
              sm18data.txb = s-ourbank.
              sm18data.state = 0.
              sm18data.jh = p-trx.
             /* sm18data.Request = R-Data.*/
              sm18data.before_summ[1] = v-Amount[1].
              sm18data.before_summ[2] = v-Amount[2].
              sm18data.before_summ[3] = v-Amount[3].
              sm18data.before_summ[4] = v-Amount[4].
              sm18data.before_summ[5] = v-Amount[5].
              sm18data.before_summ[6] = v-Amount[6].
              sm18data.before_summ[7] = v-Amount[7].
              sm18data.before_summ[8] = v-Amount[8].
              sm18data.before_summ[9] = v-Amount[9].
              sm18data.before_summ[10] = v-Amount[10].
              if p-type = 4 then sm18data.dam = p-summ. /* Прием в сейф*/
              if p-type = 3 then sm18data.cam = p-summ. /* Выдача из сейфа*/
              release sm18data.
              find first sm18data where sm18data.docno = v-recid no-lock no-error.
       end. /*transaction*/
    end.

end procedure.
/**************************************************************************************************************/
procedure SaveResult:
    if p-type = 3 or p-type = 4 or p-type = 10 then
    do:
      def var p-Amount as decimal extent 10.
      def buffer b-sm18data for sm18data.
      do transaction:
        find first b-sm18data where b-sm18data.docno = v-recid exclusive-lock no-error.
        if avail b-sm18data and SafeFault = false then do:
           run cm18_info(v-safe,v-side,output R-Data, output p-Amount).
           b-sm18data.Responce = R-Data.
           if b-sm18data.crc <> 0 then do:
             if p-acceptedAmt + p-dispensedAmt <> p-summ then do:
               b-sm18data.sm_summ = abs(b-sm18data.before_summ[b-sm18data.crc] - p-Amount[b-sm18data.crc]).
               b-sm18data.tc_summ = p-summ - b-sm18data.sm_summ.
             end.
             else do:
               b-sm18data.sm_summ = p-acceptedAmt.
               b-sm18data.tc_summ = p-dispensedAmt.
             end.
           end.

           b-sm18data.after_summ[1] = p-Amount[1].
           b-sm18data.after_summ[2] = p-Amount[2].
           b-sm18data.after_summ[3] = p-Amount[3].
           b-sm18data.after_summ[4] = p-Amount[4].
           b-sm18data.after_summ[5] = p-Amount[5].
           b-sm18data.after_summ[6] = p-Amount[6].
           b-sm18data.after_summ[7] = p-Amount[7].
           b-sm18data.after_summ[8] = p-Amount[8].
           b-sm18data.after_summ[9] = p-Amount[9].
           b-sm18data.after_summ[10] = p-Amount[10].

           if p-rez = true then do:
             b-sm18data.rez = 101.
             /*
             if p-acceptedAmt <> b-sm18data.sm_summ then do: message "Несоответствие данных о сумме ЭК!". pause 1. end.
             if p-dispensedAmt <> b-sm18data.tc_summ then do: message "Несоответствие данных о сумме Миникассы!". pause 1. end.
             */
             p-acceptedAmt = b-sm18data.sm_summ.
             p-dispensedAmt = b-sm18data.tc_summ.
             if b-sm18data.sm_summ + b-sm18data.tc_summ = p-summ then b-sm18data.state = 1.
             else b-sm18data.state = 0.
           end.
           else do:
             if b-sm18data.crc <> 0 and p-Amount[b-sm18data.crc] = b-sm18data.before_summ[b-sm18data.crc] then b-sm18data.state = - 1.
           end.

           release b-sm18data.
        end.
      end. /*transaction*/
    end.
end procedure.
/**************************************************************************************************************/
procedure PostSaveData:
    def buffer b2-sm18data for sm18data.
    do transaction:
        create b2-sm18data.
        v-recid = next-value(sm18_id).
        b2-sm18data.docno = v-recid.
        b2-sm18data.who_cr = p-ofc.
        b2-sm18data.whn_cr = today.
        b2-sm18data.time_cr = time.
        b2-sm18data.oper_id = p-type.
        b2-sm18data.crc =  p-crc.
        b2-sm18data.safe = v-safe.
        b2-sm18data.txb = s-ourbank.
        b2-sm18data.state = 0.
        b2-sm18data.jh = p-trx.
        /* sm18data.Request = R-Data.*/
        b2-sm18data.before_summ[1] = sm18data.after_summ[1].
        b2-sm18data.before_summ[2] = sm18data.after_summ[2].
        b2-sm18data.before_summ[3] = sm18data.after_summ[3].
        b2-sm18data.before_summ[4] = sm18data.after_summ[4].
        b2-sm18data.before_summ[5] = sm18data.after_summ[5].
        b2-sm18data.before_summ[6] = sm18data.after_summ[6].
        b2-sm18data.before_summ[7] = sm18data.after_summ[7].
        b2-sm18data.before_summ[8] = sm18data.after_summ[8].
        b2-sm18data.before_summ[9] = sm18data.after_summ[9].
        b2-sm18data.before_summ[10] = sm18data.after_summ[10].
        if p-type = 4 then b2-sm18data.dam = p-summ. /* Прием в сейф*/
        if p-type = 3 then b2-sm18data.cam = p-summ. /* Выдача из сейфа*/
        release b2-sm18data.
    end. /*transaction*/
end procedure.
