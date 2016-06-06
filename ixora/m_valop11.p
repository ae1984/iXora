/* m_valop.p
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
 * BASES
        BANK COMM        
 * AUTHOR
        04/11/04 dpuchkov
 * CHANGES
        19/09/06 suchkov - Исправлена ошибка с неявным описанием полей
  головной модуль для валютных операций
*/



&scoped-define ShowMenu assign current-window:menubar = menu m_menu:handle.

define input parameter dnum as char.
def var dhandle as handle.
def var dhandle1 as handle.
def shared var dType as integer.
def var progs as char extent 5 initial  ["exprconv",
                                         "ordconv",
                                         "exreconv",
                                         "oreconv",
                                         "crosconv11"].


define sub-menu m_document.
   menu-item d_create label "Создать"
   menu-item d_open   label "Открыть"
   menu-item d_view   label "Просмотр"
   menu-item d_delete label "Удалить"
   menu-item d_exit   label "Выход".

define sub-menu m_inet.
/*   menu-item i_keywrd  label "Кодовое слово" */
   menu-item i_reject  label "Отказ".
   menu-item i_print   label "Печать".
            
define sub-menu m_transaction.
   menu-item t_create  label "Создать"
   menu-item t_create2 label "Вторая транзакция"
   menu-item t_delete  label "Удалить"
   menu-item t_print   label "Печать".

/*define sub-menu o_percent.
   menu-item p_add    label "Добавить/Редактировать"
   menu-item p_delete label "Удалить"
   menu-item p_view   label "Просмотр всех".*/

define sub-menu m_options.
/*  sub-menu o_percent label "Специальные тарифы".    */
    menu-item o_comms label "Комиссии".
  

define menu m_menu menubar
   sub-menu m_document     label "Документ"
   sub-menu m_inet         label "Интернет-заявки"
   sub-menu m_transaction  label "Транзакция"
   sub-menu m_options      label "Настройки".

find first dealing_doc where DocNo = dnum no-lock no-error.
if not avail dealing_doc or who_cr <> "inbank" then 
sub-menu m_inet:SENSITIVE = FALSE.
/*if avail dealing_doc and who_cr = "inbank" then*/
menu-item d_delete:SENSITIVE = FALSE.

if dType = 1 or dType = 3 then MENU-ITEM t_create2:SENSITIVE = FALSE.

/*
on choose of menu-item i_keywrd
do:
    if dealing_doc.sts ne 0 then do:
       run connib.
       run dil_iwrd(DocNo).
       if connected("ib") then disconnect "ib".
       {&ShowMenu}
    end.
end.
*/

on choose of menu-item i_reject
do:
    if dealing_doc.who_cr = "inbank" and dealing_doc.jh = ? and dealing_doc.jh2 = ? then do:
        run connib.
        run dil_irej(DocNo).
        if connected("ib") then disconnect "ib".
        {&ShowMenu}
    end.
end.

on choose of menu-item i_print
do:
    if dealing_doc.who_cr = "inbank" then do:
        run connib.
        run dil_iprt(DocNo).
        if connected("ib") then disconnect "ib".
        {&ShowMenu}
    end.
end.
                                        

on choose of menu-item d_create
do:
  if dhandle = ? 
     then do: run value(progs[dType]) persistent set dhandle.  run new_doc in dhandle. end.
     else run new_doc in dhandle.
  /*hide all.*/
end.

on choose of menu-item d_open
do:
  menu m_menu:sensitive = false.
  if dhandle = ? 
     then do: run value(progs[dType]) persistent set dhandle.  run open_doc in dhandle. end.
     else run open_doc in dhandle.
  /*hide all.*/ 
  menu m_menu:sensitive = true.
end.

on choose of menu-item d_view
do:
/*   menu m_menu:sensitive = false.*/
   sub-menu m_options:sensitive = true.
   sub-menu m_document:sensitive = false.
   sub-menu m_inet:sensitive = false.
   sub-menu m_transaction:sensitive = false.
   if dhandle = ? 
      then 
           do: 
              run value(progs[dType])  persistent set dhandle.  
              if dnum <> '' then dhandle:private-data = dnum. 
              run view_doc in dhandle. 
           end.
      else run view_doc in dhandle.
   /*hide all.*/ 
/*   menu m_menu:sensitive = true.*/
   sub-menu m_document:sensitive = true.
   sub-menu m_inet:sensitive = true.
   sub-menu m_transaction:sensitive = true.
end.

on choose of menu-item d_delete
do:
  if dhandle = ? 
     then do: run value(progs[dType]) persistent set dhandle.  run delete_doc in dhandle. end.
     else run delete_doc in dhandle.
  /*hide all.*/   
end.

on choose of menu-item d_exit
do:
  if valid-handle(dhandle) then delete procedure dhandle.
  if valid-handle(dhandle1) then delete procedure dhandle1.
end.

on choose of menu-item t_delete
do:
  if dhandle = ? 
     then do: run value(progs[dType]) persistent set dhandle.  run delete_trans in dhandle. end.
     else run delete_trans in dhandle.
  /*hide all.*/   
end.

on choose of menu-item t_create
do:
  if dhandle = ? 
     then do: run value(progs[dType]) persistent set dhandle.  run create_trans in dhandle. end.
     else run create_trans in dhandle.
  /*hide all.*/   
end.

on choose of menu-item t_create2
do:
 /* if dType = 2 then do: 
     if dhandle = ? 
        then do: run ordconv persistent set dhandle.  run create_trans2 in dhandle. end.
        else run create_trans2 in dhandle.
  end.*/
  if dhandle = ? 
     then do: run value(progs[dType]) persistent set dhandle.  run create_trans2 in dhandle. end.
     else run create_trans2 in dhandle.
     if avail dealing_doc then 
     if dealing_doc.who_cr = "inbank" and return-value = "" then 
        run dil_iacp.p(dealing_doc.DocNo).
  /*hide all.*/ 
end.


on choose of menu-item t_print
do:
   if dhandle = ? 
      then do: run value(progs[dType]) persistent set dhandle.  run print_doc in dhandle. end.
      else run print_doc in dhandle.
   clear all.
   /*hide all.*/ 
end.

on choose of menu-item o_comms
do:
   if dhandle = ? 
      then do: run value(progs[dType]) persistent set dhandle.  run edit_comms in dhandle. end.
      else run edit_comms in dhandle.
/*   clear all.
   /*hide all.*/ */
end.

/*

on choose of menu-item p_view
do:
  if dhandle1 = ? 
    then do: run perc_conv persistent set dhandle1.  run view_all in dhandle1. end.
    else run view_all in dhandle1.
  clear all.
  /*hide all.*/
end.

on choose of menu-item p_add
do:
  if dhandle1 = ? 
    then do: run perc_conv persistent set dhandle1.  run add_client in dhandle1. end.
    else run add_client in dhandle1.
  clear all.
  /*hide all.*/
end.

on choose of menu-item p_delete
do:
  if dhandle1 = ? 
    then do: run perc_conv persistent set dhandle1.  run del_client in dhandle1. end.
    else run del_client in dhandle1.
  clear all.
  /*hide all.*/
end. */


assign current-window:menubar = menu m_menu:handle.


if dnum <> '' then
                do:
                   APPLY "CHOOSE" TO menu-item d_view.
                end.  


wait-for choose of menu-item d_exit.
