/* tltrxuni.p
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
        15/10/03 sasco Переделка unix [silent] чтобы кодировка не менялась (раньше иероглифика была) :-)
        15/10/03 sasco Вывод итогов по коммунальным платежам
*/

/* tltrxz.p

*/
def var v-today as date . 
def var v-ofc like ofc.ofc . 
{global.i}
v-ofc = g-ofc . 
v-today = g-today . 

 update v-today label "За дату " v-ofc label "Офицер " 
  with centered side-label 1 column row 5  frame fff .


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
DEF var m-amtd LIKE aal.amt.
DEF var m-amtk LIKE aal.amt.
DEF var m-sumdk1 LIKE aal.amt.
DEF var m-sumkk1 LIKE aal.amt.
DEF var m-sumd1 LIKE aal.amt.
DEF var m-sumk1 LIKE aal.amt.
DEF var m-sumdk2 LIKE aal.amt.
DEF var m-sumkk2 LIKE aal.amt.
DEF var m-sumd2 LIKE aal.amt.
DEF var m-sumk2 LIKE aal.amt.

DEF var m-diff LIKE aal.amt.
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


m-fun = "TLTRX".
dest = "prit".
v-copy = 1.
form "КОМАНДА ПЕЧАТИ    :" dest format "x(40)" skip
     "КОЛ-ВО ЭКЗЕМПЛЯРОВ: " v-copy format "zzzz"
             with row 4 no-box no-label centered frame image1.
VIEW FRAME image1.
UPDATE dest WITH FRAME image1 no-box.
UPDATE v-copy validate(v-copy ge 1,"") WITH FRAME image1 no-box.
HIDE FRAME image1.


display "Ждите ..." with frame aa row 10 no-label centered. pause 0 . 

FIND sysc WHERE sysc.sysc eq "GLARPB" NO-LOCK.
if AVAILABLE sysc then
do:
  m-str = chval.
  v-nbabeg = integer(substring(m-str,1,INDEX(m-str,',') - 1)).
  m-str = substring(m-str,INDEX(m-str,',') + 1).
  v-nbaend = integer(substring(m-str,1,INDEX(m-str,',') - 1)).
  m-str = substring(m-str,INDEX(m-str,',') + 1).
  v-nbpbeg = integer(substring(m-str,1,INDEX(m-str,',') - 1)).
  m-str = substring(m-str,INDEX(m-str,',') + 1).
  v-nbpend = integer(substring(m-str,1,INDEX(m-str,',') - 1)).
end.
ELSE
do:
  v-nbabeg = 300000.
  v-nbaend = 400000.
  v-nbpbeg = 600000.
  v-nbpend = 700000.
end.


DEF WORKFILE otl
  FIELD gl LIKE gl.gl
  FIELD cam LIKE jl.cam
  FIELD dam LIKE jl.cam
  FIELD ncam AS int
  FIELD ndam AS int.



FIND sysc WHERE sysc.sysc eq "cashgl" NO-LOCK NO-ERROR .
if AVAILABLE sysc then
m-cashgl = sysc.inval.

for each otl.
  DELETE otl.
end.



OUTPUT STREAM m-out1 TO VALUE (lc(TRIM(v-ofc)) + "msos.txt").
OUTPUT STREAM m-out2 TO VALUE ( lc(TRIM(v-ofc)) + "mson.txt").


sts1 = FALSE.
sts2 = FALSE.

FIND FIRST jl WHERE jl.who = v-ofc AND jl.jdt = v-today USE-INDEX jlwho
   NO-LOCK NO-ERROR.


if AVAILABLE jl then
do:

  PUT STREAM m-out1 CHR(15).
  display stream m-out1
    g-comp format "x(70)" skip
                "Исполнитель " v-ofc " Дата " v-today skip
                "Дата печати  " today string(time,"HH:MM:SS") skip
                "Отштампованные проводки" format   "x(45)" skip
  fill("=",132) format "x(132)"
  with width 132 frame tltrxh1 no-hide no-box no-label no-underline.
  HIDE FRAME tltrxh1.

  PUT STREAM m-out2 CHR(15).
  display stream m-out2
   g-comp format "x(70)" skip
               "Исполнитель " v-ofc " Дата   " v-today skip
               "Дата печати  " today string(time,"HH:MM:SS") skip
               "Неотштампованные проводки" format "x(45)" skip
  fill("=",132) format "x(132)"
  with width 132 frame tltrxh2 no-hide no-box no-label no-underline.
  HIDE FRAME tltrxh2.

  m-var1 = FALSE.
  m-var2 = FALSE.



  for each jl WHERE jl.who = v-ofc AND jl.jdt = v-today USE-INDEX jlwho
      NO-LOCK  BREAK BY jl.crc BY jl.jh BY jl.ln:

    if FIRST-OF(jl.crc) then
    do:
      FIND crc WHERE crc.crc = jl.crc NO-LOCK NO-ERROR.
      form header skip(1)
        "[ Валюта - "  + crc.des  + " ]"  format "x(70)"
        with row 6 no-label no-box frame crc.
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

    end.
    FIND jh WHERE jh.jh = jl.jh NO-LOCK NO-ERROR.
    if AVAILABLE jh then
    m-sts = jh.sts.
    ELSE
    m-sts = 1.

    if NOT m-first1 AND m-sts >= 6 then
    do:
      m-first1 = TRUE.
      VIEW STREAM m-out1 FRAME crc.
      HIDE FRAME crc.
    end.

    if NOT m-first2 AND m-sts < 6 then
    do:
      m-first2 = TRUE.
      VIEW STREAM m-out2 FRAME crc.
      HIDE FRAME crc.
    end.

    m-amtk = 0.
    m-amtd = 0.

    if jl.dc eq "D"  then
    do:
      if m-sts >= 6 then
      do:
        if jl.gl = m-cashgl then
        m-sumdk1 = m-sumdk1 + jl.dam.
        m-sumd1 = m-sumd1 + jl.dam.
      end.
      ELSE
      do:
        if jl.gl = m-cashgl then
        m-sumdk2 = m-sumdk2 + jl.dam.
        m-sumd2 = m-sumd2 + jl.dam.
      end.
      m-amtd = jl.dam.
    end.
    ELSE
    do:
      if m-sts >= 6 then
      do:
        if jl.gl = m-cashgl then
        m-sumkk1 = m-sumkk1 + jl.cam.
        m-sumk1 = m-sumk1 + jl.cam.
      end.
      ELSE
      do:
        if jl.gl = m-cashgl then
        m-sumkk2 = m-sumkk2 + jl.cam.
        m-sumk2 = m-sumk2 + jl.cam.
      end.
      m-amtk = jl.cam.
    end.

    m-char = string(jl.tim,"HH:MM:SS").
    if m-sts = 1  then
       m-stsstr = "Err".
    ELSE
       m-stsstr = "   ".
  form
 m-char
 column-label "Время"
            jl.jh
 column-label "Пров.#"
            jl.ln  FORMAT "zzzz"
 column-label "Лин"
            jl.gl
 column-label "Счет Гл.Книги "
            jl.acc
 column-label "Счет "
            m-amtd at 73
 column-label "Дебет "
            m-amtk
 column-label "Кредит "
            jl.teller
 column-label "Штамп  "
            m-sts
 column-label "Ст."
            m-stsstr format "x(3)" label "Ош."
 header skip(1)
            with width 132 row 7 4 down frame jltl no-box overlay.
    if  m-sts >= 6 then
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
    if NOT AVAILABLE otl then
    do:
      CREATE otl.
      otl.gl = jl.gl.
    end.
    if jl.dc eq "D" then
    do:
      otl.dam = otl.dam + jl.dam.
      otl.ndam = otl.ndam + 1.
    end.
    ELSE
    do:
      otl.cam = otl.cam + jl.cam.
      otl.ncam = otl.ncam + 1.
    end.

    if LAST-OF ( jl.crc ) then
    do:
      if m-first1 then
      do:
        HIDE FRAME jltl.
        m-var1 = TRUE.
form
"Итого    " m-sumd1 at 73 m-sumk1
  header
  fill("-",132) format "x(132)"
  with frame tl1total1 width 132  down
  no-box no-label no-underline overlay.

        DISPLAY STREAM m-out1 m-sumd1 m-sumk1
          WITH FRAME tl1total1.
        HIDE FRAME tl1total1.
form
 "Итого касса  " m-sumdk1 at 73 m-sumkk1 skip
 "Остатки касса" m-diff
  header
  fill("-",132) format "x(132)"
  with frame tltotal1 width 132
  down no-box no-label no-underline overlay.

        m-diff = m-sumdk1 - m-sumkk1.
        DISPLAY STREAM m-out1
          m-sumdk1 m-sumkk1 m-diff WITH FRAME tltotal1.
        HIDE FRAME tltotal1.
      end.
      if m-first2 then
      do:
        m-var2 = TRUE.
form
"Итого    " m-sumd2 at 73 m-sumk2
  header
  fill("-",132) format "x(132)"
  with frame tl1total2 width 132 down
  no-box no-label no-underline overlay.
        DISPLAY STREAM m-out2 m-sumd2 m-sumk2
          WITH  FRAME tl1total2.
        HIDE FRAME tl1total2.
        HIDE FRAME jltl.
form
"Итого касса  " m-sumdk2 at 73 m-sumkk2 skip
"Остатки кассы" m-diff
  header
  fill("-",132) format "x(132)"
  with frame tltotal2 width 132
   down no-box no-label no-underline overlay.
        m-diff = m-sumdk2 - m-sumkk2.
        DISPLAY STREAM m-out2
          m-sumdk2 m-sumkk2 m-diff WITH FRAME tltotal2.
        HIDE FRAME tltotal2.
      end.
    end.
  end.  /* for each jl */

end.

if m-var1 then
  sts1 = TRUE.

if m-var2 then
  sts2 = TRUE.



/*
FIND FIRST aal WHERE aal.who = v-ofc AND aal.regdt = v-today USE-INDEX aalwho
  NO-LOCK NO-ERROR.
if AVAILABLE aal then
do:

  if NOT sts1 and NOT sts2  then
  do:
    PUT STREAM m-out1 CHR(15).
    display stream m-out1
  g-comp format "x(70)" skip
            "Исполнитель " v-ofc " Дата   " v-today skip
            "Дата печати  " today string(time,"HH:MM:SS") skip
            "Отштампованные проводки" format "x(45)" skip
  fill("=",132) format "x(132)"
  with width 132 frame tltrxh10 no-hide no-box no-label no-underline.
    HIDE FRAME tltrxh10.
    m-var1 = FALSE.

    PUT STREAM m-out2 CHR(15).
     display stream m-out2
 g-comp format "x(70)" skip
            "Исполнитель " v-ofc " Дата   " v-today skip
            "Дата печати  " today string(time,"HH:MM:SS") skip
            "Неотштампованные операции" format "x(45)" skip
  fill("=",132) format "x(132)"
with width 132 frame tltrxh20 no-hide no-box no-label no-underline.
    HIDE FRAME tltrxh20.
    m-var2 = FALSE.
  end.


for each aal WHERE aal.who = v-ofc AND aal.regdt = v-today USE-INDEX aalwho NO-LOCK  BREAK BY aal.crc BY aal.aah BY aal.ln:
	    if FIRST-OF(aal.crc) then
	    do:
		      FIND crc WHERE crc.crc = aal.crc NO-LOCK.
		      form header skip(1)
		            "[ Валюта - "  + crc.des  + " ]"  format "x(70)"
		             with row 6 no-label no-box frame crc1.
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
	    end.
	if (aal.jh = 0 OR aal.jh = ? ) then
    	do:
	      FIND aah WHERE aah.aah = aal.aah NO-LOCK NO-ERROR.
	      if AVAILABLE aah then
		      m-stn = aah.stn.
	      ELSE
		      m-stn = 1.
	      FIND aax WHERE aax.lgr eq aal.lgr AND aax.ln eq aal.aax NO-LOCK NO-ERROR.
		      m-char = string(aal.tim,"HH:MM:SS").
		      m-amtd = 0.
		      m-amtk = 0.
	      if aax.cash <> ? then
	      do:
		        if aax.cash eq TRUE  then
		        do:
			          if m-stn >= 6 then
				          m-sumdk1 = m-sumdk1 + aal.amt.
			          ELSE
				          m-sumdk2 = m-sumdk2 + aal.amt.
		        end.
        		ELSE
		        if aax.cash eq FALSE then
		        do:
			          if m-stn >= 6 then
				          m-sumkk1 = m-sumkk1 + aal.amt.
			          ELSE
				          m-sumkk2 = m-sumkk2 + aal.amt.
		        end.
      	      end.
	      if m-stn = 1       then
		      m-stsstr = "Ош.".
	      ELSE
		      m-stsstr = "   ".
	      if m-stn >= 6 then
	      do:
	        if NOT m-first1  then
	        do:
	          m-first1 = TRUE.
	          VIEW STREAM m-out1 FRAME crc1.
	          HIDE FRAME crc1.
        	end.
	        form   m-char		    column-label "Время"	            aal.aah format 'zzzzzzz9'		    column-label "ЛКТ"	            aal.ln FORMAT "zzzz"		    column-label "Лин"		            aal.jh
		    column-label "Опер.#"	            aal.aax		    column-label "Код Опер. "        	    aax.des		    column-label "Операция "		            aal.aaa		    column-label "Счет "
		            aal.amt format "z,zzz,zzz,zzz,zz9.99-"		    column-label "Сумма"		            aal.teller		    column-label "Штамп  "		            m-stn		    column-label "Стс"
	            m-stsstr format "x(3)"		    column-label "Ош."		    header skip(1)		            with width 132 down frame aaltl no-box  .
		        DISPLAY STREAM m-out1 m-char aal.aah FORMAT 'zzzzzzz9' aal.ln aal.jh aal.aax aax.des aal.aaa  aal.amt FORMAT "z,zzz,zzz,zzz,zz9.99-"  aal.teller m-stn m-stsstr   WITH FRAME aaltl.
      	      end.
	      if m-stn < 6 then
	      do:
	        if NOT m-first2  then
	        do:
        	  m-first2 = TRUE.
	          VIEW STREAM m-out2 FRAME crc1.
        	  HIDE FRAME crc1.
	        end.
        	form            m-char    column-label "Время"            aal.aah format 'zzzzzzz9'    column-label "ЛКТ"            aal.ln FORMAT "zzzz"    column-label "Лин"            aal.jh    column-label "Опер.#"            aal.aax
			    column-label "Код Опер. "            aax.des    column-label "Операция "            aal.aaa    column-label "Счет "            aal.amt format "z,zzz,zzz,zzz,zz9.99-"    column-label "Сумма"            aal.teller
			    column-label "Штамп  "            m-stn    column-label "Стс"            m-stsstr format "x(3)"    column-label "Ош."    header skip(1)            with width 132 down frame aaltl no-box  .
		DISPLAY STREAM m-out2 m-char          aal.aah FORMAT 'zzzzzzz9' aal.ln aal.jh aal.aax aax.des aal.aaa          aal.amt FORMAT "z,zzz,zzz,zzz,zz9.99-"          aal.teller m-stn m-stsstr          WITH FRAME aaltl.
	      end.

	      if aax.dgl ne 0 then
	      do:
	        FIND FIRST otl WHERE otl.gl = aax.dgl  NO-ERROR.
	        if NOT AVAILABLE otl then
	        do:
	          CREATE otl.
		          otl.gl = aax.dgl.
	        end.
	        otl.dam = otl.dam + aal.amt.
	        otl.ndam = otl.ndam + 1.
	      end.
	      if aax.cgl ne 0 then
	      do:
		        FIND FIRST otl WHERE otl.gl = aax.cgl  NO-ERROR.
		        if NOT AVAILABLE otl then
		        do:
		          CREATE otl.
		          otl.gl = aax.cgl.
		        end.
		        otl.cam = otl.cam + aal.amt.
		        otl.ncam = otl.ncam + 1.
	      end.
    	end. 

	    if LAST-OF (aal.crc) then
	    do:
	      if m-first1 then
	      do:
	        m-var1 = TRUE.
	        m-diff = m-sumdk1 - m-sumkk1.
		 form  "Итого касса" m-sumdk1 at 73 m-sumkk1 skip "Остатки касса" m-diff  header  fill("-",132) format "x(132)"  with frame tltotal61  width 132  down no-box no-label no-underline overlay.
	        DISPLAY STREAM m-out1  m-sumdk1 m-sumkk1 m-diff WITH  FRAME tltotal61.        HIDE FRAME tltotal61.        HIDE FRAME aaltl.
	      end.
	      if m-first2 then
	      do:
	        m-var2 = TRUE.
	        m-diff = m-sumdk2 - m-sumkk2.
	        form  "Итого касса  " m-sumdk2 at 73 m-sumkk2 skip "Остатки касса" m-diff   header   fill("-",132) format "x(132)"   with frame tltotal62 width 132   down no-box no-label no-underline overlay.
	        DISPLAY STREAM m-out2          m-sumdk2 m-sumkk2 m-diff WITH FRAME tltotal62.        HIDE FRAME tltotal62.        HIDE FRAME aaltl.
	      end.
	    end.   
end. 


  if m-var1 then
  sts1 = TRUE.

  if m-var2 then
  sts2 = TRUE.


end.
*/


OUTPUT STREAM m-out3 TO VALUE ( lc(TRIM(v-ofc)) + "sum.txt")  page-size 59.
if NOT sts1 AND NOT sts2 then
do:
  PUT STREAM m-out1 CHR(15).
  PUT STREAM m-out2 CHR(15).
  display stream m-out1
  g-comp format "x(70)" skip
            "Исполнитель " v-ofc " Дата   " v-today skip
            "Дата печати  " today string(time,"HH:MM:SS") skip
            "Отштампованные операции" format "x(45)" skip
  fill("=",132) format "x(132)"
with width 132 frame tltrxh11 no-hide no-box no-label no-underline.
 display stream m-out2
 g-comp format "x(70)" skip
            "Исполнитель " v-ofc " Дата   " v-today skip
            "Дата печати  " today string(time,"HH:MM:SS") skip
            "Неакцептованные проводки" format "x(45)" skip
  fill("=",132) format "x(132)"
  with width 132 frame tltrxh21 no-hide no-box no-label no-underline.
  HIDE FRAME tltrxh11.
  HIDE FRAME tltrxh21.
end.



form header "Нет проводок."
  with frame navvar  down
  no-box no-label no-underline overlay.

if NOT sts1 then
VIEW STREAM m-out1 FRAME navvar.
if NOT sts2 then
VIEW STREAM m-out2 FRAME navvar.

DISPLAY STREAM m-out1 SKIP(3).
DISPLAY STREAM m-out2 SKIP(3).

OUTPUT STREAM m-out1 close.
OUTPUT STREAM m-out2 close.

FIND ofc WHERE ofc.ofc = v-ofc NO-LOCK.
vtitle =  " Все операции ответисполнителя за  :" + string(v-today) + chr(10) +
 " Исполнитель : " + ofc.name.
vtoday = v-today.
vtime = string(TIME,"HH:MM:SS").



FORM HEADER
  SKIP(3)
  g-comp vtoday vtime "BY" caps(v-ofc)
  "Page: " + string(PAGE-NUMBER, "zzz9") FORMAT "x(10)" TO 132 SKIP
  g-fname g-mdes SKIP
  vtitle FORMAT "x(132)" SKIP
  FILL("=",132) FORMAT "x(132)" SKIP
  WITH width 132 PAGE-TOP no-box NO-LABEL FRAME rpthead.
VIEW STREAM m-out3 FRAME rpthead.


for each otl WHERE NOT
    ((otl.gl ge v-nbabeg AND otl.gl lt v-nbaend) OR
    (otl.gl ge v-nbpbeg AND otl.gl lt v-nbpend))  BREAK BY otl.gl.


  FIND gl WHERE otl.gl = gl.gl NO-LOCK.
  {ofcsum.f "stream m-out3" }
end.

for each otl WHERE
    ((otl.gl ge v-nbabeg AND otl.gl lt v-nbaend) OR
    (otl.gl ge v-nbpbeg AND otl.gl lt v-nbpend))  BREAK BY otl.gl.

  FIND gl WHERE otl.gl = gl.gl NO-LOCK.
  {ofcsum.f "stream m-out3" }
end.

OUTPUT STREAM m-out3 close.

/* sasco вывод коммунальных */
UNIX silent rm -f value( lc(trim(v-ofc)) + "comm.txt").
run tltrxcomm (lc(trim(v-ofc)) + "comm.txt", v-today, v-ofc, yes).

if caps(trim(dest)) = 'JOE' then
   REPEAT WHILE v-copy gt 0 :
     UNIX value(dest) value( lc(trim(v-ofc)) + "msos.txt").
     PAUSE 0.
     UNIX value(dest) value( lc(trim(v-ofc)) + "mson.txt").
     PAUSE 0.
     UNIX value(dest) value( lc(trim(v-ofc)) + "sum.txt").
     PAUSE 0.
     UNIX value(dest) value( lc(trim(v-ofc)) + "comm.txt").
     PAUSE 0.
     v-copy = v-copy - 1.
  end.
else
   REPEAT WHILE v-copy gt 0 :
     UNIX silent value(dest) value( lc(trim(v-ofc)) + "msos.txt").
     PAUSE 0.
     UNIX silent value(dest) value( lc(trim(v-ofc)) + "mson.txt").
     PAUSE 0.
     UNIX silent value(dest) value( lc(trim(v-ofc)) + "sum.txt").
     PAUSE 0.
     UNIX silent value(dest) value( lc(trim(v-ofc)) + "comm.txt").
     PAUSE 0.
     v-copy = v-copy - 1.
   end.

pause 0 .

UNIX silent rm -f value( lc(trim(v-ofc)) + "msos.txt").
UNIX silent rm -f value( lc(trim(v-ofc)) + "mson.txt").
UNIX silent rm -f value( lc(trim(v-ofc)) + "sum.txt").
UNIX silent rm -f value( lc(trim(v-ofc)) + "comm.txt").
pause 0 . 
