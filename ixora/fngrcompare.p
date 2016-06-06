/* fngrcompare.p
 * MODULE
        БИОМЕТРИЯЧЕСКИЙ АНАЛИЗ
 * DESCRIPTION
        Назначение программы, описание процедур и функций
	Сканирование и сравнение отпечатков пальцев 
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
        19/09/05 u00121
 * CHANGES
        02/02/06 u00121 - изменил принцип формирования ответов от сканера
        06/01/08 marinav - исправлен путь к базам с /data/9/ на /data/
        27/03/2008 madiyar - новые сканеры
*/

def input param i-cif as char.
def input param i-upl as char.
def output param o-out as int init 2.

def var v as char no-undo.

DEFINE BUTTON button-scan LABEL "Сканировать".
DEFINE BUTTON button-compare LABEL "Сверить".

FORM button-scan button-compare WITH FRAME but-frame ROW 7 overlay.

ON CHOOSE OF button-scan do:
    /*Удаляем файлы с пользовательского компьютера*******************/
    unix silent value("ssh Administrator@`askhost` erase /Q c:\\\\bio\\\\out\\\\*").
    
    unix silent value("touch run.bin").
    unix silent value("scp -q run.bin Administrator@`askhost`:c:\\\\bio\\\\in").  
end.

ON CHOOSE OF button-compare DO:
    /*копирование файлов из базы данных на пользовательский компьютер*/
    unix silent value("scp -q /data/import/fingers/" + i-cif + "/" + string(i-upl) + "/hXTemplate1 Administrator@`askhost`:c://bio//out//hXTemplate2").
    input through value ("ssh Administrator@`askhost` c:\\\\bio\\\\compare c:\\\\bio\\\\out\\\\hXTemplate1 c:\\\\bio\\\\out\\\\hXTemplate2").
    import v.
    o-out = integer(v) no-error.
    input close.
    
    /*Удаляем файлы с пользовательского компьютера*******************/
    unix silent value("ssh Administrator@`askhost` erase /Q c:\\\\bio\\\\out\\\\*").
end.

ENABLE all WITH FRAME but-frame.
WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW or CHOOSE OF button-compare.






