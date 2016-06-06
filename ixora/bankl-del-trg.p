/* bankl-del-trg.p
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
        31/12/99 pragma

 * BASES
	BANK
 * CHANGES
        11.06.2012 id00477 изменил наименование файла лога
 */

TRIGGER PROCEDURE FOR Delete OF bankl.

def var uid as char.

if connected ('bank') then assign uid = userid ('bank').

output to value ("/data/log/bankl-del_crt.log") append.

put unformatted
    today " " string (time, "HH:MM:SS") " " uid " - deleted" .

output close.
