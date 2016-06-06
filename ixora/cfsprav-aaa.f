/* cfsprav-aaa.f
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

/* cfsprav-aaa.f
   Форма для выбора счетов для справки

   26.03.2003 nadejda
*/

form 
    t-accs.choice no-label format "x"
    t-accs.aaa label "СЧЕТ" format "x(10)"
    t-accs.name label "НАИМЕНОВАНИЕ" format "x(20)"
    t-accs.crccode label "ВАЛ" format "x(3)"
with 12 down title " ОТМЕТЬТЕ НУЖНЫЕ СЧЕТА " overlay centered row 6 no-label frame f-aaa.
