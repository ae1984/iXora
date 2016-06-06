/* set_hold.p
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

/*==========================================================================
=                                                                          =
=                   Hold Balance Setting Utility                           =
=              VKR System by Andrey Popov April 1998.                      =
=                                                                          =
==========================================================================*/                                                                 

{vkr_lib.i}

define input parameter rec_id as recid.       /* AAS Record ID    */ 

define variable n_account like wood.account.	/* Customers Account */
define variable sh_active_group as integer.

find first aas where recid(aas) = rec_id no-lock no-error.

if not available aas then return.

run checker ( " ", aas.aaa, " " ,aas.payee, 0 , output sh_active_group ).
n_account = return-value.

if n_account = "" or n_account = ? or n_account = "1"  then do:
   run event_rgt ( "SetHold", "Hold Add.", n_account, string(aas.aaa) + "-" + string(aas.ln), g-ofc,"Checker Error").
      return "1".
end.

do transaction:

find first hold where hold.aas_aaa = aas.aaa and
                      hold.aas_ln = aas.ln exclusive-lock no-error.
                       
 if not available hold then do:
    create hold.
     hold.account = n_account.
     hold.aas_aaa = aas.aaa.
     hold.aas_ln  = aas.ln.
     hold.savedate = today.
     hold.savetime = time.
     run event_rgt ( "SetHold", "Hold Add.", n_account, string(aas.aaa) + "-" + string(aas.ln), g-ofc,"Hold Added").
 end.
  else 
    do:
      hold.account = n_account.
      hold.savedate = today.
      hold.savetime = time.
      run event_rgt ( "SetHold", "Acc. Chng.", n_account, string(aas.aaa) + "-" + string(aas.ln), g-ofc,"Hold SubAccount Changed"). 
    end. 

end. 
return.                          
