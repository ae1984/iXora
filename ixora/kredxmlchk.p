/*kredxmlchk.p
 * MODULE
       Кредиты
 * DESCRIPTION
        Проверка загрузки в КБ по номерам пакетов
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
        24/03/2009 galina
 * BASES
        BANK
 * CHANGES
        25/03/2009 galina - копируем и открываем res1.xml
        18.06.2009 galina - изменила пароль и логин
        12.05.2010 galina - изменила пароль и логин
*/

def var v-batchid as integer.
form v-batchid label "Номер пакета" format ">>>>>>>>>>>9" help "Введите номер пакета" with centered frame fbatch title 'НОМЕР ПАКЕТА'.
update v-batchid with frame fbatch.
unix silent value ("cb1pump.pl -login=MBuser37 -password=Nastya2211 -method=GetBatchStatus2 -batchid=" + string(v-batchid) + " > res1.xml").
unix silent value("cptwin res1.xml iexplore").
unix silent value("rm -f res1.xml").