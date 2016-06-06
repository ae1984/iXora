/* kztcfind.p
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


/*DISABLE acnt commonpl.sum WITH FRAME sf. */

def var cnt as integer.
def var acnt as char.

def frame sfi
     cnt    label "Телефон"  format "999999" 
     acnt   view-as text label "Сч. извещение."     format "x(15)" skip
     "Enter - Выбор счета " at 1   with side-labels centered overlay view-as dialog-box.

    on value-changed of cnt in frame sfi do:
        cnt = integer(cnt:screen-value).

        find first kaztelsp where kaztelsp.phone = integer(cnt:screen-value) 
                   USE-INDEX phone no-lock no-error.

        if avail kaztelsp then acnt = kaztelsp.statenmb. 
                          else acnt = ''. 

        displ acnt with frame sfi.
        apply "value-changed" to self.
    end.

on endkey of cnt in frame sfi
    do:
          hide frame sfi.
          return string(cnt).
    end.

on return of cnt in frame sfi
    do: 
        apply "endkey" to frame sfi.
    end.  

        UPDATE 
               cnt validate(
                        can-find( first kaztelsp where
                        kaztelsp.phone = cnt no-lock), "Не верный счет")
               WITH FRAME sfi editing:
                   readkey.
                   apply lastkey.
                   if frame-field = "cnt" then
                            apply "value-changed" to cnt in frame sfi.
               end.

hide frame sfi.
return string(acnt).

/* Enable acnt commonpl.sum WITH FRAME sf. */
