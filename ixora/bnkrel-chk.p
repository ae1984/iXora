/* bnkrel-chk.p
 * MODULE
        Название модуля
 * DESCRIPTION
        добавление информации о клиентах связанных с банком особыми отношениями
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        cif-new.p cif-joi.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
       06/08/2010 - galina, aigul
 * BASES
        BANK COMM
 * CHANGES
       19/08/2010 galina - проверяем, только если введен РНН
       02/01/2013 madiyar - проверяем по ИИН/БИН
*/

{global.i}

def shared var s-cif like cif.cif.
find first cif where cif.cif = s-cif no-lock no-error.
if avail cif and trim(cif.bin) <> '' then do:
    find first prisv where prisv.rnn = cif.bin no-lock no-error.
    if avail prisv then do:
            message "Данный клиент связан с банком особыми отношениями!" view-as alert-box title "Внимание".
            find first sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = cif.cif and  sub-cod.d-cod = 'bnkrel' no-lock no-error.
            if avail sub-cod then do:
                if sub-cod.ccode <> "01" then do transaction:
                    find current sub-cod exclusive-lock.
                    sub-cod.ccode = "01".
                    find current sub-cod no-lock.
                end.
            end.
            else do transaction:
                    create sub-cod.
                    sub-cod.acc = cif.cif.
                    sub-cod.sub = "cln".
                    sub-cod.d-cod = "bnkrel".
                    sub-cod.ccode = "01".
                    sub-cod.rdt = g-today.
                    sub-cod.rcode = "".
            end.
    end.
    if not avail prisv then do:
        find first sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = cif.cif and  sub-cod.d-cod = 'bnkrel' no-lock no-error.
            if avail sub-cod then do:

                if sub-cod.ccode <> "02" then do transaction:
                    find current sub-cod exclusive-lock.
                    sub-cod.ccode = "02".
                    find current sub-cod no-lock.
                end.
            end.
            else do transaction:
                    create sub-cod.
                    sub-cod.acc = cif.cif.
                    sub-cod.sub = "cln".
                    sub-cod.d-cod = "bnkrel".
                    sub-cod.ccode = "02".
                    sub-cod.rdt = g-today.
                    sub-cod.rcode = "".
            end.
    end.
end.