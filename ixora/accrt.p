/* accrt.p
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

/*
    Программа сравнения рассчитанных процентов по пассивным счетам
    с балансом
*/
{mainhead.i UPRSA"}
{image1.i rpt.img}
output to rpt.img.

def var v-sum like aaa.accrued.
def var v-sum1 like glbal.bal column-label "P–rrё±. Ls.".
def var v-diff as decimal column-label "Novirze".
def var v-err as char initial "***" column-label "Kµ­da".


form header
  skip(3)
  g-comp g-today string(time,"HH:MM:SS")  " Izp."  caps(g-ofc)
    skip
  g-fname g-mdes skip
  fill("=",77) format "x(77)" skip
  with no-box no-label frame rpthead.
view  frame rpthead.
	    /*
	    form
	    header "                  Atlikumi" skip
	    "IzpildЁt–js " g-ofc " Datums " g-today skip
	    "Drukas datums " today string(time,"HH:MM:SS") skip
 "======================================================================="
with frame bab no-hide no-box no-label no-underline.
view frame bab.
	      */
for each crc where sts ne 9 no-lock :
      /*
      form
      crc.crc  label "Val"
      crc.des label "Nosaukums"
      crc.rate[1] column-label "Val­tas!kurss"
      crc.rate[9] format "zzzz9" label "par"
      with frame crc no-box .
      */

      form
      crc.crc  label "Val"
      crc.des label "Nosaukums"
      crc.rate[1] column-label "Val­tas!kurss"
      crc.rate[9] format "zzzzzzzz9" label "par"
      with frame crc no-box down.

      disp crc.crc
      crc.des
      crc.rate[1]
      crc.rate[9] with frame crc.

end.

for each lgr no-lock,
each aaa where aaa.lgr eq lgr.lgr no-lock
break by lgr.accgl by lgr.crc by lgr.lgr:


accumulate aaa.accrued (total by lgr.crc).
accumulate aaa.accrued(total by lgr.accgl).
accumulate aaa.accrued(total by lgr.lgr).

if last-of(lgr.accgl) then do:
    find crc where crc.crc eq lgr.crc no-lock no-error.
    find glbal where glbal.gl eq lgr.accgl and glbal.crc eq lgr.crc no-lock
    no-error.
    if available glbal then do:
    display
    lgr.accgl column-label "GGK"
    crc.code column-label "Val"
    lgr.lgr column-label "GRP"
    accum total by lgr.lgr aaa.accrued column-label "Uzkr–tie!gr.kop–"
    accum total by lgr.crc aaa.accrued column-label "Uzkr–tie!val.kop–"
    glbal.bal column-label "Bilance" with width 132.

    v-diff = (accum total by lgr.crc aaa.accrued) - glbal.bal.
    if
    round((accum total by lgr.crc aaa.accrued),2) ne
    glbal.bal then display v-err v-diff with width 132.
    end.
    else
    display
    lgr.accgl column-label "GGK"
    crc.code column-label "Val"
    lgr.lgr column-label "GRP"
    accum total by lgr.lgr aaa.accrued column-label "Uzkr–tie!gr.kop–"
    accum total by lgr.crc aaa.accrued column-label "Uzkr–tie!val.kop–"
    with width 132.
    v-sum1 = v-sum1 +
    (accum total by lgr.crc aaa.accrued) * crc.rate[1] / crc.rate[9].
    display v-sum1 with width 132.
    v-sum1 = 0.
end.
else

if last-of(lgr.crc) then do:
    find crc where crc.crc eq lgr.crc no-lock no-error.
    find glbal where glbal.gl eq lgr.accgl and glbal.crc eq lgr.crc no-lock
    no-error.
    if available glbal then do:
    display
    lgr.accgl column-label "GGK"
    crc.code column-label "Val"
    lgr.lgr column-label "GRP"
    accum total by lgr.lgr aaa.accrued column-label "Uzkr–tie!gr.kop–"
    accum total by lgr.crc aaa.accrued column-label "Uzkr–tie!val.kop–"
    glbal.bal column-label "Bilance" with width 132.

    v-diff = (accum total by lgr.crc aaa.accrued) - glbal.bal.
    if
    round((accum total by lgr.crc aaa.accrued),2) ne
    glbal.bal then display v-err v-diff
    with width 132.
    end.
    else
    display
    lgr.accgl column-label "GGK"
    crc.code column-label "Val"
    lgr.lgr column-label "GRP"
    accum total by lgr.lgr aaa.accrued column-label "Uzkr–tie!gr.kop–"
    accum total by lgr.crc aaa.accrued column-label "Uzkr–tie!val.kop–"
    with width 132.
    v-sum1 = v-sum1 +
    (accum total by lgr.crc aaa.accrued) * crc.rate[1] / crc.rate[9].
end.
else
if last-of(lgr.lgr) then do:
    find crc where crc.crc eq lgr.crc no-lock no-error.
    display
    lgr.accgl column-label "GGK"
    crc.code column-label "Val"
    lgr.lgr
    accum total by lgr.lgr aaa.accrued column-label "Uzkr–tie!gr.kop–"
    with width 132.
end.

end.

display skip(2)
  "*****   DOKUMENTA BEIGAS   *****"   SKIP(1)
  with frame rptend no-box no-label .
output close.
unix silent value(dest) rpt.img.
