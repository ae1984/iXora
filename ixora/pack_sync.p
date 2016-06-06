/* pack_sync.p
 * MODULE
        Администрирование АБПК
 * DESCRIPTION
        Разрешение / Запрещение использования пунктов меню
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        21/08/2007 madiyar
 * BASES
        bank, comm
 * CHANGES
*/

def input parameter v-ofc like ofc.ofc.
{r-branch.i &proc = "pack_sync1(v-ofc)"}

