/* inkprn.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
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
        --/--/2008 alex
 * BASES
        BANK COMM
 * CHANGES
        10.06.2009 galina - добавила вывод частичных погашений и рееестра для ОПВ и СО
        26.06.2009 galina - остаток суммы по частичной оплате ИР берем на дату оплаты
                            не выводим КБК для ОПВ и СО
        22.07.2009 galina - выводим трехзначный КНП
        08/06/2010 galina - выводим 20-тизначный счет плетельщика
        11/10/2011 evseev - переход на ИИН/БИН и правка из-за изменение формата 102
        24/10/2011 evseev - конвертация РНН в ИИН/БИН
        07/05/2012 evseev - разбор не 3х а 4х строк /ASSIGN/
        13.08.2012 evseev - ТЗ-1454
        09.01.2013 evseev - исправил ошибку. не было реализовано отображение тиын в сумме прописью
*/
{chbin.i}
def input parameter v-num as integer.
def input parameter v-ref as char.

def var v-ofile as char no-undo.
def var v-ifile as char no-undo.
def var v-str       as char no-undo.

def var v-dt        as char no-undo.
def var v-inkdt     as char no-undo.
def var v-time      as char no-undo.
def var v-name      as char no-undo.
def var v-rnn       as char no-undo.
def var vbin        as char no-undo.
def var v-bank      as char no-undo.
def var v-ben       as char no-undo.
def var v-beniik    as char no-undo.
def var v-benrnn    as char no-undo.
def var v-benbin    as char no-undo.
def var v-benbank   as char no-undo.
def var v-pbank     as char no-undo.
def var v-sumwrd    as char no-undo.
def var v-nazn      as char no-undo format "x(70)".
def var v-kod       as char no-undo.
def var v-iik       as char no-undo.
def var v-sum       as char no-undo.
def var v-bik       as char no-undo.
def var v-kbe       as char no-undo.
def var v-benbik    as char no-undo.
def var v-pbik      as char no-undo.
def var v-knp       as char no-undo.
def var v-kbk       as char no-undo.
def var v-vo        as char no-undo.
def var v-fsum      as char no-undo.
def var v-rfio      as char no-undo.
def var v-rsign     as char no-undo.
def var v-nfio      as char no-undo.
def var v-nsign     as char no-undo.
def var v-inkrec    as char no-undo.
def var v-pdt       as char no-undo.
def var v-psum      as char no-undo.
def var v-osum      as char no-undo.
def var v-podp      as char no-undo.
def var v-daykz     as char no-undo.
def var v-filename  as char no-undo.
def var v-tsnum     as int no-undo.
def var v-txt       as char no-undo.
def var v-vpl       as char no-undo.
def var j           as int no-undo.

def temp-table wrk no-undo
  field num like inc100.num
  field clname like inc100.name
  field iik like inc100.iik
  field sum like inc100.sum
  field ost as deci
  field stat like inc100.stat
  field rdt like inc100.rdt
  field rtm like inc100.rtm
  field mnu like inc100.mnu
  field bank as char
  field bankname as char
  field dtpay as date
  field sumpay as deci
  index idx is primary dtpay.

def temp-table t-s400 no-undo
    field num as int
    field str as char format "x(100)"
    index idx is primary num.

def stream v-out.
def stream r-in.

def stream v-out2.
def var v-fm as char no-undo.
def var v-nm as char no-undo.
def var v-ft as char no-undo.
def var v-sik as char no-undo.
def var v-rnn2 as char no-undo.
def var v-dtb as char no-undo.
def var v-sum2 as char no-undo.
def var i as integer no-undo.

if v-bin then v-ifile = "/data/docs/inkprnbin.htm". else v-ifile = "/data/docs/inkprn.htm".
v-ofile = "ink.htm".

find first inc100 where inc100.num eq v-num and inc100.ref eq v-ref no-lock no-error.

run pkdefdtstr(inc100.rdt, output v-dt, output v-daykz).
run pkdefdtstr(date(substr(inc100.dt, 5, 2) + substr(inc100.dt, 3, 2) + substr(inc100.dt, 1, 2)), output v-inkdt, output v-daykz).
v-inkrec = "<table style= ""border-collapse:collapse; width:100%; font-size:12px; font-family:'Times New Roman';""><tr valign= top align= center><td style=""border-width:1px; border-style:solid; border-color:black; width:25%;""> Реквизиты<br>инкассового распоряжения<br>на сумму частичной оплаты</td><td style=""border-width:1px; border-style:solid; border-color:black; width:15%;"">Дата<br>частичного платежа</td><td style=""border-width:1px; border-style:solid; border-color:black; width:15%;"">Сумма<br>частичного платежа</td><td style=""border-width:1px; border-style:solid; border-color:black; width:25%;"">Остаток суммы<br>инкассового распоряжения</td><td style=""border-width:1px; border-style:solid; border-color:black; width:20%;"">Подписи<br>уполномоченных лиц</td></tr>".
if inc100.vo <>'09' and inc100.vo <>'07' then do:
    run report.
    find first wrk no-lock no-error.
    if avail wrk then do:
      for each wrk no-lock:
        v-inkrec = v-inkrec + "<tr valign= top align= center ><td style=""border-width:1px; border-style:solid; border-color:black; width:25%;""> №" +
                   string(inc100.num) + " от " + v-dt + "</td><td style=""border-width:1px; border-style:solid; border-color:black; width:25%;"">" +
                   string(wrk.dtpay,'99/99/9999') + "</td><td style=""border-width:1px; border-style:solid; border-color:black; width:15%;"">" +
                   replace(string(wrk.sumpay, ">>>>>>>>>>>9.99"), ",", ".") + "</td><td style=""border-width:1px; border-style:solid; border-color:black; width:25%;"">" +
                   replace(string(wrk.ost, ">>>>>>>>>>>9.99"), ",", ".") + "</td><td  style=""border-width:1px; border-style:solid; border-color:black; width:20%;""></td></tr>".
      end.
    end.
end.
v-inkrec = v-inkrec + "</table>".
v-time = string(inc100.rtm, "hh:mm").
v-name = inc100.name.
v-rnn = inc100.jss.
vbin = inc100.bin.
v-iik = inc100.iik.
find first aaa where aaa.aaa = v-iik no-lock no-error.
if avail aaa then do:
   find first cif where cif.cif = aaa.cif no-lock no-error.
end.

if vbin = "" then do:
   if avail cif then  do:
      vbin = cif.bin.
      find current inc100 exclusive-lock.
      inc100.bin = vbin.
      find current inc100 no-lock.
   end.
end.

if v-bin and vbin = "" then do:
   find first rnn where rnn.trn = v-rnn no-lock no-error.
   if avail rnn then do:
      vbin = rnn.bin.
   end. else do:
         find first rnnu where rnnu.trn = v-rnn no-lock no-error.
         if avail rnnu then do:
            vbin = rnnu.bin.
         end. else do:
            vbin = ''.
         end.
   end.
   find current inc100 exclusive-lock.
   inc100.bin = vbin.
   find current inc100 no-lock.
   if vbin = "" then vbin = "Не найден БИН. РНН:" + v-rnn.
end.
v-ben = inc100.bnf.
v-benrnn = inc100.dpname.
v-benbin = inc100.nkbin.
if v-bin and v-benbin = "" then do:
   find first taxnk where taxnk.rnn = inc100.dpname no-lock no-error.
   if avail taxnk then do:
      v-benbin = taxnk.bin.
   end. else do:
      find first p_f_list where p_f_list.rnn = inc100.dpname no-lock no-error.
      if avail p_f_list then do:
         v-benbin = p_f_list.bin.
      end. else do:
         v-benbin = ''.
      end.
   end.
   find current inc100 exclusive-lock.
   inc100.nkbin = v-benbin.
   find current inc100 no-lock.
end.

v-sum = replace(string(inc100.sum, ">>>>>>>>>>>9.99"), ",", ".").
v-knp = string(inc100.knp).
if length(v-knp) < 3 then v-knp = fill('0',3 - length(v-knp)) + v-knp.
if inc100.vo <> '09' and inc100.vo <> '07' then v-kbk = string(inc100.kbk, "999999").
v-vo = inc100.vo.
v-fsum = v-sum.
v-kod = inc100.irsseco.
v-kbe = "11".

run Sm-vrd(v-sum, output v-sumwrd).
v-sumwrd = v-sumwrd + " тенге".
if int(inc100.sum) <> inc100.sum then do:
   v-sumwrd = v-sumwrd + ' ' + entry(2,string(inc100.sum),'.') + ' тиын' no-error.
end. else v-sumwrd = v-sumwrd + ' 00 тиын'.
v-sumwrd = v-sumwrd + '.'.

find first txb where txb.bank eq inc100.bank no-lock no-error.
if avail txb then v-bik = txb.mfo.

v-filename = inc100.filename.
empty temp-table t-s400.
v-tsnum = 0.
v-str = "".


input stream r-in from value("/data/import/inkarc/" + string(year(inc100.rdt),"9999") + string(month(inc100.rdt),"99") + string(day(inc100.rdt),"99") + "/" + v-filename).
repeat:
    import stream r-in unformatted v-txt.
    if v-txt ne "" then do:
        create t-s400.
        assign t-s400.num = v-tsnum
            t-s400.str = v-txt.
    end.
    v-tsnum = v-tsnum + 1.
end.

input stream r-in close.
find first t-s400 where t-s400.str begins "/ASSIGN/" no-lock no-error.
if avail t-s400 then do:
    v-nazn = entry(3, t-s400.str, "/").
    do j = 1 to 4:
        find next t-s400 no-lock no-error.
        if t-s400.str begins ":" or t-s400.str begins "/" or t-s400.str begins "-" then leave.
        v-nazn = v-nazn + t-s400.str.
    end.
end.

if inc100.vo <> '09' and inc100.vo <> '07' then do:
    find first t-s400 where t-s400.str begins ":50:" no-lock no-error.
    if avail t-s400 then v-beniik = entry(3, t-s400.str, "/").

    find first t-s400 where t-s400.str begins ":52B:" no-lock no-error.

    if avail t-s400 then do:
        v-benbik = entry(3, t-s400.str, ":").
        find first bankl where bankl.bank eq v-benbik no-lock no-error.
        if avail bankl then v-benbank = bankl.name.
    end.


    find first budcodes where budcodes.code eq int(v-kbk) no-lock no-error.
    if avail budcodes then v-vpl = substr(budcodes.name, 4).
end.

def var v-position as integer no-undo.
def var v-str1 as char no-undo.

if inc100.vo = '09' or inc100.vo = '07' then do:
    find first t-s400 where t-s400.str begins "/ASSIGN/" no-lock no-error.
    if avail t-s400 then v-position = t-s400.num.

    find first t-s400 where t-s400.str begins ":59:" no-lock no-error.
    if avail t-s400 then v-beniik = entry(3, t-s400.str, ":").

    find first t-s400 where t-s400.str begins ":57B:" no-lock no-error.

    if avail t-s400 then do:
        v-benbik = entry(3, t-s400.str, ":").
        find first bankl where bankl.bank eq v-benbik no-lock no-error.
        if avail bankl then v-benbank = bankl.name.
    end.

    for each t-s400 where t-s400.str begins ":32B:" no-lock:
       if v-sum2 <> '' then v-sum2 = v-sum2 + ','.
       v-sum2 = v-sum2 + replace(substr(entry(3,t-s400.str,':'),4),',','.').
    end.

    if v-bin then do:
        for each t-s400 where t-s400.str begins "/OPV/" no-lock:
           if t-s400.num < v-position then next.
           if v-sik <> '' then v-sik = v-sik + ','.
           v-sik = v-sik + entry(3,t-s400.str,'/').
        end.
        for each t-s400 where t-s400.str begins "/FM/" no-lock:
           if t-s400.num < v-position then next.
           if v-fm <> '' then v-fm = v-fm + ','.
           v-fm = v-fm + entry(3,t-s400.str,'/').
        end.
        for each t-s400 where t-s400.str begins "/NM/" no-lock:
           if t-s400.num < v-position then next.
           if v-nm <> '' then v-nm = v-nm + ','.
           v-nm = v-nm + entry(3,t-s400.str,'/').
        end.

        for each t-s400 where t-s400.str begins "/FT/" no-lock:
           if t-s400.num < v-position then next.
           if v-ft <> '' then v-ft = v-ft + ','.
           v-ft = v-ft + entry(3,t-s400.str,'/').
        end.

        for each t-s400 where t-s400.str begins "//FM/" no-lock:
           if v-fm <> '' then v-fm = v-fm + ','.
           v-fm = v-fm + entry(4,t-s400.str,'/').
        end.
        for each t-s400 where t-s400.str begins "//NM/" no-lock:
           if v-nm <> '' then v-nm = v-nm + ','.
           v-nm = v-nm + entry(4,t-s400.str,'/').
        end.

        for each t-s400 where t-s400.str begins "//FT/" no-lock:
           if v-ft <> '' then v-ft = v-ft + ','.
           v-ft = v-ft + entry(4,t-s400.str,'/').
        end.

        for each t-s400 where t-s400.str begins "/IDN/" no-lock:
           if t-s400.num < v-position then next.
           if v-rnn2 <> '' then v-rnn2 = v-rnn2 + ','.
           v-rnn2 = v-rnn2 + entry(3,t-s400.str,'/').
        end.
        for each t-s400 where t-s400.str begins "//RNN/" no-lock:
            if v-rnn2 <> '' then v-rnn2 = v-rnn2 + ','.
            v-str1 = entry(4,t-s400.str,'/').
            find first rnn where rnn.trn = v-str1 no-lock no-error.
            if avail rnn then do:
               v-str1 = rnn.bin.
            end. else do:
               find first rnnu where rnnu.trn = v-str1 no-lock no-error.
               if avail rnnu then do:
                  v-str1 = rnnu.bin.
               end. else do:
                  v-str1 = ''.
               end.
            end.
            if v-str1 = '' then v-str1 = 'Не найден ИИН. РНН:' + entry(4,t-s400.str,'/').
            v-rnn2 = v-rnn2 + v-str1.
        end.

        for each t-s400 where t-s400.str begins "/DT/" no-lock:
           if t-s400.num < v-position then next.
           if v-dtb <> '' then v-dtb = v-dtb + ','.
           v-dtb = v-dtb + entry(3,t-s400.str,'/').
        end.
        for each t-s400 where t-s400.str begins "//DT/" no-lock:
           if v-dtb <> '' then v-dtb = v-dtb + ','.
           v-dtb = v-dtb + entry(4,t-s400.str,'/').
        end.
    end. else do:
        for each t-s400 where t-s400.str begins ":70:/OPV/" no-lock:
           if v-sik <> '' then v-sik = v-sik + ','.
           v-sik = v-sik + entry(3,t-s400.str,'/').
        end.
        for each t-s400 where t-s400.str begins "//FM/" no-lock:
           if v-fm <> '' then v-fm = v-fm + ','.
           v-fm = v-fm + entry(4,t-s400.str,'/').
        end.
        for each t-s400 where t-s400.str begins "//NM/" no-lock:
           if v-nm <> '' then v-nm = v-nm + ','.
           v-nm = v-nm + entry(4,t-s400.str,'/').
        end.
        for each t-s400 where t-s400.str begins "//FT/" no-lock:
           if v-ft <> '' then v-ft = v-ft + ','.
           v-ft = v-ft + entry(4,t-s400.str,'/').
        end.
        if v-bin then do:
            for each t-s400 where t-s400.str begins "//IDN/" no-lock:
               if v-rnn2 <> '' then v-rnn2 = v-rnn2 + ','.
               v-rnn2 = v-rnn2 + entry(4,t-s400.str,'/').
            end.
        end. else do:
            for each t-s400 where t-s400.str begins "//RNN/" no-lock:
               if v-rnn2 <> '' then v-rnn2 = v-rnn2 + ','.
               v-rnn2 = v-rnn2 + entry(4,t-s400.str,'/').
            end.
        end.
        for each t-s400 where t-s400.str begins "//DT/" no-lock:
           if v-dtb <> '' then v-dtb = v-dtb + ','.
           v-dtb = v-dtb + entry(4,t-s400.str,'/').
        end.
    end.
end.
find first cmp no-lock no-error.
if avail cmp then v-bank = cmp.name.


v-pbank = "".



output stream v-out to value(v-ofile).
run upd_field.
unix silent value("cptwin " + v-ofile + " iexplore").

if inc100.vo = '09' or inc100.vo = '07' then do:
    output stream v-out2 to reestr.htm.
    {html-title.i
     &stream = " stream v-out2 "
     &size-add = "xx-"
     &title = " Реестр по пенс. и соц. платежам "
    }

    if v-bin then do:
        put stream v-out2 unformatted
        "<P align = ""center""><FONT size=""3"" face=""Times New Roman""><B>Реестр к инкассовому рапоряжению № " v-num "<br>от " v-dt "</B></FONT></P>"
        "<table style= ""border-collapse:collapse; width:100%; font-size:12px; font-family:'Times New Roman'; border-color:black;"">"
        "<TR align=""center"" valign=""center"" style=""font:bold"">"
        "<td style=""border-width:1px; border-style:solid; border-color:black;"" >№ Поля <br>по порядку</td>"
        "<td style=""border-width:1px; border-style:solid; border-color:black;"">ФИО</td>"
        /*"<td style=""border-width:1px; border-style:solid; border-color:black;"">СИК</td>"*/
        "<td style=""border-width:1px; border-style:solid; border-color:black;"">ИИН</td>"
        "<td style=""border-width:1px; border-style:solid; border-color:black;"">Дата<br>рождения</td>"
        "<td style=""border-width:1px; border-style:solid; border-color:black;"">Сумма</td></tr>".
        do i = 1 to num-entries(v-rnn2):
          put stream v-out2 unformatted "<tr>"
          "<td style=""border-width:1px; border-style:solid; border-color:black;"">" i "</td>"
          "<td style=""border-width:1px; border-style:solid; border-color:black;"">" entry(i,v-fm) " " entry(i,v-nm) " "  entry(i,v-ft) "</td>"
          /*"<td style=""border-width:1px; border-style:solid; border-color:black;"">" entry(i,v-sik) "</td>"*/
          "<td style=""border-width:1px; border-style:solid; border-color:black;"">" entry(i,v-rnn2) "</td>"
          "<td style=""border-width:1px; border-style:solid; border-color:black;"">" substr(entry(i,v-dtb),7,2) "/" substr(entry(i,v-dtb),5,2) '/' substr(entry(i,v-dtb),1,4) "</td>"
          "<td style=""border-width:1px; border-style:solid; border-color:black;"">" entry(i,v-sum2) "</td></tr>".
        end.
        put stream v-out2 unformatted "<tr>"
        "<td colspan = ""4"" align = ""right""><b>Итого</b></td>"
        "<td ><b>" v-sum "</b></td></tr>"
        /*put stream v-out2 unformatted*/ "</table>".
    end. else do:
        put stream v-out2 unformatted
        "<P align = ""center""><FONT size=""3"" face=""Times New Roman""><B>Реестр к инкассовому рапоряжению № " v-num "<br>от " v-dt "</B></FONT></P>"
        "<table style= ""border-collapse:collapse; width:100%; font-size:12px; font-family:'Times New Roman'; border-color:black;"">"
        "<TR align=""center"" valign=""center"" style=""font:bold"">"
        "<td style=""border-width:1px; border-style:solid; border-color:black;"" >№ Поля <br>по порядку</td>"
        "<td style=""border-width:1px; border-style:solid; border-color:black;"">ФИО</td>"
        "<td style=""border-width:1px; border-style:solid; border-color:black;"">СИК</td>"
        "<td style=""border-width:1px; border-style:solid; border-color:black;"">РНН</td>"
        "<td style=""border-width:1px; border-style:solid; border-color:black;"">Дата<br>рождения</td>"
        "<td style=""border-width:1px; border-style:solid; border-color:black;"">Сумма</td></tr>".
        do i = 1 to num-entries(v-rnn2):
          put stream v-out2 unformatted "<tr>"
          "<td style=""border-width:1px; border-style:solid; border-color:black;"">" i "</td>"
          "<td style=""border-width:1px; border-style:solid; border-color:black;"">" entry(i,v-fm) " " entry(i,v-nm) " "  entry(i,v-ft) "</td>"
          "<td style=""border-width:1px; border-style:solid; border-color:black;"">" entry(i,v-sik) "</td>"
          "<td style=""border-width:1px; border-style:solid; border-color:black;"">" entry(i,v-rnn2) "</td>"
          "<td style=""border-width:1px; border-style:solid; border-color:black;"">" substr(entry(i,v-dtb),7,2) "/" substr(entry(i,v-dtb),5,2) '/' substr(entry(i,v-dtb),1,4) "</td>"
          "<td style=""border-width:1px; border-style:solid; border-color:black;"">" entry(i,v-sum2) "</td></tr>".
        end.
        put stream v-out2 unformatted "<tr>"
        "<td colspan = ""5"" align = ""right""><b>Итого</b></td>"
        "<td ><b>" v-sum "</b></td></tr>"
        "</table>".
    end.
    {html-end.i}
    output stream v-out2 close.
    unix silent value("cptwin reestr.htm iexplore").
end.



/**/
procedure report.
    def buffer b-wrk for wrk.
    def var v-ost as deci no-undo init 0.
    find first aas where aas.aaa = inc100.iik and aas.fnum = string(inc100.num) no-lock no-error.
    /*if avail aas then v-ost = deci(aas.docprim).*/
    for each aaar where aaar.a5 = inc100.iik and aaar.a4 = '1' and aaar.a2 = string(inc100.num) no-lock break by date(a6):
          find last b-wrk where b-wrk.iik = inc100.iik and b-wrk.num = int(aaar.a2) no-lock  no-error .
          if avail b-wrk then v-ost = b-wrk.ost. else v-ost = inc100.sum.
          v-ost = v-ost - deci(aaar.a3).
          create wrk.
          assign wrk.num = inc100.num
                 wrk.clname = inc100.name
                 wrk.iik = inc100.iik
                 wrk.sum = inc100.sum
                 wrk.ost = v-ost
                 wrk.stat = inc100.stat
                 wrk.rdt = inc100.rdt
                 wrk.rtm = inc100.rtm
                 wrk.mnu = inc100.mnu
                 wrk.bank = inc100.bank
                 wrk.dtpay = date(aaar.a6)
                 wrk.sumpay = deci(aaar.a3).
    end. /* for each aaar */
end.
/**/


procedure upd_field.

input from value(v-ifile).
repeat:
    import unformatted v-str.
    v-str = trim(v-str).
    repeat:
        if v-str matches "*\{\&v-dt\}*" then do:
            v-str = replace (v-str, "\{\&v-dt\}", v-dt).
            next.
        end.
        if v-str matches "*\{\&v-inkdt\}*" then do:
            v-str = replace (v-str, "\{\&v-inkdt\}", v-inkdt).
            next.
        end.
        if v-str matches "*\{\&v-time\}*" then do:
            v-str = replace (v-str, "\{\&v-time\}", v-time).
            next.
        end.

        if v-str matches "*\{\&v-num\}*" then do:
            v-str = replace (v-str, "\{\&v-num\}", string(v-num)).
            next.
        end.
        if v-str matches "*\{\&v-name\}*" then do:
            v-str = replace (v-str, "\{\&v-name\}", v-name).
            next.
        end.
        if v-str matches "*\{\&v-rnn\}*" then do:
            v-str = replace (v-str, "\{\&v-rnn\}", v-rnn).
            next.
        end.
        if v-str matches "*\{\&v-bin\}*" then do:
            v-str = replace (v-str, "\{\&v-bin\}", vbin).
            next.
        end.
        if v-str matches "*\{\&v-bank\}*" then do:
            v-str = replace (v-str, "\{\&v-bank\}", v-bank).
            next.
        end.
        if v-str matches "*\{\&v-ben\}*" then do:
            v-str = replace (v-str, "\{\&v-ben\}", v-ben).
            next.
        end.
        if v-str matches "*\{\&v-benrnn\}*" then do:
            v-str = replace (v-str, "\{\&v-benrnn\}", v-benrnn).
            next.
        end.
        if v-str matches "*\{\&v-benbin\}*" then do:
            v-str = replace (v-str, "\{\&v-benbin\}", v-benbin).
            next.
        end.
        if v-str matches "*\{\&v-benbank\}*" then do:
            v-str = replace (v-str, "\{\&v-benbank\}", v-benbank).
            next.
        end.
        if v-str matches "*\{\&v-pbank\}*" then do:
            v-str = replace (v-str, "\{\&v-pbank\}", v-pbank).
            next.
        end.
        if v-str matches "*\{\&v-sumwrd\}*" then do:
            v-str = replace (v-str, "\{\&v-sumwrd\}", v-sumwrd).
            next.
        end.
        if v-str matches "*\{\&v-nazn\}*" then do:
            v-str = replace (v-str, "\{\&v-nazn\}", v-nazn).
            next.
        end.

        if v-str matches "*\{\&v-kod\}*" then do:
            v-str = replace (v-str, "\{\&v-kod\}", v-kod).
            next.
        end.
        if v-str matches "*\{\&v-iik\}*" then do:
            v-str = replace (v-str, "\{\&v-iik\}", string(v-iik, "x(20)")).
            next.
        end.
        if v-str matches "*\{\&v-sum\}*" then do:
            v-str = replace (v-str, "\{\&v-sum\}", v-sum).
            next.
        end.
        if v-str matches "*\{\&v-bik\}*" then do:
            v-str = replace (v-str, "\{\&v-bik\}", v-bik).
            next.
        end.
        if v-str matches "*\{\&v-kbe\}*" then do:
            v-str = replace (v-str, "\{\&v-kbe\}", v-kbe).
            next.
        end.
        if v-str matches "*\{\&v-beniik\}*" then do:
            v-str = replace (v-str, "\{\&v-beniik\}", v-beniik).
            next.
        end.
        if v-str matches "*\{\&v-benbik\}*" then do:
            v-str = replace (v-str, "\{\&v-benbik\}", v-benbik).
            next.
        end.
        if v-str matches "*\{\&v-pbik\}*" then do:
            v-str = replace (v-str, "\{\&v-pbik\}", v-pbik).
            next.
        end.
        if v-str matches "*\{\&v-knp\}*" then do:
            v-str = replace (v-str, "\{\&v-knp\}", v-knp).
            next.
        end.

        if v-str matches "*\{\&v-kbk\}*" then do:
            v-str = replace (v-str, "\{\&v-kbk\}", v-kbk).
            next.
        end.
        if v-str matches "*\{\&v-vo\}*" then do:
            v-str = replace (v-str, "\{\&v-vo\}", v-vo).
            next.
        end.
        if v-str matches "*\{\&v-fsum\}*" then do:
            v-str = replace (v-str, "\{\&v-fsum\}", v-fsum).
            next.
        end.

        if v-str matches "*\{\&v-rfio\}*" then do:
            if v-rfio ne "" then v-str = replace (v-str, "\{\&v-rfio\}", v-rfio).
            else v-str = replace (v-str, "\{\&v-rfio\}", "_____________________________________________________").
            next.
        end.
        if v-str matches "*\{\&v-rsign\}*" then do:
            if v-rsign ne "" then v-str = replace (v-str, "\{\&v-rsign\}", v-rsign).
            else v-str = replace (v-str, "\{\&v-rsign\}", "_____________________________________________________").
            next.
        end.
        if v-str matches "*\{\&v-nfio\}*" then do:
            if v-nfio ne "" then v-str = replace (v-str, "\{\&v-nfio\}", v-nfio).
            else v-str = replace (v-str, "\{\&v-nfio\}", "_____________________________________________________").
            next.
        end.
        if v-str matches "*\{\&v-nsign\}*" then do:
            if v-nsign ne "" then v-str = replace (v-str, "\{\&v-nsign\}", v-nsign).
            else v-str = replace (v-str, "\{\&v-nsign\}", "_____________________________________________________").
            next.
        end.

        if v-str matches "*\{\&v-inkrec\}*" then do:
            v-str = replace (v-str, "\{\&v-inkrec\}", v-inkrec).
            next.
        end.
        if v-str matches "*\{\&v-pdt\}*" then do:
            v-str = replace (v-str, "\{\&v-pdt\}", v-pdt).
            next.
        end.
        if v-str matches "*\{\&v-psum\}*" then do:
            v-str = replace (v-str, "\{\&v-psum\}", v-psum).
            next.
        end.
        if v-str matches "*\{\&v-osum\}*" then do:
            v-str = replace (v-str, "\{\&v-osum\}", v-osum).
            next.
        end.
        if v-str matches "*\{\&v-podp\}*" then do:
            v-str = replace (v-str, "\{\&v-podp\}", v-podp).
            next.
        end.
        if v-str matches "*\{\&v-vpl\}*" then do:
            v-str = replace (v-str, "\{\&v-vpl\}", v-vpl).
            next.
        end.
        leave.
    end.
    put stream v-out unformatted v-str skip.
end.
input close.
output stream v-out close.

end.