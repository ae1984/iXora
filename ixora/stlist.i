/* stlist.i
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

/* 02/07/98 workfile definition for table deals */
/* {1} = "", "NEW" or "NEW SHARED" */
/* {2} = "" or "NO-UNDO" */

DEFINE {1} temp-table stml 
  FIELD aaa      AS CHARACTER
  FIELD seq           AS DECIMAL
  FIELD d_from   AS DATE
  FIELD d_to     AS DATE
  FIELD sts      AS CHARACTER
  FIELD who      AS CHARACTER
  FIELD whn      AS DATE
  FIELD sq       AS INTEGER EXTENT 2
  FIELD active         AS character
  INDEX intrf_idx  aaa ASCENDING seq DESCENDING d_from DESCENDING d_to DESCENDING
  INDEX common_idx IS PRIMARY aaa ASCENDING seq ASCENDING d_from ASCENDING d_to ASCENDING.

define buffer m-stml for stml.
def var isolda as logical.  
  
