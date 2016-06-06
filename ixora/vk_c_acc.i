/* vk_c_acc.i
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

/* ======================================================================
=									=
=			Closing account Processing			=
=									=
====================================================================== */




find first tree where tree.account = t_account and tree.grp = grps no-lock no-error. 
   if available tree and tree.sts = "C" then do:
        run event_rgt ( "AccChk", "Check", t_account, "", g-ofc, "Transaction on the closed account. Moved to default account : " + tree.ancestor + def_prefix  ).
        t_account = tree.ancestor + def_prefix.
        deal_sts = "new".
        find first tree where tree.account = t_account and tree.grp = grps no-lock no-error.
           if not available tree then do:
              run event_rgt ( "AccChk", "Check", t_account, "", g-ofc, "Unknown Error. Terminated." ). 	         
              return "1".  
           end.
   end.
