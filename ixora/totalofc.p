/* totalofc.p
 * MODULE
        totalofc.p
 * DESCRIPTION
       собрать сотрудников всех филиалов в временн табл tempofc
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
        27.01.2011
 * BASES
        BANK
 * CHANGES
*/
def shared temp-table tempofc no-undo
    field ofc as char
    field oname as char
index ind is primary ofc.
message "Ждите идет подготовка данных для отчета".

for each txb.ofc no-lock.
    create tempofc.
    tempofc.ofc = txb.ofc.ofc.
    tempofc.oname = txb.ofc.name.
end.

