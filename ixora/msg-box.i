/* msg-box.i
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

/* Generates a frame with a given text and no-pause option */

define var myMsgInfoString as char.
define frame myMsgInfoFrame
             myMsgInfoString format "x(50)"
             with row 2 centered no-labels overlay.

procedure SHOW-MSG-BOX.
def input parameter inStr as char.
    displ inStr @ myMsgInfoString with frame myMsgInfoFrame. 
    pause 0.
end procedure.

procedure HIDE-MSG-BOX.
    hide frame myMsgInfoFrame. 
    pause 0.
end procedure.
