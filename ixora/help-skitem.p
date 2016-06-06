/* help-skitem.p
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
	02.09.05 nataly была добавлена {sk_all.i} для перекомпиляции
*/
{sk_all.i}

def input parameter v-grp like grp.grp.
def var choice as int format "9" init 2.
def var str as char format "x(60)" init ''.
message "Поиск по номеру (1) или поиск по части названия (2)" update choice. 
if choice = 2 then message "Часть названия" update str.
{skappbra.i
      &head      = "item"
      &index     = "grp_item no-lock"
      &formname  = "sk-help"
      &framename = "hitem"
      &where     = " item.grp = v-grp and caps(item.des) matches '*' + caps(trim(str)) + '*' and item.arc <> yes "
      &addcon    = "false"
      &deletecon = "false"
      &display   = "item.item item.des"
      &highlight = "item.item item.des"
      &postkey   = "else if keyfunction(lastkey) = 'RETURN' then do 
                          on endkey undo, leave:
                           /* frame-value = item.item. */
                           hide frame hitem.
                           return string(item.item).  
                    end."
      &end = "hide frame hitem."
}          

