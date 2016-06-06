/* lgps.i
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

def {1} shared var m_hst as char.
def {1} shared var m_copy as char.
def {1} shared var m_pid like bank.que.pid.
def {1} shared var u_pid as cha.
def {1} shared var v-text as cha.
if "{1}"  matches "*l*l*" then run setps.
