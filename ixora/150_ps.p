/* 150_ps.p
 * MODULE
        150_PS
 * DESCRIPTION
        Копирует файл прогнозных платежей на Texaka1 и Bankonline
 * RUN
        Процесс платежной системы. Запускать ТОЛЬКО под Superman! (а то работать не будет)
 * CALLER
        стандартные для процессов
 * SCRIPT
        стандартные для процессов
 * INHERIT
        стандартные для процессов
 * MENU
        5.1
 * AUTHOR
        10/12/03 suchkov
 * CHANGES
        26/01/04 suchkov - Поправил ошибку с паролем и коннектом по ftp
        28/01/04 suchkov - Добавил запись времени в лог
        03/03/04 suchkov - Теперь ibhost берется из sysc
        17/10/05 tsoy    - check_KIS ввиду того что процесс KIS переодически зависает.
        10/10/06 suchkov - Переделал коннект на scp
        17/10/06 suchkov - Теперь коннект под юзером inbank
*/

define variable lbeks   as character initial "".
define variable i       as integer  .
define variable lpash   as character.
define variable ibhost  as character.
define variable lpashio as character.



run check_KIS. 

find sysc where sysc.sysc = "150FLE" no-lock .
lpash = sysc.chval .

find sysc where sysc = "IBHOST".
ibhost = entry (lookup("-H",sysc.chval," ") + 1, sysc.chval," ").

find sysc where sysc.sysc = "150IO" no-lock .
lpashio = sysc.chval .


find sysc where sysc.sysc = "lbeks" no-lock .
do i = 1 to num-entries (sysc.chval,"/"):
    lbeks = lbeks + ENTRY (i, sysc.chval, "/") + "\\" + "\\" .
end.
lbeks = substring (lbeks, 1, length (lbeks) - 2).

find sysc where sysc.sysc = "150txt" no-lock .

/* display lbeks skip sysc.chval skip entry (3, sysc.chval, "\\") skip lpash . */
unix silent value("echo Начало копирования; date").

unix silent value("if rcp ntmain:" + lbeks + sysc.chval + " . ; then if [ `ls " + entry (3, sysc.chval, "\\") + 
        " -al | awk -F' ' '\{ print $5 ;\}'` -ne '0' ] ; then cp " + entry (3, sysc.chval, "\\") + " " + lpash + " ; fi ; fi ") .

/*unix silent value("echo 'open " + ibhost + "\nuser superman '$fpassw'\nput " + entry (3, sysc.chval, "\\") + " " +
            lpashio + entry (3, sysc.chval, "\\") + "\nbye\n' | ftp -n -v").*/

unix silent value("scp -q " + entry (3, sysc.chval, "\\") + " " + "inbank@" + ibhost + ":" + lpashio ).

unix silent value("echo Конец копирования; date").
