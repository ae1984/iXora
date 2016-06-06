/* fltr.p
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
*/

  def shared temp-table fltr field pid like que.pid column-label "Код" 
  field v as cha label "Показать"  .
  def var h as int .
  h = 15 .

       {browpnp.i
        &h = "h"
        &where = "true"
        &frame-phrase = "row 1 centered scroll 1 h down  overlay 
        title 'ПС фильтр' "
        &seldisp = "fltr.v"
        &file = "fltr"
        &disp = "' ' fltr.pid fltr.v "
        &postupd = " hide all. "
        &addcon = "false"
        &updcon = "false"
        &delcon = "false"
        &retcon = "true"
        &befret = " hide all . "
        &action = " 
         if keyfunction(lastkey) = ' ' then
              do:
                if  fltr.v = '*' then fltr.v = ' ' .
                else fltr.v = '*'.
            end.
         if keyfunction(lastkey) = 'a' then do:
                  for each fltr . fltr.v = '*' . end . leave . end.
         if keyfunction(lastkey) = 'q' then   do:
                  for each fltr . fltr.v = ' ' . end. leave . end.
         if keyfunction(lastkey) = 'go' then return .   
         if keyfunction(lastkey) = 'put' then do:
          output to \.psman.flt.
           for each fltr . 
            export fltr  . 
           end .
          output close .
          message 'Выполнено. Нажмите пробел для продолжения.' . 
           pause no-message.
          return .
         end.     "
       }
