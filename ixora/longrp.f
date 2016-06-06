/* longrp.f
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
*/

/* longrp.f 02-24-93

   10.02.2003 sasco - добавил выбор физ/юр лиц и 
              краткосрочности/долгосрочности кредита
              поле .stn = integer = <1-физ/2-юр><1-краткоср/2-долгоср/3-овердрафт>
*/

def var lonfiz  as int format "9" label "Физ/Юр".
def var lonsrok as int format "9" label "Срок".

form   longrp.longrp label "Группа"
       longrp.des label "Описание"
       longrp.gl validate (can-find (gl where gl.gl = longrp.gl),"Не найден счет Г/К!") label "Г/К"
       lonsrok validate (lonsrok = 1 or lonsrok = 2 or lonsrok = 3, "Ошибка! 1-кратко, 2-долго, 3-овердрафт")
              help "1 - краткосроч, 2 - долгосроч, 3 - овердрафт"
       lonfiz validate (lonfiz = 1 or lonfiz = 2, "Ошибка! 1 - физ лицо, 2 - юр лицо")
              help "1 - физ лицо, 2 - юр лицо"
   with centered row 3 down frame longrp.
