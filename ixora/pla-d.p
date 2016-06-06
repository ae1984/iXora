/* pla-d.p
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

/*  pla-d.p
 01.07.2000 - печать платежки

*/
DEF SHARED VAR vld AS CHAR.
def shared var g-ofc like ofc.ofc.
DEF VAR cda AS CHAR EXTENT 5 INIT ["Ls","USD","DEM","",""].
DEF VAR cdr AS CHAR EXTENT 5 INIT ["RUR","USD","DEM","UAK","BUR"].
DEF VAR cdn AS CHAR EXTENT 5 INIT ["Руб.","USD","DEM","Крб.","Белорус.руб."].

DEF VAR cfa AS CHAR EXTENT 5 INIT ["sant.","","","",""].
DEF VAR cfr AS CHAR EXTENT 5 INIT [" ."," ."," ."," ."," ."].
DEF VAR csa AS CHAR.
DEF VAR cipa AS CHAR.

DEF VAR big AS LOG INIT TRUE.
DEF  SHARED VAR v-nmb LIKE pla.nmb.

DEF VAR amy AS CHAR.
DEF VAR name AS CHAR INIT "".
DEF VAR stk AS CHAR EXTENT 5 INIT "".
DEF VAR nt AS INT INIT 36.
DEF VAR jj AS INT INIT 1.

DEF VAR short AS LOG INIT TRUE. /* исплз. сокращения млн. млрд. тыс.*/

FIND FIRST pla WHERE pla.who EQ g-ofc  AND pla.lang EQ vld NO-ERROR.
DEF VAR ii AS INT INIT 1.
DEF VAR nn AS INT INIT 0.
IF vld EQ "l" THEN
DO:
  FORM "Druk–t " ii FORMAT "zz9" "kopijas"  WITH ROW 7  NO-LABEL
    OVERLAY CENTERED FRAME gg.
  VIEW FRAME gg.
  UPDATE ii WITH FRAME gg.
  REPEAT:
    IF TRIM(pla.code) EQ cda[jj] THEN
    DO:
      csa = cfa[jj].
      IF jj = 1 THEN
      DO: /* обработка латов */
        cipa = SUBSTRING(STRING(pla.summ,"zzzzzzzzzzz9.99"),12,1).
        IF cipa EQ "1" THEN
        cda[jj] = "lats".
        ELSE
        cda[jj] = "lati".
      END.
      RUN Sm-vrd(INPUT pla.summ , OUTPUT name).
      LEAVE.
    END.
    jj = jj + 1.
    IF jj = 5 THEN
    DO:
      cda[jj] = pla.code.
      csa = " .".
      RUN Sm-vrd(INPUT pla.summ , OUTPUT name).
      LEAVE.
    END.
  END.
  amy = SUBSTRING(STRING(pla.summ,"999999999999.99"),14,2).
  name = name + " " +  TRIM(cda[jj]) + "  " +  amy +   " " + csa.
  jj = 1.
  REPEAT:
    RUN  rin-dal(INPUT-OUTPUT name, OUTPUT stk[jj], INPUT nt).
    IF LENGTH(stk[jj]) EQ 0 THEN
    LEAVE.
    jj = jj + 1.
    IF jj = 2 THEN
    nt = 51.
  END.
  OUTPUT TO pla.txt.
  REPEAT WHILE ii NE 0:
    PUT FILL("-",67)  FORMAT "x(67)" SKIP.
    PUT   "MAKS…№ANAS UZDEVUMS  Nr. " AT 20 pla.nmb ":" AT 67 SKIP.
    PUT  STRING(pla.regdt,"99/99/99") AT 25  " g." ":" AT 67 SKIP.
    PUT  CHR(27) + "E"   FORMAT "x(2)" "Maks–t–js:"
      CHR(27) + "F"   FORMAT "x(2)"
      "DEBETS"  AT 48    "SUMMA" AT 62 ":" AT 71  SKIP.
    PUT pla.ma1 FILL("-",26) FORMAT "x(26)" AT 41  ":" SKIP.
    PUT pla.ma2
      CHR(27) + "E"   FORMAT "x(2)" pla.rs1 AT 43
      CHR(27) + "F"   FORMAT "x(2)"
      pla.code AT 63  ":" AT 71 SKIP.
    PUT  CHR(27) + "E"  FORMAT "x(2)" "Maks–t–ja banka:"
      pla.rs2 AT 43
      CHR(27) + "F"   FORMAT "x(2)"
      ":" AT 71  SKIP.
    PUT pla.ba1
      CHR(27) + "E"   FORMAT "x(2)"
      pla.summ AT 51
      CHR(27) + "F"   FORMAT "x(2)"
      ":" AT 71 SKIP.
    PUT pla.ba2
      CHR(27) + "E"   FORMAT "x(2)" pla.kb2 AT 43
      CHR(27) + "F"   FORMAT "x(2)"
      ":" AT 71 SKIP.
    PUT FILL("-",66) FORMAT "x(66)"  ":" SKIP.
    PUT CHR(27) + "E"    FORMAT "x(2)" "Sa‡ёmёjs:"
      CHR(27) + "F"  FORMAT "x(2)"
      "KRED§TS" AT 48 ":"  AT 71 SKIP.
    PUT pla.sa1 FILL("-",26) FORMAT "x(26)" AT 41  ":"  SKIP.
    PUT pla.sa2
      CHR(27) + "E"   FORMAT "x(2)" pla.rs3 AT 43
      CHR(27) + "F"   FORMAT "x(2)"
      ":" AT 71 SKIP.
    PUT  CHR(27) + "E"  FORMAT "x(2)" "Sa‡ёmёja banka:"
      pla.rs4 AT 43
      CHR(27) + "F"  FORMAT "x(2)"
      ":"  AT 71 SKIP.
    PUT pla.ba3
      ":" AT 67 SKIP.
    PUT pla.ba4
      CHR(27) + "E"   FORMAT "x(2)" pla.kb4 AT 43
      CHR(27) + "F"   FORMAT "x(2)"
      ":" AT 71 SKIP.
    PUT FILL("-",66) FORMAT "x(66)"  ":" SKIP.
    PUT "Summa v–rdiem: " stk[1] FORMAT "x(36)" ":" AT 53 ":" AT 67 SKIP.
    PUT stk[2] FORMAT "x(51)"  ":" AT 53 "Veids " pla.ve   ":" AT 67 SKIP.
    PUT stk[3] FORMAT "x(51)"  ":" AT 53  ":" AT 67 SKIP.
    PUT stk[4] FORMAT "x(51)"  ":" AT 53 "-------------"   ":" AT 67 SKIP.
    PUT stk[5] FORMAT "x(51)"  ":" AT 53  ":" AT 67 SKIP.
    PUT "Maks–juma mёr±is:" ":" AT 53 "Mёr±is " pla.me  ":" AT 67 SKIP.
    PUT pla.ap[1]        ":" AT 53 ":" AT 67 SKIP.
    PUT pla.ap[2]        "--------------"  AT 53  ":" SKIP.
    PUT pla.ap[3]        ":" AT 67 SKIP.
    PUT pla.ap[4]        ":" AT 67 SKIP.
    PUT pla.ap[5]        ":" AT 67 SKIP.
    PUT "Bankas oper–cija veikta" AT 40 ":" AT 67 SKIP.
    PUT "Z.V." AT 7  ":" AT 67 SKIP.
    PUT "Klienta paraksti" AT 3 "Bankas paraksti" AT 48 ":" AT 67 SKIP.
    PUT ":" AT 67 SKIP.
    PUT FILL("-",67)  FORMAT "x(67)" SKIP.

    nn = nn + 1.
    IF nn = ii then
    DO:
      LEAVE.
    END.
    ELSE
    DO:
      IF nn MODULO 2  EQ  1 THEN
      PUT SKIP(2).
      ELSE
      PUT CHR(12) FORMAT "x(1)".
    END.
  END.
  PUT SKIP(15).
  OUTPUT CLOSE.
END.
ELSE
DO:
  FORM "Печатать " ii FORMAT "zz9" "копий"  WITH ROW 7  NO-LABEL
    OVERLAY CENTERED FRAME gga.
  VIEW FRAME gga.
  UPDATE ii WITH FRAME gga.
  jj = 1.
  REPEAT:
    IF  TRIM(pla.code) EQ cdr[jj] THEN
    DO:
      csa = cfr[jj].
      cdr[jj] = cdn[jj].
      RUN Sm-vrd(INPUT pla.summ , OUTPUT name).
      LEAVE.
    END.
    jj = jj + 1.
    IF jj > 5 THEN
    DO:
      jj = jj - 1.
      cdr[jj] = pla.code.
          csa = " .".
      RUN Sm-vrd(INPUT pla.summ , OUTPUT name).
      LEAVE.
    END.
  END.
  amy = SUBSTRING(STRING(pla.summ,"999999999999.99"),14,2).
 /* name = TRIM(cdr[jj])+ " " + name + "  " + amy + " " + csa. */
   name = name + " " + TRIM(cdr[jj])+ " "  + amy + " " + "тиын".
    jj = 1.
  REPEAT:
    RUN  rin-dal(INPUT-OUTPUT name, OUTPUT stk[jj], INPUT nt).
    IF LENGTH(stk[jj]) EQ 0 THEN        
    LEAVE.
    jj = jj + 1.
    IF jj = 2 THEN
    nt = 51.
  END.
  OUTPUT TO pla.txt.
  REPEAT WHILE ii NE 0:
    PUT   "ПЛАТЕЖНОЕ ПОРУЧЕНИЕ  # " AT 20 pla.nmb  SKIP.
    PUT  STRING(pla.regdt,"99/99/99") AT 25  " г." SKIP.
    PUT   "СУММА" AT 60   SKIP.
    PUT FILL("-",70)  FORMAT "x(70)" SKIP.
    PUT   "Отправитель денег:"
          ":" at 35
          "ИИК"  AT 41  
          ":"    at 46
          "КОд"  AT 48
          ":"    at 52 
          pla.summ format '>,>>>,>>>,>>9.99' 
          ":" AT 70  SKIP.
    put   pla.ma1 format 'x(34)'
          ":" at 35
          ":" at 46
          pla.ve format 'x(2)' at 49
          ":" at 52
          ":" at 70 SKIP.
    put    
          ":" at 35
          pla.rs1 at 36
          ":-----:" at 46
          ":" at 70 SKIP.
    PUT "РНН " 
        pla.ma2 format 'x(12)'
        ":" at 35
        ":" at 52       
        ":" AT 70 SKIP.
    PUT ":----------------:" at 35
                            ":" AT 70 SKIP.
    PUT "Банк-получатель:"
        ":" at 35
        "БИК" AT 41
        ":" at 52
        ":" AT 70  SKIP.
    PUT pla.ba1 format 'x(34)'
        ":" at 35
        pla.kb2 at 36
        ":" at 52      
        ":" AT 70 SKIP.
    PUT FILL("-",34) FORMAT "x(34)"
        ":" at 35
        ":----------------:" at 35
        ":"  at 70 SKIP.
    PUT  "Бенефициар:"
         ":" at 35
         "ИИК"  AT 41
         ":"    at 46
         "КБе"  AT 48
         ":"    at 52
         ":" AT 70  SKIP.
    put  pla.sa1 format 'x(34)'
         ":" at 35
         ":" at 46
         pla.me format 'x(2)' at 49
         ":" at 52
         ":" at 70 SKIP.
    put  ":" at 35
         pla.rs2 at 36
         ":-----:" at 46
         ":" at 70 SKIP.
    PUT "РНН "
         pla.sa2 format 'x(12)'
         ":" at 35
         ":" at 52
         ":" AT 70 SKIP.
    PUT ":----------------:" at 35
        ":" AT 70 SKIP.
    PUT "Банк бенефициара:"
        ":" at 35
        "БИК" AT 41
        ":" at 52
        ":" AT 70  SKIP.
    PUT pla.ba2 format 'x(34)'
        ":" at 35
        pla.kb4 at 36
        ":" at 52
        ":" AT 70 SKIP.
    PUT FILL("-",70)  FORMAT "x(70)" SKIP.

    PUT "Сумма прописью: " stk[1] FORMAT "x(52)"  ":" AT 70 SKIP.
    PUT stk[2] FORMAT "x(68)"  ":" AT 70 SKIP.
    PUT FILL("-",25)  FORMAT "x(25)" at 45 
        ":" AT 70 SKIP.
    put "Дата получения товара (оказания услуг)"
        ":" at 44
        "Код назначения" at 45
        ":" at 59
        pla.rs3 format 'x(3)' at 62
        ":" AT 70 SKIP.
    put pla.ba3 format 'x(12)'
            ":" at 44
            "платежа       " at 45
            ":" at 59
            ":" AT 70 SKIP.
    PUT "Назначение платежа:"
        ":" at 44
        FILL("-",25)  FORMAT "x(25)" at 45
        ":" AT 70 SKIP.
    PUT pla.ap[1] format 'x(43)'
        ":" at 44
        "Код бюджетной " at 45
        ":" at 59
        pla.rs4 format 'x(6)' at 62
        ":" AT 70 SKIP.
    PUT pla.ap[2] format 'x(43)'  
        ":" at 44
        "классификации " at 45
        ":" at 59
        ":" AT 70 SKIP.
    PUT pla.ap[3] format 'x(43)'
        FILL("-",25)  FORMAT "x(25)" at 45
        ":" AT 70 SKIP.
    PUT pla.ap[4] format 'x(43)'  
        ":" at 44
        "Дата          " at 45
        ":" at 59
        pla.ba4 format 'x(10)' at 60
        ":" AT 70 SKIP.
    PUT pla.ap[5] format 'x(43)'       
        ":" at 44
        "валютирования " at 45
        ":" at 59
        ":" AT 70 SKIP.
    PUT FILL("-",70)  FORMAT "x(70)" SKIP.
    PUT "Проведено банком-получателем"  at 40  SKIP.
    PUT "М.П." AT 7    SKIP.    
    PUT "Подписи клиента" AT 3 "Подписи банка" AT 48 sKIP.
                                    
    nn = nn + 1.
    IF nn  = ii THEN LEAVE.
    ELSE PUT SKIP(4).
  END.
  PUT SKIP(2).
  OUTPUT CLOSE.
END.
UNIX silent prit -t pla.txt. 
HIDE ALL.
