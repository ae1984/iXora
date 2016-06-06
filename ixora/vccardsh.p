/* vccardsh.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Просмотр и редактирование истории отправления ЛКБК
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
        --/--/2011 damir
 * BASES
        BANK COMM
 * CHANGES
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
        03.05.2013 damir - Внедрено Т.З. № 1107.
*/
def shared var s-contract like vccontrs.contract.

def var v-sel as char.
def var v-head as char init "vccardsh".

run sel("ВЫБЕРИТЕ","1.Сформировать ЛКБК|2.Просмотр документа|3.Сканировать|4.Выход").
v-sel = trim(return-value).

case v-sel:
    when "1" then run vccrlkbk.
    when "2" then run vc-oper("1",trim(string(s-contract)),v-head).
    when "3" then run vc-oper("2",trim(string(s-contract)),v-head).
    when "4" then return.
end case.

