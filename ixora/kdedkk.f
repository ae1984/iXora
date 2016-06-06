/* pkedkk.f
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
        18.03.2004 marinav
 * CHANGES
*/

def var v-codfr as char init "kdkom".
def var v-ln as integer.

form
     codfr.code format "x(2)" label "ПП"
     codfr.papa format "x(2)" label "КК"
     codfr.name[1] format "x(45)" label "ДОЛЖНОСТЬ"
     codfr.name[2] format "x(19)" label "ФАМИЛИЯ, ИНИЦИАЛЫ"
     v-ln format "9"  label "N"
       help " Порядковый номер члена Кредитного Комитета в списке подписей, 0 - исключить"
       validate (v-ln <> 0 , 
                 " Введите номер!")
     with row 5 centered scroll 1 12 down frame kdedkk .
