/* memor.p
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

/*программа формирует мемориальные обороты по счетам ГК*/
define var datJdt2 as date /* initial today*/.
define var datJdt1 as date /*initial today*/.
define temp-table tct
field tjh like jl.jh
field tgl like jl.gl
field tcam like jl.cam
field tcrc like jl.crc
field tln like jl.ln
field tf as integer
index iJdt tjh tf.
/*THE INDEX  iJdt WAS ADDED BY TIMUR*/


define temp-table tdc
field jh like jl.jh
field gl1 like jl.gl
field gl2 like jl.gl
field sum like jl.dam
field crc like jl.crc.

update datJdt1 label 'С' 
       datJdt2  label 'ПО'
       with row 8 centered side-label   frame opt .
               
hide frame opt.
for each jl where 
/*(jl.jh = 645971 or jl.jh = 475707 or jl.jh = 568607)*/ 
jl.jdt <= datJdt2 and jl.jdt >= datJdt1 
and jl.dc = "C" break by jl.jh by jl.crc by jl.ln:
    create tct.
    tct.tjh = jl.jh.
    tct.tgl = jl.gl.
    tct.tcam = jl.cam.
    tct.tcrc = jl.crc.
    tct.tln = jl.ln.
end.
for each jl where 
/*(jl.jh = 645971 or jl.jh = 475707 or jl.jh = 568607)*/ 
jl.jdt <= datJdt2 and jl.jdt >= datJdt1 
and jl.dc = "D" break by jl.jh by jl.crc by jl.ln:
    find first tct where tct.tjh = jl.jh and tct.tf = 0.
    if jl.dam = tct.tcam and jl.crc = tct.tcrc then do:
        tct.tf = 1.
        create tdc.
        tdc.jh = jl.jh.
        tdc.gl1 = jl.gl.
        tdc.gl2 = tct.tgl.
        tdc.sum = jl.dam.
        tdc.crc = jl.crc.
    end.
    else do:
        create tdc. 
        tdc.jh = jl.jh.
        tdc.gl1 = jl.gl.
        tdc.gl2 = 999999.
        tdc.sum = jl.dam.
        tdc.crc = jl.crc.
    end.
end.
output to "www5.txt".
put "" skip.
put "                     МЕМОРИАЛЬНЫЕ ОБОРОТЫ" skip.
put "                            " datJdt1 " - " datJdt2 skip.
put "--------------------------------------------------------------" skip.
put "Вал. Дебет      Кредит                       Оборот       Кол." skip.
put "--------------------------------------------------------------" skip.
for each tdc break by tdc.crc by tdc.gl1 by tdc.gl2:
    accumulate sum (total by tdc.crc by tdc.gl1 by tdc.gl2). 
    accumulate sum (total by tdc.crc by tdc.gl1).
    accumulate sum (count by tdc.crc by tdc.gl1 by tdc.gl2).
    if last-of(gl2) then do:
        put tdc.crc "   " tdc.gl1 "     " tdc.gl2 "          " accum total by tdc.gl2 tdc.sum format "->>>,>>>,>>>,>99.99" " " accum count by tdc.gl2 tdc.sum skip.
    end.
    if last-of(gl1) then do:
        
        put "     Итого:                     " accum total by tdc.gl1 tdc.sum format  "->>>,>>>,>>>,>99.99" skip.
        put "--------------------------------------------------------------" skip.
        
    end.
end.
/*for each tdc break by tdc.crc:
    displ tdc.
end.*/
output close.
run menu-prt('www5.txt').