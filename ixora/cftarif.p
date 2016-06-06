/* cftarif.p
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

/* cftarif.p
   Отчет по льготным тарифам клиента

   28.04.2003 nadejda
*/

{mainhead.i}

def var v-cif as char.
def var v-cifname as char.

def frame f-client 
  v-cif label "КЛИЕНТ " format "x(6)" colon 10 help " Введите код клиента (F2 - поиск)"
    validate (can-find(first cif where cif.cif = v-cif no-lock), " Клиент с таким кодом не найден!")
  v-cifname no-label format "x(45)" colon 18
  with side-label row 4 no-box.

update v-cif with frame f-client.

find first cif where cif.cif = v-cif no-lock no-error.
v-cifname = trim((cif.prefix) + " " + trim(cif.name)).

displ v-cifname with frame f-client.

run clntarifex (v-cif).


