/* 150-name.i
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

/* 
KOVAL - Тест наимeнования в 150.txt 
вызов из 150main.p
*/

{trim.i}

for each t150 where t150.ref=tmp150.ref use-index nr:

err=false.
msg="".

find first accounts where accounts.ourbik = t150.dbank and accounts.aaa = t150.daccnt no-error.

if not avail accounts then assign err=true msg="Нет такого счета.".
else do:

  if accounts.t = "aaa" then do:
        find first clients where clients.cif = accounts.cif no-error.

        /* sasco - использование функции GPSTrim() из trimu.i */
        tmpout  = GPSTrim (d-2-u(t150.dest)).
        tmp     = GPSTrim (clients.ownform + " " + clients.sname).
        stmp    = GPSTrim (clients.ownform + " " + clients.name).


        if ((tmp <> tmpout) and (stmp<>tmpout)) then assign 
                                                        err = true 
                                                        msg = "Не соответствие Наименования получателя.".
        if err then do:
                i = i + 1.
/*              put unformatted t150.ref trim(d-2-u(t150.dest)) " [cif="  trim(trim(clients.ownform) + " " + trim(clients.name)) "]" skip.*/
                ds = t150.amt.  /* Сумма */
                dss = dss + ds.
                tmp = substr(t150.vdat,5,2) + "." + substr(t150.vdat,3,2) + "." + substr(t150.vdat,1,2).

                if t150.final = "1" then t150.final = "FINAL".
                                    else t150.final = "PRESENT".

                put unformatted "N " string(t150.nr,">>>9")  " "  clients.cif " " trim(trim(clients.ownform) + " " + trim(clients.name)) skip
                          " Тип: " t150.final "  Плат.система: " t150.sys "  Референс: " t150.ref skip
                          " Сумма: " trim(string(ds,'>>>,>>>,>>>,>>9.99')) "    Получен банком: " t150.dt "  Дата валютирования: " tmp skip 
                          "  Банк отпр.: " t150.sbank "    Счет отпр.: " t150.saccnt skip
                          "  Банк получ: " t150.dbank "    Счет получ: " t150.daccnt skip 
                          "  РНН отпрв : " t150.srnn " " trim(d-2-u(substr(t150.sender,1,50))) skip
                          "  РНН получ : " t150.drnn " " trim(d-2-u(substr(t150.dest,1,50))) skip
                          "  Назначение платежа: " skip
                          space(4) d-2-u(substr(t150.details,1,55)) skip
                          space(4) d-2-u(substr(t150.details,56,75)) skip(1).
        end.

  end.

end.

assign t150.err=err t150.msg=msg.


end. /*  f o r  */

