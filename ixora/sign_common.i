/* sign_common.i
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
        11/06/2008 madiyar
 * CHANGES
        19/06/2008 madiyar - добавил 3ий вариант, операционку
        18/07/2011 evseev - добавил DKKOGO и 4ый вариант И.о.
*/

def var spr_list as char no-undo.
spr_list = "DKFACE,DKFACEKZ,DKKOMU,DKOSN,DKOSNKZ,DKPODP,DKPODPKZ,DKSUFF,DKKOGO,DKKOGOKZ,DKDOLZHN".

def temp-table t-faces no-undo
  field code as integer
  field face as char
  index idx is primary code.

create t-faces.
t-faces.code = 1.
t-faces.face = "Председатель правления / Директор филиала".
create t-faces.
t-faces.code = 2.
t-faces.face = "Главный бухгалтер / Главный бухгалтер филиала".
create t-faces.
t-faces.code = 3.
t-faces.face = "Директор опер. департамента / Начальник опер. отдела филиала".
create t-faces.
t-faces.code = 4.
t-faces.face = "И.о. директора филиала".

