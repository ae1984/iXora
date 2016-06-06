/* stvar.i
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
        BANK 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
       14.04.2006 nataly перевела на базу BANK
*/

def {1} shared var g-okey    as   log.

DEF {1} SHARED VAR g-rptform LIKE txb.sthead.rptform.  
DEF {1} SHARED VAR g-source  LIKE txb.sthead.source.
DEF {1} SHARED VAR g-src     LIKE txb.sthead.source.
DEF {1} SHARED VAR g-rptfrom LIKE txb.sthead.rptfrom.
DEF {1} SHARED VAR g-rptto   LIKE txb.sthead.rptto.
DEF {1} SHARED VAR g-rem     LIKE txb.sthead.rem.
DEF {1} SHARED VAR g-referid LIKE txb.sthead.referid.
DEF {1} SHARED VAR g-host    as   char format "x(10)".

