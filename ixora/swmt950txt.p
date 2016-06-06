/* swmt950txt.p
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

 * CHANGES
            18/04/2012 Luiza
*/



define input parameter in_cif like cif.cif.        /* Customer's CIF         */
define input parameter in_account like aaa.aaa.        /* Customer's Account         */
define input parameter in_date_from   as date.        /* Period Begin                */
define input parameter in_date_to  as date.        /* Period End                */
define input parameter in_format as character.        /* Report Format         */
define input parameter in_destination as character.        /* Report Name / Destination */
define input parameter in_command  as character.        /* Output Command         */
define input parameter in_stmsts   as character.   /* Report Status */

define shared variable g-comp AS character.
define shared variable g-today as date.
define shared variable g-batch as logical.
define shared variable g-ofc   like ofc.ofc.

define variable partkom as character.  /* Printing CommandLine */
define variable bar as character.
define variable msg as character.
define variable prt as logical initial no.

def var hostmy   as char format 'x(15)'.
def var ipaddr   as char format 'x(15)'.
def var dirc     as char format 'x(15)'.

dirc = 'c:/vipiski'.
define shared var g-fname like nmenu.fname.

/* Temporary Tables & Shared Variables Structure Defining -------------- */

{header-t.i "shared" }
{deals.i    "new shared" }
{wkdef.i    "shared" }

/* --- Checking for available information for period ------------------ */

form
    bar format "x(18)"
with no-label no-box row 20 column 2 frame q.

if ( in_date_from < a_start ) or
   ( in_date_to < in_date_from ) or
   ( in_date_to > g-today ) then do:
   run elog("STGENP","ERR", "Not available date periods. Terminated.").
   if g-batch = false then pause 10 message "Nav pieejamais izraksta par periodu".
   return "1".
end.


/* --- Data Generator Executing ---------------------------------------- */

/* ... Format Extracting ............................................... */

 integer(in_format) no-error.

 if NOT ERROR-STATUS:ERROR then do:

 if integer(in_format) > 0 then do:

    find first ofc where ofc.ofc = g-ofc no-lock no-error.

      if available ofc then do: /* ... first ( common ) mode ... */
            define variable i as integer.
            do i = 1 to 6:
              if integer(in_format) = i then do:
              /*if integer(in_format) = ( i * 8 - 7 ) then do:*/
                 in_format = substring(ofc.expr[4], ( i * 8 - 7 ) , 8).
                 leave.
              end.
            end.
      end.
 end.
 end.


/* ..................................................................... */

 find first stformat where stformat.fid = in_format no-lock no-error.
    if not available stformat then
      find first stformat where stformat.fid = "dft" no-lock no-error.

 if not available stformat then do:
    run elog("STGENP","ERR", "Not found statement format " + in_format + ". Terminated.").
    return "1".
 end.

 formfeed = stformat.formfeed.  /* Form Feed Sequence         */
 cols = stformat.cols.                /* Page Size: Columns        */
 rows = stformat.rows.                /* Page Size: Rows        */
 v-codfr = stformat.codfr.        /* Format Codificator        */
 margin = stformat.margin.      /* Left Margin                */

 if stformat.executor = ? or stformat.executor = "" then do:
    run elog("STGENP","ERR", "Unknown executor for format " + in_format + ". Terminated.").
    return "1".
 end.


 branch = "".

 find first sysc where sysc.sysc = "OURBNK" no-lock.
 if available sysc then do:
    if trim(sysc.chval) = "RKB00" then branch = "Centralais Ofiss".
    else do:
    find first bankl where trim(bankl.bank) = trim(sysc.chval) no-lock no-error.
      if available bankl then do:
         branch = lc(trim(substring(bankl.name, 5))).
         substring(branch,1,1) = caps(substring(branch,1,1)).
      end.
    end.
 end.



 run value(stformat.executor)(in_cif, in_account, in_date_from, in_date_to, in_stmsts).



 if return-value = "1" then do:
    run elog("STGENP","ERR", "Data Generator execution not completed. Terminated.").
    return "1".
 end.
run swmt950s(in_destination,in_account,in_date_from).
return.

