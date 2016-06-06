/* pkrpcrd0.p
 * MODULE
        Потребкредиты
 * DESCRIPTION
        Отчеты для выпуска карт
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
        07/09/2006 madiyar
 * BASES
        bank, comm, txb
 * CHANGES
*/

def input parameter v-select_rep as integer no-undo.

run value("pkrpcrd" + string(v-select_rep,"9")).

