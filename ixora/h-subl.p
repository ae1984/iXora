/* h-subl.p
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


def  var oo as char extent 2 format "x(3)" initial
     ["DFB", "CIF"].
def var x as int.
def var y as int.
def var v-subl like bankt.sub.
def var v-time as cha.
def shared frame bankt.


{bankt.f}

x = frame-line(bankt).
y = frame-row(bankt).

x = x + y.

     form oo with overlay row x 1 columns col 24  no-labels
		      frame oo.
		    display oo with frame oo.
		    choose field oo AUTO-RETURN with frame oo .
frame-value = frame-value.
