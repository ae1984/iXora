/* dcls7.p
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
        16.02.2004 marinav - закрытие тех овердрафтов (перенесено из dcls17)
        24.05.2005 sasco   - переделал поиск и закрытие тех овердрафтов, чтобы не трогать aaa.svc
*/

/* ======================================================================
=                                                                         =
=        Valsts Kase Sub Account -> Main Account Money Transfer                =
=                                                                          =
====================================================================== */

{vkr_lib.i}

define variable rcode        as inte.
define variable rdes         as char.
define variable vdel         as char initial "^".
define variable vend         as char initial "&&&".
define variable vparam         as char.
define variable vjh         as inte.
define variable i         as inte.
define variable vtim         as inte.

define variable acc_quan         as integer initial 0.

define variable vbal                like jl.dam.
define variable vavl                like jl.dam.
define variable vhbal                like jl.dam.
define variable vfbal                like jl.dam.
define variable vcrline                like jl.dam.
define variable vcrlused        like jl.dam.
define variable vooo                like aaa.aaa.

define variable my_account         like wood.account.

/* ---------- Select of Sub Account still opened in the Platon ----------- */

for each tree where tree.acctype = "S" and
                    tree.grp = 1       and
              ( length(tree.account) = 10 or tree.old_acc <> "no" )  no-lock.

    if tree.old_acc = "" or tree.old_acc = ? or tree.old_acc = "no" then my_account = tree.account.
       else
         my_account = tree.old_acc.

    /* --- Checking of account presenting in aaa ------------------ */

    find aaa where aaa.aaa = my_account exclusive-lock no-error.

    if not available aaa then do:
       run event_rgt ( "DCloseMT", "ChkAcc", tree.account, "", g-ofc, "Not aaa Account. Skipped ...").
       next.
    end.

    run aaa-bal777(aaa.aaa, output vbal, output vavl, output vhbal,
                   output vfbal, output vcrline, output vcrlused, output vooo).

  if vavl >  0 then do:

    /* --- Checking of ancestor presenting in aaa ------- */

    find aaa where aaa.aaa = tree.ancestor exclusive-lock no-error.

    if not available aaa then do:
       run event_rgt ( "DCloseMT", "ChkAcc", tree.ancestor, "", g-ofc, "Ancestor is not aaa Account. Skipped ...").
       next.
    end.

    /* --- Checking of balances of accounts ------------- */

    acc_quan = acc_quan + 1.

    vparam = vparam + vdel
              + string(vavl) + vdel
                  + my_account + vdel          /* -- Debit Account  ------- */
                     + tree.ancestor + vdel        /* -- Credit Account ------- */
              + "/" + tree.prefix + " " + mt_prefix.

    run event_rgt ( "DCloseMT", "ParamCreate", my_account, tree.ancestor, g-ofc, "Added Transfer Line of " + trim(string(vavl,">>>,>>>,>>>,>>9.99")) ) .

  end. /* if vavl > 0 ... */

end.  /* for each tree where ... */

vparam = string(acc_quan) + vparam.

vjh = 0.

if acc_quan > 0 then do:

        run trxgen("dcl0001",vdel, vparam, output rcode, output rdes, input-output vjh).

        run event_rgt ( "DCloseMT", "TRXGEN", "dcl00001", string(vjh), g-ofc, "Transaction Completed with error code = " + string(rcode) + " and error description: " + rdes ).
end.



/* 16.02.2004 marinav */
/* 05.03.2011 k.gitalov счета в кэшпулинге не трогать!!!
for each lgr where lgr.led eq "ODA" no-lock:
  c-aaa:
  for each aaa of lgr :
    /* sasco 24/05/05 - if not aaa.svc or aaa.sta = "C" then next c-aaa. */
    if aaa.opnamt = 0 or aaa.sta = "C" then next c-aaa.
    aaa.opnamt = 0.
    /* sasco 24/05/05 - aaa.svc = no.
    aaa.cbal = aaa.opnamt - aaa.dr[1] + aaa.cr[1]. */
    aaa.cbal = aaa.cr[1] - aaa.dr[1].
  end.
end.
*/