/* sign_sp_common.i
 * MODULE
        Потребительские кредиты - замена подписей
 * DESCRIPTION
        Общие переменные и временные таблицы для замены подписей
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        08/08/2011 evseev
 * CHANGES
*/

def var spr_list as char no-undo.
spr_list = "DKOSN,DKOSNKZ,DKPODP,DKPODPKZ,DKKOGO,DKKOGOKZ,DKDOLZHN,DKDOLZHNKZ".

def temp-table t-faces no-undo
  field code as integer
  field face as char
  index idx is primary code.

create t-faces.
t-faces.code = 1.
t-faces.face = "Директор СП".


