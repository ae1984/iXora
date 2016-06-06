/* chk_clnd_fhmon.f
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
        09/07/2004 madiyar
 * CHANGES
        26/05/2011 madiyar - ухудшение фин. состояния - в lnmoncln.res-ch[1]
        31/05/2011 madiyar - ухудшение фин. состояния обязательно к проставлению только если проставлена дата проверки
        17/09/2013 Sayat(id01143) - ТЗ 1586 от 16/11/2012 "Мониторинги - отсрочка" - добавлено поле lnmoncln.otsr
        04/10/2013 Sayat(id01143) - ТЗ 1198 от 04/11/2011 "Мониторинг залогов - переоценка" задана ширина формы 90 (чтобы данные по одной записи не перескакивали на следующую строку)
        07.11.2013 dmitriy - ТЗ 1725
*/

form lnmoncln.pdt label "График"
     lnmoncln.pwho label "Исполнитель" format "x(7)"
     lnmoncln.edt label "Проверка"
     lnmoncln.ewho label "Исполнитель" format "x(7)"
     lnmoncln.res-deci[1] label "Оборот (KZT)" format ">>>,>>>,>>>,>>9.99"
     v-codfrname   label "Фин.сост" format "x(20)" help "Выбор финансового состояния через F2"
     lnmoncln.mark   label "Балл"   format "99" validate(lnmoncln.mark >= 12 and lnmoncln.mark <= 60,'Проставление баллов в интервале 12 – 60')
     lnmoncln.res-ch[1] label "Ухудшение ФС" format "x(3)" validate((lnmoncln.edt = ?) or (lookup(lnmoncln.res-ch[1],"ДА,НЕТ,Д,Н,YES,NO,Y,N") > 0), "Введено некорректное значение! (должно быть да/нет)")
     lnmoncln.otsr label "Отсрочка" validate(lnmoncln.otsr >= 0 and lnmoncln.otsr <= 3,'Некорректное значение!') help "0-нет,1-первая,2-вторая,3-третья"
   with overlay no-hide centered row 5 10 down
   title v-title
   frame longr width 105.



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