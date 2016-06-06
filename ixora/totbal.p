/* totbal.p
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

def buffer b-glbal for glbal.
def buffer b-gl for gl.
def var v-crc like crc.crc.
def var less as cha format "x(20)".
hide all.
display " Currency ? ( 0 - all ) " v-crc no-label with centered row 4  frame qq.
update v-crc with frame qq.
display " Print command ? " less with centered no-label frame eee.
update less with frame eee.
display " W a i t , making file 'rpt.img' ... " with centered frame ww.
unix silent cp rpt.img rpt.bak.
output to rpt.img.
put chr(15) chr(10) .
display skip.
for each crc where crc.crc = v-crc or v-crc = 0 .
 for each gl where gl.totlev ne 0 and gl.totgl ne 0
  break by gl.totgl by gl.gl.
   output to terminal.
    display crc.crc crc.des with centered frame zzz.
   pause 0.
   output to rpt.img append.
    find glbal where glbal.crc  =  crc.crc and glbal.gl = gl.gl.
    display  gl.gl glbal.bal  (total  by
     gl.totgl )  with no-label no-box.
    if last-of(gl.totgl) then do:
     find b-glbal where b-glbal.gl = gl.totgl and b-glbal.crc = crc.crc.
     display  gl.totgl b-glbal.bal ( total by gl.totgl) with no-label.
    end.
  end.
  end.
  output to terminal.
  hide frame qq.
  hide frame ww.
  hide frame zzz.
  hide frame eee.
  display "" skip with no-box.

  unix silent value(less) rpt.img.
