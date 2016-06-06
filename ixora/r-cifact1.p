/* r-cifact1.p
 * MODULE
         Клиенты
 * DESCRIPTION
        Активность клиентов
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
        BANK COMM TXB
 * AUTHOR
        28/11/10 marinav
 * CHANGES
        26.09.2011 id00477 - отделил код клиента от его наименования
        07/10/2011 dmitriy - добавил столбцы: вид деятельности, обороты за период, адрес
        13/10/2011 madiyar - v-date
        01/11/2011 dmitriy - убрал изменения от 07/10/11 и 13/10/11 (ОД попросили оставить как было)
                           - создал новый файл r-cifact1_b, перенес в п.м. 1-4-1-19 (измененный отчет для СП)
        06/01/2012 dmitriy - изменил v-dat1 на v-date в вызове lonbalcrc_txb
        29/05/2012 dmitriy - добавил столбец "Перечень шифров отраслей экономики"
        22/08/2012 dmitriy - добавил столбец "Электронный адрес"
        17/09/2013 galina - ТЗ 1911 добавила столбец "форма собственности"
        25/11/2013 galina - ТЗ2217 добавила столбец "Счета"
*/

def shared var v-date as date.
def shared var v-jl as inte.
def shared var v-type as char.
def shared stream m-out.

def shared var v-dat1 as date.
def shared var v-dat2 as date.


def var coun as inte.
def var coun1 as inte.
def var coun_cif as inte .
def var coun1_cif as inte.
def var v-ost as decimal.
def var v-bin as char.
def var v-ecdivis as char.
def var v-mail as char.

find first txb.cmp no-lock.

/*кол активных клиентов на филиале */
coun_cif = 0. coun1_cif = 0.


for each txb.cif where txb.cif.type = v-type no-lock.
    /*кол активных счетов на филиале */
    coun = 0. /* кол-во открытых счетов*/
    coun1 = 0.  /* кол-во транзакций */

    for each txb.aaa where txb.aaa.cif = txb.cif.cif and txb.aaa.regdt <= v-date /*and not (string(txb.aaa.gl)) begins '2870'*/ no-lock use-index cif.
       if string(txb.aaa.gl) begins '2870' or string(txb.aaa.gl) begins '2240' then next.
       find first txb.lgr where txb.lgr.lgr = txb.aaa.lgr no-lock no-error.
       if txb.lgr.led = 'DDA' or  txb.lgr.led = 'TDA' or txb.lgr.led = 'SAV' or txb.lgr.led = 'CDA' then do:

         if txb.aaa.sta = 'C' then do:
            find first txb.sub-cod where txb.sub-cod.sub = 'cif' and txb.sub-cod.acc = txb.aaa.aaa and txb.sub-cod.d-cod = 'clsa' no-lock no-error.
            if avail txb.sub-cod then do:
               if txb.sub-cod.rdt >= v-date then coun = coun + 1.
            end.
         end.
         else coun = coun + 1.

         if coun1 = 0 then do:
            for each txb.jl where txb.jl.jdt >= v-dat1 and txb.jl.jdt < v-dat2 and txb.jl.acc = txb.aaa.aaa no-lock.
                find first txb.trxcods where txb.trxcods.trxh = txb.jl.jh  and
                                       txb.trxcods.trxln = txb.jl.ln and
	   		               txb.trxcods.code begins "chg" no-lock no-error.

                if not available trxcods then  coun1 = coun1 + 1.
            end.
            if coun1 >= v-jl then coun1 = 1.
                             else coun1 = 0.
         end.

       end.
    end.

    if coun  > 0 then coun_cif  = coun_cif  + 1.
    if coun1 > 0 then coun1_cif = coun1_cif + 1.

    if coun  > 0 then do:
        put stream m-out unformatted "<tr><td>" "</td>"
                                       "<td>" txb.cmp.name format "x(40)" "</td>"
                                       "<td>" txb.cif.cif format "x(6)"  "</td>". /* 26.09.2011 id00477 */
                                       if v-type = 'B' then put stream m-out unformatted "<td>" txb.cif.prefix "</td>".
        put stream m-out unformatted "<td>" txb.cif.name format "x(40)"  "</td>"
                                     "<td>" string(coun)  "</td>".


                if coun1 > 0 then put stream m-out unformatted  "<td>акт</td>".
                             else put stream m-out unformatted  "<td></td>" .

        find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = 'clnsegm' no-lock no-error.
        if avail txb.sub-cod then do:
              find first txb.codfr where txb.codfr.codfr = 'clnsegm' and txb.codfr.code = txb.sub-cod.ccode no-lock no-error.
              if avail txb.codfr then     put stream m-out unformatted  "<td>" txb.codfr.name format 'x(50)' "</td>".
                                 else     put stream m-out unformatted  "<td></td>".
        end.
        else put stream m-out unformatted  "<td></td>".

        v-ost = 0.
        for each txb.lon where txb.lon.cif = txb.cif.cif no-lock:
            run lonbalcrc_txb('lon',txb.lon.lon,v-date,"1,7",no,txb.lon.crc,output v-ost).
            if v-ost > 0 then leave.
        end.
        if v-ost > 0 then put stream m-out unformatted  "<td>Да</td>".
                    else put stream m-out unformatted  "<td>Нет</td>".

        v-bin = "'" + txb.cif.bin.
        put stream m-out unformatted "<td>" v-bin format 'x(13)' "</td>".

        v-ecdivis = "".
        find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = 'ecdivis' no-lock no-error.
        if avail txb.sub-cod then do:
            find first txb.codfr where txb.codfr.codfr = txb.sub-cod.d-cod and txb.codfr.code = txb.sub-cod.ccode  no-lock no-error.
            if avail txb.codfr then v-ecdivis = txb.codfr.name[1].
        end.

        put stream m-out unformatted "<td>" v-ecdivis format 'x(100)' "</td>" skip.

        v-mail = "".
        find first txb.cif-mail where txb.cif-mail.cif = txb.cif.cif no-lock no-error.
        if avail txb.cif-mail then v-mail = txb.cif-mail.mail.
        put stream m-out unformatted "<td>" v-mail format 'x(50)' "</td></tr>" skip.


    end.

end.
