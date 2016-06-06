/* cm18_3.p
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
        21/07/2012 k.gitalov мультивалютный барабан ## и **
        22/08/2012 Luiza закомментировала вопрос "Выдать из миникассы ?"
        24/09/2012 Luiza закомментировала условие and v-crc <> "KZT" при проверке на возможность выдачи из миникассы
*/

{classes.i}
{cm18.i}
{cm18_abs.i}
 /*Выдача наличных*/
 def input param v-safe as char.
 def input param v-side as char.
 def input param v-summ as deci.
 def input param v-crc as char.
 def output param v-acceptedAmt as deci.
 def output param v-dispensedAmt as deci.
 def output param v-rez as log.

 def var rez as int.
 def var data as char.
 def var Real-summ as deci extent 4.
 def var Tempo-summ as deci.
 def var Tempo-val as deci.
 def var Repit as log.
 def var SafeName as char.
 def var ofcname as char.
 def var choice as log.
 def shared var SafeFault as log.
 SafeName = v-safe.

 def shared var OperSumm as deci.
 def shared var AcceptSumm as deci.

  REPEAT on ENDKEY UNDO ,leave :
   displ "       ЖДИТЕ...    " skip  with side-labels row 18 width 22 centered frame f-mess.
   run cm18_trx( GetSafeIP(v-safe), v-side,"SafeData","",output data,output rez).
   hide frame f-mess.
   if rez <> 101 then do:
    MESSAGE ErrorValue(rez) + "~n Повторить?" VIEW-AS ALERT-BOX MESSAGE BUTTONS YES-NO TITLE "Выдача банкнот из сейфа" UPDATE choice.
    if choice = ? or choice = no then leave.
   end.
   else leave.
  END.
  if rez <> 101 then return.

  run DecodeSafeData(data).

   find first wrk no-lock no-error.
    if not avail wrk then do:
    message "Нет данных о конфигурации сейфа " + SafeName view-as alert-box.
    return.
   end.

  Tempo-val = GetCashOfc(v-crc,g-ofc,g-today).
  Tempo-summ =  CalcNoteCount(v-crc, v-summ ).

  if Tempo-summ < 0 then do:
  /* Пока работаем без миникассы
   if Tempo-val < v-summ then do:
     message "Невозможно выдать " string(v-summ) + " " + v-crc  VIEW-AS ALERT-BOX.
     v-rez = false.
     return.
   end.
   */
   /*message "Невозможно выдать из сейфа " string(v-summ) + " " + v-crc + "~n Выдать из миникассы ?" VIEW-AS ALERT-BOX MESSAGE BUTTONS YES-NO  UPDATE choice.*/
    message "Невозможно выдать из сейфа " string(v-summ) + " " + v-crc view-as alert-box.
    choice = yes.
   if choice = ? or choice = no then do: v-rez = false.   return. end.
   else do:
     v-dispensedAmt = v-summ.
     v-rez = true.
     return.
   end.
  end.


   define query q_list for wrk .
   define browse b_list query q_list no-lock
   display wrk.ind   label "№"  FORMAT ">9"
          wrk.nom   label "Номинал " format ">>>>>>>>>>9"
          wrk.crc   label "Валюта  " format "x(3)"
          wrk.used  label "Доступно"  format ">>>>>>>>9"
          wrk.out  label  "Кол-во  "  format ">>>>>>>>9"
          wrk.out_summ label  "Сумма" format ">>>>>>>>>>>>9"
          with  12  DOWN  NO-ASSIGN  SEPARATORS  no-row-markers .

    DEFINE BUTTON go-button LABEL "Выполнить".
    DEFINE BUTTON cancel-button LABEL "Отменить".

    def var Oper-val as deci init 0.
    def var Oper-out as deci init 0.

    Oper-val = GetSummVal(v-crc).
    Oper-out = GetOutSummVal(v-crc).


    DEFINE FRAME MainFrame
         skip (1)
         ofcname format "x(40)"label " Менеджер" skip
         b_list skip
         " Доступно:" space(22) "  К выдаче:"  v-summ format "zzzzzzzzzzz9-" no-label v-oper1 as char format "x(3)" no-label skip
         "     Сейф:" Oper-val  format "zzzzzzzzzzz9-" no-label v-oper2 as char format "x(3)" no-label space(5)
         "     Сейф:" Oper-out  format "zzzzzzzzzzz9-" no-label v-oper3 as char format "x(3)" no-label skip
         "Миникасса:" Tempo-val  format "zzzzzzzzzzz9-" no-label v-oper4 as char format "x(3)" no-label space(5)
         "Миникасса:" Tempo-summ  format "zzzzzzzzzzz9-" no-label v-oper5 as char format "x(3)" no-label skip(1)

         space(20) go-button cancel-button
    WITH SIDE-LABELS centered /*overlay*/ row 4 WIDTH 65 TITLE "Выдача банкнот из сейфа " + SafeName .

    ON RETURN OF b_list  in  frame MainFrame
    DO:
       def var Pos as int.
       Pos = b_list:focused-row.

       if wrk.type = "##" or wrk.type = "--" or wrk.type = "**" then
       do:
          /*Мультивалютный и ветхие не обрабатываем*/
       end.
       else do:

         displ wrk.out    format ">>>>>>>>9"
             view-as fill-in size 9 by 1 with  no-label overlay
             row b_list:focused-row + 9  column 61 no-box  frame EditFrame2 width 72.

          def var tmp_sel as int.
          tmp_sel = wrk.out.
          set wrk.out with frame EditFrame2.
          if wrk.out entered then do:
            if wrk.out > wrk.used then do:
             wrk.out = tmp_sel.
             message "Неправильное значение!" view-as alert-box.
            end.
            else do:

              if Oper-out + ((wrk.out - tmp_sel) * wrk.nom) > v-summ then do: wrk.out = tmp_sel. message "Неправильное значение!" view-as alert-box. end.
              else do:
                wrk.out_summ = wrk.out * wrk.nom.
              end.

            end.
            open query q_list for each wrk where wrk.crc = v-crc and wrk.nom > 0 BY wrk.ind.
          end.
       end.

       Oper-out = GetOutSummVal(v-crc).
       Tempo-summ = v-summ - Oper-out.

       b_list:SELECT-ROW(Pos).
       display Oper-val v-oper1 Oper-out v-oper2 Tempo-val v-oper3 Tempo-summ v-oper4 v-summ v-oper5  WITH  FRAME MainFrame.

    END.

    ON GO OF b_list in frame MainFrame
    DO:

    END.
    ON CHOOSE OF go-button
    DO:

       /*if (Tempo-summ > Tempo-val)  and v-crc <> "KZT" then do:
         message "Невозможно выдать из миникассы" string(Tempo-summ) + " " + v-crc  VIEW-AS ALERT-BOX.
       end.
       else do:*/

           Oper-out = GetOutSummVal(v-crc).
           if Oper-out = 0 or Oper-out > v-summ then return.

           def var list-val as char.
           for each wrk no-lock:
             if wrk.out > 0 then do:
               list-val = list-val + wrk.cass + "," + string(wrk.out) + ",".
             end.
           end.
           for each wrk_ext break by wrk_ext.num:
            if first-of( wrk_ext.num ) then do:
               if UsedOutExt(wrk_ext.num) > 0 then do:
                  list-val = list-val + fill(wrk_ext.num,4) + "," + string(UsedOutExt(wrk_ext.num)) + ",".
               end.
            end.
           end.
           list-val = substr(list-val,1,Length(list-val) - 1).

           hide frame MainFrame.

           ClearResult().

/*
           REPEAT on ENDKEY UNDO ,leave :
               displ "       ЖДИТЕ...    " skip  with side-labels row 18 width 22 centered frame f-mess1.
               run cm18_trx(GetSafeIP(v-safe), v-side, "SafeOut",list-val,output data,output rez).
               hide frame f-mess1.

               if rez = 207 or rez = 205 then do:
                MESSAGE ErrorValue(rez) + "~n Повторить?" VIEW-AS ALERT-BOX MESSAGE BUTTONS YES-NO TITLE "Прием банкнот" UPDATE choice.
                if choice = ? or choice = no then leave.
               end.
               if rez = 1002 then do:
                 SafeFault = true.
                 v-rez = false.
                 return.
               end.
           END.
*/


           displ "       ЖДИТЕ...    " skip  with side-labels row 18 width 22 centered frame f-mess1.
           run cm18_trx(GetSafeIP(v-safe), v-side,"SafeOut",list-val,output data,output rez).
           hide frame f-mess1.
           if rez = 1002 then do:
             SafeFault = true.
             v-rez = false.
             return.
           end.

           run GetNoteCount(data,"Wout").
           Real-summ[1] = GetSummValRes("KZT").
           Real-summ[2] = GetSummValRes("USD").
           Real-summ[3] = GetSummValRes("EUR").
           Real-summ[4] = GetSummValRes("RUR").
           if rez <> 101 and Real-summ[GetCRInd(v-crc)] = 0 then do:
              message ErrorValue(rez) view-as alert-box.
              v-rez = false.
              apply "endkey" to frame MainFrame.
           end.

           /*run cm18_Result("Результат выгрузки " + SafeName).*/

           v-acceptedAmt = Real-summ[GetCRInd(v-crc)].
           if v-acceptedAmt <> Oper-out then v-rez = false.
           else v-dispensedAmt = v-summ - v-acceptedAmt.

           if (v-acceptedAmt = 0 and v-dispensedAmt = 0) or ((v-acceptedAmt + v-dispensedAmt) <> v-summ) then v-rez = false.
           else v-rez = true.
      /*end.*/

       apply "endkey" to frame MainFrame.
       hide frame MainFrame.

    END.
    ON CHOOSE OF cancel-button
    DO:
       v-rez = false.
       apply "endkey" to frame MainFrame.
       hide frame MainFrame.
    END.

    ON CURSOR-UP OF b_list in  frame MainFrame
    DO:
      GET PREV q_list.
    END.

    ON CURSOR-DOWN OF b_list in  frame MainFrame
    DO:
      GET NEXT q_list.
    END.

    ON END-ERROR OF b_list in  frame MainFrame
    DO:
      v-rez = true.
      apply "endkey" to frame MainFrame.
      hide frame MainFrame.
    END.

    open query q_list for each wrk where wrk.crc = v-crc and wrk.nom > 0 BY wrk.ind.

    v-oper1 = v-crc.
    v-oper2 = v-crc.
    v-oper3 = v-crc.
    v-oper4 = v-crc.
    v-oper5 = v-crc.
    ofcname = Base:ofcname.
    display ofcname Oper-val v-oper1 Oper-out v-oper2 Tempo-val v-oper3 Tempo-summ v-oper4 v-summ v-oper5 WITH  FRAME MainFrame.
    enable b_list go-button cancel-button WITH  FRAME MainFrame.
    WAIT-FOR endkey of frame MainFrame.
    hide frame MainFrame.

