/* astm1.p
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

def input parameter tit as char.
def input parameter op as char.
{mainhead.i}

  Define Variable selection  As Character.
  Define Variable menuchoice As Char Extent 3  format "x(60)" INITIAL
          [" 1.  НОВАЯ карточка ",     
           " 2.  ДОПОЛН.СУММА  для карточки",   
           " 3.  ВЫХОД / <F4>"]. 
      
 Repeat:
    Form SKIP(1) menuchoice[1]
                 menuchoice[2]
                 menuchoice[3] SKIP(2)
                 "Введите номер или выберите клав.<ENTER>"

    With FRAME izms-m  CENTERED
                      TITLE " " + tit + " "       
                      ATTR-SPACE  NO-LABELS ROW 4.
 DISPLAY menuchoice WITH FRAME izms-m. 
 CHOOSE FIELD menuchoice AUTO-RETURN WITH FRAME izms-m.
  selection = SUBSTR(FRAME-VALUE,1,2). 
  If selection eq " 1" then do on endkey undo, leave:
      if op="1" then run astie("1").
      if op="3" then run astie("3").
      if op="8" then run astie("8").
  end.

  else If selection eq " 2" then do on endkey undo, leave:
      if op="1" then run astpc("1",substr(frame-value,4,25)).
      if op="3" then run astpc("3",substr(frame-value,4,25)).
      if op="8" then run astpc("8",substr(frame-value,4,25)).
  end. 
  else If selection eq "3" then return.
  return.
END.



