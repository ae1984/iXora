/* chk_clnd_zlg.f
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
        18/07/2013 Sayat(id01143) - ТЗ 1198 от 04/11/2011 "Мониторинг залогов - переоценка" добавлены проверка даты проведения мониторинга и форма longr2 для проведения мониторинга залогов
        17/09/2013 Sayat(id01143) - ТЗ 1586 от 16/11/2012 "Мониторинги - отсрочка" - добавлено поле lnmoncln.otsr
        07/10/2013 Sayat(id01143) - ТЗ 1198 от 04/11/2011 "Мониторинг залогов - переоценка" задана ширина формы 90 (чтобы данные по одной записи не перескакивали на следующую строку)
*/
def var v-zalsum as deci.
def var v-zalcrc as int.

form lnmoncln.pdt label "График"
     lnmoncln.pwho label "Исполнитель"
     lnmoncln.edt label "Проверка" validate(lnmoncln.edt <= g-today or lnmoncln.edt = ? , 'Дата проведенной проверки не может быть позже текущей!')
     lnmoncln.ewho label "Исполнитель"
     lnmoncln.otsr label "Отсрочка" validate(lnmoncln.otsr >= 0 and lnmoncln.otsr <= 3,'Некорректное значение!') help "0-нет,1-первая,2-вторая,3-третья"
   with overlay no-hide centered width 90 row 5 10 down
   title v-title
   frame longr.

form lnmoncln.pdt label "График"
     lnmoncln.pwho label "Исполнитель" format "x(11)"
     lnmoncln.edt label "Проверка" validate(lnmoncln.edt <= g-today or lnmoncln.edt = ? , 'Дата проведенной проверки не может быть позже текущей!')
     lnmoncln.ewho label "Исполнитель" format "x(11)"
     v-zalcrc label "Валюта" format ">9"
     v-zalsum label "Сумма" format "->>>,>>>,>>>,>>9.99"
     lnmoncln.otsr label "Отсрочка" validate(lnmoncln.otsr >= 0 and lnmoncln.otsr <= 3,'Некорректное значение!') help "0-нет,1-первая,2-вторая,3-третья"
   with overlay no-hide centered width 90 row 5 10 down
   title v-title
   frame longr2.