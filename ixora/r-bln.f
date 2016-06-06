/* r-bln.f
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
*/

/*---------------------------------------------------------------------------
  #3.Izmai‡as formas galvi‡–
----------------------------------------------------------------------------*/
define variable grupa    as integer label 'Группa'.
define variable valuta   as integer label 'Валюта'.
define variable druka    as logical label 'Печать ?'.
define variable dzest    as logical label 'Новый отчет ?'.
define variable gaidiet  as character format 'x(22)' init
      'Секундочку...'.
define variable head0    as character format 'x(32)' init
      'С П И С О К . '.
define variable gr-nos   as character format 'x(6)' init 'Группа'.
define variable val-nos  as character format 'x(7)' init 'Валюта'.
define variable head     as character format 'x(134)' extent 3.
head[1] =
    '----------------------------------------------------------------------' +
    '----------------------------------------------------------------------'.
head[2] =
    'Нпп:     Договор    :Посл.транз. : CIF  :    Н а и м е н о в а н и е   :' +
    '  Кредит  :   Сумма    :   Остаток   :Дата рег. :  Срок    :% ставка' .
head[3] =
    '---:----------------:------------:------:------------------------------:' +
    '----------:------------:-------------:----------:----------:--------'.
