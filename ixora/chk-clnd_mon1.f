/* chk_clnd.f
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
        07.11.2013 dmitriy - ТЗ 1725. Добавил столбцы "Фин.сост" и "Балл"
*/

form lnmoncln.edt label "Проверка"
     lnmoncln.ewho label "Исполнитель" format "x(7)"
     lnmoncln.res-deci[1] label "Оборот (KZT)" format ">>>,>>>,>>>,>>9.99"
     v-codfrname   label "Фин.сост" format "x(20)" help "Выбор финансового состояния через F2"
     lnmoncln.mark   label "Балл"   format "99" validate(lnmoncln.mark >= 12 and lnmoncln.mark <= 60,'Проставление баллов в интервале 12 – 60')

   with overlay no-hide centered row 5 10 down
   title v-title
   frame longr.

DEFINE QUERY q-fins FOR codfr.

DEFINE BROWSE b-fins QUERY q-fins
       DISPLAY codfr.code label "Код  " format "x(3)" codfr.name[1] label "Наименование   " format "x(60)"
       WITH  15 DOWN.
DEFINE FRAME f-fins b-fins  WITH overlay 1 COLUMN SIDE-LABELS row 10 COLUMN 35 width 85 NO-BOX.

on help of v-codfrname in frame longr do:
    OPEN QUERY  q-fins FOR EACH codfr where codfr.codfr = "finsost" no-lock.
    ENABLE ALL WITH FRAME f-fins.
    wait-for return of frame f-fins
    FOCUS b-fins IN FRAME f-fins.
    lnmoncln.fins = codfr.code.
    v-codfrname = codfr.name[1].
    hide frame f-fins.
    displ v-codfrname with frame longr.
end.