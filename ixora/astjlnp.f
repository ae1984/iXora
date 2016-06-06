/* astjlnp.f
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


form astjln.aast label "K.Nr." format "x(8)"
     astjln.atrx label "Оп" format "xx"
     astjln.apriz no-label format "x"
     astjln.ajdt label "Дата  "
     astjln.aamt label "Сумма" format "zzzzzzz9.99"
     astjln.adc  no-label 
     astjln.aqty label "Кол" format "zz9"
     astjln.ajh label "Nr.оп."
     astjln.icost label "Первон.ст." format "zzzzzzz9.99"
     skip
     "         "
     astjln.afag format "x(3)" 
     astjln.ak format "x(1)"
     astjln.stdt label "Сторно  " 
     astjln.stjh label "   оп.Nr"
     astjln.crline label "Нал.ост.ст.нач.года" format "zzzzzzz9.99-"
     astjln.prdec[1] label "+/- тек.году " format "zzzzzzz9.99-"
     skip 
     "            " astjln.arem[1] no-label   format "x(55)"
     skip

  with centered overlay  row 4 4 down  no-hide 
       title  "  Изменение операции " frame astjlnp.
