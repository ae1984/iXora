/* cm18_restart.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание программы
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
        15/09/2012 k.gitalov
 * BASES
        BANK COMM
 * CHANGES
        19/09/2012 k.gitalov перекомпиляция
*/




def input param ClientIP as char.


def var BUFF as char.
def var Service as char.

    message "Остановка процесса...".
    input through value("ssh  -q Administrator@" + ClientIP + " 'SC stop CASHBOXTools' ").
    repeat:
     import unformatted BUFF.
     Service = Service + BUFF.
    end.
    hide message no-pause.

    message "Старт процесса...".
    input through value("ssh  -q Administrator@" + ClientIP + " 'SC start CASHBOXTools' ").
    repeat:
     import unformatted BUFF.
     Service = Service + BUFF.
    end.

    hide message no-pause.
    if index(Service,"START_PENDING") > 0 then message "Сервис запущен!".
    else message "Ошибка при запуске процесса".