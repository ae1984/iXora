/* jcom.f
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
        15.07.2005 saltanat - Включила поля пункта тарифа .
        09.09.2005 saltanat - Изменила формат поля пункт тарифа.
        22.02.2010 marinav - расширение формы
        24.08.10 marinav - tarif2.stat = 'r'
*/

/** jcom.f **/

define frame fr_com
    joucom.comcode label "КОД" validate (
        can-find (tarif2 where tarif2.num + tarif2.kod eq joucom.comcode and tarif2.stat = 'r'),
        "Код не найден в тарификаторе.") format "x(4)"
    joucom.punkt label "Пункт" format "x(30)"   
    joucom.comdes  label "ОПИСАНИЕ КОМИССИИ " format "x(40)"
    joucom.comnat  label "НАЦ.ВАЛ."
    joucom.comprim label "ПРИОР."
    with row 6 centered 10 down overlay width 100 with title f_title.
