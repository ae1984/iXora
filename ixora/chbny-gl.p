/* chbny-gl.p
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


define var vgl like gl.gl.
define var vdes like gl.des.
define var vsname like gl.sname.
define var vdname1 like gl.dname1.
define var vdname2 like gl.dname2.
define var vcname1 like gl.cname1.
define var vcname2 like gl.cname2.
define var vsubled like gl.subled.
define var vlevel like gl.level.
define var vgrp like gl.grp.
define var vrevgl like gl.revgl.
define var vgl1   like gl.gl1.
define var vautogl like gl.autogl.
define var vcode like gl.code.

input from gl.d no-echo.

output to rpt.img page-size 59.
repeat:
  set vgl vdes vsname vdname1 vdname2 vcname1 vcname2 vsubled
      vlevel vgrp vrevgl vgl1 vautogl vcode.
  display
     vgl    label "ACCT#"
     vdes
     vdname1 at 49 vdname2
     vsubled label "SUBLED"
     vlevel
     vgrp
     vcode
     vsname at 8
     vcname1 at 49 vcname2
     vrevgl  label "REVERSE"
     vgl1    label "PROFIT#"
     vautogl label "CONTRA"
     skip(1)
     with width 132 down frame prn.
end.
output close.

input close.
