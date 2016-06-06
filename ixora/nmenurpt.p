/* nmenurpt.p
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

/* nmenurpt.p
*/

{mainhead.i MMRPT}

define var v-stack as cha.
define var v-ln like nmenu.ln.
define var v-lnstack as cha.
define var v-deep as int.
define var vnmdes like nmdes.des.

v-stack = "menu".
v-ln = 1.
v-deep = 1.

{image1.i rpt.img}
{image2.i}
{report1.i 55}
{report2.i 132}

repeat:
  find nmenu where nmenu.father eq entry(1,v-stack)
	      and  nmenu.ln eq v-ln no-error.
  if not available nmenu then do:
    if v-deep eq 1 then leave.
    v-ln = integer(entry(1,v-lnstack)).
    v-stack = substring(v-stack,index(v-stack,",") + 1).
    v-lnstack = substring(v-lnstack,index(v-lnstack,",") + 1).
    v-deep = v-deep - 1.
    put skip(1).
    next.
  end.
  find nmdes where nmdes.lang eq g-lang
	      and  nmdes.fname eq nmenu.fname no-error.

  if available nmdes then
    vnmdes = nmdes.des.
  else vnmdes = "".

  put space(8 * v-deep - 8)
      nmenu.ln space(1)
      vnmdes space(1)
      nmenu.fname space(1)
      nmenu.link
      nmenu.proc skip.
  v-ln = v-ln + 1.
  if nmenu.proc eq "" and nmenu.link eq "" then do:
    v-stack = nmenu.fname + "," + v-stack.
    v-lnstack = string(v-ln) + "," +  v-lnstack.
    v-ln = 1.
    v-deep = v-deep + 1.
  end.
end.
{report3.i}
{image3.i}
