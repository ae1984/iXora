/* incas10.p
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
        15.05.2011 k.gitalov
 * BASES
        BANK COMM
 * CHANGES
        21/07/2012 k.gitalov мультивалютный барабан ## и **
*/

{classes.i}
{cm18.i "new"}

 /*создание задачи на выгрузку сейфа*/
 def input param v-safe as char.
 def output param Real-summ as deci extent 4.
 def output param v-rez as log.
 def var v-recid as int.
 def var v-Amount as deci extent 10.
 def var data as char.
 def var SafeName as char.
 SafeName = v-safe.
 v-rez = false.

 find first sm18data where sm18data.safe = v-safe and sm18data.state = 0 and sm18data.oper_id <> 10 no-lock no-error.
 if avail sm18data then do:
    message "Сейф занят пользователем " sm18data.who_cr view-as alert-box.
    return.
 end.
 find last sm18data where sm18data.safe = v-safe and sm18data.state = 0 and sm18data.oper_id = 10 use-index ind no-lock no-error.
  if avail sm18data then do:
   if sm18data.who_cr <> g-ofc then do:
      message "Есть начатая пользователем " sm18data.who_cr " операция инкассации!" view-as alert-box.
      return.
   end.
 end.

   find last sm18data where sm18data.safe = v-safe  and sm18data.state = 1 use-index ind no-lock no-error.
   if avail sm18data then do:
    data = sm18data.Responce.
    v-Amount[1] = sm18data.after_summ[1].
    v-Amount[2] = sm18data.after_summ[2].
    v-Amount[3] = sm18data.after_summ[3].
    v-Amount[4] = sm18data.after_summ[4].
    v-Amount[5] = sm18data.after_summ[5].
    v-Amount[6] = sm18data.after_summ[6].
    v-Amount[7] = sm18data.after_summ[7].
    v-Amount[8] = sm18data.after_summ[8].
    v-Amount[9] = sm18data.after_summ[9].
    v-Amount[10] = sm18data.after_summ[10].
   end.
   else data = "".

   ClearData().
   run DecodeSafeData(data).

   find first wrk no-lock no-error.
   find first wrk_ext no-lock no-error.
   if not avail wrk and not avail wrk_ext then do:
    message "Нет данных о конфигурации сейфа!" view-as alert-box.
    return.
   end.



   find last sm18data where sm18data.safe = v-safe and
                             sm18data.whn_cr = today and
                             sm18data.who_cr = g-ofc and
                             sm18data.state = 0 and
                             sm18data.oper_id = 10 use-index ind no-lock no-error.
   if not avail sm18data then do:
     create sm18data.
     v-recid = next-value(sm18_id).
     sm18data.docno = v-recid.
     sm18data.who_cr = g-ofc.
     sm18data.whn_cr = today.
     sm18data.time_cr = time.
     sm18data.oper_id = 10.
     sm18data.crc =  0.
     sm18data.safe = v-safe.
     sm18data.txb = Base:b-txb.
     sm18data.state = 0.
     sm18data.jh = 0.
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
     release sm18data.
   end.
   else do:
    if sm18data.jh = 0 then v-recid = sm18data.docno. /*Изменение последней непроведенной инкассации*/
    else do:
     message "Последяя инкассация имеет транзакцию" string(sm18data.jh) " но статус операции 0 !" view-as alert-box.
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

    DEFINE BUTTON all-button LABEL "Полная".
    DEFINE BUTTON go-button LABEL "Выполнить".
    DEFINE BUTTON cancel-button LABEL "Закрыть".

    def var KZT-val as deci init 0.
    def var USD-val as deci init 0.
    def var EUR-val as deci init 0.
    def var RUR-val as deci init 0.

    def var KZT-out as deci init 0.
    def var USD-out as deci init 0.
    def var EUR-out as deci init 0.
    def var RUR-out as deci init 0.

    KZT-val = GetSummVal("KZT").
    USD-val = GetSummVal("USD").
    EUR-val = GetSummVal("EUR").
    RUR-val = GetSummVal("RUR").

    KZT-out = GetOutSummVal("KZT").
    USD-out = GetOutSummVal("USD").
    EUR-out = GetOutSummVal("EUR").
    RUR-out = GetOutSummVal("RUR").

    DEFINE FRAME MainFrame
         skip (1)
         b_list skip
         "Всего:" space(32) "К выдаче:" skip
         KZT-val label "  KZT" format ">>>,>>>,>>9.99-" space(19) KZT-out label "  KZT" format ">>>,>>>,>>9.99-"skip
         USD-val label "  USD" format ">>>,>>>,>>9.99-" space(19) USD-out label "  USD" format ">>>,>>>,>>9.99-"skip
         EUR-val label "  EUR" format ">>>,>>>,>>9.99-" space(19) EUR-out label "  EUR" format ">>>,>>>,>>9.99-"skip
         RUR-val label "  RUB" format ">>>,>>>,>>9.99-" space(19) RUR-out label "  RUB" format ">>>,>>>,>>9.99-"skip
         space(14) all-button go-button cancel-button
    WITH SIDE-LABELS centered overlay row 4 WIDTH 65 TITLE "Инкассация сейфа " + SafeName .

    ON RETURN OF b_list  in  frame MainFrame
    DO:
       def var Pos as int.
       Pos = b_list:focused-row.

       if wrk.type = "##" or wrk.type = "--" or wrk.type = "**" then do:
          if UsedCountExt(wrk.num) = 0 then return.
          define query q_list2 for wrk_ext .
          define browse b_list2 query q_list2 no-lock
          display wrk_ext.ind   label "№"  FORMAT ">9"
          wrk_ext.nom   label "Номинал " format ">>>>>>>>>>9"
          wrk_ext.crc   label "Валюта  " format "x(3)"
          wrk_ext.out  label "Кол-во  "  format ">>>>>>>>9"
          wrk_ext.summ label  "Сумма" format ">>>>>>>>>>>>9"
          with  6  DOWN NO-ASSIGN  SEPARATORS  no-row-markers .

          DEFINE BUTTON yes_out LABEL "Выгружать".
          DEFINE BUTTON no_out LABEL "Не выгружать".


          DEFINE FRAME EditFrame
               b_list2 skip
               space(12) yes_out no_out
          WITH SIDE-LABELS centered row 8 WIDTH 55 TITLE "Выгрузка барабана № " + string(wrk.ind) .
          enable yes_out no_out WITH  FRAME EditFrame.

          ON CHOOSE OF yes_out
          DO:
              for each wrk_ext where wrk_ext.num = wrk.num exclusive-lock:
                wrk_ext.out = wrk_ext.used.
                wrk_ext.out_summ = wrk_ext.nom * wrk_ext.out.
              end.
              open query q_list2 for each wrk_ext where wrk_ext.num = wrk.num BY wrk_ext.ind.
              APPLY "endkey" TO FRAME EditFrame.
          END.
          ON CHOOSE OF no_out
          DO:
              for each wrk_ext where wrk_ext.num = wrk.num exclusive-lock:
                wrk_ext.out = 0.
                wrk_ext.out_summ = 0.
              end.
              open query q_list2 for each wrk_ext where wrk_ext.num = wrk.num BY wrk_ext.ind.
              APPLY "endkey" TO FRAME EditFrame.
          END.
          ON END-ERROR OF yes_out, no_out, b_list2 in  frame EditFrame /*OF b_list2 */ /*in  frame EditFrame */
          DO:
            APPLY "endkey" TO FRAME EditFrame.
            hide frame EditFrame.
          END.
          open query q_list2 for each wrk_ext where wrk_ext.num = wrk.num BY wrk_ext.ind.

          WAIT-FOR endkey of frame EditFrame.
          hide frame EditFrame.

       end.
       else do:

         displ wrk.out    format ">>>>>>>>9"
             view-as fill-in size 9 by 1 with  no-label overlay
             row b_list:focused-row + 8  column 61 no-box  frame EditFrame2 width 72.

          set wrk.out with frame EditFrame2.
          if wrk.out entered then do:
            if wrk.out > wrk.used then do:
             wrk.out = 0.
             message "Неправильное значение!" view-as alert-box.
            end.
            else do:
              wrk.out_summ = wrk.out * wrk.nom.
            end.
            open query q_list for each wrk BY wrk.ind.
          end.
       end.

       KZT-out = GetOutSummVal("KZT").
       USD-out = GetOutSummVal("USD").
       EUR-out = GetOutSummVal("EUR").
       RUR-out = GetOutSummVal("RUR").

       b_list:SELECT-ROW(Pos).
       display KZT-val USD-val EUR-val RUR-val KZT-out USD-out EUR-out RUR-out WITH  FRAME MainFrame.
    END.

    ON GO OF b_list in frame MainFrame
    DO:

    END.
    ON CHOOSE OF all-button
    DO:
       for each wrk:
        wrk.out = wrk.used.
        wrk.out_summ = wrk.out * wrk.nom.
       end.
       for each wrk_ext:
        wrk_ext.out = wrk_ext.used.
        wrk_ext.out_summ = wrk_ext.nom * wrk_ext.out.
       end.

       open query q_list for each wrk BY wrk.ind.
       KZT-out = GetOutSummVal("KZT").
       USD-out = GetOutSummVal("USD").
       EUR-out = GetOutSummVal("EUR").
       RUR-out = GetOutSummVal("RUR").
       display KZT-val USD-val EUR-val RUR-val KZT-out USD-out EUR-out RUR-out WITH  FRAME MainFrame.
    END.
    ON CHOOSE OF go-button
    DO:

       def var list-val as char.
       for each wrk where wrk.type <> "##" and wrk.type <> "--" and wrk.type <> "**" no-lock:
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

       if length(list-val) = 0 then do: message "Необходимо сделать выбор" view-as alert-box. return. end.

       find first sm18data where sm18data.docno = v-recid exclusive-lock no-error.
       if avail sm18data then do:
          sm18data.Request = list-val.
          release sm18data.
          Real-summ[1] = GetOutSummVal("KZT").
          Real-summ[2] = GetOutSummVal("USD").
          Real-summ[3] = GetOutSummVal("EUR").
          Real-summ[4] = GetOutSummVal("RUR").
          v-rez = true.
          run csprint(v-safe).
       end.
       else do:
          message "Не найдена запись " v-recid view-as alert-box.
       end.

       apply "endkey" to frame MainFrame.
       hide frame MainFrame.
    END.
    ON CHOOSE OF cancel-button
    DO:
       find first sm18data where sm18data.docno = v-recid exclusive-lock.
       if avail sm18data then sm18data.state = - 2.
       release sm18data.
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

    ON END-ERROR OF b_list , cancel-button , go-button ,all-button in  frame MainFrame
    DO:
      find first sm18data where sm18data.docno = v-recid exclusive-lock.
       if avail sm18data then sm18data.state = - 2.
       release sm18data.
       apply "endkey" to frame MainFrame.
       hide frame MainFrame.
    END.

    open query q_list for each wrk  BY wrk.ind.

    display KZT-val USD-val EUR-val RUR-val KZT-out USD-out EUR-out RUR-out WITH  FRAME MainFrame.
    enable b_list all-button go-button cancel-button WITH  FRAME MainFrame.
    WAIT-FOR endkey of frame MainFrame.
    hide frame MainFrame.

