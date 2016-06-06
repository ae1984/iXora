/* pk.i
 * MODULE
        ПотребКредит
 * DESCRIPTION
        Общие переменные потребительского кредитования
 * RUN
        Должна присутствовать в любой программе, где есть обращение к общим переменным
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        
 * AUTHOR
        24.01.2003 nadejda
 * CHANGES
        04.02.2003 marinav
        08.02.2003 nadejda перекомпиляция в связи с добавлением полей в pkanketa
        11.02.2003 marinav перекомпиляция в связи с добавлением полей в pkanketa
                           добавлена общая переменная - номер анкеты
        13.02.2003 nadejda 
        20.03.2003 marinav перекомпиляция в связи с добавлением полей в pkanketa sumcom, sumout
        10.05.2003 marinav новые поля в pkkrit
        12.08.2003 marinav перекомпиляция исходников в связи с переносом таблицы pkkrit из COMM в BANK
        10.12.2003 nadejda добавлена программа {pk0.i} - общая для перекомпиляции ВСЕХ исходников, использующих таблицы Потребкредита
*/


{pk0.i}

/* текущий вид кредита */
define {1} shared var s-credtype as char.
/* определить вид кредита по первым буквам вызванного меню */
if "{1}" = "new" then do:
  def var vs as char.
  vs = caps(substr(g-fname, 1, 2)).
  find bookcod where bookcod.bookcod = "credtype" and caps(bookcod.info[1]) = vs no-lock no-error.
  if avail bookcod then s-credtype = bookcod.code.
                   else s-credtype = "0".
end.

/* номер текущей обрабатываемой анкеты */
define {1} shared var s-pkankln like pkanketa.ln. 

/* файл факсимиле для подписи документов - путь на локальной машине + название.  
   Определяется в pkdogsgn.p 
*/
define {1} shared var s-dogsign as char.
define {1} shared var s-lon as char.

/* каталог временных файлов на локальной машине юзера */
define {1} shared var s-tempfolder as char.

/* текущий банк */
{comm-txb.i}
define {1} shared var s-ourbank as char.
s-ourbank = comm-txb().


