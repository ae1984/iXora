/* astjlnp1.f
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


form astjln.aast /*label "K.Nr."*/ format "x(8)"
     astjln.atrx /*label "Оп"*/ format "xx"
     astjln.apriz no-label format "x"
     astjln.ajdt /*label "Дата  "*/
    /* astjln.aamt label "Сумма" format "zzzzzzz9.99" */
     astjln.adc  no-label 
     astjln.aqty /*label "Кол" */ format "zz9"
     astjln.ajh /*label "Nr.оп." */
    /* astjln.icost label "Первон.ст." format "zzzzzzz9.99" 
      skip 
     "         "
    */
     astjln.afag format "x(3)"  
     astjln.ak format "x(1)" 
     astjln.stdt /*label "Сторно  " */ 
     astjln.stjh /*label "   оп.Nr" */
   /*
     astjln.crline label "Нал.ост.ст.нач.года" format "zzzzzzz9.99-"
     astjln.prdec[1] label "+/- тек.году " format "zzzzzzz9.99-"
   */ 
    skip 
     "Баланс.ст. " astjln.d[1] no-label format "zzzzzz,zzz,zz9.99"  "DR" 
                  astjln.c[1] no-label format "zzzzzz,zzz,zz9.99"  "CR"
     skip
     "      Износ" astjln.d[3] no-label format "zzzzzz,zzz,zz9.99"  "DR" 
                  astjln.c[3] no-label format "zzzzzz,zzz,zz9.99"  "CR"
     skip
     "Фонд переоц"astjln.d[4] no-label format "zzzzzz,zzz,zz9.99"  "DR" 
                  astjln.c[4] no-label format "zzzzzz,zzz,zz9.99"  "CR"
     skip

     "            " astjln.arem[1] no-label   format "x(55)"
     skip

  with centered overlay  row 3 3 down  no-hide no-labels
       title  "K.Nr. Оп.   Дата    Кол-во  Nr.оп.   Гр.   Сторно         оп.Nr"

  /*"  Изменение операции "*/ frame astjlnp.
