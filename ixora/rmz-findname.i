/* iovyp.i
 * MODULE
        Интернет-банкинг
 * DESCRIPTION
        Поиск имени и РНН/ИИН/БИН по RMZ
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU

 * BASES
        BANK TXB
 * AUTHOR
        05.12.2012 berdibekov
*/



/**
  * Поиск имени и РНН/ИИН/БИН по RMZ
  * Call this only after finded txb.remtrz. I.e. if available txb.remtrz
  * @return Returns payer_rnn, payer_name, rcpt_rnn, rcpt_rnn
  */
procedure rmzFindName:

    def input parameter rmz as char.

    def output parameter payer_name as char.
    def output parameter payer_rnn as char.
    def output parameter rcpt_name as char.
    def output parameter rcpt_rnn as char.

    def var i as integer.
    def var tmp as char.

    def var rnnTxt as char init "/RNN/".

    if v-bin then
        rnnTxt = "/IDN/".

    find last txb.remtrz where txb.remtrz.remtrz = rmz no-lock no-error.
    if avail txb.remtrz then do:
        rcpt_name = "".
        do i = 1 to 3:
            tmp = trim( txb.remtrz.bn[i] ).
            rcpt_name   = rcpt_name + if length( tmp ) = 60 then tmp else tmp + " ".
        end.

        tmp = rcpt_name.
        i = r-index( tmp, rnnTxt ).
        if i <> 0 then do:
            rcpt_name = trim( substring( tmp, 1, i - 1 )).
            rcpt_rnn = trim( substring( tmp, i + 5, 12 )).
        end.
        else do:
            tmp = "".
            do i = 1 to 3:
                tmp = tmp + trim(txb.remtrz.bn[i]).
            end.
            i = r-index(tmp, rnnTxt).
            if i <> 0 then do:
                rcpt_name = trim(substring(tmp, 1, i - 1)).
                rcpt_rnn = trim(substring(tmp, i + 5, 12)).
            end.
        end.

        i = r-index( txb.remtrz.ord, rnnTxt ).
        if i <> 0 then do:
            payer_name = trim( substring( txb.remtrz.ord, 1, i - 01 )).
            payer_rnn = trim( substring( txb.remtrz.ord, i + 5, 12 )).
        end.
        else do:
            payer_name = trim( txb.remtrz.ord ).
        end.


    end.


end procedure.

