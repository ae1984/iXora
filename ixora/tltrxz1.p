/* tltrxz1.p
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
        01.11.2004 Добавил проверку на наличие прав в кодификаторе control
*/

/* tltrxz1.p
Sushinin Vladimir
*/

{global.i}

DEF var m-fun AS char.
DEF var dest AS char.
DEF var v-copy AS int.
DEF VAR sts1 AS LOGICAL.
DEF VAR sts2 AS LOGICAL.


DEF STREAM m-out1.
DEF STREAM m-out2.
DEF STREAM m-out3.
DEF var m-count AS integer initial 0.
DEF var m-cashgl AS integer.
DEF var m-first1 AS logical.
DEF var m-var1 AS logical.
DEF var m-first2 AS logical.
DEF var m-var2 AS logical.
DEF var m-amtd as dec.
DEF var m-amtk as dec.
DEF var m-sumdk1 as dec.
DEF var m-sumkk1 as dec.
DEF var m-sumd1 as dec.
DEF var m-sumk1 as dec.
DEF var m-sumdk2 as dec.
DEF var m-sumkk2 as dec.
DEF var m-sumd2 as dec.
DEF var m-sumk2 as dec.

DEF var m-diff as dec.
DEF var m-stn as int.
DEF var m-sts LIKE jh.sts.
DEF var m-title AS char.
DEF var m-stsstr AS char.
DEF var m-char AS char.
DEF var i AS int.
DEF var j AS int.
DEF var m-keyofcjl AS log.
DEF var m-keyofc AS log.
DEF var vtitle AS char FORMAT "x(132)".
DEF var vtoday AS date.
DEF var vtime AS char.
DEF var tek-dat AS date.
DEF var v-ofc LIKE ofc.ofc.


DEF var v-nbabeg LIKE gl.gl.
DEF var v-nbaend LIKE gl.gl.
DEF var v-nbpbeg LIKE gl.gl.
DEF var v-nbpend LIKE gl.gl.
DEF var m-str AS char.

def var v-ret as log.

v-ofc = g-ofc.
m-fun = "TLTRX".
dest = "prit".
v-copy = 1.
{tlprompt.f}
VIEW FRAME image1.
UPDATE dest  WITH FRAME image1 no-box.
UPDATE v-ofc VALIDATE(can-find(ofc where ofc.ofc = v-ofc use-index ofc), "")
   tek-dat  VALIDATE (tek-dat < g-today + 10, "")
   v-copy  validate(v-copy ge 1,"")  WITH FRAME image1 no-box.
HIDE FRAME image1.

run check_control (g-ofc, v-ofc, output v-ret) .
if not v-ret then do:
    message "У вас недостаточно прав на просмотр " + v-ofc  view-as alert-box.
end. 

FIND sysc WHERE sysc.sysc eq "GLARPB" NO-LOCK.
IF AVAILABLE sysc THEN
DO:
  m-str = chval.
  v-nbabeg = integer(substring(m-str,1,INDEX(m-str,',') - 1)).
  m-str = substring(m-str,INDEX(m-str,',') + 1).
  v-nbaend = integer(substring(m-str,1,INDEX(m-str,',') - 1)).
  m-str = substring(m-str,INDEX(m-str,',') + 1).
  v-nbpbeg = integer(substring(m-str,1,INDEX(m-str,',') - 1)).
  m-str = substring(m-str,INDEX(m-str,',') + 1).
  v-nbpend = integer(substring(m-str,1,INDEX(m-str,',') - 1)).
END.
ELSE
DO:
  v-nbabeg = 300000.
  v-nbaend = 400000.
  v-nbpbeg = 600000.
  v-nbpend = 700000.
END.


DEF WORKFILE otl
  FIELD gl LIKE gl.gl
  FIELD cam LIKE jl.cam
  FIELD dam LIKE jl.cam
  FIELD ncam AS int
  FIELD ndam AS int.



FIND sysc WHERE sysc.sysc eq "cashgl" NO-LOCK NO-ERROR .
IF AVAILABLE sysc THEN
m-cashgl = sysc.inval.

FOR EACH otl.
  DELETE otl.
END.



OUTPUT STREAM m-out1 TO VALUE (lc(TRIM(v-ofc)) + "msos.txt").
OUTPUT STREAM m-out2 TO VALUE ( lc(TRIM(v-ofc)) + "mson.txt").


sts1 = FALSE.
sts2 = FALSE.


m-var1 = FALSE.
m-var2 = FALSE.



FIND FIRST jl WHERE jl.who = v-ofc AND jl.jdt = tek-dat USE-INDEX jlwho
  NO-LOCK NO-ERROR.

IF AVAILABLE jl THEN
DO:

  PUT STREAM m-out1 CHR(15).
  {tltrx1_01.f}


  HIDE FRAME tltrxh1.

  PUT STREAM m-out2 CHR(15).
  {tltrx1_02.f}
  HIDE FRAME tltrxh2.


  FOR EACH jl WHERE jl.who = v-ofc  AND  jl.jdt = tek-dat
      USE-INDEX jlwho  NO-LOCK  BREAK BY jl.crc BY jl.jh BY jl.ln:

    FIND jh WHERE jh.jh = jl.jh USE-INDEX jh NO-LOCK.
    m-sts = jh.sts.

    IF FIRST-OF(jl.crc) THEN
    DO:
      FIND crc WHERE crc.crc = jl.crc NO-LOCK NO-ERROR.
      {tltrx0.f}
      m-first1 = NO.
      m-first2 = NO.
      m-sumk1 = 0.
      m-sumd1 = 0.
      m-sumkk1 = 0.
      m-sumdk1 = 0.
      m-sumk2 = 0.
      m-sumd2 = 0.
      m-sumkk2 = 0.
      m-sumdk2 = 0.

    END.

    IF NOT (jh.party BEGINS "RETAIL") THEN
    DO:

      IF NOT m-first1 AND m-sts >= 6 THEN
      DO:
        m-first1 = TRUE.
        VIEW STREAM m-out1 FRAME crc.
        HIDE FRAME crc.
      END.

      IF NOT m-first2 AND m-sts < 6 THEN
      DO:
        m-first2 = TRUE.
        VIEW STREAM m-out2 FRAME crc.
        HIDE FRAME crc.
      END.

      m-amtk = 0.
      m-amtd = 0.

      IF jl.dc eq "D"  THEN
      DO:
        IF m-sts >= 6 THEN
        DO:
          IF jl.gl = m-cashgl THEN
          m-sumdk1 = m-sumdk1 + jl.dam.
          m-sumd1 = m-sumd1 + jl.dam.
        END.
        ELSE
        DO:
          IF jl.gl = m-cashgl THEN
          m-sumdk2 = m-sumdk2 + jl.dam.
          m-sumd2 = m-sumd2 + jl.dam.
        END.
        m-amtd = jl.dam.
      END.
      ELSE
      DO:
        IF m-sts >= 6 THEN
        DO:
          IF jl.gl = m-cashgl THEN
          m-sumkk1 = m-sumkk1 + jl.cam.
          m-sumk1 = m-sumk1 + jl.cam.
        END.
        ELSE
        DO:
          IF jl.gl = m-cashgl THEN
          m-sumkk2 = m-sumkk2 + jl.cam.
          m-sumk2 = m-sumk2 + jl.cam.
        END.
        m-amtk = jl.cam.
      END.

      m-char = string(jl.tim,"HH:MM:SS").
      IF m-sts = 1  THEN
      m-stsstr = "Err".
      ELSE
      m-stsstr = "   ".
      {tltrx2.f}
      IF  m-sts >= 6 THEN
      DISPLAY STREAM m-out1 m-char
        jl.jh jl.ln jl.gl jl.acc m-amtd m-amtk
        jl.teller m-sts m-stsstr
        WITH FRAME jltl .
      ELSE
      DISPLAY STREAM m-out2 m-char
        jl.jh jl.ln jl.gl jl.acc m-amtd m-amtk
        jl.teller m-sts m-stsstr
        WITH FRAME jltl .

      FIND FIRST otl WHERE otl.gl = jl.gl  EXCLUSIVE-LOCK
        NO-ERROR.
      IF NOT AVAILABLE otl THEN
      DO:
        CREATE otl.
        otl.gl = jl.gl.
      END.
      IF jl.dc eq "D" THEN
      DO:
        otl.dam = otl.dam + jl.dam.
        otl.ndam = otl.ndam + 1.
      END.
      ELSE
      DO:
        otl.cam = otl.cam + jl.cam.
        otl.ncam = otl.ncam + 1.
      END.

    END.

    IF LAST-OF ( jl.crc ) THEN
    DO:
      IF m-first1 THEN
      DO:
        HIDE FRAME jltl.
        m-var1 = TRUE.
        {tltrx41.f}
        DISPLAY STREAM m-out1 m-sumd1 m-sumk1
          WITH FRAME tl1total1.
        HIDE FRAME tl1total1.
        {tltrx31.f}
        m-diff = m-sumdk1 - m-sumkk1.
        DISPLAY STREAM m-out1
          m-sumdk1 m-sumkk1 m-diff WITH FRAME tltotal1.
        HIDE FRAME tltotal1.
      END.
      IF m-first2 THEN
      DO:
        m-var2 = TRUE.
        {tltrx42.f}
        DISPLAY STREAM m-out2 m-sumd2 m-sumk2
          WITH  FRAME tl1total2.
        HIDE FRAME tl1total2.
        HIDE FRAME jltl.
        {tltrx32.f}
        m-diff = m-sumdk2 - m-sumkk2.
        DISPLAY STREAM m-out2
          m-sumdk2 m-sumkk2 m-diff WITH FRAME tltotal2.
        HIDE FRAME tltotal2.
      END.
    END.
  END. /* for each jl */
END.



IF m-var1 THEN
sts1 = TRUE.

IF m-var2 THEN
sts2 = TRUE.


/*
FIND FIRST aal WHERE aal.who = v-ofc AND aal.regdt = tek-dat USE-INDEX aalwho
  NO-LOCK NO-ERROR.

IF AVAILABLE aal THEN
DO:

  IF NOT sts1 AND NOT sts2  THEN
  DO:
    PUT STREAM m-out1 CHR(15).
    {tltrx1_010.f}
    HIDE FRAME tltrxh10.
    m-var1 = FALSE.

    PUT STREAM m-out2 CHR(15).
    {tltrx1_020.f}
    HIDE FRAME tltrxh20.
    m-var2 = FALSE.
  END.


  FOR EACH aal WHERE aal.who = v-ofc  AND  aal.regdt = tek-dat  AND
      (aal.aax <> 21 AND aal.aax <> 22 AND aal.aax <> 23) USE-INDEX aalwho
      NO-LOCK  BREAK BY aal.crc BY aal.aah BY aal.ln:

    FIND aah WHERE aah.aah = aal.aah NO-LOCK NO-ERROR.
    IF AVAILABLE aah THEN
    m-stn = aah.stn.
    ELSE
    m-stn = 1.


    IF FIRST-OF(aal.crc) THEN
    DO:
      FIND crc WHERE crc.crc = aal.crc NO-LOCK.
      {tltrxc.f}
      m-first1 = NO.
      m-first2 = NO.
      m-sumk1 = 0.
      m-sumd1 = 0.
      m-sumkk1 = 0.
      m-sumdk1 = 0.
      m-sumk2 = 0.
      m-sumd2 = 0.
      m-sumkk2 = 0.
      m-sumdk2 = 0.
    END.

    FIND jh WHERE jh.jh = aal.jh USE-INDEX jh NO-LOCK.
    IF (jh.party BEGINS "RETAIL") THEN
    DO:

      FIND aax WHERE aax.lgr eq aal.lgr AND aax.ln eq aal.aax NO-LOCK
        NO-ERROR.

      m-char = string(aal.tim,"HH:MM:SS").
      m-amtd = 0.
      m-amtk = 0.
      IF aax.cash <> ? THEN
      DO:
        IF aax.cash eq TRUE  THEN
        DO:
          IF m-stn >= 6 THEN
          m-sumdk1 = m-sumdk1 + aal.amt.
          ELSE
          m-sumdk2 = m-sumdk2 + aal.amt.
        END.
        ELSE
        IF aax.cash eq FALSE THEN
        DO:
          IF m-stn >= 6 THEN
          m-sumkk1 = m-sumkk1 + aal.amt.
          ELSE
          m-sumkk2 = m-sumkk2 + aal.amt.
        END.
      END.
      IF m-stn = 1
        THEN
      m-stsstr = "Err".
      ELSE
      m-stsstr = "   ".


      IF m-stn >= 6 THEN
      DO:
        IF NOT m-first1  THEN
        DO:
          m-first1 = TRUE.
          VIEW STREAM m-out1 FRAME crc1.
          HIDE FRAME crc1.
        END.
        {tltrx1.f}
        DISPLAY STREAM m-out1 m-char
          aal.aah FORMAT 'zzzzzzz9' aal.ln aal.jh aal.aax aax.des aal.aaa
          aal.amt FORMAT "z,zzz,zzz,zzz,zz9.99-"
          aal.teller m-stn m-stsstr
          WITH FRAME aaltl.
      END.

      IF m-stn < 6 THEN
      DO:
        IF NOT m-first2  THEN
        DO:
          m-first2 = TRUE.
          VIEW STREAM m-out2 FRAME crc1.
          HIDE FRAME crc1.
        END.
        {tltrx1.f}
        DISPLAY STREAM m-out2 m-char
          aal.aah FORMAT 'zzzzzzz9' aal.ln aal.jh aal.aax aax.des aal.aaa
          aal.amt FORMAT "z,zzz,zzz,zzz,zz9.99-"
          aal.teller m-stn m-stsstr
          WITH FRAME aaltl.
      END.

      IF aax.dgl ne 0 THEN
      DO:
        FIND FIRST otl WHERE otl.gl = aax.dgl  NO-ERROR.
        IF NOT AVAILABLE otl THEN
        DO:
          CREATE otl.
          otl.gl = aax.dgl.
        END.
        otl.dam = otl.dam + aal.amt.
        otl.ndam = otl.ndam + 1.
      END.
      IF aax.cgl ne 0 THEN
      DO:
        FIND FIRST otl WHERE otl.gl = aax.cgl  NO-ERROR.
        IF NOT AVAILABLE otl THEN
        DO:
          CREATE otl.
          otl.gl = aax.cgl.
        END.
        otl.cam = otl.cam + aal.amt.
        otl.ncam = otl.ncam + 1.
      END.
    END.

    IF LAST-OF (aal.crc) THEN
    DO:
      IF m-first1 THEN
      DO:
        m-var1 = TRUE.
        m-diff = m-sumdk1 - m-sumkk1.
        {tltrx61.f}
        DISPLAY STREAM m-out1
          m-sumdk1 m-sumkk1 m-diff WITH  FRAME tltotal61.
        HIDE FRAME tltotal61.
        HIDE FRAME aaltl.
      END.
      IF m-first2 THEN
      DO:
        m-var2 = TRUE.
        m-diff = m-sumdk2 - m-sumkk2.
        {tltrx62.f}
        DISPLAY STREAM m-out2
          m-sumdk2 m-sumkk2 m-diff WITH FRAME tltotal62.
        HIDE FRAME tltotal62.
        HIDE FRAME aaltl.
      END.

    END. 

  END. 


  IF m-var1 THEN
  sts1 = TRUE.

  IF m-var2 THEN
  sts2 = TRUE.


END. 
*/


OUTPUT STREAM m-out3 TO VALUE ( lc(TRIM(v-ofc)) + "sum.txt")  page-size 59.
IF NOT sts1 AND NOT sts2 THEN
DO:
  PUT STREAM m-out1 CHR(15).
  PUT STREAM m-out2 CHR(15).
  {tltrx1_011.f}
  {tltrx1_021.f}
  HIDE FRAME tltrxh11.
  HIDE FRAME tltrxh21.
END.




{tltrx5.f}

IF NOT sts1 THEN
VIEW STREAM m-out1 FRAME navvar.
IF NOT sts2 THEN
VIEW STREAM m-out2 FRAME navvar.

DISPLAY STREAM m-out1 SKIP(3).
DISPLAY STREAM m-out2 SKIP(3).

OUTPUT STREAM m-out1 close.
OUTPUT STREAM m-out2 close.

FIND ofc WHERE ofc.ofc = v-ofc NO-LOCK.
vtitle = {ofcsumt1.f} .
vtoday = tek-dat.
vtime = string(TIME,"HH:MM:SS").



FORM HEADER
  SKIP(3)
  g-comp vtoday vtime "Польз." caps(v-ofc)
  "Стр: " + string(PAGE-NUMBER, "zzz9") FORMAT "x(10)" TO 132 SKIP
  g-fname g-mdes SKIP
  vtitle FORMAT "x(132)" SKIP
  FILL("=",132) FORMAT "x(132)" SKIP
  WITH width 132 PAGE-TOP no-box NO-LABEL FRAME rpthead.
VIEW STREAM m-out3 FRAME rpthead.


FOR EACH otl WHERE NOT
    ((otl.gl ge v-nbabeg AND otl.gl lt v-nbaend) OR
    (otl.gl ge v-nbpbeg AND otl.gl lt v-nbpend))  BREAK BY otl.gl.


  FIND gl WHERE otl.gl = gl.gl NO-LOCK.
  {ofcsum.f "stream m-out3" }
END.

FOR EACH otl WHERE
    ((otl.gl ge v-nbabeg AND otl.gl lt v-nbaend) OR
    (otl.gl ge v-nbpbeg AND otl.gl lt v-nbpend))  BREAK BY otl.gl.

  FIND gl WHERE otl.gl = gl.gl NO-LOCK.
  {ofcsum.f "stream m-out3" }
END.

OUTPUT STREAM m-out3 close.

REPEAT WHILE v-copy gt 0 :
  UNIX  value(dest) value( lc(trim(v-ofc)) + "msos.txt").
  PAUSE 0.
  UNIX  value(dest) value( lc(trim(v-ofc)) + "mson.txt").
  PAUSE 0.
  UNIX  value(dest) value( lc(trim(v-ofc)) + "sum.txt").
  PAUSE 0.
  v-copy = v-copy - 1.
END.


UNIX silent rm -f value( lc(trim(v-ofc)) + "msos.txt").
UNIX silent rm -f value( lc(trim(v-ofc)) + "mson.txt").
UNIX silent rm -f value( lc(trim(v-ofc)) + "sum.txt").
 

