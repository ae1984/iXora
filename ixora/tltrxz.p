/* tltrxz.p
 * MODULE
        Операционист
 * DESCRIPTION
        Отчет о сегодняшних операциях - полный и по внутрибанковским проводкам
 * RUN
        
 * CALLER
        tltrx.p
 * SCRIPT
        
 * INHERIT
        tltrxzd.p - отчет по внутрибанковским операциям по видам
 * MENU
        2-3-1
 * AUTHOR
        31/12/99 Sushinin Vladimir
 * CHANGES
        02.06.2003 nadejda - добавила в конце сбор трех файлов в один
        19.08.2003 nadejda - оптимизация цикла по jl (временная таблица) для ускорения работы
        09.10.2003 sasco - печать отчета по коммунальным платежам
        08.11.2005 dpuchkov - добавил FIND crc .
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
DEF var m-cashgl AS integer init 100100.
DEF var m-tranzitgl AS integer init 255120.
DEF var m-first1 AS logical.
DEF var m-var1 AS logical.
DEF var m-first2 AS logical.
DEF var m-var2 AS logical.
DEF var m-amtd as dec decimals 2 format "-z,zzz,zzz,zzz,zzz.99".
DEF var m-amtk as dec decimals 2 format "-z,zzz,zzz,zzz,zzz.99".
DEF var m-sumdk1 as dec decimals 2 format "-z,zzz,zzz,zzz,zzz.99".
DEF var m-sumkk1 as dec decimals 2 format "-z,zzz,zzz,zzz,zzz.99".
DEF var m-sumd1 as dec decimals 2 format "-z,zzz,zzz,zzz,zzz.99".
DEF var m-sumk1 as dec decimals 2 format "-z,zzz,zzz,zzz,zzz.99".
DEF var m-sumdk2 as dec decimals 2 format "-z,zzz,zzz,zzz,zzz.99".
DEF var m-sumkk2 as dec decimals 2 format "-z,zzz,zzz,zzz,zzz.99".
DEF var m-sumd2 as dec decimals 2 format "-z,zzz,zzz,zzz,zzz.99".
DEF var m-sumk2 as dec decimals 2 format "-z,zzz,zzz,zzz,zzz.99".

DEF var m-diff as dec decimals 2 format "-z,zzz,zzz,zzz,zzz.99".
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

DEF var v-nbabeg LIKE gl.gl.
DEF var v-nbaend LIKE gl.gl.
DEF var v-nbpbeg LIKE gl.gl.
DEF var v-nbpend LIKE gl.gl.
DEF var m-str AS char.
DEF var report-type AS int.
DEF var report-date AS date.
DEF var report-title AS char FORMAT "x(132)".
DEF var avail-rep AS log.

DEF var count like jl.dam.


DEF BUFFER bufjl FOR jl.

m-fun = "TLTRX".
dest = "prit".
v-copy = 1.
report-type = 2.
report-date = g-today.

{tlimage10.f}   

VIEW FRAME image1.
UPDATE report-date dest v-copy validate(v-copy ge 1,"") WITH FRAME image1.


HIDE FRAME image1.

DEF BUTTON intrareport LABEL "      Внутрибанковские операции     ".
DEF BUTTON intrarepdet LABEL " Внутрибанковские операции по видам ".
DEF BUTTON fullreport LABEL  "            Полный отчет            ".
DEF BUTTON exitmenu LABEL    "                ВЫХОД               ". 

def frame butframe
  skip(1) 
  intrareport skip 
  intrarepdet skip 
  fullreport skip(1)
  exitmenu skip
with centered row 6 title "ВЫБЕРИТЕ ВАРИАНТ ОТЧЕТА:".

report-type = 0.
ON CHOOSE OF intrareport, intrarepdet, fullreport, exitmenu do:
  if self:label = "Внутрибанковские операции" then report-type = 1.
  else 
  if self:label = "Внутрибанковские операции по видам" then report-type = 3.
  else 
  if self:label = "Полный отчет" then report-type = 2.
END.


enable all with frame butframe.

WAIT-FOR CHOOSE OF intrareport, intrarepdet, fullreport, exitmenu.
if report-type = 0 then return.

hide frame butframe.

message " Формируется отчет...".

if report-type = 3 then do:
  run tltrxzd(report-date, dest, v-copy).
  return.
end.


FIND sysc WHERE sysc.sysc eq "GLARPB" NO-LOCK.
IF AVAILABLE sysc THEN
DO:
  m-str = chval.
  v-nbabeg = integer(substring(m-str,1,INDEX(m-str,",") - 1)).
  m-str = substring(m-str,INDEX(m-str,",") + 1).
  v-nbaend = integer(substring(m-str,1,INDEX(m-str,",") - 1)).
  m-str = substring(m-str,INDEX(m-str,",") + 1).
  v-nbpbeg = integer(substring(m-str,1,INDEX(m-str,",") - 1)).
  m-str = substring(m-str,INDEX(m-str,",") + 1).
  v-nbpend = integer(substring(m-str,1,INDEX(m-str,",") - 1)).
END.
ELSE
DO:
  v-nbabeg = 300000.
  v-nbaend = 400000.
  v-nbpbeg = 600000.
  v-nbpend = 700000.
END.


DEF temp-table otl
  FIELD gl LIKE gl.gl
  FIELD cam LIKE jl.cam
  FIELD dam LIKE jl.cam
  FIELD ncam AS int
  FIELD ndam AS int
  index gl is primary unique gl.



FIND sysc WHERE sysc.sysc eq "cashgl" NO-LOCK NO-ERROR .
IF AVAILABLE sysc THEN m-cashgl = sysc.inval.

FIND sysc WHERE sysc.sysc eq "pspygl" NO-LOCK NO-ERROR .
IF AVAILABLE sysc THEN m-tranzitgl = sysc.inval.

FOR EACH otl.
  DELETE otl.
END.

OUTPUT STREAM m-out1 TO VALUE (lc(TRIM(g-ofc)) + "msos.txt").
OUTPUT STREAM m-out2 TO VALUE ( lc(TRIM(g-ofc)) + "mson.txt").

sts1 = FALSE.
sts2 = FALSE.



def temp-table t-jl
  field jh like jh.jh
  field ln like jl.ln
  field crc like crc.crc
  index main is primary unique crc jh ln.

for each jl where jl.who = g-ofc and jl.jdt = report-date USE-INDEX jlwho no-lock break by jl.jh:
  if first-of (jl.jh) then do:
    avail-rep = (report-type = 2).
    if report-type = 1 then do:
      find first bufjl where bufjl.who = g-ofc AND bufjl.jdt = report-date
                and bufjl.jh = jl.jh and bufjl.gl = m-tranzitgl USE-INDEX jhln NO-LOCK NO-ERROR.
      avail-rep = not avail bufjl.
    end.
  
  end.

  if avail-rep then do:
    create t-jl.
    assign t-jl.jh = jl.jh
           t-jl.ln = jl.ln
           t-jl.crc = jl.crc.
  end.
end.


FIND FIRST t-jl NO-LOCK NO-ERROR.

avail-rep = AVAILABLE t-jl.

m-var1 = FALSE.
m-var2 = FALSE.

IF report-type =1 THEN 
  vtitle = "(внутр. операции)".
ELSE 
  vtitle = "(полный отчет)".


IF avail-rep THEN DO:
                         
  PUT STREAM m-out1 CHR(15).
  {tltrx01.f}
  HIDE FRAME tltrxh1.

  PUT STREAM m-out2 CHR(15).
  {tltrx02.f}
  HIDE FRAME tltrxh2.


  FOR EACH t-jl NO-LOCK BREAK BY t-jl.crc BY t-jl.jh BY t-jl.ln:

    find first jl where jl.jh = t-jl.jh and jl.ln = t-jl.ln use-index jhln no-lock no-error.
                              
    IF FIRST-OF(t-jl.crc) THEN DO:

      FIND crc WHERE crc.crc = t-jl.crc NO-LOCK NO-ERROR.
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


    FIND jh WHERE jh.jh = jl.jh NO-LOCK NO-ERROR.
    IF AVAILABLE jh THEN m-sts = jh.sts.
                    ELSE m-sts = 1.

    IF NOT m-first1 AND m-sts >= 6 THEN DO:
      m-first1 = TRUE.
      VIEW STREAM m-out1 FRAME crc.
      HIDE FRAME crc.
    END.

    IF NOT m-first2 AND m-sts < 6 THEN DO:
      m-first2 = TRUE.
      FIND crc WHERE crc.crc = t-jl.crc NO-LOCK NO-ERROR.
      VIEW STREAM m-out2 FRAME crc.
      HIDE FRAME crc.
    END.


/* ================================================< 15.10.2001, sasco <=== */
    IF FIRST-OF(t-jl.crc) then run vyp_ofc_1 (crc.crc).
/* ======================================================================== */


    m-amtk = 0.
    m-amtd = 0.

    IF jl.dc eq "D"  THEN DO:
      IF m-sts >= 6 THEN DO:
        IF jl.gl = m-cashgl THEN m-sumdk1 = m-sumdk1 + jl.dam.
        m-sumd1 = m-sumd1 + jl.dam.
      END.
      ELSE DO:
        IF jl.gl = m-cashgl THEN m-sumdk2 = m-sumdk2 + jl.dam.
        m-sumd2 = m-sumd2 + jl.dam.
      END.
      m-amtd = jl.dam.
    END.
    ELSE DO:
      IF m-sts >= 6 THEN DO:
        IF jl.gl = m-cashgl THEN m-sumkk1 = m-sumkk1 + jl.cam.
        m-sumk1 = m-sumk1 + jl.cam.
      END.
      ELSE DO:
        IF jl.gl = m-cashgl THEN m-sumkk2 = m-sumkk2 + jl.cam.
        m-sumk2 = m-sumk2 + jl.cam.
      END.
      m-amtk = jl.cam.
    END.

    find jh where jh.jh = jl.jh no-lock no-error.
    m-char = string(jh.tim,"HH:MM:SS").
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

    FIND FIRST otl WHERE otl.gl = jl.gl  NO-ERROR.
    IF NOT AVAILABLE otl THEN DO:
      CREATE otl.
      otl.gl = jl.gl.
    END.

    find last crchis where crchis.crc = jl.crc and crchis.rdt <= report-date no-lock no-error.
    IF jl.dc eq "D" THEN DO:
      otl.dam = otl.dam + jl.dam * crchis.rate[1].
      otl.ndam = otl.ndam + 1.
    END.
    ELSE DO:
      otl.cam = otl.cam + jl.cam * crchis.rate[1].
      otl.ncam = otl.ncam + 1.
    END.

    IF LAST-OF (t-jl.crc) THEN DO:

      IF m-first1 THEN DO:
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
/* ============================================ 16.10.2001, sasco >>>====== */
        FIND crc WHERE crc.crc = t-jl.crc NO-LOCK NO-ERROR.
        run vyp_ost_1 (crc.crc).
/* ============================================ 16.10.2001, sasco >>>====== */
      END.
      IF m-first2 THEN DO:
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

  END.  /* for each jl */

END.


IF m-var1 THEN
  sts1 = TRUE.

IF m-var2 THEN
  sts2 = TRUE.

/*
FIND FIRST aal WHERE aal.who = g-ofc AND aal.regdt = report-date USE-INDEX aalwho
         NO-LOCK NO-ERROR.
       

avail-rep = (AVAILABLE jl AND report-type = 2).

IF AVAILABLE jl AND report-type = 1 THEN DO:
  FIND FIRST bufjl WHERE bufjl.who = g-ofc AND bufjl.jdt = report-date AND
              bufjl.jh = jl.jh AND bufjl.gl = m-tranzitgl USE-INDEX jhln NO-LOCK NO-ERROR.
  avail-rep = not avail bufjl.
END.



IF AVAILABLE aal AND report-type = 2 THEN
  avail-rep = yes.
ELSE
  IF AVAILABLE aal AND report-type = 1 THEN DO:
    avail-rep = no.
    REPEAT:
      FIND FIRST bufjl WHERE bufjl.who = g-ofc AND bufjl.jdt = report-date AND
         bufjl.jh=aal.jh AND bufjl.gl = m-tranzitgl USE-INDEX jlwho
         NO-LOCK NO-ERROR.
      IF NOT AVAILABLE bufjl THEN
      DO:
        avail-rep = yes.
        LEAVE.
      END.
      ELSE
      DO:
        FIND NEXT aal NO-LOCK.
        IF NOT AVAILABLE aal THEN LEAVE.
      END.
    END.
  END.
  ELSE
    avail-rep = no.

IF avail-rep = yes THEN DO:

IF NOT sts1 and NOT sts2  THEN
  DO:
    PUT STREAM m-out1 CHR(15).
    {tltrx010.f}
    HIDE FRAME tltrxh10.
    m-var1 = FALSE.

    PUT STREAM m-out2 CHR(15).
    {tltrx020.f}
    HIDE FRAME tltrxh20.
    m-var2 = FALSE.
  END.

  FOR EACH aal WHERE aal.who = g-ofc AND aal.regdt = report-date
      USE-INDEX aalwho NO-LOCK  BREAK BY aal.crc BY aal.aah BY aal.ln:

    IF report-type = 2 THEN
      avail-rep = yes.
    ELSE DO:
      avail-rep = no.
      FIND FIRST bufjl WHERE bufjl.who = g-ofc AND bufjl.jdt = report-date AND
        bufjl.jh=aal.jh AND bufjl.gl = m-tranzitgl USE-INDEX jlwho NO-LOCK NO-ERROR.
      IF NOT AVAILABLE bufjl THEN
        avail-rep = yes.
    END.
    
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

  IF avail-rep = yes THEN DO:
  
    IF (aal.jh = 0 OR aal.jh = ? ) THEN
    DO:
      FIND aah WHERE aah.aah = aal.aah NO-LOCK NO-ERROR.
      IF AVAILABLE aah THEN
      m-stn = aah.stn.
      ELSE
      m-stn = 1.

      FIND aax WHERE aax.lgr eq aal.lgr AND aax.ln eq aal.aax NO-LOCK NO-ERROR.

      find jh where jh.jh = aal.jh no-lock no-error.
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
      m-stsstr = "Ош.".
      ELSE
      m-stsstr = "   ".


      IF m-stn >= 6 THEN
      DO:
        IF NOT m-first1  THEN
        DO:
          m-first1 = TRUE.
          VIEW STREAM m-out1 FRAME crc1.
          HIDE FRAME crc1.


    run vyp_ofc_1 (crc.crc).


        END.
        {tltrx1.f}
        DISPLAY STREAM m-out1 m-char
          aal.aah FORMAT "zzzzzzz9" aal.ln aal.jh aal.aax aax.des aal.aaa
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
          aal.aah FORMAT "zzzzzzz9" aal.ln aal.jh aal.aax aax.des aal.aaa
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

OUTPUT STREAM m-out3 TO VALUE ( lc(TRIM(g-ofc)) + "sum.txt").
IF NOT sts1 AND NOT sts2 THEN
DO:
  PUT STREAM m-out1 CHR(15).
  PUT STREAM m-out2 CHR(15).

  {tltrx011.f}
  {tltrx021.f}

  HIDE FRAME tltrxh11.
  HIDE FRAME tltrxh21.
END.



{tltrx5.f}

IF NOT sts1 THEN VIEW STREAM m-out1 FRAME navvar.
IF NOT sts2 THEN VIEW STREAM m-out2 FRAME navvar.

DISPLAY STREAM m-out1 SKIP(3).
DISPLAY STREAM m-out2 SKIP(3).

OUTPUT STREAM m-out1 close.
OUTPUT STREAM m-out2 close.

FIND ofc WHERE ofc.ofc = g-ofc NO-LOCK.
IF report-type = 1 THEN
  report-title = " Внутрибанковские".
ELSE 
  report-title = " Все".

vtitle = {ofcsumt.f}

vtoday = g-today.
vtime = string(TIME,"HH:MM:SS").
                       
FORM HEADER
  SKIP(3)
  g-comp vtoday vtime "BY" caps(g-ofc)
  "Page: " + string(PAGE-NUMBER, "zzz9") FORMAT "x(10)" TO 132 SKIP
  g-fname g-mdes SKIP
  vtitle FORMAT "x(132)" SKIP
  FILL("=",132) FORMAT "x(132)" SKIP
  WITH width 132 PAGE-TOP no-box NO-LABEL FRAME rpthead.

VIEW STREAM m-out3 FRAME rpthead.


find first otl where not ((otl.gl >= v-nbabeg AND otl.gl < v-nbaend) or
      (otl.gl >= v-nbpbeg AND otl.gl < v-nbpend)) no-lock no-error.

if avail otl then
  FOR EACH otl :

    if ((otl.gl >= v-nbabeg AND otl.gl < v-nbaend) or
        (otl.gl >= v-nbpbeg AND otl.gl < v-nbpend)) then next.

      FIND gl WHERE otl.gl = gl.gl NO-LOCK no-error.
      {ofcsum.f "stream m-out3" }
  END. 

find first otl where ((otl.gl >= v-nbabeg AND otl.gl < v-nbaend) or
      (otl.gl >= v-nbpbeg AND otl.gl < v-nbpend)) no-lock no-error.
if avail otl then 
  FOR EACH otl :

    if not ((otl.gl >= v-nbabeg AND otl.gl < v-nbaend) or
           (otl.gl >= v-nbpbeg AND otl.gl < v-nbpend)) then next.


    FIND gl WHERE otl.gl = gl.gl NO-LOCK no-error.
    {ofcsum.f "stream m-out3" }
  END.


OUTPUT STREAM m-out3 close.

hide message no-pause.

/* sasco вывод коммунальных */
UNIX silent rm -f value( lc(trim(g-ofc)) + "comm.txt").
run tltrxcomm (lc(trim(g-ofc)) + "comm.txt", report-date, g-ofc, no).
 
UNIX silent cat value(lc(trim(g-ofc)) + "msos.txt") > repsofc.txt.
UNIX silent cat value( lc(trim(g-ofc)) + "mson.txt") >> repsofc.txt.
UNIX silent cat value( lc(trim(g-ofc)) + "sum.txt") >> repsofc.txt.
UNIX silent cat value( lc(trim(g-ofc)) + "comm.txt") >> repsofc.txt.

UNIX silent rm -f value( lc(trim(g-ofc)) + "msos.txt").
UNIX silent rm -f value( lc(trim(g-ofc)) + "mson.txt").
UNIX silent rm -f value( lc(trim(g-ofc)) + "sum.txt").
UNIX silent rm -f value( lc(trim(g-ofc)) + "comm.txt").

REPEAT WHILE v-copy gt 0 :
  UNIX silent value(dest) repsofc.txt.
  v-copy = v-copy - 1.
END.
UNIX rm -f repsofc.txt.

hide all no-pause.

pause 0.

/* ================================================> 15.10.2001, sasco >=== */
/*========================= Выписка авансов, подкреплений и расходов ======*/
procedure vyp_ofc_1.
def input parameter incrc like crc.crc.

   put stream m-out1 fill ("-", 70) format "x(70)" skip.
   put stream m-out1 "Аванс на начало дня" format "x(30)".

   find cashofc where cashofc.whn eq report-date and
                          cashofc.ofc eq g-ofc and
                          cashofc.sts eq 1 /* avans */
                          and cashofc.crc eq incrc
                          no-lock no-error.
   if not avail cashofc then
   do:
           create cashofc.
           cashofc.whn = report-date.
           cashofc.ofc = g-ofc.
           cashofc.sts = 1.
           cashofc.crc = incrc.
           cashofc.amt = 0.
   end.


   put stream m-out1 cashofc.amt skip.
   put stream m-out1 skip "Подкрепления в течение дня (общая сумма)".

   count = 0.0.
   for each cashofc where cashofc.whn eq report-date and
                          cashofc.ofc eq g-ofc and
                          cashofc.sts eq 3 /* podkr */
                          and cashofc.crc eq incrc no-lock:
             if avail cashofc then
             count = count + cashofc.amt.
    end.

    if count ne 0.0 then
    put stream m-out1 count skip.

    put stream m-out1 skip "Расходы (общая сумма)".
    count = 0.0.
        for each cashofc where cashofc.whn eq report-date and
                               cashofc.ofc eq g-ofc and
                               cashofc.sts eq 4 /* return */
                               and cashofc.crc eq incrc no-lock:

        if avail cashofc then count = count + cashofc.amt.
        end.

        if count ne 0.0 then
             put stream m-out1 count skip.

end procedure.
/*========================= Выписка авансов, подкреплений и расходов2 ======*/
procedure vyp_ofc_2.
def input parameter incrc like crc.crc.

   put stream m-out2 fill ("-", 70) format "x(70)" skip.
   put stream m-out2 "Аванс на начало дня" format "x(30)".

   find cashofc where cashofc.whn eq report-date and
                          cashofc.ofc eq g-ofc and
                          cashofc.sts eq 1 /* avans */
                          and cashofc.crc eq incrc
                          no-lock no-error.
   if not avail cashofc then
   do:
           create cashofc.
           cashofc.whn = report-date.
           cashofc.ofc = g-ofc.
           cashofc.sts = 1.
           cashofc.crc = incrc.
           cashofc.amt = 0.
   end.

   put stream m-out1 cashofc.amt skip.

   put stream m-out2 skip "Подкрепления в течение дня (общая сумма)".

   count = 0.0.
   for each cashofc where cashofc.whn eq report-date and
                          cashofc.ofc eq g-ofc and
                          cashofc.sts eq 3 /* podkr */
                          and cashofc.crc eq incrc no-lock:
             if avail cashofc then
             count = count + cashofc.amt.
    end.

    if count ne 0.0 then
    put stream m-out2 count skip.

    put stream m-out2 skip "Расходы (общая сумма)".
    count = 0.0.
        for each cashofc where cashofc.whn eq report-date and
                               cashofc.ofc eq g-ofc and
                               cashofc.sts eq 4 /* return */
                               and cashofc.crc eq incrc no-lock:

        if avail cashofc then count = count + cashofc.amt.
        end.
        if count ne 0.0 then
             put stream m-out2 count skip.

end procedure.
procedure vyp_ost_1.
def input parameter incrc like crc.crc.

find cashofc where cashofc.ofc eq g-ofc and
                   cashofc.whn eq report-date
                   and cashofc.sts eq 2
                   and cashofc.crc eq incrc
                   no-lock no-error.
   if not avail cashofc then
   do:
           create cashofc.
           cashofc.whn = report-date.
           cashofc.ofc = g-ofc.
           cashofc.sts = 2.
           cashofc.crc = incrc.
           cashofc.amt = 0.
   end.

if avail cashofc then
do:
   put stream m-out1 "Остаток наличной валюты в кассе: ".
   put stream m-out1 cashofc.amt skip.
end.
 end procedure.
