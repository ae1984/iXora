/* s-lonisl.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Выдача кредита
 * RUN
        s-lonisl
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        4-1-1- Верхнее меню "Выдача"
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        30.10.2002 nadejda - наименование клиента заменено на форма собств + наименование
        25.08.2003 marinav - Учет платежей по графику погашения только по кредитной линии
        09.09.2003 nadejda - если перевод на счет, то заморозить эти средства на счете до контроля старшим менеджером
        11.09.2003 nadejda - добавлено прописывание признака выдачи "GRANT OF LOAN" в jh.party
        20.11.2003 nadejda - вызов заморозки специнструкций изменен с jou-aasnew на lon-aasnew для возможности блокировки денег ФЛ
        07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
        08.05.2004 nadejda - если выдача на счет и это юрлицо - включить его в список для мониторинга казначейства
        14.05.2004 nadejda - если сумма больше минимальной - на мониторинг
        19/07/2004 madiyar - при выдаче потреб.кредита физ.лицу - выводится запрос об установке льготных тарифов
        02.11.2004 saltanat - в процедуре x-lonisj изменила заполнение переменной s-glrem.
        08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
        05.07.2005 saltanat - Выборка льгот по счетам.
        28/09/2005 madiyar - код комиссии 141 -> 230
        07/10/2005 madiyar - льготы ставятся на счет, соотв. на счет KZT - льготы только KZT, на валютные счета - льготы только валютные
        02.11.2005 dpuchkov добавил номер очереди
        08/12/2005 madiyar - если льгота была на клиента, ее не трогаем
        26/12/2005 madiyar - изменения в льготах
        05/01/2006 Natalya D. - для филиалов, если кредит не подписан, то не выдавать.
        14/04/2006 madiyar - новые льготы 180, 181, 193
        19/04/2006 madiyar - разморозка по тарифу 193 при навешивании льгот
        04/05/06 marinav Увеличить размерность поля суммы
        13.07.2006 Natalya D. - добавлена проверка юзера на наличие у него пакета прав, разрешающих проведение транзакций
        29/05/2007 madiyar - убрал лишний код для чистки библиотеки
        21/05/2008 madiyar - при выдаче кредита статус кредита меняется на активный ('A')
        20/11/2008 madiyar - подправил изменение статуса на активный ('A')
        09/08/2010 madiyar - убрал льготы по тарифам 195, 105, 254; добавил 450 и 429
        03/12/2010 madiyar - выдача траншей по КЛ
*/

{global.i}
{lonlev.i}

/* 19/07/2004 madiyar - переменные и процедуры для выдачи льгот по потреб. кредитам */
{comm-txb.i}
define var s-ourbank as char.
s-ourbank = comm-txb().

def var ii as integer.

def buffer b-ofc for ofc.
define var v-chk as char.
def var paraksts as logi.

def buffer blon for lon.
def buffer bloncon for loncon.

procedure add-excl.
  def input parameter p-aaa as char.
  def input parameter p-cif as char.
  def input parameter p-kod as char.

  find tarif2 where tarif2.str5 = p-kod and tarif2.stat = 'r' no-lock no-error.
  if avail tarif2 then do:

   find tarifex where tarifex.cif = p-cif and tarifex.str5 = p-kod exclusive-lock no-error.
    if not avail tarifex then do:
      create tarifex.
      assign tarifex.cif = p-cif
             tarifex.kont = tarif2.kont
             tarifex.pakalp = "Временно - потреб кредит"
             tarifex.str5 = p-kod
             tarifex.crc = 1
             tarifex.who = "M" + g-ofc    /* 'установлено вручную или по временным льготным тарифам' */
             tarifex.whn = g-today
             tarifex.stat = 'r'
             tarifex.wtim = time
             tarifex.ost = tarif2.ost
             tarifex.proc = tarif2.proc
             tarifex.max1 = tarif2.max1
             tarifex.min1 = tarif2.min1.
      run tarifexhis_update.
    end.

    find tarifex2 where tarifex2.aaa = p-aaa and tarifex2.cif = p-cif and tarifex2.str5 = p-kod exclusive-lock no-error.
    if not avail tarifex2 then do:
      create tarifex2.
      assign tarifex2.aaa = p-aaa
             tarifex2.cif = p-cif
             tarifex2.kont = tarif2.kont
             tarifex2.pakalp = "Временно - потреб кредит"
             tarifex2.str5 = p-kod
             tarifex2.crc = 1
             tarifex2.who = "M" + g-ofc   /* -- признак 'установлено вручную или по временным льготным тарифам' */
             tarifex2.whn = g-today
             tarifex2.stat = 'r'
             tarifex2.wtim = time.
    end.
    assign tarifex2.ost  = 0
           tarifex2.proc = 0
           tarifex2.max1 = 0
           tarifex2.min1 = 0.

   run tarifex2his_update.

    release tarifex.
    release tarifex2.
  end. /* tarif2 */
end procedure.

/* ---- процедура сохранения истории при добавлении и изменении данных" ---- */
procedure tarifexhis_update.
        create tarifexhis.
        buffer-copy tarifex to tarifexhis.
end procedure.

procedure tarifex2his_update.
        create tarifex2his.
        buffer-copy tarifex2 to tarifex2his.
end procedure.

/* 19/07/2004 madiyar end */

{s-lonisj.f}.

def shared var s-lon like lon.lon .  /* acct # */
def shared var xjh like jh.jh.

define new shared variable s-vint like lnsci.iv.
define new shared variable s-gl like gl.gl.     /* payment gl # */
define new shared variable s-acc like jl.acc.   /* payment acct # */
define new shared variable s-acciss2 like jl.acc.
define new shared variable s-aaa like aaa.aaa.
define new shared variable s-srv like jl.dam extent 3.
define new shared variable algpay as decimal.
define new shared variable loniss like jl.dam.
define new shared variable loniss1  as decimal.
define new shared variable loniss2  as decimal.
define new shared variable loniss21 as decimal.
define new shared variable s-payment as decimal.
define new shared variable s-crc like crc.crc.
define new shared variable s-jh like jh.jh.
define new shared variable s-consol like jh.consol initial false.
define new shared variable s-aah  as int.
define new shared variable s-line as int.
define new shared variable s-force as log initial false.
define new shared variable camt as dec.
define new shared variable y-jh as integer.
define new shared variable y-vln as integer.
define new shared variable s-remo like remtrz.remtrz.
define new shared variable s-gliss2 like gl.gl.
define new shared variable s-glin   like gl.gl.
define new shared variable s-glout  like gl.gl.
define new shared variable s-crcin  like crc.crc.
define new shared variable s-crcout like crc.crc.
define new shared variable s-accin  like jl.acc.
define new shared variable s-accout like jl.acc.
define new shared variable s-amtin  as decimal.
define new shared variable s-amtout as decimal.
define new shared variable rc       as integer init 0.
define new shared variable s-rem    as character init "".
define new shared variable s-longl  as integer extent 20.
define new shared variable sjh      like jh.jh.
define new shared variable vln      as integer.
define new shared variable vcif     like lon.cif.
def new shared var s-cif as char.

def var cl-ost as deci no-undo.

def var schggl like lon.gl extent 3 .
def var s-ptype like lon.ptype.
def var loniss20 as decimal.
def var londam like jl.dam.
def var not-iss like jl.dam.
def var vnrr as inte.
def var vnr as inte.
def var vn as inte.
def var v-srv as inte format "zz9" extent 3.
def var vrem as cha format "x(55)".
def var vamt like jl.dam.
def var cnt as int.
def var v-name as character.
def buffer b for lnscg.
def var branch as char format "x(3)".
define variable c-code  as character.
define variable c-code1 as character.
define variable c-code2 as character.
define variable c-code21 as character.
define variable c-code3 as character.
define variable c-code4 as character.
define variable c-code5 as character.
define variable kurss   as decimal.
define variable v-glcash as integer.
define variable ok as logical.
define variable   ja  as logical format "да/нет".
define variable   j   as integer.
def var i as int.
define variable   vou-count as integer format "z9".
define variable   depo-sum  as decimal.
define variable   depo-atl  as decimal.
def var v-sum as decimal.
def var v-jlsum as decimal.

/*---- variables for leasing ------*/

{s-lonliz.i "NEW"}

define variable lon-avn as    decimal.       /* avanss */
define variable pvn-sum as    decimal.       /* summa  PVN */
define variable not-paied-avn as  decimal.   /* avansa neapmaks–ta summa */

define variable v-avncrc    as character.
define variable v-avncrc1   as character.
define variable v-pvncrc    as character.
define variable v-pvncrc1   as character.
define variable depo-crc    as character.
define variable depo-crc1   as character.
define variable s-pvn-debet  like gl.gl.
define variable s-pvn-kredit like gl.gl.
define variable s-gl-avn     like gl.gl.
define variable s-gl-depo    like gl.gl.

def var gl-loniss  like gl.gl.
def var gl-loniss2 like gl.gl.
def var gl-depo    like gl.gl.
def var gl-jlcrc   like gl.gl.

def var gl-rem5    as char extent 5.


def var v-param as char.
def var v-templ as char.
def var vdel as char initial "^".
def var v-rcode as int.
def var v-rdes as char.
def var v-nxt as int.
def var v-who as char format "x(50)".
def var v-passp as char .
def var v-perkod as char format "x(50)".
define frame f_cus
    v-who   label "ПОЛУЧАТЕЛЬ " skip
    v-passp  label "ПАСПОРТ    "  format "x(320)" view-as fill-in size 50 by 1
    skip
    v-perkod label "ПЕРС.КОД   "
    with row 15 col 16 overlay side-labels.
/* ja - EKNP - 26/03/2002 */
define temp-table w-cods
       field template as char
       field parnum as inte
       field codfr as char
       field what as char
       field name as char
       field val as char.
/*ja - EKNP - 26/03/2002 */

lon-avn       = 0.
pvn-sum       = 0.
avnpay        = 0.
pvnpay        = 0.
noform-pay    = 0.
atalg-pay     = 0.
total-pay     = 0.
avnpay1       = 0.
pvnpay1       = 0.
noform-pay1   = 0.
atalg-pay1    = 0.
total-pay1    = 0.
not-paied-avn = 0.
depo-sum      = 0.
depo-pay      = 0.
depo-pay1     = 0.
find sysc where sysc.sysc = 'bilext' no-lock no-error.
if avail sysc then branch = sysc.chval.
find sysc where sysc.sysc = "CASHGL" no-lock.
v-glcash = sysc.inval.

find lon where lon.lon = s-lon.
s-cif = lon.cif.

find loncon where loncon.lon = s-lon no-lock no-error.
if substring(loncon.rez-char[10],index(loncon.rez-char[10],"&") + 1,3) = "yes" then paraksts = yes.
else paraksts = no.
find ofc where ofc.ofc = g-ofc no-lock no-error.
if paraksts = no and (ofc.titcd <> '523') and (comm-txb() <> 'TXB00') then do:
    message "Вы не можете выдать неподписанный кредит!" view-as alert-box. pause 5.
    return.
end.

find first blon where blon.clmain = s-lon no-lock no-error.
if avail blon then do:
    message "По данной кредитной линии уже есть привязанные транши, выдача невозможна!" view-as alert-box.
    return.
end.

if lon.clmain <> '' then do:
    find first blon where blon.lon = lon.clmain no-lock no-error.
    if (not avail blon) or (blon.gua <> "CL") then do:
        message "Не найдена кредитная линия данного транша!" view-as alert-box.
        return.
    end.
end.

/* PVN % */
if lon.gua <> "LK" then lon-pvn = 0.
else do:
   find first lonhar where lonhar.lon = lon.lon and lonhar.ln = 1
   no-lock no-error.
   if lonhar.rez-char[3]  <> ""  then lon-pvn = decimal(lonhar.rez-char[3]).
   else lon-pvn = 0.
end.
if lon.gua = "LK" or lon.gua = "FK"
then do:
     run clear-fg("D").
     if lon.gua = "FK"
     then run clear-pg("C").
end.

s-ptype = 1.
loniss20 = 0.
if lon.gua = "LK"
then do:
     find lonhar where lonhar.lon = s-lon and lonhar.ln = 1 no-lock.
     loniss20 = lonhar.rez-dec[2].
     depo-sum = lonhar.rez-dec[4].
     find first lonliz where lonliz.lon = s-lon no-lock no-error.
     if available lonliz then do:
        lon-avn = lonliz.cam[1] - lonliz.dam[1].
        not-paied-avn = loniss20 - lon-avn.
        depo-atl = lonliz.cam[5] - lonliz.dam[5].
     end.
     else do:
        lon-avn = 0.
        not-paied-avn = loniss20 - lon-avn.
        depo-atl = 0.
     end.

     find arp where arp.arp = "44" + string(lon.crc) + "LIZ" no-lock no-error.
     if not available arp
     then do:
          bell.
          message "Несуществующая АРП карточка" "44" + string(lon.crc) + "LIZ".
          pause.
          return.
     end.
     s-gliss2 = arp.gl.
     s-gl-avn = arp.gl.

     run f-longl(lon.gl,"pvn_debet,pvn_kredit,gl-depo",output ok).
     if not ok
        then do:
        bell.
        message lon.lon " - s-lonisj:"
        "longl не определен счет".
        pause.
        return.
     end.
     s-pvn-debet  = s-longl[1].
     s-pvn-kredit = s-longl[2].
     s-gl-depo    = s-longl[3].
end.

not-iss = lon.opnamt.
if lon.gua = "CL" or lon.gua = "FK"
then do:
    for each trxbal where trxbal.subled eq "LON" and trxbal.acc eq lon.lon
    and trxbal.crc eq lon.crc
    no-lock :
        if lookup(string(trxbal.level) , v-lonprnlev , ";") gt 0 then
        not-iss = not-iss - (trxbal.dam - trxbal.cam).
    end.
    /*
     not-iss = not-iss - lon.dam[1] + lon.cam[1].
    */
    if lon.duedt < g-today then not-iss = 0.
end.
else do:
     for each lnscg where lnscg.lng = s-lon and lnscg.flp > 0 and lnscg.f0 > -1:
         not-iss = not-iss - lnscg.paid.
     end.
end.
if lon.gua = "LK"
then not-iss = not-iss - loniss20 - depo-sum.

/* Учет выданных аккредитивов и гарантий*/
for each lnakkred where lnakkred.lon = lon.lon no-lock:
   if lnakkred.crc ne lon.crc then  do:
       if lon.crc = 1 then do:
          find last crc where crc.crc = lnakkred.crc no-lock no-error.
          not-iss = not-iss - lnakkred.amount * crc.rate[1].
       end.
       if lon.crc ne 1 then do:
          find last crc where crc.crc = lnakkred.crc no-lock no-error.
          v-sum = lnakkred.amount * crc.rate[1].

          find last crc where crc.crc = lon.crc no-lock no-error.
          not-iss = not-iss - v-sum / crc.rate[1].
       end.
   end.
   else do:
       not-iss = not-iss - lnakkred.amount.
   end.
end.

/* Учет платежей по графику только по кредитной линии */
if lon.gua = "CL" then do:
   for each lnsch where lnn = lon.lon and lnsch.flp = 0 and lnsch.f0 > 0 and lnsch.stdat <= g-today no-lock.
       not-iss = not-iss - lnsch.paid.
   end.
end.

if not-iss lt 0 then not-iss = 0.
s-crc = lon.crc.
find crc where crc.crc = s-crc no-lock.
c-code    = crc.code.
c-code1   = crc.code.
c-code21  = c-code.
v-pvncrc  = c-code.
v-pvncrc1 = c-code.
c-code2   = c-code.
c-code3   = c-code.
c-code4   = c-code.
c-code5   = c-code.
depo-crc  = c-code.
depo-crc1 = c-code.

{s-lonissl.f}

on help of s-acc in frame s-loniss do:
  run h-hacc.
  s-acc = return-value.
  displ s-acc with frame s-loniss.
end.



c1:
repeat on endkey undo, return:
   s-crc = lon.crc.
   camt = 0.
   find crc where crc.crc = s-crc no-lock.
   kurss = crc.rate[4] / crc.rate[9].
   c-code = crc.code.
   c-code1 = crc.code.
   c-code21 = c-code.
   v-pvncrc = c-code.
   c-code2  = c-code.
   c-code3  = c-code.
   c-code4  = c-code.
   c-code5  = c-code.
   depo-crc = crc.code.

   update s-ptype validate(s-ptype > 0 and s-ptype < 5 and s-ptype ne 2, "")
          with frame s-loniss.
   if s-ptype = 1
   then do:
        v-name = "Выдача наличными".
        s-gl = v-glcash.
        display s-gl v-name with frame s-loniss.
   end.
   if s-ptype = 2
   then do on error undo,retry:
        v-name = "Чек".
        display v-name with frame s-loniss.
        update s-acc with frame s-loniss.
        find ock where ock.ock = s-acc no-error.
        if available ock
        then do:
             bell.
             message "CHECK ALREADY EXIST ...".
             undo,retry.
        end.
   end.
   if s-ptype = 3
   then do on error undo,retry:
        update s-acc with frame s-loniss.
        find aaa where aaa.aaa = s-acc no-error.
        if not available aaa
        then do:
             bell.
             {mesg.i 2203}.
             undo,retry.
        end.
        s-crc = aaa.crc.
        s-gl = aaa.gl.
        if aaa.sta eq "C"
        then do:
             bell.
             {mesg.i 6207}.
             undo,retry.
        end.
        s-aaa = s-acc.

        /* 19/07/2004 madiyar - установка льгот по потреб.кредитам */
        find cif where cif.cif = s-cif no-lock no-error.
        find sub-cod where sub-cod.sub = "cln" and sub-cod.acc = cif.cif and sub-cod.d-cod = "clnsts" no-lock.

        if sub-cod.ccode = '1' then do:
           message skip "Применить льготы по потреб. кредитам к текущему счету клиента?" skip(1)
                   view-as alert-box question buttons yes-no title " Внимание! " update choice as logical.
           if choice then do:
              if lon.crc = 1 then do:
                /*
                run add-excl(aaa.aaa, s-cif, "195").
                */
                run add-excl(aaa.aaa, s-cif, "230").
                /* run add-excl(aaa.aaa, s-cif, "142"). */
                run add-excl(aaa.aaa, s-cif, "180").
                run add-excl(aaa.aaa, s-cif, "450").
                run add-excl(aaa.aaa, s-cif, "429").
              end.
              else do:
                /*
                run add-excl(aaa.aaa, s-cif, "105").
                run add-excl(aaa.aaa, s-cif, "254").
                */
                /*
                run add-excl(aaa.aaa, s-cif, "165").
                run add-excl(aaa.aaa, s-cif, "166").
                */
                run add-excl(aaa.aaa, s-cif, "181").
              end.
              run add-excl(aaa.aaa, s-cif, "193").

              /* разморозка по 193 тарифу */
              find first aas where aas.aaa = aaa.aaa and aas.payee begins 'Неснижаемый остаток ОД |' no-lock no-error.
              if avail aas then run tdaremholdfiz(aaa.aaa).

           end. /* if choice */
        end. /* if sub-cod.ccode = '1' */

        /* 19/07/2004 madiyar end */

        def var vbal like jl.dam.
        def var vavl like jl.dam.
        def var vhbal like jl.dam.
        def var vfbal like jl.dam.
        def var vcrline like jl.dam.
        def var vcrlused like jl.dam.
        def var vooo like aaa.aaa.
        def buffer bcrc for crc.

        find bcrc where bcrc.crc = aaa.crc no-lock no-error.
        run aaa-bal777(input s-aaa, output vbal,output vavl, output vhbal,
        output vfbal, output vcrline, output vcrlused, output vooo).

        message "Входящий остаток: " string(vavl, "->>>,>>>,>>9.99")
        " " bcrc.code.
        pause no-message.

        run aaa-aas.
        find first aas where aas.aaa = s-aaa and aas.sic = 'SP' no-lock
             no-error.
        if available aas
        then do:
             pause.
             undo,retry.
        end.
        find cif where cif.cif = aaa.cif no-lock.
        v-name = aaa.aaa + " " + trim(trim(cif.prefix) + " " + trim(cif.name)).
        if cif.jss ne "" then v-name = v-name + " РНН " + cif.jss.
        display s-gl v-name with frame s-loniss.
    end.
    if s-ptype = 4
    then do:
         s-gl = 0.
         v-name = "Исходящий перевод".
         display s-gl v-name with frame s-loniss.
    end.
    if s-ptype <> 3
    then update s-crc with frame s-loniss.
    if s-crc <> lon.crc
    then do:
         find crc where crc.crc = s-crc no-lock.
         if s-gl = v-glcash
         then kurss = kurss * crc.rate[9] / crc.rate[3].
         else kurss = kurss * crc.rate[9] / crc.rate[5].
         c-code1 = crc.code.
         c-code21 = c-code1.
         v-pvncrc1 = crc.code.
         depo-crc1 = crc.code.
    end.
    else kurss = 1.
    display s-crc c-code1
    /* c-code21 v-pvncrc v-pvncrc1 */
    /* c-code3 c-code4 c-code5 */
    /* depo-crc depo-crc1 */

            with frame s-loniss.
    if s-ptype = 5
    then do on error undo,retry:
         update s-gl with frame s-loniss.
         find gl where gl.gl = s-gl no-lock no-error.
         if not available  gl
         then do:
              bell.
              undo,retry.
         end.
         v-name = gl.des.
         display v-name with frame s-loniss.
         if trim(gl.subled) <> ""
         then update s-acc with frame s-loniss.
         else s-acc = "".
    end.
    update loniss with frame s-loniss.
    /*
    pvn-sum  = round((loniss + loniss2 + depo-pay) * lon-pvn / 100, 2).
    pvnpay   = pvn-sum.
    pvnpay1  = round((loniss1 + loniss21 + depo-pay1) * lon-pvn / 100, 2).
    display pvn-sum pvnpay pvnpay1 with frame s-loniss.

    pause 0.
    */

    if lastkey = 13 or lon.gua = "LK" or lon.gua = "FK" then
    inner: do:
         if loniss = 0
         then do:
              run lnscgupd(input lon.lon).
              run loniss-p.
              if lon.gua = "LK" or lon.gua = "FK"
              then do:
                   run clear-fg("D").
                   if lon.gua = "FK"
                   then run clear-pg("C").
                   leave inner.
              end.
              next.
         end.
    end.
    if lon.gua <> "LK" and lon.gua <> "FK"
    then do:
         if  loniss = 0
         then do:
              update loniss1 with frame s-loniss.
              loniss = round(loniss1 / kurss, 2).
         end.
         else do:
              loniss1 = round(kurss * loniss, 2).
         end.
         display loniss loniss1 with frame s-loniss.
         /*
         pvn-sum  = round((loniss + loniss2 + depo-pay) * lon-pvn / 100, 2).
         pvnpay   = pvn-sum.
         pvnpay1  = round((loniss1 + loniss21 + depo-pay1) * lon-pvn / 100, 2).
         display pvn-sum pvnpay pvnpay1 with frame s-loniss.
         pause 0.
         */
    end.
    if loniss > 0
    then do:
         if lon.duedt < g-today
         then do:
              bell.
              message "Срок кредита истек!".
              next.
         end.
         else if loniss > not-iss
         then do:
              bell.
              message "Превышена сумма кредита!".
              next.
         end.
         if lon.gua = "LO" and lon.clmain <> '' then do:
            if lon.trtype <> 1 and lon.trtype <> 2 then do:
                bell.
                message "Указан некорректный тип транша, должен быть 1 или 2!".
                next.
            end.
            find first blon where blon.lon = lon.clmain no-lock no-error.
            if not avail blon then do:
                bell.
                message "Не найдена карточка кредитной линии!".
                next.
            end.
            if lon.trtype = 1 then run lonbalcrc('lon',blon.lon,g-today,"15",yes,blon.crc,output cl-ost).
            else run lonbalcrc('lon',blon.lon,g-today,"35",yes,blon.crc,output cl-ost).
            cl-ost = - cl-ost.
            if loniss > cl-ost then do:
                bell.
                message "Превышена сумма" if lon.trtype = 1 then "возобновляемого" else "невозобновляемого" "остатка кредитной линии!".
                next.
            end.
         end.
    end.
    if lon.gua = "LK"
    then inner: do on endkey undo,return:
         update loniss2 with frame s-loniss.
         if loniss2 > lon-avn and loniss2 > 0 then do:
            message "Превышена сумма аванса !".
            undo inner, retry inner.
         end.

         loniss21 = round(kurss * loniss2, 2).
         display loniss21 with frame s-loniss.

         if loniss2 = 0
         then do:
            if lastkey = 13 then do:
               run lonavn-p2(s-gl-avn, "D").
               leave inner.
            end.
            update loniss21 with frame s-loniss.

            if round(kurss * loniss21, 2) > lon-avn and loniss21 > 0 then do:
               message "Превышена сумма аванса !".
               undo inner, retry inner.
            end.

            loniss2 = round(loniss21 / kurss, 2).
            display loniss2 with frame s-loniss.
         end.

         display loniss2 loniss21 with frame s-loniss.
         s-acciss2 = "44" + string(lon.crc) + "liz".

         pvn-sum  = round((loniss + loniss2 + depo-pay) * lon-pvn / 100, 2).
         pvnpay   = pvn-sum.
         pvnpay1  = round((loniss1 + loniss21 + depo-pay1) * lon-pvn / 100, 2).
         display pvn-sum pvnpay pvnpay1 with frame s-loniss.
         pause 0.
    end.
    pause 0.

    if lon.gua = "LK"
    then inner: do on endkey undo,return:
         update depo-pay with frame s-loniss.
         if depo-pay > depo-atl and depo-pay > 0 then do:
            message "Превышена сумма депозита !".
            undo inner, retry inner.
         end.

         depo-pay1 = round(kurss * depo-pay, 2).
         display depo-pay1 with frame s-loniss.

         if depo-pay = 0
         then do:
            if lastkey = 13 then do:
               run lonavn-p2(s-gl-depo, "D").
               leave inner.
            end.
            update depo-pay1 with frame s-loniss.

            if round(kurss * depo-pay1, 2) > lon-avn and depo-pay1 > 0 then do:
               message "Превышена сумма депозита !".
               undo inner, retry inner.
            end.

            depo-pay = round(depo-pay1 / kurss, 2).
            display depo-pay with frame s-loniss.
         end.

         display depo-pay depo-pay1 with frame s-loniss.

         pvn-sum  = round((loniss + loniss2 + depo-pay) * lon-pvn / 100, 2).
         pvnpay   = pvn-sum.
         pvnpay1  = round((loniss1 + loniss21 + depo-pay1) * lon-pvn / 100, 2).
         display pvn-sum pvnpay pvnpay1 with frame s-loniss.
         pause 0.
    end.
    pause 0.

/*-----------------------------------------------------------------------
update s-acc with frame s-loniss. find dfb where dfb.dfb = s-acc no-error.
if not available dfb then do: bell. {mesg.i 2203}. undo,retry. end.
if dfb.crc ne lon.crc then do: bell. {mesg.i 9813}. undo,retry. end. end.
------------------------------------------------------------------------*/
    do cnt = 1 to 3:
       s-srv[cnt] = 0.
    end.
    if s-ptype <> 4 and lon.gua <> "LK"
    then do:
         do on error undo, retry:
            /*
            update v-srv validate(v-srv >= 0 and v-srv <= 100, "")
            with frame s-loniss.
            */
            if v-srv[1] + v-srv[2] + v-srv[3] > 100
            then do:
                 bell.
                 undo, retry.
            end.
         end.
         do cnt = 1 to 3:
            s-srv[cnt] = round(v-srv[cnt] * loniss / 100, 2).
         end.
         do on error undo, retry:
            /*
            update s-srv[1] validate(s-srv [1] >= 0 and s-srv[1] <= loniss, "")
                            when v-srv[1] = 0
                   s-srv[2] validate(s-srv [2] >= 0 and s-srv[2] <= loniss, "")
                            when v-srv[2] = 0
                   s-srv[3] validate(s-srv [3] >= 0 and s-srv[3] <= loniss, "")
                            when v-srv[3] = 0
                            with frame s-loniss.
            */
            if s-srv[1] + s-srv[2] + s-srv[3] > loniss
            then do:
                 bell.
                 undo, retry.
            end.
         end.

         pause 0.

         find sysc where sysc.sysc eq "LONC1" no-lock no-error.
         schggl[1] = sysc.inval.
         find sysc where sysc.sysc eq "LONC2" no-lock no-error.
         schggl[2] = sysc.inval.
         find sysc where sysc.sysc eq "LONC3" no-lock no-error.
         schggl[3] = sysc.inval.
    end.

    /* dobavlenije primechanija */
    do:
       s-glrem2 = "Выдача кредита".
       update  s-glrem2 with frame s-loniss.
       display s-glrem2 with frame s-loniss.
       pause 0.
       update  v-name with frame s-loniss.
       display v-name with frame s-loniss.
       pause 0.

    end.

    do on endkey undo, next c1 on error undo, next c1:
       ja = no.
       update ja with frame s-loniss.
       if ja then do:

          if s-ptype eq 1 then
          update v-who v-passp v-perkod with frame f_cus.



          run x-lonisj.  /* процедура в этом же файле */

          if return-value = "exit" then return.
          else if return-value = "next" then undo,next c1.
       end.
       else undo,next c1.
    end.
    leave.
end.

if loniss = 0 and loniss2 = 0 and depo-pay = 0 and pvnpay = 0
and s-srv[1] = 0 and s-srv[2] = 0 and s-srv[3] = 0
then undo,return.
find jh where jh.jh = s-jh.

/* pechat vauchera */
ja = no.
vou-count = 1. /* kolichestvo vaucherov */

do on endkey undo:
   message "Печатать ваучер ?" update ja.
   if ja
   then do:
      message "Сколько ?" update vou-count.
      if vou-count > 0 and vou-count < 10 then do:
         find first jl where jl.jh = s-jh no-error.
         if available jl
         then do:
              {mesg.i 0933} s-jh.
              s-jh = jh.jh.
              do i = 1 to vou-count:
                  if s-ptype = 1 then run vou_lon2(s-jh,'',2, "").  /* x-jlvou.  vou_bank. */
                  else run vou_lon(s-jh,'').
              end.

              /*
              if jh.sts < 5 then jh.sts = 5.
              for each jl of jh:
                if jl.sts < 5 then jl.sts = 5.
              end.
              */
         end.  /* if available jl */
         else do:
            message "Can't find transaction " s-jh view-as alert-box.
            return.
         end.
      end.  /* if vou-count > 0 */
   end. /* if ja */

   /* с апреля 2004 печать не обязательна, подготавливаем для штамповки */
   if jh.sts < 5 then jh.sts = 5.
   for each jl of jh:
     if jl.sts < 5 then jl.sts = 5.
   end.
   pause 0.
end.
pause 0.

if s-ptype >= 2 and jh.sts <= 5 then do:
   run ln_kontofc (jh.who, no, output ja).
   if ja then do:
     ja = no.
     message "Штамповать ?" update ja.
     if ja then do:
       run chgsts(input "lon", jh.jh, "lon").
       run jl-stmp.
     end.
  end.
end.


if s-ptype = 3 then do:
  /* найти линию проводки с окончательной суммой */
  find first jl where jl.jh = s-jh and jl.acc = s-acc and jl.dc = "c" no-lock no-error.
  if avail jl then do:
    /* 09.09.2003 nadejda - если перевод на счет и проводка еще не отштампована, то заморозить эти средства на счете до контроля старшим менеджером */
    if jh.sts <= 5 then run lon-aasnew (s-acc, jl.cam, s-jh).

    /* 08.05.2004 nadejda - если это юрлицо - включить его в список для мониторинга казначейства */
    find sub-cod where sub-cod.sub = "cln" and sub-cod.acc = s-cif and sub-cod.d-cod = "clnsts" no-lock no-error.
    if avail sub-cod and sub-cod.ccode = "0" then do:
      find sysc where sysc = "monlop" no-lock no-error.
      /* включить в список, если есть настройка мониторинга */
      if avail sysc then do:
        v-jlsum = jl.cam.
        if jl.crc <> 1 then do:
          find first crc where crc.crc = jl.crc no-lock no-error.
          v-jlsum = v-jlsum * crc.rate[1].
        end.
        /* 14.05.2004 nadejda - если сумма больше минимальной - на мониторинг */
        if v-jlsum >= sysc.deval then run mclnadd ("1", s-cif, s-lon, s-acc, jl.crc, jl.cam, s-jh).
      end.
    end.
  end.
end.


/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
procedure x-lonisj.

    /* формирование примечания */
    find lon where lon.lon eq s-lon no-lock no-error.
    find cif where cif.cif eq lon.cif no-lock no-error.
    s-rem = trim(trim(cif.prefix) + " " + trim(cif.name)).
    find loncon where loncon.lon eq s-lon no-lock no-error.
    find crc where crc.crc eq lon.crc no-lock no-error.
    s-glrem = "Кредит " + s-lon + " " + loncon.lcnt + " " +
              trim(string(lon.opnamt,">>>,>>>,>>>,>>>,>>>,>>9.99-")) + " " + crc.code + " " + 
              trim(trim(cif.prefix) + " " + trim(cif.name)) + " РНН " + cif.jss.

    s-glremx[1] = trim(s-glrem).
    s-glremx[2] = trim(s-glrem2).
    s-glremx[3] = "".
    s-glremx[4] = v-name.
    if s-ptype = 1 then s-glremx[5] = "/ПОЛУЧАТЕЛЬ/" + v-who + "/ПАСПОРТ/" + v-passp + "/ПЕРС.КОД/" + v-perkod.

    find lon where lon.lon = s-lon.
    c1:
    do on endkey undo,return on error undo,return:
        vcif = lon.cif.
        do on error undo,next:
            find loncon where loncon.lon = lon.lon no-lock.
            find cif where cif.cif = lon.cif no-lock.
            s-rem = trim(trim(cif.prefix) + " " + trim(cif.name)).
            do while index(s-rem,"^") <> 0 :
                substring(s-rem,index(s-rem,"^"),1) = "'".
            end.
            camt = 0.
            s-jh = 0.
            if s-ptype = 4 then do:
                s-remo = "".
                run LONl_ps(not-iss).
                if s-remo = "" then do:
                    undo c1.
                    return "next".
                end.
            end.
            if (s-ptype = 1) or (s-ptype = 3) then do:
                v-param = string (loniss) + vdel + lon.lon + vdel.
                if s-ptype = 3 and s-crc = lon.crc then do:
                    v-param = v-param + s-acc + vdel.
                    v-templ = "LON0003".
                end.
                else v-templ = "LON0001".
                v-param = v-param +
                          s-glremx[1] + vdel +
                          s-glremx[2] + vdel +
                          s-glremx[3] + vdel +
                          s-glremx[4] + vdel +
                          s-glremx[5].

                if lon.crc <> s-crc then do:
                    if s-ptype = 3 then do:
                        v-templ = "LON0004".
                        v-param = s-acc + vdel + v-param.
                    end.
                    else v-templ = "LON0002".
                    v-param = string (s-crc) + vdel + v-param.
                end.

                run Collect_Undefined_Codes(v-templ).
                run Parametrize_Undefined_Codes(output OK).
                if not OK then do:
                    bell.
                    message "Не все коды введены! Транзакция не будет создана!" view-as alert-box.
                    return "exit".
                end.

                run Insert_Codes_Values(v-templ, vdel, input-output v-param).
                s-jh = 0.
                
                /*Natalya D. - перед формированием транзакции проверяет юзера на соответствие пакету доступа*/
                run usrrights.
                if return-value = '1' then run trxgen (v-templ, vdel, v-param, "lon", lon.lon, output v-rcode, output v-rdes, input-output s-jh).
                else do:
                    message "У Вас нет прав для создания транзакции!" view-as alert-box.
                    return "exit".
                end.

                if v-rcode <> 0 then do:
                    message v-rdes.
                    pause.
                    s-jh = 0.
                    undo, next.
                end.
                
                if lon.clmain <> '' then do:
                    v-param = string (loniss) + vdel + lon.clmain.
                    if lon.trtype = 1 then v-templ = "LON0139".
                    else v-templ = "LON0140".
                    find first bloncon where bloncon.lon = lon.clmain no-lock no-error.
                    s-glrem = "Списание ".
                    if lon.trtype = 1 then s-glrem = s-glrem + "возобн. ".
                    else s-glrem = s-glrem + "невозобн. ".
                    s-glrem = s-glrem + "дост. остатка КЛ, " + lon.clmain + " " + if avail bloncon then bloncon.lcnt else ''.
                    s-glrem = s-glrem + " " + trim(string(loniss,">>>,>>>,>>>,>>>,>>>,>>9.99-")) + " " + crc.code +
                              " " + trim(trim(cif.prefix) + " " + trim(cif.name)) + " РНН " + cif.jss.
                    v-param = v-param + vdel + s-glrem + vdel + vdel + vdel + vdel.
                    run trxgen (v-templ, vdel, v-param, "lon", lon.lon, output v-rcode, output v-rdes, input-output s-jh).
                    if v-rcode <> 0 then do:
                        message v-rdes + " Ошибка списания дост. остатка КЛ!".
                        pause.
                    end.
                end.

                if lon.sts <> 'A' then do:
                    find first blon where blon.lon = lon.lon exclusive-lock.
                    blon.sts = 'A'.
                    find current blon no-lock.
                end.

                find jh where jh.jh = s-jh exclusive-lock no-error.

                jh.party = trim ("GRANT OF LOAN " + jh.party).
                find current jh no-lock.

                run lonresadd(s-jh).

                /*Номер очереди*/
                if s-ptype = 1 then do:
                    find b-ofc where b-ofc.ofc = g-ofc no-lock no-error.
                    if comm-txb() = "TXB00" then do: /*Только Алматы ЦО*/
                        find last acheck where acheck.jh = string(s-jh) and acheck.dt = g-today no-lock no-error.
                        if not avail acheck then do:
                            v-chk = "".
                            v-chk = string(NEXT-VALUE(krnum)).
                            create acheck.
                            acheck.jh = string(s-jh).
                            acheck.num = string(day(g-today),"99") + string(month(g-today),"99") + string(year(g-today)) + substr(g-ofc, 4, 3) + v-chk.
                            acheck.dt = g-today.
                            acheck.n1 = v-chk.
                            release acheck.
                        end.
                    end.
                end.
                /*Номер очереди*/
            end.
            
            if s-jh <> 0 then do:
                v-nxt = 0.
                for each lnscg where lnscg.lng = lon.lon and lnscg.f0 = 0 and lnscg.flp > 0 no-lock:
                    v-nxt = lnscg.flp.
                end.

                create lnscg.
                lnscg.lng = s-lon.
                lnscg.flp = v-nxt + 1.
                lnscg.f0 = 0.
                lnscg.paid = loniss.
                lnscg.stdat = g-today.
                lnscg.jh = s-jh.
                lnscg.whn = g-today.
                lnscg.who = g-ofc.
                lnscg.schn = "   . ." + string(lnscg.flp,"zzzz").
            end.
        end.
    end. /* c1 */
end procedure.
/*------------------------------------------------------------------*/

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
