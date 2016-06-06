/* plas.p
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

/*    smenu - стартовая программа  всех меню
AGA  08/08/94
*/



DEF   SHARED VAR g-ofc LIKE ofc.ofc.
/*      g-ofc = userid("bank").  */

DEF   SHARED VAR g-today AS DATE.

DEF NEW  SHARED FRAME plat.
DEF NEW  SHARED FRAME platr.
DEF NEW SHARED VAR vld AS CHAR INIT "r".
DEF NEW SHARED VAR v-nmb LIKE pla.nmb.
DEF VAR men AS CHAR EXTENT 5 FORMAT "x(10)" INIT "".
DEF VAR menr AS CHAR EXTENT 5 FORMAT "x(10)" INIT "".
DEF VAR prg AS CHAR EXTENT 5 FORMAT "x(16)" INIT "".

men[4] = " No jauna ".
men[1] = " Redi¦ёt  ".
men[2] = " Druka    ".
men[3] = " Valoda   ".
men[5] = " Izeja    ".

menr[4] = " Заново   ".
menr[1] = " Редакт.  ".
menr[2] = " Печать   ".
menr[3] = " Язык     ".
menr[5] = " Выход    ".

prg[4] = "plb-j".
prg[1] = "plb-r".
prg[2] = "plb-d".
prg[3] = "pla-v".
prg[5] = "".

DEF VAR jn AS INT.
DEF VAR jk AS INT.
{plas.f}
{plasr.f}


REPEAT:
  IF vld EQ "l" THEN
  DO:
    FIND first pla WHERE pla.who = g-ofc AND pla.lang = vld NO-LOCK NO-ERROR.
    IF NOT AVAILABLE pla THEN
    DO:
      RUN pla-l.
      FIND FIRST pla WHERE pla.who = g-ofc AND pla.lang = vld NO-LOCK NO-ERROR.
      v-nmb = pla.nmb.
    END.
    VIEW FRAME plat.
    DISP pla.nmb pla.regdt
      pla.ma1 pla.code pla.ma2 pla.rs1 pla.rs2 pla.summ
      pla.ba1 pla.ba2 pla.kb2
      pla.sa1 pla.sa2  pla.rs3 pla.rs4
      pla.ba3 pla.ba4 pla.kb4
      pla.ve  pla.me
      pla.ap[1] pla.ap[2] pla.ap[3]
      pla.ap[4] pla.ap[5]
      WITH FRAME plat .
    PAUSE 0.
    DISP men WITH ROW 15 COLUMN 66 NO-LABEL
      OVERLAY NO-HIDE FRAME n2 WIDTH 12.
    PAUSE 0.
    HIDE MESSAGE.
    CHOOSE FIELD men WITH FRAME n2.
    IF prg[FRAME-INDEX] = "" THEN
    DO:

      RETURN.
    END.
    ELSE
    DO:  /* проверка доступа и наличие программы  */
      IF SEARCH(prg[FRAME-INDEX] + ".r") NE ? THEN
      DO:
        RUN VALUE(prg[FRAME-INDEX]).
      END.
      ELSE
      BELL.
    END.
  END.
  ELSE
  DO:
    FIND FIRST pla WHERE pla.who = g-ofc AND pla.lang = vld NO-LOCK NO-ERROR.
    IF NOT AVAILABLE pla THEN
    DO:
      RUN pla-i.
      FIND FIRST pla WHERE pla.who = g-ofc AND pla.lang = vld NO-LOCK NO-ERROR.
      v-nmb = pla.nmb.
    END.
    VIEW FRAME platr.
    DISP pla.nmb pla.regdt
      pla.ma1 pla.code pla.ma2 pla.rs1 pla.rs2 pla.summ
      pla.ba1 pla.ba2 pla.kb2
      pla.sa1 pla.sa2 pla.rs3 pla.rs4
      pla.ba3 pla.ba4 pla.kb4
      pla.ve  pla.me
      pla.ap[1] pla.ap[2] pla.ap[3]
      pla.ap[4] pla.ap[5]
      WITH FRAME platr .
    PAUSE 0.
    DISP menr WITH ROW 15 COLUMN 66 NO-LABEL
      OVERLAY NO-HIDE FRAME n3 WIDTH 12.
    PAUSE 0.
    HIDE MESSAGE.
    CHOOSE FIELD menr WITH FRAME n3.
    IF prg[FRAME-INDEX] = "" THEN
    DO:
      RETURN.
    END.
    ELSE
    DO:  /* проверка доступа и наличие программы  */
      IF SEARCH(prg[FRAME-INDEX] + ".r") NE ? THEN
      DO:
        RUN VALUE(prg[FRAME-INDEX]).
      END.
      ELSE
      BELL.
    END.
  END.
END.
