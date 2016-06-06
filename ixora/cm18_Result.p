/* cm18_Result.p
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

{cm18.i}

   def input param v-title as char.

   define buffer b-wrk for result.
   define query q_list for b-wrk .
   define browse b_list query q_list no-lock
   display b-wrk.ind   label "№"  FORMAT ">9"
          b-wrk.nom   label "Номинал " format ">>>>>>>>>>9"
          b-wrk.crc   label "Валюта  " format "x(3)"
          b-wrk.used  label "Кол-во  "  format ">>>>>>>>9"
          b-wrk.summ label  "Сумма" format ">>>>>>>>>>>>9"
          with  12  DOWN  NO-ASSIGN  SEPARATORS  no-row-markers .
    DEFINE BUTTON ok-button LABEL "OK".

    def var KZT-val as deci init 0.
    def var USD-val as deci init 0.
    def var EUR-val as deci init 0.
    def var RUR-val as deci init 0.

    KZT-val = GetSummValRes("KZT").
    USD-val = GetSummValRes("USD").
    EUR-val = GetSummValRes("EUR").
    RUR-val = GetSummValRes("RUR").

    DEFINE FRAME MainFrame
         skip (1)
         b_list skip
         "Всего:" skip
         KZT-val label "  KZT" format "zzzzzzzzzzz9" skip
         USD-val label "  USD" format "zzzzzzzzzzz9" skip
         EUR-val label "  EUR" format "zzzzzzzzzzz9" skip
         RUR-val label "  RUB" format "zzzzzzzzzzz9" skip
         space(24)  ok-button
    WITH SIDE-LABELS centered  row 4 WIDTH 55 TITLE  v-title.


    ON CHOOSE OF ok-button
    DO:
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
      apply "endkey" to frame MainFrame.
      hide frame MainFrame.
    END.

    open query q_list for each b-wrk where  b-wrk.nom > 0 BY b-wrk.ind.

    display KZT-val USD-val EUR-val RUR-val WITH  FRAME MainFrame.
    enable  ok-button b_list WITH  FRAME MainFrame.
    WAIT-FOR endkey of frame MainFrame.
    hide frame MainFrame.

