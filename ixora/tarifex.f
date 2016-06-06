/* tarifex.f
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
 * BASES
        BANK COMM
 * CHANGES
        23.09.2003 nadejda  - изменен формат вывода суммы - выод 2 знаков после запятой
        15.12.2011 damir - увеличил формат ввода поля "Услуга".
        01.08.2012 damir - увеличил формат ввода поля "Сумма" на 1 символ, и уменьшил на 1 символ поле "%".
*/

/*def shared var paka like tarif1.pakalp.*/
def var v-am as char.

form
     tarifex.cif label "Клиент"
     tarifex.kont validate (can-find(gl where gl.gl = tarifex.kont),"Счет не найден ") column-label " Счет"
     tarifex.pakalp  format "x(49)" column-label "Услуга"
     tarifex.crc  format "99" column-label "Вал" validate (can-find(crc where crc.crc = tarifex.crc),"Валюта не найдена ")
     tarifex.ost  validate(tarifex.ost >= 0," >=0 !") format "zzzzz9.99" column-label "Сумма"
     tarifex.proc format "z9.999" column-label "  %  "
     tarifex.min1 format "zzzzzz9" column-label " Мин "
     tarifex.max1 format "zzzzzz9" column-label " Макс"
     v-am format "x" column-label "AM"
with overlay column 1 row 7 11 down title string(code) + " " + tit width 105 frame tarifex.
message "F4 - выход ,RETURN - выбор ".


