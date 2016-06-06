/* pushshow.p
 * MODULE
        PUSH-отчеты
 * DESCRIPTION
        Просмотр готового отчета
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
{push.i}

def query qt for pushrun.
def browse bt query qt
           displ pushrun.d column-label "День" label "День"
                 pushrun.m column-label "Месяц" 
                 pushrun.y column-label "Год" 
                 pushrun.q column-label "Квартал" 
                 pushrun.rdt column-label "Сформирован" 
            with row 1 centered 12 down title "Выберите существующий отчет".
def frame ft bt help "ENTER - просмотр, F4 - выход" with row 3 centered no-label no-box.
                 
on "return" of browse bt do:
   if not avail pushrun then leave.
   if SEARCH (pushrun.fname) = ? then do:
      message "Не найден файл " + pushrun.fname view-as alert-box title "Ошибка".
      leave. 
   end.
   if not yes-no ("ВНИМАНИЕ", "Просмотреть отчет?") then leave.
   unix silent value ("cptwin " + pushrun.fname + " excel").
end.

open query qt for each pushrun where pushrun.id = vid no-lock.
enable all with frame ft.
wait-for window-close of frame ft focus browse bt.


