/* bookank.f
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
        06.05.05 marinav - добавилось поле info[2]
*/

form
    bookcod.code label "КОД"
        validate (bookcod.code <> "", " Введите код элемента справочника !")
    bookcod.name label "НАИМЕНОВАНИЕ" format "x(36)"
        validate (bookcod.name <> "", " Введите название элемента справочника !")
    bookcod.info[1] label "Рейт" format "x(4)" help "Рейтинг"
        validate (bookcod.info[1] <> "", " Введите вес рейтинга !")
    bookcod.info[2] label "Соц." format "x(4)" help "Социальный рейтинг"
        validate (bookcod.info[2] <> "", " Введите вес социального рейтинга !")
    bookcod.regdt 
    bookcod.regwho
with centered 13 down title v-title overlay row 4 frame bookcod.
