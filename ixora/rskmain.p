/* rskmain.p
 * MODULE
        Кредитный Модуль
 * DESCRIPTION
        Риски
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
        24/09/2004 madiar
 * CHANGES
        27/09/2004 madiar - mycif -> v-cif, для поиска по F2
*/

{mainhead.i}

def var v-sel as char.
def var v-cif as char.

run sel2 ("Выбор :", " 1. Риски ссудного портфеля | 2. Матрица рисков по клиенту ", output v-sel).
if v-sel = "1" then run rskmain1.
if v-sel = "2" then do:
  update v-cif label ' Код клиента ' format 'X(6)'
       validate (can-find(cif where cif.cif = v-cif), " Клиент не найден! ") skip
       with side-label row 5 centered frame cif.
  run rskmain2(v-cif).
end.

hide message no-pause.
