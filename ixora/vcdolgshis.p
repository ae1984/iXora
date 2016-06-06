/* vcdolgshis.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Просмотр истории документа по долгам
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
        24/06/04 saltanat
 * CHANGES
*/

def new shared var s-viewcommand as char.

s-viewcommand = "ps_less".
run vcdolgshis0.
