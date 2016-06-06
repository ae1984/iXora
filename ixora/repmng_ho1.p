/* repmng_ho1.p
 * MODULE
        Главная бухгалтерская книга
 * DESCRIPTION
        Управленческая отчетность
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        12.18
 * AUTHOR
        14/12/2010 madiyar
 * BASES
        BANK COMM TXB
 * CHANGES
        13.08.2013 damir - Внедрено Т.З. № 1182,1258,1257,1650. Добавил в londoh_clients 4434; com_exp - getRMZExp (добавил CHF,AUD); поставил по lc группу счетов 6000; добавил по
                           com_inexp 5754; по SO_Adjust_provision_account заменил на 3305,3315; добавил по SO_depoGAR 2707; добавил по SO_rashod_deposit 5229; добавил по dueBanks
                           1264,1705; добавил по securTrade 1745; добавил по lonast 1697; добавил по assets_other 1810,1890 и добавил getGL2; добавил по depov%,depoSM%,depoCORP% 2723;
                           добавил по SO_prochieObiaz 2890.
*/

def shared temp-table t-period no-undo
    field pid as integer
    field dtb as date
    field dte as date
    index idx is primary dtb.

def shared temp-table t-krit no-undo
    field kid as integer
    field kcode as char
    field bold_code as log
    field color_code as log
    field des_en as char
    field des_ru as char
    field level as integer
    index idx is primary kid
    index idx2 kcode.

def shared temp-table t-kritval no-undo
    field bank as char
    field kid as integer
    field pid as integer
    field sum as deci
    index idx is primary bank kid pid.

def shared var g-today as date.
def var SS1 as deci.

def var s-ourbank as char no-undo.
find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
    display " There is no record OURBNK in bank.sysc file !!".
    pause.
    return.
end.
s-ourbank = trim(txb.sysc.chval).

def var v-bankn as char no-undo.
if s-ourbank = "txb00" then v-bankn = "ЦО".
else do:
    find first txb.cmp no-lock no-error.
    if avail txb.cmp then v-bankn = entry(1,txb.cmp.addr[1]).
    else v-bankn = s-ourbank.
end.

define frame msg.
frame msg:title = v-bankn.

/*Собираем группы счетов*/
def var v-lgr as char.
v-lgr = "".
for each txb.trxlevgl where string(txb.trxlevgl.glr) begins "5219" or string(txb.trxlevgl.glr) begins "5229" or string(txb.trxlevgl.glr) begins "5223" no-lock:
    if not (txb.trxlevgl.subled = "CIF") then next.
    for each txb.aaa where txb.aaa.gl = txb.trxlevgl.gl no-lock:
        if v-lgr <> "" then v-lgr = v-lgr + "," + txb.aaa.lgr.
        else v-lgr = txb.aaa.lgr.
    end.
end.
/*-----------------------*/

function getGL returns deci (input p-gl as integer, input p-dt as date).
    def var res as deci no-undo.
    def var res1 as deci no-undo.
    res = 0.
    for each txb.crc no-lock:
        find last txb.glday where txb.glday.gl = p-gl and txb.glday.crc = txb.crc.crc and txb.glday.gdt <= p-dt no-lock no-error.
        if avail txb.glday then do:

            res1 = txb.glday.dam - txb.glday.cam.

            if res1 <> 0 then do:
                if txb.crc.crc = 1 then res = res + res1.
                else do:
                    find last txb.crchis where txb.crchis.crc = txb.crc.crc and txb.crchis.rdt <= p-dt no-lock no-error.
                    if avail txb.crchis then res = res + res1 * txb.crchis.rate[1].
                end.
            end.
        end.
    end.
    return res.
end function.

function getGL2 returns deci (input p-gl as integer, input p-dt as date).
    def var res as deci no-undo.
    def var res1 as deci no-undo.
    res = 0.
    for each txb.crc no-lock:
        find last txb.glday where txb.glday.gl = p-gl and txb.glday.crc = txb.crc.crc and txb.glday.gdt <= p-dt no-lock no-error.
        if avail txb.glday then do:

            res1 = txb.glday.bal.

            if res1 <> 0 then do:
                if txb.crc.crc = 1 then res = res + res1.
                else do:
                    find last txb.crchis where txb.crchis.crc = txb.crc.crc and txb.crchis.rdt <= p-dt no-lock no-error.
                    if avail txb.crchis then res = res + res1 * txb.crchis.rate[1].
                end.
            end.
        end.
    end.
    return res.
end function.

function getGLcrc returns deci (input p-gl as integer, input p-dt as date, input crc as integer).
    def var res as deci no-undo.
    def var res1 as deci no-undo.
    res = 0.
    find first txb.crc where txb.crc.crc = crc no-lock no-error.
    if avail txb.crc then do:
        find last txb.glday where txb.glday.gl = p-gl and txb.glday.crc = txb.crc.crc and txb.glday.gdt <= p-dt no-lock no-error.
        if avail txb.glday then do:
            res1 = txb.glday.dam - txb.glday.cam.
            if res1 <> 0 then do:
                if txb.crc.crc = 1 then res = res + res1.
                else do:
                    find last txb.crchis where txb.crchis.crc = txb.crc.crc and txb.crchis.rdt <= p-dt no-lock no-error.
                    if avail txb.crchis then res = res + res1 * txb.crchis.rate[1].
                end.
            end.
        end.
    end.
    return res.
end function.

function str2GL returns integer (input p-glstr as char, input p-gltype as char).
    def var res as integer no-undo.
    res = 0.
    def var v-i as integer no-undo.
    v-i = ?.
    def var v-c as char no-undo.
    v-c = ''.
    p-glstr = trim(p-glstr).
    if (p-gltype = "start") or (p-gltype = "end") then do:
        if p-gltype = "start" then v-c = '0'. else v-c = '9'.
        if (p-glstr <> '') and length(p-glstr) <= 6 then do:
            v-i = integer(p-glstr) no-error.
            if (v-i <> ?) and (v-i > 0) then do:
                res = integer(p-glstr + fill(v-c,6 - length(p-glstr))).
            end.
        end.
    end.
    return res.
end function.



function getGroupGL returns deci (input p-gr as char, input p-ex as char, input p-dt as date).
    def var res as deci no-undo.
    def var v-i as integer no-undo.
    def var v-j as integer no-undo.
    def var gr as char no-undo.
    p-gr = trim(p-gr).
    p-ex = trim(p-ex).
    res = 0.
    if p-gr <> '' then do:
        do v-i = 1 to num-entries(p-gr):
            gr = entry(v-i,p-gr).
         g: for each txb.gl where txb.gl.gl >= str2GL(gr,"start") and txb.gl.gl <= str2GL(gr,"end") no-lock:
                /* gl.totact = no gl.totlev = 1 */
                if gl.totact and p-gr <> "359910" then next.
                if p-ex <> '' then do:
                    do v-j = 1 to num-entries(p-ex):
                        if substring(string(txb.gl.gl),1,length(entry(v-j,p-ex))) = entry(v-j,p-ex) then next g.
                    end.
                end.

                res = res + getGL(txb.gl.gl,p-dt).

            end.
        end. /* do v-i */
    end. /* if p-gr <> '' */
    return res.
end function.


function getGLTurnover returns decimal (input p-gr as char, p-ex as char, input p-dt as date):
    def var res as deci no-undo.
    def var dt1 as date no-undo.
    def var dt2 as date no-undo.
    def var mm as integer no-undo.
    def var yy as integer no-undo.
    dt1 = date(month(p-dt),1,year(p-dt)) - 1.
    yy = year(p-dt).
    mm = month(p-dt) + 1.
    if mm = 13 then assign yy = yy + 1 mm = 1.
    dt2 = date(mm,1,yy) - 1.
    res = getGroupGL(p-gr,p-ex,dt2) - getGroupGL(p-gr,p-ex,dt1).
    return res.
end function.

function getKID returns integer (input p-kcode as char).
    find first t-krit where t-krit.kcode = p-kcode no-lock no-error.
    if avail t-krit then return t-krit.kid.
    else return 0.
end function.

function getKritVal returns deci (input p-kcode as char, input p-pid as integer).
    def var v-res as deci no-undo.
    v-res = 0.
    def var v-kid as integer no-undo.
    v-kid = getKID(p-kcode).
    if v-kid > 0 then do:
        find first t-kritval where t-kritval.bank = s-ourbank and t-kritval.kid = v-kid and t-kritval.pid = p-pid no-lock no-error.
        if avail t-kritval then v-res = t-kritval.sum.
    end.
    return v-res.
end function.

procedure setKritVal.
    def input parameter p-kcode as char no-undo.
    def input parameter p-pid as integer no-undo.
    def input parameter p-sum as deci no-undo.

    def var v-kid as integer no-undo.
    v-kid = getKID(p-kcode).
    if v-kid > 0 then do:
        find first t-kritval where t-kritval.bank = s-ourbank and t-kritval.kid = v-kid and t-kritval.pid = p-pid no-error.
        if not avail t-kritval then do:
            create t-kritval.
            assign t-kritval.bank = s-ourbank
                   t-kritval.kid = v-kid
                   t-kritval.pid = p-pid.
        end.
        t-kritval.sum = t-kritval.sum + p-sum.
    end.
end procedure.


/* Получить сохраненное ранее значение */
function getStoredKritVal returns deci (input p-bank as char, input p-kcode as char, input p-dtb as date).
    def var v-res as deci no-undo.
    v-res = 0.
    find first uprdata where uprdata.bank = p-bank and uprdata.kcode = p-kcode and uprdata.dtb = p-dtb no-lock no-error.
    if avail uprdata then v-res = uprdata.kvalue.
    return v-res.
end function.

/* Получить сумму сохраненных ранее значений */
function getStoredKritVals returns deci (input p-kcode as char, input p-dtb as date).
    def var v-res as deci no-undo.
    v-res = 0.
    for each uprdata where uprdata.kcode = p-kcode and uprdata.dtb = p-dtb no-lock:
     v-res = v-res + uprdata.kvalue.
    end.
    return v-res.
end function.

/* Получить сохраненное ранее значение */
function getStoredKritValAll returns deci (input p-bank as char, input p-kcode as char, input p-dtb as date).
    def var v-res as deci no-undo.
    v-res = 0.

   case p-bank:
       when "txb00" then do:
          find first uprdata where uprdata.bank = "txb00" and uprdata.kcode = p-kcode and uprdata.dtb = p-dtb no-lock no-error.
          if avail uprdata then v-res = uprdata.kvalue.
       end.
       when "txb" then do:
          for each uprdata where uprdata.bank <> "txb00" and uprdata.kcode = p-kcode and uprdata.dtb = p-dtb no-lock:
            v-res = v-res + uprdata.kvalue.
          end.
       end.
       when "all" then do:
          for each uprdata where uprdata.kcode = p-kcode and uprdata.dtb = p-dtb no-lock:
            v-res = v-res + uprdata.kvalue.
          end.
       end.
       OTHERWISE do:
          for each uprdata where uprdata.bank = p-bank and uprdata.kcode = p-kcode and uprdata.dtb = p-dtb no-lock:
            v-res = v-res + uprdata.kvalue.
          end.
       end.
   end case.

   return v-res.
end function.
/* Сохранить значение для использования в других отчетах */
procedure setStoredKritVal.
    def input parameter p-bank as char no-undo.
    def input parameter p-kcode as char no-undo.
    def input parameter p-dtb as date no-undo.
    def input parameter p-sum as deci no-undo.
    do transaction:
        find first uprdata where uprdata.bank = p-bank and uprdata.kcode = p-kcode and uprdata.dtb = p-dtb exclusive-lock no-error.
        if not avail uprdata then do:
            create uprdata.
            assign uprdata.bank = p-bank
                   uprdata.kcode = p-kcode
                   uprdata.dtb = p-dtb.
        end.
        uprdata.kvalue = p-sum.
        find current uprdata no-lock.
    end. /* transaction */
end procedure.

/* Получить справочное значение - integer */
function getSprValI returns integer (input p-bank as char, input p-spr_id as char, input p-dt as date).
    def var v-res as integer no-undo.
    if p-bank = "all" then do:
        for each comm.txb where comm.txb.consolid no-lock:
            find last uprsprav where uprsprav.bank = comm.txb.bank and uprsprav.id = p-spr_id and uprsprav.date <= p-dt no-lock no-error.
            if avail uprsprav then v-res = v-res + uprsprav.inval.
        end.
    end.
    else do:
        find last uprsprav where uprsprav.bank = p-bank and uprsprav.id = p-spr_id and uprsprav.date <= p-dt no-lock no-error.
        if avail uprsprav then v-res = uprsprav.inval.
    end.
    return v-res.
end function.
/* Получить справочное значение - deci */
function getSprValR returns deci (input p-bank as char, input p-spr_id as char, input p-dt as date).
    def var v-res as deci no-undo.
    if p-bank = "all" then do:
        for each comm.txb where comm.txb.consolid no-lock:
            find last uprsprav where uprsprav.bank = comm.txb.bank and uprsprav.id = p-spr_id and uprsprav.date <= p-dt no-lock no-error.
            if avail uprsprav then v-res = v-res + uprsprav.deval.
        end.
    end.
    else do:
        find last uprsprav where uprsprav.bank = p-bank and uprsprav.id = p-spr_id and uprsprav.date <= p-dt no-lock no-error.
        if avail uprsprav then v-res = uprsprav.deval.
    end.
    return v-res.
end function.
/* Получить справочное значение - char */
function getSprVal returns char (input p-bank as char, input p-spr_id as char, input p-dt as date).
    def var v-res as char no-undo.
    find last uprsprav where uprsprav.bank = p-bank and uprsprav.id = p-spr_id and uprsprav.date <= p-dt no-lock no-error.
    if avail uprsprav then v-res = uprsprav.chval.
    return v-res.
end function.

function days_in_month returns integer (input p-m as integer, input p-y as integer).
    def var res as integer no-undo.
    def var mm as integer no-undo.
    def var yy as integer no-undo.
    yy = p-y.
    mm = p-m + 1.
    if mm = 13 then assign mm = 1 yy = yy + 1.
    res = day(date(mm,1,yy) - 1).
    return res.
end function.

function AccrualMethod returns decimal (input p as date, input t as date, input S0 as deci, input S1 as deci, input S2 as deci):
    def var res as deci no-undo.
    def var mm as integer.
    def var yy as integer.
     p = p - 1.
    if year(t) = year(p) and month(t) = month(p) then res = S1 * (t - p) / days_in_month(month(t),year(t)).
    else do:
        if day(t) = days_in_month(month(t),year(t)) then res = S2 - (S1 * day(p)) / days_in_month(month(t),year(t)).
        else do:
            yy = year(t).
            mm = month(t) - 1.
            if mm = 0 then assign mm = 12 yy = yy - 1.
            res = S1 - S0 * day(p) / days_in_month(mm,yy) + S1 * day(t) / days_in_month(month(t),year(t)).
        end.
    end.
    return res.
end function.

/*********************************************************************************/
/*********************************************************************************/
/*********************************************************************************/
/*********************************************************************************/
/*********************************************************************************/

def var PayKZT as int init 0.
def var PayRUB as int init 0.
def var PayVal as int init 0.

function getRMZExp returns decimal (input dt1 as date , input dt2 as date):
    def var res as decimal.
    def var v-type as char no-undo.

    res = 0.

    if s-ourbank = "txb00" then v-type = '6'. else v-type = '4'.
    for each txb.remtrz where txb.remtrz.valdt2 >= dt1 and txb.remtrz.valdt2 <= dt2 and txb.remtrz.ptype = v-type no-lock:
        if txb.remtrz.jh1 = ? or txb.remtrz.jh2 = ? then next.
        if s-ourbank <> "txb00" then do:
            if txb.remtrz.rbank begins "txb" then next.
            /*
            if (remtrz.fcrc = 1) and (remtrz.rbank begins "txb") then next.
            else
            if (remtrz.fcrc <> 1) and (remtrz.rbank begins "txb") then next.
            */
        end.

        case txb.remtrz.fcrc:
         when 1 then do: res = res + getStoredKritVal('',"payCostKZT",dt1). end.
         when 2 then do: res = res + getStoredKritVal('',"payCostUSD",dt1). end.
         when 3 then do: res = res + getStoredKritVal('',"payCostEUR",dt1). end.
         when 4 then do: res = res + getStoredKritVal('',"payCostRUB",dt1). end.
         when 6 then do: res = res + getStoredKritVal('',"payCostGBP",dt1). end.
         when 8 then do: res = res + getStoredKritVal('',"payCostAUD",dt1). end.
         when 9 then do: res = res + getStoredKritVal('',"payCostCHF",dt1). end.
        end case.

    end.

    return res.
end function.


/*********************************************************************************/
/*********************************************************************************/
/*********************************************************************************/
/*********************************************************************************/
/*********************************************************************************/

/*********************************************************************************/
function Convcrc returns decimal ( input sum as decimal, input c1 as int, input c2 as int, input d1 as date):
    define buffer bcrc1 for txb.crchis.
    define buffer bcrc2 for txb.crchis.
    if c1 <> c2 then do:
        find last bcrc1 where bcrc1.crc = c1 and bcrc1.rdt <= d1 no-lock no-error.
        find last bcrc2 where bcrc2.crc = c2 and bcrc2.rdt <= d1 no-lock no-error.
        if avail bcrc1 and avail bcrc2 then return sum * bcrc1.rate[1] / bcrc2.rate[1].
    end.
    else return sum.
end function.
/**************************************************************************************/
function getAccType returns int (input accno as char):
    def var v-urfiz as int init -1.
    def buffer b-cif for txb.cif.
    def buffer b-aaa for txb.aaa.
    def buffer b-sub-cod for txb.sub-cod.

    find first b-aaa where b-aaa.aaa = accno no-lock no-error.
    if avail b-aaa then do:
        find first b-cif where b-cif.cif = b-aaa.cif no-lock no-error.
        if avail b-cif then do:
            if b-cif.type = 'P' then v-urfiz = 1. /* retail */
            else do:
                find first b-sub-cod where b-sub-cod.sub = 'cln' and b-sub-cod.acc = b-cif.cif and b-sub-cod.d-cod = "clnsegm" no-lock no-error.
                if (avail b-sub-cod) and ((b-sub-cod.ccode = "02") or (b-sub-cod.ccode = "03") or (b-sub-cod.ccode = "04")) then v-urfiz = 2. /* sme */
                else v-urfiz = 3. /* corporate */
            end.
        end.
        else message "Нет такого клиента O_o " b-aaa.cif view-as alert-box.
    end.
    return v-urfiz.
end function.
/**************************************************************************************/
function crc-crc-date returns decimal (sum as decimal, c1 as int, c2 as int, d1 as date).
    define buffer bcrc1 for txb.crchis.
    define buffer bcrc2 for txb.crchis.

    if d1 = 10.01.08 or d1 = 12.01.08 then do:
        if c1 <> c2 then do:
            find last bcrc1 where bcrc1.crc = c1 and bcrc1.rdt < d1 no-lock no-error.
            find last bcrc2 where bcrc2.crc = c2 and bcrc2.rdt < d1 no-lock no-error.
            return sum * bcrc1.rate[1] / bcrc2.rate[1].
        end.
        else return sum.
    end.
    if c1 <> c2 then do:
        find last bcrc1 where bcrc1.crc = c1 and bcrc1.rdt <= d1 no-lock no-error.
        find last bcrc2 where bcrc2.crc = c2 and bcrc2.rdt <= d1 no-lock no-error.
        return sum * bcrc1.rate[1] / bcrc2.rate[1].
    end.
    else return sum.
end function.
/**************************************************************************************/
function GetExpense returns deci ( input p-dt as date, input ext_cod as log , input s-code as char , input v-gl as char).
  def var res as deci init 0 .
  def var i as int init 0 .
  def var i2 as int init 0 .
  def var iret as log init false .
  def var jhs-code as char  no-undo.
  def var is-cod as char no-undo.
  def var v-rate as deci no-undo.
  def var summ as deci no-undo.
  def var v-date as date no-undo.
  def var v-date2 as date no-undo.
  def var mm as integer no-undo.
  def var yy as integer no-undo.
  DEFINE BUFFER b-gl FOR txb.gl.
  DEFINE VARIABLE qh AS HANDLE.
  DEFINE VARIABLE ListGL AS CHAR INIT "".
  CREATE QUERY qh.
  qh:SET-BUFFERS("b-gl").

  v-date = date(month(p-dt),1,year(p-dt)).
  yy = year(p-dt).
  mm = month(p-dt) + 1.
  if mm = 13 then assign yy = yy + 1 mm = 1.
  v-date2 = date(mm,1,yy) - 1.

  do i = 1 to num-entries(v-gl,","):
   if ListGL <> "" then ListGL = ListGL + " or ".
   ListGL = ListGL + " string(b-gl.gl) begins '" + entry(i,v-gl,",") + "'".
  end.

        qh:QUERY-CLOSE().
        qh:QUERY-PREPARE("for each b-gl where " + ListGL ).
        qh:QUERY-OPEN.
        qh:GET-FIRST().

        if avail b-gl then
        do:
          REPEAT:
           IF qh:QUERY-OFF-END THEN LEAVE.
             for each txb.jl  no-lock where txb.jl.jdt >= v-date  and txb.jl.jdt <= v-date2 and txb.jl.gl = b-gl.gl.
              if trim(txb.jl.rem[1]) begins 'Свертка '  then next.
              if trim(txb.jl.rem[1]) begins 'CONVERSION ' then next.

              find first txb.trxcods where txb.trxcods.trxh = txb.jl.jh and txb.trxcods.trxln = txb.jl.ln and txb.trxcods.trxt = 0 and txb.trxcods.codfr = 'cods' use-index trxcd_idx  no-lock no-error.
              if not avail txb.trxcods then next.
              for each txb.trxcods no-lock where txb.trxcods.trxh = txb.jl.jh  and txb.trxcods.trxln = txb.jl.ln and  txb.trxcods.trxt = 0 and txb.trxcods.codfr = 'cods' use-index trxcd_idx .

               find last txb.crchis where txb.crchis.crc = txb.jl.crc
                   and txb.crchis.rdt <= txb.jl.jdt  use-index crcrdt no-lock no-error.
               if not available txb.crchis then do:
                 message 'Не задан курс для валюты ' txb.jl.crc .
                 v-rate =  1.
               end.
               else do:
                 v-rate =  txb.crchis.rate[1].
                end.

                jhs-code = substr(txb.trxcods.code,1,7).
                iret = false.

                if s-code = "" then assign iret = yes ext_cod = yes.
                else iret = (lookup(jhs-code,s-code) > 0).

                if (ext_cod and iret) or ((not ext_cod) and (not iret)) then /*только по коду s-code*/
                do:
                    summ = 0.
                    if txb.jl.dam <> 0 then  summ = txb.jl.dam * v-rate .  else summ = - (txb.jl.cam * v-rate).
                    res = res + summ.
                end.

              end.
             end.
           qh:GET-NEXT().
          END.
        end. /*gl*/

  return res.
end function.
/**************************************************************************************/
function getDEPOsum returns decimal (input val as char,  input srok as char, input p-dt as date).
         def var result as decimal.
         def var sm as decimal.
         def var j as integer.
         def var v-jlbl as integer.
         result = 0.


/* Розница ФЛ */
         if val = "ret" then do:
            if srok = "2" or srok = "3" or srok = "4" then do:
               for each txb.aaa where (string(aaa.gl) begins "2206" or string(aaa.gl) begins "2207" or string(aaa.gl) begins "2208") and txb.aaa.stadt <= p-dt no-lock:
                   find last txb.crc where txb.crc.crc = txb.aaa.crc no-lock no-error.
                   if srok = "2" and txb.aaa.expdt - p-dt < 365 then do:
                      sm = 0.
                      run lonbal3('cif', txb.aaa.aaa, p-dt - 1, "1", yes, output sm).
                      result = result + round(crc-crc-date(decimal(sm), txb.aaa.crc, 1, p-dt - 1), 2).

                   end.
                   else
                   if srok = "3" and (txb.aaa.expdt - p-dt >= 365) and  (txb.aaa.expdt - p-dt < 1095) then do:
                      sm = 0.
                      run lonbal3('cif', txb.aaa.aaa, p-dt - 1, "1", yes, output sm).
                      result = result + round(crc-crc-date(decimal(sm), txb.aaa.crc, 1, p-dt - 1), 2).

                   end.
                   else
                   if srok = "4" and (txb.aaa.expdt - p-dt >= 1095) then do:
                      sm = 0.
                      run lonbal3('cif', txb.aaa.aaa, p-dt - 1, "1", yes, output sm).
                      result = result + round(crc-crc-date(decimal(sm), txb.aaa.crc, 1, p-dt - 1), 2).

                   end.
               end.
            end.
            if srok = "5"  then do:
               for each txb.aaa where  txb.aaa.stadt <= p-dt no-lock:
                   find last txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
                   if avail txb.cif and txb.cif.type = "P"  then do:
                      find last txb.crc where txb.crc.crc = txb.aaa.crc no-lock no-error.
                      find  last txb.trxlevgl where txb.trxlevgl.gl eq txb.aaa.gl and txb.trxlevgl.subled eq "cif" and  txb.trxlevgl.level eq 2 no-lock no-error.
                      if not avail txb.trxlevgl then next.
                      if lookup(substr(string(txb.trxlevgl.glr),1,4),"2719,2720,2721,2723") = 0 then next.
                      sm = 0.
                      run lonbal3('cif', txb.aaa.aaa, p-dt - 1, "2", yes, output sm).
                      result = result + round(crc-crc-date(decimal(sm), txb.aaa.crc, 1, p-dt - 1), 2).

                   end.
               end.
            end.
         end.
         else

/* МСБ */
         if val = "mcb" then do:
           if srok = "1"  then do:
              for each txb.aaa where (string(aaa.gl) begins "2203" or string(aaa.gl) begins "2204" ) and txb.aaa.stadt <= p-dt no-lock:

                  find last txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
                  if avail txb.cif and txb.cif.type <> "P"  then do:
                       find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.aaa.cif and txb.sub-cod.d-cod = "clnsegm" no-lock no-error.
                       if (avail txb.sub-cod) and ((txb.sub-cod.ccode = "02") or (txb.sub-cod.ccode = "03") or (txb.sub-cod.ccode = "04")) then do:
                          sm = 0.
                          run lonbal3('cif', txb.aaa.aaa, p-dt - 1, "1", yes, output sm).
                          result = result + round(crc-crc-date(decimal(sm), txb.aaa.crc, 1, p-dt - 1), 2).
                       end.
                  end.
              end.
           end.
           if srok = "2" or srok = "3" or srok = "4" then do:
              for each txb.aaa where (string(aaa.gl) begins "2215" or string(aaa.gl) begins "2217" or string(aaa.gl) begins "2219" or string(aaa.gl) begins "2223") and txb.aaa.stadt <= p-dt no-lock:
                  find last txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
                  if avail txb.cif and txb.cif.type <> "P"  then do:
                       find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.aaa.cif and txb.sub-cod.d-cod = "clnsegm" no-lock no-error.
                       if (avail txb.sub-cod) and ((txb.sub-cod.ccode = "02") or (txb.sub-cod.ccode = "03") or (txb.sub-cod.ccode = "04")) then do:
                          if (srok = "2" and txb.aaa.expdt - p-dt < 365) or (srok = "2" and txb.aaa.expdt = ?) then do:
                             sm = 0.
                             run lonbal3('cif', txb.aaa.aaa, p-dt - 1, "1", yes, output sm).
                             result = result + round(crc-crc-date(decimal(sm), txb.aaa.crc, 1, p-dt - 1), 2).
                          end.
                          else
                          if srok = "3" and (txb.aaa.expdt - p-dt >= 365) and  (txb.aaa.expdt - p-dt < 1095) then do:
                             sm = 0.
                             run lonbal3('cif', txb.aaa.aaa, p-dt - 1, "1", yes, output sm).
                             result = result + round(crc-crc-date(decimal(sm), txb.aaa.crc, 1, p-dt - 1), 2).

                          end.
                          else
                          if srok = "4" and (txb.aaa.expdt - p-dt >= 1095) then do:
                             sm = 0.
                             run lonbal3('cif', txb.aaa.aaa, p-dt - 1, "1", yes, output sm).
                             result = result + round(crc-crc-date(decimal(sm), txb.aaa.crc, 1, p-dt - 1), 2).

                          end.
                       end.
                 end.
              end.
           end.
           if srok = "5"  then do:
               for each txb.aaa where  txb.aaa.stadt <= p-dt no-lock:
                   find last txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
                   if avail txb.cif and txb.cif.type <> "P"  then do:
                       find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.aaa.cif and txb.sub-cod.d-cod = "clnsegm" no-lock no-error.
                       if (avail txb.sub-cod) and ((txb.sub-cod.ccode = "02") or (txb.sub-cod.ccode = "03") or (txb.sub-cod.ccode = "04")) then do:
                          find  last txb.trxlevgl where txb.trxlevgl.gl eq txb.aaa.gl and txb.trxlevgl.subled eq "cif" and  txb.trxlevgl.level eq 2 no-lock no-error.
                          if not avail txb.trxlevgl then next.
                          if lookup(substr(string(txb.trxlevgl.glr),1,4),"2719,2720,2721,2723") = 0 then next.
                          sm = 0.
                          run lonbal3('cif', txb.aaa.aaa, p-dt - 1, "2", yes, output sm).
                          result = result + round(crc-crc-date(decimal(sm), txb.aaa.crc, 1, p-dt - 1), 2).
                       end.
                   end.
               end.
           end.
         end.
         else

/* Корпоративные */
         if val = "corp" then do:
           if srok = "1"  then do:
              for each txb.aaa where (string(aaa.gl) begins "2203" or string(aaa.gl) begins "2204" ) and txb.aaa.stadt <= p-dt no-lock:

                  find last txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
                  if avail txb.cif and txb.cif.type <> "P"  then do:
                       find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.aaa.cif and txb.sub-cod.d-cod = "clnsegm" no-lock no-error.
                       if (not avail txb.sub-cod) or ((avail txb.sub-cod) and ((txb.sub-cod.ccode <> "02") and (txb.sub-cod.ccode <> "03") and (txb.sub-cod.ccode <> "04"))) then do:
                          sm = 0.
                          run lonbal3('cif', txb.aaa.aaa, p-dt - 1, "1", yes, output sm).
                          result = result + round(crc-crc-date(decimal(sm), txb.aaa.crc, 1, p-dt - 1), 2).
                       end.
                  end.
              end.
           end.
           if srok = "2" or srok = "3" or srok = "4" then do:
              for each txb.aaa where (string(aaa.gl) begins "2215" or string(aaa.gl) begins "2217" or string(aaa.gl) begins "2223") and txb.aaa.stadt <= p-dt no-lock:
                  find last txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
                  if avail txb.cif and txb.cif.type <> "P"  then do:
                       find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.aaa.cif and txb.sub-cod.d-cod = "clnsegm" no-lock no-error.
                       if (not avail txb.sub-cod) or ((avail txb.sub-cod) and ((txb.sub-cod.ccode <> "02") and (txb.sub-cod.ccode <> "03") and (txb.sub-cod.ccode <> "04"))) then do:
                          if (srok = "2" and txb.aaa.expdt - p-dt < 365) or (srok = "2" and txb.aaa.expdt = ?) then do:
                             sm = 0.
                             run lonbal3('cif', txb.aaa.aaa, p-dt - 1, "1", yes, output sm).
                             result = result + round(crc-crc-date(decimal(sm), txb.aaa.crc, 1, p-dt - 1), 2).
                          end.
                          else
                          if srok = "3" and (txb.aaa.expdt - p-dt >= 365) and  (txb.aaa.expdt - p-dt < 1095) then do:
                             sm = 0.
                             run lonbal3('cif', txb.aaa.aaa, p-dt - 1, "1", yes, output sm).
                             result = result + round(crc-crc-date(decimal(sm), txb.aaa.crc, 1, p-dt - 1), 2).

                          end.
                          else
                          if srok = "4" and (txb.aaa.expdt - p-dt >= 1095) then do:
                             sm = 0.
                             run lonbal3('cif', txb.aaa.aaa, p-dt - 1, "1", yes, output sm).
                             result = result + round(crc-crc-date(decimal(sm), txb.aaa.crc, 1, p-dt - 1), 2).

                          end.
                       end.
                 end.
              end.
           end.
           if srok = "5"  then do:
               for each txb.aaa where  txb.aaa.stadt <= p-dt no-lock:
                   find last txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
                   if avail txb.cif and txb.cif.type <> "P"  then do:
                       find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.aaa.cif and txb.sub-cod.d-cod = "clnsegm" no-lock no-error.
                       if (not avail txb.sub-cod) or ((avail txb.sub-cod) and ((txb.sub-cod.ccode <> "02") and (txb.sub-cod.ccode <> "03") and (txb.sub-cod.ccode <> "04"))) then do:
                          find  last txb.trxlevgl where txb.trxlevgl.gl eq txb.aaa.gl and txb.trxlevgl.subled eq "cif" and  txb.trxlevgl.level eq 2 no-lock no-error.
                          if not avail txb.trxlevgl then next.
                          if lookup(substr(string(txb.trxlevgl.glr),1,4),"2719,2720,2721,2723") = 0 then next.
                          sm = 0.
                          run lonbal3('cif', txb.aaa.aaa, p-dt - 1, "2", yes, output sm).
                          result = result + round(crc-crc-date(decimal(sm), txb.aaa.crc, 1, p-dt - 1), 2).
                       end.
                   end.
               end.
           end.

         end.
         /* прочие обязательства */
         if val = "obiazPROCHIE" then do:
            result = 0.
            do j = 1 to 22:
               if j = 1 then v-jlbl = 255110.
               if j = 2 then v-jlbl = 255120.
               if j = 3 then v-jlbl = 279940.
               if j = 4 then v-jlbl = 285110.
               if j = 5 then v-jlbl = 285430.
               if j = 6 then v-jlbl = 286010.
               if j = 7 then v-jlbl = 286020.
               if j = 8 then v-jlbl = 286080.
               if j = 9 then v-jlbl = 286090.
               if j = 10 then v-jlbl = 286710.

               if j = 11 then v-jlbl = 287010.
               if j = 12 then v-jlbl = 287020.
               if j = 13 then v-jlbl = 287030.
               if j = 14 then v-jlbl = 287031.
               if j = 15 then v-jlbl = 287032.
               if j = 16 then v-jlbl = 287033.

               if j = 17 then v-jlbl = 287034.
               if j = 18 then v-jlbl = 287035.
               if j = 19 then v-jlbl = 287036.
               if j = 20 then v-jlbl = 287037.
               if j = 21 then v-jlbl = 287050.
               if j = 22 then v-jlbl = 287052.
               result = result + abs(getGL(v-jlbl,p-dt)).
            end.
         end.

         if val = "depoGAR" then do:
            result = 0.
            result = abs(getGL(224010,p-dt)) + abs(getGL(224011,p-dt)).
         end.





         return result.
end function.
/**************************************************************************************/
function getRashsum returns decimal (input val as char,  input srok as char, input p-dte as date, input p-dtb as date).
         def var result as decimal.
         def var sm as decimal.
         def var j as integer.
         def var v-jlbl as integer.
         def var v-11-bg as decimal.
         def var v-11-ed as decimal.
         result = 0.

         if val = "intRozn" then do:
            result = 0.
            for each txb.lgr where txb.lgr.led = "TDA" no-lock:
                for each txb.aaa where txb.aaa.lgr = txb.lgr.lgr  no-lock:
                    run lonbalcrc_txb('cif',txb.aaa.aaa,p-dte,"11",yes,1,output v-11-ed).
                    run lonbalcrc_txb('cif',txb.aaa.aaa,p-dtb,"11",no,1,output v-11-bg).
                    result = result + (v-11-ed - v-11-bg).
                end.
            end.
         end.

         if val = "intMsb" then do:
            result = 0.

            for each txb.lgr where lookup(txb.lgr.lgr,"484,485,486,487,488,489,478,479,480,481,482,483") > 0
            or lookup(txb.lgr.lgr,v-lgr) > 0
            no-lock:
                for each txb.aaa where txb.aaa.lgr = txb.lgr.lgr  no-lock:
                    find last txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
                    find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.aaa.cif and txb.sub-cod.d-cod = "clnsegm" no-lock no-error.
                    if (avail txb.sub-cod) and ((txb.sub-cod.ccode = "02") or (txb.sub-cod.ccode = "03") or (txb.sub-cod.ccode = "04")) then do:
                        sm = 0.
                        run lonbalcrc_txb('cif',txb.aaa.aaa,p-dte,"11",yes,1,output v-11-ed).
                        run lonbalcrc_txb('cif',txb.aaa.aaa,p-dtb,"11",no,1,output v-11-bg).
                        result = result + (v-11-ed - v-11-bg).
                    end.
                end.
            end.
         end.

         if val = "intCorporate" then do:
            result = 0.

            for each txb.lgr where lookup(txb.lgr.lgr,"484,485,486,487,488,489,478,479,480,481,482,483") > 0
            or lookup(txb.lgr.lgr,v-lgr) > 0
            no-lock:
                for each txb.aaa where txb.aaa.lgr = txb.lgr.lgr   no-lock:
                    find last txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
                       find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.aaa.cif and txb.sub-cod.d-cod = "clnsegm" no-lock no-error.
                       if (not avail txb.sub-cod) or ((avail txb.sub-cod) and ((txb.sub-cod.ccode <> "02") and (txb.sub-cod.ccode <> "03") and (txb.sub-cod.ccode <> "04"))) then do:
                        sm = 0.
                        run lonbalcrc_txb('cif',txb.aaa.aaa,p-dte,"11",yes,1,output v-11-ed).
                        run lonbalcrc_txb('cif',txb.aaa.aaa,p-dtb,"11",no,1,output v-11-bg).
                        result = result + (v-11-ed - v-11-bg).
                    end.
                end.
            end.
         end.

         return result.
end function.
/**************************************************************************************/
procedure lonbal3.

define input  parameter p-sub like txb.trxbal.subled.
define input  parameter p-acc as char.
define input  parameter p-dt like txb.jl.jdt.
define input  parameter p-lvls as char.
define input  parameter p-includetoday as logi.
define output parameter res as decimal.

def var i as integer.
def buffer b-aaa for txb.aaa.
res = 0.

if p-dt > g-today then p-dt = g-today.   /*return.*/

if p-includetoday then do: /* за дату */
  if p-dt = g-today then do:
     for each txb.trxbal where txb.trxbal.subled = p-sub and txb.trxbal.acc = p-acc no-lock:
         if lookup(string(txb.trxbal.level), p-lvls) > 0 then do:

            find txb.b-aaa where txb.b-aaa.aaa = p-acc no-lock no-error.
            if not avail txb.b-aaa then return.

	    find txb.trxlevgl where txb.trxlevgl.gl     eq txb.b-aaa.gl
                            and txb.trxlevgl.subled eq p-sub
                            and lookup(string(txb.trxlevgl.level), p-lvls) > 0 no-lock no-error.
            if not avail txb.trxlevgl then return.

	    find txb.gl where txb.gl.gl eq txb.trxlevgl.glr no-lock no-error.
	    if not avail txb.gl then return.

	    if txb.gl.type eq "A" or txb.gl.type eq "E" then res = res + txb.trxbal.dam - txb.trxbal.cam.
	    else res = res + txb.trxbal.cam - txb.trxbal.dam.

	    find txb.sub-cod where txb.sub-cod.sub eq "gld" and txb.sub-cod.d-cod eq "gldic"
	                   and txb.sub-cod.acc eq string(txb.trxlevgl.glr) no-lock no-error.
	    if available txb.sub-cod and txb.sub-cod.ccode eq "01" then res = - res.


	    for each txb.jl where txb.jl.acc = p-acc
                          and txb.jl.jdt >= p-dt
                          and txb.jl.lev = 1 no-lock:
	    if txb.gl.type eq "A" or txb.gl.type eq "E" then res = res - txb.jl.dam + txb.jl.cam.
            else res = res + txb.jl.dam - txb.jl.cam.
            end.

         end.
     end.
  end.
  else
do:
     do i = 1 to num-entries(p-lvls):
        find last txb.histrxbal where txb.histrxbal.subled = p-sub
                              and txb.histrxbal.acc = p-acc
                              and txb.histrxbal.level = integer(entry(i, p-lvls))
                              and txb.histrxbal.dt <= p-dt no-lock no-error.
        if avail txb.histrxbal then do:
            find txb.b-aaa where txb.b-aaa.aaa = p-acc no-lock no-error.
            if not avail txb.b-aaa then return.

	    find txb.trxlevgl where txb.trxlevgl.gl     eq txb.b-aaa.gl
                            and txb.trxlevgl.subled eq p-sub
                            and lookup(string(txb.trxlevgl.level), p-lvls) > 0 no-lock no-error.
            if not avail txb.trxlevgl then return.

	    find txb.gl where txb.gl.gl eq txb.trxlevgl.glr no-lock no-error.
	    if not avail txb.gl then return.

	    if txb.gl.type eq "A" or txb.gl.type eq "E" then res = res + txb.histrxbal.dam - txb.histrxbal.cam.
	    else res = res + txb.histrxbal.cam - txb.histrxbal.dam.

	    find txb.sub-cod where txb.sub-cod.sub eq "gld" and txb.sub-cod.d-cod eq "gldic"
	                   and txb.sub-cod.acc eq string(txb.trxlevgl.glr) no-lock no-error.
	    if available txb.sub-cod and txb.sub-cod.ccode eq "01" then res = - res.

        end.
     end.
  end.
end. /* if p-includetoday */
else do: /* на дату */
   do i = 1 to num-entries(p-lvls):
       find last txb.histrxbal where txb.histrxbal.subled = p-sub and txb.histrxbal.acc = p-acc and txb.histrxbal.level = integer(entry(i, p-lvls))
                                 and txb.histrxbal.dt < p-dt no-lock no-error.
       if avail txb.histrxbal then do:
            find txb.b-aaa where txb.b-aaa.aaa = p-acc no-lock no-error.
            if not avail txb.b-aaa then return.

	    find txb.trxlevgl where txb.trxlevgl.gl     eq txb.b-aaa.gl
                            and txb.trxlevgl.subled eq p-sub
                            and lookup(string(txb.trxlevgl.level), p-lvls) > 0 no-lock no-error.
            if not avail txb.trxlevgl then return.

	    find txb.gl where txb.gl.gl eq txb.trxlevgl.glr no-lock no-error.
	    if not avail txb.gl then return.

	    if txb.gl.type eq "A" or txb.gl.type eq "E" then res = res + txb.histrxbal.dam - txb.histrxbal.cam.
	    else res = res + txb.histrxbal.cam - txb.histrxbal.dam.

	    find txb.sub-cod where txb.sub-cod.sub eq "gld" and txb.sub-cod.d-cod eq "gldic"
	                   and txb.sub-cod.acc eq string(txb.trxlevgl.glr) no-lock no-error.
	    if available txb.sub-cod and txb.sub-cod.ccode eq "01" then res = - res.

       end.
   end.
end.



end.
/**************************************************************************************/

def var i as integer no-undo.
def var v-urfiz as integer no-undo.
def var v-gr as integer no-undo.
def var v-days_od as integer no-undo.
def var v-days_prc as integer no-undo.
def var v-days as integer no-undo.
def var bilance as deci no-undo.
def var v-bal as deci no-undo.
def var v-bal2 as deci no-undo.
def var predopl as deci no-undo.
def var bil as deci no-undo.
def var v-sum as deci no-undo.
def var totals as deci no-undo.

def var v-od as deci no-undo extent 3.
def var v-odpr as deci no-undo.
def var v-prc as deci no-undo.
def var v-prcpr as deci no-undo.
def var v-prov as deci no-undo.

def var v-ostp as deci no-undo extent 3.

def var dn1 as integer no-undo.
def var dn2 as deci no-undo.

def var dtm_prev as date no-undo.
def var dtm_before_prev as date no-undo.

def var v-tiin as deci no-undo.
def var v-Abonus as deci no-undo extent 3.
/* Due */
for each t-period no-lock:
    run setKritVal("nbrkCorr",t-period.pid,getGroupGL("1051",'',t-period.dte)).
    run setKritVal("nbrkDep",t-period.pid,getGroupGL("1103,1710",'',t-period.dte)).
    run setKritVal("dueBanks",t-period.pid,getGroupGL("125,1725,1052,1855,1264,1705",'',t-period.dte)).
    run setKritVal("lonast",t-period.pid,getGroupGL("1610,1651,1652,1653,1654,1655,1656,1657,1658,1692,1693,1694,1698,1697",'',t-period.dte)).
    run setKritVal("astSoft",t-period.pid,getGroupGL("1659,1699",'',t-period.dte)).
    run setKritVal("taxAst",t-period.pid,getGroupGL("1857",'',t-period.dte)).
    run setKritVal("assets_other",t-period.pid,getGroupGL("1894,160,179,185,186,187","1855,1857,1858,186010,1859",t-period.dte) + getGL2(181000,t-period.dte) + getGL2(189000,t-period.dte) ).


    for each txb.arp where txb.arp.gl = 186010 and index(txb.arp.des,"тиын") > 0 and txb.arp.crc = 1  no-lock.
      v-tiin = 0.
      run lonbalcrc_txb('arp',txb.arp.arp,t-period.dte,"1",no,1,output v-tiin).
      run setKritVal("assets_other",t-period.pid,v-tiin).
    end.
end.

/* Securities */
for each t-period no-lock:
    run setKritVal("securTrade",t-period.pid,getGroupGL("120,145,148,1744,1745",'',t-period.dte)).
    run setKritVal("securInvest",t-period.pid,getGroupGL("147",'',t-period.dte)).
    run setKritVal("securREPO",t-period.pid,getGroupGL("146",'',t-period.dte)).
end.

for each t-period no-lock:
    run setKritVal("dueNBRK",t-period.pid,getKritVal("nbrkCorr",t-period.pid) + getKritVal("nbrkDep",t-period.pid)).
    run setKritVal("secur",t-period.pid,getKritVal("securTrade",t-period.pid) + getKritVal("securInvest",t-period.pid) + getKritVal("securREPO",t-period.pid)).
end.

/* LC's */
for each t-period no-lock:
    run setKritVal("lc",t-period.pid,getGroupGL("6000",'',t-period.dte)).
    run setKritVal("lg",t-period.pid,getGroupGL("6055,6075",'',t-period.dte)).
    run setKritVal("openfx",t-period.pid,getGL(185800,t-period.dte)).
    for each txb.crc where crc.crc <> 5 no-lock:
      run setKritVal("openfx" + string(txb.crc.crc),t-period.pid,getGLcrc(185800,t-period.dte,txb.crc.crc)).
    end.
end.

display v-bankn + " - Loans " format "x(40)" string(time,"HH:MM:SS") skip with centered frame msg.

/* Loans */
for each t-period no-lock:
    v-prc = 0. v-prcpr = 0. v-odpr = 0. v-od = 0.
    v-prov = 0. v-Abonus = 0.
    for each txb.lon no-lock:
        if txb.lon.opnamt <= 0 then next.
        if txb.lon.rdt > t-period.dte then next.
        find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
        /*
        if not avail txb.cif then next.
        */

        run lonbalcrc_txb('lon',txb.lon.lon,t-period.dte,"1,7",yes,txb.lon.crc,output bilance).
        /*if v-bal <= 0 then next.*/

        if txb.cif.type = 'P' then v-urfiz = 1. /* retail */
        else do:
            find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = "clnsegm" no-lock no-error.
            if (avail txb.sub-cod) and ((txb.sub-cod.ccode = "02") or (txb.sub-cod.ccode = "03") or (txb.sub-cod.ccode = "04")) then v-urfiz = 2. /* sme */
            else v-urfiz = 3. /* corporate */
        end.

        v-days = 0. v-days_od = 0. v-days_prc = 0.
        if bilance > 0 then do:
            run lndayspr_txb(txb.lon.lon,t-period.dte,yes,output v-days_od,output v-days_prc).
            if v-days_od > v-days_prc then v-days = v-days_od. else v-days = v-days_prc.
        end.

        find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.rdt <= t-period.dte no-lock no-error.

        /* ОД */
        if bilance > 0 then do:
            if v-days > 30 then v-odpr = v-odpr + bilance * txb.crchis.rate[1].
            else do:
                run lonbalcrc_txb('lon',txb.lon.lon,t-period.dte,"1",yes,txb.lon.crc,output v-bal).
                run lonbalcrc_txb('lon',txb.lon.lon,t-period.dte,"7",yes,txb.lon.crc,output v-bal2).

                v-ostp = 0.

                predopl = 0.
                if v-bal2 <= 0 then do:
                    bil = 0.
                    for each txb.lnsch where txb.lnsch.lnn = txb.lon.lon and txb.lnsch.f0 > 0 and txb.lnsch.stdat <= t-period.dte no-lock:
                        bil = bil + txb.lnsch.stval.
                    end. /* for each lnsch */
                    predopl = (txb.lon.opnamt - v-bal - v-bal2) - bil.
                    if predopl < 0 then predopl = 0.
                end.
                else v-ostp[1] = v-ostp[1] + v-bal2.

                v-sum = v-bal.
                for each txb.lnsch where txb.lnsch.lnn = txb.lon.lon and txb.lnsch.f0 > 0 and txb.lnsch.stdat > t-period.dte no-lock:

                    v-gr = 0.
                    run day-360(t-period.dte,txb.lnsch.stdat - 1,lon.basedy,output dn1,output dn2).
                    if dn1 <= 360 then v-gr = 1.
                    else
                    if dn1 <= 1080 then v-gr = 2.
                    else v-gr = 3.

                    if txb.lnsch.stval > predopl then do:
                        if v-sum >= (txb.lnsch.stval - predopl) then do:
                            v-sum = v-sum - (txb.lnsch.stval - predopl).
                            v-ostp[v-gr] = v-ostp[v-gr] + (txb.lnsch.stval - predopl).
                        end.
                        else do:
                            v-sum = 0.
                            v-ostp[v-gr] = v-ostp[v-gr] + v-sum.
                        end.
                    end.
                    predopl = predopl - txb.lnsch.stval.
                    if predopl < 0 then predopl = 0.

                    if v-sum = 0 then leave.

                end. /* for each lnsch */

                if v-sum > 0 then v-ostp[1] = v-ostp[1] + v-sum.
                if v-ostp[1] + v-ostp[2] + v-ostp[3] <> v-bal + v-bal2 then v-ostp[1] = v-bal + v-bal2 - (v-ostp[2] + v-ostp[3]).

                do i = 1 to 3: v-od[i] = v-od[i] + v-ostp[i] * txb.crchis.rate[1]. end.
            end.
        end.

        /* текущее вознаграждение */
        run lonbalcrc_txb('lon',txb.lon.lon,t-period.dte,"2",yes,txb.lon.crc,output v-bal).
        v-prc = v-prc + v-bal * txb.crchis.rate[1].
        /* просроченное вознаграждение */
        run lonbalcrc_txb('lon',txb.lon.lon,t-period.dte,"9",yes,txb.lon.crc,output v-bal).
        v-prcpr = v-prcpr + v-bal * txb.crchis.rate[1].

        /* провизии */
        run lonbalcrc_txb('lon',txb.lon.lon,t-period.dte,"6,36",yes,txb.lon.crc,output v-bal).
        v-prov = v-prov + v-bal * txb.crchis.rate[1].
        run lonbalcrc_txb('lon',txb.lon.lon,t-period.dte,"37",yes,1,output v-bal).
        v-prov = v-prov + v-bal.

        /*Вознаграждение - Астана-Бонус*/
        run lonbalcrc_txb('lon',txb.lon.lon,t-period.dte,"49",yes,txb.lon.crc,output v-bal).
        v-Abonus[v-urfiz] = v-Abonus[v-urfiz] + v-bal * txb.crchis.rate[1].
    end.

    run setKritVal("lonrp18",t-period.pid,getGroupGL("1434","",t-period.dte)).

    totals = v-od[1] + v-od[2] + v-od[3] + v-prc + v-odpr + v-prcpr + v-prov + getKritVal("lonrp18",t-period.pid) + v-Abonus[1].

    run setKritVal("lon",t-period.pid,totals).

    run setKritVal("lonr",t-period.pid,totals).
    run setKritVal("lonr1",t-period.pid,v-od[1]).
    run setKritVal("lonr2",t-period.pid,v-od[2]).
    run setKritVal("lonr3",t-period.pid,v-od[3]).
    run setKritVal("lonri",t-period.pid,v-prc + v-Abonus[1]).
    run setKritVal("lonro30",t-period.pid,v-odpr).
    run setKritVal("lonrio",t-period.pid,v-prcpr).
    run setKritVal("lonrp",t-period.pid,v-prov).


    run setKritVal("assets_total",
                   t-period.pid,
                   totals + getKritVal("dueNBRK",t-period.pid) + getKritVal("dueBanks",t-period.pid) + getKritVal("secur",t-period.pid) +
                   getKritVal("lonast",t-period.pid) + getKritVal("astSoft",t-period.pid) + getKritVal("taxAst",t-period.pid) + getKritVal("assets_other",t-period.pid) +
                   getGroupGL("1434","",t-period.dte) ).
end.

/* Учет кредитов МКО - добавляем ОД в "до 1 года", и провизии */
def var v-gl_lon as deci no-undo.
for each t-period no-lock:
    v-od[1] = getKritVal("lonr1",t-period.pid).
    v-od[2] = getKritVal("lonr2",t-period.pid).
    v-od[3] = getKritVal("lonr3",t-period.pid).
    v-odpr = getKritVal("lonro30",t-period.pid).
    v-prov = getKritVal("lonrp",t-period.pid).
    v-gl_lon = getGroupGL("1411,1417,1424",'',t-period.dte).

    /*
    message string(v-gl_lon,"->>>,>>>,>>>,>>9.99") string(v-od[1] + v-od[2] + v-od[3] + v-odpr,"->>>,>>>,>>>,>>9.99") string(v-gl_lon - (v-od[1] + v-od[2] + v-od[3] + v-odpr),"->>>,>>>,>>>,>>9.99") view-as alert-box.
    */

    if v-gl_lon > v-od[1] + v-od[2] + v-od[3] + v-odpr then run setKritVal("lonr1",t-period.pid,v-gl_lon - (v-od[1] + v-od[2] + v-od[3] + v-odpr)).
    v-gl_lon = getGroupGL("1428",'',t-period.dte).
    if v-gl_lon <> v-prov then run setKritVal("lonrp",t-period.pid,v-gl_lon - v-prov).
end.

display v-bankn + " - Loans Income " format "x(40)" string(time,"HH:MM:SS") skip with centered frame msg.

for each t-period no-lock:
if month(t-period.dtb) = 1 and day(t-period.dtb) < 6 then do:
    run setKritVal("londoh_banks",t-period.pid, abs(getGroupGL("405,410,425,4265",'',t-period.dte)) ).
    run setKritVal("londoh_clients",t-period.pid, abs(getGroupGL("440,441,442,443,444,4900,4434",'',t-period.dte))).
    run setKritVal("londoh_secur",t-period.pid, abs(getGroupGL("420,445,446,447,448",'',t-period.dte))).
    run setKritVal("londoh_other",t-period.pid, abs(getGroupGL("4320",'',t-period.dte))).
end.
else
do:
    run setKritVal("londoh_banks",t-period.pid, abs(getGroupGL("405,410,425,4265",'',t-period.dte)) - abs(getGroupGL("405,410,425,4265",'',t-period.dtb - 1))).
    run setKritVal("londoh_clients",t-period.pid, abs(getGroupGL("440,441,442,443,444,4900,4434",'',t-period.dte)) - abs(getGroupGL("440,441,442,443,444,4900,4434",'',t-period.dtb - 1))).
    run setKritVal("londoh_secur",t-period.pid, abs(getGroupGL("420,445,446,447,448",'',t-period.dte)) - abs(getGroupGL("420,445,446,447,448",'',t-period.dtb - 1))).
    run setKritVal("londoh_other",t-period.pid, abs(getGroupGL("4320",'',t-period.dte)) - abs(getGroupGL("4320",'',t-period.dtb - 1))).

end.


   run setKritVal("londoh_branch", t-period.pid, getStoredKritValAll("txb","intHO", t-period.dtb ) ).
   run setKritVal("capital_cost_ho", t-period.pid, getStoredKritValAll("txb","com_capcost", t-period.dtb ) ).

  /*  londoh = londoh_banks + londoh_clients + londoh_secur + londoh_other + londoh_branch + capital_cost_ho */

    run setKritVal("londoh",t-period.pid,
                    getKritVal("londoh_banks",t-period.pid) + getKritVal("londoh_clients",t-period.pid) +
                    getKritVal("londoh_secur",t-period.pid) + getKritVal("londoh_other",t-period.pid) +
                    getKritVal("londoh_branch",t-period.pid) + getKritVal("capital_cost_ho",t-period.pid)).


    dtm_prev = date(month(t-period.dte),1,year(t-period.dte)) - 1.
    dtm_before_prev = date(month(dtm_prev),1,year(dtm_prev)) - 1.

    run setKritVal("com_prov1",t-period.pid,AccrualMethod(t-period.dtb,t-period.dte,GetExpense( dtm_before_prev ,no,"","545"),GetExpense( dtm_prev ,no,"","545"), GetExpense( t-period.dte ,no,"","545"))).
    run setKritVal("com_prov2",t-period.pid,AccrualMethod(t-period.dtb,t-period.dte,abs(GetExpense( dtm_before_prev ,no,"","495")),abs(GetExpense( dtm_prev ,no,"","495")), abs(GetExpense( t-period.dte ,no,"","495")))).
    run setKritVal("com_prov",t-period.pid,getKritVal("com_prov1",t-period.pid) - getKritVal("com_prov2",t-period.pid)).
    run setKritVal("com_exp",t-period.pid,getRMZExp(t-period.dtb,t-period.dte) + abs(getGL(560840,t-period.dte)) - abs(getGL(560840,t-period.dtb - 1))).

end.

/*если стоимость платежа = 0 то запихиваем остаток по счету ГК в ком. расходы ЦО*/
for each t-period no-lock:

  if getStoredKritVals("payCostKZT_Count",t-period.dtb) = 0 then do:
     run setKritVal("com_exp",t-period.pid, getStoredKritVals("com_exp_KZT",t-period.dtb)).
  end.
  if getStoredKritVals("payCostRUB_Count",t-period.dtb) = 0 then do:
     run setKritVal("com_exp",t-period.pid, getStoredKritVals("com_exp_RUB",t-period.dtb)).
  end.
  if getStoredKritVals("payCostUSD_Count",t-period.dtb) = 0 then do:
     run setKritVal("com_exp",t-period.pid, getStoredKritVals("com_exp_USD",t-period.dtb)).
  end.
  if getStoredKritVals("payCostEUR_Count",t-period.dtb) = 0 then do:
     run setKritVal("com_exp",t-period.pid, getStoredKritVals("com_exp_EUR",t-period.dtb)).
  end.
  if getStoredKritVals("payCostGBP_Count",t-period.dtb) = 0 then do:
    /* message "last = " getKritVal("com_exp",t-period.pid) " + " getStoredKritVals("com_exp_GBP",t-period.dtb) view-as alert-box.*/
     run setKritVal("com_exp",t-period.pid, getStoredKritVals("com_exp_GBP",t-period.dtb)).
    /* message "now = " getKritVal("com_exp",t-period.pid) view-as alert-box.*/
  end.
  if getStoredKritVals("payCostAUD_Count",t-period.dtb) = 0 then do:
     run setKritVal("com_exp",t-period.pid, getStoredKritVals("com_exp_AUD",t-period.dtb)).
  end.
  if getStoredKritVals("payCostCHF_Count",t-period.dtb) = 0 then do:
     run setKritVal("com_exp",t-period.pid, getStoredKritVals("com_exp_CHF",t-period.dtb)).
  end.
end.


/*"Нетто прочие доходы/расходы*/
for each t-period no-lock:
    run setKritVal("com_inexp",t-period.pid,
        (
        abs(getGroupGL("4921,4510,4540,4560,4570,4580,4590,4591,4591,4592,4593,4594,4704,4705,4707,4709,4710,4711,4712,4713,4731,4732,4733,4734,4851,4856,4891,4892,4893,4895,4896,4897,4922,4923",'',t-period.dte))
        - abs(getGroupGL("5510,5540,5560,5570,5580,5590,5591,5592,5593,5594,5704,5705,5708,5709,5710,5711,5712,5713,5714,5731,5732,5733,5754,5851,5854,5856,5891,5892,5893,5895,5896,5897,5900,5921",'',t-period.dte ))
        )
        -
        (
        abs(getGroupGL("4921,4510,4540,4560,4570,4580,4590,4591,4591,4592,4593,4594,4704,4705,4707,4709,4710,4711,4712,4713,4731,4732,4733,4734,4851,4856,4891,4892,4893,4895,4896,4897,4922,4923",'',t-period.dtb - 1 ))
        - abs(getGroupGL("5510,5540,5560,5570,5580,5590,5591,5592,5593,5594,5704,5705,5708,5709,5710,5711,5712,5713,5714,5731,5732,5733,5754,5851,5854,5856,5891,5892,5893,5895,5896,5897,5900,5921",'',t-period.dtb - 1 ))
        )
        ).
    run setKritVal("com_inexp_val",t-period.pid,
        (
         abs(getGroupGL("4703","",t-period.dte)) - abs(getGroupGL("5703","",t-period.dte))
        )
        -
        (
         abs(getGroupGL("4703","",t-period.dtb - 1)) - abs(getGroupGL("5703","",t-period.dtb - 1))
        )
        ).
end.
/*id00205*/

display v-bankn + " - Comission Income " format "x(40)" string(time,"HH:MM:SS") skip with centered frame msg.

for each t-period no-lock:
    run setKritVal("com_incom",t-period.pid, abs(getGroupGL("4601,4602,4603,4604,4606,4607,4608,4609,4610,4611,4612,4613,4614,4615,4616,4617,4618",'',t-period.dte)) - abs(getGroupGL("4601,4602,4603,4604,4606,4607,4608,4609,4610,4611,4612,4613,4614,4615,4616,4617,4618",'',t-period.dtb - 1))).
end. /* for each t-period */

/*end id00205*/

display v-bankn + " - Deposits " format "x(40)" string(time,"HH:MM:SS") skip with centered frame msg.

def var d_all as decimal.
def var d_all1 as decimal.
def var d_all2 as decimal.

for each t-period no-lock:
/* Розница ФЛ */

    run setKritVal("SO_dueToBanks", t-period.pid, abs(getGroupGL("201,212",'',t-period.dte))).
    run setKritVal("SO_depov", t-period.pid, abs(getGL(220520,t-period.dte)) + abs(getGL(220530,t-period.dte)) + getDEPOsum("mcb", "1" , t-period.dte) + getDEPOsum("corp", "1", t-period.dte)).
    run setKritVal("SO_depov1", t-period.pid, getDEPOsum("ret", "2" , t-period.dte) + getDEPOsum("mcb", "2" , t-period.dte) + getDEPOsum("corp", "2" , t-period.dte)).
    run setKritVal("SO_depov2", t-period.pid, getDEPOsum("ret", "3" , t-period.dte) + getDEPOsum("mcb", "3" , t-period.dte) + getDEPOsum("corp", "3" , t-period.dte)).
    run setKritVal("SO_depov3", t-period.pid, getDEPOsum("ret", "4" , t-period.dte) + getDEPOsum("mcb", "4" , t-period.dte) + getDEPOsum("corp", "4" , t-period.dte)).
    run setKritVal("SO_depov%", t-period.pid, getDEPOsum("ret", "5" , t-period.dte) + getDEPOsum("mcb", "5" , t-period.dte) + getDEPOsum("corp", "5" , t-period.dte)).

    run setKritVal("SO_depoGAR", t-period.pid,  abs(getGroupGL("223,224",'',t-period.dte)) + abs(getGroupGL("2869,2707",'',t-period.dte))).

    d_all = 0.
    d_all = getKritVal("SO_depov",t-period.pid) + getKritVal("SO_depov1",t-period.pid) + getKritVal("SO_depov2",t-period.pid) +
    getKritVal("SO_depov3",t-period.pid) + getKritVal("SO_depov%",t-period.pid) + getKritVal("SO_depoGAR",t-period.pid).
    run setKritVal("SO_depo", t-period.pid, d_all).

    run setKritVal("SO_privlSr", t-period.pid,  abs(getGroupGL("203,204",'',t-period.dte)) ).
    run setKritVal("SO_dolgObiaz", t-period.pid,  abs(getGroupGL("230",'',t-period.dte)) +  abs(getGroupGL("2255",'',t-period.dte)) ).
    run setKritVal("SO_dolgObiaz", t-period.pid,  abs(getGroupGL("230",'',t-period.dte)) +  abs(getGroupGL("2255",'',t-period.dte)) ).
    run setKritVal("SO_nalogObiaz", t-period.pid,  abs(getGroupGL("2857",'',t-period.dte))).

    /*    run setKritVal("SO_prochieObiaz", t-period.pid,  abs(getGroupGL("286,255,279,285,287",'2869,',t-period.dte))). */  /*сам добавил 286710*/


    run setKritVal("docSetCredit", t-period.pid,  abs(getGroupGL("2855",'',t-period.dte))).
    run setKritVal("SO_prochieObiaz", t-period.pid,  abs(getGroupGL("2894,255,279,285,286,287",'2855,2869,286010,2858,2859',t-period.dte)) + abs( getGL2(289000,t-period.dte)) ).


    for each txb.arp where txb.arp.gl = 286010 and index(txb.arp.des,"тиын") > 0 and txb.arp.crc = 1  no-lock.
      v-tiin = 0.
      run lonbalcrc_txb('arp',txb.arp.arp,t-period.dte,"1",no,1,output v-tiin).
      run setKritVal("SO_prochieObiaz",t-period.pid,abs(v-tiin)).
    end.

    run setKritVal("SO_subordDolg", t-period.pid,  abs(getGroupGL("240",'',t-period.dte))  +  abs(getGroupGL("2740",'',t-period.dte)) ).

    d_all1 = 0.
    d_all1 = getKritVal("SO_dueToBanks",t-period.pid)
           + getKritVal("SO_depo",t-period.pid) + getKritVal("SO_depoGAR",t-period.pid)
           + getKritVal("SO_privlSr",t-period.pid)
           + getKritVal("SO_dolgObiaz",t-period.pid)
           + getKritVal("SO_nalogObiaz",t-period.pid)
           + getKritVal("SO_prochieObiaz",t-period.pid)
           + getKritVal("SO_subordDolg",t-period.pid)
           + getKritVal("docSetCredit",t-period.pid).
    run setKritVal("SO_obiazatelstva", t-period.pid,  d_all1 ).


    run setKritVal("SO_Aksion_capital", t-period.pid,  abs(getGroupGL("3001",'',t-period.dte)) ).
    run setKritVal("SO_Privelig_capital", t-period.pid,  abs(getGroupGL("3025",'',t-period.dte)) ).

    run setKritVal("SO_Adjust_provision_account", t-period.pid, abs(getGroupGL("3305,3315",'',t-period.dte)) ). /*TZ1120*/

    /*run setKritVal("SO_Reserve", t-period.pid,  abs(getGroupGL("3540,3561",'',t-period.dte)) ). TZ1120*/

    run setKritVal("SO_Ner_dohod_pred", t-period.pid, - getGroupGL("3580",'',t-period.dte) ).

    /*run setKritVal("SO_Ner_dohod_tekuch", t-period.pid, getGroupGL("359910",'',t-period.dte) ). TZ1120*/
    run setKritVal("SO_Net_profit_loss", t-period.pid, getGL2(359910,t-period.dte) ). /*TZ1120*/
    run setKritVal("SO_Retained_earnings", t-period.pid, - getGroupGL("359913",'',t-period.dte) ). /*TZ1120*/
    run setKritVal("SO_Ner_dohod_tekuch", t-period.pid, getKritVal("SO_Net_profit_loss",t-period.pid) + getKritVal("SO_Retained_earnings",t-period.pid) ). /*TZ1120*/
    run setKritVal("SO_Reserve", t-period.pid,  getKritVal("SO_Ner_dohod_pred",t-period.pid) + getKritVal("SO_Ner_dohod_tekuch",t-period.pid)). /*TZ1120*/

    run setKritVal("SO_Ner_other_reserve", t-period.pid,  abs(getGroupGL("3510",'',t-period.dte)) ).


    /*TZ1061 делаем сумму отрицательной*/
   run setKritVal("SO_allocated_branches", t-period.pid, - getStoredKritValAll("txb","CAPITAL", t-period.dtb )).


   d_all2 = 0.
   d_all2 =  getKritVal("SO_Aksion_capital",t-period.pid)
           + getKritVal("SO_Privelig_capital",t-period.pid)
           + getKritVal("SO_Adjust_provision_account",t-period.pid)
           + getKritVal("SO_Reserve",t-period.pid)
           + getKritVal("SO_Ner_other_reserve",t-period.pid)
           + getKritVal("SO_allocated_branches",t-period.pid).

/*


Shareholders equity =           SO_ustkapital
Ordinary share capital          SO_Aksion_capital
+ Preference share capital      SO_Privelig_capital
+ Provisions adjustment account SO_Adjust_provision_account
+ Revaluation reserve           SO_Reserve
+ Other reserves                SO_Ner_other_reserve
+ Equity allocated to branches  SO_allocated_branches


*/
/*
"SO_Aksion_capital","Ordinary share capital"
"SO_Privelig_capital","Preference share capital"
"SO_Reserve","Revaluation reserve"
"SO_Ner_dohod_pred","Retained earnings (previous period)"
"SO_Ner_dohod_tekuch","Retained earnings (current period)"
"SO_Ner_other_reserve","Other reserves"
"SO_allocated_branches","Equity allocated to branches"
*/

    run setKritVal("SO_ustkapital", t-period.pid,  d_all2 ).

    run setKritVal("SO_itoge_obiaz", t-period.pid,  d_all1 + d_all2 ).

    /*
    message string(getKritVal("dueNBRK",t-period.pid),">>>,>>>,>>>,>>9.99")
            string(getKritVal("dueBanks",t-period.pid),">>>,>>>,>>>,>>9.99")
            string(getKritVal("SO_depov",t-period.pid),">>>,>>>,>>>,>>9.99")
    view-as alert-box.
    */

    run setKritVal("SO_do_vostr", t-period.pid, (getKritVal("dueNBRK",t-period.pid) + getKritVal("dueBanks",t-period.pid) - getKritVal("SO_depov",t-period.pid))).

/*
    "SO_zaim_1","Upto 1 year" =
    "lonr1","Upto 1 year" +
    "lonri","% interest" -
    "SO_depov1","Upto 1 year" +
    "SO_depov%","% interest"
*/
    run setKritVal("SO_zaim_1", t-period.pid, ( getKritVal("lonr1",t-period.pid) + getKritVal("lonri",t-period.pid) )
                                            - ( getKritVal("SO_depov1",t-period.pid) + getKritVal("SO_depov%",t-period.pid) ) ).




    run setKritVal("SO_zaim_2", t-period.pid,  getKritVal("lonr2",t-period.pid) - getKritVal("SO_depov2",t-period.pid) ).
    run setKritVal("SO_zaim_3", t-period.pid,  getKritVal("lonr3",t-period.pid) - getKritVal("SO_depov3",t-period.pid)).

    /* SO_zaim_4  = (lonrp + assets_other) - (SO_depoGAR + SO_prochieObiaz)*/
/*
    "SO_zaim_4","Without term" =
    ( "secur","Securities portfolio" +
      "lonro30","Overdue credits (over 30 days)" +
      "lonrio","% overdue interest" +
      "lonrp","Provisions specific" +
      "lonrp18","Discount" +
      "lonast","Property and equipment" +
      "astSoft","Goodwill, software and other intangible assets" +
      "taxAst","Deferred tax assets" +
      "assets_other","Other assets" ) -
    ( "SO_dueToBanks","Due to banks" +
      "SO_depoGAR","Other deposits (guarantees, etc)" +
      "SO_privlSr","Other borrowed funds" +
      "SO_dolgObiaz","Debt securities issued" +
      "SO_nalogObiaz","Deferred tax liabilities" +
      "docSetCredit","Documentary settlements creditors" +
      "SO_prochieObiaz","Other liabilities" +
      "SO_subordDolg","Subbordinated debt" +
      "SO_ustkapital","Shareholders equity" )
*/
    run setKritVal("SO_zaim_4", t-period.pid,   ( getKritVal("secur",t-period.pid) +
                                                  getKritVal("lonro30",t-period.pid) +
                                                  getKritVal("lonrio",t-period.pid) +
                                                  getKritVal("lonrp",t-period.pid) +
                                                  getKritVal("lonrp18",t-period.pid) +
                                                  getKritVal("lonast",t-period.pid) +
                                                  getKritVal("astSoft",t-period.pid) +
                                                  getKritVal("taxAst",t-period.pid) +
                                                  getKritVal("assets_other",t-period.pid) ) -
                                                ( getKritVal("SO_dueToBanks",t-period.pid) +
                                                  getKritVal("SO_depoGAR",t-period.pid) +
                                                  getKritVal("SO_privlSr",t-period.pid) +
                                                  getKritVal("SO_dolgObiaz",t-period.pid) +
                                                  getKritVal("SO_nalogObiaz",t-period.pid) +
                                                  getKritVal("docSetCredit",t-period.pid) +
                                                  getKritVal("SO_prochieObiaz",t-period.pid) +
                                                  getKritVal("SO_subordDolg",t-period.pid) +
                                                  getKritVal("SO_ustkapital",t-period.pid) )
                                                  ).

   /* run setKritVal("SO_zaim_4", t-period.pid,( getKritVal("lonrp",t-period.pid) + getKritVal("assets_other",t-period.pid) ) - ( getKritVal("SO_depoGAR",t-period.pid) + getKritVal("SO_prochieObiaz",t-period.pid)) ).*/



/*    run setKritVal("SO_zaimi", t-period.pid,  getKritVal("SO_do_vostr",t-period.pid) + getKritVal("SO_zaim_1",t-period.pid) + getKritVal("SO_zaim_2",t-period.pid) + getKritVal("SO_zaim_3",t-period.pid) + getKritVal("SO_zaim_4",t-period.pid)).*/
      run setKritVal("SO_itogo_dolg", t-period.pid,  getKritVal("SO_do_vostr",t-period.pid) + getKritVal("SO_zaim_1",t-period.pid) + getKritVal("SO_zaim_2",t-period.pid) + getKritVal("SO_zaim_3",t-period.pid) + getKritVal("SO_zaim_4",t-period.pid)).


   /* run setKritVal("SO_itogo_dolg", t-period.pid,  getKritVal("SO_zaimi",t-period.pid)).*/

    if month(t-period.dtb) = 1 and day(t-period.dtb) < 6 then do:
      run setKritVal("SO_rashod_deposit", t-period.pid,  abs(getGroupGL("5203,5204,5211,5215,5217,5223,5219,5229",'',t-period.dte))).
      run setKritVal("SO_rashod_bank", t-period.pid,  abs(getGroupGL("5111,5112,5113,5121,5122,5123,5124,5125,5126,5127,5128,5129,5130,5133,5134,5135,5136,5137,5138,5140,5141",'',t-period.dte))).
      run setKritVal("SO_rashod_sen", t-period.pid,  abs(getGroupGL("5301,5303,5305,5306,5307,5308",'',t-period.dte)) ).
      run setKritVal("SO_rashod_subDolg", t-period.pid,  abs(getGroupGL("5401,5402,5404,5406,5407",'',t-period.dte)) ).
      run setKritVal("SO_pref_shares", t-period.pid,  abs(getGroupGL("5926",'',t-period.dte)) ).
      run setKritVal("SO_rashod_prochie", t-period.pid,  abs(getGroupGL("503,509,506,505,504",'',t-period.dte))).
    end.
    else
    do:
      run setKritVal("SO_rashod_deposit", t-period.pid,  abs(getGroupGL("5203,5204,5211,5215,5217,5223,5219,5229",'',t-period.dte)) -  abs(getGroupGL("5203,5204,5211,5215,5217,5223,5219,5229",'', t-period.dtb - 1) )).
      run setKritVal("SO_rashod_bank", t-period.pid,  abs(getGroupGL("5111,5112,5113,5121,5122,5123,5124,5125,5126,5127,5128,5129,5130,5133,5134,5135,5136,5137,5138,5140,5141",'',t-period.dte)) -  abs(getGroupGL("5111,5112,5113,5121,5122,5123,5124,5125,5126,5127,5128,5129,5130,5133,5134,5135,5136,5137,5138,5140,5141",'',t-period.dtb - 1 ))).
      run setKritVal("SO_rashod_sen", t-period.pid,  abs(getGroupGL("5301,5303,5305,5306,5307,5308",'',t-period.dte)) -  abs(getGroupGL("5301,5303,5305,5306,5307,5308",'',t-period.dtb - 1))).
      run setKritVal("SO_rashod_subDolg", t-period.pid,  abs(getGroupGL("5401,5402,5404,5406,5407",'',t-period.dte)) -  abs(getGroupGL("5401,5402,5404,5406,5407",'',t-period.dtb - 1))).
      run setKritVal("SO_pref_shares", t-period.pid,  abs(getGroupGL("5926",'',t-period.dte))  - abs(getGroupGL("5926",'',t-period.dtb - 1))).
      run setKritVal("SO_rashod_prochie", t-period.pid,  abs(getGroupGL("503,509,506,505,504",'',t-period.dte)) -  abs(getGroupGL("503,509,506,505,504",'',t-period.dtb - 1 ))).
    end.




  /* SO_rashod = SO_rashod_deposit + SO_rashod_bank + SO_rashod_sen + SO_rashod_subDolg + SO_rashod_prochie + SO_rashod_filial*/
    run setKritVal("SO_rashod_filial", t-period.pid, getStoredKritValAll("txb","londHO", t-period.dtb ) ).

    run setKritVal("SO_rashod", t-period.pid,
        getKritVal("SO_rashod_deposit",t-period.pid) +
        getKritVal("SO_rashod_bank",t-period.pid) +
        getKritVal("SO_rashod_sen",t-period.pid) +
        getKritVal("SO_rashod_subDolg",t-period.pid) +
        getKritVal("SO_pref_shares",t-period.pid)  +
        getKritVal("SO_rashod_prochie",t-period.pid) +
        getKritVal("SO_rashod_filial",t-period.pid) ).




    SS1=0.
    SS1 = getKritVal("SO_do_vostr",t-period.pid) * getSprValR ('', "param_y1" , t-period.dtb ) +
          getKritVal("SO_zaim_1",t-period.pid) * getSprValR ('', "param_y2" , t-period.dtb ) +
          getKritVal("SO_zaim_2",t-period.pid) * getSprValR ('', "param_y3" , t-period.dtb ) +
          getKritVal("SO_zaim_3",t-period.pid) * getSprValR ('', "param_y4" , t-period.dtb ) +
          getKritVal("SO_zaim_4",t-period.pid) * getSprValR ('', "param_y5" , t-period.dtb ).

     SS1 = SS1 / 365 * 7.
     if SS1 < 0 then do:
       /* Филиалы  Процентные доходы */
     /*  run setKritVal("londoh_branch", t-period.pid, SS1 ).*/
      /* run setKritVal("SO_rashod_filial", t-period.pid, 0 ).*/
      /* run setKritVal("londoh",t-period.pid, getKritVal("londoh_branch",t-period.pid) ).*/
     end.
     else do:
       /* Филиалы   Процентные расходы */
      /* run setKritVal("londoh_branch", t-period.pid, 0 ).*/
      /* run setKritVal("SO_rashod_filial", t-period.pid, SS1 ).*/
      /* run setKritVal("SO_rashod", t-period.pid, getKritVal("SO_rashod_filial",t-period.pid)   ).*/
     end.



end.

for each t-period no-lock:
    run setKritVal("net_incom", t-period.pid, getKritVal("londoh",t-period.pid) - getKritVal("SO_rashod",t-period.pid)).
    run setKritVal("com_incom_all", t-period.pid, getKritVal("com_incom",t-period.pid) - getKritVal("com_exp",t-period.pid)).

   /*run setKritVal("com_other1003",t-period.pid, abs(getGroupGL("4921",'',t-period.dte) - getGroupGL("4921",'',t-period.dtb - 1 )) ).*/
   run setKritVal("com_FXincome1003",t-period.pid, abs(getGroupGL("4530",'',t-period.dte) - getGroupGL("4530",'',t-period.dtb - 1 )) ).
   run setKritVal("com_FXexpense1003",t-period.pid,getGroupGL("5530",'',t-period.dte) - getGroupGL("5530",'',t-period.dtb - 1 ) ).
   /*com_incom - com_exp + com_other1003 + com_FXincome1003 - com_FXexpense1003*/
   run setKritVal("com_NetCommFXincome1003",t-period.pid,getKritVal("com_incom",t-period.pid) - getKritVal("com_exp",t-period.pid) +
   /*getKritVal("com_other1003",t-period.pid) +*/ getKritVal("com_FXincome1003",t-period.pid) - getKritVal("com_FXexpense1003",t-period.pid)).


end.

display v-bankn + " - Operational Expenses " format "x(40)" string(time,"HH:MM:SS") skip with centered frame msg.

/*операционные расходы*/
for each t-period no-lock:
    dtm_prev = date(month(t-period.dte),1,year(t-period.dte)) - 1.
    dtm_before_prev = date(month(dtm_prev),1,year(dtm_prev)) - 1.

 /*  message "Зарплата и социальные платежи~n S0 =" string(GetExpense( dtm_before_prev ,no,"","5721")) "~n S1 =" string(GetExpense( dtm_prev ,no,"","5721")) "~n S2 =" string(GetExpense( t-period.dte ,no,"","5721")) "~n X = " string(AccrualMethod(t-period.dtb,t-period.dte,GetExpense( dtm_before_prev ,no,"","5721"),GetExpense( dtm_prev ,no,"","5721"), GetExpense( t-period.dte ,no,"","5721")),">>>>>>>>>>>.99-") view-as alert-box.*/

    run setKritVal("com_socpay",t-period.pid,AccrualMethod(t-period.dtb,t-period.dte,GetExpense( dtm_before_prev ,no,"","572940,5721"),GetExpense( dtm_prev ,no,"","572940,5721"), GetExpense( t-period.dte ,no,"","572940,5721"))).
    /*TZ972*/
    run setKritVal("com_bon",t-period.pid,AccrualMethod(t-period.dtb,t-period.dte,GetExpense( dtm_before_prev ,no,"","572910,572930,572950,572960,572970,572980,572990"),GetExpense( dtm_prev ,no,"","572910,572930,572950,572960,572970,572980,572990"), GetExpense( t-period.dte ,no,"","572910,572930,572950,572960,572970,572980,572990"))).

    run setKritVal("com_trip",t-period.pid,AccrualMethod(t-period.dtb,t-period.dte,GetExpense( dtm_before_prev ,no,"","5749"),GetExpense( dtm_prev ,no,"","5749"), GetExpense( t-period.dte ,no,"","5749"))).
    run setKritVal("com_renpay",t-period.pid,AccrualMethod(t-period.dtb,t-period.dte,GetExpense( dtm_before_prev ,no,"","5923"),GetExpense( dtm_prev ,no,"","5923"), GetExpense( t-period.dte ,no,"","5923"))).
    run setKritVal("com_renpay",t-period.pid,AccrualMethod(t-period.dtb,t-period.dte,GetExpense( dtm_before_prev ,yes,"3020101,3020102,3020103,3020104,3020105,3020106,3020107","5748"),GetExpense( dtm_prev ,yes,"3020101,3020102,3020103,3020104,3020105,3020106,3020107","5748"), GetExpense( t-period.dte ,yes,"3020101,3020102,3020103,3020104,3020105,3020106,3020107","5748"))).
    run setKritVal("com_amort",t-period.pid,AccrualMethod(t-period.dtb,t-period.dte,GetExpense( dtm_before_prev ,no,"","578"),GetExpense( dtm_prev ,no,"","578"), GetExpense( t-period.dte ,no,"","578"))).
    run setKritVal("com_taxgov",t-period.pid,AccrualMethod(t-period.dtb,t-period.dte,GetExpense( dtm_before_prev ,no,"","576,5722"),GetExpense( dtm_prev ,no,"","576,5722"), GetExpense( t-period.dte ,no,"","576,5722"))).
    run setKritVal("com_mark",t-period.pid,AccrualMethod(t-period.dtb,t-period.dte,GetExpense( dtm_before_prev ,no,"","5745"),GetExpense( dtm_prev ,no,"","5745"), GetExpense( t-period.dte ,no,"","5745"))).
    run setKritVal("com_call",t-period.pid,AccrualMethod(t-period.dtb,t-period.dte,GetExpense( dtm_before_prev ,no,"","5753"),GetExpense( dtm_prev ,no,"","5753"), GetExpense( t-period.dte ,no,"","5753"))).
    run setKritVal("com_secur",t-period.pid,AccrualMethod(t-period.dtb,t-period.dte,GetExpense( dtm_before_prev ,no,"","5746"),GetExpense( dtm_prev ,no,"","5746"), GetExpense( t-period.dte ,no,"","5746"))).
    run setKritVal("com_admin",t-period.pid,AccrualMethod(t-period.dtb,t-period.dte,GetExpense( dtm_before_prev ,no,"","5742"),GetExpense( dtm_prev ,no,"","5742"), GetExpense( t-period.dte ,no,"","5742"))).
    run setKritVal("com_audit",t-period.pid,AccrualMethod(t-period.dtb,t-period.dte,GetExpense( dtm_before_prev ,no,"","5750"),GetExpense( dtm_prev ,no,"","5750"), GetExpense( t-period.dte ,no,"","5750"))).
    /*TZ972*/
    run setKritVal("com_other",t-period.pid,AccrualMethod(t-period.dtb,t-period.dte,
                      GetExpense( dtm_before_prev ,no,"","5741,5743,5744,5747,5752,5852,5853,5922") - abs( GetExpense( dtm_before_prev ,no,"","4852, 4853") ),
                      GetExpense( dtm_prev ,no,"","5741,5743,5744,5747,5752,5852,5853,5922") - abs( GetExpense( dtm_prev ,no,"","4852, 4853") ),
                      GetExpense( t-period.dte ,no,"","5741,5743,5744,5747,5752,5852,5853,5922") - abs( GetExpense( t-period.dte ,no,"","4852, 4853") )
                      )).

    run setKritVal("com_other",t-period.pid,AccrualMethod(t-period.dtb,t-period.dte,GetExpense( dtm_before_prev ,no,"3020101,3020102,3020103,3020104,3020105,3020106,3020107","5748"),GetExpense( dtm_prev ,no,"3020101,3020102,3020103,3020104,3020105,3020106,3020107","5748"), GetExpense( t-period.dte ,no,"3020101,3020102,3020103,3020104,3020105,3020106,3020107","5748"))).
    run setKritVal("com_exp_all",t-period.pid, getKritVal("com_socpay",t-period.pid) +
                                               getKritVal("com_bon",t-period.pid) +
                                               getKritVal("com_trip",t-period.pid) +
                                               getKritVal("com_renpay",t-period.pid) +
                                               getKritVal("com_amort",t-period.pid) +
                                               getKritVal("com_taxgov",t-period.pid) +
                                               getKritVal("com_mark",t-period.pid) +
                                               getKritVal("com_call",t-period.pid) +
                                               getKritVal("com_admin",t-period.pid) +
                                               getKritVal("com_audit",t-period.pid) +
                                               getKritVal("com_secur",t-period.pid) +
                                               getKritVal("com_other",t-period.pid)).

end.


/*1   com_precost */
/*2*/

def var COdata as deci.  /*Расходы (5класс) ЦО на филиалы*/
def var BotCount as deci. /*кол-во сотрудников филиала*/
def var AllBots as deci. /*общее кол-во сотрудников банка*/
def var FillArea as deci decimals 4. /*площадь филиала, единица измерения площади 4 знака после запятой*/
def var BankArea as deci decimals 4. /*общая площадь всего банка, единица измерения площади 4 знака после запятой*/


def var q as deci extent 10.

for each t-period no-lock:

    /*
    run setStoredKritVal( s-ourbank , "?" , t-period.dtb ,getKritVal("?",t-period.pid)).

    COdata = getKritVal("?",t-period.pid).
    */
   /* run setStoredKritVal( s-ourbank , "com_exp_all" , t-period.dtb ,getKritVal("com_exp_all",t-period.pid)).*/

    COdata = getKritVal("com_exp_all",t-period.pid).


    BotCount = getSprValI ( s-ourbank , "staffCount" , t-period.dtb ).
    AllBots = getSprValI ( "all" , "staffCount" , t-period.dtb ).
    FillArea = getSprValR ( s-ourbank , "filArea" , t-period.dtb ).
    BankArea = getSprValR ( "all" , "filArea" , t-period.dtb ).

    q[1] = BotCount / AllBots * 0.60.

    q[2] = FillArea / BankArea * 0.40.

    q[3] = q[1] + q[2].

    q[4] = COdata * q[3].

  /* message string(COdata,">>>,>>>,>>>,>>9.99") BotCount AllBots FillArea BankArea string(q[4],">>>,>>>,>>>,>>9.99") view-as alert-box.*/

    /*Распределение расходов ЦО на филиалы*/
    if AllBots <> 0 and BankArea <> 0 then
        run setKritVal("com_operexp",t-period.pid, (COdata * (( (BotCount / AllBots)  * 0.60) + (( FillArea / BankArea ) * 0.40))) - COdata ). /*нужны значения из данных ЦО*/


    /*Операционная прибыль ЦО (до провизий)*/

    run setKritVal("com_precost",t-period.pid,
    getKritVal("net_incom",t-period.pid) +
    getKritVal("com_NetCommFXincome1003",t-period.pid) +
    getKritVal("com_inexp",t-period.pid) +
    getKritVal("com_inexp_val",t-period.pid) -
    getKritVal("com_exp_all",t-period.pid) -
    getKritVal("com_operexp",t-period.pid)).

end.

/*3*/
for each t-period no-lock:
    /*Итого операционный доход ЦО с учетом провизий*/
    run setKritVal("com_postcost",t-period.pid, getKritVal("com_precost",t-period.pid) - getKritVal("com_prov",t-period.pid) ).
end.

/*4*/
for each t-period no-lock:
    /*Итого операционный доход ЦО (с учетом распределения расходов ЦО)*/
    /* com_capcost = com_postcost - com_operexp*/
    run setKritVal("com_capcost",t-period.pid, getKritVal("com_postcost",t-period.pid) - getKritVal("com_operexp",t-period.pid) ).
end.






/* Если не создана запись со значением - создаем с нулем */
for each t-krit no-lock:
    for each t-period no-lock:
        find first t-kritval where t-kritval.bank = s-ourbank and t-kritval.kid = t-krit.kid and t-kritval.pid = t-period.pid no-lock no-error.
        if not avail t-kritval then run setKritVal(t-krit.kcode, t-period.pid, 0).
    end.
end.

hide frame msg no-pause.



/* Сохранение данных для консолидированного отчета*/
for each t-period no-lock:

   run setStoredKritVal( s-ourbank , "dueNBRK" , t-period.dtb ,getKritVal("dueNBRK",t-period.pid)).
   run setStoredKritVal( s-ourbank , "nbrkCorr" , t-period.dtb ,getKritVal("nbrkCorr",t-period.pid)).
   run setStoredKritVal( s-ourbank , "nbrkDep" , t-period.dtb ,getKritVal("nbrkDep",t-period.pid)).
   run setStoredKritVal( s-ourbank , "dueBanks" , t-period.dtb ,getKritVal("dueBanks",t-period.pid)).

   run setStoredKritVal( s-ourbank , "secur" , t-period.dtb ,getKritVal("secur",t-period.pid)).
   run setStoredKritVal( s-ourbank , "securTrade" , t-period.dtb ,getKritVal("securTrade",t-period.pid)).
   run setStoredKritVal( s-ourbank , "securInvest" , t-period.dtb ,getKritVal("securInvest",t-period.pid)).
   run setStoredKritVal( s-ourbank , "securREPO" , t-period.dtb ,getKritVal("securREPO",t-period.pid)).

   run setStoredKritVal( s-ourbank , "lon" , t-period.dtb ,getKritVal("lon",t-period.pid)).
   run setStoredKritVal( s-ourbank , "lonr1" , t-period.dtb ,getKritVal("lonr1",t-period.pid)).
   run setStoredKritVal( s-ourbank , "lonr2" , t-period.dtb ,getKritVal("lonr2",t-period.pid)).
   run setStoredKritVal( s-ourbank , "lonr3" , t-period.dtb ,getKritVal("lonr3",t-period.pid)).
   run setStoredKritVal( s-ourbank , "lonri" , t-period.dtb ,getKritVal("lonri",t-period.pid)).
   run setStoredKritVal( s-ourbank , "lonro30" , t-period.dtb ,getKritVal("lonro30",t-period.pid)).
   run setStoredKritVal( s-ourbank , "lonrio" , t-period.dtb ,getKritVal("lonrio",t-period.pid)).
   run setStoredKritVal( s-ourbank , "lonrp" , t-period.dtb ,getKritVal("lonrp",t-period.pid)).
   run setStoredKritVal( s-ourbank , "lonrp18" , t-period.dtb ,getKritVal("lonrp18",t-period.pid)).

   run setStoredKritVal( s-ourbank , "lonast" , t-period.dtb ,getKritVal("lonast",t-period.pid)).
   run setStoredKritVal( s-ourbank , "astSoft" , t-period.dtb ,getKritVal("astSoft",t-period.pid)).
   run setStoredKritVal( s-ourbank , "taxAst" , t-period.dtb ,getKritVal("taxAst",t-period.pid)).
   run setStoredKritVal( s-ourbank , "assets_other" , t-period.dtb ,getKritVal("assets_other",t-period.pid)).
   run setStoredKritVal( s-ourbank , "assets_total" , t-period.dtb ,getKritVal("assets_total",t-period.pid)).

   run setStoredKritVal( s-ourbank , "SO_dueToBanks" , t-period.dtb ,getKritVal("SO_dueToBanks",t-period.pid)).
   run setStoredKritVal( s-ourbank , "SO_depo" , t-period.dtb ,getKritVal("SO_depo",t-period.pid)).
   run setStoredKritVal( s-ourbank , "SO_depov" , t-period.dtb ,getKritVal("SO_depov",t-period.pid)).
   run setStoredKritVal( s-ourbank , "SO_depov1" , t-period.dtb ,getKritVal("SO_depov1",t-period.pid)).
   run setStoredKritVal( s-ourbank , "SO_depov2" , t-period.dtb ,getKritVal("SO_depov2",t-period.pid)).
   run setStoredKritVal( s-ourbank , "SO_depov3" , t-period.dtb ,getKritVal("SO_depov3",t-period.pid)).
   run setStoredKritVal( s-ourbank , "SO_depov%" , t-period.dtb ,getKritVal("SO_depov%",t-period.pid)).

   run setStoredKritVal( s-ourbank , "SO_depoGAR" , t-period.dtb ,getKritVal("SO_depoGAR",t-period.pid)).
   run setStoredKritVal( s-ourbank , "SO_privlSr" , t-period.dtb ,getKritVal("SO_privlSr",t-period.pid)).
   run setStoredKritVal( s-ourbank , "SO_dolgObiaz" , t-period.dtb ,getKritVal("SO_dolgObiaz",t-period.pid)).
   run setStoredKritVal( s-ourbank , "SO_nalogObiaz" , t-period.dtb ,getKritVal("SO_nalogObiaz",t-period.pid)).

   run setStoredKritVal( s-ourbank , "docSetCredit" , t-period.dtb ,getKritVal("docSetCredit",t-period.pid)).

   run setStoredKritVal( s-ourbank , "SO_prochieObiaz" , t-period.dtb ,getKritVal("SO_prochieObiaz",t-period.pid)).
   run setStoredKritVal( s-ourbank , "SO_subordDolg" , t-period.dtb ,getKritVal("SO_subordDolg",t-period.pid)).
   run setStoredKritVal( s-ourbank , "SO_obiazatelstva" , t-period.dtb ,getKritVal("SO_obiazatelstva",t-period.pid)).

   run setStoredKritVal( s-ourbank , "SO_ustkapital" , t-period.dtb ,getKritVal("SO_ustkapital",t-period.pid)).
   run setStoredKritVal( s-ourbank , "SO_Aksion_capital" , t-period.dtb ,getKritVal("SO_Aksion_capital",t-period.pid)).
   run setStoredKritVal( s-ourbank , "SO_Privelig_capital" , t-period.dtb ,getKritVal("SO_Privelig_capital",t-period.pid)).

   run setStoredKritVal( s-ourbank , "SO_Adjust_provision_account" , t-period.dtb ,getKritVal("SO_Adjust_provision_account",t-period.pid)). /*TZ1120*/

   run setStoredKritVal( s-ourbank , "SO_Reserve" , t-period.dtb ,getKritVal("SO_Reserve",t-period.pid)).

   run setStoredKritVal( s-ourbank , "SO_Ner_dohod_pred" , t-period.dtb ,getKritVal("SO_Ner_dohod_pred",t-period.pid)).
   run setStoredKritVal( s-ourbank , "SO_Ner_dohod_tekuch" , t-period.dtb ,getKritVal("SO_Ner_dohod_tekuch",t-period.pid)).

   run setStoredKritVal( s-ourbank , "SO_Net_profit_loss" , t-period.dtb ,getKritVal("SO_Net_profit_loss",t-period.pid)). /*TZ1120*/
   run setStoredKritVal( s-ourbank , "SO_Retained_earnings" , t-period.dtb ,getKritVal("SO_Retained_earnings",t-period.pid)). /*TZ1120*/

   run setStoredKritVal( s-ourbank , "SO_Ner_other_reserve" , t-period.dtb ,getKritVal("SO_Ner_other_reserve",t-period.pid)).
   run setStoredKritVal( s-ourbank , "SO_itoge_obiaz" , t-period.dtb ,getKritVal("SO_itoge_obiaz",t-period.pid)).



  /* run setStoredKritVal( s-ourbank , "SO_allocated_branches" , t-period.dtb ,getKritVal("SO_allocated_branches",t-period.pid)).*/

   run setStoredKritVal( s-ourbank , "SO_zaimi" , t-period.dtb ,getKritVal("SO_zaimi",t-period.pid)).
   run setStoredKritVal( s-ourbank , "SO_do_vostr" , t-period.dtb ,getKritVal("SO_do_vostr",t-period.pid)).
   run setStoredKritVal( s-ourbank , "SO_zaim_1" , t-period.dtb ,getKritVal("SO_zaim_1",t-period.pid)).
   run setStoredKritVal( s-ourbank , "SO_zaim_2" , t-period.dtb ,getKritVal("SO_zaim_2",t-period.pid)).
   run setStoredKritVal( s-ourbank , "SO_zaim_3" , t-period.dtb ,getKritVal("SO_zaim_3",t-period.pid)).
   run setStoredKritVal( s-ourbank , "SO_zaim_4" , t-period.dtb ,getKritVal("SO_zaim_4",t-period.pid)).
   run setStoredKritVal( s-ourbank , "SO_itogo_dolg" , t-period.dtb ,getKritVal("SO_itogo_dolg",t-period.pid)).

   run setStoredKritVal( s-ourbank , "londoh" , t-period.dtb ,getKritVal("londoh",t-period.pid)).
   run setStoredKritVal( s-ourbank , "londoh_banks" , t-period.dtb ,getKritVal("londoh_banks",t-period.pid)).
   run setStoredKritVal( s-ourbank , "londoh_clients" , t-period.dtb ,getKritVal("londoh_clients",t-period.pid)).
   run setStoredKritVal( s-ourbank , "londoh_secur" , t-period.dtb ,getKritVal("londoh_secur",t-period.pid)).
   run setStoredKritVal( s-ourbank , "londoh_other" , t-period.dtb ,getKritVal("londoh_other",t-period.pid)).
   run setStoredKritVal( s-ourbank , "londoh_branch" , t-period.dtb ,getKritVal("londoh_branch",t-period.pid)).

   run setStoredKritVal( s-ourbank , "SO_rashod" , t-period.dtb ,getKritVal("SO_rashod",t-period.pid)).
   run setStoredKritVal( s-ourbank , "SO_rashod_deposit" , t-period.dtb ,getKritVal("SO_rashod_deposit",t-period.pid)).
   run setStoredKritVal( s-ourbank , "SO_rashod_bank" , t-period.dtb ,getKritVal("SO_rashod_bank",t-period.pid)).
   run setStoredKritVal( s-ourbank , "SO_rashod_sen" , t-period.dtb ,getKritVal("SO_rashod_sen",t-period.pid)).
   run setStoredKritVal( s-ourbank , "SO_rashod_subDolg" , t-period.dtb ,getKritVal("SO_rashod_subDolg",t-period.pid)).
   run setStoredKritVal( s-ourbank , "SO_pref_shares" , t-period.dtb ,getKritVal("SO_pref_shares",t-period.pid)).
   run setStoredKritVal( s-ourbank , "SO_rashod_prochie" , t-period.dtb ,getKritVal("SO_rashod_prochie",t-period.pid)).
   run setStoredKritVal( s-ourbank , "SO_rashod_filial" , t-period.dtb ,getKritVal("SO_rashod_filial",t-period.pid)).

   run setStoredKritVal( s-ourbank , "net_incom" , t-period.dtb ,getKritVal("net_incom",t-period.pid)).
   run setStoredKritVal( s-ourbank , "com_incom" , t-period.dtb ,getKritVal("com_incom",t-period.pid)).

 /*  run setStoredKritVal( s-ourbank , "com_other1003" , t-period.dtb ,getKritVal("com_other1003",t-period.pid)).*/
   run setStoredKritVal( s-ourbank , "com_FXincome1003" , t-period.dtb ,getKritVal("com_FXincome1003",t-period.pid)).
   run setStoredKritVal( s-ourbank , "com_FXexpense1003" , t-period.dtb ,getKritVal("com_FXexpense1003",t-period.pid)).
   run setStoredKritVal( s-ourbank , "com_NetCommFXincome1003" , t-period.dtb ,getKritVal("com_NetCommFXincome1003",t-period.pid)).

   run setStoredKritVal( s-ourbank , "com_exp" , t-period.dtb ,getKritVal("com_exp",t-period.pid)).
   run setStoredKritVal( s-ourbank , "com_incom_all" , t-period.dtb ,getKritVal("com_incom_all",t-period.pid)).

   run setStoredKritVal( s-ourbank , "com_inexp" , t-period.dtb ,getKritVal("com_inexp",t-period.pid)).
   run setStoredKritVal( s-ourbank , "com_inexp_val" , t-period.dtb ,getKritVal("com_inexp_val",t-period.pid)).

   run setStoredKritVal( s-ourbank , "com_socpay" , t-period.dtb ,getKritVal("com_socpay",t-period.pid)).
   run setStoredKritVal( s-ourbank , "com_bon" , t-period.dtb ,getKritVal("com_bon",t-period.pid)).
   run setStoredKritVal( s-ourbank , "com_trip" , t-period.dtb ,getKritVal("com_trip",t-period.pid)).
   run setStoredKritVal( s-ourbank , "com_renpay" , t-period.dtb ,getKritVal("com_renpay",t-period.pid)).
   run setStoredKritVal( s-ourbank , "com_amort" , t-period.dtb ,getKritVal("com_amort",t-period.pid)).
   run setStoredKritVal( s-ourbank , "com_taxgov" , t-period.dtb ,getKritVal("com_taxgov",t-period.pid)).
   run setStoredKritVal( s-ourbank , "com_mark" , t-period.dtb ,getKritVal("com_mark",t-period.pid)).
   run setStoredKritVal( s-ourbank , "com_call" , t-period.dtb ,getKritVal("com_call",t-period.pid)).
   run setStoredKritVal( s-ourbank , "com_secur" , t-period.dtb ,getKritVal("com_secur",t-period.pid)).
   run setStoredKritVal( s-ourbank , "com_admin" , t-period.dtb ,getKritVal("com_admin",t-period.pid)).
   run setStoredKritVal( s-ourbank , "com_audit" , t-period.dtb ,getKritVal("com_audit",t-period.pid)).
   run setStoredKritVal( s-ourbank , "com_other" , t-period.dtb ,getKritVal("com_other",t-period.pid)).
   run setStoredKritVal( s-ourbank , "com_exp_all" , t-period.dtb ,getKritVal("com_exp_all",t-period.pid)).

   run setStoredKritVal( s-ourbank , "com_precost" , t-period.dtb ,getKritVal("com_precost",t-period.pid)).

   run setStoredKritVal( s-ourbank , "com_prov" , t-period.dtb ,getKritVal("com_prov",t-period.pid)).
   run setStoredKritVal( s-ourbank , "com_prov1" , t-period.dtb ,getKritVal("com_prov1",t-period.pid)).
   run setStoredKritVal( s-ourbank , "com_prov2" , t-period.dtb ,getKritVal("com_prov2",t-period.pid)).

   run setStoredKritVal( s-ourbank , "com_postcost" , t-period.dtb ,getKritVal("com_postcost",t-period.pid)).

   run setStoredKritVal( s-ourbank , "com_operexp" , t-period.dtb ,getKritVal("com_operexp",t-period.pid)).
   run setStoredKritVal( s-ourbank , "com_capcost" , t-period.dtb ,getKritVal("com_capcost",t-period.pid)).

   run setStoredKritVal( s-ourbank , "lc" , t-period.dtb ,getKritVal("lc",t-period.pid)).
   run setStoredKritVal( s-ourbank , "lg" , t-period.dtb ,getKritVal("lg",t-period.pid)).

   run setStoredKritVal( s-ourbank , "openfx" , t-period.dtb ,getKritVal("openfx",t-period.pid)).

   for each crc where crc.crc <> 5 no-lock.
     run setStoredKritVal( s-ourbank , "openfx" + string(crc.crc) , t-period.dtb ,getKritVal("openfx" + string(crc.crc),t-period.pid)).
   end.


end.


/*
output stream rep close.
v-result = "".
input through value ("mv " + repname + " /data/reports/uprav/" + repname ).
repeat:
  import unformatted v-result.
end.
if v-result <> "" then do:
     message " Произошла ошибка при перемещении отчета - " v-result.
end.
*/
