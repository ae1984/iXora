/* chk_clnd.f
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
        09/07/2004 madiar
 * CHANGES
        17/09/2013 Sayat(id01143) - ТЗ 1586 от 16/11/2012 "Мониторинги - отсрочка" - добавлено поле lnmoncln.otsr
*/

form lnmoncln.pdt label "График"
     lnmoncln.pwho label "Исполнитель"
     lnmoncln.edt label "Проверка"
     lnmoncln.ewho label "Исполнитель"
     lnmoncln.otsr label "Отсрочка" validate(lnmoncln.otsr >= 0 and lnmoncln.otsr <= 3,'Некорректное значение!') help "0-нет,1-первая,2-вторая,3-третья"
   with overlay no-hide centered row 5 10 down
   title v-title
   frame longr.