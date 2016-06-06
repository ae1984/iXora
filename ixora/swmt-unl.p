/* swmt-unl.p
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
        20/05/2010 k.gitalov новая версия
        08/02/2012 k.gitalov изменил ip адрес сервера
*/


/* scp –i /home/id00276/.ssh/id_swift /data/export/mt103/ Administrator@192.168.222.226:/swift/in/ */

def var v-path   as char init "/data/export/mt103/".
def var v-file   as char.  /* init "RMZA158484". */
def var v-result as char init "Все".
def var v-aaa as char.


 input through value ("ls /data/export/mt103/").
 repeat:
   import unformatted v-aaa.
   v-result = v-result + "|" +  v-aaa.
 end.

 if v-result = "Все" then do: message "Нет файлов для отправки!" view-as alert-box. return. end.
 run sel1("Выберите файл для отправки",v-result).
 v-aaa = return-value.

 if v-aaa = "Все" then v-file = "*".
 else v-file = v-aaa.

 v-result = "".
 input through value ("scp -i $HOME/.ssh/id_swift -o PasswordAuthentication=no " + v-path + v-file + " r00t@192.168.222.229:/swift/in/").
/* input through value ("scp -i $HOME/.ssh/id_swift -o PasswordAuthentication=no " + v-path + v-file + " Administrator@192.168.222.226:/swift/in/").*/
 repeat:
  import unformatted v-result.
 end.

if v-result <> "" then do:
  message skip " Произошла ошибка при копировании файла" v-file skip(1) v-result
          view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.
else do:
   v-result = "".
   input through value ("rm " + v-path + v-file).
   repeat:
     import v-result.
   end.

   if v-result <> "" then do:
      message skip " Произошла ошибка при удалении файла " v-path + v-file skip(1) v-result
          view-as alert-box buttons ok title " ОШИБКА ! ".
      return.
   end.

  message "Отправка на сервер SWIFT завершена!".
  pause 1.
end.

/*
unix value('clear;su - telex -c "cd /home/telex;export PATH=$PATH:/usr/local/bin;tobkc;echo $?"').
*/

