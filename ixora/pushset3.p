/* pushset3.p
 * MODULE
        PUSH-отчеты
 * DESCRIPTION
        Привязка PUSH отчетов к отдельным получателям
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT

 * MENU
        
 * AUTHOR
        25/07/05 sasco
 * CHANGES
*/

{global.i}
{push.i "new"}
{yes-no.i}

def buffer buford for pushord.

def query qt for pushord.
def browse bt query qt
           displ pushord.id
                 pushord.ofc 
                 pushord.oper
                 with row 1 10 down centered title "Отчеты".
def frame ft bt help "ENTER - редактирование, F1 - новый, F8 - удалить".

def frame fedit 
          buford.id help "F2 - выбор"
          buford.ofc
          buford.oper
          with row 4 1 column centered overlay title "Редактирование".

on "help" of buford.id in frame fedit run help-pushid.

on "return" of browse bt do:
   if not avail pushord then leave.
   find buford where rowid (buford) = rowid (pushord) no-error.
   if not avail buford then leave.
   displ buford with frame fedit. pause 0.
   update buford with frame fedit.
   browse bt:refresh().
end.
                         
on "go" of browse bt do:
   if not yes-no ("", "Добавить отчет?") then leave.
   create buford.
   update buford with frame fedit.
   if not yes-no ("", "Сохранить?") then do:
      delete buford.
      leave.
   end.
   close query qt.
   open query qt for each pushord no-lock.
   browse bt:refresh().
end.
                         
on "clear" of browse bt do:
   if not avail pushord then leave.
   if not yes-no ("", "Удалить отчет?") then leave.
   find buford where rowid (buford) = rowid (pushord) no-error.
   if not avail buford then leave.
   delete buford.
   close query qt.
   open query qt for each pushord no-lock.
   if can-find (first buford) then browse bt:refresh().
end.
                         
open query qt for each pushord no-lock. 
enable all with frame ft.
wait-for window-close of current-window focus browse bt.

