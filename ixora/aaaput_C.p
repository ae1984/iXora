/* aaaput_C.p
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

/* ========================================================== */
/*                                                            */
/*                  progr=  aaaput_C.p                        */
/*   uzliek kontam  slegts  =  C                              */
/*    - type = B M N                                          */
/*    - norekina konti  2XX                                   */
/*    - atlikums = 0  &                                       */
/*    - nav apgroz pedejos 6 menesus                          */
/* ========================================================   */


OUTPUT TO putCC.txt.

DEF STREAM st.
OUTPUT STREAM st TO TERMINAL.
DEF SHARED var g-ofc LIKE ofc.ofc.

DEF var dat AS date.
DEF var dd AS int .
DEF var mm AS int .
DEF var yy AS int.
DEF var cc AS int .
DEF var hb AS char FORMAT "xx" .
DEF var zz AS int .
DEF var vdep LIKE  ppoint.dep.
DEF var vpoint LIKE point.point.
DEF var ppname LIKE ppoint.name.
DEF var ddname LIKE point.addr[1].
DEF var stt AS log.


DEF SHARED var g-today AS date.
DEF var ltt AS log.     /* пpизнак удаленного счета */
DEF var jj AS int.      /* счетчик                  */
DEF var njn AS int.
DEF var smn AS int.
DEF var txt AS char.

DEF var endt AS log. /* pазpешение на закpытие счета */
DEF var badt AS char.
DEF var addt AS char.
DEF var acdt AS char.
DEF var tekdt AS char. /* текущая дата */
DEF var vecdt AS char. /* дата закpытия счетов */


dat = g-today .
/*
dat = date(03,31,1997).  */
dd = day(dat) .
mm = month(dat) .
yy = year(dat) .
IF ( mm - 6 ) le 0 THEN
DO:
  mm = ( mm + 12 ) - 6.
  yy = yy - 1.
END .
ELSE
DO:
  mm = mm - 6 .
END .
vecdt =  string(yy, "9999") + string(mm, "99") + string(dd, "99").
repeat:
  dd = day(dat).
  mm = month(dat).
  yy = year(dat).
  tekdt =  string(yy, "9999") + string(mm, "99") + string(dd, "99").
  if tekdt GT vecdt then dat = dat - 1.
  else leave.
end.                      
/*
disp stream st "Поpа закpывать счета" dat tekdt vecdt.    */

PUT SKIP(2)
  "AIZVERTIE KONTI" AT 54 SKIP
  g-today AT 53 STRING(TIME,"HH:MM:SS") AT 62 SKIP(1)
  "NAV APGROZIJUMI NO:" AT 47 dat AT 66  SKIP(2).
PUT "KIF" AT 1 "NOSAUKUMS" AT 8 "REG.Nr." AT 70 "PK" AT 87 "DP" AT 90
  "KONTS" AT 94 "ST" AT 106
  "HB" AT 109
  "ATLIKUMS" AT 112 "PED.APGR" AT 124 SKIP .
PUT "------" AT 1
  "------------------------------------------------------------" AT 8
  "---------------" AT 70 "-- --" AT 87 "----------" AT 94
  "-- -- ---------" AT 106 "--------" AT 124 SKIP(1) .

FOR EACH cif WHERE cif.type ne "P" AND cif.type ne "X"
    EXCLUSIVE-LOCK BREAK BY cif.jame BY cif.cif:
  /* закpываем клиентов "B","M","N" */
  ltt = FALSE. /* начальные условия заполнения REF. */

  FIND FIRST aaa WHERE aaa.cif = cif.cif AND aaa.aaa BEGINS "2"
    NO-ERROR .
  IF FIRST-OF(cif.jame) THEN
  DO:
    stt = TRUE.
    vpoint = int(cif.jame) / 1000 - 0.5.
    vdep = int(substring(cif.jame,3)).
    FIND FIRST point WHERE point.point = vpoint NO-LOCK NO-ERROR.
    IF AVAILABLE(point) THEN
    ddname = point.addr[1].
    ELSE
    ddname = "".
    FIND FIRST ppoint WHERE ppoint.point = vpoint AND
      ppoint.dep = vdep NO-LOCK NO-ERROR.
    IF AVAILABLE(ppoint) THEN
    ppname = ppoint.name.
    ELSE
    ppname = "".
  END.
  REPEAT WHILE  AVAILABLE aaa :
    DISP STREAM st cif.cif WITH CENTERED row 6
      TITLE "Searcing CIF" FRAME cifaaa .
    PAUSE 0.
    IF aaa.cr[1] - aaa.dr[1] <= 0 AND aaa.sta ne "C" AND aaa.sta ne "M"
      AND aaa.sta ne "D" AND aaa.sta ne "T"
      THEN
    DO:

      FIND LAST aab WHERE  aab.aaa = aaa.aaa
        NO-ERROR .
      IF AVAILABLE aab THEN
      DO:
        IF aab.avl EQ 0.00 then DO:
        IF aab.fdt EQ ?
          THEN
        DO:
          badt = "? ".
          IF aaa.cdt EQ ? THEN
          DO:
            acdt = "? ".
            IF aaa.ddt EQ ? THEN
            DO:
              addt = "? ".
              IF aaa.regdt EQ ? THEN
              endt = TRUE. /* удалять нафиг !*/
              ELSE
              IF aaa.regdt < dat THEN
              endt = TRUE.
            END.
            ELSE
            DO:
              addt = string(aaa.ddt,"99/99/99").
              IF aaa.ddt < dat THEN
              endt = TRUE.
            END.
          END.
          ELSE
          DO:
            acdt = string(aaa.cdt,"99/99/99").
            IF aaa.ddt EQ ? THEN
            DO:
              addt = "? ".
              IF aaa.cdt < dat THEN
              endt = TRUE.
            END.
            ELSE
            DO:
              addt = string(aaa.ddt,"99/99/99").
              IF aaa.ddt < dat AND aaa.cdt < dat THEN
              endt = TRUE.
            END.
          END.
        END. /* нет даты  в aab. */
        ELSE /* есть дата в aab. */
        DO:
          badt = string(aab.fdt,"99/99/99").
          IF aaa.cdt EQ ? THEN
          DO:
            acdt = "? ".
            IF aaa.ddt EQ ? THEN
            DO:
              addt = "? ".
              IF aab.fdt < dat THEN
              endt = TRUE.
            END.
            ELSE
            DO:
              addt = string(aaa.ddt,"99/99/99").
              IF aaa.ddt < dat AND aab.fdt < dat THEN
              endt = TRUE.
            END.
          END.
          ELSE
          DO:
            acdt = string(aaa.cdt,"99/99/99").
            IF aaa.ddt EQ ? THEN
            DO:
              addt = "? ".
              IF aaa.cdt < dat AND aab.fdt < dat THEN
              endt = TRUE.
            END.
            ELSE
            DO:
              addt = string(aaa.ddt,"99/99/99").
              IF aaa.ddt < dat AND aaa.cdt < dat
                AND aab.fdt < dat THEN
              endt = TRUE.
            END.
          END.
        END.
        END.
      END.
      ELSE  /* нет aab. */
      DO:
        badt = "? ".
        IF aaa.cdt EQ ? THEN
        DO:
          acdt = "? ".
          IF aaa.ddt EQ ? THEN
          DO:
            addt = "? ".
            IF aaa.regdt EQ ? THEN
            endt = TRUE. /* удалять нафиг !*/
            ELSE
            IF aaa.regdt < dat THEN
            endt = TRUE.
          END.
          ELSE
          DO:
            addt = string(aaa.ddt,"99/99/99").
            IF aaa.ddt < dat THEN
            endt = TRUE.
          END.
        END.
        ELSE
        DO:
          acdt = string(aaa.cdt,"99/99/99").
          IF aaa.ddt EQ ? THEN
          DO:
            addt = "? ".
            IF aaa.cdt < dat THEN
            endt = TRUE.
          END.
          ELSE
          DO:
            addt = string(aaa.ddt,"99/99/99").
            IF aaa.ddt < dat AND aaa.cdt < dat THEN
            endt = TRUE.
          END.
        END.
      END.
    END.
    IF endt  THEN
    DO:
      FIND FIRST aas WHERE aas.aaa = aaa.aaa
        NO-LOCK NO-ERROR .
      IF  AVAILABLE aas THEN
      hb = aas.sic.
      ELSE
      hb = "" .
      cc = int( cif.jame ) .

      IF stt THEN
      DO:
        stt = FALSE.
        PUT SKIP(2) .
        PUT SPACE(25)  ddname SKIP(0).
        PUT SPACE(25)  ppname SKIP(1).
      END.
      PUT SKIP
        cif.cif AT 1
        cif.name AT 8 FORMAT "x(60)"
        cif.jss  AT 70
        cc / 1000 AT 87 FORMAT "99"
        int (substr(cif.jame,3) )  AT 90
        FORMAT "99"
        aaa.aaa AT 94
        aaa.sta AT 106
        hb      AT 108
        aaa.cr[1] - aaa.dr[1] AT 111
        badt    AT 124  FORMAT "x(8)"
        acdt AT 133
        addt AT 142 .

      aaa.sta = "C" .
      aaa.who = g-ofc.
      aaa.whn = g-today .
      aaa.cltdt = g-today . /* пpогpамма меню 1.4 ставит в это
      поле дату закpытия и эта!!! дата используется в
      пpогpаммах,  анализиpующих дату закpытия счета*/

      IF ltt THEN
      txt = txt + "," + aaa.aaa.
      ELSE
      txt = "; " + aaa.aaa .
      ltt = TRUE.


      zz = zz + 1.

      /*   displ cif.cif aaa.aaa aaa.sta aaa.cr[1] - aaa.dr[1]
      " "   aab.fdt " " dat .     */

      endt = FALSE.
    END.
    FIND NEXT aaa WHERE aaa.cif = cif.cif AND aaa.aaa BEGINS "2"
      NO-ERROR .
  END .
  IF ltt THEN
  DO:   /* заполнение REF. если были закpыты счета */
    txt = txt +  " slёgts pёc RKB noteik. " + string(g-today,"99/99/99").
    jj = 10.
    REPEAT WHILE jj NE 1:
      IF cif.ref[jj] NE "" THEN
      LEAVE.
      jj = jj - 1.
    END.
    njn = length(TRIM(cif.ref[jj])).
    smn = 0.
    IF  njn LT 65 THEN
    DO:
      cif.ref[jj] = TRIM(cif.ref[jj]) + substring(txt,1,65 - njn).
      smn = 65 - njn.
      jj = jj + 1.
    END.
    REPEAT WHILE jj LE 10:
      IF length(TRIM(substring(txt,smn + 1))) EQ 0 THEN
      LEAVE.
      cif.ref[jj] = substring(txt,smn + 1,65).
      smn = smn + 65.
      jj = jj + 1.
    END.
    IF jj = 11 AND length(TRIM(substring(txt,smn + 1))) GT 0 THEN
    cif.ref[jj - 1] = cif.ref[jj - 1] + substring(txt,smn + 1,65).
    /*   DISP  cif.cif WITH CENTERED row 6.   pause 0.  */
  END.

END .

PUT SKIP(2)
  "========================== Dokumenta beigas ======================="
  AT 10 SKIP(1) "Kopa=" AT 5 zz SKIP(08) .
OUTPUT close.


