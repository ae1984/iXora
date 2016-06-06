/* assaxx.p
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

FOR EACH AAX WHERE AAX.LN EQ 66:
display aax.dgl aax.cgl.
find lgr where lgr.lgr eq aax.lgr.
display lgr.gl lgr.accgl.
aax.dgl = lgr.accgl.
aax.cgl = lgr.gl.
