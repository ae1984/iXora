/* prntest.p
 * MODULE
        Общий
 * DESCRIPTION
        Тест печати на принтер
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        31/07/2007 madiyar
 * BASES
        bank
 * CHANGES
        02/08/2007 madiyar - добавил тест привязки фоток
        31/10/2008 madiyar - альтернативная директория для загрузки фотографий
*/

def var v-str as char no-undo extent 3.
def var pcoun as integer no-undo.
def var wdir as integer no-undo.
def shared var g-ofc as char.
def stream rep.

define button b1 label "Печать тестовой страницы".
define button b2 label "Вывод тестового отчета".
define button b3 label "Тест привязки фотографий".
define button b4 label "Выход".

define frame tst_main
skip(1) " 1." b1 " " skip " 2." b2 " " skip " 3." b3 " " skip " 4." b4 " " skip(1)
with row 15 no-labels /*no-box*/ centered.

on choose of b1 do:
    
    message "Ждите...".
    
    output stream rep to test.htm.
    find first cmp no-lock no-error.
    if avail cmp then do:
        v-str[1] = cmp.name.
        v-str[2] = cmp.addr[1].
    end.
    
    find first ofc where ofc.ofc = g-ofc no-lock no-error.
    if avail ofc then v-str[3] = g-ofc + ' ' + ofc.name.
    
    put stream rep unformatted
        skip
        v-str[1] skip
        v-str[2] skip
        v-str[3] skip
        skip(1)
        "Тестовая страница." skip.
    
    output stream rep close.
    
    unix silent prit -t test.htm.
    
    hide message no-pause.
    
    message " Тест завершен " view-as alert-box info.
    
end.

on choose of b2 do:
    
    message "Ждите...".
    
    output stream rep to test.htm.
    find first cmp no-lock no-error.
    if avail cmp then do:
        v-str[1] = cmp.name.
        v-str[2] = cmp.addr[1].
    end.
    
    find first ofc where ofc.ofc = g-ofc no-lock no-error.
    if avail ofc then v-str[3] = g-ofc + ' ' + ofc.name.
    
    put stream rep unformatted
        "<html><head><title>Тестовый отчет</title>" skip
        "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
        "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body><pre>" skip.
    
    put stream rep unformatted
        skip
        v-str[1] skip
        v-str[2] skip
        v-str[3] skip
        skip(1)
        "Тестовая страница." skip.
    
    put stream rep unformatted
        "</pre></body></html>" skip.
    
    output stream rep close.
    
    unix silent cptwin test.htm iexplore.
    
    hide message no-pause.
    
    message " Тест завершен " view-as alert-box info.
    
end.

on choose of b3 do:
    
    message "Ждите...".
    
    run check_photos(output pcoun,output wdir).
    if (pcoun <= 0) or (wdir <= 0) then message " Фотографии отсутствуют! " view-as alert-box error.
    else message " Найдено " pcoun " фото " view-as alert-box information.
    
    hide message no-pause.
    
end.

on choose of b4 do:
    apply "end-error" to frame tst_main.
end.

view frame tst_main.
enable all with frame tst_main.
wait-for window-close of current-window.


