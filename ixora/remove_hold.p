/* remove_hold.p
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
=                   Hold Balance Remove Utility                            =
=              VKR System by Andrey Popov April 1998.                      =
=                                                                          =
==========================================================================*/                                                                 

{vkr_lib.i}

define input parameter aas_aaa like aas.aaa.
define input parameter aas_ln  like aas.ln.
define input parameter aas_det like aas.payee. 

define variable n_account like wood.account.	/* Customers Account */


do transaction:

find first hold where hold.aas_aaa = aas_aaa and
                      hold.aas_ln = aas_ln exclusive-lock no-error.
                       
 if not available hold then do:
     run event_rgt ( "RemoveHold", "Remove Add.", aas_det, string(aas_aaa) + "-" + string(aas_ln), g-ofc,"Can not find hold record ...").      
 end.
  else do:
     delete hold.
     run event_rgt ( "RemoveHold", "Remove Add.", aas_det, string(aas_aaa) + "-" + string(aas_ln), g-ofc,"Hold Removed ..."). 
  end.  

end. 

return. 
                         
