/* ofimen.p
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
        17.02.2011 id00004 увеличил формат ввода функции до 10 знаков т.к некоторые функции не вмещались
*/

/***************************************************************************\
*****************************************************************************
**  Program: ofimen.p
**       By: AGA
** Descript: Печать всех ofc, котоpые имеют пpаво на данную функцию
**
*****************************************************************************
\***************************************************************************/

def shared var g-today as date.
DEF var gfc LIKE ofc.ofc.
DEF var vpor LIKE nmenu.fname.
DEF var vvpor LIKE nmenu.fname .
DEF var vnam LIKE nmdes.des.
DEF var num AS char.

def stream sta.
def var van as log.

OUTPUT stream sta TO rpt.img.

  vpor = vvpor.    
  update  "ИМЯ ФУНКЦИИ"  vpor format "x(10)" help " Введите имя функции "
   with centered row 6 frame fff no-label.
  vvpor = vpor.
  FIND first nmenu  WHERE nmenu.fname = vpor NO-LOCK NO-ERROR .
  vpor = nmenu.fname.
  IF AVAILABLE nmenu THEN
  DO:
          Find first nmdes WHERE nmdes.fname = nmenu.fname
          AND nmdes.lang = "RR" NO-LOCK.
          vnam = nmdes.des.
          num = "". 
      REPEAT:
          FIND nmenu WHERE nmenu.fname = vpor   NO-LOCK NO-ERROR.
          IF AVAILABLE nmenu THEN
          DO:
            num = trim(string(nmenu.ln,"z9")) + "." + num.
            IF nmenu.father  =  "menu" THEN
            LEAVE.
            vpor = nmenu.father.
          END.
          ELSE
          DO:
            num = "".
            LEAVE.
          END.
      END.
 
 
    PUT stream sta SKIP(3).
    put stream sta "Дата "  at 55  g-today 
      "  "   string(time,"HH:MM:SS") SKIP(0).

    PUT stream sta "PRAGMA:  права доступа к пункту меню "  trim(num) format "x(30)"  skip.
      PUT  stream sta caps(vvpor) format "x(8)" "  " vnam   SKIP(2).
    FOR EACH sec WHERE sec.fname = vvpor NO-LOCK:
       FIND first ofc where ofc.ofc = sec.ofc no-lock no-error.
       if available ofc /*and ofc.tit EQ "user"*/ then do:
        put stream sta ofc.ofc "  " ofc.name skip. 
       end.
    END.
  END.
  put STREAM STA skip(2).

PUT stream sta "------ КОНЕЦ ДОКУМЕНТА ------" FORMAT "x(30)" SKIP.

OUTPUT stream sta close.

run menu-prt("rpt.img").

