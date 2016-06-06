/* cm18_NoteOut.p
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
        23.08.2012 k.gitalov возврат ОК только при кодах 101 и 210
*/

{cm18.i}
 /*Инкассация*/
 def input param v-safe as char.
 def input param v-side as char.
 def input param v-Request as char.
 def output param Real-summ as deci extent 10.
 def output param v-rez as log.


 def var rez as int.
 def var data as char.
 def var SafeName as char.
 def shared var SafeFault as log.
 SafeName = v-safe.

  ClearData().

  REPEAT on ENDKEY UNDO ,leave :
   run cm18_trx(GetSafeIP(v-safe), v-side,"SafeData","",output data,output rez).
   if rez <> 101 then do:
    MESSAGE ErrorValue(rez) + "~n Повторить?" VIEW-AS ALERT-BOX MESSAGE BUTTONS YES-NO TITLE "Выдача банкнот из сейфа" UPDATE choice1 AS LOGICAL.
    if choice1 = ? or choice1 = no then leave.
   end.
   else leave.
  END.

  if rez <> 101 then return.
  run DecodeSafeData(data).

       ClearResult().

       displ "       ЖДИТЕ...    " skip  with side-labels row 18 width 22 centered frame f-mess.
       run cm18_trx(GetSafeIP(v-safe), v-side,"SafeOut",v-Request,output data,output rez).
       hide frame f-mess.
       if rez = 1002 then do:
         /*При инкассации будем считать что выдали все если нажимают F4 :)*/
         message "Нажатие клавиши F4 записано в лог файл!" view-as alert-box.
         SafeFault = true.
         v-rez = false.
         return.
      end.
       run GetNoteCount(data,"Wout").

       Real-summ[1] = GetSummValRes("KZT").
       Real-summ[2] = GetSummValRes("USD").
       Real-summ[3] = GetSummValRes("EUR").
       Real-summ[4] = GetSummValRes("RUR").

      if rez = 101 or rez = 210 then do:
          v-rez = true.
      end.
      else do:
          message ErrorValue(rez) view-as alert-box.
          v-rez = false.
      end.


     /* run cm18_Result("Результат выгрузки " + SafeName).*/