/* depport_data.p
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
        26/10/2011 evseev
 * BASES
        TXB
 * CHANGES
*/

def input parameter v-bank     as char.
def shared var dt as date.
def shared var typerep as integer.
def shared var d1 as integer.
def shared var d2 as integer.

def var v-type as char.
def var doe as integer.
def var doe1 as integer.
def var v-edt as date.

def shared temp-table tbl no-undo
    field period    as char
    field period1    as char
	field gl        like txb.aaa.gl
	field gl2        like txb.aaa.gl
    field filial    as char
    field aaa       like txb.aaa.aaa
    field clname    as char
    field crc       like txb.aaa.crc
    field rdt       like txb.aaa.regdt
    field edt       like txb.aaa.expdt
    field rate      like txb.aaa.rate
    field opnamt    like txb.aaa.opnamt
    field ostcrc    as decimal
    field ostkzt    as decimal
    field sumcrc    as decimal
    field sumkzt    as decimal
    field kurs      like txb.crchis.rate[1]
    field depname   as char
    field str1      as char
    field str2      as char
    field str3      as char
    field paydate   as date
    field paysumcrc as decimal
    field paysumkzt as decimal.



if typerep = 1 then v-type = "".
if typerep = 2 then v-type = "B".
if typerep = 3 then v-type = "P".

def var v-x3 as char.
def var v-period as char.
def var v-period1 as char.
def var v-rate as decimal.
def var v-kurs as decimal.
def var v-bal as decimal.
def var v-bal2 as decimal.
def var v-uslov as char.
def var v-osnov as char.
def var v-attrib as char.
def var nm as char.
def var v-opnamt as decimal.
def var v-glr like txb.trxlevgl.glr.
def var v-paydt as date.

for each txb.aaa where txb.aaa.regdt < dt no-lock:
    if length(txb.aaa.aaa) <> 20 then next.
    /*
    if txb.aaa.sta = "C" then do:
       find first txb.sub-cod where txb.sub-cod.sub = 'cif' and txb.sub-cod.acc = txb.aaa.aaa and txb.sub-cod.d-cod = 'clsa' no-lock no-error.
       if avail txb.sub-cod then do:
          if txb.sub-cod.rdt <= dt then next.
       end.
    end.
    */
    if not (txb.aaa.gl >=220600 and txb.aaa.gl <=220699) then
     if not (txb.aaa.gl >=220700 and txb.aaa.gl <=220799) then
      if not (txb.aaa.gl >=220800 and txb.aaa.gl <=220899) then
       if not (txb.aaa.gl >=221300 and txb.aaa.gl <=221399) then
        if not (txb.aaa.gl >=221500 and txb.aaa.gl <=221599) then
         if not (txb.aaa.gl >=221700 and txb.aaa.gl <=221799) then
          if not (txb.aaa.gl >=221900 and txb.aaa.gl <=221999) then
           if not (txb.aaa.gl >=222200 and txb.aaa.gl <=222299) then
            if not (txb.aaa.gl >=222300 and txb.aaa.gl <=222399) then
             if not (txb.aaa.gl >=222900 and txb.aaa.gl <=222999) then
              if not (txb.aaa.gl >=224000 and txb.aaa.gl <=224099) then next.

    find first txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
    if not avail txb.cif then do:
      run savelog( "depport", "[5] Не найдена запись в cif. aaa=" + txb.aaa.aaa + " lgr=" + txb.aaa.lgr + " gl=" + string(txb.aaa.gl)).
      next.
    end.
    if v-type <> "" then do:
       if txb.cif.type <> v-type then next.
    end.


    find first txb.acvolt where txb.acvolt.aaa = txb.aaa.aaa no-lock no-error.
    if not avail txb.acvolt then do:
      run savelog( "depport", "[1] Не найдена запись в acvolt. Операция продолжена... aaa=" + txb.aaa.aaa + " lgr=" + txb.aaa.lgr + " gl=" + string(txb.aaa.gl) ).
      /*next.*/
      v-edt = txb.aaa.expdt.
      /*if date(txb.acvolt.x3) < dt then next.*/
      doe = v-edt - dt.
    end. else do:
        /*if date(txb.acvolt.x3) < dt then next.*/
        v-edt = date(txb.acvolt.x3).
        doe = v-edt - dt.
    end.
    /*
    if d1 > doe and d2 < doe then do:
       run savelog( "depport", "[6] if d1 > doe and d2 < doe then. aaa=" + txb.aaa.aaa + " lgr=" + txb.aaa.lgr + " gl=" + string(txb.aaa.gl)).
       next.
    end.
    */

    v-period = "".
    if doe >= 0    and doe <= 6     then v-period = "до 7 дней"   .
    if doe >= 7    and doe <= 30    then v-period = "до 1 месяца" .
    if doe >= 31   and doe <= 92    then v-period = "до 3 месяцев".
    if doe >= 93   and doe <= 182   then v-period = "до 6 месяцев".
    if doe >= 183  and doe <= 365   then v-period = "до 1 года"   .
    if doe >= 366  and doe <= 1095  then v-period = "до 3 лет"    .
    if doe >= 1096 and doe <= 9999999 then v-period = "свыше 3 лет" .
    if v-edt = ? or v-edt < dt then v-period = "до 7 дней"   .

    /*run savelog('depport_data', txb.aaa.aaa ).
    run savelog('depport_data',string(v-edt)).
    run savelog('depport_data',string(dt) ).
    run savelog('depport_data',string(doe)).
    run savelog('depport_data',v-period).
    run savelog('depport_data',txb.cif.prefix + " " + txb.cif.name).*/

    v-rate = 0.
    find last txb.accr where txb.accr.aaa = txb.aaa.aaa and txb.accr.fdt < dt no-lock no-error.
    if avail txb.accr then v-rate = txb.accr.rate.
    if v-rate = 0 then do:
      run savelog( "depport", "[2] В accr % ставка=0. aaa=" + txb.aaa.aaa ).
      v-rate = txb.aaa.rate.
    end.

    find first txb.lgr where txb.lgr.lgr = txb.aaa.lgr no-lock no-error.
    if not avail txb.lgr then do:
      run savelog( "depport", "[3] Не найдена запись в lgr. aaa=" + txb.aaa.aaa + " lgr=" + txb.aaa.lgr + " gl=" + string(txb.aaa.gl) ).
      next.
    end.


    find last txb.crchis where txb.crchis.crc = txb.aaa.crc and txb.crchis.rdt < dt no-lock no-error.
    if not avail txb.crchis then do:
      run savelog( "depport", "[4] Не найдена запись в crchis. aaa=" + txb.aaa.aaa + " дата=" + string(dt) + " lgr=" + txb.aaa.lgr + " gl=" + string(txb.aaa.gl)).
      next.
    end.
    v-kurs = txb.crchis.rate[1].

    v-bal = 0.
    run lonbalcrc_txb('cif',txb.aaa.aaa,dt,"1",no,txb.aaa.crc,output v-bal).
    v-bal = - v-bal.

    v-bal2 = 0.
    run lonbalcrc_txb('cif',txb.aaa.aaa,dt,"2",no,txb.aaa.crc,output v-bal2).
    v-bal2 = - v-bal2.


    v-uslov = ''.
    v-osnov = ''.
    v-attrib = ''.
    find txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "clnuoo" and txb.sub-cod.acc = txb.aaa.cif no-lock no-error. /*условия обслуживания и основание*/
    if avail txb.sub-cod then do:
       if txb.sub-cod.ccode = 'msc' then do:
         v-uslov = ''.
         v-osnov = ''.
       end.
       else do:
         v-osnov = replace(txb.sub-cod.rcode,'^',' ').
         find txb.codfr where txb.codfr.codfr = "clnuoo" and txb.codfr.code = txb.sub-cod.ccode no-lock no-error.
         if avail txb.codfr then do:
           v-uslov = txb.codfr.name[1].
         end.
       end.
    end.


    if txb.cif.jss <> '' then do:
        find first prisv where prisv.rnn = txb.cif.jss and prisv.rnn <> '' no-lock no-error.
        if avail prisv then do:
             find first txb.codfr where txb.codfr.codfr = "affil" and txb.codfr.code = prisv.specrel no-lock.
             if avail txb.codfr then v-attrib = txb.codfr.name[1].
             if not avail txb.codfr then v-attrib = 'Нет такого справочника'.
        end. else do:
            if num-entries(trim(txb.cif.name),' ') > 0 then nm = entry(1,trim(txb.cif.name),' ').
            if num-entries(trim(txb.cif.name),' ') > 1 and entry(2,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(2,trim(txb.cif.name),' ').
            if num-entries(trim(txb.cif.name),' ') > 2 and entry(3,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(3,trim(txb.cif.name),' ').
            find first prisv where trim(prisv.name) = nm no-lock no-error.
            if avail prisv then do:
                 find first txb.codfr where txb.codfr.codfr = "affil" and txb.codfr.code = prisv.specrel no-lock.
                 if avail txb.codfr then v-attrib = txb.codfr.name[1].
                 if not avail txb.codfr then v-attrib = 'Нет такого справочника'.
            end. else v-attrib = "Не связанное лицо".
        end.
    end.


    v-opnamt = txb.aaa.opnamt.
    find first txb.jl where txb.jl.whn >= txb.aaa.regdt and  txb.jl.acc = txb.aaa.aaa and txb.jl.gl = txb.aaa.gl and txb.jl.dc = 'c' no-lock  no-error.
    if avail txb.jl then v-opnamt = txb.jl.cam.

    v-glr = 0.
    find txb.trxlevgl where txb.trxlevgl.gl = aaa.gl and txb.trxlevgl.subled = "cif" and txb.trxlevgl.level = 2 no-lock no-error.
    if avail txb.trxlevgl then v-glr = txb.trxlevgl.glr.

    v-paydt = ?.
    v-period1 = "".
    if avail txb.acvolt then do:
        if txb.acvolt.sts = "d"  then do:
           run EventHandlerDt("F", dt, date(txb.acvolt.x1), v-edt - 1, output v-paydt).
        end. else do:
           run EventHandlerDt(txb.lgr.intpay, dt, date(txb.acvolt.x1), v-edt - 1, output v-paydt).
        end.
        doe1 = v-paydt - dt.
        if doe1 >= 0    and doe1 <= 6     then v-period1 = "до 7 дней"   .
        if doe1 >= 7    and doe1 <= 30    then v-period1 = "до 1 месяца" .
        if doe1 >= 31   and doe1 <= 92    then v-period1 = "до 3 месяцев".
        if doe1 >= 93   and doe1 <= 182   then v-period1 = "до 6 месяцев".
        if doe1 >= 183  and doe1 <= 365   then v-period1 = "до 1 года"   .
        if doe1 >= 366  and doe1 <= 1095  then v-period1 = "до 3 лет"    .
        if doe1 >= 1096 and doe1 <= 9999999 then v-period1 = "свыше 3 лет" .
        if v-paydt = ? then v-period1 = "до 7 дней"   .
    end. else v-period1 = "до 7 дней"   .

    /*run savelog('depport_data',txb.cif.prefix + " " + txb.cif.name).
    run savelog('depport_data',string(v-paydt)).
    run savelog('depport_data',string(doe1)).*/

    create tbl.
      assign
        tbl.period  = v-period
        tbl.period1 = v-period1
        tbl.gl      = txb.aaa.gl
        tbl.gl2      = v-glr
        tbl.filial  = v-bank
        tbl.aaa     = txb.aaa.aaa
        tbl.clname  = txb.cif.prefix + " " + txb.cif.name
        tbl.crc     = txb.aaa.crc
        tbl.rdt     = txb.aaa.regdt
        tbl.edt     = v-edt
        tbl.rate    = v-rate
        tbl.opnamt  = v-opnamt
        tbl.ostcrc  = txb.lgr.tlimit[1]
        tbl.ostkzt  = txb.lgr.tlimit[1] * v-kurs
        tbl.sumcrc  = v-bal
        tbl.sumkzt  = v-bal * v-kurs
        tbl.kurs    = v-kurs
        tbl.depname = txb.lgr.des
        tbl.str1    = v-attrib
        tbl.str2    = v-uslov
        tbl.str3    = v-osnov
        tbl.paydate = v-paydt
        tbl.paysumcrc = v-bal2
        tbl.paysumkzt = v-bal2 * v-kurs.
        /*if avail acvolt then tbl.period  = txb.lgr.intpay + " " + txb.acvolt.x1 + " " + string(v-edt - 1).*/

end.


Procedure EventHandlerDt.
def input parameter e_period as char.
def input parameter e_date as date.
def input parameter a_start as date.
def input parameter a_expire as date.
def output parameter exp_date as date.

def var vterm as inte.
def var e_refdate as date.
def var e_displdate as date.
def var t_date as date.
def var years as inte initial 0.
def var months as inte initial 0.
def var days as inte initial 0.

def var t-years as inte initial 0.
def var t-months as inte initial 0.
def var t-days as inte initial 0.


def var i as integer initial 0.

if e_period  = "N" then return.
else if e_period = "S"  then do:
   exp_date = a_start.
   return.
end.
else if e_period = "F" then do:
   exp_date = a_expire.
   return.
end.
else if e_period = "M" or e_period = "Q" or e_period = "Y"
     or e_period = "1" or e_period = "2" or e_period = "3"
     or e_period = "4" or e_period = "5" or e_period = "6"
     or e_period = "7" or e_period = "8" or e_period = "9" then do:
     if e_period = "M" then vterm = 1.
     else if e_period = "Q" then vterm = 3.
     else if e_period = "Y" then vterm = 12.
     else vterm = integer(e_period).
     t_date = a_start.
     i = 1.



     repeat:
       days = day(a_start).
       years = integer(vterm / 12 - 0.5).
       months = vterm - years * 12.
       months = months + month(t_date).
       if months > 12 then do:
         years = years + 1.
         months = months - 12.
       end.


       /*Если счет открыт в последний день месяца но не в феврале*/
       if (month(a_start) <> month(a_start + 1)) and month(a_start) <> 2 then do:
          t-years = years.
          t-months = months + 1.
          if t-months = 13 then do:
             t-months = 1.
             t-years = years + 1.
          end.
          t-days = 1.

          if months <> 2 then do:
             e_displdate = date(t-months, t-days, year(t_date) + t-years) - 2.
          end.
          else do:
             e_displdate = date(t-months, t-days, year(t_date) + t-years).
          end.
       end.

       else
       /*Если счет открыт 1-го числа*/
       if day(a_start) = 1 then do: /*Если Дата открытия 1 числа*/
          if months <> 3 then
             e_displdate = date(months, days, year(t_date) + years) - 1.
          else
             e_displdate = date(months, days, year(t_date) + years).
       end.
       else
       /*Если счет открыт не первого и не последнего */
       do: /*обычная дата*/

          if months = 2 and (days = 29 or days = 30 or days = 31) then
          do:
             months = 3. days = 2.
          end.

          days = days - 1.
          e_displdate = date(months, days, year(t_date) + years).
       end.

       if e_displdate >= e_date then do:
          exp_date = e_displdate.
          return.
       end. /*else if e_displdate > a_expire then return.*/

       t_date = date(months, 15, year(t_date) + years).
       i = i + 1.
     end.  /*repeat*/

end.
else if e_period = "D" then exp_date = e_date.
End procedure.

