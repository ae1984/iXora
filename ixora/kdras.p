/* s-lnrska.p
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
        30/04/2004 madiar - Просмотр клиентов филиалов в ГБ
      30.09.2005 marinav - изменения для бизнес-кредитов
    05/09/06   marinav - добавление индексов
*/

/* Кредитные риски 
   Внесение и редактирование баланса по активу 
   26.07.02 */

{global.i}
{kd.i}

if s-kdcif = '' then return.

find kdcif where kdcif.kdcif = s-kdcif and (kdcif.bank = s-ourbank or s-ourbank = "TXB00") 
     no-lock no-error.

if not avail kdcif then do:
  message skip " Клиент N" s-kdcif "не найден !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.


define var v-sel as char.
define var v-sel1 as char.

  run uni_book ("kdbk", "*", output v-sel).
  v-sel = entry(1, v-sel).


  run sel ("Выбор :", 
           " 1. Создать новый | 2. Редактировать существующий | 3. Выход").
  v-sel1 = return-value.

  case v-sel1:     
    when "1" then
      if s-ourbank <> kdcif.bank then return.
      else run s-lnrskz (v-sel1, v-sel).
    when "2" then
      if s-ourbank <> kdcif.bank then return.
      else run s-lnrskz (v-sel1, v-sel).
    when "3" then return.
  end case.

