/* cif-pc.p
 * MODULE
        Новые клиенты и открытие счетов
 * DESCRIPTION
	    Платежные карты: инд.выпуск/перевыпуск
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        1.2
 * AUTHOR
        17.05.2013 Lyubov
 * BASES
        BANK COMM
 * CHANGES
*/

def shared var s-cif   like cif.cif.
find first cif where cif.cif = s-cif no-lock no-error.
if not avail cif then return.
if cif.type = 'b' then run cif-pcul.
else run cif-pcfl.