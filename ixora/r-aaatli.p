/* r-aaatli.p
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
 * BASES
        BANK 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

/* r-aaatli.p - AGA - остатки на счетах клиентов
и X клиентов на текущую дату
25/04/95
*/
/*
   01.10.2002 nadejda - наименование клиента заменено на форма собств + наименование 
*/

DEF VAR atk LIKE jl.dam LABEL "ATLIKUMS" .
DEF VAR sdt LIKE aaa.cdt LABEL "APGROZ. uz ".
DEF VAR atx LIKE jl.dam EXTENT 3 .
DEF VAR atp LIKE jl.dam EXTENT 3 .
DEF SHARED VAR g-today LIKE aaa.cdt.
DEF SHARED VAR g-comp AS CHAR.
DEF VAR tpa AS CHAR  FORMAT "x(1)" LABEL "TIPS" INIT " ".
DEF VAR tpb AS CHAR  FORMAT "x(1)" LABEL "TIPS" INIT " ".
DEF VAR tpc AS CHAR  FORMAT "x(1)" LABEL "TIPS" INIT " ".

DEF STREAM r2.
DEF STREAM r3.
DEF STREAM r4.
DEF STREAM ter.


sdt = g-today.

DEF VAR nn AS INT.
DEF VAR sobo LIKE jl.dam EXTENT 3 LABEL "APGROZ. >=".
DEF VAR pobo LIKE jl.dam EXTENT 3 LABEL "APGROZ. <".
DEF VAR sobu LIKE jl.dam EXTENT 3 LABEL "APGROZ. >=".
DEF VAR pobu LIKE jl.dam EXTENT 3 LABEL "APGROZ. <".
DEF VAR so LIKE jl.dam  LABEL "APGROZ. >=".
DEF VAR po LIKE jl.dam  LABEL "APGROZ. <".


DEF VAR crc LIKE crc.crc  LABEL "VAL®TA" INIT 1.
DEF VAR cod LIKE crc.code LABEL "VAL®TA" .
DEF VAR coda LIKE crc.code LABEL "VAL®TA" .

DEF VAR bne AS LOG INIT FALSE.
DEF VAR jn AS INT.
DEF VAR tur AS LOG FORMAT "ja/nё".


UPDATE crc VALIDATE(CAN-FIND(crc WHERE crc.crc = crc)," Nav t–das val­tas ! ") WITH SIDE-LABEL CENTERED FRAME asd.
FIND FIRST crc WHERE CRC.CRC EQ CRC NO-LOCK.
Cod = crc.code.

jn = 1.
REPEAT:
  FORM   cod so po WITH 3 DOWN FRAME bn.
  DISP   cod WITH  FRAME bn.
  UPDATE so po WITH COLUMN 12 FRAME bn.
  sobo[jn] = so.
  pobo[jn] = po.
  IF po GT 0 THEN
  so = po.
  ELSE
  LEAVE.
  po = 0.
  IF jn EQ 3 THEN
  LEAVE.
  ELSE
  jn = jn + 1.
END.
HIDE FRAME bn.
coda = cod.
MESSAGE "Programma ilgi str–d–s.   TURPIN…T ? ja/nё" UPDATE tur.
IF NOT tur THEN
RETURN.
MESSAGE "GAIDIET ... GAIDIET ... GAIDIET ...".
OUTPUT STREAM r2 TO r2.txt.
OUTPUT STREAM r3 TO r3.txt.
OUTPUT STREAM r4 TO r4.txt.
OUTPUT STREAM ter TO TERMINAL.

DEF VAR adam LIKE jl.dam.
DEF VAR acam LIKE jl.cam.
DEF VAR maca LIKE jl.cam.

PUT STREAM r2  g-comp FORMAT "x(40)" "laiks: " STRING(TIME,"HH:MM:SS")
  "   datums "  STRING(g-today) SKIP(0) .
PUT STREAM r2 "KLIENTU ATLIKUMI DIAPAZONOS  "
  "uz  " + STRING(sdt)   FORMAT "x(40)" SKIP(1).
PUT STREAM r2
  "=======================================================".
FORMAT "x(55)" SKIP(2).

PUT STREAM r2 "KLIENTU ATLIKUMI   " AT 20
  "uz  " + STRING(sdt)   FORMAT "x(40)" SKIP(1).
IF pobo[1] GT 0 THEN
PUT STREAM r2 sobo[1]   " - "   pobo[1]  coda SKIP(1).
ELSE
PUT STREAM r2 sobo[1]   " - un vairak  " FORMAT "x(14)" coda SKIP(1).
IF sobo[2] NE 0 THEN
DO:
  PUT STREAM r3 "KLIENTU ATLIKUMI    " AT 20
    "uz " + STRING(sdt)    FORMAT "x(40)" SKIP(1).
  IF pobo[2] GT 0 THEN
  PUT STREAM r3 sobo[2]   " - "   pobo[2] coda  SKIP(1).
  ELSE
  PUT STREAM r3 sobo[2]   " - un vairak " FORMAT "x(14)" coda SKIP(1).
  IF sobo[3] NE 0 THEN
  DO:
    PUT STREAM r4 "KLIENTU ATLIKUMI    " AT 20
      "uz " + STRING(sdt)   FORMAT "x(40)" SKIP(1).
    IF pobo[3] GT 0 THEN
    PUT STREAM r4 sobo[3]   " - "   pobo[3] coda  SKIP(1).
    ELSE
    PUT STREAM r4 sobo[3]   " - un vairak  " FORMAT "x(14)" coda SKIP(1).
  END.
END.



FOR EACH aaa WHERE aaa.crc EQ crc AND aaa.lgr GT "200"
    AND aaa.lgr LT "300" NO-LOCK:
  atk = aaa.cr[1] - aaa.dr[1].
  DISP STREAM ter aaa.aaa atk WITH FRAME sda.
  PAUSE 0.
  IF sobo[1] GT 0 OR pobo[1] GT 0  THEN
  DO:
    IF (atk GE sobo[1] AND atk LT pobo[1]) THEN
    DO:
      FIND FIRST cif WHERE cif.cif EQ aaa.cif NO-LOCK NO-ERROR.
      IF AVAILABLE(cif) THEN
      DO:
        IF cif.type EQ "X" THEN
        DO:
          atx[1] = atx[1] + atk.
          tpa    =  "X" .
        END.
        ELSE
        DO:
          atp[1] = atp[1] + atk.
          tpa = " ".
        END.
        DISP STREAM r2 cif.cif tpa  trim(trim(cif.prefix) + " " + trim(cif.name)) @ cif.name aaa.aaa atk aaa.crc
          WITH DOWN WIDTH 130 FRAME sas.
      END.

    END.
  END.
  ELSE
  DO:
    IF sobo[1] GT 0 AND pobo[1] EQ 0 THEN
    DO:
      bne = TRUE.
      IF atk GE sobo[1] THEN
      DO:
        FIND FIRST cif WHERE cif.cif EQ aaa.cif NO-LOCK NO-ERROR.
        IF AVAILABLE(cif) THEN
        DO:
          IF cif.type EQ "X" THEN
          DO:
            atx[1] = atx[1] + atk.
            tpa    =  "X" .
          END.
          ELSE
          DO:
            atp[1] = atp[1] + atk.
            tpa = " ".
          END.
          DISP STREAM r2 cif.cif tpa  trim(trim(cif.prefix) + " " + trim(cif.name)) @ cif.name aaa.aaa atk aaa.crc
            WITH DOWN WIDTH 130 FRAME sas.
        END.

      END.
    END.
  END.
  IF NOT bne THEN
  DO:
    IF sobo[2] GT 0 AND pobo[2] GT 0  THEN
    DO:
      IF (atk GE sobo[2] AND atk LT pobo[2]) THEN
      DO:
        FIND FIRST cif WHERE cif.cif EQ aaa.cif NO-LOCK NO-ERROR.
        IF AVAILABLE(cif) THEN
        DO:
          IF cif.type EQ "X" THEN
          DO:
            atx[2] = atx[2] + atk.
            tpb = "X" .
          END.
          ELSE
          DO:
            atp[2] = atp[2] + atk.
            tpb = " ".
          END.
          DISP STREAM r3 cif.cif tpb trim(trim(cif.prefix) + " " + trim(cif.name)) @ cif.name aaa.aaa atk aaa.crc
            WITH DOWN WIDTH 130 FRAME sbs.
        END.

      END.
    END.
    ELSE
    IF sobo[2] GT 0 AND pobo[2] EQ 0 THEN
    DO:
      bne = TRUE.
      IF atk GE sobo[2] THEN
      DO:
        FIND FIRST cif WHERE cif.cif EQ aaa.cif NO-LOCK NO-ERROR.
        IF AVAILABLE(cif) THEN
        DO:
          IF cif.type EQ "X" THEN
          DO:
            atx[2] = atx[2] + atk.
            tpb = "X" .
          END.
          ELSE
          DO:
            atp[2] = atp[2] + atk.
            tpb = " ".
          END.
          DISP STREAM r3 cif.cif tpb trim(trim(cif.prefix) + " " + trim(cif.name)) @ cif.name aaa.aaa atk aaa.crc
            WITH DOWN WIDTH 130 FRAME sbs.
        END.

      END.
    END.
  END.
  IF NOT bne THEN
  DO:
    IF sobo[3] GT 0 AND pobo[3] GT 0  THEN
    DO:
      IF (atk GE sobo[3] AND atk LT pobo[3]) THEN
      DO:
        FIND FIRST cif WHERE cif.cif EQ aaa.cif NO-LOCK NO-ERROR.
        IF AVAILABLE(cif) THEN
        DO:
          IF cif.type EQ "X" THEN
          DO:
            atx[3] = atx[3] + atk.
            tpc = "X" .
          END.
          ELSE
          DO:
            atp[3] = atp[3] + atk.
            tpc = " ".
          END.
          DISP STREAM r4 cif.cif tpc trim(trim(cif.prefix) + " " + trim(cif.name)) @ cif.name aaa.aaa atk aaa.crc
            WITH DOWN WIDTH 130 FRAME scs.
        END.

      END.
    END.
    ELSE
    IF sobo[3] GT 0 AND pobo[3] EQ 0 THEN
    DO:
      bne = TRUE.
      IF atk GE sobo[3] THEN
      DO:
        FIND FIRST cif WHERE cif.cif EQ aaa.cif NO-LOCK NO-ERROR.
        IF AVAILABLE(cif) THEN
        DO:
          IF cif.type EQ "X" THEN
          DO:
            atx[3] = atx[3] + atk.
            tpc = "X" .
          END.
          ELSE
          DO:
            atp[3] = atp[3] + atk.
            tpc = " ".
          END.
          DISP STREAM r4 cif.cif tpc trim(trim(cif.prefix) + " " + trim(cif.name)) @ cif.name aaa.aaa atk aaa.crc
            WITH DOWN WIDTH 130 FRAME scs.
        END.

      END.
    END.
  END.
  bne = FALSE.
  atk = 0.


END.
HIDE FRAME sda.

PUT STREAM r2 SKIP(2).
PUT STREAM r3 SKIP(2).
PUT STREAM r4 SKIP(2).

IF sobo[1] GT 0 OR pobo[1] GT 0  THEN
DO:
  PUT STREAM r2 "X klienti KOP…:" atx[1] "  " atx[1] * 100 / (atx[1] + atp[1])
    FORMAT "zz9.99"  "%% " FORMAT "x(3)" SKIP(1).
  PUT STREAM r2 "P–rёjie   KOP…:" atp[1] "  " atp[1] * 100 / (atx[1] + atp[1])
    FORMAT "zz9.99" "%% " FORMAT "x(3)" SKIP(1).
END.
IF sobo[2] GT 0  THEN
DO:
  PUT STREAM r3 "X klienti KOP…:" atx[2] "  " atx[2] * 100 / (atx[2] + atp[2])
    FORMAT "zz9.99"  "%% " FORMAT "x(3)" SKIP(1).
  PUT STREAM r3 "P–rёjie   KOP…:" atp[2] "  " atp[2] * 100 / (atx[2] + atp[2])
    FORMAT "zz9.99" "%% " FORMAT "x(3)" SKIP(1).
END.
IF sobo[3] GT 0  THEN
DO:
  PUT STREAM r4 "X klienti KOP…:" atx[3] "  " atx[3] * 100 / (atx[3] + atp[3])
    FORMAT "zz9.99"  "%% " FORMAT "x(3)" SKIP(1).
  PUT STREAM r4 "P–rёjie   KOP…:" atp[3] "  " atp[3] * 100 / (atx[3] + atp[3])
    FORMAT "zz9.99" "%% " FORMAT "x(3)" SKIP(1).
END.

PUT STREAM r2 SKIP(4).
PUT STREAM r3 SKIP(4).
PUT STREAM r4
  "=================  DOKUMENTA BEIGAS  ==================" SKIP(15).

OUTPUT STREAM ter CLOSE.
OUTPUT STREAM r2 CLOSE.
OUTPUT STREAM r3 CLOSE.
OUTPUT STREAM r4 CLOSE.
UNIX silent /bin/cat r2.txt r3.txt r4.txt > rpt.img.
UNIX silent /bin/rm -f r2.txt.
UNIX silent /bin/rm -f r3.txt.
UNIX silent /bin/rm -f r4.txt.

UNIX silent prit -scr rpt.img.
