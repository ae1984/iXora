/* data_remove.p
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

/*=================================================================================
=                                                                                                                                             =
=                                           Data Remove Utility                                                                       =
=                              VKR System by Andrey Popov, April 1998                                                    =
=                                                                                                                                             =
==================================================================================*/
{vkr_lib.i}

     
define input parameter i_jh             as integer.                /* Transaction Reference */
define input parameter i_jl             as integer.	       /* Transacton Line    */
define input parameter i_date		as date.		/* TRX Date */
define input parameter i_acc		like wood.account.	/* TRX Account */
define input parameter in_trx_type	as integer.		/* TRX Type */

do transaction:

find wood where wood.jh = i_jh and 
                wood.jl = i_jl and
                wood.date = i_date and
                wood.trx_type = in_trx_type  exclusive-lock no-error.
   if available wood then do:
        run h_w ( integer(recid(wood)), "delete", ? , wood.reference , ?, g-ofc).
        run event_rgt ( "DataRem", "Delete", wood.account, string(i_jh) + "-" + string(i_jl), g-ofc,"Deal Entry removed " + string(wood.date) + ".").
        delete wood.
   end.
   else 
        run event_rgt ( "DataRem", "Delete", "", string(i_jh) + "-" + string(i_jl), g-ofc,"Not found deal entry with trx" ). 
end.         


