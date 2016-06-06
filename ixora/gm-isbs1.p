/* gm-isbs1.p
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
       25/07/2007 madiyar - убрал упоминание удаленной таблицы e002
*/

/* gm-isbs.p
   06/07/93 edited by S. Choi
   03/03/00 
   13/06/00
*/

{mainhead.i "MBSPL2"}

define buffer b-gl for gl.
define buffer basecrc for crc.
define buffer crc2 for crc.
def buffer p-crc for crc.
define buffer b-crc for crc.

define var vasof as date.
define var vbal as deci extent 4 format 'zzz,zzz,zzz,zz9.99-'.
define var savefile as cha.
define var vtitle-1 as char format "x(110)".
define var v-crc like crc.crc initial 1.
/***********/
def temp-table gll field gllist as char format "x(10)".
def var i as int.
def var tt as cha.
def var v-gll as char format "x(10)".
def var v-name like gl.des init "".
def var vgl like pglbal.gl.
/*def var v-sysc like sysc.chval.*/
def temp-table tbal
             field point like point.point
             field npoint as char format "x(30)"
             field gl like jl.gl
             field crc like jl.crc
             field lbal as deci decimals 4
             field bbal as deci decimals 4
             field kbal as deci decimals 4.
def var n-point as char format "x(30)".
def var v-point like point.point.
def var pvglbal like glbal.bal.
def var pvsubbal like glbal.bal.

/***********/



find sysc where sysc.sysc eq "GLDATE" no-lock no-error.
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
if g-batch eq false then do:
  update v-crc validate(can-find(crc where crc.crc eq v-crc),
                        "RECORD NOT FOUND")
         with centered row 9 side-label no-box frame crc.
end.
{image2.i}


find basecrc where basecrc.crc eq v-crc no-lock no-error.
find crc where crc.crc eq 1 no-lock no-error.
    

{report1.i 59}
    
vtitle = "БАЛАНС (ТЕНГЕ)    ЗА " + string(vasof).

vtitle-1 =
" Г/К          НАЗВАНИЕ                       НАЦИОНАЛЬНАЯ ВАЛЮТА        "
 + "ПРОЧИЕ ВАЛЮТЫ               ВСЕГО".

{report2.i 110 "vtitle-1 skip fill(""="",110) format ""x(110)"" skip" aa}

for each gl where (gl.type eq "A" or gl.type eq "L" or gl.type eq "O")
             and  gl.ibfact eq false no-lock
             break by gl.type by gl.gl :
  if first(gl.type) then do:
    for each crc where crc.sts ne 9 no-lock:
      disp crc.crc label "ВАЛ."crc.des label "НАЗВАНИЕ"
      crc.rate[1] format "zzz9.99" label "КУРС " crc.rate[9] format
      "zzzzzz9" label "РАЗМЕРНОСТЬ".
    end.
    find crc where crc.crc eq 1 no-lock no-error.
  end.

  if first-of(gl.type)
    then do:
           if gl.type eq "A"
        then do:
               put skip(1) "*** АКТИВЫ ***" skip(1).
             end.
      else if gl.type eq "L"
        then do:
       /*   page.  */
          put skip(1) "*** ПАССИВЫ ***" skip(1).
        end.
      else if gl.type eq "O"
        then do:
          put skip(1) "*** КАПИТАЛ ***" skip(1).
        end.
    end.
  find glbal where glbal.gl eq gl.gl and glbal.crc eq 1 no-lock no-error.
  vbal[1] = glbal.bal * basecrc.rate[9] / basecrc.rate[1].

  /* other currencies */
  vbal[3] = 0.
  for each glbal where glbal.gl eq gl.gl and glbal.crc ge 2 no-lock:
    find b-crc where b-crc.crc eq glbal.crc no-lock no-error.
    vbal[3] = vbal[3] + glbal.bal *
    (b-crc.rate[1] * basecrc.rate[9] / (basecrc.rate[1] * b-crc.rate[9])).
  end.

  if gl.ibfgl ne 0 then do:
      find b-gl where b-gl.gl eq gl.ibfgl no-lock no-error.
      find glbal where glbal.gl eq gl.ibfgl and glbal.crc eq 1 no-lock no-error.
/*      vbal[1] = vbal[1] + glbal.bal.  */
  vbal[1] = vbal[1] + glbal.bal * basecrc.rate[9] / basecrc.rate[1].
      /* other currencies */
      for each glbal where glbal.gl eq gl.ibfgl and glbal.crc ge 2 no-lock:
        find b-crc where b-crc.crc eq glbal.crc no-lock no-error.
    vbal[3] = vbal[3] + glbal.bal *
    (b-crc.rate[1] * basecrc.rate[9] / (basecrc.rate[1] * b-crc.rate[9])).
      end.
  end.
  vbal[4] = vbal[1] + vbal[3].
  if gl.vadisp then  do:
  display gl.gl when gl.gldisp
          gl.des form "x(35)"
          vbal[1]
          vbal[3]
          vbal[4]
          with width 110 no-label down frame bs.
  if gl.nskip ne 0 then down 1 with frame bs.
  end.
end.
hide frame rptbottomaa.
{report3.i " " aa} 

output to value(vimgfname) page-size 59 append.           /*доходы,расходы*/
vtitle = "ДОХОДЫ И РАСХОДЫ        ЗА " + string(vasof).

vtitle-1 =
" Г/К          НАЗВАНИЕ                       НАЦИОНАЛЬНАЯ ВАЛЮТА        "
 + "ПРОЧИЕ ВАЛЮТЫ               ВСЕГО".


{report2.i 110 "vtitle-1 skip fill(""="",110) format ""x(110)"" skip" bb}

for each gl where (gl.type eq "R" or gl.type eq "E")
             and  gl.ibfact eq false no-lock
             break by gl.type descending by gl.gl :

  if first-of(gl.type)
    then do:
           if gl.type eq "R"
        then do:
               put skip(1) "*** ДОХОДЫ ***" skip(1).
             end.
      else if gl.type eq "E"
        then do:
      /*    page.    */
          put skip(1) "*** РАСХОДЫ ***" skip(1).
        end.
    end.
  find glbal where glbal.gl eq gl.gl and glbal.crc eq 1 no-lock no-error.
/* vbal[1] = glbal.bal / basecrc.rate[1].    */
  vbal[1] = glbal.bal * basecrc.rate[9] / basecrc.rate[1].
  /* other currencies */
  vbal[3] = 0.
  for each glbal where glbal.gl eq gl.gl and glbal.crc ge 2 no-lock:
    find b-crc where b-crc.crc eq glbal.crc no-lock no-error.
    vbal[3] = vbal[3] + glbal.bal *
    (b-crc.rate[1] * basecrc.rate[9] / (basecrc.rate[1] * b-crc.rate[9])).
  end.
  if gl.ibfgl ne 0 then do:
      find b-gl where b-gl.gl eq gl.ibfgl no-lock no-error.
      find glbal where glbal.gl eq gl.ibfgl and glbal.crc eq 1 no-lock no-error.
/*      vbal[1] = vbal[1] + glbal.bal.      */
  vbal[1] = glbal.bal * basecrc.rate[9] / basecrc.rate[1].
      /* other currencies */
      for each glbal where glbal.gl eq gl.ibfgl and glbal.crc ge 2 no-lock:
        find b-crc where b-crc.crc eq glbal.crc no-lock no-error.
    vbal[3] = vbal[3] + glbal.bal *
    (b-crc.rate[1] * basecrc.rate[9] / (basecrc.rate[1] * b-crc.rate[9])).
      end.
  end.
  vbal[4] = vbal[1] + vbal[3].

  if gl.vadisp then do:
  display gl.gl when gl.gldisp
          gl.des form "x(35)"
          vbal[1]
          vbal[3]
          vbal[4]
          with width 110 no-label down frame glis.
  if gl.nskip ne 0 then down 1 with frame glis.
  end.
end.
hide frame rptbottombb.
{report3.i " " bb}  










/*******************************/

/*output to value(vimgfname) page-size 59 append.           /*пункты*/
vtitle = "РАСЧЕТНЫЕ ГРУППЫ             ЗА " + string(vasof).

vtitle-1 =
" Г/К          НАЗВАНИЕ                       НАЦИОНАЛЬНАЯ ВАЛЮТА        "
 + "ПРОЧИЕ ВАЛЮТЫ               ВСЕГО".

{report2.i 110 "vtitle-1 skip fill(""="",110) format ""x(110)"" skip" cc}

for each gl where gl.ibfact eq false break by gl.gl:
    find first gll where gll.gllist = string(gl.gl) no-lock no-error.
    if available gll then do:
        find first glbal where glbal.gl eq gl.gl and glbal.crc eq 1 no-lock
        no-error.
        vbal[1] = glbal.bal * basecrc.rate[9] / basecrc.rate[1].

        /* other currencies */
        vbal[3] = 0.
        for each glbal where glbal.gl eq gl.gl and glbal.crc ge 2:
            find b-crc where b-crc.crc eq glbal.crc.
            vbal[3] = vbal[3] + glbal.bal * (b-crc.rate[1] *
            basecrc.rate[9] / (basecrc.rate[1] * b-crc.rate[9])).
        end.

        if gl.ibfgl ne 0 then do:
            find b-gl where b-gl.gl eq gl.ibfgl.
            find glbal where glbal.gl eq gl.ibfgl and glbal.crc eq 1.
            vbal[1] = vbal[1] + glbal.bal * basecrc.rate[9] / basecrc.rate[1].
            /* other currencies */
            for each glbal where glbal.gl eq gl.ibfgl and glbal.crc ge 2:
                find b-crc where b-crc.crc eq glbal.crc.
                vbal[3] = vbal[3] + glbal.bal * (b-crc.rate[1] *
                basecrc.rate[9] / (basecrc.rate[1] * b-crc.rate[9])).
            end.
        end.
        vbal[4] = vbal[1] + vbal[3].
        if gl.vadisp then  do:
            display gl.gl when gl.gldisp
            gl.des form "x(35)"
            vbal[1]
            vbal[3]
            vbal[4]
            with width 110 no-label down frame sbs.
            if gl.nskip ne 0 then down 1 with frame sbs.
        end.

/*for each point break by point.point:*/
    for each pglbal where pglbal.gl eq gl.gl and pglbal.crc eq 1
    break by point:
        find point where point.point = pglbal.point no-lock no-error.
        find first tbal where tbal.point = pglbal.point and
        tbal.gl = pglbal.gl no-lock no-error.
        if not available tbal then do:
            create tbal.
            tbal.gl = pglbal.gl.
            tbal.point = pglbal.point.
            tbal.npoint = point.addr[1].
        end.
        tbal.lbal = tbal.lbal +
        pglbal.bal * basecrc.rate[9] / basecrc.rate[1].
        tbal.kbal = tbal.kbal +
        pglbal.bal * basecrc.rate[9] / basecrc.rate[1].
    end. /*pglbal*/
        /* other currencies */
        tbal.bbal = 0.
        for each pglbal where pglbal.gl eq gl.gl and pglbal.crc ge 2
        break by pglbal.point:
            find p-crc where p-crc.crc eq pglbal.crc.
            find first tbal where tbal.point = pglbal.point and
            tbal.gl = pglbal.gl no-lock no-error.
            if not available tbal then do:
                create tbal.
                tbal.gl = pglbal.gl.
                tbal.point = pglbal.point.
            end.
                tbal.bbal = tbal.bbal + pglbal.bal *
(p-crc.rate[1] * basecrc.rate[9] / (basecrc.rate[1] * p-crc.rate[9])).
                tbal.kbal = tbal.kbal + pglbal.bal *
    (p-crc.rate[1] * basecrc.rate[9] / (basecrc.rate[1] * p-crc.rate[9])).

        end.   /*pglbal*/

        for each tbal break by tbal.point:
            display "Grupa" tbal.point
            tbal.npoint format "x(33)"
            tbal.lbal format "z,zzz,zzz,zzz,zz9.99-"
            tbal.bbal format "z,zzz,zzz,zzz,zz9.99-"
            tbal.kbal format "z,zzz,zzz,zzz,zz9.99-"
            with width 132 no-label down frame ssbs.
            if gl.nskip ne 0 then down 1 with frame ssbs.
        end.  /*tbal*/
    end.       /*gll*/
end. /*gl*/
hide frame rptbottomcc.
{report3.i " " cc} */
/*******************************/
{image3.i no}
/*find sysc where sysc.sysc eq "SAVDIR".
savefile = sysc.chval +
           substring(string(g-today),1,2) +
           substring(string(g-today),4,2).
unix silent cp rpt.img value(savefile).*/
