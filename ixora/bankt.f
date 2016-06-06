/* bankt.f
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
        02.06.2004 nadejda - изменен смысл поля bankt.aut - теперь это признак, что корсчет открыт именно в этом банке, а не просто через него отправлять
        18.11.09 marinav - формат счета увеличен до 21 знака
*/


def buffer b-bankt for bankt.

form " " 
    bankt.cbank column-label "Корр.банк" 
    v-subl column-label "Тип счета" 
    bankt.acc format "x(21)" column-label " Счет  "
    bankt.crc column-label "Валюта" 
    bankt.aut column-label "СОБСТВ?"
              help " Ностро-счет открыт именно в этом банке или нет?"
              validate (not bankt.aut or (bankt.aut and not can-find(first b-bankt where b-bankt.acc = bankt.acc and 
                                                   b-bankt.crc = bankt.crc and b-bankt.aut no-lock)), 
                        " Уже сть банк, указанный собственником данного ностро-счета!")
    bankt.racc column-label "Акт" bankt.vdate column-label "Дни"
    v-time format "99:99:99" column-label "Кон.Время"
    with centered overlay row 6 down frame bankt .
