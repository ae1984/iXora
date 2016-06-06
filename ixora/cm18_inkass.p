/* cm18_inkass.p
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
        15/09/2012 k.gitalov
 * BASES
        BANK COMM
 * CHANGES
        19/09/2012 k.gitalov перекомпиляция
*/

{classes.i}
{cm18.i "new"}
{cm18_abs.i}
{system.i}
 /*Полная выгрузка сейфа*/

def input parameter v-safe as char.

 def var ClientIP as char.
 def var v-side as char.
 def var v-summ as deci.
 def var v-crc as char.
 def var v-acceptedAmt as deci.
 def var v-dispensedAmt as deci.
 def var v-rez as log.
 def var Install as log.
 def var Real-summ as deci extent 4.
 def var rez as int.
 def var data as char.
 def var SafeName as char.
 SafeName = v-safe.
def var s-ourbank as char no-undo.
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
end.
s-ourbank = trim(sysc.chval).
v-side = "L".
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



   find first wrk no-lock no-error.
    if not avail wrk then do:
    message "Нет данных о конфигурации сейфа!" view-as alert-box.
    return.
   end.

   for each wrk:
    wrk.out = wrk.used.
    wrk.out_summ = wrk.out * wrk.nom.
   end.
   for each wrk_ext:
    wrk_ext.out = wrk_ext.used.
    wrk_ext.out_summ = wrk_ext.nom * wrk_ext.out.
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
         KZT-val label "  KZT" format "zzzzzzzzzzz9" space(22) KZT-out label "  KZT" format "zzzzzzzzzzz9"skip
         USD-val label "  USD" format "zzzzzzzzzzz9" space(22) USD-out label "  USD" format "zzzzzzzzzzz9"skip
         EUR-val label "  EUR" format "zzzzzzzzzzz9" space(22) EUR-out label "  EUR" format "zzzzzzzzzzz9"skip
         RUR-val label "  RUB" format "zzzzzzzzzzz9" space(22) RUR-out label "  RUB" format "zzzzzzzzzzz9"skip
         space(20) go-button cancel-button
    WITH SIDE-LABELS centered overlay row 4 WIDTH 65 TITLE "Инкассация сейфа " + SafeName .

    ON RETURN OF b_list  in  frame MainFrame
    DO:
       /*при необходимости убрать*/
       return.
      /*
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
          WITH SIDE-LABELS centered  row 8 WIDTH 55 TITLE "Выгрузка барабана № " + string(wrk.ind) .
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
       */
    END.

    ON GO OF b_list in frame MainFrame
    DO:

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

       hide frame MainFrame.

       ClearResult().

       displ "       ЖДИТЕ...    " skip  with side-labels row 18 width 22 centered frame f-mess.

       run cm18_trx(GetSafeIP(v-safe), v-side,"SafeOut",list-val,output data,output rez).

       run GetNoteCount(data,"Wout").

       if rez <> 101 and (GetSummValRes("KZT") + GetSummValRes("USD") + GetSummValRes("EUR") + GetSummValRes("RUR")) = 0 then do:
          message ErrorValue(rez) view-as alert-box.
          v-rez = false.
          apply "endkey" to frame MainFrame.
       end.
       else do:
          v-rez = true.
       end.

       hide frame f-mess.
       run cm18_Result("Результат выгрузки " + SafeName).

       apply "endkey" to frame MainFrame.
       hide frame MainFrame.

    END.
    ON CHOOSE OF cancel-button
    DO:
       apply "endkey" to frame MainFrame.
       v-rez = true.
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
      return.
    END.

    open query q_list for each wrk /*where wrk.crc = v-crc*/ BY wrk.ind.

    display KZT-val USD-val EUR-val RUR-val KZT-out USD-out EUR-out RUR-out WITH  FRAME MainFrame.
    enable b_list go-button cancel-button WITH  FRAME MainFrame.
    WAIT-FOR endkey of frame MainFrame.
    hide frame MainFrame.

