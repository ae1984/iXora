/* gl-isbs1.p
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
*/

/* checked jane */
/* gl-isbs.org
   08-30-90 created by S. Choi
   09-05-90 revised by Simon Y. Kim
*/

{mainhead.i BSPL}  /* BALANCE SHEET & INCOME STATEMENT */

define buffer b-gl for gl.
define var vasof as date.
define var vbal like jl.dam label "B A L A N C E  ".
define var savefile as cha.
define var vtitle-1 as char format "x(80)".
define var vcrc like crc.crc .
def var vdes like crc.des.
define var pcrc like crc.crc initial 1.
def var bbal like glbal.bal.
def temp-table gll field gllist as char format "x(10)".
def var i as int.
def var tt as cha.
def var v-gll as char format "x(10)".
def var v-name like gl.des init "".
def var vgl like pglbal.gl.
def temp-table tbal
             field point like point.point
             field npoint as char format "x(30)"
             field gl like jl.gl
             field crc like jl.crc
             field lbal like pglbal.bal.
def var n-point as char format "x(30)".
def var v-point like point.point.
def var pvglbal like glbal.bal.
def var pvsubbal like glbal.bal.

find sysc where sysc.sysc eq "GLDATE".
vasof = sysc.daval.
/*********************/

find sysc where sysc.sysc = "GLPNT" no-lock no-error.
tt = sysc.chval .
repeat :
 create gll .
 gll.gllist = substr(tt,1,index(tt,",") - 1 ).
 tt = substr(tt,index(tt,",") + 1,length(sysc.chval)).
 if tt = "" then leave .
end.
/*********************/

{image1.i rpt.img}
 if g-batch eq false
    then do:
      update pcrc help " 0 - All currency "
             with centered no-box side-label row 8 frame opt.
      find last cls.
/*      vasof = cls.cls.    */
 end.

{image2.i}

{report1.i 59}

for each crc where crc.sts eq 0 and (crc.crc eq pcrc or pcrc eq 0 ) no-lock
break by crc:

    if pcrc eq 0 then do:

        find first glbal where glbal.crc eq crc.crc and glbal.bal ne 0
        no-lock no-error.
        if not available glbal then next.

    end.
/*
    if pcrc eq 0 then do:

        find first pglbal where pglbal.crc eq crc.crc and pglbal.bal ne 0
        no-lock no-error.
        if not available pglbal then next.

    end.
*/
vcrc = crc.crc.
vdes = crc.des.

vtitle = " BILANCE  (" + vdes + ")" + "    PAR " + string(vasof).

vtitle-1 = {gl-isvt11.f}

{report2.i 80 "vtitle-1 skip fill(""="",80) format ""x(80)"" skip" aa}

for each gl where (gl.type eq "A" or gl.type eq "L" or gl.type eq "O")
             and  gl.ibfact eq false
             break by gl.type by gl.gl:

  if first-of(gl.type)
    then do:
           if gl.type eq "A"
        then do:
                {gl-isA1.f}
             end.
      else if gl.type eq "L"
        then do:
               {gl-isL1.f}
        end.
      else if gl.type eq "O"
        then do:
                 {gl-isO1.f}
        end.
    end.

  find glbal where glbal.gl eq gl.gl and glbal.crc eq vcrc.
  vbal = glbal.bal.

  if gl.ibfgl ne 0
    then do:
      find b-gl where b-gl.gl eq gl.ibfgl.
      find glbal where glbal.gl eq b-gl.gl and glbal.crc eq vcrc no-lock
      no-error.
      vbal = vbal + glbal.bal.
    end.
  if gl.vadisp then do:
      if vbal ne 0 then
      display gl.gl when gl.gldisp eq true
          gl.des when gl.gldisp eq true
          vbal when gl.vadisp eq true
          with width 80 no-label down frame bs.
      if gl.nskip ne 0 then down gl.nskip with frame bs.
  end.

end.

for each gl where (gl.type eq "R" or gl.type eq "E")
             and  gl.ibfact eq false
             break by gl.type descending by gl.gl:

  if first-of(gl.type)
    then do:
           if gl.type eq "R"
        then do:
               {gl-isR1.f}
             end.
      else if gl.type eq "E"
        then do:
               {gl-isE1.f}
        end.
    end.

  find glbal where glbal.gl eq gl.gl and glbal.crc eq vcrc.
  vbal = glbal.bal.

  if gl.ibfgl ne 0
    then do:
      find b-gl where b-gl.gl eq gl.ibfgl.
      find glbal where glbal.gl eq b-gl.gl and glbal.crc eq vcrc.
      vbal = vbal + glbal.bal.
    end.

  if gl.vadisp then do:
  if vbal ne 0 then
  display gl.gl when gl.gldisp eq true
          gl.des when gl.gldisp eq true
          vbal when gl.vadisp eq true
          with width 80 no-label down frame glis.
  if gl.nskip ne 0 then down gl.nskip with frame glis.
  end.


end.

/*******************************/

for each gl where gl.ibfact eq false break by gl.gl:
    find first gll where gll.gllist = string(gl.gl) no-lock no-error.
    if available gll then do:
        {gl-point1.f}
        find first glbal where glbal.gl eq gl.gl and glbal.crc eq vcrc no-lock
        no-error.
        vbal = glbal.bal.

        if gl.ibfgl ne 0 then do:
            find b-gl where b-gl.gl eq gl.ibfgl.
            find glbal where glbal.gl eq gl.ibfgl and glbal.crc eq vcrc.
            vbal = vbal + glbal.bal.
        end.
        if gl.vadisp then  do:
            display gl.gl when gl.gldisp eq true
            gl.des form "x(40)" when gl.gldisp eq true
            vbal when gl.vadisp eq true
            with width 132 no-label down frame sbs.
            if gl.nskip ne 0 then down 1 with frame sbs.
        end.

    for each pglbal where pglbal.gl eq gl.gl and pglbal.crc eq vcrc
    break by point:
        if pglbal.bal eq 0 then next.
        find point where point.point = pglbal.point no-lock no-error.
        find first tbal where tbal.point = pglbal.point and
        tbal.gl = pglbal.gl and tbal.crc = pglbal.crc no-lock no-error.
        if not available tbal then do:
            create tbal.
            tbal.gl = pglbal.gl.
            tbal.point = pglbal.point.
            tbal.npoint = point.addr[1].
            tbal.crc = pglbal.crc.
        end.
        tbal.lbal =  tbal.lbal + pglbal.bal.
    end. /*pglbal*/

        for each tbal where tbal.crc = vcrc break by tbal.point:
            display "Grupa" tbal.point
            tbal.npoint format "x(38)"
            tbal.lbal
            with width 132 no-label down frame ssbs.
            if gl.nskip ne 0 then down 1 with frame ssbs.
        end.  /*tbal*/
    end.       /*gll*/
end. /*gl*/

if not last(crc.crc) and pcrc eq 0 then page.
end.     /* crc */
{report3.i " " aa}
/*******************************/
{image3.i no}
/*find sysc where sysc.sysc eq "SAVDIR".
savefile = sysc.chval +
           substring(string(g-today),1,2) +
           substring(string(g-today),4,2).
unix silent cp rpt.img value(savefile).*/
