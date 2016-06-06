/* tswdload.p
 * MODULE
        Загрузка справочников БИК
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
        5-14-7
 * AUTHOR
        19.07.2004 tsoy
        23.04.2010 k.gitalov Расширение таблицы, scp вместо rcp
        17.06.2011 Luiza добавление в swibic БИК банков России из файла bic_ru.dat.
 * CHANGES
*/

def var v-path   as char init "C:\\FI.dat".
def var v-result as char.
def var v-str    as char.
def var v-str1    as char.
def var v-bic    as char.
def var v-name   as char.
def var v-city   as char.
def var v-type   as char.
def var v-addr   as char.
def var cnt  as char.
def var i        as integer init 0.
def stream v-inp.
def stream v-inp1.


/*
def frame fth
          v-path   label "Путь" format "x(30)" skip
with centered overlay row 10 side-labels title "Закачать справочник БИК".

update v-path with frame fth.
*/
/*
 scp -i $HOME/.ssh/id_swift -o PasswordAuthentication=no Administrator@192.168.222.226:/bic/FI.DAT /data/import/swift/bic.dat
  input through value ('rcp `askhost`:' + replace(v-path ,'\\','\\\\') + ' ' + "bic.dat" + "; echo $?").
*/


/*input through value ("scp Administrator@`askhost`:" + replace(v-path ,"\\","\\\\") + "  /data/import/swift/bic.dat").*/

message "Копирование файла данных...".
pause 1.

/*input through value ("scp -i $HOME/.ssh/id_swift -o PasswordAuthentication=no Administrator@192.168.222.226:/bic/FI.DAT /data/import/swift/bic.dat").*/
input through value ("scp -i $HOME/.ssh/id_swift -o PasswordAuthentication=no r00t@192.168.222.229:/bic/FI.DAT /data/import/swift/bic.dat").
repeat:
  import v-result.
end.


if v-result <> "" then do:
  message skip " Произошла ошибка при копировании файла" v-path skip(1)
          view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.
else do:
  message "Копирование завершено, удаление текущих данных...".
  pause 1.
end.



for each swibic exclusive-lock.
   delete swibic.
end.

message "Удаление завершено, импорт данных...".
pause 1.

input stream v-inp from "/data/import/swift/bic.dat".
repeat:
 import stream v-inp unformatted v-str.
  i = i + 1 .
  v-bic =  substring (v-str, 4, 11).
  v-name = trim(substring (v-str, 15, 100)).
  v-city = trim(substring (v-str, 190, 20)).
  v-type = trim(substring (v-str, 225, 10)).
  v-addr = trim(substring (v-str, 324, 100)).
  cnt = substring (v-bic, 5, 2).


  find first codfr where codfr.codfr = "iso3166" and codfr.code = cnt no-lock no-error.
  if avail codfr then
  do:
    cnt = codfr.name[1].
  end.
  else do:
    /* message "Неизвестный код страны - " + cnt + " >>> " + v-bic + " >>> " + v-city view-as alert-box.*/
    cnt = "UNKNOWN".
  end.


   create swibic.
   swibic.bic = v-bic.
   swibic.name = v-name.
   swibic.city = v-city.
   swibic.type = v-type.
   swibic.addr = v-addr.
   swibic.cnt  = cnt.
end.
/* Luiza------------------------------*/

input stream v-inp1 from "/data/import/swift/bic_ru.dat".
repeat:
    import stream v-inp1 unformatted v-str1.
    i = i + 1 .
    v-bic =  entry(1,v-str1,"^").
    v-name = entry(2,v-str1,"^").
    v-city = entry(4,v-str1,"^").
    v-type = "SUPE".
    v-addr = entry(3,v-str1,"^").
    cnt = "RUSSIAN FEDERATION".


    create swibic.
    swibic.bic = v-bic.
    swibic.name = v-name.
    swibic.city = v-city.
    swibic.type = v-type.
    swibic.addr = v-addr.
    swibic.cnt  = cnt.
end.

/*---------------------------------------------*/
hide message no-pause.
message "Добавлено "  + string (i) + " записей"  view-as alert-box.
