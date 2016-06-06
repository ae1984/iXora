/* bankl-crt-trg.p
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
        11.06.2012 id00477
 * BASES
	BANK
 * CHANGES
 */

TRIGGER PROCEDURE For CREATE OF bankl.

def var uid as char.

if connected ('bank') then assign uid = userid ('bank').

output to value ("/data/log/bankl-del_crt.log") append.

put unformatted
    today " " string (time, "HH:MM:SS") " " uid " - created" .

output close.
