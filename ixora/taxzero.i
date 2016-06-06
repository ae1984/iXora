/* taxzero.i
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
        05/09/2006 u00568 Evgeniy - еслт f4 то возвращает пробел.
*/


def new shared var df_name as char init "".

def var s_full_name as char.

define frame sfx with side-labels centered view-as dialog-box.

def frame sfx
     "ФИО налогоплательщика " skip
     "----------------------------------------------------"  skip
     df_name                          label "ФИО"            format "x(45)"
     with side-labels centered.

do transaction on error undo, return :
  update
    df_name
  with frame sfx editing:
    readkey.
    apply lastkey.
  end.
end.

s_full_name = df_name.

hide frame sfx.
return s_full_name.
