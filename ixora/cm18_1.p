/* cm18_1.p
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
*/
{classes.i}
{cm18.i}
{cm18_abs.i}

def input param v-safe as char.
def input param v-side as char.
def var rez as int.
def var data as char.
def var SafeName as char.
SafeName = v-safe.


  REPEAT on ENDKEY UNDO ,leave :
   displ "       ЖДИТЕ...    " skip  with side-labels row 18 width 22 centered frame f-mess.
   run cm18_trx(GetSafeIP(v-safe),v-side,"SafeData","",output data,output rez).
   hide frame f-mess.
   if rez <> 101 then do:
    MESSAGE ErrorValue(rez) + "~n Повторить?" VIEW-AS ALERT-BOX MESSAGE BUTTONS YES-NO TITLE "Запрос конфигурации" UPDATE choice AS LOGICAL.
    if choice = ? or choice = no then  leave.
   end.
   else leave.
  end.

  if rez <> 101 then return.

  run DecodeSafeData(data).



   find first wrk no-lock no-error.
   if not avail wrk then do:
    message "Нет данных о конфигурации сейфа!" view-as alert-box.
    return.
   end.


   define query q_list for wrk .
   define browse b_list query q_list no-lock
   display wrk.ind   label "№"  FORMAT ">9"
          wrk.nom   label "Номинал " format ">>>>>>>>>>9"
          wrk.crc   label "Валюта  " format "x(3)"
          wrk.used  label "Кол-во  "  format ">>>>>>>>9"
          wrk.free  label "Свободно"  format ">>>>>>>>9"
          wrk.summ label  "Сумма" format ">>>>>>>>>>>>9"
          with  12  DOWN  NO-ASSIGN  SEPARATORS  no-row-markers .

    DEFINE BUTTON cancel-button LABEL "Закрыть".
    DEFINE BUTTON print-button LABEL "Печать".

    def var KZT-val as deci init 0.
    def var USD-val as deci init 0.
    def var EUR-val as deci init 0.
    def var RUR-val as deci init 0.
    def var KZT-ofc as deci init 0.
    def var USD-ofc as deci init 0.
    def var EUR-ofc as deci init 0.
    def var RUR-ofc as deci init 0.
    def var ofcname as char.

    KZT-val = GetSummVal("KZT").
    USD-val = GetSummVal("USD").
    EUR-val = GetSummVal("EUR").
    RUR-val = GetSummVal("RUR").
    KZT-ofc = GetCashOfc("KZT",g-ofc,g-today).
    USD-ofc = GetCashOfc("USD",g-ofc,g-today).
    EUR-ofc = GetCashOfc("EUR",g-ofc,g-today).
    RUR-ofc = GetCashOfc("RUR",g-ofc,g-today).


    DEFINE FRAME MainFrame
         skip (1)
         ofcname format "x(40)"label " Менеджер" skip
         b_list skip
         " Сейф:" space(30) "Миникасса:" skip
         KZT-val label "  KZT" format ">>>,>>>,>>9.99-"  space(18) KZT-ofc label "  KZT" format ">>>,>>>,>>9.99-" skip
         USD-val label "  USD" format ">>>,>>>,>>9.99-"  space(18) USD-ofc label "  USD" format ">>>,>>>,>>9.99-" skip
         EUR-val label "  EUR" format ">>>,>>>,>>9.99-"  space(18) EUR-ofc label "  EUR" format ">>>,>>>,>>9.99-" skip
         RUR-val label "  RUB" format ">>>,>>>,>>9.99-"  space(18) RUR-ofc label "  RUB" format ">>>,>>>,>>9.99-" skip
         space(21) print-button  cancel-button
    WITH SIDE-LABELS centered row 4 WIDTH 65 TITLE "Состояние сейфа " + SafeName .

    ON RETURN OF b_list  in  frame MainFrame
    DO:
       def var Pos as int.
       Pos = b_list:focused-row.

      /* if wrk.num = "K" or wrk.num = "L" then do:*/
       if wrk.type = "##" or wrk.type = "--" or wrk.type = "**" then do:
          if UsedCountExt(wrk.num) = 0 then do: message "Барабан пуст!" view-as alert-box. return. end.
          define query q_list2 for wrk_ext .
          define browse b_list2 query q_list2 no-lock
          display wrk_ext.ind   label "№"  FORMAT ">9"
          wrk_ext.nom   label "Номинал " format ">>>>>>>>>>9"
          wrk_ext.crc   label "Валюта  " format "x(3)"
          wrk_ext.used  label "Кол-во  "  format ">>>>>>>>9"
          wrk_ext.summ label  "Сумма" format ">>>>>>>>>>>>9"
          with  6  DOWN NO-ASSIGN  SEPARATORS  no-row-markers .

          DEFINE FRAME EditFrame
               b_list2 skip
          WITH SIDE-LABELS centered row 8 WIDTH 55 TITLE "Состояние барабана № " + string(wrk.ind) .
          enable b_list2 WITH  FRAME EditFrame.
          open query q_list2 for each wrk_ext where wrk_ext.num = wrk.num BY wrk_ext.ind.

          WAIT-FOR endkey of frame EditFrame.
          hide frame EditFrame.

       end.
       else do:

         displ  wrk.nom  format ">>>>>>>>>>9"
          wrk.crc    format "x(3)"
          wrk.used    format ">>>>>>>>9"
          wrk.free    format ">>>>>>>>9"
          wrk.summ  format ">>>>>>>>>>>>9"
             view-as fill-in size 9 by 1 with  no-label overlay
             row b_list:focused-row + 8  column 30 no-box  frame EditFrame2 width 72.
       end.

       b_list:SELECT-ROW(Pos).
    END.
    ON CHOOSE OF cancel-button
    DO:
       apply "endkey" to frame MainFrame.
       hide frame MainFrame.
    END.

    ON CHOOSE OF print-button
    DO:
       run csprint(v-safe).
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
      apply "endkey" to frame MainFrame.
      hide frame MainFrame.
    END.

    open query q_list for each wrk BY wrk.ind.

    ofcname = Base:ofcname.
    display ofcname KZT-val KZT-ofc USD-val USD-ofc EUR-val EUR-ofc RUR-val RUR-ofc WITH  FRAME MainFrame.
    enable b_list print-button cancel-button WITH  FRAME MainFrame.


    WAIT-FOR endkey of frame MainFrame.
    hide frame MainFrame.


