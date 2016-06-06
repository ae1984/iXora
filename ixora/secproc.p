/* secproc.p
 * MODULE
        Администрирование ПРАГМЫ
 * DESCRIPTION
        Список пользователей с доступом к функции по имени функции
 * RUN
        главное меню
 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        9-1-5-12
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        07.05.2004 nadejda - исправлена ошибка при добавлении новых записей - теперь добавляет нормально
                             добавлены метки по-русски
        25/07/2007 madiyar - убрал ссылку на удаленную таблицу
        16/05/2012 madiyar - расширил формат поля для ввода функции
*/

/* secproc.p
   security maintenance by procedure name
*/

{mainhead.i}  /*  SECURITY MAINTENANCE BY PROCEDURE NAME  */

def var vproc like nmenu.proc.
def var v-fname as char.

main: repeat:
  update v-fname label "ФУНКЦИЯ" format "x(40)"
  /* help "Enter procedure name or ? for list." */
    with frame proc row 3 side-label centered.
  /*
  if input sec.proc = ? then do:
    {mesg.i 0860} update vproc.
    for each menu use-index proc where menu.proc >= vproc:
      display menu.proc menu.des menu.mgrp with row 2 centered down.
    end.
    undo main, retry.
  end.
  */
  find nmenu where nmenu.fname = v-fname no-lock no-error.
  find nmdes where nmdes.fname = nmenu.fname and nmdes.lang = g-lang no-lock no-error.
  display nmdes.des no-label when available nmdes with frame proc.

  {mult.i
   &head = sec
   &headkey = ofc
   &where = "sec.fname = v-fname"
   &index = "ofcfname"
   &type = string
   &datetype = " "
   &formname = secproc
   &framename = sec
   &addcon = true
   &updatecon = true
   &deletecon = true
   &start = " "
   &viewframe = " "
   &predisplay = "find ofc where ofc.ofc eq sec.ofc no-error.
                  if avail ofc then do:"
   &display = "sec.ofc ofc.name"
   &postdisplay = " end."
   &numprg = prompt
   &preadd = " "
   &postadd = " sec.fname = v-fname. "
   &newpreupdate = " "
   &preupdate = " "
   &update = "sec.ofc"
   &postupdate = " "
   &newpostupdate = " "
   &predelete = " "
   &postdelete =  " "
   &get = " "
   &put = " "
   &end = " "
  }
end.
