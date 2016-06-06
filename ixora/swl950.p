/* swl950.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
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
        19.11.2012 evseev ТЗ-1288
 * BASES
        BANK
 * CHANGES
*/

message 'Ждите...'.

run swiftload('103').
run swiftload('950').

run Mt950ChkMt103.
run mt103tormz.

message 'Готово!' view-as alert-box info buttons ok.