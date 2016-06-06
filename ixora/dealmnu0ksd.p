/* dealmnu0ksd.p
 * MODULE
        Модуль ЦБ (используется таблица deal)
 * DESCRIPTION
        меню собственных сделок с ЦБ
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        dealref.p
 * MENU
        7-1-1
 * BASES
        BANK
 * AUTHOR
        26/06/2012 id01143 (ТЗ 1328)
 * CHANGES
*/


def new shared var v-new as log.
def new shared var v-edit as log.
def new shared var v-deal like deal.deal.

def var v-select as integer no-undo.
run sel3 (" МЕНЮ СОБСТВЕННЫХ СДЕЛОК ", " 0. НОВЫЙ | 1. ПРОСМОТР | 2. РЕДАКТИРОВАНИЕ | 3. ВЫХОД ", output v-select).
if v-select = 1 then run dealnewksd(no).
if v-select = 2 then run dealreadksd(no).
if v-select = 3 then run dealeditksd(no).
if v-select = 4 then return.
