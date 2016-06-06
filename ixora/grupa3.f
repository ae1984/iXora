/* grupa3.f
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

form header "Обработка           "  with frame d1 no-label row 1 column 50 .
form header
"Grupa   " with frame bc row 12 column 40 no-label no-box no-underline.
display "(В)се группы или одна (Г)руппа " with frame b column 30
row 10 no-label no-box.
update m-sa format "Все группы/Группа" with frame  b no-label no-box.
m-limit = 10000.
