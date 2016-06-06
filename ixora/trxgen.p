/* trxgen.p
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
 * BASES
        BANK COMM
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        13/05/2004 madiar - добавил второй входной пар-р (true/false) в trxdel - показывать запрос причины удаления транзакции или нет.
        03/05/2012 Luiza  - добавила рассылку в деп казначейства, если операции с 185800 и внебал превышают лимиты
        04/05/2012 Luiza  - добавила BANK COMM для BASES
        27/11/2012 Luiza  - подключила convgl.i  ТЗ 1374
        28/11/2012 Luiza - ТЗ 1374 изменила условие выбора линий проводки
*/

def input parameter trxcode as char.
def input parameter vdel as char.
def input parameter vparam as char.

def input parameter vsub as char.
def input parameter vref as char.

def output parameter rcode as inte.
def output parameter rdes as char.
def input-output parameter vjh as inte.
def var flag as logi initial false.
def var rrcode as inte.
def var rrdes as char.
{convgl.i "bank"}
define temp-table tempjl like jl.
for each jl where jl.jh = vjh and (jl.gl = 185800 or jl.gl = 185900 or jl.gl = 285800 or jl.gl = 285900 or (jl.gl >= 600000 and jl.gl <= 641500 and jl.gl <> 603600) or
                        (jl.gl >= 650000 and jl.gl <= 691500 and jl.gl <> 653600)) and jl.crc <> 1 no-lock.
    create tempjl.
    buffer-copy jl to tempjl.
end.

if vsub ne "" then  do:
 find first trxsub where trxsub.sub = vsub no-lock no-error .
 if not avail trxsub then do:
  rcode = 50 .
  rdes = " Объект SUB = " + vsub + " не найден в TRXSUB "  .
  return .
 end.
end.

if vjh > 0 then flag = true.

run trxgen0(trxcode, vdel, vparam, vsub, vref, output rcode
                   , output rdes, input-output vjh).

if flag = true and rcode > 0 then do:
      if can-find(jh where jh.jh = vjh) then do:
         run trxsts(vjh, 0, output rrcode, output rrdes).
         run trxdel(vjh, false, output rrcode, output rrdes).
      end.
end.

/*Luiza ---------------------------------------------------------------*/
def shared var g-ofc as char .
def shared var g-today as date .
def var vvrate as char.
def var vvfio as char.
def var vvop as char.
def var vvrem as char.
def buffer bjl for jl.
for each jl where jl.jh = vjh and (jl.gl = 185800 or jl.gl = 185900 or jl.gl = 285800 or jl.gl = 285900 or (jl.gl >= 600000 and jl.gl <= 641500 and jl.gl <> 603600) or
                        (jl.gl >= 650000 and jl.gl <= 691500 and jl.gl <> 653600)) and jl.crc <> 1 no-lock.
        find first crclim where crclim.crc = jl.crc no-lock no-error.
        find first cmp no-lock no-error.
        if available cmp then do:
            if available crclim and ((jl.dc = "D" and jl.dam >= crclim.lim and crclim.lim <> 0)
                or (jl.dc = "C" and jl.cam >= crclim.lim and crclim.lim <> 0 ))then do:

                find first jh where jh.jh = jl.jh no-lock no-error.
                if available jh then do:
                    vvrate = "".
                    vvfio = "".
                    find first joudoc where joudoc.docnum = jh.ref no-lock no-error.
                    if available joudoc then do:
                        vvrem = joudoc.remark[1].
                        if joudoc.info <> "" then vvfio = joudoc.info.
                        else if jl.rem[1] begins "Обмен валюты" then vvfio = "Обменный пункт".
                        if joudoc.srate > 1 then vvrate = string(joudoc.srate).
                        else  vvrate = string(joudoc.brate).
                    end.
                    else do:
                        find first dealing_doc where dealing_doc.docNo = vref no-lock no-error.
                        if available dealing_doc then vvrate = string(dealing_doc.rate).
                    end.
                    if vvrem = "" then vvrem = jl.rem[1].
                    if vvrem = "" then do:
                        find first bjl where bjl.jh = vjh and bjl.ln = 1 no-lock no-error.
                        vvrem = bjl.rem[1].
                    end.
                    if vvfio = "" then do:
                        find first aaa where aaa.aaa = bjl.acc no-lock no-error.
                        if available aaa then do:
                            find first cif where cif.cif = aaa.cif no-lock no-error.
                            if available cif then vvfio = cif.name.
                        end.
                    end.
                end.
                if jl.dc = "D" then do:
                    if isConvGL(jl.gl) then vvop = "продажа". else vvop = "покупка".
                    find first tempjl where tempjl.ln = jl.ln no-lock no-error.
                    if not available tempjl then do:
                        for each ofcsend1 no-lock.
                            run mail(trim(ofcsend1.ofc) + "@metrocombank.kz", trim(jl.who) + "@metrocombank.kz", "Уведомление об операции в ин валюте",
                            "Добрый день!\n\n Проведена операция в ин валюте \n " + cmp.name + "\n" +  vvop + " на сумму: " + string(jl.dam) +
                            " " + crclim.ccod + "\n курс " + vvrate + "\n клиент: " + vvfio + "\n примечание: " + vvrem +
                            "\n транзакция: " + string(jl.jh) + "\n создал: " + trim(jl.who) + "\n " + string(g-today) + "  " +
                            string(time,"HH:MM"), "1", "","" ).
                        end.
                    end.
                end.
                if jl.dc = "C" then do:
                    if isConvGL(jl.gl) then vvop = "покупка". else vvop = "продажа".
                    find first tempjl where tempjl.ln = jl.ln no-lock no-error.
                    if not available tempjl then do:
                        for each ofcsend1 no-lock.
                            run mail(trim(ofcsend1.ofc) + "@metrocombank.kz", trim(jl.who) + "@metrocombank.kz", "Уведомление об операции в ин валюте",
                            "Добрый день!\n\n Проведена операция в ин валюте \n " + cmp.name + "\n" + vvop + " на сумму: " + string(jl.cam) +
                            " " + crclim.ccod + "\n курс " + vvrate + "\n клиент: " + vvfio + "\n примечание: " + vvrem +
                            "\n транзакция: " + string(jl.jh) + "\n создал: " + trim(jl.who) + "\n " + string(g-today) + "  " +
                            string(time,"HH:MM"), "1", "","" ).
                        end.
                    end. /* for each */
                end. /* else do:  */
            end. /* if available crclim  */
        end.
end.  /*  for each jl */
/*-------------------------------------------------------------------------*/

