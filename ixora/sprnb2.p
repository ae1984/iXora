/* sprnb2.p
 * MODULE
        ___Ю ФЁR-ЁАБ
 * DESCRIPTION

 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * CONNECT
        bank, comm, (_____<_-__ __" TXB->bank)
 * AUTHOR
        13.09.2005 dpuchkov
 * CHANGES
        13/12/2011 evseev - ТЗ-625. Переход на ИИН/БИН
*/



def shared temp-table waaatbl like txb.aaa
    field number2 as integer
    field closed  as char.



def shared temp-table t2
    field number  as integer
    field number2 as integer
    field jss     like txb.cif.jss
    field bin     like txb.cif.bin
    field name    like txb.cif.name
    field cif     like txb.cif.cif
    field prefix  like txb.cif.prefix
    field closed  as char.





for each t2:
    for each txb.aaa where txb.aaa.cif = t2.cif /*and txb.aaa.sta <> "C" and txb.aaa.sta <> "E"*/   no-lock:
        find txb.lgr where txb.lgr.lgr = txb.aaa.lgr no-lock.
        if txb.lgr.led = 'ODA' then next.
        create waaatbl.
        waaatbl.number2 = t2.number2.
        waaatbl.cif = txb.aaa.cif.
        waaatbl.aaa = txb.aaa.aaa.
        waaatbl.cr[1] = txb.aaa.cr[1].
        waaatbl.dr[1] = txb.aaa.dr[1].
        waaatbl.sta = txb.aaa.sta.
        waaatbl.crc = txb.aaa.crc.
        waaatbl.stadt = txb.aaa.stadt.

        if txb.aaa.sta = "C" or txb.aaa.sta = "E" then
        do:
            find last txb.aadrt where txb.aadrt.idclr = txb.aaa.aaa no-lock no-error.
            if avail txb.aadrt then
            do:
                waaatbl.cltdt = txb.aadrt.whn.
            end.
            else
            do:
                waaatbl.cltdt = txb.aaa.cltdt.
            end.
        end.


        if txb.aaa.sta = "C" or txb.aaa.sta = "E" then  waaatbl.closed = "C".


        find last txb.crc where txb.crc.crc = txb.aaa.crc no-lock no-error.
        if avail txb.crc then
        do:
            waaatbl.lgr =  txb.crc.code.
        end.
    end.
end.