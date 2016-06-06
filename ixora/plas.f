/* plas.f
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
**  Program: plat.f
**       By:
** Descript:
**
*****************************************************************************
\***************************************************************************/

FORM
  SPACE (18)
  "MEMORI…LAIS ORDERIS  Nr."  pla.nmb  "  DATUMS:" pla.regdt  SKIP(1)
  "                                                  DEBETS  " SKIP
  "MAKS…T." pla.ma1 "Knt." at 47 pla.rs1  SKIP
  "       " pla.ma2 "Knt." AT 47 pla.rs2 "    SUMMA" SKIP(0)
  " BANKA:" pla.ba1 "KODS:" AT 47 pla.kb2  pla.code at 69 SKIP
  "       " pla.ba2  pla.summ at 58 SKIP
  "                                                   KRED§TS "  SKIP
  " SAјEM." pla.sa1  "Knt." AT 47 pla.rs3   SKIP
  "       " pla.sa2  "Knt." AT 47 pla.rs4   SKIP
  " BANKA:" pla.ba3  "KODS:"  AT 47 pla.kb4 SKIP
  "       " pla.ba4     SKIP
  "VEIDS:" AT 50 pla.ve "  MЁRґIS:"  pla.me SKIP
  "APRAKSTS:" SKIP
  pla.ap[1] SKIP
  pla.ap[2] SKIP
  pla.ap[3] SKIP
  pla.ap[4] SKIP
  pla.ap[5]

  /*
  123456789012345678901234567890123456789012345678901234567890123456789012345
  */

  WITH  /* overlay RAW 3 */ NO-LABEL NO-BOX FRAME plat no-hide.
