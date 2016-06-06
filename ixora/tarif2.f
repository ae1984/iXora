/* tarif2.f
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
        23.09.2003 nadejda  - изменен формат вывода суммы - выод 2 знаков после запятой
        13.12.2011 damir - расширил фрейм.
        01.08.2013 damir - Внедрено Т.З. № 2001. Расширил фрейм и поле сумма.
*/

/*def shared var paka like tarif1.pakalp.*/
form
     tarif2.num     /*validate(can-find(tarif
                    where tarif.num = tarif2.num),
                    "Nezinamais kods") */
                    label "Nr" format "x(2)"
     tarif2.kod     label "Nr"    format "x(2)"
     tarif2.kont    validate (can-find(gl where gl.gl = tarif2.kont), "Счет не найден  ") column-label " Счет"
     tarif2.pakalp  format "x(55)" column-label "Услуга"
     tarif2.crc     format "99" column-label "Вал" validate (can-find(crc where crc.crc = tarif2.crc), "Валюта не найдена ")
     tarif2.ost     validate(tarif2.ost >= 0," >=0 !") format "zzzzzzzzz9.99" column-label 'Сумма'
     tarif2.proc    format "zz.99" column-label '  %  '
     tarif2.min1    format "zzzzzz9"  column-label ' Мин '
     tarif2.max1    format "zzzzzz9"  column-label ' Макс'
with overlay   column 1 row 7 11 down title paka width 110 frame tarif2.
message 'F4 - выход            ,RETURN - выбор          '.
