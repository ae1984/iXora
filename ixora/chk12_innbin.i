/* chk12_innbin.i
 * MODULE
        Операционный
 * DESCRIPTION
        Функция для проверки контрольного разряда ИНН/БИН
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
        13/11/2009 madiyar
 * BASES
        BANK
 * CHANGES
        09.01.2013 evseev - ТЗ-1632
*/

function chk12_innbin returns logical (input inn as char).
    def var res as logical no-undo.
    def var w1 as integer extent 11 init [1,2,3,4,5,6,7,8,9,10,11].
    def var w2 as integer extent 11 init [3,4,5,6,7,8,9,10,11,1,2].
    def var dset as char no-undo init "0123456789".
    def var sum as integer no-undo.
    def var digit12 as integer no-undo.
    def var i as integer no-undo.
    if trim(inn) = "-" then do: res = yes. return res. end.
    if length(inn) <> 12 then do: res = no. return res. end.

    do i = 1 to 12:
        if index(dset,substring(inn,i,1)) = 0 then do: res = no. return res. end.
    end.

    sum = 0.
    do i = 1 to 11:
        sum = sum + w1[i] * integer(substring(inn,i,1)).
    end.
    digit12 = sum mod 11.
    if digit12 = 10 then do:
        sum = 0.
        do i = 1 to 11:
            sum = sum + w2[i] * integer(substring(inn,i,1)).
        end.
        digit12 = sum mod 11.
        if digit12 = 10 then do: res = no. return res. end.
    end.
    if digit12 = integer(substring(inn,12,1)) then res = yes.
    return res.
end function.

