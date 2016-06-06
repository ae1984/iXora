/* stmeuro.i
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

/*  1st (Define) Include for formatter for EURO Currencies */
/*  stmeuro.i Started 28/12/1998  LAST-MO: 07/01/1999      */
/* ^^^^^^^^^^^^^^^^^^^^^^ EURO Currency Rates ^^^^^^^^^^^^^^^^^^^^^^^^^ */
def var v-euro as logical init no.
def var euroamt like aab.bal. 
def var neuroamt like aab.bal.

def var vrat1 as deci decimals 4 format "9.9999".
def var vrat2 as deci decimals 4 format "9.9999".
def var coef1 as inte.
def var coef2 as inte.
def var marg1 as deci.
def var marg2 as deci.

  v-euro = no.
  if acc_list.d_to >= 01/01/1999 then do:
  find sysc where sysc.sysc eq "EURO" no-lock no-error.
  if available sysc then do:
  find crc where crc.crc eq acc_list.crc no-lock.
  if crc.crc ne 11 and index(sysc.chval, crc.code) gt 0 then v-euro = yes.
  end.  /* if avail sysc */
  end.  /* if New Year   */
  else v-euro = no.
 
