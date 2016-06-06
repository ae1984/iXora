/* ibplm4.p
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
*/

/* ibplm4.p
Модуль:
            Платежная система
Назначение: 
            Контроль кодового слова платежа Интернет-офиса
Вызывается: 
            er_3a_ps.p
Пункты меню: 
            5.2.8
Автор: 
            PRAGMA
Дата создания:
            PRAGMA
Протокол изменений:
            30.07.2003 sasco Переделал на вызов ibplm4a, где фраза подтянется сама
            06.08.03 marinav Добавлена проверка на льготного клиента t11074

*/                                        

/*
run connib.
run ibchkkey.
disconnect "ib".
*/

define shared variable s-remtrz like remtrz.remtrz.

run connib.
run ibplm4a.
disconnect "ib".

/*************/
find remtrz where remtrz.remtrz = s-remtrz no-lock no-error.
  if avail remtrz and remtrz.fcrc > 1 then do:
   find aaa where aaa.aaa = remtrz.dracc no-lock no-error.
     if avail aaa and aaa.cif = 't11074' then
          message skip " Проверьте комиссии для льготного клиента"   skip(1)
           view-as alert-box button Ok title "Внимание!".
  end.

/**************/
