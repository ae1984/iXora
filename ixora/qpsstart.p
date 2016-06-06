/* qpsstart.p
 * MODULE
        Процессы для работы с Sonic
 * DESCRIPTION
        Запуск/остановка процессов для работы с Sonic - standalone
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
        05/03/2009 madiyar
 * BASES
        BANK
 * CHANGES
        11/03/2009 madiyar - не нужен коннект к comm'у
*/

{mainhead.i}

run qpsmng('','',0).

