/* FindArp100200.p
 * MODULE
        Касса
 * DESCRIPTION
	Определение кассы в пути для РКО по логину офицера и валюте
 * RUN
        -
 * CALLER
        crdwkend.p
 * SCRIPT
        -
 * INHERIT
        -
 * MENU
	-
 * AUTHOR
        13.04.2005 u00121
 * BASE`s
	BANK
 * CHANGES
	18.04.2005 u00121 - если счет не найден теперь возвращает "?"
*/


def input param i-dep as char no-undo. /*Код департамента сотрудника*/
def input param i-crc as integer no-undo. /*Код валюты*/
def output param o-arp as char no-undo. /*возвращаем полученный счет АРП*/

o-arp = "?". /*18.04.2005 u00121*/

def buffer b-sub-cod for sub-cod.

    for each arp where arp.crc = i-crc no-lock:
        find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "arptype" and sub-cod.acc = arp.arp no-lock no-error.
        if not avail sub-cod then next.
        if sub-cod.ccode <> "obmen1002" then next. 

        find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "sproftcn" and sub-cod.acc = arp.arp no-lock no-error.
        if not avail sub-cod then next.
        if sub-cod.ccode <> i-dep then next.
        o-arp = arp.arp.
        leave.
    end.
