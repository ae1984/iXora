/*  crelog.p
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
        21/09/04 dpuchkov
 * CHANGES
*/


  def input parameter l_err as char.
  def input parameter s_cif as char.

  {global.i} 

   if l_err  = "n" then do:
    create ciflog.
       assign
         ciflog.ofc = g-ofc
         ciflog.jdt = today
         ciflog.cif = s_cif
         ciflog.sectime = time
         ciflog.menu = "5.2.8 Контроль входящих переводов ИНТЕРНЕТ-офис".

   end.
   else
   if l_err  = "u" then do:
      create ciflogu.
      assign
        ciflogu.ofc = g-ofc
        ciflogu.jdt = today
        ciflogu.sectime = time
        ciflogu.cif = s_cif
        ciflogu.menu = "5.2.8 Контроль входящих переводов ИНТЕРНЕТ-офис".
    end.