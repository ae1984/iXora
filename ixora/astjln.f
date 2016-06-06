/* astjln.f
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


form skip
 "На"  g-today astjln.agl ":" v-icost   "Остаток:"  v-atl skip
 "           " v-gl3 ":" v-nol  "Кол-во :" ast.qty format "zzz9" skip 
                                         "    Дат.рег." at 52 ast.rdt skip
 "-------------------------------------------------------------------------"
      skip
 "Операция N:" astjln.ajh "   Дата: "astjln.ajdt "  Исп.:"astjln.awho  
                           " Код.оп.:" astjln.atrx format "xx" skip
 "-------------------------------------------------------------------------"
     skip
      v-gl1 astjln.d[1] format "zzzzzz,zzz,zz9.99-" "DR" 
            astjln.c[1] format "zzzzzz,zzz,zz9.99-" "CR" 
             astjln.aqty format "zz9-" "шт." skip
      v-am  astjln.d[3] format "zzzzzz,zzz,zz9.99-" "DR"
            astjln.c[3] format "zzzzzz,zzz,zz9.99-" "CR"  
            skip 
     v-gl4  astjln.d[4] format "zzzzzz,zzz,zz9.99-" "DR"
            astjln.c[4] format "zzzzzz,zzz,zz9.99-" "CR"  
            skip  

  
     astjln.arem[1]  format "x(60)" skip
     astjln.arem[2]  format "x(60)" skip
  
/*     "Ост.ст.налоговая:" astjln.crline format "zzzzzzzz9.99-" "+"
                         astjln.prdec[1] format "zzzzzzzz9.99-" skip
*/
     "Корресп.cч.:" astjln.korgl astjln.koracc " " astjln.kpriz   format "x(40)" skip
     "Сторно   :" astjln.stdt astjln.stjh skip
  with centered no-labels overlay no-hide row 7 
       title "  " + astjln.aast + "  " + ast.name + "  " frame astjln.



/*******************************
form skip
     "Счет :" astjln.agl  "на" at 25 g-today  "Остаток :" at 38 v-atl skip
     "Дат.рег." ast.rdt           "Кол-во  : " at 38 ast.qty format "zzz9" skip
 "-------------------------------------------------------------------------"
      skip
 "  Дата         Дебет        Кредит     Кол-во     Nr.опер.       Код.оп." skip
 "-------------------------------------------------------------------------"
     skip
      astjln.ajdt 
     astjln.dam format "zzz,zzz,zz9.99-" skip
     astjln.cam format "zzz,zzz,zz9.99-" at 20
     astjln.apriz no-label format "x"
     astjln.aqty format "zz9-" "gab.  " 
     astjln.ajh astjln.awho astjln.atrx format "xx" skip 
     astjln.arem[1]  format "x(60)" skip
     astjln.arem[2]  format "x(60)" skip
     "  Перв.стоим.:" astjln.icost format "zzzzzzzz9.99-"
     "Ост.ст.налоговая:" astjln.crline format "zzzzzzzz9.99-" "+"
                         astjln.prdec[1] format "zzzzzzzz9.99-" skip
     "Корреспондент:" astjln.korgl astjln.koracc " " astjln.kpriz   format "x(40)" skip
     "Сторно   :" astjln.stdt astjln.stjh skip
  with centered no-labels overlay no-hide row 7 
       title "  " + astjln.aast + "  " + ast.name + "  " frame astjln.
**********************************************/
