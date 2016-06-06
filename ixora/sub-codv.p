/* sub-codv.p
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

  def input parameter v-acc like aaa.aaa . 
  def input parameter v-sub like gl.sub .
  def input parameter v-dcod like sub-cod.d-cod .
  def input parameter v-ccode like sub-cod.ccode .
        find first sub-cod where sub-cod.acc = v-acc 
         and sub-cod.sub = v-sub and sub-cod.d-cod = v-dcod 
         use-index dcod  no-lock no-error . 
         if not avail sub-cod then 
         do transact:
          create sub-cod. 
          sub-cod.acc = v-acc. 
          sub-cod.sub = v-sub. 
          sub-cod.d-cod = v-dcod . 
          sub-cod.ccode = v-ccode . 
         end.
         else if sub-cod.ccode ne v-ccode then  
         do:
         Message " Запись с кодификатором " + v-dcod + " уже существует:" + v-ccode. 
         pause. 
         end.
