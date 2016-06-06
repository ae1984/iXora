/* pars_out.p
 * MODULE
        Монитор        
 * DESCRIPTION
        Исходящие 
 RUN
 * CALLER
        KIS_ps
 * SCRIPT
        стандартные для процессов
 * INHERIT
        стандартные для процессов
 * MENU
        6.1
 * AUTHOR
        16.11.2006 tsoy
 * CHANGES

*/

{global.i}

run savelog ("mt100","Обработка исходящих платежей  начало " ).

def var v-knp as char.

for each clrdoc where clrdoc.rdt =  g-today no-lock.

    find last mt100 where mt100.rdt = g-today and mt100.paysys = "CLEAR" and mt100.f20 = clrdoc.rem no-lock no-error.
    if avail mt100 then next.

    find remtrz where remtrz.remtrz =  clrdoc.rem no-lock no-error.
    if not avail remtrz then next.

    create mt100.
        mt100.f20 = clrdoc.rem.
        mt100.id                = next-value (mt100seq).
        mt100.direct            = 1.
        mt100.paysys            = "CLEAR". /* "GROSS"  */
        mt100.mttype            = "100".
        mt100.tim               = time.
        mt100.rdt               = g-today.
        mt100.fname             = "".

        mt100.f32valdt          = remtrz.valdt2.
        mt100.f32crc            = "KZT".
        mt100.f32amt            = remtrz.amt.
        mt100.f50type           = "D".
        mt100.f50acc            = remtrz.sacc.

    find aaa where aaa.aaa = remtrz.sacc no-lock no-error .
    find cif where cif.cif = aaa.cif  no-lock no-error .

    if avail cif then do:

         mt100.f50name           = cif.name.
         mt100.f50rnn            = cif.jss.

         /* признак резиденства */
         find cif where cif.cif = cif.cif no-lock no-error.
         if avail cif  then do:
            if substr(cif.geo,3,1) eq '1' then mt100.f50irs = '1'.
            else mt100.f50irs = '2'.
         end.
      
         /* сектор экономики */
         find sub-cod where sub-cod.acc = cif.cif
                        and sub-cod.sub = 'cln'
                        and sub-cod.d-cod = 'secek' no-lock no-error.
         if avail sub-cod and sub-cod.ccode ne 'msc'
            then mt100.f50seco = sub-cod.ccode.


         /* Глав Бух */
         find sub-cod where sub-cod.acc = cif.cif
                        and sub-cod.sub = 'cln'
                        and sub-cod.d-cod = 'mainbk' no-lock no-error.
         if avail sub-cod and sub-cod.ccode ne 'msc'
            then mt100.f50chief = sub-cod.ccode.

         /*  01 */
         find sub-cod where sub-cod.acc = cif.cif
                        and sub-cod.sub = 'cln'
                        and sub-cod.d-cod = 'chief' no-lock no-error.
         if avail sub-cod and sub-cod.ccode ne 'msc'
            then mt100.f50mainbk = sub-cod.ccode.

    end.

    mt100.f52b              = "TXB00".
    mt100.f57b              = remtrz.rbank.
    mt100.f59b              = remtrz.racc.
    mt100.f70date           = remtrz.valdt1.
    mt100.f70vo             = "01".

    find first sub-cod where sub-cod.d-cod = "eknp" and sub-cod.acc = remtrz.remtrz and sub-cod.sub = "rmz" no-lock no-error .
    if avail sub-cod and sub-cod.rcod <> "" and sub-cod.rcod matches "*,*,*" then 
         v-knp =  entry(3, sub-cod.rcod).
    else 
         v-knp = "000".

    mt100.f70knp            = v-knp.
    mt100.f70pso            = "01".
    mt100.f70send           = "07".
    mt100.f70prt            = "50".
    mt100.f70num            = remtrz.sqn.
    mt100.f70assign         = remtrz.rcvinfo[1] + remtrz.rcvinfo[2] + remtrz.rcvinfo[3] + remtrz.rcvinfo[4] + remtrz.rcvinfo[5] + remtrz.rcvinfo[6]. 
    mt100.f53               = remtrz.scbank.
    mt100.f54               = remtrz.rcbank.
    mt100.f59name           = remtrz.ord.

end.

for each clrdog where clrdog.rdt =  g-today no-lock.
    find last mt100 where mt100.rdt = g-today and mt100.paysys = "GROSS" and mt100.f20 = clrdog.rem no-lock no-error.
    if avail mt100 then next.

    find remtrz where remtrz.remtrz =  clrdog.rem no-lock no-error.
    if not avail remtrz then next.

    create mt100.

    mt100.f20 = clrdog.rem.
    mt100.id                = next-value (mt100seq).
    mt100.direct            = 1.
    mt100.paysys            = "GROSS". 
    mt100.mttype            = "100".
    mt100.tim               = time.
    mt100.rdt               = g-today.
    mt100.fname             = "".

    mt100.f32valdt          = remtrz.valdt2.
    mt100.f32crc            = "KZT".
    mt100.f32amt            = remtrz.amt.
    mt100.f50type           = "D".
    mt100.f50acc            = remtrz.sacc.

    find aaa where aaa.aaa = remtrz.sacc no-lock no-error .
    find cif where cif.cif = aaa.cif  no-lock no-error .

    if avail cif then do:

         mt100.f50name           = cif.name.
         mt100.f50rnn            = cif.jss.

         /* признак резиденства */
         find cif where cif.cif = cif.cif no-lock no-error.
         if avail cif  then do:
            if substr(cif.geo,3,1) eq '1' then mt100.f50irs = '1'.
            else mt100.f50irs = '2'.
         end.
      
         /* сектор экономики */
         find sub-cod where sub-cod.acc = cif.cif
                        and sub-cod.sub = 'cln'
                        and sub-cod.d-cod = 'secek' no-lock no-error.
         if avail sub-cod and sub-cod.ccode ne 'msc'
            then mt100.f50seco = sub-cod.ccode.


         /* Глав Бух */
         find sub-cod where sub-cod.acc = cif.cif
                        and sub-cod.sub = 'cln'
                        and sub-cod.d-cod = 'mainbk' no-lock no-error.
         if avail sub-cod and sub-cod.ccode ne 'msc'
            then mt100.f50chief = sub-cod.ccode.

         /*  01 */
         find sub-cod where sub-cod.acc = cif.cif
                        and sub-cod.sub = 'cln'
                        and sub-cod.d-cod = 'chief' no-lock no-error.
         if avail sub-cod and sub-cod.ccode ne 'msc'
            then mt100.f50mainbk = sub-cod.ccode.

    end.

    mt100.f52b              = "TXB00".
    mt100.f57b              = remtrz.rbank.
    mt100.f59b              = remtrz.racc.
    mt100.f70date           = remtrz.valdt1.
    mt100.f70vo             = "01".

    find first sub-cod where sub-cod.d-cod = "eknp" and sub-cod.acc = remtrz.remtrz and sub-cod.sub = "rmz" no-lock no-error .
    if avail sub-cod and sub-cod.rcod <> "" and sub-cod.rcod matches "*,*,*" then 
         v-knp =  entry(3, sub-cod.rcod).
    else 
         v-knp = "000".

    mt100.f70knp            = v-knp.
    mt100.f70pso            = "01".
    mt100.f70send           = "07".
    mt100.f70prt            = "50".
    mt100.f70num            = remtrz.sqn.
    mt100.f70assign         = remtrz.rcvinfo[1] + remtrz.rcvinfo[2] + remtrz.rcvinfo[3] + remtrz.rcvinfo[4] + remtrz.rcvinfo[5] + remtrz.rcvinfo[6]. 
    mt100.f53               = remtrz.scbank.
    mt100.f54               = remtrz.rcbank.
    mt100.f59name           = remtrz.ord.
end.

run savelog ("mt100","Обработка исходящих платежей  конец " ).

