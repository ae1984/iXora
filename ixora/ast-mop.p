/* ast-mop.p
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
        11.11.10 marinav - 11.  Передача ОС между подразделениями              
        07.12.10 marinav - 12.  Реализация ОС               
*/

/*define new shared variable tab as char format "x(6)".
define new shared variable mmsg as char format "x(40)".
*/
{mainhead.i}
  Define Variable selection  As Character.
  Define Variable menuchoice As Char Extent 13  format "x(60)" INITIAL
          [" 1.  ОПЕРАЦИЙ ПРОСМОТР,УДАЛЕНИЕ,СТОРНИРОВАНИЕ",
           " 2.  ПРИХОД                                              ", 
           " 3.  ПЕРЕРЕГИСТРАЦИЯ (приход с износом)                ",   
           " 4.  УВЕЛИЧЕНИЕ СТОИМОСТИ ОС (+)",
           " 5.  ПЕРЕОЦЕНКА ОСНОВНЫХ СРЕДСТВ (+,-)",
           " 6.  ПЕРЕМЕЩЕНИЕ С Карт. НА Карт.                      ",   
           " 7.  ВЫБЫТИЕ                                         ",   
           " 8.  ПЕРЕРЕГИСТРАЦИЯ (выбытие,передача)              ",   
           " 9.  УМЕНЬШЕНИЕ СТОИМОСТИ ОС (-)",
           "10.  ТЕКУЩИЙ РЕМОНТ",  /* KOVAL */
           "11.  Передача ОС между подразделениями               ",
           "12.  Реализация ОС                      ",
           "13.  ВЫХОД / <F4>"]. 
      
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
                 menuchoice[10]
                 menuchoice[11]
                 menuchoice[12] 
                 menuchoice[13] 
                 SKIP(2)
                 "Введите номер или выберите клавишой <ENTER>"

    With FRAME izms-m CENTERED
                      TITLE " ОПЕРАЦИИ С ОСНОВНЫМИ СРЕДСТВАМИ "       
                      ATTR-SPACE  OVERLAY NO-LABELS ROW 4.
 DISPLAY menuchoice WITH FRAME izms-m. 
 CHOOSE FIELD menuchoice AUTO-RETURN WITH FRAME izms-m.
  selection = SUBSTR(FRAME-VALUE,1,2). 
  If selection eq " 1" then do on endkey undo, leave:
        run astopr.
  end.

  else If selection eq " 2" then do on endkey undo, leave:
       run astm1(frame-value,"1"). /* run astie("1"). */
  end. 

  else If selection eq " 3" then do on endkey undo, leave:
       run astm1(frame-value,"3"). /* run astie("2"). */
  end. 

  else If selection eq " 4" then do on endkey undo, leave:
       run astpc("+","").
  end. 
  else If selection eq " 5" then do on endkey undo, leave:
       run astm2(frame-value,"p"). /* run astie("8"). */
  end. 
  else If selection eq " 6" then do on endkey undo, leave:
       run astpv.
  end. 
  else If selection eq " 7" then do on endkey undo, leave:
       run astiz("1").
  end. 
  else If selection eq " 8" then do on endkey undo, leave:
       run astiz("2").
  end. 
  else If selection eq " 9" then do on endkey undo, leave:
       run astpc("-","").
  end. 

  else If selection eq "10" then do on endkey undo, leave:
       run astrem("r1"). /* KOVAL repair */
  end. 

  else If selection eq "11" then do on endkey undo, leave:
       run astpe.
  end. 

  else If selection eq "12" then do on endkey undo, leave:
       run astre.
  end. 

  else If selection eq "13" then return.

END.
