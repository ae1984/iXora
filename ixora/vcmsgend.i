/* vcmsgend.i
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Окончание формирования телеграммы
 * RUN
        передается вид телеграммы, которую нужно послать
 * CALLER
        vcmsg104, vcmsg105, vcmsg106
 * SCRIPT

 * INHERIT

 * MENU
        15.5.2, 15.5.3, 15.5.4
 * AUTHOR
        19.03.2003 nadejda - вырезан кусок из vc104msg.p
 * BASES
        BANK COMM
 * CHANGES
        15.08.2003 nadejda - добавлено стирание файлов в домашнем каталоге юзера
        10.11.2008 galina - вызываем скрипт un-win1 для заворота каретеки в кодировке windows
        09.10.2013 damir - Т.З. № 1670.
*/


put stream rpt "-}".

output stream rpt close.

/* копирование файла в каталог телеграмм */
unix silent value("un-win1 " + v-filename0 + " " + v-filename).

input through value("scp -q " + v-filename + " " + v-ipaddr + ":" + v-dir + ";echo $?" ).
repeat :
  import v-exitcod.
end.
pause 0.

unix silent rm -f value (v-filename0).
unix silent rm -f value (v-filename).

if v-exitcod <> "0" then do:
  message skip " Произошла ошибка при копировании сообщения в каталог" skip(1)
          v-dir
          skip(1) view-as alert-box button ok title " ОШИБКА ! ".
  return.
end.

find vcparams where vcparams.parcode = "mt{&msg}-n" exclusive-lock no-error.
if not avail vcparams then do:
  message skip " Не найден параметр mt{&msg}-n !"
          skip(1) view-as alert-box button ok title " ОШИБКА ! ".
  return.
end.
vcparams.valinte = vcparams.valinte + 1.
find current vcparams no-lock.


hide message no-pause.
/*message skip " Создан файл телеграммы" v-filename
        skip(1) view-as alert-box button ok title "".*/

