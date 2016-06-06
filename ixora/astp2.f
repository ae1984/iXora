/* astp2.f
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

form
 "   Nr КАРТОЧКИ :" ast.ast format "x(8)" skip
 "    ИНВЕНТ.Nr. :" ast.addr[2] format "x(20)" skip
 "      НАЗВАНИЕ :" ast.name skip
 "  МЕСТО РАСПОЛ.:" ast.attn format "x(5)" " " v-attnn format "x(25)"

 with frame astp row 5 overlay centered no-labels no-hide
    title "  ПРОСМОТР И КОРРЕКТИРОВКА КАРТОЧКИ ОСНОВНОГО СРЕДСТВА".

