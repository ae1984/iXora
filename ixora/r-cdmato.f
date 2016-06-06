﻿/* r-cdmato.f
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
 * BASES
        BANK COMM
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

m-str1 = "ИТОГО    ".
m-str2 = "Обработка ".
update "с " m-begday " по " m-endday with frame aaa no-box no-label row 8
column 40 .

{image2.i}
{report1.i 59}

vtitle = "СРОЧНЫЕ ДЕПОЗИТЫ С ДАТОЙ ЗАКРЫТИЯ СЕГОДНЯ" + chr(15).

vtitle1 =
"СЧЕТ  #     КИФ   ВАЛ          ВКЛАД           % СТАВКА            ОСТАТОК  "
+ "         ПРОЦЕНТЫ       ОСТАТОК + ПРОЦ.     ДАТА     ДАТА ".