/* pssecset.p
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

/* h-quetyp.p */
  {global.i} 
/*
{ps-prmt.i}    
*/
def var h as int .
def var i as int .
def var d as int .
def new shared var p like pssec.proc .

h = 15 .
d = 60.
do:
       {browpnp.i
        &h = "h"
        &form = " '   '  pssec.proc 
         column-label 'Процедура/Функция '"
        &where = "true "
        &frame-phrase = "row 1 centered scroll 1 h down overlay "
        &predisp =
        " display  
        ' < Пробел > - список исполнителей F9 - Добавить F10 - Удалить '
         with centered row 21 no-box overlay   ."
        &seldisp = "pssec.proc"
        &file = "pssec"
        &disp = " pssec.proc "
        &addupd = "pssec.proc "
        &upd    = " pssec.proc "
        &postupd = " "
        &addcon = "true "
        &updcon = "true "
        &delcon = "true"
        &retcon = "false"
        &befret = "  "
        &action = " if keylabel(lastkey) = ' '
         then do: 
          p = pssec.proc .
          run ofcsel_ps .
         end.        "
       }

end.
