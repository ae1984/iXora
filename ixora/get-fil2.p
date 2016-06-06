/* get-fil2.p
 * MODULE
        Финансовый мониторинг
 * DESCRIPTION
        Проверка на наличие ID пользователя в базе филиала
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        cifmin_m
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        16.02.2011 ruslan
 * BASES
        BANK TXB
 * CHANGES
        25.02.2011 ruslan перекомпиляция
*/


def input parameter id as char.
def output parameter v-log as logical.

    find first txb.ofc where txb.ofc.ofc = id no-lock no-error.
      if avail txb.ofc then v-log = true.
        else v-log = false.