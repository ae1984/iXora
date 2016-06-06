/* smart_adm.p
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
        19/09/2012 k.gitalov перекомпиляция

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
def shared var v-safe_list as char.
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


v-safe = "".
run sel1("Сейфы",v-safe_list).
v-safe = return-value.

IF keyfunction(lastkey) = "END-ERROR" then v-safe = "".
if v-safe = "" then return.

v-side = "L".


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
               run cm18_2(v-safe,v-side, input-output v-Amount).
                message
                "KZT:" + string(v-Amount[1],">>>,>>>,>>9.99-") + "~n" +
                "USD:" + string(v-Amount[2],">>>,>>>,>>9.99-") + "~n" +
                "EUR:" + string(v-Amount[3],">>>,>>>,>>9.99-") + "~n" +
                "RUB:" + string(v-Amount[4],">>>,>>>,>>9.99-") + "~n"
                view-as alert-box title "Пересчет наличных".

          END.
          WHEN 3 THEN  /*Выдача наличных*/
          DO:
             run cm18_3(v-safe, v-side, OperSumm ,  GetCRC(p-crc), output p-acceptedAmt, output p-dispensedAmt, output p-rez).
             if p-rez = false then do: leave. end.

                message "Сумма операции: " + string(OperSumm,">>>,>>>,>>9.99-") + " " + GetCRC(p-crc) + "~n" +
                "          Сейф: " + string(p-acceptedAmt,">>>,>>>,>>9.99-") + " " + GetCRC(p-crc) + "~n" +
                "     Миникасса: " + string(p-dispensedAmt,">>>,>>>,>>9.99-") + " " + GetCRC(p-crc)   view-as alert-box title "Выдача наличных".
          END.
          WHEN 4 THEN  /*Прием наличных*/
          DO:

            def var v-acceptedTmp as deci init 0.
            def var v-dispensedTmp as deci init 0.
            run SelectEndPoint("","Сумма операции         :" + string(OperSumm,">>>,>>>,>>9.99-") +  " " + GetCRC(p-crc) ,"" , output v-point).
            if v-point = 2 then do:
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
                   end.
                   if v-point = 2 then do: /*Выдали из темпокассы*/
                    p-dispensedAmt = OperSumm - p-acceptedAmt.
                    p-rez = true.
                   end.
                   if v-point = 1 then do:
                     run cm18_3(v-safe, v-side, (p-acceptedAmt + p-dispensedAmt ) - OperSumm,  GetCRC(p-crc), output v-acceptedTmp, output v-dispensedTmp, output p-rez).
                     p-acceptedAmt = p-acceptedAmt - v-acceptedTmp.
                     if v-dispensedTmp < 0 then  p-dispensedAmt = p-dispensedAmt + v-dispensedTmp.
                     else p-dispensedAmt = p-dispensedAmt - v-dispensedTmp.
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
                       p-dispensedAmt = OperSumm - p-acceptedAmt.
                       p-rez = true.
                   end.
                   if v-point = 1 then do:
                       run cm18_4(v-safe, v-side, OperSumm - (p-acceptedAmt + p-dispensedAmt), GetCRC(p-crc),output v-acceptedTmp /*, output v-dispensedTmp*/ , output p-rez).
                       p-acceptedAmt = p-acceptedAmt + v-acceptedTmp.
                       if v-acceptedTmp = 0 then v-point = 0.
                   end.

                  end.

                  if SafeFault = true then leave.

                  if p-rez = false and v-point = 0 /*SafeFault = false*/ then do:
                   if (p-acceptedAmt + p-dispensedAmt) <> 0 then do:
                      MESSAGE "Отменить текущую транзакцию?" VIEW-AS ALERT-BOX MESSAGE BUTTONS Yes-No TITLE "Прием наличных" UPDATE choice.
                      if choice = ? or choice = no then do: /* p-rez = true.*/ next. end.
                      else do:
                             OperSumm = (p-acceptedAmt + p-dispensedAmt).
                             p-acceptedAmt = 0.
                             p-dispensedAmt = 0.
                             do while ( OperSumm <> (p-acceptedAmt + p-dispensedAmt)) :
                                run cm18_3(v-safe, v-side, OperSumm ,  GetCRC(p-crc), output v-acceptedTmp, output v-dispensedTmp, output p-rez).
                                p-acceptedAmt = p-acceptedAmt + v-acceptedTmp.
                                p-dispensedAmt = p-dispensedAmt + v-dispensedTmp.
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
               message  "Сумма операции: " + string(OperSumm,">>>,>>>,>>9.99-") + " " + GetCRC(p-crc) + "~n" +
                        "          Сейф: " + string(p-acceptedAmt,">>>,>>>,>>9.99-") + " " + GetCRC(p-crc) + "~n" +
                        "     Миникасса: " + string(p-dispensedAmt,">>>,>>>,>>9.99-") + " " + GetCRC(p-crc)   view-as alert-box title "Прием наличных".
            end.
          END.
          WHEN 5 THEN  /*Синхронизация*/
          DO:

          run cm18_info(v-safe,v-side,output R-Data, output v-Amount).

          {r-branch.i &proc="cm18_synhro(v-safe,R-Data,v-Amount)"}

          END.
          WHEN 10 THEN  /*Инкассация*/
          DO:

             find first sm18data where sm18data.docno = v-recid and sm18data.state = 0 no-lock no-error.
             if avail sm18data then do:
               run cm18_10(v-safe, v-side, sm18data.Request ,  output v-Amount, output p-rez).
               message
                "KZT:" + string(v-Amount[1],">>>,>>>,>>9.99-") + "~n" +
                "USD:" + string(v-Amount[2],">>>,>>>,>>9.99-") + "~n" +
                "EUR:" + string(v-Amount[3],">>>,>>>,>>9.99-") + "~n" +
                "RUB:" + string(v-Amount[4],">>>,>>>,>>9.99-") + "~n"
                view-as alert-box title "Выгрузка сейфа".
             end.
             else p-rez = false.
          END.
          OTHERWISE DO:
             message "Неизвестная операция " p-type view-as alert-box.

          END.
        END CASE.






