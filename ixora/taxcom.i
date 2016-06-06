﻿/* taxcom.i
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
        08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
        11.02.2005 kanat - изменил группу выбираемых тарифов
        10.02.2006 u00568 evgeniy - сделал возможным передачу не одного кода в процедуру,
          а нескольких, через #
          в случае если сумма не попадает в вилки сумм тарифов, берется последний тариф.
*/
{comm-com.i}

function taxcom returns decimal ( sum as decimal, code as char).
  return COMM-COM (sum, code).
end.
