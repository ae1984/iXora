/* reportya.p
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

/*
  reportya
*/
def shared var s-gl like gl.gl.
find gl where gl.gl eq s-gl .
  update gl.totact label "Итог"
  gl.totlev label "Итоговый уровень" 
  gl.totgl  label "Итоговый счет"
  gl.nskip  label "Кол-во строк"
  gl.vadisp label "Печатать"
  gl.gldisp label "Печатать счет"
  gl.left   label "Сдвиг слева"
/*  
    gl.ibfact 
    gl.ibfgl    
    gl.fr2900 
    gl.fr2951 
*/
with row 3 1 col column 25 overlay top-only frame rpt.
