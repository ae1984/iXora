/* almtvfind.p
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


def var contr as decimal.
def var lname as char.
def var sm as decimal init 0.
def var rid as rowid.

def frame sf
    contr skip
    lname
    with side-labels centered view-as dialog-box.

        update 
               contr format ">>>>>>>>>9" label "Номер контракта"
               lname format "x(25)" label "Фамилия"
               WITH side-labels 1 column  FRAME sf.
hide frame sf.

DEFINE QUERY q1 FOR almatv.

def browse b1 
    query q1 no-lock
    display 
        left-trim(string(almatv.ndoc,">>>>>>>9")) format "x(8)" label "No кон." 
        almatv.f format "x(15)" label "ФИО"
        Address format "x(15)" label "Адрес" 
        house format "x(5)" label "дом" 
        flat format "x(9)" label "квартира" 
        Summ format "->>>>>>9.99" label "Cумма"
        with 14 down title "Платежи АЛМА TV".

def frame f1 
    b1.
on return of b1
    do: 
        rid=rowid(almatv).
        apply "endkey" to frame f1.
    end.   
     
lname = caps(trim(lname)).
def var len as integer.
len = length(lname).

open query q1 for each almatv where dtfk = ? and (contr=0 or ndoc=contr) and
     (lname="" or caps(substr(almatv.f, 1, len)) = caps(lname)) no-lock.
   
if num-results("q1")=0 then
do:
    MESSAGE "Записи не найдены."
          VIEW-AS ALERT-BOX INFORMATION BUTTONS ok
                 TITLE "Платежи АЛМА TV".
    return.                 
end.
                 
ENABLE all WITH centered FRAME f1.
b1:SET-REPOSITIONED-ROW(14, "CONDITIONAL").
APPLY "VALUE-CHANGED" TO BROWSE b1.
WAIT-FOR endkey OF frame f1.

hide frame f1.
return string(rid).

