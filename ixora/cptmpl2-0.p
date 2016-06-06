/* cptmpl2-0.p
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

/* cptmpl2-0.p
   Копирование шаблонов от одного пользователя к другому по логину

   05.01.2003 nadejda - выделен кусок из cptmpl2.p
*/

def input parameter v-ofcexp as char.
def input parameter v-ofcimp as char.

for each ujosec where lookup(v-ofcexp, ujosec.officers) > 0 and 
                      lookup(v-ofcimp, ujosec.officers) = 0 exclusive-lock:
  if length(ujosec.officers) > 0 and substr(ujosec.officers, length(ujosec.officers), 1) <> "," then
    ujosec.officers = ujosec.officers + ",".
  ujosec.officers = ujosec.officers + v-ofcimp + ",".
end.

