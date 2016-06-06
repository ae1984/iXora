/* aaastmt.p
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

/* aaastmt.p
   PRINT ACCOUNT STATEMENT
*/

{mainhead.i CFSTPR}  /* PRINT ACCOUNT STATEMENT */

define new shared var s-aaa like aaa.aaa.
define var staaa like aaa.aaa initial "ALL".
define var vinter as log label "INTERIM".
define var vtitle1 as cha form "x(132)".

{image1.i stmt.img}
update staaa with row 7 centered side-label no-box frame opt.
{image2.i}

for each aaa use-index aaa
  where
  (staaa eq "ALL" or aaa.aaa eq staaa)
  and aaa.pass eq ""
		     and (aaa.sta ne "C" or aaa.mdr[1] ne aaa.dr[1]
		     or aaa.mcr[1] ne aaa.cr[1])
     ,each lgr of aaa where lgr.led eq "DDA" or lgr.led eq "SAV"
     break by aaa.crc by aaa.aaa:
    s-aaa = aaa.aaa.
    if vinter eq true
      then run s-aaasti.
      else run s-aaast.
  end. /* aaa */
{image3.i}
