/* sf_main2.p
 * MODULE
        Аналитика
 * DESCRIPTION
        Аналитика - поиск РНН, машин, АлмаТВ, клиентов
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
        04.02.2004 sasco
 * CHANGES
*/


{global.i}

{get-dep.i}

def var i as integer.

DEFINE BUTTON brnnf LABEL "  РНН физических лиц   ".
DEFINE BUTTON brnnu LABEL "  РНН юридических лиц  ".
DEFINE BUTTON bauto LABEL "  Автомобили           ".
DEFINE BUTTON balma LABEL "  АлмаТВ               ".
DEFINE BUTTON bkmob LABEL "  K-Mobile             ".
define button bkcel Label "  K'Cell               ".
/*
DEFINE BUTTON bcif  LABEL "  Клиенты банка        ".
DEFINE BUTTON bpkrp LABEL "  Быстрые кредиты      ".
*/
DEFINE BUTTON bexit LABEL "  F4 - Выход           ". 

def frame f1 
    skip (1) 
    brnnf help " " skip
    brnnu help " " skip
    bauto help " " skip
    balma help " " skip
    bkmob help " " skip
    bkcel help " " skip
/*
    bcif  help " " skip
    bpkrp help " " skip
*/
    bexit help " " skip (1)
    WITH CENTERED 1 column row 3 TITLE " Аналитика ".


ON CHOOSE OF brnnf IN FRAME f1
    do:
        run sf_rnn.
    end.
ON CHOOSE OF brnnu IN FRAME f1
    do:
        run sf_rnnu.
    end.
ON CHOOSE OF bauto IN FRAME f1
    do:
        run sf_auto.
    end.
ON CHOOSE OF balma IN FRAME f1
    do:
        run sf_alma.
    end.
ON CHOOSE OF bkmob IN FRAME f1
    do:
        run connibkm.
    end.
ON CHOOSE OF bkcel IN FRAME f1
    do:
        run connibkc.
    end.
/*
ON CHOOSE OF bcif IN FRAME f1
    do:
        run sf_cif.
    end.
ON CHOOSE OF bpkrp IN FRAME f1
    do:
        run pkrepbo.
    end.
*/
ON CHOOSE OF bexit IN FRAME f1
    do:
        apply "pick-area" to frame f1.
    end.


ENABLE all WITH centered FRAME f1.
wait-for window-close of current-window or "pick-area" of frame f1.

