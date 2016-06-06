/* subadd-pc.i
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

/* funadd.i 
   Создание записи в sub-cod для нового fun, lon

   09.12.2002 nadejda
*/

def buffer buf-subcod for sub-cod.
def buffer buf-ofc for ofc.

find buf-subcod where buf-subcod.sub = "{&sub}" and buf-subcod.d-cod = "sproftcn" and 
   buf-subcod.acc = {&sub}.{&sub} exclusive-lock no-error.
if not avail buf-subcod then do:
  create buf-subcod.
  assign buf-subcod.sub = "{&sub}" 
         buf-subcod.d-cod = "sproftcn"
         buf-subcod.acc = {&sub}.{&sub}
         buf-subcod.rdt = g-today.
end.

find buf-ofc where buf-ofc.ofc = {&sub}.who no-lock no-error.
if avail buf-ofc and buf-ofc.titcd <> "" then buf-subcod.ccode = buf-ofc.titcd.
else buf-subcod.ccode = "101". 

find current buf-subcod no-lock no-error.
