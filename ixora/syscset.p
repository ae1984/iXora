/* syscset.p
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

 /* setsysc.p  */ 


DEFINE QUERY q1 FOR sysc. 
def var aa as char format "x(5)".
def var bb as char format "x(51)".
def var cc as char format "x(65)".
def var cc1 as char format "x(75)".
def var cc2 as char format "x(75)".
def var cc3 as char format "x(75)".
def var cc4 as char format "x(75)".
def var answ as logical init "no".
def var m-rtn as logical.
Def button but_del label "Удалить" . 
Def button but_add label "Добавить" .
Def button but_upd label "Коррекция" .

 DEFINE VARIABLE method-return AS LOGICAL NO-UNDO.


DEFINE BROWSE b1 QUERY q1 DISPLAY sysc.sysc label "КОД" 
        sysc.des label "ОПИСАНИЕ" format "x(30)" enable sysc.des      
        WITH 10 DOWN no-assign title "SYSC"  . 

DEFINE FRAME f1
        b1 but_del but_add but_upd 
        WITH SIDE-LABELS AT ROW 2 COLUMN 2.
define frame f2
        aa label "КОД" 
        WITH SIDE-LABELS AT ROW 13 COLUMN 1.
define frame f3
        bb label "ОПИСАНИЕ" 
        WITH SIDE-LABELS AT ROW 13 COLUMN 15.
define frame f4
        cc label "ЗНАЧЕНИЕ" cc1 no-labels cc2 no-labels 
        cc3 no-labels cc4 no-labels
        WITH SIDE-LABELS AT ROW 15 COLUMN 1.
/*
define frame f5
        answ label "Вы уверены ??? Удалить строку???"
        with side-labels AT ROW 17 COLUMN 1.
*/        
        
OPEN QUERY q1 FOR EACH sysc where sysc.sysc begins ">" exclusive-lock.

ENABLE b1 but_del but_add but_upd WITH FRAME f1.


on "end-error" of frame f1 do:
    pause 1.
    hide frame f1.                                 
    hide frame f5.
    return.
end.

ON ROW-LEAVE OF b1 IN FRAME f1 DO:
    IF b1:NEW-ROW THEN DO:
        aa = "". bb = "". cc = "". cc1 = "". cc2 = "". cc3 = "". cc4 = "".
        update aa with overlay frame f2.
        update bb with overlay frame f3.
        update cc cc1 cc2 cc3 cc4 with overlay frame f4.
        create sysc.
        sysc.sysc = ">" + aa.
        sysc.des = bb.
        sysc.chval = trim(cc) + trim(cc1) + trim(cc2) + trim(cc3) + trim(cc4).
        
        /*ASSIGN INPUT BROWSE b1 sysc.sysc .*/
        DISPLAY sysc.sysc sysc.des WITH BROWSE b1.        
        method-return = b1:CREATE-RESULT-LIST-ENTRY().
        hide frame f2.
        hide frame f3.
        hide frame f4.
        RETURN. 
    END.
end.

ON CHOOSE OF but_add IN FRAME f1 /* Insert */
    DO:
        method-return = b1:INSERT-ROW("AFTER").
    END.
 
on choose of but_del in frame f1 
    do:
        answ = no.
        message "Вы уверены ?? Удалить строку " + sysc.sysc " ??"
        update answ /*with overlay frame f5*/ .
        if answ and b1:NUM-SELECTED-ROWS in frame f1 > 0  then do:
            m-rtn = b1:FETCH-SELECTED-ROW(1).
            GET CURRENT q1 EXCLUSIVE-LOCK.
            delete  sysc.
            m-rtn = b1:DELETE-SELECTED-ROWS().
            close query q1.
            find first sysc .
            open query q1 for each sysc where sysc.sysc begins ">" 
            exclusive-lock.
            m-rtn = b1:select-focused-row() in frame f1.
            enable all with frame f1.
            hide frame f5.
        end.
 end.
 
on choose of but_upd or "return" of sysc.des in browse b1
    do: 
        aa = "". bb = "". cc = "".
        aa = substring(sysc.sysc,2,6).
        disp aa with overlay frame f2.
        update aa with overlay frame f2.
        find sysc where sysc.sysc eq ">" + aa exclusive-lock.
        bb = sysc.des.
        cc = substring(sysc.chval,1,65).
        cc1 = substring(sysc.chval,66,75).
        cc2 = substring(sysc.chval,141,75).
        cc3 = substring(sysc.chval,216,75).
        cc4 = substring(sysc.chval,291,75).
        update bb with overlay frame f3.
        update cc cc1 cc2 cc3 cc4 with overlay frame f4.
        sysc.sysc = ">" + aa.
        sysc.des  = bb.
        sysc.chval = trim(cc) + trim(cc1) + trim(cc2) + trim(cc3) + trim(cc4).
        disp sysc.sysc sysc.des with browse b1.
        hide frame f2.
        hide frame f3.
        hide frame f4.
        apply "entry" to browse b1.
 end.   

  
wait-for /*choose of but_del in frame f1 or 
         choose of but_add in frame f1 or
         choose of but_upd in frame f1*/ close of current-window.
