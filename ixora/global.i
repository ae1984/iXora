/* global.i
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
        27/04/2009 madiyar - при каждой отработке global.i читаем g-today из cls
*/

/* global.i
   03-17-88 created by Simon Y. Kim
   04-22-89 add g-bra by Walter Rim
*/

define {1} shared var g-lang   as cha.
define {1} shared var g-crc    like crc.crc.
define {1} shared var g-ofc    like ofc.ofc.
define {1} shared var g-proc   like nmenu.proc.
define {1} shared var g-fname  like nmenu.fname.
define {1} shared var g-mdes   like nmdes.des.
define {1} shared var g-today  as date.
define {1} shared var g-comp   like cmp.name.
define {1} shared var g-dbdir  as cha. /* Database Directory */
define {1} shared var g-dbname as cha. /* Database Name */
define {1} shared var g-cdlib  as log.
define {1} shared var g-browse as cha.
define {1} shared var g-editor as cha.
define {1} shared var g-pfdir  as cha.
define {1} shared var g-permit as int.

define {1} shared var g-lprpt  as cha. /* LP command for rpt */
define {1} shared var g-lplab  as cha. /* LP command for label */
define {1} shared var g-lplet  as cha. /* LP command for letter */
define {1} shared var g-lpstmt as cha. /* LP command for statement */
define {1} shared var g-lpvou  as cha. /* LP command for voucher */

define {1} shared var g-labfmk as cha. /* Form Lable Program */
define {1} shared var g-stmtmk as cha. /* Form Statement Program */
define {1} shared var g-letfmk as cha. /* Form Letter Program */

define {1} shared var g-bra    as int.

{2}

define {1} shared variable g-basedy like sysc.inval.
/*
define {1} shared variable g-prnvou like sysc.chval.
define {1} shared variable g-prnrpt like sysc.chval.
define {1} shared variable g-lprhdr like sysc.chval.
define {1} shared variable g-lprtrr like sysc.chval.
*/
define {1} shared variable g-tty    as int.
define {1} shared variable g-lty    as int.
define {1} shared variable g-aaa    like aaa.aaa.
define {1} shared variable g-cif    like cif.cif.
define {1} shared variable g-batch  as log initial false.
define {1} shared variable g-defdfb as cha. /* Default DFB */
define {1} shared variable g-inc    as int.

define {1} shared variable h-rec as recid.
define {1} shared variable l-rec as recid.

define {1} shared variable vmgrp as cha.

define variable nday as int.

define {1} shared variable g-trxby as character format "x(10)" extent 3 initial
  ["[By SWIFT]","[By Telex]","[By Mail]"].

find last cls no-lock no-error.
if available cls then g-today = cls.cls + 1.
