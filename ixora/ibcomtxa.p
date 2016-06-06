/* ibcomtxa.p
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
	24.05.2003 nadejda - убраны параметры -H -S из коннекта 
        31.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
*/

def input parameter g-today as date.
def input parameter g-ofc as char.
def input parameter g-dnum as char.
def input parameter g-phone as char.
def input parameter g-sum as decimal.
def input parameter g-rem as char.
def input parameter g-rid as integer.
def input parameter g-name as char.

find first txb where txb.txb = 0 and txb.visible and txb.consolid and txb.city = 0 no-lock no-error.                              
if connected ("txb") then disconnect "txb".

connect value(" -db " + " -H " + comm.txb.host + " -S " + comm.txb.service + txb.path + " -ld txb -U " + txb.login + " -P " + txb.password).                     
                                                                                                          
run ibcomtxb (g-today, g-ofc, g-dnum, g-phone, g-sum, g-rem, g-rid, g-name).

if connected ('txb') then disconnect "txb".                                               



