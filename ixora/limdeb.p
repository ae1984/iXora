/* limdeb.p
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

/* 19/03/2003 - Kanat - Ввод ограничений по дебетовым операциям по счетам 406 группы клиентов */

{comm-txb.i}

def var seltxb as int.
seltxb = comm-cod().

{get-dep.i}
{comm-com.i}
{yes-no.i}

def input parameter newdoc as logical.
def input parameter aaa_acc as char.
def input parameter g-today as date.

def var cret as char init "".
define frame sf with side-labels centered view-as dialog-box.

def var lcom  as logical init false.
def var cdate as date init today.
def var do_trans as logical.


def frame sf
     "Лимиты по дебетовым операциям" skip
     "----------------------------------------"  skip
     debet_restr.date    view-as text label "Дата"
     debet_restr.sum                  label "Сумма"        format ">>>,>>>,>>>,>>>,>>9.99"
     with side-labels centered.



find first aaa where aaa.aaa = aaa_acc no-lock no-error.

if avail aaa then do:

find first cif where cif.cif = aaa.cif and cif.cgr = 406 no-lock no-error.

if avail cif then do:

do transaction:
    if newdoc then create debet_restr.
              else find debet_restr where debet_restr.aaa = aaa_acc.

       debet_restr.date = g-today.

       display 
               debet_restr.date 
               with side-labels frame sf.

    if newdoc or (debet_restr.date <> ?) then do:
               update 
                     debet_restr.sum
                  with frame sf editing:
                  readkey.
                  apply lastkey.
               end.

        message "Сохранить информацию ?" view-as alert-box question buttons yes-no-cancel
                 title "ВНИМАНИЕ" update choice as logical.

        case choice:
            when true then do :
                update 
                debet_restr.date    = g-today
                debet_restr.ltime   = time
                debet_restr.cif     = aaa.cif
                debet_restr.aaa     = aaa.aaa
                debet_restr.login   = userid("bank").

                cret = string(rowid(debet_restr)).
            end.
            when false then                                  
                undo.
            otherwise
                undo, leave.
        end case.

        end.

     else 
         display
            debet_restr.date
            debet_restr.sum format ">>>,>>>,>>>,>>>,>>9.99" with frame sf.

end.
end.
else
    message 'Операция невозможна' view-as alert-box title 'Внимание'.    
end.



hide frame sf.

return cret.
