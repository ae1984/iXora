/* ofc_perm.p
 * MODULE
        Название Программного Модуля
	Администрирование АБПК
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
	ofc_check.p
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
   * BASES
         BANK TXB
 * AUTHOR
        07/12/2011 id00477
 * CHANGES

*/

def input parameter v-ofc like txb.ofc.ofc.
def shared var n_ofc as int.

find first txb.ofc where txb.ofc.ofc = v-ofc no-lock no-error.
if avail(txb.ofc) then n_ofc = n_ofc + 1.



