/* pla-v.p
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
*/

/* plarv.p

AGA - 07/05/96 - изменение языка

*/

DEF SHARED VAR vld AS CHAR.
DEF SHARED VAR v-nmb LIKE pla.nmb.
DEF SHARED VAR g-ofc LIKE ofc.ofc.
DEF SHARED VAR g-today AS DATE.
DEF VAR kl AS CHAR FORMAT "x(9)" EXTENT 2  INIT ["latvieЅu","krievu"].
DEF VAR kr AS CHAR FORMAT "x(9)" EXTENT 2  INIT ["латышский","русский"].
IF vld EQ "l" THEN
DO:
  DISP kl WITH ROW 14 COLUMN 65 NO-LABEL
    OVERLAY FRAME g5 WIDTH 12 .
  CHOOSE FIELD kl WITH FRAME g5.
  IF FRAME-INDEX EQ 1 THEN
  vld = "l".
  ELSE
  vld = "r".
  HIDE FRAME g5.
END.
ELSE
DO:
  DISP kr WITH ROW 14 COLUMN 65 NO-LABEL
    OVERLAY FRAME g6 WIDTH 12 .
  CHOOSE FIELD kr WITH FRAME g6.
  IF FRAME-INDEX EQ 1 THEN
  vld = "l".
  ELSE
  vld = "r".
  HIDE FRAME g6.
END.
PAUSE 0.
