/* ofc_check.p
 * MODULE
        Название Программного Модуля
	Администрирование АБПК
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
	secofc.p
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
  * BASES
         BANK COMM

 * AUTHOR
        07/12/2011 id00477
 * CHANGES

*/

def new shared var n_ofc as int.
def input parameter v-ofc like ofc.ofc.
def shared var v-sync as log.

{r-branch.i &proc = "ofc_perm(v-ofc)"}

if n_ofc = 17 then v-sync = true. /* если пакет или пользователь встречается во всех филиалах, */
else v-sync = false.              /* даем добро на синхронизацию */