/* ppoint.f
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
        11/04/06 nataly добавила признак доходов-расходов
        04/05/08 marinav добавила описание фрейма
*/

form ppoint.depart 
     ppoin.name  format "x(70)"
     ppoint.tel1 validate(can-find(codfr where codfr.codfr = 'sdep' and codfr.code = ppoint.tel1 no-lock),
                              'Неверно задан код доходов-расходов ')  format 'x(3)' with column 10 row 4 title "Управления"
no-label with size 100 by 32 centered 15 down overlay no-hide frame ppoint.
