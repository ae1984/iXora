/* pushset1.p
 * MODULE
        PUSH-отчеты
 * DESCRIPTION
        Настройка PUSH отчетов
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT

 * MENU
        
 * AUTHOR
        25/07/05 sasco
 * CHANGES
*/


{yes-no.i}

def buffer bufrep for pushrep.

def query qt for pushrep.
def browse bt query qt
           displ pushrep.id 
                 pushrep.des
                 pushrep.proc
                 with row 1 10 down centered title "Список отчетов".
def frame ft bt help "ENTER - редактирование, F1 - новый, F8 - удалить".

def var vid as int.

def frame fedit 
          bufrep.des label "Название"
          bufrep.proc label "Процедура"
          bufrep.id label "ID"
          bufrep.type label "Тип" help "d - daily, m - monthly, y - yearly"
          bufrep.oper label "Операция" help "e - email, "
          bufrep.path label "Путь к хранилищу данных"
          bufrep.host label "HOST сервера"
          bufrep.prefix label "Префикс названия файла"
          bufrep.params label "Параметры"
          with row 4 centered 1 column overlay title "Редактирование".

on "return" of browse bt do:
   if not avail pushrep then leave.
   find bufrep where rowid (bufrep) = rowid (pushrep) no-error.
   if not avail bufrep then leave.
   displ bufrep with frame fedit. pause 0.
   update bufrep except bufrep.id with frame fedit.
   browse bt:refresh().
end.
                         
on "go" of browse bt do:
   if not yes-no ("", "Добавить отчет?") then leave.
   find last bufrep no-lock use-index id no-error.
   if not avail bufrep then vid = 1.
   else vid = bufrep.id + 1.
   create bufrep.
   bufrep.id = vid.
   displ bufrep with frame fedit. pause 0.
   update bufrep except bufrep.id with frame fedit.
   if not yes-no ("", "Сохранить?") then do:
      delete bufrep.
      leave.
   end.
   close query qt.
   open query qt for each pushrep no-lock use-index id.
   browse bt:refresh().
end.
                         
on "clear" of browse bt do:
   if not avail pushrep then leave.
   if not yes-no ("", "Удалить отчет?") then leave.
   find bufrep where rowid (bufrep) = rowid (pushrep) no-error.
   if not avail bufrep then leave.
   delete bufrep.
   close query qt.
   open query qt for each pushrep no-lock.
   if can-find (first bufrep) then browse bt:refresh().
end.
                         
open query qt for each pushrep no-lock. 
enable all with frame ft.
wait-for window-close of current-window focus browse bt.

