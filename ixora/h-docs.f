/* h-docs.f
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
        29.06.2012 damir - добавил vcdocs.kod14,vcpartners.name,vcdocs.knp в form.
        02.06.2012 damir  - добавил v-partner.
*/

        /* h-docs.f Валютный контроль
        Форма к списку документов
        18.10.2002 nadejda создан
        */


form
    vcdocs.dndate    format "99/99/99"
    vcdocs.dnnum     format "x(20)"
    codfr.name[2]    format "x(6)"  label "ТИП"
    vcdocs.origin                   label "ОРИГ?"
    vcdocs.sum
    ncrc.code        format "xxx"   label "ВАЛ"
    vcdocs.payret                   label "ВЗВ"
    vcdocs.kod14     format "x(8)"  label "КОД РАСЧ"
    v-partner        format "x(10)" label "ИНОПАРТНЕР"
    vcdocs.knp       format "x(3)"  label "КНП"
with width 105 row 4 centered scroll 1 30 down overlay frame h-docs.


