/* pushview.p
 * MODULE
        PUSH-отчеты
 * DESCRIPTION
        Просмотр отчетов
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT

 * MENU
        
 * AUTHOR
        28/03/05 sasco
 * CHANGES
        31/03/05 sasco Оптимизировал блок транзакции (добавил do transaction...)
*/


{mainhead.i}
{yes-no.i}
{push.i "new"}

def temp-table temprep like pushrep.

def query qt for temprep.
def browse bt query qt
           displ temprep.id label "ID" format "zz9"
                 temprep.des label "Описание" format "x(50)"
            with row 1 centered 12 down title "Выберите отчет".
def frame ft bt help "ENTER - просмотр, F4 - выход" with row 3 centered no-label no-box.
                 
on "return" of browse bt do:
   if not avail temprep then leave.
   if not yes-no ("ВНИМАНИЕ", "Просмотреть отчет~n" + temprep.des) then leave.
   vid = temprep.id.
   run pushshow.
end.

for each pushrep no-lock:
    if can-find (first pushord where pushord.id = pushrep.id and pushord.ofc = g-ofc) then do:
       create temprep.
       buffer-copy pushrep to temprep.
    end.
end.

open query qt for each temprep.
enable all with frame ft.
wait-for window-close of frame ft focus browse bt.

