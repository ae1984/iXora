/* repnds1.p
 * MODULE
        Налоговая отчетность
 * DESCRIPTION
        Реестр счетов-фактур
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
        02.08.2008 - marinav
 * CHANGES
        06.11.09 marinav - добавлено 2 отчета
        04.05.2010 marinav - увеличена размерность поля
*/


def var nom as int.
def var nom1 as int.
def var err as int.
def shared var dt1 as date .
def shared var dt2 as date .
def shared stream m-out.
def shared stream m-out1.
def shared stream m-err.
 

def var v-sum as deci.
def var v-sum1 as deci.


def temp-table t-deb
    field nom as int
    field rnn as char
    field bin as char
    field nf  like  txb.debmon.nf
    field df  like  txb.debmon.df
    field sum as deci
    field sumn as deci
    index main rnn nf df.
    
nom = 0.

find first txb.cmp.


       put stream m-out unformatted "<tr></tr><tr align=""center""><td><h4>"  txb.cmp.name "<BR>".
       put stream m-out unformatted "<br><br></h4></td></tr><tr></tr>" skip.

       put stream m-out "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0""style=""border-collapse: collapse"">" 
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"" >N </td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" >РНН</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" >ИИН (БИН) поставщика</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" >N сч. фактуры</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" >Дата выписки <br> сч. фактуры</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" >Всего стоимость <br> без НДС</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" >Сумма НДС</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" >Сумма НДС, <br> отн. в зачет</td>"
                  "</tr>" skip.



       for each txb.debmon no-lock use-index jh.

           find first txb.jl where txb.jl.jh = txb.debmon.jh and txb.jl.jdt >= dt1 and txb.jl.jdt <= dt2 no-lock no-error.   
           if avail txb.jl then do:

               find t-deb where t-deb.rnn = txb.debmon.rnn and t-deb.nf = txb.debmon.nf and t-deb.df =  txb.debmon.df no-error.
               if not avail t-deb then do:
                    create t-deb .
                    nom = nom + 1.
                    t-deb.rnn = txb.debmon.rnn. t-deb.nf = txb.debmon.nf. t-deb.df =  txb.debmon.df. t-deb.nom = nom.
               end.
            
               find first txb.jl where txb.jl.jh = txb.debmon.jh and txb.jl.ln = 003 no-lock no-error.
               if avail txb.jl then
                      t-deb.sum = t-deb.sum + txb.jl.dam + txb.jl.cam .

               find first txb.jl where txb.jl.jh = txb.debmon.jh and txb.jl.ln = 001 no-lock no-error.
               if avail txb.jl then
                      t-deb.sumn = t-deb.sumn + txb.jl.dam + txb.jl.cam. 

               v-sum = v-sum + txb.jl.dam + txb.jl.cam.


               if txb.debmon.df < dt1 or txb.debmon.df > dt2 then do:
                          nom1 = nom1 + 1.
                          if nom1 = 1 then do: 
                                put stream m-out1 unformatted "<tr></tr><tr align=""center""><td><h4>"  txb.cmp.name "<BR>".
                                put stream m-out1 unformatted "</h4></td></tr>" skip.

                                put stream m-out1 "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0""style=""border-collapse: collapse"">" 
                                           "<tr style=""font:bold"">"
                                           "<td bgcolor=""#C0C0C0"" align=""center"" >N </td>"
                                           "<td bgcolor=""#C0C0C0"" align=""center"" >РНН</td>"
                                           "<td bgcolor=""#C0C0C0"" align=""center"" >N сч. фактуры</td>"
                                           "<td bgcolor=""#C0C0C0"" align=""center"" >Дата выписки <br> сч. фактуры</td>"
                                           "<td bgcolor=""#C0C0C0"" align=""center"" >Всего стоимость <br> без НДС</td>"
                                           "<td bgcolor=""#C0C0C0"" align=""center"" >Сумма НДС</td>"
                                           "<td bgcolor=""#C0C0C0"" align=""center"" >Сумма НДС, <br> отн. в зачет</td>"
                                           "</tr>" skip.
                          end.

                          put stream m-out1 "<tr align=""right"">"
                             "<td > " nom "</td>"
                             "<td >&nbsp;" txb.debmon.rnn format "x(12)" "</td>"
                             "<td >&nbsp;" txb.debmon.nf  "</td>"
                             "<td > " txb.debmon.df  "</td>".

                          find first txb.jl where txb.jl.jh = txb.debmon.jh and txb.jl.ln = 003 no-lock no-error.
                          if avail txb.jl then
                             put stream m-out1
                             "<td > " txb.jl.dam + txb.jl.cam   format 'zzzzzzz9.99' "</td>" .
                          else 
                             put stream m-out1  "<td > </td>".

                          find first txb.jl where txb.jl.jh = txb.debmon.jh and txb.jl.ln = 001 no-lock no-error.
                          if avail txb.jl then
                             put stream m-out1
                             "<td > " txb.jl.dam + txb.jl.cam   format 'zzzzzzz9.99' "</td>"
                             "<td > " txb.jl.dam + txb.jl.cam   format 'zzzzzzz9.99' "</td>".

                          put stream m-out1 "</tr>" skip .

               end.
           end.
       end.

       for each t-deb no-lock by t-deb.nom.

            put stream m-out "<tr align=""right"">"
                   "<td >" t-deb.nom "</td>"
                   "<td >" t-deb.rnn format "x(12)" "</td>"
                   "<td >" t-deb.bin "</td>"
                   "<td >" t-deb.nf  "</td>"
                   "<td >" t-deb.df  "</td>"
                   "<td >" t-deb.sum  format 'zzzzzzzz9' "</td>" 
                   "<td >" t-deb.sumn  format 'zzzzzzzz9' "</td>" 
                   "<td >" t-deb.sumn  format 'zzzzzzzz9' "</td>" .

            put stream m-out "</tr>" skip .
       end.

       put stream m-out  "<td ></td><td ></td><td ></td><td ></td><td ></td><td ><b> " v-sum  format 'zzzzzzzz9.99' "</td><td ><b> " v-sum  format 'zzzzzzzz9.99' "</td>".


       put stream m-out "</table>" skip.
       put stream m-out1 "</table>" skip.


 /*************************************************************************************/
       nom = 0.

       for each txb.arp where txb.arp.gl = 185100 and txb.arp.des matches "*НДС*" no-lock .

       for each txb.jl where txb.jl.acc = txb.arp.arp and txb.jl.dc = 'd' and txb.jl.jdt >= dt1 and txb.jl.jdt <= dt2 no-lock.   
           find first txb.debmon where txb.debmon.jh = txb.jl.jh no-lock no-error.
           if not avail txb.debmon then do:
               nom = nom + 1.
               if nom = 1 then do:
                   put stream m-err unformatted "<tr></tr><tr align=""center""><td><h4>"  txb.cmp.name "<BR>".
                   put stream m-err unformatted "</h4></td></tr>" skip.

                   put stream m-err "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0""style=""border-collapse: collapse"">" 
                              "<tr style=""font:bold"">"
                              "<td bgcolor=""#C0C0C0"" align=""center"" >N </td>"
                              "<td bgcolor=""#C0C0C0"" align=""center"" >Дата</td>"
                              "<td bgcolor=""#C0C0C0"" align=""center"" >Номер проводки</td>"
                              "<td bgcolor=""#C0C0C0"" align=""center"" >Номер счета</td>"
                              "<td bgcolor=""#C0C0C0"" align=""center"" >Сумма НДС</td>"
                              "<td bgcolor=""#C0C0C0"" align=""center"" >Назначение платежа</td>"
                              "</tr>" skip.
               end.

               put stream m-err unformatted "<tr align=""right"">"
                      "<td > " nom "</td>"
                      "<td > " txb.jl.jdt "</td>"
                      "<td > " txb.jl.jh  "</td>"
                      "<td >&nbsp;" txb.arp.arp "</td>"
                      "<td > " txb.jl.dam  format 'zzzzzzz9.99' "</td>"
                      "<td align=""left""> " trim(txb.jl.rem[1]) + trim(txb.jl.rem[2]) + trim(txb.jl.rem[3]) + trim(txb.jl.rem[4]) + trim(txb.jl.rem[5]) "</td>".

               put stream m-err "</tr>" skip .
               v-sum1 = v-sum1 + txb.jl.dam + txb.jl.cam.

           end.
       end.
       end.
       if v-sum1 > 0 then put stream m-err "<tr align=""right""><td></td><td></td><td></td><td><td ><b> " v-sum1  format 'zzzzzzz9.99' "</td></tr>".
       put stream m-err "</table>" skip.


 /*************************************************************************************/

