/* vcbin.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Поиск ИИН физ.лица
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
        02/11/2009 galina
 * BASES
        BANK TXB
 * CHANGES
        12/11/2009 galina - перекомпеляция
        25/11/2009 galina - перекомпеляция
        05/10/2010 galina - перекомпеляция
        02.06.2011 aigul - вывод банка
*/


def input parameter p-bank as char.
def output parameter v-bank as char.
find first txb.cmp where txb.cmp.code = int(substr(p-bank,4,2)) no-lock no-error.
if avail txb.cmp then v-bank = txb.cmp.name.