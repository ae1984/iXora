/* htm2wiki.p
 * MODULE
        Программа общего назначения
 * DESCRIPTION
        Преобразование гипертекстовой разметки в разметку вики
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
        06/01/2008 madiyar
 * BASES
        BANK
 * CHANGES
        14/01/2009 madiyar - удаление избыточных тэгов <span>
*/

{mainhead.i}

function ns_check returns character (input parm as character).
    def var v-str as char no-undo.
    v-str = parm.
    v-str = replace(v-str,"/","//").
    v-str = replace(v-str,"!","\\!").
    v-str = replace(v-str," ","\\ ").
    v-str = "\\""" + v-str + "\\""".
    return (v-str).
end function.

function ms_remove_tag returns char (input src_str as char, input tag as char).
    def var v-str1 as char no-undo.
    def var v-str2 as char no-undo.
    def var i as integer no-undo.
    def var j as integer no-undo.
    v-str1 = src_str.
    repeat:
        if index(v-str1,'<' + tag + ' ') > 0 then do:
            i = index(v-str1,'<' + tag + ' ').
            if i > 1 then assign v-str2 = substring(v-str1,1,i - 1) v-str1 = substring(v-str1,i,length(v-str1) - i + 1).
            else v-str2 = ''.
            j = index(v-str1,'>').
            if j > 0 then do:
                if j < length(v-str1) then v-str1 = substring(v-str1,j + 1,length(v-str1) - j).
                else v-str1 = ''.
            end.
            v-str1 = trim(v-str1).
            v-str2 = trim(v-str2).
            if v-str1 <> '' and v-str2 <> '' then v-str2 = v-str2 + ' '.
            v-str1 = v-str2 + v-str1.
        end.
        else leave.
    end.
    return (v-str1).
end function.

function ms_remove returns char (input parm as char).
    def var v-str as char no-undo.
    v-str = parm.
    
    v-str = trim(replace(v-str,'<span>',' ')).
    v-str = trim(replace(v-str,'</span>',' ')).
    v-str = ms_remove_tag(v-str,"span").
    
    
    return (v-str).
end function.

def var v-file as char no-undo.
update v-file format "x(50)" label "Исходный файл (c:\\tmp\\~)" with side-labels frame fr.
v-file = trim(v-file).
if v-file = '' then return.

def var v-file_out as char no-undo.
v-file_out = entry(1,v-file,'.') + ".txt".

def var v-txt as char no-undo.

input through value("scp -q Administrator@`askhost`:" + ns_check("c:/tmp/" + v-file) + " .;echo $?").
import unformatted v-txt.
if trim(v-txt) <> '0' then do:
    message "Ошибка копирования исходного файла!" view-as alert-box error.
    return.
end.

unix silent value("perl /pragma/bin9/htm2wiki.pl " + v-file + " > 1.tmp").

def stream sout.
input through value("cat 1.tmp").
output stream sout to value(v-file_out).
repeat:
    import unformatted v-txt.
    if trim(v-txt) <> '' then v-txt = ms_remove(v-txt).
    put stream sout unformatted v-txt skip.
end.
input close.
output stream sout close.

input through value("scp -q " + v-file_out + " Administrator@`askhost`:c:/tmp;echo $?").
import unformatted v-txt.
if trim(v-txt) <> '0' then do:
    message "Ошибка копирования преобразованного файла!" view-as alert-box error.
    return.
end.

unix silent value("rm -f 1.tmp " + v-file + " " + v-file_out).

