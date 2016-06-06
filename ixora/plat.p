/* plat.p
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

/*    plat.p
      Формирование платежного поручения
      Изменения от 01.07.2000
*/



DEF   SHARED VAR g-ofc LIKE ofc.ofc.

DEF   SHARED VAR g-today AS DATE.

DEF NEW  SHARED FRAME platr.
DEF NEW SHARED VAR vld AS CHAR INIT "r".
DEF NEW SHARED VAR v-nmb LIKE pla.nmb.
DEF VAR menr AS CHAR EXTENT 4 FORMAT "x(13)" INIT "".
DEF VAR prg AS CHAR EXTENT 4 FORMAT "x(16)" INIT "".


menr[1] = " Новый док-т ".
menr[2] = " Редакция    ".             
menr[3] = " Печать      ".
menr[4] = " Выход       ".

prg[1] = "pla-j".           
prg[2] = "pla-r".
prg[3] = "pla-d".
prg[4] = "".

DEF VAR jn AS INT.
DEF VAR jk AS INT.
{platr.f}                   


REPEAT:
  IF vld EQ "l" THEN
  DO:
    FIND FIRST pla WHERE pla.who = g-ofc AND pla.lang = vld NO-LOCK NO-ERROR.
    IF NOT AVAILABLE pla THEN
    DO:
      RUN pla-l.
      FIND FIRST pla WHERE pla.who = g-ofc AND pla.lang = vld NO-LOCK NO-ERROR.
      v-nmb = pla.nmb.
    END.
    VIEW FRAME plat.
    DISP pla.nmb pla.regdt
         pla.ma1 pla.rs1 pla.ve format 'x(2)' pla.summ
         pla.ma2
         pla.ba1 pla.kb2 pla.code format 'x(5)'
         pla.sa1 pla.rs2 pla.me
         pla.sa2
         pla.ba2 pla.kb4
         pla.ba3
         pla.ap[1] pla.rs3 
         pla.ap[2] pla.ap[3] pla.rs4
         pla.ap[4] pla.ap[5] pla.ba4
         WITH FRAME platr .  
    PAUSE 0.
    DISP menr WITH ROW 16 COLUMN 66 NO-LABEL
      OVERLAY NO-HIDE FRAME n2 WIDTH 15.
    PAUSE 0.
    HIDE MESSAGE.
    CHOOSE FIELD menr WITH FRAME n2.
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
         pla.ma1 pla.rs1 pla.ve format 'x(2)' pla.summ 
         pla.ma2  
         pla.ba1 pla.kb2 pla.code format 'x(5)' 
         pla.sa1 pla.rs2 pla.me 
         pla.sa2    
         pla.ba2 pla.kb4      
         pla.ba3 
         pla.ap[1] pla.rs3
         pla.ap[2] pla.ap[3] pla.rs4
         pla.ap[4] pla.ap[5] pla.ba4
         WITH FRAME platr . 
    PAUSE 0.
    DISP menr WITH ROW 16 COLUMN 66 NO-LABEL
      OVERLAY NO-HIDE FRAME n3 WIDTH 15.
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