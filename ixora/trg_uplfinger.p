/* trg_uplfinger.p
 * MODULE
        БИОМЕТРИЯЧЕСКИЙ АНАЛИЗ
 * DESCRIPTION
        Назначение программы, описание процедур и функций
        Формирование истории снятия отпечатков пальцев
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
        19/09/05 u00121
 * CHANGES
        05/05/2010 galina - перекомпиляция
*/

TRIGGER PROCEDURE FOR Assign OF upl.finger.
create uplfnghst.
        uplfnghst.cif = upl.cif. /*код клиента*/
        uplfnghst.ofc = user('bank'). /*логин пользователя*/
        uplfnghst.dt = today. /*дата изменения*/
        uplfnghst.tm = time. /*время изменения*/
        uplfnghst.upl = string(upl.uplid). /*код доверенного лица*/
        uplfnghst.sts = upl.finger. /*признак изменения*/
