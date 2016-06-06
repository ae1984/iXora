/* cif-npr.f
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
 * CHANGES
      25/09/2008 galina - счет 20-тизначный 
*/

/* cif-npr.f  -   02/03/94 AGA печать открытых счетов     */
/*  ACCOUNT STATEMENT */

def var ci2  as char format "x(7)"  init "Время: ".
def var ci3  as char format "x(27)" init "ВЫПИСКА ПО СЧЕТАМ КЛИЕНТА    ".
def var ci4  as char format "x(10)" init   "   Дата   ".
def var ci5  as char format "x(7)"  init   "КИФ# : ".
def var ci6  as char init "Закрыт  ".
def var ci7  as char format "x(20)" init "СЧЕТ # : ".
def var ci8  as char format "x(20)" init "  КОНЕЦ ДОКУМЕНТА  ".
