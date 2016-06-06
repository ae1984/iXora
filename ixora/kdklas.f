/* kdklas.f
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Форма для ввода параметров классификации
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
        29.12.2003  marinav
 * CHANGES
*/


/* Тип критерия     1 - клас-ция для досье
                    2 - клас-ция для кредитов */

form
     kdklass.type format ">>9" label "ТИП" 
       help " Тип критерия"
     kdklass.ln format ">>9" label "НОМ" 
       help " Номер критерия по порядку"
     kdklass.kod format "x(10)" label "Код" 
       help " Код критерия"
     kdklass.name format "x(35)" 
       help " Наименование критерия"
     kdklass.sprav format "x(10)" label "Справочник"
       help "Справочник "
     kdklass.proc format "x(10)" label "Процедура"
       help " Процедура "
     with row 5 centered scroll 1 down title "КЛАССИФИКАЦИЯ ОБЯЗАТЕЛЬСТВА" 
     frame kdkri .

