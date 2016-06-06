/* mob333txa.p
 * MODULE
        Название Программного Модуля
        KMobile
 * DESCRIPTION
        Назначение программы, описание процедур и функций
        Копирование информации о платеже
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
        Запускает mob333txb
        нужен коннект к comm
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

find first txb where txb.txb = 0 and txb.visible and txb.consolid and txb.city = 0 no-lock no-error.                              
if connected ("txb") then disconnect "txb".

connect value(" -db " + txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld txb -U " + txb.login + " -P " + txb.password).                     
                                                                                                          
run mob333txb (g-today, g-ofc, g-dnum, g-phone, g-sum, g-rem).

if connected ('txb') then disconnect "txb".                                               


