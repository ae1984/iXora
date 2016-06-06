/* cm18_video.p
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


run to_screen("video","").
message "Закрыть" view-as alert-box.
run to_screen("default","").
