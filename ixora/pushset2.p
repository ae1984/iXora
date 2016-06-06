/* pushset2.p
 * MODULE
        PUSH-отчеты
 * DESCRIPTION
        Настройка получателей PUSH отчетов
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

def buffer bufofc for pushofc.

def query qt for pushofc.
def browse bt query qt
           displ pushofc.ofc
                 pushofc.email format 'x(30)'
                 /* pushofc.host
                 pushofc.path */
                 with row 1 10 down centered title "Получатели".
def frame ft bt help "ENTER - редактирование, F1 - новый, F8 - удалить".

def frame fedit 
          bufofc.ofc
          bufofc.email format 'x(30)'
          bufofc.host
          bufofc.path 
          with row 4 1 column centered overlay title "Редактирование".

on "return" of browse bt do:
   if not avail pushofc then leave.
   find bufofc where rowid (bufofc) = rowid (pushofc) no-error.
   if not avail bufofc then leave.
   displ bufofc with frame fedit. pause 0.
   update bufofc with frame fedit.
   browse bt:refresh().
end.
                         
on "go" of browse bt do:
   if not yes-no ("", "Добавить получателя?") then leave.
   create bufofc.
   update bufofc with frame fedit.
   if not yes-no ("", "Сохранить?") then do:
      delete bufofc.
      leave.
   end.
   close query qt.
   open query qt for each pushofc no-lock.
   browse bt:refresh().
end.
                         
on "clear" of browse bt do:
   if not avail pushofc then leave.
   if not yes-no ("", "Удалить получателя?") then leave.
   find bufofc where rowid (bufofc) = rowid (pushofc) no-error.
   if not avail bufofc then leave.
   delete bufofc.
   close query qt.
   open query qt for each pushofc no-lock.
   if can-find (first bufofc) then browse bt:refresh().
end.
                         
open query qt for each pushofc no-lock. 
enable all with frame ft.
wait-for window-close of current-window focus browse bt.

