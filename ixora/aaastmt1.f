/* aaastmt1.f
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



form header
  skip(2)
  cmp.name    at 44 skip
  cmp.addr[1] at 44 skip
  cmp.addr[2] at 44 skip
  cmp.addr[3] at 44 skip
  cmp.tel     at 44 skip(3)
  cifname at 5    lgr.des at 44 skip
  cif.jame at 5     skip
  cif.addr[1] at 5 "ACCOUNT NUMBER" at 44 aaa.aaa " (" crc.code ")" skip
  cif.addr[2] at 5 "STATEMENT AS OF" at 44 tdt skip
  cif.addr[3] at 5 skip
  skip(1)
  fill("_",80) format "x(80)" skip(1)
  with frame pagetop no-box no-label page-top width 96.
else

form header
  skip(2)
  cmp.name    at 44 skip
  cmp.addr[1] at 44 skip
  cmp.addr[2] at 44 skip
  cmp.addr[3] at 44 skip
  cmp.tel     at 44 skip(3)
  cifname at 5    lgr.des at 44 skip
  cif.addr[1] at 5  "ACCOUNT NUMBER" at 44 aaa.aaa skip
  cif.addr[2] at 5 "STATEMENT AS OF" at 44 tdt skip
  cif.addr[3] at 5  skip
  skip(1)
  fill("_",80) format "x(80)" skip(1)
  with frame pagetop2 no-box no-label page-top width 96.
