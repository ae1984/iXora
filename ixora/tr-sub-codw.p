/* tr-sub-codw.p
 * MODULE
        Внутрибанковские операции
 * DESCRIPTION
        Триггер на изменение записи в sub-cod
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
        --/--/2013 damir
 * BASES
        BANK COMM
 * CHANGES
        17.05.2013 damir - Внедрено Т.З. № 1803.
*/
TRIGGER PROCEDURE FOR WRITE of sub-cod old oldsub-cod.

{global.i}

if sub-cod.sub = oldsub-cod.sub and sub-cod.d-cod = oldsub-cod.d-cod and sub-cod.acc = oldsub-cod.acc then do:
    if sub-cod.d-cod = "arptype" then do:
        if sub-cod.ccode <> oldsub-cod.ccode then run addrec.
    end.
end.
else if sub-cod.sub <> oldsub-cod.sub and sub-cod.d-cod <> oldsub-cod.d-cod and sub-cod.acc <> oldsub-cod.acc then do:
    if sub-cod.d-cod = "arptype" then do:
        run addrec.
    end.
end.

procedure addrec:
    create hissc.
    hissc.acc = sub-cod.acc.
    hissc.sub = sub-cod.sub.
    hissc.d-cod = sub-cod.d-cod.
    hissc.ccode = sub-cod.ccode.
    hissc.rdt = sub-cod.rdt.
    hissc.rcode = sub-cod.rcode.
    hissc.who = g-ofc.
    hissc.tim = time.
end procedure.



