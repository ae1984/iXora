/* lb102ink.p
 * MODULE
        Платежная система
 * DESCRIPTION
        Программа формирования файла сообщения по ОПВ и СО ИР  при выгрузке
 * RUN

 * CALLER
        lb100.p, lb100g.p
 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        26.06.2009 galina
 * CHANGES
       29/07/2009 galina - добавила референс в назначение платежа
       30/07/2010 galina - ищем aaar, если бакн отправитель ЦО
       06/06/2011 evseev - переход на ИИН/БИН
       20/10/2011 evseev - изменять реквизиты Получателей, после перехода на ИИН/БИН, с РНН на ИИН. Изменение формата 102.
                           Исправил разбор строки /assign/
       24/10/2011 evseev - исправил синт. ошибку
 * BASES
        BANK COMM
*/

{chbin.i}
def input parameter iddat as date.
def input parameter v-paysys as char.
def input parameter p-cnt as integer.
def output parameter amttot like remtrz.payment.
def output parameter cnt as integer.

def shared var g-today as date .
def shared var g-ofc as cha .
def shared var v-text as cha .
def shared var vnum as int .

def var v-namebnk as char.
def var v-ks as char .  /* v-ba */
def buffer u-remtrz for remtrz .
def buffer t-bankl for bankl.
def var i as int.
def var v-unidir as cha .
def var ii as int .
def var v-dt as cha .
def var t-amt as cha .
def var v-name as char.
define variable vdetpay as character .
def var eknp-code as char.
def var filenum as int .
def var filenumstr as char.
def var daynum as cha .
def var v-tnum as char.
def var v-clecod as cha.
def var v-knp as char init "000".

def stream prot .
def stream main .

/*****/
def shared temp-table t-pnjink
  field bstr as char
  field rnn as char
  field rem as char
  field sbank as char
  field sacc as char
  field rbank as char
  field racc as char
  index main sbank sacc rbank racc rnn rem.

/***/
def var ourbank as cha .
def var v-lbmfo as cha .
def var ourbic as cha .
def var lbbic as cha .
def var regs as cha .
/* обнулим счетчик файлов */
filenum = 0.

find first t-pnjink  no-error.

/* если нет таких платежей -> выход */
if not available t-pnjink  then return.

{lb100s.i "v-paysys"}


do transaction :
  amttot = 0.
  daynum = string(g-today - date(12, 31, year(g-today) - 1), "999") .
  output stream prot to value(v-unidir + "m" + daynum + string(vnum * 100, "99999") + ".eks") append.

  for each t-pnjink  no-lock  break by t-pnjink.sbank by t-pnjink.sacc by t-pnjink .rbank by t-pnjink.racc by t-pnjink.rnn:

    find first remtrz where remtrz.remtrz = t-pnjink.rem no-lock no-error.
    if not avail remtrz then next.

    if remtrz.sbank = ourbank then do:
            find first aaar where aaar.a1 = remtrz.remtrz and aaar.a5 = remtrz.sacc /*and aaar.a4 <> "1"*/ no-lock no-error.
            if not avail aaar then next.
            find first inc100 where inc100.num = decimal(aaar.a2) and inc100.iik = aaar.a5 no-lock no-error.
            if not avail inc100 then next.

      end.
      else do:
          find first inc100 where inc100.num = integer(entry(num-entries(remtrz.sqn,'.'),remtrz.sqn,'.')) and inc100.iik = remtrz.sacc no-lock no-error.
          if not avail inc100 then next.
      end.
    if trim(inc100.reschar[1]) = '' then next.

    find first bankl where bankl.bank = remtrz.rbank no-lock no-error.
    if not avail bankl then next.

    output stream main to value("/tmp/ttt.eks") .

    filenum = 0 + vnum * 100. /* 0 - пенсионные, 1 - обычные, 2 - налоговые по новой форме */
    filenumstr = string(filenum,"99999").

    find crc where crc.crc = remtrz.tcrc no-lock no-error.
    find first t-bankl where t-bankl.bank = remtrz.sbank no-lock no-error.
    find first bankt where bankt.cbank = remtrz.sbank and bankt.crc = remtrz.tcrc no-lock no-error.

    find first sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = remtrz.remtrz and sub-cod.d-cod = "eknp" no-lock use-index dcod no-error.
    if avail sub-cod then eknp-code = sub-cod.rcod.
    else eknp-code = "".
    if eknp-code <> "" and eknp-code matches "*,*,*" then v-knp =  entry(3, sub-cod.rcod).
    else v-knp = "000".

    put stream main unformatted "\{1:" +  v-tnum + "\}" skip
                                "\{2:I102S".
    if v-paysys = "c" then put stream main unformatted "CLEAR".
                      else put stream main unformatted "GROSS".

      /*iban*/
    put stream main unformatted  "000000U3003"  + "\}" skip
                                 "\{4:" skip
                                 ":20:" remtrz.remtrz skip.

    if v-bin then do:
        if inc100.bin = "" then do:
           find first rnnu where rnnu.trn = inc100.jss  no-lock no-error.
           if avail rnnu then do:
              find current inc100 exclusive-lock no-error.
              inc100.bin = rnnu.bin.
              find current inc100 no-lock no-error.
           end. else do:
              find first rnn where rnn.trn = inc100.jss  no-lock no-error.
              if avail rnn then do:
                  find current inc100 exclusive-lock no-error.
                  inc100.bin = rnn.bin.
                  find current inc100 no-lock no-error.
              end. else do:
                  run savelog( "_lb102ink", inc100.ref + ": Не найден НП[1]").
                  return.
              end.
           end.
        end.
        put stream main unformatted ":50:/D/" + string(inc100.iik,'x(20)') skip
                                    "/NAME/" + inc100.name skip
                                    "/IDN/" + inc100.bin skip.
    end. else do:
        put stream main unformatted ":50:/D/" + string(inc100.iik,'x(20)') skip
                                    "/NAME/" + inc100.name skip
                                    "/RNN/" + inc100.jss skip.
    end.
    /*имя первого руководителя и главбуха*/
    v-name = ''. v-namebnk = ''.
    find first txb where txb.bank = remtrz.sbank and txb.consolid no-lock no-error.
    if avail txb then do:
       if connected ("txb") then disconnect "txb".
       connect value(" -db " + replace(txb.path, '/data/', '/data/b') + " -ld txb -U " + txb.login + " -P " + txb.password).
       if v-bin then run chifname(inc100.bin, output v-name, output v-namebnk).
       else run chifname(inc100.jss, output v-name, output v-namebnk).
       if connected ("txb") then disconnect "txb".
    end.
    put stream main unformatted "/CHIEF/" + v-name skip
                                "/MAINBNK/" + v-namebnk skip.


    if eknp-code <> "" and eknp-code matches "*,*,*" then do :
       put stream main unformatted "/IRS/" + substr(entry(1, eknp-code), 1, 1) skip.
       put stream main unformatted "/SECO/" + substr(entry(1, eknp-code), 2, 1) skip.
    end.

  /*iban*/
    put stream main unformatted
       ":52B:" + trim(v-clecod) + chr(10) .

    put stream main unformatted
    if remtrz.rbank ne remtrz.rcbank then
       ":54B:" + trim(remtrz.rcbank)  + chr(10)
    else ""
       ":57B:" + trim(remtrz.rbank) skip.

     /* получатель */
    if v-bin then do:
        if inc100.nkbin = '' then do:
            find first p_f_list where p_f_list.rnn = inc100.dpname no-lock no-error.
            if not avail p_f_list then do:
                run savelog( "_lb102ink", inc100.ref + ": Не найден пенсионный фонд [1]").
                return.
            end.
            find current inc100 exclusive-lock no-error.
            inc100.nkbin = p_f_list.bin.
            find current inc100 no-lock no-error.
        end.
        put stream main unformatted
        ":59:" + remtrz.racc skip
        "/NAME/" + inc100.bnf skip
        "/IDN/" + inc100.nkbin skip.
    end. else do:
        put stream main unformatted
        ":59:" + remtrz.racc skip
        "/NAME/" + inc100.bnf skip
        "/RNN/" + inc100.dpname skip.
    end.
    if eknp-code <> "" and eknp-code matches "*,*,*" then do :
       put stream main unformatted "/IRS/" + substr(entry(2, eknp-code), 1, 1) skip.
       put stream main unformatted "/SECO/" + substr(entry(2, eknp-code), 2, 1) skip.
    end.
    /***********/
    v-dt = ''.
    if remtrz.rcvinfo[2] ne '' then
    v-dt = substr(string(year(date(remtrz.rcvinfo[2]))), 3, 2) +
         string(month(date(remtrz.rcvinfo[2])), "99") + string(day(date(remtrz.rcvinfo[2])), "99") +
         chr(10).
    else
    v-dt = substr(string(year(remtrz.valdt1)), 3, 2) +
         string(month(remtrz.valdt1), "99") + string(day(remtrz.valdt1), "99") +
         chr(10).

    put stream main unformatted
    ":70:/NUM/" + string(inc100.num) skip
    "/DATE/" + v-dt
    "/VO/01" skip
    "/SEND/07" skip
    "/KNP/" + v-knp skip
    "/PSO/01" skip.
    put stream main unformatted "/PRT/05" skip.
    if not inc100.reschar[1] matches '*/PERIOD/*'  then  put stream main unformatted '/PERIOD/' + string(inc100.kbk) skip.
    v-dt = "/ASSIGN/RFB." + inc100.ref + ".".

    vdetpay = "" .
    do ii = 1 to 4:
       vdetpay = vdetpay + trim(remtrz.detpay[ii]).
    end.

    if vdetpay <> "" then do:
       if length (vdetpay) > 41 then do:
          if length (vdetpay) > 111 then do:
             if length (vdetpay) > 181 then do:
                if length (vdetpay) > 251 then do:
                   if length (vdetpay) > 321 then do:
                      if length (vdetpay) > 391 then
                        v-dt = v-dt + substring (vdetpay,1,41)
                          + chr(10) + substring (vdetpay,42,70)
                          + chr(10) + substring (vdetpay,112,70)
                          + chr(10) + substring (vdetpay,182,70)
                          + chr(10) + substring (vdetpay,252,70)
                          + chr(10) + substring (vdetpay,322,70).
                   else v-dt = v-dt + substring (vdetpay,1,41)
                          + chr(10) + substring (vdetpay,42,70)
                          + chr(10) + substring (vdetpay,112,70)
                          + chr(10) + substring (vdetpay,182,70)
                          + chr(10) + substring (vdetpay,252,70)
                          + chr(10) + substring (vdetpay,322).
                   end.
                   else v-dt = v-dt + substring (vdetpay,1,41)
                          + chr(10) + substring (vdetpay,42,70)
                          + chr(10) + substring (vdetpay,112,70)
                          + chr(10) + substring (vdetpay,182,70)
                          + chr(10) + substring (vdetpay,252).
                end.
                else v-dt = v-dt + substring (vdetpay,1,41)
                          + chr(10) + substring (vdetpay,42,70)
                          + chr(10) + substring (vdetpay,112,70)
                          + chr(10) + substring (vdetpay,182).

             end.
             else v-dt = v-dt + substring (vdetpay,1,41)
                          + chr(10) + substring (vdetpay,42,70)
                          + chr(10) + substring (vdetpay,112) .
          end.
          else v-dt = v-dt + substring (vdetpay,1,41) + chr(10) + substring (vdetpay,42).
       end.
       else v-dt = v-dt + vdetpay .
    end.
    v-dt = v-dt + chr(10).

    put stream main unformatted caps(v-dt).

    def var v-str as char.
    def var v-str1 as char.
    if v-bin then do:
        if inc100.reschar[1] matches '*^//FM*' then do:
            v-str = ''.
            do i = 1 to num-entries(inc100.reschar[1],'^'):
                  v-str = entry(i,inc100.reschar[1],'^').
                  if v-str begins ":70:/OPV/" then do:
                     v-str1 = entry(3,v-str,'/').
                     v-str1 = substr(v-str1,1,1).
                     v-str = ":70:/OPV/" + v-str1.
                  end.
                  if v-str begins "//DT/" then v-str = replace (v-str,"//DT","/DT").
                  if v-str begins "//RNN/" then do:
                     v-str1 = entry(4,v-str,'/').
                     find first rnn where rnn.trn = v-str1 no-lock no-error.
                     if avail rnn then do:
                        v-str = "/IDN/" + rnn.bin.
                     end. else do:
                        find first rnnu where rnnu.trn = v-str1 no-lock no-error.
                        if avail rnnu then do:
                           v-str = "/IDN/" + rnnu.bin.
                        end. else do:
                           run savelog( "_lb102ink", inc100.ref + ": Не найден получатель[1]").
                           return.
                        end.
                     end.
                  end.
                  if v-str begins '//FM/' then do:
                     v-str = '/FM/' + entry(4,v-str,'/').
                     /*if num-entries(v-str,'/') > 4 then do:
                        v-str = '/FM/' + entry(5,v-str,'/').
                     end.*/
                  end.
                  if v-str begins '//NM/' then do:
                     v-str = '/NM/' + entry(4,v-str,'/').
                     /*if num-entries(v-str,'/') > 4 then do:
                        v-str = '/NM/' + entry(5,v-str,'/').
                     end.*/
                  end.
                  if v-str begins '//FT/' then do:
                     v-str = '/FT/' + entry(4,v-str,'/').
                     /*if num-entries(v-str,'/') > 4 then do:
                        v-str = '/FT/' + entry(5,v-str,'/').
                     end.*/
                  end.

                  put stream main unformatted v-str skip.
            end.
        end. else do:
            do i = 1 to num-entries(inc100.reschar[1],'^'):
              put stream main unformatted entry(i,inc100.reschar[1],'^') skip.
            end.
        end.
    end. else do:
        do i = 1 to num-entries(inc100.reschar[1],'^'):
          put stream main unformatted entry(i,inc100.reschar[1],'^') skip.
        end.
    end.

    do:
       find first u-remtrz where remtrz.remtrz = u-remtrz.remtrz exclusive-lock.
       u-remtrz.t_sqn = remtrz.remtrz.
       u-remtrz.ref = "p" + daynum + filenumstr + ".eks/102/".
    end.


    t-amt = trim(string(remtrz.payment, "zzzzzzzzzzzzzzz9.99-")).
    if index(t-amt,".") > 0 then t-amt = replace(t-amt, ".", ",").

    put stream main unformatted ":32A:"
        substring(string(year(iddat)), 3, 2)
        month(iddat) format "99"
        day(iddat) format "99"
        crc.code format "x(3)"
        t-amt skip
        "-}"  skip.

    cnt = cnt + 1.
    amttot = amttot + remtrz.payment.

    put stream prot unformatted p-cnt + cnt ":" trim(remtrz.remtrz)
    if index(remtrz.sqn, ".", 19) = 0 then caps(substring(remtrz.sqn, 19))
    else caps(substring(remtrz.sqn, 19,index(remtrz.sqn, ".", 19) - 19)) ":"
    v-ks ":" remtrz.payment " - p" + daynum + filenumstr + ".eks"
    skip.

    output stream main close .

    if filenum > 0 then do:
      unix silent value("cat /tmp/ttt.eks >>" + v-unidir + "p" + daynum + filenumstr + ".eks").
      unix silent /bin/rm -f /tmp/ttt.eks.
    end.
 end. /*  for each  t-pnjink   */

end. /*do transaction*/

output stream prot close.

