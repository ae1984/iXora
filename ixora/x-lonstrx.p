  /* x-lonstrx.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Назначение программы, описание процедур и функций
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
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        20.10.2003  marinav  Добавился шаблон lon0064 для оплаты штрафов
        30.12.2003 marinav Изменился шаблон lon0048
        07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
        27/09/2004 madiar - Списание на внебаланс (if s-ptype eq 9) - шаблон lon0048 поменял на новый шаблон lon0091
        29/09/2004 madiar - Списание на внебаланс (if s-ptype eq 9) - запретили проводки по тенговым кредитам пропускать через счета конвертации
        30/11/2004 madiar - Списание штрафов
        03/12/2004 madiar - Потерянные кредиты - три новые линии в шаблоне lon0091
        28/02/2005 madiar - Исправил ошибку, возникающую при попытке списания кредита в валюте
        02.11.2005 dpuchkov добавил номер очереди
        13.07.2006 Natalya D. - добавлена проверка юзера на наличие у него пакета прав, разрешающих проведение транзакций
        10.01.2011 Luiza   - добавила передачу пустого параметра ("") при вызове trxsim.p
*/

{global.i}
{s-lonliz.i}
{comm-txb.i}
def var ja-ne as log format "да/нет".
def var vou-count as int.
def shared var s-ptype as int.

def shared var s-lon like lon.lon.
def shared var s-crc like crc.crc.
def shared var ppay like lon.opnamt.
def shared var ipay like lon.opnamt.
/*
def shared var total-pay1 as dec.
def shared var total-pay  as dec.
*/
def shared var s-acc like aaa.aaa.
def shared var s-rmz like remtrz.remtrz.
def shared var s-gl like gl.gl.

def shared var ppay1 as decimal.
def shared var ipay1 as decimal.

def shared var v-amtod as dec.
def shared var v-intod as dec.
def shared var v-amtbl as dec.
def shared var v-payod as dec.
def shared var v-payiod as dec.
def shared var v-payiod1 as dec.
def shared var v-paybl as dec.
def shared var v-payod1 as dec.
def shared var v-paybl1 as dec.
define shared variable sds-pay as decimal.
define shared variable sds-pay1 as decimal.

def var v-templ as char.
def var v-param as char.
def var vdel as char initial "^".
def var rcode as int.
def var rdes as char.
def var jparr as char.
def shared var s-jh like jh.jh.

def var jane as log.
def var v-nxt as int.

def var i as int.
def var v-tmpl as int.

def var v-amtint as dec.
def var v-prdint as dec.
def var v-intnc  as dec.
def var v-intnc1  as dec.
def var v-intnc2  as dec.

def var v-buyamt as dec.
def var v-selamt as dec.
def var v-buyamt1 as dec.
def var v-selamt1 as dec.

def buffer b-ofc for ofc.
define var v-chk as char.


def var v-payi1 as dec. /*  Оплата просроченных процентов из предоплаты */
def var v-payi2 as dec. /*  Оплата процентов из предоплаты */
def var v-payi3 as dec. /*  Оплата просроченных процентов из источника */
def var v-payi4 as dec. /*  Оплата процентов из источника */
def var v-payi5 as dec. /*  Оплата предоплаты процентов из источника */
def var v-payi6 as dec.

/* ja - EKNP - 26/03/2002 */
define temp-table w-cods
       field template as char
       field parnum as inte
       field codfr as char
       field what as char
       field name as char
       field val as char.
def var OK as logi initial false.
/*ja - EKNP - 26/03/2002 */

find lon where lon.lon eq s-lon no-lock no-error.
find trxbal where trxbal.sub eq "lon" and trxbal.acc eq lon.lon and
trxbal.crc eq lon.crc and trxbal.lev eq 2 no-lock no-error.
if available trxbal then v-amtint = trxbal.dam - trxbal.cam. else v-amtint = 0.



find trxbal where trxbal.sub eq "lon" and trxbal.acc eq lon.lon and
trxbal.crc eq lon.crc and trxbal.lev eq 10 no-lock no-error.
if available trxbal then v-prdint = trxbal.cam - trxbal.dam. else v-prdint = 0.

find trxbal where trxbal.sub eq "lon" and trxbal.acc eq lon.lon and
trxbal.crc eq 1 and trxbal.lev eq 11 no-lock no-error.
if available trxbal then v-intnc = trxbal.cam - trxbal.dam. else v-intnc = 0.

if lon.crc ne s-crc then do :
    find crc where crc.crc eq s-crc no-lock no-error.
    if s-ptype eq 1 then
    v-buyamt = total-pay1 * (crc.rate[1] - crc.rate[2]) / crc.rate[9].
    else v-buyamt = total-pay1 * (crc.rate[1] - crc.rate[4]) / crc.rate[9].
    if v-buyamt lt 0 then do:
        v-buyamt1 = - v-buyamt.
        v-buyamt = 0.
    end.
    else v-buyamt1 = 0.

    find crc where crc.crc eq lon.crc no-lock no-error.
    v-selamt = total-pay * (crc.rate[5] - crc.rate[1]) / crc.rate[9].
    if v-selamt lt 0 then do:
        v-selamt1 = - v-selamt.
        v-selamt = 0.
    end.
    else v-selamt1 = 0.
    v-param = string(v-buyamt) + vdel +
    string(v-buyamt1) + vdel +
    string(v-selamt) + vdel +
    string(v-selamt1) + vdel +
    string(total-pay1) + vdel +
    string(s-crc) + vdel .
    v-templ = "lon0012".
    if s-ptype eq 3 then do:
        v-param = v-param + s-acc + vdel.
        v-templ = "lon0016".
    end.
    if s-ptype eq 4 then v-templ = "lon0018".
end.
else do:
    v-param = "".
    v-templ = "lon0011".
    if s-ptype eq 3 then do:
        v-param = s-acc + vdel.
        v-templ = "lon0015".
    end.
    if s-ptype eq 4 then v-templ = "lon0017".
end.


    v-payi5 = ipay - (v-amtint + v-payiod - v-prdint) .

    if v-payi5 ge 0 then
    v-payi6 = v-intod - v-payiod.
    else v-payi6 = v-intod - v-payiod - v-payi5 .
    if lon.crc ne 1 then do:
        find crc where crc.crc eq lon.crc no-lock no-error.
        v-payi6 = v-payi6 * crc.rate[1] / crc.rate[9].
    end.
    v-payi6 = v-intnc - v-payi6.
    if v-payi6 lt 0 then v-payi6 = 0.

    if v-payi5 ge v-prdint then do:
        v-payi5 = v-payi5 - v-prdint.
        v-payi1 = 0.
        v-payi2 = 0.
        v-payi3 = v-payiod.
        v-payi4 = ipay - v-payi3 - v-payi5.
    end.
    else do :
        if v-payi5 ge 0 then
        v-payi1 = v-prdint - v-payi5.
        else v-payi1 = v-prdint.
        v-payi5 = 0.
        if v-payi1 gt v-payiod1 then do:
            v-payi2 = v-payi1 - v-payiod.
            v-payi1 = v-payiod.
        end.
        else v-payi2 = 0.
        v-payi3 = v-payiod - v-payi1.
        v-payi4 = ipay - v-payi3.
    end.

if lon.crc eq s-crc then
v-param = string(ppay - v-payod - v-paybl) + vdel + v-param +
lon.lon + vdel +
string(v-payod) + vdel +
string(v-paybl) + vdel +
string(v-payi4) + vdel +
string(v-payi3) + vdel +
string(v-payi5) + vdel +
string(v-payi2) + vdel +
string(v-payi1) + vdel +
string(v-payi6).
else
v-param = v-param + string(ppay - v-payod - v-paybl) + vdel +
lon.lon + vdel +
string(v-payod) + vdel +
string(v-paybl) + vdel +
string(v-payi4) + vdel +
string(v-payi3) + vdel +
string(v-payi5) + vdel +
string(v-payi2) + vdel +
string(v-payi1) + vdel +
string(v-payi6).


/*
if s-ptype eq 9 then do:
v-templ = "LON0048".

v-param = string(ppay - v-payod - v-paybl) + vdel +
lon.lon + vdel +
string(v-payod) + vdel +
string(v-paybl) + vdel +
string(v-payi4) + vdel + | 2 |
string(v-payi3). | 9 |
find crc where crc.crc eq s-crc no-lock no-error.
v-intnc1 = 0.
if (v-payi3 + v-payi4 + ppay) * crc.rate[1] > v-intnc
              then v-intnc1 = (v-payi3 + v-payi4 + ppay) * crc.rate[1] - v-intnc.

v-param = v-param + vdel + string((ppay - v-payod - v-paybl) * crc.rate[1]) +
vdel + string(v-intnc) + vdel + string(v-intnc1) + vdel + string(ppay) +
vdel + string(v-payi3 + v-payi4).

end.
*/


if s-ptype eq 9 then do:
v-templ = "LON0091".

find crc where crc.crc eq s-crc no-lock no-error.

/*
v-payod - проср од
v-payiod - проср проценты
v-intnc - содержимое 11го уровня
*/

if s-crc <> 1 then do:
   v-param = string(v-payod * crc.rate[1]) + vdel + /* закрываем провизии (сумма провизий = проср. од, переводим в тенге на счет конвертации) */
             lon.lon + vdel + /* ссудный счет */
             string(v-payod) + vdel + /* закрываем проср. од, в валюте кредита на счет конвертации */
             string(v-payod). /* начисляем на 13 уровень - списанная основная сумма кредита */

   v-param = v-param + vdel +
   s-glremx[1] + vdel +
   s-glremx[2] + vdel +
   s-glremx[3] + vdel +
   s-glremx[4] + vdel +
   s-glremx[5].

   v-intnc1 = 0.
   v-intnc2 = 0.
   if v-intnc > v-payiod * crc.rate[1] then v-intnc1 = v-payiod * crc.rate[1].
   else do: v-intnc1 = v-intnc. v-intnc2 = v-payiod * crc.rate[1] - v-intnc. end.

   v-param = v-param + vdel +
             string(v-intnc1) + vdel + /* закрываем 11 уровень на сумму проср. % , переводим в тенге на счет конвертации */
             string(v-payiod) + vdel + /* закрываем 9 уровень на сумму проср. % */
             string(v-payiod) + vdel + /* начисляем на 14 уровень - списанные % */
             string(v-intnc2) + vdel + /* закрываем 594200 на сумму v-payiod * crc.rate[1] - v-intnc */
             '0' + vdel + '0' + vdel + '0' + vdel + /* прямые проводки, без счетов конвертации */
             string(sds-pay) + vdel + string(sds-pay). /* штрафы */

   find first sub-cod where sub-cod.acc = lon.lon and sub-cod.sub = "LON" and sub-cod.d-cod = "kdlost" no-lock no-error.
   if avail sub-cod then do:
      if sub-cod.ccode = '01' then v-param = v-param + vdel + string(v-payod) + vdel + string(v-payiod) + vdel + string(sds-pay).
      else v-param = v-param + vdel + '0' + vdel + '0' + vdel + '0'.
   end.
   else v-param = v-param + vdel + '0' + vdel + '0' + vdel + '0'.

end.
else do:
   v-param = '0' + vdel + /* закрываем провизии (сумма провизий = проср. од, переводим в тенге на счет конвертации) */
             lon.lon + vdel + /* ссудный счет */
             '0' + vdel + /* закрываем проср. од, в валюте кредита на счет конвертации */
             string(v-payod). /* начисляем на 13 уровень - списанная основная сумма кредита */

   v-param = v-param + vdel +
   s-glremx[1] + vdel +
   s-glremx[2] + vdel +
   s-glremx[3] + vdel +
   s-glremx[4] + vdel +
   s-glremx[5].

   v-intnc1 = 0.
   v-intnc2 = 0.
   if v-intnc > v-payiod then v-intnc1 = v-payiod.
   else do: v-intnc1 = v-intnc. v-intnc2 = v-payiod - v-intnc. end.

   v-param = v-param + vdel +
             '0' + vdel + /* закрываем 11 уровень на сумму проср. % , переводим в тенге на счет конвертации */
             '0' + vdel + /* закрываем 9 уровень на сумму проср. % */
             string(v-payiod) + vdel + /* начисляем на 14 уровень - списанные % */
             '0' + vdel + /* закрываем 594200 на сумму v-payiod * crc.rate[1] - v-intnc */
             string(v-payod) + vdel + /* погашаем проср од провизиями */
             string(v-intnc1) + vdel + /* Дт 11 Кт 9 */
             string(v-intnc2) + vdel + /* Дт 594200 Кт 9 */
             string(sds-pay) + vdel + string(sds-pay). /* штрафы */

   find first sub-cod where sub-cod.acc = lon.lon and sub-cod.sub = "LON" and sub-cod.d-cod = "kdlost" no-lock no-error.
   if avail sub-cod then do:
      if sub-cod.ccode = '01' then v-param = v-param + vdel + string(v-payod) + vdel + string(v-payiod) + vdel + string(sds-pay).
      else v-param = v-param + vdel + '0' + vdel + '0' + vdel + '0'.
   end.
   else v-param = v-param + vdel + '0' + vdel + '0' + vdel + '0'.

end.

end.


if s-ptype = 1 and sds-pay1 > 0 then do:
   v-templ = "LON0064".
   v-param = string(sds-pay1) + vdel + lon.lon.
   s-glremx[1] = 'Оплата штрафов ' + string(sds-pay1).
   s-glremx[1] = ''.
   s-glremx[1] = ''.
   s-glremx[1] = ''.
   s-glremx[1] = ''.
end.

v-param = v-param + vdel +
s-glremx[1] + vdel +
s-glremx[2] + vdel +
s-glremx[3] + vdel +
s-glremx[4] + vdel +
s-glremx[5].

/*Natalya D. - перед формированием транзакции проверяет юзера на соответствие пакету доступа*/
            run usrrights.
            if return-value = '1' then
               run trxsim("", v-templ, vdel, v-param, 4, output rcode,
               output rdes, output jparr).
            else do:
              message "У Вас нет прав для создания транзакции!"
                   view-as alert-box.
               return "exit".
            end.
/*end*/
if rcode ne 0 then do:
    message rdes.
    pause 11.
    undo, return.
end.

/* ja - EKNP - 26/03/2002 --------------------------------------------*/
        run Collect_Undefined_Codes(v-templ).
        run Parametrize_Undefined_Codes(output OK).
        if not OK then do:
           bell.
           message "Не все коды введены! Транзакция не будет создана!"
                   view-as alert-box.
           return "exit".
        end.

           run Insert_Codes_Values(v-templ, vdel, input-output v-param).
/* ja - EKNP - 26/03/2002 --------------------------------------------*/

s-jh = 0.

/*Natalya D. - перед формированием транзакции проверяет юзера на соответствие пакету доступа*/
            run usrrights.
            if return-value = '1' then
               run trxgen (v-templ, vdel, v-param, "lon" , lon.lon , output rcode,
                           output rdes, input-output s-jh).
            else do:
              message "У Вас нет прав для создания транзакции!"
                   view-as alert-box.
               return "exit".
            end.
/*end*/
if rcode ne 0 then do:
    message rdes.
    pause 10.
    undo, return.
end.
run lonresadd(s-jh).

find jh where jh.jh eq s-jh no-lock no-error.
if available jh then do :

if s-ptype = 4
then do:
     find remtrz where remtrz.remtrz = s-rmz no-lock no-error.
     ja-ne = available remtrz.
     if ja-ne
     then do:
          find first que where que.remtrz = s-rmz no-lock no-error.
          if available que
          then do:
               if remtrz.jh2 = s-jh and que.pid = "F"
               then ja-ne = true.
               else do:
                    run longoF(s-rmz,"LON",jh.jh,output ja-ne).
               end.
          end.
     end.
     if not ja-ne
     then do:
          bell.
          message "В операции не найден перевод !".
          pause.
          undo,return.
     end.
end.







if ppay gt 0 then do:
v-nxt = 0.
for each lnsch where lnsch.lnn eq lon.lon no-lock :
    if lnsch.f0 eq 0 and lnsch.flp gt 0 then do:
        if v-nxt lt lnsch.flp then v-nxt = lnsch.flp.
    end.
end.
create lnsch.
lnsch.lnn = lon.lon.
lnsch.f0 = 0.
lnsch.flp = v-nxt + 1.
lnsch.schn = "   . ." + string(lnsch.flp,"zzzz").
lnsch.paid = ppay.
lnsch.stdat = jh.jdt.
lnsch.jh = jh.jh.
lnsch.whn = g-today.
lnsch.who = g-ofc.
end.

if ipay gt 0 then do:
v-nxt = 0.
for each lnsci where lnsci.lni eq lon.lon no-lock :
    if lnsci.f0 eq 0 and lnsci.flp gt 0 then do:
        if v-nxt lt lnsci.flp then v-nxt = lnsci.flp.
    end.
end.
create lnsci.
lnsci.lni = lon.lon.
lnsci.f0 = 0.
lnsci.flp = v-nxt + 1.
lnsci.schn = "   . ." + string(lnsci.flp,"zzzz").
lnsci.paid-iv = ipay.
lnsci.idat = jh.jdt.
lnsci.jh = jh.jh.
lnsci.whn = g-today.
lnsci.who = g-ofc.
end.


/*Номер очереди*/
if s-ptype = 1 then do:
 find b-ofc where b-ofc.ofc = g-ofc no-lock no-error.
 if comm-txb() = "TXB00" then do: /*Только Алматы ЦО*/
       find last acheck where acheck.jh = string(s-jh) and acheck.dt = g-today no-lock no-error.
       if not avail acheck then do:
          v-chk = "".
          v-chk = string(NEXT-VALUE(krnum)).
          create acheck.
                 acheck.jh  = string(s-jh).
                 acheck.num = string(day(g-today),"99") + string(month(g-today),"99") + string(year(g-today)) + substr(g-ofc, 4, 3) + v-chk.
                 acheck.dt = g-today.
                 acheck.n1 = v-chk.
         release acheck.
       end.
  end.
end.
/*Номер очереди*/


/* pechat vauchera */
ja-ne = no.
vou-count = 1. /* kolichestvo vaucherov */

do on endkey undo:
   message "Печатать ваучер ?" update ja-ne.
   if ja-ne
   then do:
      message "Сколько ?" update vou-count format "9" .
      if vou-count > 0 and vou-count < 10 then do:
         find first jl where jl.jh = s-jh no-error.
         if available jl
         then do:
              {mesg.i 0933} s-jh.
              s-jh = jh.jh.


              do i = 1 to vou-count:
/*               run vou_lon(s-jh,'').*/
if s-ptype = 1 then
      run vou_lon2(s-jh,'',1, "").
else
      run vou_lon(s-jh,'').
              end.
              find jh where jh.jh eq s-jh exclusive-lock.
              if jh.sts < 5
              then jh.sts = 5.
              for each jl of jh:
                  if jl.sts < 5
                  then jl.sts = 5.
              end.
         end.  /* if available jl */
         else do:
            message "Не найдена транзакция " s-jh view-as alert-box.
            return.
         end.
      end.  /* if vou-count > 0 */
   end. /* if ja-ne */
   if lon.gua = "LK" then do on endkey undo:
      ja-ne = no.
      vou-count = 1.
      message "Печатать ордер-счет ?" update ja-ne.
      if ja-ne
      then do:
         message "Сколько ?" update vou-count.
         if vou-count > 0 and vou-count < 10 then do:
            do i = 1 to vou-count:
               run x-lonord.
            end.
         end. /* if vou-count */
      end. /* if ja-ne */
   end.
end.
pause 0.

/*if s-ptype >= 2 and jh.sts = 5
then do:
     ja-ne = no.
     do on endkey undo:
        message "Штамповать ?" update ja-ne.
        if ja-ne
        then do:
             run jl-stmp.
        end.
     end.
end.
*/

end.

/*ja - EKNP - 26/03/2002 -------------------------------------------*/
Procedure Collect_Undefined_Codes.

def input parameter c-templ as char.
def var vjj as inte.
def var vkk as inte.
def var ja-name as char.

for each w-cods:
   delete w-cods.
end.
for each trxhead where trxhead.system = substring (c-templ, 1, 3)
             and trxhead.code = integer(substring(c-templ, 4, 4)) no-lock:

    if trxhead.sts-f eq "r" then vjj = vjj + 1.

    if trxhead.party-f eq "r" then vjj = vjj + 1.

    if trxhead.point-f eq "r" then vjj = vjj + 1.

    if trxhead.depart-f eq "r" then vjj = vjj + 1.

    if trxhead.mult-f eq "r" then vjj = vjj + 1.

    if trxhead.opt-f eq "r" then vjj = vjj + 1.

    for each trxtmpl where trxtmpl.code eq c-templ no-lock:

        if trxtmpl.amt-f eq "r" then vjj = vjj + 1.

        if trxtmpl.crc-f eq "r" then vjj = vjj + 1.

        if trxtmpl.rate-f eq "r" then vjj = vjj + 1.

        if trxtmpl.drgl-f eq "r" then vjj = vjj + 1.

        if trxtmpl.drsub-f eq "r" then vjj = vjj + 1.

        if trxtmpl.dev-f eq "r" then vjj = vjj + 1.

        if trxtmpl.dracc-f eq "r" then vjj = vjj + 1.

        if trxtmpl.crgl-f eq "r" then vjj = vjj + 1.

        if trxtmpl.crsub-f eq "r" then vjj = vjj + 1.

        if trxtmpl.cev-f eq "r" then vjj = vjj + 1.

        if trxtmpl.cracc-f eq "r" then vjj = vjj + 1.

        repeat vkk = 1 to 5:
            if trxtmpl.rem-f[vkk] eq "r" then vjj = vjj + 1.
        end.

        for each trxcdf where trxcdf.trxcode = trxtmpl.code
                          and trxcdf.trxln = trxtmpl.ln:

         if trxcdf.drcod-f eq "r" then do:
             vjj = vjj + 1.

             find first trxlabs where trxlabs.code = trxtmpl.code
                                  and trxlabs.ln = trxtmpl.ln
                                  and trxlabs.fld = trxcdf.codfr + "_Dr"
                                                        no-lock no-error.
             if available trxlabs then ja-name = trxlabs.des.
             else do:
               find codific where codific.codfr = trxcdf.codfr no-lock no-error.
               if available codific then ja-name = codific.name.
               else ja-name = "Неизвестный кодификатор".
             end.
            create w-cods.
                   w-cods.template = c-templ.
                   w-cods.parnum = vjj.
                   w-cods.codfr = trxcdf.codfr.
                   w-cods.name = ja-name.
         end.

         if trxcdf.crcode-f eq "r" then do:
             vjj = vjj + 1.

             find first trxlabs where trxlabs.code = trxtmpl.code
                                  and trxlabs.ln = trxtmpl.ln
                                  and trxlabs.fld = trxcdf.codfr + "_Cr"
                                                        no-lock no-error.
             if available trxlabs then ja-name = trxlabs.des.
             else do:
               find codific where codific.codfr = trxcdf.codfr no-lock no-error.
               if available codific then ja-name = codific.name.
               else ja-name = "Неизвестный кодификатор".
             end.
            create w-cods.
                   w-cods.template = c-templ.
                   w-cods.parnum = vjj.
                   w-cods.codfr = trxcdf.codfr.
                   w-cods.name = ja-name.
         end.
  end.
    end. /*for each trxtmpl*/
end. /*for each trxhead*/

End procedure.

Procedure Parametrize_Undefined_Codes.

  def var ja-nr as inte.
  def output parameter OK as logi initial false.
  def var jrcode as inte.
  def var saved-val as char.

  find first w-cods no-error.
  if not available w-cods then do:
    OK = true.
    return.
  end.

  {jabrew.i
   &start = " on help of w-cods.val in frame lon_cods do:
                  if w-cods.codfr = 'spnpl' then run uni_help1(w-cods.codfr,'4*').
                                            else run uni_help1(w-cods.codfr,'*').
              end.
              vkey = 'return'.
              key-i = 0. "

   &head = "w-cods"
   &headkey = "parnum"
   &where = "true"
   &formname = "lon_cods"
   &framename = "lon_cods"
   &deletecon = "false"
   &addcon = "false"
   &prechoose = "message 'F1-сохранить и выйти; F4-выйти; Enter-редактировать; F2-помощь'."
   &predisplay = " ja-nr = ja-nr + 1. "
   &display = "ja-nr /*w-cods.codfr*/ w-cods.name /*w-cods.what*/ w-cods.val"
   &highlight = "ja-nr"
   &postkey = "else if vkeyfunction = 'return' then do:
               valid:
               repeat:
                saved-val = w-cods.val.
                update w-cods.val with frame lon_cods.
                find codfr where codfr.codfr = w-cods.codfr
                             and codfr.code = w-cods.val no-lock no-error.
                if not available codfr or codfr.code = 'msc' then do:
                   bell.
                   message 'Некорректное значение кода! Введите правильно!'
                           view-as alert-box.
                   w-cods.val = saved-val.
                   display w-cods.val with frame lon_cods.
                   next valid.
                end.
                else leave valid.
               end.
                if crec <> lrec and not keyfunction(lastkey) = 'end-error' then do:
                  key-i = 0.
                  vkey = 'cursor-down^return'.
                end.
               end.
               else if keyfunction(lastkey) = 'GO' then do:
                   jrcode = 0.
                 for each w-cods:
                  find codfr where codfr.codfr = w-cods.codfr
                             and codfr.code = w-cods.val no-lock no-error.
                  if not available codfr or codfr.code = 'msc' then jrcode = 1.
                 end.
                 if jrcode <> 0 then do:
                    bell.
                    message 'Введите коды корректно!' view-as alert-box.
                    ja-nr = 0.
                    next upper.
                 end.
                 else do: OK = true. leave upper. end.
               end."
   &end = "hide frame lon_cods.
           hide message."
}

End procedure.

Procedure Insert_Codes_Values.

def input parameter t-template as char.
def input parameter t-delimiter as char.
def input-output parameter t-par-string as char.
def var t-entry as char.

for each w-cods where w-cods.template = t-template break by w-cods.parnum:
   t-entry = entry(w-cods.parnum,t-par-string,t-delimiter) no-error.
   if ERROR-STATUS:error then
      t-par-string = t-par-string + t-delimiter + w-cods.val.
   else do:
      entry(w-cods.parnum,t-par-string,t-delimiter) = t-delimiter + t-entry.
      entry(w-cods.parnum,t-par-string,t-delimiter) = w-cods.val.
   end.
end.

End procedure.
/*ja - EKNP - 26/03/2002 ------------------------------------------*/
