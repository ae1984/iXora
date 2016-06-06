﻿/* plasr.f
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

/***************************************************************************\
*****************************************************************************
**  Program: platr.f
**       By:
** Descript:
**
*****************************************************************************
\***************************************************************************/

FORM
  SPACE (18)
  "МЕМОРИАЛЬHЫЙ  ОРДЕР   # "   pla.nmb  "  ДАТА:" pla.regdt  SKIP(1)
  "                                                  ДЕБЕТ   " SKIP
  "ПЛАТЕЛ." pla.ma1 "Счт." AT 47 pla.rs1 SKIP
  "       " pla.ma2 "Счт." AT 47 pla.rs2 "  СУММА" SKIP(0)
  "  БАНК:" pla.ba1 " КОД:" AT 47 pla.kb2  pla.code at 69 SKIP
  "       " pla.ba2  pla.summ  at 58 SKIP
  "                                                   КРЕДИТ  "  SKIP
  "ПОЛУЧАТ" pla.sa1  "Счт." AT 47 pla.rs3  SKIP
  "       " pla.sa2  "Счт." AT 47 pla.rs4   SKIP
  "  БАНК:" pla.ba3  " КОД:"  AT 47 pla.kb4 SKIP
  "       " pla.ba4     SKIP
  "ОПЕР.:" AT 50 pla.ve "  ЦЕЛЬ:"  pla.me SKIP
  "ОПИСАНИЕ:" SKIP
  pla.ap[1] SKIP
  pla.ap[2] SKIP
  pla.ap[3] SKIP
  pla.ap[4] SKIP
  pla.ap[5]

  /*
  123456789012345678901234567890123456789012345678901234567890123456789012345
  */

  WITH  /* overlay RAW 3 */ NO-LABEL NO-BOX FRAME platr no-hide.
