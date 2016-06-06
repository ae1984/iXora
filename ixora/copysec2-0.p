/* copysec2-0.p
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

/* copysec2-0.p
   Копирование доступов пользователей в меню от одного к другому по логину

   05.01.2003 nadejda выделен кусок из copysec2.p
*/

def input parameter ofrom as char.
def input parameter oto as char.
def buffer bsec for sec.

for each sec where sec.ofc = ofrom no-lock:
  find first bsec where bsec.ofc = oto and bsec.fname = sec.fname no-lock no-error.
  if not avail bsec then do:
    create bsec.
    assign bsec.ofc = oto
           bsec.fname = sec.fname.
  end.
end.

