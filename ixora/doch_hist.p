/* doch_hist.p
 * MODULE
        Название модуля
 * DESCRIPTION
        запись истории изменений статуса документов doch в таблицу dochhist
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
        21.02.2011 Luiza
 * BASES
        BANK
 * CHANGES
*/
def input parameter v_docid as char format "x(9)".
def shared var g-ofc as char.
find doch where doch.docid = v_docid no-lock no-error.
IF AVAILABLE doch then do:
create dochhist.
    dochhist.docid = v_docid.
    dochhist.rdt = today.
    dochhist.rtim = TIME.
    dochhist.rwho = g-ofc.
    dochhist.sts = doch.sts.
end.
else message " Ошибка, не найдена таблица doch.".
return.
