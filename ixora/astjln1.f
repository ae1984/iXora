/* astjln1.f
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
     astjln.ajdt label "Дата  "
     astjln.apriz no-label format "x"
     astjln.aqty label "Кол" format "zzz9"
     astjln.ajh label "Nr.оп." 
     astjln.arem[1] no-label   format "x(30)"
     astjln.atrx label "Oп" format "xx"
  with centered overlay no-hide row 4 10 down
 title "С " + string(v-dt1,"99/99/99") + " по " + string(v-dt2,"99/99/99") 
       + "  " + v-astn  frame astjln1.

/********************************************
form astjln.aast label "K.Nr." format "x(8)"
     astjln.ajdt label "Дата  "
     astjln.aamt label "Сумма" format "zzz,zzz,zz9.99"
     astjln.adc  no-label 
     astjln.apriz no-label format "x"
     astjln.aqty label "Кол" format "zz9"
     astjln.ajh label "Nr.оп." 
     astjln.arem[1] no-label   format "x(22)"
     astjln.atrx label "Oп" format "xx"
  with centered overlay no-hide row 7 10 down
       title v-astn frame astjln1.
************************************************/
