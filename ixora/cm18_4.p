/* cm18_4.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание программы
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        --/--/2011 k.gitalov
 * BASES
        BANK COMM
 * CHANGES
*/

{classes.i}
{cm18.i}
 /*Прием наличных*/
 def input param v-safe as char.
 def input param v-side as char.
 def input param v-summ as deci.
 def input param v-crc as char.
 def output param v-acceptedAmt as deci.
/* def output param v-dispensedAmt as deci.*/
 def output param v-rez as log.

 def var Real-summ as deci extent 4.
 def var SafeName as char.
 SafeName = v-safe.
 def var rez as int.
 def var data as char.
 def var def-val as char.
 def shared var OperSumm as deci.
 /*def shared var AcceptSumm as deci.*/
 def shared var SafeFault as log.
 def var choice as log.

   case v-crc:
     when "KZT" then do: def-val = "KZ00". end.
     when "USD" then do: def-val = "US00". end.
     when "EUR" then do: def-val = "EU00". end.
     when "RUR" then do: def-val = "RU00". end.
     otherwise do:
         return.
     end.
   end case.


  MESSAGE "Положите " + string(v-summ) + " " + v-crc + " в приемный слот~n  И нажмите 'OK'" VIEW-AS ALERT-BOX MESSAGE BUTTONS OK-CANCEL TITLE "Прием банкнот в сейф " + SafeName UPDATE choice .
  if choice = ? or choice = no then do: /*if (v-acceptedAmt + v-dispensedAmt) = 0 then */  v-rez = false. return. end.


      REPEAT on ENDKEY UNDO ,leave :
       displ "       ЖДИТЕ...    " skip  with side-labels row 18 width 22 centered frame f-mess.
       run cm18_trx(GetSafeIP(v-safe), v-side, "SafeDepo",def-val,output data,output rez).
       hide frame f-mess.

       if rez = 207 or rez = 205 then do:
        MESSAGE ErrorValue(rez) + "~n Повторить?" VIEW-AS ALERT-BOX MESSAGE BUTTONS YES-NO TITLE "Прием банкнот" UPDATE choice.
        if choice = ? or choice = no then leave.
       end.
       else leave.
      END.

      if rez = 1002 then do:
         SafeFault = true.
         v-rez = false.
         return.
      end.
      run DecodeSafeData(data).

      ClearResult().
      run GetNoteCount(data,"Depo").
      Real-summ[1] = GetSummValRes("KZT").
      Real-summ[2] = GetSummValRes("USD").
      Real-summ[3] = GetSummValRes("EUR").
      Real-summ[4] = GetSummValRes("RUR").

     /* if Real-summ[1] + Real-summ[2] + Real-summ[3] + Real-summ[4] <> 0 then  run cm18_Result("Принято в сейф " + SafeName).*/

      if rez <> 101 and Real-summ[GetCRInd(v-crc)] = 0 then do:
          message ErrorValue(rez) view-as alert-box.
          v-rez = false.
          return.
      end.

      v-acceptedAmt = Real-summ[GetCRInd(v-crc)].

     /* if v-acceptedAmt <> 0 then  v-rez = true.*/


      if v-acceptedAmt  = v-summ  then do:
        v-rez = true.
        return.
      end.

/*
      if v-acceptedAmt > v-summ then do:
        rez = 0.  Приняли больше, нужно дать сдачу
        do while rez = 0:
           run SelectEndPoint("Сумма операции         :" + string(OperSumm,">>>>>>>>>>9") +  " " + v-crc ,
                              "Принято                :" + string(AcceptSumm + v-acceptedAmt,">>>>>>>>>>9") + " " + v-crc ,
                              "Необходимо выдать сдачу:" + string((AcceptSumm + v-acceptedAmt) - OperSumm , ">>>>>>>>>>9") + " " + v-crc  ,output rez).
        end.
        if rez = 2 then do: Выдали из темпокассы
           v-dispensedAmt = v-summ - v-acceptedAmt.
        end.
        else v-dispensedAmt = 0.
        v-rez = true.
        return.
      end.
*/

/*
      if v-acceptedAmt < v-summ then do:
        rez = 0.  Приняли меньше, нужно доложить
        do while rez = 0:
           run SelectEndPoint("Сумма операции         :" + string(OperSumm,">>>>>>>>>>9") +  " " + v-crc ,
                              "Принято                :" + string(AcceptSumm + v-acceptedAmt,">>>>>>>>>>9") + " " + v-crc ,
                              "Необходимо принять еще :" + string( OperSumm - ( AcceptSumm + v-acceptedAmt),">>>>>>>>>>9") +  " " + v-crc , output rez).
        end.
        if rez = 2 then do: Приняли в темпокассу
           v-dispensedAmt = v-summ - v-acceptedAmt.
        end.
        else v-dispensedAmt = 0.
        v-rez = true.
        return.
      end.
*/



