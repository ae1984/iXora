/* profcned.f
 * MODULE
        справочник профит-центров
 * DESCRIPTION
        справочник профит-центров
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
        16.05.05 nataly добавлен код доходов-расходов (codfr.name[4] = codfr.code where codfr.codfr = 'sdep')
        14.06.05 nataly добавлен код департамента модуля ЗАРПЛАТЫ codfr.name[3]
        17/02/06 nataly увеличена разрядность кода доходов-расходов
        03.11.06 u00121 увеличил формат поля codfr.name[4] до 6 символов
*/

/* profcned.f 
   Форма редактирования справочника Профит-центров

   15.01.2003 nadejda создан
*/

def var v-nkname as char.

form
     codfr.code format "x(3)" label "КОД"
     codfr.name[1] format "x(35)" label "ПОЛНОЕ НАИМЕНОВАНИЕ"
     codfr.name[3] format 'x(3)' label "ЗП"
     codfr.name[4] format 'x(6)' label "Д/Р"
     codfr.name[5] format "x(12)" label "РНН НК"
     v-nkname format "x(12)" label "НАЛОГ.КОМ-Т"
     with row 5 centered scroll 1 12 down frame pced.
