/* kasef.f
 * MODULE
        kasef.f
 * DESCRIPTION
        Форма для ввода курсов валют на Казахстанской Фондовой бирже
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
        20-07-2004 torbaev
        11.08.2004 saltanat - добавила ввод курсов "минимум", "максимум", "закрытие"
 * CHANGES
*/

form 
     t-kasecrc.crc format 'Z9' label "Номер" 
     t-kasecrc.des format "X(23)"  label "Назв. валюты"
     t-kasecrc.rate[1] format "zzz9.99" label "Средневзв. "
     t-kasecrc.rate[2] format "zzz9.99" label "Минимум "
     t-kasecrc.rate[3] format "zzz9.99" label "Максимум "
     t-kasecrc.rate[4] format "zzz9.99" label "Закрытие "
     t-kasecrc.code format "x(3)" label "Мнемо"
     t-kasecrc.regdt format "99/99/9999" label "Рег.дата"
     t-kasecrc.tim label "Рег.Время"

     with centered scroll 1 1 down frame f-kaseedit .

     




