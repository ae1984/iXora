/* lcoutcor2.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        EXLC: Корреспонденция - исходящий свифт
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
        18/02/2011 id00810
 * CHANGES
        05.03.2012 Lyubov - добавила шаренную переменную для формата сообщения
*/

def new shared var s-lcprod as char initial 'EXLC'.
def new shared var s-mt as int.
s-mt = 799.
run lcoutcor.