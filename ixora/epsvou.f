/* epsvou.f
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

/* epsvou.f
*/

form  skip(1) space(1) vpay skip
      space(1) vsub validate(vsub ne "","СУБЪЕКТ НЕ ПРИНИМАЕТ БЛАНК!   ") skip
      space(1) vbal1 validate(vbal1 gt 0,"ТРЕБУЕТСЯ ВВЕСТИ СУММУ    !") skip
      space(1) s-jh skip
      space(1) vdate skip
   /*   space(1) vpres skip  */
      space(1) s-acc validate(can-find(eps where eps.eps eq s-acc),
        "РАСХ.СЧЕТ НЕ СУЩЕСТВУЕТ!     ") label "КОД РАСХОДА" skip
      space(1) eps.des label "ОПИСАНИЕ РАСХОДА" format "x(26)" skip
      space(1) s-gl2 validate(can-find(gl where gl.gl eq s-gl2),
        "СЧЕТ НЕ ИМЕЕТ СИЛЫ")
      space(3) vdes format "x(30)" no-label vchk label "ЧЕК#" skip
      space(1) vofc validate(vofc eq "" or can-find(ofc where ofc.ofc eq vofc),
        "НЕ ТАКОГО РАБОТНИКА!   ")
      space(1) vname no-label skip
      space(1) vrem[1] format "x(45)" label "ПРИМЕЧАНИЯ " skip
      vrem[2] label "" at 11 SPACE(1) skip
      vrem[3] label "" at 11 skip
      vrem[4] label "" at 11 skip
      vrem[5] label "" at 11 skip
      with title " РАСХОДНЫЙ ПЛАТЕЖ "
      side-label row 3 frame pay.
