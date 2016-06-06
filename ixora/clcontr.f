/* clcontr.f
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Форма настройки списка контролеров
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        9-2-3-6, 4-3-7
 * AUTHOR
        08.09.2003 nadejda
 * CHANGES
*/

/*
function chkcod returns logical (p-value as char).
  def var i as integer.

  if p-value = "" then return false.

  if index (p-value, ".") > 0 or index (p-value, ",") > 0 then return false.

  i = integer (p-value) no-error.
  if error-status:error then return false.

  return true.
end.
*/

form
     t-con.ofc
       validate (can-find (ofc where ofc.ofc = t-con.ofc no-lock), " Нет такого офицера!")
       help " Офицер-контролер (F2 - поиск)"
     t-con.name 
     t-con.depart 
     t-con.deps
       help " ДА - контроль только своего департамента, НЕТ - любого"
     with row 5 centered scroll 1 12 down frame f-ed .
