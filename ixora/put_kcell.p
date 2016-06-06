/* put_kcell.p
 * MODULE
        Платежи 
 * DESCRIPTION
        FTP Posting
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
        19/04/2006  tsoy
 * CHANGES
        19/04/2006  tsoy Изменил текст выводимый в лог
*/

{lgps.i}

def var v-str as char.
def var v-log as char.
def var v-ok  as logi.

def input parameter p-file as char.
def output parameter p-out as logi .

unix silent value("scp -q " + p-file + " transfer@192.168.2.3:\~/. " ).

v-ok  = false.
p-out = false.

input through value( "ssh transfer@192.168.2.3 ./put_kcell " + p-file ). 
repeat:

    import unformatted v-str.
    v-log = v-log + v-str.
    if index(v-str, "226 Transfer complete") > 0  then v-ok = true .

end.
input close.  

if v-ok then do:


     v-text = "Загрузка файла в K-Cell  " + p-file.
     run lgps .

     
     unix silent value("ssh transfer@192.168.2.3 rm " + p-file).
     pause 0.

     p-out = v-ok.

end. else do:

     v-text = "Error : Ошибка Загрузка файла в K-Cell  " + p-file + " " + v-log.
     run lgps . 

     p-out = v-ok.

end.


