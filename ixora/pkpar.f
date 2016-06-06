/* pkpar.f
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
        26.05.2003 Надежда Лысковская - добавлено значение по умолчанию pkkrit.res[2]
        06.05.05 marinav добавлены поля rating_yc rating_nc
        23/09/2005 madiar - расширил поле "НОМ"
        31/10/2005 madiar - добавил поле "Источник анкеты"
        19/04/2006 Natalya D. - увеличила длину строки для Справочника значений
*/

/* pkpar.p ПотребКредиты
   Форма редактирования критериев анкеты
   Создан:  Марина Андрусенко
*/

def var v-akiin as char format "x(300)".
def var v-akiout as char format "x(300)".


form
     pkkrit.ln format ">>>>9" label "НОМ"
       help " Номер критерия по порядку"
     pkkrit.kritcod format "x(10)" label "Код"
       help " Код критерия"
     pkkrit.kritname format "x(30)"
       help " Наименование критерия в анкете"
     pkkrit.krittype format "x" label "Т"
       help " Тип критерия (F2 - помощь)"
     pkkrit.priz format "x" label "Пр"
       help " Признак ввода (1- менеджер, 0- автоматич, 2- не обрабатывать)"
     pkkrit.credtype format "x(15)" label "Виды кредитов"
       help " Список видов кредитов, где участвует критерий (F2 - помощь)"
     pkkrit.rating_y format "->>9" label "  да"
       help " Рейтинг при положительном результате обработки"
     pkkrit.rating_n format "->>9" label " нет"
       help " Рейтинг при отрицательном результате обработки"
     with row 1 centered scroll 1 down title "КРИТЕРИИ ОЦЕНКИ РЕЙТИНГА КЛИЕНТА"
     frame pkkri .

form
     pkkrit.rating_yc[1]  format "x(30)" label "          Рейтинг да "  help " Рейтинг при положительном результате обработки" skip
     pkkrit.rating_nc[1]  format "x(30)" label "         Рейтинг нет "  help " Рейтинг при отрицательном результате обработки" skip
     pkkrit.rating_yc[2]  format "x(30)" label "     Соц. рейтинг да "  help " Соц. рейтинг при положительном результате обработки" skip
     pkkrit.rating_nc[2]  format "x(30)" label "    Соц. рейтинг нет "  help " Соц. рейтинг при отрицательном результате обработки" skip
     pkkrit.res[2]  format "x(30)"       label "  Значение по умолч. " skip
     pkkrit.res[1]  format "x(40)" label "    Строка подсказки " skip
     pkkrit.procval format "x(15)" label "   Валидность данных " skip
     pkkrit.kritspr format "x(40)" label " Справочник значений " skip
     pkkrit.proc    format "x(15)" label " Процедура обработки " skip
     pkkrit.res[3]  format "x(40)" label "     Источник анкеты " skip(1)

     with frame pkkri1 overlay  row 6 width 60
     centered top-only side-label.
