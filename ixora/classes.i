/* classes.i
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        24.02.2009 k.gitalov
 * CHANGES
*/

{global.i}


def var Base AS CLASS GlobalClass. 

if not VALID-OBJECT(Base) then Base = NEW GlobalClass(g-lang,g-crc,g-ofc,g-proc,g-fname,g-today,g-comp,g-dbdir,g-dbname,g-cdlib,g-browse,g-editor,
                             g-pfdir,g-permit,g-lprpt,g-lplab,g-lplet,g-lpstmt,g-lpvou,g-labfmk,g-stmtmk,g-letfmk,g-bra,g-basedy,
                             g-tty,g-lty,g-aaa,g-cif,g-batch,g-defdfb,g-inc).

