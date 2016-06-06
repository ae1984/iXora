/* rmzmon.p
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
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        05/01/05 tsoy добавил 31 и E
        29/03/05 kanat - добавил очередь DRLB и DRPR
        07/04/05 kanat - добавил очередь DRSTW
        19/04/05 kanat - добавил очередь DRLBG
*/

/*
   KOVAL 
   Объединил программки lbmon, stmon, v1v2mon, st2mon в этот файл
*/

def  var ootchoice as char extent 11 format "x(35)" initial
     ["  LB,LBG ",
      "   STW   ",
      "  V1,V2  ",
      "   ST2   ",
      "   ST5   ",
      "   31    ",
      "   E     ",
      "  DRLB   ",
      "  DRPR   ",
      "  DRLBG  ",
      "  DRSTW  "
      ].

ON F2 ANYWHERE DO:
  form ootchoice
  with overlay row 10 1 col centered no-labels
  frame ootfr.
  display ootchoice with frame ootfr.
  choose field ootchoice AUTO-RETURN with frame ootfr.
  run rmzmon1(trim(FRAME-VALUE)).
end.

APPLY "F2" to current-window.



