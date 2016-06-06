/* pipl.p
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
        1-1-2 меню Вноситель
 * BASES
        BANK COMM
 * AUTHOR
        10/02/2006 dpuchkov
 * CHANGES
        31.08.2012 evseev - иин/бин
*/



def shared var s-cif as char.




  def frame pip
    pipl.cif   format "x(6)"     label  "CIF - клиента       " skip
    pipl.name  format "x(50)"    label  "Наименование        "    skip
    pipl.jss   format "x(12)"    label  "Номер ИИН           " /* validate (tmp_acvolt.cellsize = "Маленькая" or tmp_acvolt.cellsize = "Средняя" or tmp_acvolt.cellsize = "Большая", "Неверный тип. Используйте - F2 для выбора ") */ skip
    pipl.passp format "x(12)"    label  "Номер удост личности" skip
    pipl.pasdt                   label  "Дата удост личности " skip
    pipl.pasplase format "x(15)" label  "Место выдачи        " skip
    pipl.stats format "x(11)"    label  "Статус вносителя    " validate (pipl.stats = "Родитель" or pipl.stats = "Усыновитель" or pipl.stats = "Опекун" or pipl.stats = "Третье лицо", "Неверный тип. Используйте - F2 для выбора ") help "F2-для выбора"
  with side-labels centered row 6.


on help of pipl.stats in frame pip do:
   run sel ("Выберите статус", "Родитель|Усыновитель|Опекун|Третье лицо").
   if int(return-value) = 1 then pipl.stats = "Родитель".
   if int(return-value) = 2 then pipl.stats = "Усыновитель".
   if int(return-value) = 3 then pipl.stats = "Опекун".
   if int(return-value) = 4 then pipl.stats = "Третье лицо".
   displ pipl.stats with frame pip.
end.



   find last pipl where pipl.cif = s-cif exclusive-lock no-error.
   if avail pipl then do:
      displ   pipl.cif  with frame pip.
      update  pipl.name pipl.jss pipl.passp pipl.pasdt pipl.pasplase pipl.stats with frame pip.
   end.
   else do:
       create pipl.
              pipl.cif = s-cif.
              displ   pipl.cif  with frame pip.
              update  pipl.name pipl.jss pipl.passp pipl.pasdt pipl.pasplase pipl.stats with frame pip.
   end.