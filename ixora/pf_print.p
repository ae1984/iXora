/* pf_ownrp.p
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
        19.02.2004 nadejda - заменен userid на g-ofc
*/

{mainhead.i}
def var rid as rowid.
def var pf_file as char.
def var rmzpl as char. 
def var tempstr as char.

update rmzpl label "RMZ платежа" format "x(10)" 
       with centered side-label frame fdat.
hide frame fdat.
rmzpl = caps(rmzpl).

find first bank.sysc where bank.sysc.sysc = "PSJIN" no-lock.
if avail bank.sysc then pf_file = trim(bank.sysc.chval).
    else do:
           MESSAGE "Не настроен SYSC для каталога входящих пенсионных файлов.~nПараметр PSJIN отсутствует !"
           VIEW-AS ALERT-BOX QUESTION BUTTONS OK TITLE "Внимание".
           return.    
    end.

pf_file = pf_file + rmzpl.
input through value( ' test -f ' + pf_file + ' && echo yes '). 
            repeat:
                import tempstr.
            end.
input close.  

if tempstr <> "yes" then do:
           MESSAGE "Файл не найден !"
           VIEW-AS ALERT-BOX QUESTION BUTTONS OK TITLE "Внимание".
 return.
end.

DEFINE BUTTON brg LABEL " Печать реестра regs.txt ".
DEFINE BUTTON bsw LABEL " Просмотр файла swift.txt ".
DEFINE BUTTON bq  LABEL " Выход ".

def frame f1 
    skip
    brg skip(1)
    bsw skip(1).
/*    bq skip.

ON CHOOSE OF bq IN FRAME f1
    do:
        quit.  
    end.
*/
ON CHOOSE OF bsw IN FRAME f1
    do:
     run menu-prt (pf_file).
    end.

ON CHOOSE OF brg IN FRAME f1
    do:
     unix silent value('swt2reg ' + rmzpl + ' ' + pf_file).
     /* лишние строки для прокрутки принтера 15/11/02 sasco */
     find first ofc where ofc.ofc = g-ofc no-lock no-error.
     if ofc.mday[2] = 1 then do:
         output to value (rmzpl + '.txt') append.
         put unformatted skip(15).
         output close.
     end.
     run menu-prt (rmzpl + '.txt').
    end.
ENABLE all WITH centered FRAME f1.
WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.

unix silent value('rm -f ' + rmzpl + '.txt').
