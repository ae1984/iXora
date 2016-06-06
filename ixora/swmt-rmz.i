/* swmt-rmz.i
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
        12.05.2004 nadejda - при прописывании поля 50 в наименование получателя терялся РНН - добавила, чтобы РНН был в remtrz
        27.09.2012 evseev - логирование
*/

/* KOVAL Апдейт RMZ для совместимости с предыдущими версиями */

for each swin :

        run savelog("swiftmaket", "swmt-rmz.i  27. " + string(swin.rmz)).
        run savelog("swiftmaket", "swmt-rmz.i    . " + string(swin.swfield)).
        run savelog("swiftmaket", "swmt-rmz.i    . " + string(swin.content[1])).
        run savelog("swiftmaket", "swmt-rmz.i    . " + string(swin.content[2])).
        run savelog("swiftmaket", "swmt-rmz.i    . " + string(swin.content[3])).
        run savelog("swiftmaket", "swmt-rmz.i    . " + string(swin.content[4])).
        run savelog("swiftmaket", "swmt-rmz.i    . " + string(swin.content[5])).
        run savelog("swiftmaket", "swmt-rmz.i    . " + string(swin.content[6])).

        case swin.swfield:
                when "50" then do:
                  run savelog("swiftmaket", "swmt-rmz.i   38. " + string(remtrz.intmedact)).
                  run savelog("swiftmaket", "swmt-rmz.i   39. " + string(remtrz.ord)).
                  assign remtrz.intmedact = swin.content[2]
                         remtrz.ord = swin.content[1] + swin.content[3] + swin.content[4] + " " + swin.content[2].
                   if remtrz.ord = ? then
                   do:
                      run mail("IXqueuerr@fortebank.com", "bankadm@metrocombank.kz", "Поле ORD = ?", "swmt-rmz.i", "1", "", "").
                   end.
                end.
                when "52" then do:
                   run savelog("swiftmaket", "swmt-rmz.i   48. " + string(remtrz.ordins[1])).
                   run savelog("swiftmaket", "swmt-rmz.i     . " + string(remtrz.ordins[2])).
                   run savelog("swiftmaket", "swmt-rmz.i     . " + string(remtrz.ordins[3])).
                   run savelog("swiftmaket", "swmt-rmz.i     . " + string(remtrz.ordins[4])).
                   assign
                     remtrz.ordins[1] = swin.content[2]
                     remtrz.ordins[2] = swin.content[1]
                     remtrz.ordins[3] = swin.content[3]
                     remtrz.ordins[4] = swin.content[4].
                end.
                when "53" then do:
                   run savelog("swiftmaket", "swmt-rmz.i   59. " + string(remtrz.sndcor[1])).
                   run savelog("swiftmaket", "swmt-rmz.i     . " + string(remtrz.sndcor[2])).
                   assign
                     remtrz.sndcor[1] = swin.content[1]
                     remtrz.sndcor[2] = swin.content[2].
                end.
                when "54" then do:
                   run savelog("swiftmaket", "swmt-rmz.i   66. " + string(remtrz.rcvcor[1])).
                   run savelog("swiftmaket", "swmt-rmz.i     . " + string(remtrz.rcvcor[2])).
                   run savelog("swiftmaket", "swmt-rmz.i     . " + string(remtrz.rcvcor[3])).
                   run savelog("swiftmaket", "swmt-rmz.i     . " + string(remtrz.rcvcor[4])).
                    assign
                       remtrz.rcvcor[1] = swin.content[2]
                       remtrz.rcvcor[2] = swin.content[1]
                       remtrz.rcvcor[3] = swin.content[3]
                       remtrz.rcvcor[4] = swin.content[4].
                end.
                when "56" then do:
                   run savelog("swiftmaket", "swmt-rmz.i   77. " + string(remtrz.intmed)).
                   run savelog("swiftmaket", "swmt-rmz.i     . " + string(remtrz.intmedact)).
                    assign
                        remtrz.intmed = swin.content[2]
                        remtrz.intmedact = swin.content[1] + swin.content[3] + swin.content[5] + swin.content[4].
                end.
                when "57" then do:
                    run savelog("swiftmaket", "swmt-rmz.i  84. " + string(remtrz.bb[1])).
                    run savelog("swiftmaket", "swmt-rmz.i    . " + string(remtrz.bb[2])).
                    run savelog("swiftmaket", "swmt-rmz.i    . " + string(remtrz.bb[3])).
                   assign
                      remtrz.bb[1] = swin.content[1]
                      remtrz.bb[2] = swin.content[2]
                      remtrz.bb[3] = swin.content[3].
                end.
                when "59" then do:
                   run savelog("swiftmaket", "swmt-rmz.i   93. " + string(remtrz.ba   )).
                   run savelog("swiftmaket", "swmt-rmz.i     . " + string(remtrz.bn[1])).
                   run savelog("swiftmaket", "swmt-rmz.i     . " + string(remtrz.bn[2])).
                   run savelog("swiftmaket", "swmt-rmz.i     . " + string(remtrz.bn[3])).
                   assign
                      remtrz.ba    = swin.content[1]
                      remtrz.bn[1] = swin.content[2]
                      remtrz.bn[2] = swin.content[3]
                      remtrz.bn[3] = swin.content[4].
                end.
                when "71" then do:
                   run savelog("swiftmaket", "swmt-rmz.i  104. " + string(remtrz.bi   )).
                   assign remtrz.bi = swin.content[1].
                end.
                when "70" then do:
                   run savelog("swiftmaket", "swmt-rmz.i  108. " + string(remtrz.detpay[1])).
                   run savelog("swiftmaket", "swmt-rmz.i     . " + string(remtrz.detpay[2])).
                   run savelog("swiftmaket", "swmt-rmz.i     . " + string(remtrz.detpay[3])).
                   run savelog("swiftmaket", "swmt-rmz.i     . " + string(remtrz.detpay[4])).
                   assign
                      remtrz.detpay[1]  = swin.content[1]
                      remtrz.detpay[2]  = swin.content[2]
                      remtrz.detpay[3]  = swin.content[2]
                      remtrz.detpay[4]  = swin.content[4].
                end.
                when "72" then do:
                   run savelog("swiftmaket", "swmt-rmz.i  119. " + string(remtrz.rcvinfo[1])).
                   run savelog("swiftmaket", "swmt-rmz.i     . " + string(remtrz.rcvinfo[2])).
                   run savelog("swiftmaket", "swmt-rmz.i     . " + string(remtrz.rcvinfo[3])).
                   run savelog("swiftmaket", "swmt-rmz.i     . " + string(remtrz.rcvinfo[4])).
                   run savelog("swiftmaket", "swmt-rmz.i     . " + string(remtrz.rcvinfo[5])).
                   run savelog("swiftmaket", "swmt-rmz.i     . " + string(remtrz.rcvinfo[6])).
                   assign
                      remtrz.rcvinfo[1] = swin.content[1]
                      remtrz.rcvinfo[2] = swin.content[2]
                      remtrz.rcvinfo[3] = swin.content[3]
                      remtrz.rcvinfo[4] = swin.content[4]
                      remtrz.rcvinfo[5] = swin.content[5]
                      remtrz.rcvinfo[6] = swin.content[6].
                end.
        end case.
end.
