/* tltrxzd.p
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


/* tltrxz.p
Sushinin Vladimir

**********************************
MODIFIED BY Vlad Levitsky 29/07/97
**********************************

   27.11.2002 nadejda - вариант отчета операциониста "по видам"
   02.06.2003 nadejda - добавила в конце сбор трех файлов в один
   09.10.2003 sasco - печать отчета по коммунальным платежам

*/

{global.i}




DEF input parameter report-date AS date.
DEF input parameter dest AS char.
DEF input parameter v-copy AS int.

DEF var m-fun AS char.
DEF VAR sts1 AS LOGICAL.
DEF VAR sts2 AS LOGICAL.
def var v-local as integer.

DEF STREAM m-out1.
DEF STREAM m-out2.
DEF STREAM m-out3.
DEF var m-count AS integer initial 0.
DEF var m-cashgl AS integer.
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

DEF var v-nbabeg LIKE gl.gl.
DEF var v-nbaend LIKE gl.gl.
DEF var v-nbpbeg LIKE gl.gl.
DEF var v-nbpend LIKE gl.gl.
DEF var m-str AS char.
DEF var report-type AS int.
DEF var report-title AS char FORMAT "x(132)".
DEF var avail-rep AS log.
def var gl-sts1 as log init false.
def var gl-sts2 as log init false.
def var crc-sts as log init true.
def var typ-sts1 as log.
def var typ-sts2 as log.
def var v-typ as integer.
        
DEF var count like jl.dam.

def var typnums as int init 6.
def var typnames as char extent 6 init [
  "-----  Кассовые транзакции  -----",
  "-----  Конвертация  -----",
  "-----  Возврат со счета доходов  -----",
  "-----  Внутренние проводки (счет-счет)  -----",
  "-----  Начисление процентов на счет  -----",
  "-----  Другие транзакции  -----"].

def var v-excl as char init "255120, 603600, 653600".
def var v-percentgl as char init 
  "520310,520320,521110,521120,521130,521510,521520,521710,521720,521910,521920,522110,522120,522300,522310,522320".

def temp-table t-jl like jl
  field typ as integer init 6
  index main is primary sts crc typ jh ln.

def temp-table t-jh 
  field jh like jh.jh
  index main is primary jh.


m-fun = "TLTRX".
report-type = 3.

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



FIND sysc WHERE sysc.sysc = "cashgl" NO-LOCK NO-ERROR .
IF AVAILABLE sysc and sysc.inval <> 0 THEN m-cashgl = sysc.inval.

FIND sysc WHERE sysc.sysc = "dep%gl" NO-LOCK NO-ERROR .
IF AVAILABLE sysc and sysc.chval <> "" THEN v-percentgl = sysc.chval.

FIND sysc WHERE sysc.sysc = "pspygl" NO-LOCK NO-ERROR .
IF AVAILABLE sysc and sysc.inval <> 0 THEN v-excl = string(sysc.inval).

FIND sysc WHERE sysc.sysc = "noingl" NO-LOCK NO-ERROR .
IF AVAILABLE sysc and sysc.chval <> "" THEN do:
  if v-excl <> "" and substr(v-excl, length(v-excl), 1) <> "," then v-excl = v-excl + ",".
  v-excl = v-excl + sysc.chval.
end.

FOR EACH otl.
  DELETE otl.
END.

OUTPUT STREAM m-out1 TO VALUE (lc(TRIM(g-ofc)) + "msos.txt").
OUTPUT STREAM m-out2 TO VALUE ( lc(TRIM(g-ofc)) + "mson.txt").

sts1 = FALSE.
sts2 = FALSE.

/* временная таблица */
for each jl where jl.who = g-ofc and jl.jdt = report-date use-index jlwho no-lock:
  create t-jl.
  buffer-copy jl to t-jl.
  find jh where jh.jh = jl.jh no-lock no-error.
  if avail jh then do:
    find t-jh where t-jh.jh = jh.jh no-error.
    if not avail t-jh then do:
      create t-jh.
      t-jh.jh = jh.jh.
    end.
    t-jl.tim = jh.tim.
    if jh.sts >= 6 then t-jl.sts = 6.
    else t-jl.sts = 5.
  end.
  else
    t-jl.sts = 1.
end.

for each t-jh :
  /* если на линиях есть внешние счета ГК -> не брать в отчет */
  find first t-jl where t-jl.jh = t-jh.jh and lookup(string(t-jl.gl), v-excl) > 0 no-lock no-error.
  if avail t-jl then do:
    for each t-jl where t-jl.jh = t-jh.jh. delete t-jl. end.
  end.
  else do:
    /* на линиях есть счета начисления процентов? */
    find first t-jl where t-jl.jh = t-jh.jh and lookup(string(t-jl.gl), v-percentgl) > 0 
         no-lock no-error.
    if avail t-jl then v-typ = 5.
    else do:
      /* на линиях есть счет кассы? */
      find first t-jl where t-jl.jh = t-jh.jh and t-jl.gl = m-cashgl no-lock no-error.
      if avail t-jl then v-typ = 1.
      else do:
        /* на линиях есть счета доходов по дебету? */
        find first t-jl where t-jl.jh = t-jh.jh and t-jl.gl >= 400000 and t-jl.gl <= 499999 and t-jl.dc = "D" 
           and t-jl.subled = "" no-lock no-error.
        if avail t-jl then v-typ = 3.
        else do:
          /* на линиях есть счета cif по дебету и кредиту? */
          find first t-jl where t-jl.jh = t-jh.jh and t-jl.subled <> "cif" no-lock no-error.
          if not avail t-jl then v-typ = 4.
          else do:
            /* проводки конвертации - по шаблонам DIL */
            find first t-jl where t-jl.jh = t-jh.jh and t-jl.trx <> "dil" no-lock no-error.
            if not avail t-jl then v-typ = 2.
            else v-typ = typnums.
          end.
        end.
      end.
    end.
    for each t-jl where t-jl.jh = t-jh.jh. t-jl.typ = v-typ. end.
  end.
end.

vtitle = "(внутр. операции по видам)".

PUT STREAM m-out1 CHR(15).
{tltrx01.f}
PUT STREAM m-out2 CHR(15).
{tltrx02.f}

find first t-jl no-lock no-error.
IF AVAILABLE t-jl THEN DO:

  define frame mainhead
    skip(2) 
  "Время      Пров.  Лин Счет ГК  Счет                    Дебет                Кредит    Штамп   Ст. Ош."
    skip 
  with no-box no-label width 132.

  {tltrx31_1.f}
  {tltrx32_1.f}
  {tltrx41_1.f}
  {tltrx42_1.f}

  /* нацвалюта */
  find crchs where crchs.Hs = "L" no-lock no-error.
  v-local = crchs.crc.


  for each t-jl no-lock use-index main break by t-jl.sts by t-jl.crc by t-jl.typ:
    IF first-of(t-jl.crc) THEN DO:
      FIND crc WHERE crc.crc = t-jl.crc NO-LOCK NO-ERROR.
      {tltrx0.f}
      m-sumk1 = 0.
      m-sumd1 = 0.
      m-sumkk1 = 0.
      m-sumdk1 = 0.
      m-sumk2 = 0.
      m-sumd2 = 0.
      m-sumkk2 = 0.
      m-sumdk2 = 0.
      crc-sts = false.

      if t-jl.sts = 6 then do:
        VIEW STREAM m-out1 FRAME crc.
/* ================================================< 15.10.2001, sasco <=== */
        run vyp_ofc_1 (crc.crc).
/* ======================================================================== */
        VIEW STREAM m-out1 frame mainhead.
        PUT STREAM m-out1 fill("-",132) format "x(132)" skip.
      end.
      else do:
        VIEW STREAM m-out2 FRAME crc.
        VIEW STREAM m-out2 frame mainhead.
        PUT STREAM m-out2 fill("-",132) format "x(132)" skip.
      end.
    END.

    if first-of(t-jl.typ) then do:
      if t-jl.sts = 6 then
        PUT STREAM m-out1 skip(1) typnames[t-jl.typ] format "x(50)" skip.
      else
        PUT STREAM m-out2 skip(1) typnames[t-jl.typ] format "x(50)" skip.
    end.

    IF t-jl.dc eq "D"  THEN DO:
      IF t-jl.sts = 6 THEN DO:
        IF t-jl.gl = m-cashgl THEN  
          m-sumdk1 = m-sumdk1 + t-jl.dam.
        m-sumd1 = m-sumd1 + t-jl.dam.
      END.
      ELSE DO:
        IF t-jl.gl = m-cashgl THEN
          m-sumdk2 = m-sumdk2 + t-jl.dam.
        m-sumd2 = m-sumd2 + t-jl.dam.
      END.
    END.
    ELSE DO:
      IF t-jl.sts = 6 THEN DO:
        IF t-jl.gl = m-cashgl THEN
          m-sumkk1 = m-sumkk1 + t-jl.cam.
        m-sumk1 = m-sumk1 + t-jl.cam.
      END.
      ELSE DO:
        IF t-jl.gl = m-cashgl THEN
          m-sumkk2 = m-sumkk2 + t-jl.cam.
        m-sumk2 = m-sumk2 + t-jl.cam.
      END.
    END.

    m-char = string(t-jl.tim,"HH:MM:SS").

    IF t-jl.sts = 6 THEN DO:
      put STREAM m-out1 m-char " " t-jl.jh " " t-jl.ln  FORMAT "zzzz" " " t-jl.gl " " 
         t-jl.acc " " t-jl.dam " " t-jl.cam " " t-jl.teller " " t-jl.sts "    " skip.
    end.
    else do:
      if t-jl.sts = 1 then m-stsstr = " ERR". else m-stsstr = "    ".
      put STREAM m-out2 m-char " " t-jl.jh " " t-jl.ln  FORMAT "zzzz" " " t-jl.gl " " 
         t-jl.acc " " t-jl.dam " " t-jl.cam " " t-jl.teller " " t-jl.sts
         m-stsstr skip.
    end.

    FIND FIRST otl WHERE otl.gl = t-jl.gl  EXCLUSIVE-LOCK NO-ERROR.
    IF NOT AVAILABLE otl THEN DO:
      CREATE otl.
      otl.gl = t-jl.gl.
    END.
    find last crchis where crchis.crc = t-jl.crc and crchis.rdt <= report-date no-lock no-error.
    IF t-jl.dc eq "D" THEN DO:
      if t-jl.crc = v-local then otl.dam = otl.dam + t-jl.dam.
      else otl.dam = otl.dam + t-jl.dam * crchis.rate[1].
      otl.ndam = otl.ndam + 1.
    END.
    ELSE DO:
      if t-jl.crc = v-local then otl.cam = otl.cam + t-jl.cam.
      else otl.cam = otl.cam + t-jl.cam * crchis.rate[1].
      otl.ncam = otl.ncam + 1.
    END.

    IF LAST-OF(t-jl.crc) THEN DO:
      FIND crc WHERE crc.crc = t-jl.crc NO-LOCK NO-ERROR.
      IF t-jl.sts = 6 THEN DO:
        DISPLAY STREAM m-out1 m-sumd1 m-sumk1 WITH FRAME tl1total1.
        m-diff = m-sumdk1 - m-sumkk1.
        DISPLAY STREAM m-out1 m-sumdk1 m-sumkk1 m-diff WITH FRAME tltotal1.
/* ============================================ 16.10.2001, sasco >>>====== */
        run vyp_ost_1 (crc.crc).
/* ============================================ 16.10.2001, sasco >>>====== */
      END.
      else do:
        DISPLAY STREAM m-out2 m-sumd2 m-sumk2 WITH  FRAME tl1total2.
        m-diff = m-sumdk2 - m-sumkk2.
        DISPLAY STREAM m-out2 m-sumdk2 m-sumkk2 m-diff WITH FRAME tltotal2.
      END.
    END.

  END.  /* for each t-jl */

END.


{tltrx5.f}

find first t-jl where t-jl.sts = 6 no-lock no-error.
if not avail t-jl then
  VIEW STREAM m-out1 FRAME navvar.

find first t-jl where t-jl.sts <> 6 no-lock no-error.
if not avail t-jl then
  VIEW STREAM m-out2 FRAME navvar.

DISPLAY STREAM m-out1 SKIP(3).
DISPLAY STREAM m-out2 SKIP(3).

OUTPUT STREAM m-out1 close.
OUTPUT STREAM m-out2 close.

FIND ofc WHERE ofc.ofc = g-ofc NO-LOCK.
report-title = " Внутрибанковские".

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

OUTPUT STREAM m-out3 TO VALUE ( lc(TRIM(g-ofc)) + "sum.txt").
VIEW STREAM m-out3 FRAME rpthead.


FOR EACH otl WHERE NOT
    ((otl.gl >= v-nbabeg AND otl.gl < v-nbaend) OR
    (otl.gl >= v-nbpbeg AND otl.gl < v-nbpend))  BREAK BY otl.gl.

    FIND gl WHERE otl.gl = gl.gl NO-LOCK.
    {ofcsum.f "stream m-out3" }
END. 

FOR EACH otl WHERE
    ((otl.gl >= v-nbabeg AND otl.gl < v-nbaend) OR
    (otl.gl >= v-nbpbeg AND otl.gl < v-nbpend))  BREAK BY otl.gl.

  FIND gl WHERE otl.gl = gl.gl NO-LOCK.
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
/* ------------------- */
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
   put stream m-out1 cashofc.amt skip(1).
end.
 end procedure.
