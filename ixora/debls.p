/* debls.p
 * MODULE
        Дебиторы
 * DESCRIPTION
        Настройка дебиторов
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
        13/01/04 sasco ПЕРЕКОМПИЛЯЦИЯ
        14/01/04 sasco Добавил отчет по срокам
        11/03/04 sasco Добавил отчет по просроченным срокам
        01/06/06 u00600 добавила архив
        15/08/06 u00600 оптимизация 
*/


  {comm-txb.i}

  Define Variable selection  As Character no-undo.

  Define Variable menuchoice As Char Extent 9 format "x(41)" INITIAL
          [" 1.  НАСТРОЙКИ ГРУПП И ДЕБИТОРОВ",
           " 2.  ОТЧЕТ : ОСТАТКИ НА ДАТУ    ",
           " 3.  ОТЧЕТ : ИСТОРИЯ ДВИЖЕНИЙ   ",
           " 4.  ОТЧЕТ : ОСТАТКИ ПО СРОКАМ  ",
           " 5.  ОТЧЕТ : ИСТЕКШИЕ СРОКИ     ",
           " 6.  ИЗМЕНИТЬ СРОК              ",
           " 7.  ОТЧЕТ : ИЗМЕНЁННЫЕ СРОКИ   ",
           " 8.  АРХИВ                      ",
           " 9.  ВЫХОД / <F4>               "]. 

      
 Repeat:
    Form SKIP(1) menuchoice[1] 
                 menuchoice[2] 
                 menuchoice[3] 
                 menuchoice[4] 
                 menuchoice[5] 
                 menuchoice[6] 
                 menuchoice[7]
                 menuchoice[8]
                 menuchoice[9]
                 SKIP(2)
                 "Введите номер или выберите клавишой <ENTER>"
    With FRAME izms-m  CENTERED
                      TITLE " ОПЕРАЦИИ С ДЕБИТОРАМИ " 
                      ATTR-SPACE  OVERLAY NO-LABELS ROW 4.

 DISPLAY menuchoice WITH FRAME izms-m. 

 CHOOSE FIELD menuchoice AUTO-RETURN WITH FRAME izms-m.

  selection = SUBSTR(FRAME-VALUE,2,1). 

  If selection eq "1" then do on endkey undo, leave:
       run debset.
  end.
  else If selection eq "2" then do on endkey undo, leave:
       run debost.
  end. 
  else If selection eq "3" then do on endkey undo, leave:
       run debhist.
  end. 
  else If selection eq "4" then do on endkey undo, leave:
       run debost2.
  end. 
  else If selection eq "5" then do on endkey undo, leave:
       run debost3.
  end. 
  else If selection eq "6" then do on endkey undo, leave:
       run debsrok.
  end. 
  else If selection eq "7" then do on endkey undo, leave:
       run  debchange.
  end. 
  else If selection eq "8" then do on endkey undo, leave:
       run  debarh.
  end. 

  else If selection eq "9" then do: hide all no-pause. return. end.

END.
