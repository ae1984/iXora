/* check_term.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
      Расчет срока движения капитала
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * BASES
         BANK COMM
 * AUTHOR
        14.05.2008 galina
 * CHANGES
        10.11.2008 galina - проверка на наличие параметра p-dt
        13.04.2009 galina - при сравнении сумм округляем до двух символов после десятичного разделителя
        25/05/2009 galina - считаем срок движения капитала от заданной даты p-dt, если она есть
        07/09/2010 galina - учет актов по контарктам с ПС, если инопартнер в России или Белоруссии
        28.02.2011 aigul - добавила if avail vcdocs then vp-dt = vcdocs.dndate.
                           else vp-dt = g-today.
        13.08.2013 damir - Внедрено Т.З. № 1559,1308.
 */
{global.i}

def input parameter p-contract like vccontrs.contract.
def input parameter p-sumgtd as deci.
def input parameter p-sumplat as deci.
def input parameter p-sumakt as deci.
def input parameter p-sumexc_6 as deci.
def input parameter p-dt as date.
def output parameter p-term as integer.

def buffer b-vcdocs for vcdocs.
def buffer b1-vcdocs for vcdocs.
def buffer b2-vcdocs for vcdocs.

def var v-docsplat as char init "".
def var vp-sum as deci.
def var vp-dt as date.
def var vp-dt_pl as date.
def var vp-dt_gtd as date.
def var vp-dt_akt as date.
def var v-ts as logi.

for each codfr where codfr.codfr = "vcdoc" and index("p", codfr.name[5]) > 0 no-lock:
  v-docsplat = v-docsplat + codfr.code + ",".
end.

p-term = 0.

find vccontrs where vccontrs.contract = p-contract no-lock no-error.
if vccontrs.cttype = "3"  then do:
if  round(p-sumakt,2) > round(p-sumplat,2) then do:
  /* есть акты, не покрытые извещениями */
  if p-sumplat = 0 then do:
    /* нет извещений - берем просто первый акт */
    find first vcdocs where vcdocs.contract = p-contract and vcdocs.dntype = "17" and ((p-dt <> ? and vcdocs.dndate <= p-dt) or p-dt = ?) use-index main no-lock no-error.
    /*vp-dt = vcdocs.dndate.*/
    if avail vcdocs then vp-dt = vcdocs.dndate.
    else vp-dt = g-today.
  end.
  else do:
    /* идем по актам, пока их сумма меньше суммы платежей */
    vp-sum = 0.
    for each vcdocs where vcdocs.contract = p-contract and vcdocs.dntype = "17" and ((p-dt <> ? and vcdocs.dndate <= p-dt) or p-dt = ?)
       no-lock use-index main.
      vp-sum = vp-sum + vcdocs.sum / vcdocs.cursdoc-con.
      if vp-sum > p-sumplat then do:
        vp-dt = vcdocs.dndate.
        leave.
      end.
    end.
  end.
end.

if round(p-sumakt,2) < round(p-sumplat,2) then do:
    /* есть платежи, не покрытые актами */
    if p-sumakt = 0 then do:
      /* нет актов - берем просто первый платеж */
      find first vcdocs where vcdocs.contract = p-contract and
      lookup(vcdocs.dntype, v-docsplat) > 0 and ((p-dt <> ? and vcdocs.dndate <= p-dt) or p-dt = ?) use-index main no-lock no-error.
      /*vp-dt = vcdocs.dndate.*/
      if avail vcdocs then vp-dt = vcdocs.dndate.
      else vp-dt = g-today.
    end.
    else do:
      /* идем по платежам минус возвраты, пока их сумма меньше суммы актов */
      for each vcdocs where vcdocs.contract = p-contract and lookup(vcdocs.dntype, v-docsplat) > 0 and ((p-dt <> ? and vcdocs.dndate <= p-dt) or p-dt = ?) no-lock use-index main.
        if vcdocs.payret  then vp-sum = vp-sum - vcdocs.sum / vcdocs.cursdoc-con.
        else vp-sum = vp-sum + vcdocs.sum / vcdocs.cursdoc-con.
        if vp-sum > p-sumakt then do:
          vp-dt = vcdocs.dndate.
          leave.
        end.
      end.
    end.
  end.
  if round(p-sumakt,2) = round(p-sumplat,2) then vp-dt = g-today.
end.

if (vccontrs.cttype = '1' or vccontrs.cttype = '2') then do:
/* контракты по товарам */
v-ts = no.
find first vcpartner where vcpartner.partner = vccontrs.partner no-lock no-error.
if avail vcpartner and (vcpartners.country = 'RU' or vcpartners.country = 'BY') then do:
    v-ts = yes.
    p-sumgtd = p-sumgtd + p-sumakt.
end.
if round(p-sumgtd,2) > round(p-sumplat,2) then do:
  /* есть ГТД, не покрытые извещениями */
  if p-sumplat = 0 then do:
    /* нет извещений - берем просто первую ГТД */
    find first vcdocs where vcdocs.contract = p-contract and (vcdocs.dntype = "14" or (vcdocs.dntype = "17" and v-ts)) and ((p-dt <> ? and vcdocs.dndate <= p-dt) or p-dt = ?)
    use-index main no-lock no-error.
    /*vp-dt = vcdocs.dndate.*/
    if avail vcdocs then vp-dt = vcdocs.dndate.
    else vp-dt = g-today.
  end.
  else do:
    /* идем по ГТД, пока их сумма меньше суммы платежей */
    vp-sum = 0.
    for each vcdocs where vcdocs.contract = p-contract and (vcdocs.dntype = "14" or (vcdocs.dntype = "17" and v-ts)) and ((p-dt <> ? and vcdocs.dndate <= p-dt) or p-dt = ?)
      no-lock use-index dndate.
      if vcdocs.payret then vp-sum = vp-sum - vcdocs.sum / vcdocs.cursdoc-con.
                       else vp-sum = vp-sum + vcdocs.sum / vcdocs.cursdoc-con.
      if vp-sum > p-sumplat then do:
        vp-dt = vcdocs.dndate.
        leave.
      end.
    end.
  end.
 end.

 if round(p-sumgtd,2) < round(p-sumplat,2) then do:
    /* есть платежи, не покрытые ГТД */
    if p-sumgtd = 0 then do:
      /* нет ГТД - берем просто первый платеж */
      find first vcdocs where vcdocs.contract = p-contract and
      lookup(vcdocs.dntype, v-docsplat) > 0 and ((p-dt <> ? and vcdocs.dndate <= p-dt) or p-dt = ?) use-index main no-lock no-error.
      /*vp-dt = vcdocs.dndate.*/
      if avail vcdocs then vp-dt = vcdocs.dndate.
      else vp-dt = g-today.
    end.
    else do:
      /* идем по платежам минус возвраты, пока их сумма меньше суммы ГТД */
      for each vcdocs where vcdocs.contract = p-contract and
        lookup(vcdocs.dntype, v-docsplat) > 0 /*and vcdocs.dndate <= p-dt*/ and ((p-dt <> ? and vcdocs.dndate <= p-dt) or p-dt = ?) no-lock use-index main.
        if vcdocs.payret then vp-sum = vp-sum - vcdocs.sum / vcdocs.cursdoc-con.
                         else vp-sum = vp-sum + vcdocs.sum / vcdocs.cursdoc-con.

        if vp-sum > p-sumgtd then do:
          find first b-vcdocs where b-vcdocs.contract = p-contract and
                                    lookup(b-vcdocs.dntype, v-docsplat) > 0 and
                                    b-vcdocs.payret = yes and b-vcdocs.dndate > vcdocs.dndate and ((p-dt <> ? and vcdocs.dndate <= p-dt) or p-dt = ?) no-lock use-index main no-error.
          if avail b-vcdocs then do:
               if (vp-sum - b-vcdocs.sum / b-vcdocs.cursdoc-con) > p-sumgtd then do:
                  vp-dt = vcdocs.dndate.
                  leave.
               end.
          end.
          else do:
               vp-dt = vcdocs.dndate.
               leave.
          end.
        end.
      end.
     end.
     end.

   if round(p-sumgtd,2) = round(p-sumplat,2) then vp-dt = g-today.
end.

if vccontrs.cttype = "6" then do:
    def var v-sum1 as deci.
    def var v-sum2 as deci.
    find first vcdocs where vcdocs.contract = p-contract and lookup(vcdocs.dntype, v-docsplat) > 0 and (if vccontrs.expimp = 'E' then vcdocs.dntype = '02' else vcdocs.dntype = '03')
    and ((p-dt <> ? and vcdocs.dndate <= p-dt) or p-dt = ?) no-lock no-error.
    if avail vcdocs then do:
        v-sum1 = 0.
        m1:
        for each b1-vcdocs where b1-vcdocs.contract = p-contract and (if vccontrs.expimp = 'E' then b1-vcdocs.dntype = '02' else b1-vcdocs.dntype = '03') and
        ((p-dt <> ? and b1-vcdocs.dndate <= p-dt) or p-dt = ?) no-lock use-index docum:
            if b1-vcdocs.payret then v-sum1 = v-sum1 - b1-vcdocs.sum / b1-vcdocs.cursdoc-con.
            else v-sum1 = v-sum1 + b1-vcdocs.sum / b1-vcdocs.cursdoc-con.
            v-sum2 = 0.
            m2:
            for each b2-vcdocs where b2-vcdocs.contract = p-contract and (if vccontrs.expimp = 'E' then b2-vcdocs.dntype = '03' else b2-vcdocs.dntype = '02') and
            ((p-dt <> ? and b2-vcdocs.dndate <= p-dt) or p-dt = ?) no-lock use-index docum:
                if b2-vcdocs.payret then v-sum2 = v-sum2 - b2-vcdocs.sum / b2-vcdocs.cursdoc-con.
                else v-sum2 = v-sum2 + b2-vcdocs.sum / b2-vcdocs.cursdoc-con.
            end.
            if v-sum2 >= v-sum1 then next m1.
            else do:
                vp-dt = b1-vcdocs.dndate.
                leave m1.
            end.
        end.
    end.
    else vp-dt = g-today.
    if vp-dt = ? then vp-dt = g-today.
end.

if p-dt <> ? then p-term = p-dt - vp-dt.
else p-term = g-today - vp-dt.
