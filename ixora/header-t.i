/* header-t.i
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
        19/04/2005 madiar - поменял WORKFILE на TEMP-TABLE
        02.02.10 marinav - расширение поля счета до 20 знаков
*/

DEFINE {1} TEMP-TABLE t-header
     FIELD name  AS CHARACTER FORMAT "x(10)"
     FIELD chval AS CHARACTER INITIAL ?
     FIELD inval AS INTEGER   INITIAL ?
     FIELD dval  AS DATE      INITIAL ?
INDEX name_idx IS PRIMARY UNIQUE name ASCENDING.

DEFINE {1} VARIABLE b_start AS DATE.
DEFINE {1} VARIABLE a_start AS DATE.
DEFINE {1} VARIABLE b_end   AS DATE.

DEFINE {1} VARIABLE st-today AS DATE.

if "{1}" = "new shared" then do transaction:

find first bank.jl use-index jdt no-lock no-error.
if available bank.jl then b_start = bank.jl.jdt.
find bank.sysc where bank.sysc.sysc eq "BEGDAY" no-lock no-error.
if available bank.sysc and bank.sysc.daval lt b_start 
then b_start = sysc.daval.

/* !!!!!!!!!!!! only for test !!!!!!!!!!!!!!!!!!!!!!! */
/*
DEFINE {1} TEMP-TABLE arcmap
    FIELD d_from as date format "99/99/9999"
    FIELD d_to as date format "99/99/9999"
    FIELD host as char format "X(8)"
    FIELD path as char format "X(40)"
    FIELD server as log
    FIELD service as char format "X(8)"
    FIELD servnum as int format "99999".
*/

/* !!! only for test on base without arcmap file !!! */

find first bank.arcmap  no-lock no-error. 
if available bank.arcmap then a_start = bank.arcmap.d_from. 
   else a_start = b_start.

find last bank.jl use-index jdt no-lock no-error.
if available bank.jl then b_end = bank.jl.jdt.

create t-header.
       t-header.name = "h-cif".
create t-header.
       t-header.name = "h-bankaddr".
create t-header.
       t-header.name = "h-bankname".
create t-header.
       t-header.name = "h-bankreg".
create t-header.
       t-header.name = "h-custaddr".
create t-header.
       t-header.name = "h-custboss".
create t-header.
       t-header.name = "h-custname".
create t-header.
       t-header.name = "h-custreg".
create t-header.
       t-header.name = "h-d_from".
create t-header.
       t-header.name = "h-d_to".
create t-header.
       t-header.name = "h-phone".
create t-header.
       t-header.name = "h-repname".
create t-header.
       t-header.name = "h-repnr".
create t-header.
       t-header.name = "h-whn".
create t-header.
       t-header.name = "h-time".
create t-header.
       t-header.name = "h-who".

/* --- Footer --- */

create t-header.
       t-header.name = "e-sign".
create t-header.
       t-header.name = "ftitle".

end.

/* Page Formatter's Variables --- */

DEFINE {1} VARIABLE rows         AS INTEGER.
DEFINE {1} VARIABLE cols         AS INTEGER.
DEFINE {1} VARIABLE row_in_page  AS INTEGER.
DEFINE {1} VARIABLE new_page     AS LOGICAL.
DEFINE {1} VARIABLE new_acc      AS LOGICAL.
DEFINE {1} VARIABLE balance_mode AS LOGICAL.
DEFINE {1} VARIABLE page_num     AS INTEGER.
DEFINE {1} VARIABLE total_page   AS INTEGER.
DEFINE {1} VARIABLE frmt         AS CHARACTER.
DEFINE {1} VARIABLE margin	 AS INTEGER.

DEFINE {1} VARIABLE t1      	 AS CHARACTER.
DEFINE {1} VARIABLE t2      	 AS CHARACTER.
DEFINE {1} VARIABLE tcrc      	 AS CHARACTER.

DEFINE {1} VARIABLE formfeed     AS logical.

DEFINE {1} VARIABLE v-codfr    	 AS CHARACTER.
DEFINE {1} VARIABLE lang-code    AS INTEGER.

DEFINE {1} VARIABLE branch 	 AS CHARACTER.

DEFINE {1} VARIABLE intermbal    AS DECIMAL   DECIMALS 2 FORMAT "->>,>>>,>>>,>>>,>>9.99" LABEL "Internediary Balance".

DEFINE {1} VARIABLE a_mode       AS LOGICAL INITIAL no.

/* ------------------  Account List -------------------- */

DEFINE {1} TEMP-TABLE acc_list
           FIELD aaa  as char format "X(20)"
           FIELD d_from as date
           FIELD d_to   as date 
           FIELD crc as integer
           FIELD lgr  as char format "X(3)"
           FIELD hbal as decimal format "-z,zzz,zzz,zzz,zz9.99"
           FIELD craccnt as char format "X(10)"
	   FIELD stmsts  AS CHARACTER
           FIELD seq     AS DECIMAL
           field debit as decimal
           field credit as decimal.

/* ----------------- Codificator Details --------------- */

DEFINE {1} TEMP-TABLE trx_codes
         FIELD code AS CHARACTER
         FIELD name AS CHARACTER.

DEFINE {1} TEMP-TABLE s-hi 
       FIELD rec_id AS RECID.

