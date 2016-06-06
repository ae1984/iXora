/* nlmenued.p
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

/* nlmenued.p
   National Language Menu Description Entry
*/

{mainhead.i NLMENU}

define buffer b-nmenu for nmenu.
define var v-father like nmenu.father initial "MENU".
define var v-fname  like nmenu.fname.
define var v-max    as   int.
define var v-proc   like nmenu.proc.
define var v-ln like nmenu.ln.
define var fv as char.
define var inc as int.

repeat:
  repeat:
    v-max = 0.
    form nmenu.ln nmdes.des nmenu.fname nmenu.link nmenu.proc
	 with centered row 4 no-box 13 down frame nmenu.
    clear frame nmenu all no-pause.
    for each nmenu where nmenu.father eq v-father:
      find nmdes where nmdes.lang eq g-lang
		  and  nmdes.fname eq nmenu.fname no-error.
      disp nmenu.ln
	   nmdes.des when available nmdes
	   nmenu.fname nmenu.link nmenu.proc
	with frame nmenu.
      v-max = nmenu.ln.
      if v-max ge 13 then leave.
      down with frame nmenu.
    end.
    choose row nmenu.ln with frame nmenu.
    if frame-value eq "" then do:
      bell.
      undo, retry.
      /*
      create nmenu.
      nmenu.father = v-father.
      nmenu.ln = v-max + 1.
      display nmenu.ln nmenu.fname with frame nmenu.
      create nmdes.
      nmdes.lang = g-lang.
      */
    end.
    else do:
      find nmenu where nmenu.father eq v-father
		  and  nmenu.ln eq integer(frame-value).
    end.
    /*
    display nmdes.des nmenu.fname nmenu.link nmenu.proc nmenu.ln
	   with frame nmenu.
	   */
    form nmdes.lang nmdes.des
	with row 8 centered overlay top-only down frame nmdes.
    clear frame nmdes all no-pause.
    for each nmdes where nmdes.fname eq nmenu.fname:
      display nmdes.lang nmdes.des
	with frame nmdes.
      down with frame nmdes.
    end.
    choose row nmdes.lang with frame nmdes.
    if frame-value ne "" then do:
      find nmdes where nmdes.lang eq frame-value
		  and  nmdes.fname eq nmenu.fname no-error.
    end.
    else do:
      create nmdes.
      nmdes.fname = nmenu.fname.
      set nmdes.lang with frame nmdes.
    end.
    update nmdes.des with frame nmdes.
    if nmenu.link eq "" and nmenu.proc eq "" then do:
      v-father = nmenu.fname.
      next.
    end.
  end.
  if v-father ne "MENU" then do:
    find nmenu where nmenu.fname eq v-father.
    v-father = nmenu.father.
  end.
  else leave.
end.
