/* zdfbedit.f
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

  form    "НОСТРО БАНК : " dfb.dfb  space(10) "ВАЛЮТА : " dfb.crc skip
          "Счет ГлКн.  : " dfb.gl   space(14) "ГРУППА : " dfb.grp skip
          "НАИМЕНОВАНИЕ: " dfb.name skip
          "АДРЕС       : " dfb.addr[1] skip
          "            : " dfb.addr[2] skip
          "            : " dfb.addr[3] skip
          "ТЕЛЕФОН     : " dfb.tel space(7)
          "ФАКС        : " dfb.fax skip
          "ПРОЦ.СТАВКА : " dfb.intrate at 27 space(2)
          "КРЕДИТН.ЛИН.: " dfb.crline at 55 skip
          "СТАТУС      : "  v-subcode " " v-subname format "x(40)" skip
"=========================================================================" skip
          "                       ВХОД.ОСТАТОК  : " vtst skip
          "                       ДЕБЕТ ЗА ДЕНЬ : " vtdr skip
          "                       КРЕДИТ ЗА ДЕНЬ: " vtcr skip
          "                       ТЕКУЩИЙ ОСТАТ.: " vbal skip
"========================================================================="
          with row 3 col 1 no-label no-box
               frame dfb.
