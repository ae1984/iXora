/* vcctcom.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Снятие комиссий по контракту
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        15-1
 * AUTHOR
        06.01.2003 nadejda
 * BASES
        BANK COMM
 * CHANGES
        10.10.2003 nadejda  - при создании проводки код комиссии записывается в jh.party для печати счетов-фактур
        27.01.2004 nadejda  - в jl.rem[5] пишется название комиссии
        08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
        05.07.2005 saltanat - Выборка льгот по счетам.
        05/08/2009 galina   - выводим полный номер ПС
                              убрала транзакцию внутри транзакции
        07/12/2010 aigul    - исправила v-oda-accnt c as deci на like aaa.aaa.
        31.08.2011 aigul    - save logs
        20.07.2012 damir    - тип документа 17 (Доп.лист) заменил на тип документа 04 (Доп.согл.). Данные в vcparams тоже поправлены - изменения в
                              тарифах. На основании С.З. от 20/07/2012.
        30.07.2012 damir    - добавил keyord.i,printvouord на основании С.З. 20/07/2012.
*/

{vc.i}
{global.i}
{curs_conv.i}
{keyord.i} /*Переход на новые и старые форматы ордеров*/

def input parameter p-comcod    as char.
def input parameter p-contract  like vccontrs.contract.
def input parameter p-id        like vcps.ps.

/*def var p-comcod as char.
def var p-contract like vccontrs.contract.
def var p-id like vccontrs.contract.*/

def var v-comcod    as char.
def var v-err       as log.
def var v-crca      like crc.crc.
def var v-gl        like gl.gl.
def var v-proc      like tarif2.proc .
def var v-minsum    as dec decimals 10 .
def var v-maxsum    as dec decimals 10 .
def var v-amta      as dec.
def var v-pakala    as char.
def var v-choice    as logical.
def var v-aaa       as char.
def var v-comacc    as char.
def var v-sumcom    as deci.
def var v-debt      as deci.
def var v-dnnum     as char.

/*p-comcod = "19".
find first vccontrs where vccontrs.bank = "txb00" and vccontrs.cif = "T10007" and
    vccontrs.cttype = "1" and vccontrs.expimp = "i" and vccontrs.sts = "A" no-lock no-error.
p-contract = vccontrs.contract.
find first vcps where vcps.dntype = p-comcod no-lock no-error.
p-contract = vcps.contract.
p-id = vcps.ps.
find vccontrs where vccontrs.contract = p-contract no-lock.
displ vccontrs.cif vccontrs.ctnum vccontrs.ctdate vcps.dnnum.*/

find vccontrs where vccontrs.contract = p-contract no-lock no-error.
if not avail vccontrs then do:
    message skip " Нет контракта с ID " p-contract skip(1) view-as alert-box button ok title " ВНИМАНИЕ ! ".
    return.
end.

p-comcod = "com-" + p-comcod.

find vcparams where vcparams.parcode = p-comcod no-lock no-error.
if not avail vcparams then do:
    message skip " Комиссия с кодом" p-comcod "отсутствует в настройках модуля !" skip(1) view-as alert-box button ok title " ВНИМАНИЕ ! ".
    return.
end.

v-comcod = entry(1,vcparams.valchar).
v-err = no.

run perev0(vccontrs.aaa,
           v-comcod,
           vccontrs.cif,
           output v-crca, /* валюта комиссии */
           output v-gl,   /* счет ГК */
           output v-proc,  /* процент */
           output v-minsum,  /* мин сумма */
           output v-maxsum,  /* макс сумма */
           output v-amta, /* фиксир сумма */
           output v-pakala, /* название */
           output v-err).

if v-err then do:
    message skip " Не найдена комиссия с кодом " v-comcod skip(1) view-as alert-box button ok title " ВНИМАНИЕ ! ".
    return.
end.

if entry(2, vcparams.valchar) = "no" then do:
    /* проверка на уже существующую транзакцию по типу и номеру документа - для неповторяющихся комиссий */

    case p-comcod:
        when "com-01" or when "com-04" then do:
            find vcps where vcps.ps = p-id no-lock no-error.
            v-dnnum = vcps.dnnum.
        end.
        when "com-21" or when "com-22" then do:
            find vcrslc where vcrslc.rslc = p-id no-lock no-error.
            v-dnnum = vcrslc.dnnum.
        end.
        otherwise do:
            find vcdocs where vcdocs.docs = p-id no-lock no-error.
            v-dnnum = vcdocs.dnnum.
        end.
    end case.

    find vcctcoms where vcctcoms.contract = p-contract and vcctcoms.codcomiss = p-comcod and vcctcoms.info[1] matches "*" + v-dnnum + "*"
    and vcctcoms.jh <> 0 no-lock no-error.
    if avail vcctcoms then do:
        message skip " " + vcparams.name "('" + p-comcod + "', код " + v-comcod + ")" skip "уже снята для данного контракта !" skip(1)
        view-as alert-box button ok title " ВНИМАНИЕ ! ".
        return.
    end.
end.

if v-amta = 0 then do:
    /* сумма не фиксированная */
    case p-comcod:
        when "com-01" or when "com-04" then do:
            find vcps where vcps.ps = p-id no-lock no-error.
            v-amta = vcps.sum.
        end.
        when "com-21" or when "com-22" then do:
            v-amta = vccontrs.ctsum.
        end.
        when "com-spr" then do:
            v-amta = vccontrs.ctsum.
        end.
        otherwise do:
            find vcdocs where vcdocs.docs = p-id no-lock no-error.
            v-amta = vcdocs.sum.
        end.
    end case.

    v-amta = v-amta * v-proc.
    if v-minsum > 0 and v-amta < v-minsum then v-amta = v-minsum.
    if v-maxsum > 0 and v-amta > v-maxsum then v-amta = v-maxsum.
end.

v-aaa = vccontrs.aaa.
if v-aaa <> "" then do:
    find aaa where aaa.aaa = v-aaa no-lock no-error.
    if not avail aaa then do:
        message skip " Указанный счет для снятия комиссии " v-aaa " не найден !" skip " Будет произведен поиск другого доступного счета."
        skip(1) view-as alert-box button ok title " ВНИМАНИЕ ! ".
        v-aaa = "".
    end.
    else if aaa.cif <> vccontrs.cif then do:
        message skip " Указанный счет для снятия комиссии " vccontrs.aaa " принадлежит другому клиенту - " aaa.cif
        skip " Будет произведен поиск другого доступного счета."
        skip(1) view-as alert-box button ok title " ВНИМАНИЕ ! ".
        v-aaa = "".
    end.
    else if aaa.sta = "c" then do:
        message skip " Указанный счет для снятия комиссии " vccontrs.aaa " закрыт !" skip " Будет произведен поиск другого доступного счета."
        skip(1) view-as alert-box button ok title " ВНИМАНИЕ ! ".
        v-aaa = "".
    end.
    else if aaa.crc <> v-crca then do:
        v-choice = no.
        message skip " Валюта указанного счета для снятия комиссии" vccontrs.aaa "-" aaa.crc " не совпадает с валютой комиссии -" v-crca "!" skip(1)
        " Снять комиссию с указанного счета ?" skip(1) view-as alert-box button yes-no title " ВНИМАНИЕ ! " update v-choice.
        if not v-choice then return.
    end.
end.

run getacct (vccontrs.cif,
             v-aaa,
             v-amta,
             v-crca,
             output v-comacc,
             output v-sumcom,
             output v-debt).

case p-comcod:
    when "com-01" or when "com-04" then do:
        find vcps where vcps.ps = p-id no-lock no-error.
        v-pakala = v-pakala + ", номер " + vcps.dnnum.
        if p-comcod = "com-01" then v-pakala = v-pakala + string(vcps.num).
        v-pakala = v-pakala + " от " + string(vcps.dndate, "99/99/99").
    end.
    when "com-21" or when "com-22" then do:
        find vcrslc where vcrslc.rslc = p-id no-lock no-error.
        v-pakala = v-pakala + ", номер " + vcrslc.dnnum + " от " + string(vcrslc.dndate, "99/99/99").
    end.
    when "com-spr" then do:
        v-pakala = v-pakala + ". Количество 1, " + string(g-today, "99/99/99").
    end.
    otherwise do:
        find vcdocs where vcdocs.docs = p-id no-lock no-error.
        v-pakala = v-pakala + ", номер " + vcdocs.dnnum + " от " + string(vcdocs.dndate, "99/99/99").
    end.
end case.


if v-comacc = "" then do:
    message skip " Нет доступного счета для снятия комиссии."
    skip " Сумма комиссии занесена в список долгов клиента."
    skip(1) view-as alert-box button ok title " ВНИМАНИЕ ! ".

    create bxcif.
    assign bxcif.cif = vccontrs.cif
    bxcif.whn = g-today
    bxcif.amount = v-amta
    bxcif.crc = v-crca
    bxcif.rem = v-pakala
    bxcif.type  = v-comcod.
    release bxcif.
    run savelog( "vcctcom", ' Нажатие кнопки комиссия, ошибка: Нет доступного счета для снятия комиссии. ').
end.

if v-comacc <> vccontrs.aaa and vccontrs.aaa <> "" then do:
    v-choice = no.
    message skip " Указанный счет для снятия комиссии " vccontrs.aaa skip
    " не совпадает с найденным доступным счетом " v-comacc skip(1)
    " Снять комиссию с доступного счета ?"
    skip(1) view-as alert-box button yes-no title " ВНИМАНИЕ ! " update v-choice.
    if not v-choice then return.
end.

if v-debt > 0 then do:
    message skip " Доступная для снятия сумма" trim(string(v-sumcom, "->>>,>>>,>>>,>>9.99")) skip
    " меньше требуемой суммы комиссии" trim(string(v-amta, "->>>,>>>,>>>,>>9.99")) skip(1)
    " Сумма комиссии занесена в список долгов клиента !"
    skip(1) view-as alert-box button ok title " ВНИМАНИЕ ! ".

    create bxcif.
    assign bxcif.cif = vccontrs.cif
    bxcif.whn = g-today
    bxcif.crc = v-crca
    bxcif.rem = v-pakala
    bxcif.type  = v-comcod
    bxcif.amount = v-amta.
    release bxcif.
    v-sumcom = 0.
    run savelog( "vcctcom", ' Нажатие кнопки комиссия, ошибка: Сумма комиссии занесена в список долгов клиента !').
end.

/* параметры шаблона  */
def var vdel    as char init "|".
def var vparam  as char init "".
def var vtempl  as char init "uni0023".
def var rem2    as char init "".
def var naznpl  like codfr.code init "840".
def var rcode   as int.
def var rdes    as char.

def new shared var s-jh like jh.jh.

s-jh = 0.

find first aaa where aaa.aaa = v-comacc no-lock no-error.


if v-sumcom > 0 then do:
    find first crc where crc.crc = aaa.crc no-lock no-error.

    v-choice = yes.
    message skip
    " Сумма комиссии : " + trim(string(v-sumcom, "->>>,>>>,>>>,>>9.99")) crc.code skip
    " Счет для снятия комиссии : " + v-comacc skip(1)
    " Продолжить ?"
    skip(1) view-as alert-box button yes-no title " ВНИМАНИЕ ! " update v-choice.


    if v-choice then do:
        vparam = string(v-sumcom) + vdel + v-comacc + vdel + string(v-gl) + vdel +
        v-pakala + vdel + rem2 + vdel + naznpl.

        do: /*transaction on error undo, return:*/
            run trxgen (vtempl, vdel, vparam, "", "", output rcode, output rdes, input-output s-jh).
            if rcode ne 0 then do:
                message " [" + string(rcode) + "] " + rdes view-as alert-box button ok title " ОШИБКА ПРОВОДКИ !".
                undo, return.
            end.

            /* 10.10.2003 nadejda - код комиссии запомнить прямо в проводке для печати счетов-фактур */
            find jh where jh.jh = s-jh exclusive-lock no-error.
            jh.party = v-comcod.

            /**********************/
            /* 27.01.2004 nadejda - и еще туда же в jl.rem[5] название комиссии для счетов-фактур */
            find tarif2 where tarif2.str5 = v-comcod and tarif2.stat = 'r' no-lock no-error.

            for each jl where jl.jh = s-jh exclusive-lock:
                jl.rem[5] = tarif2.pakalp.
            end.

            /**********************/
            release jh.
            release jl.
        end.

        /* записать в комиссии контракта */
        if v-sumcom = 0 then v-sumcom = v-amta. /* если 0 - значит вся сумма в долги ушла, взять всю сумму */

        create vcctcoms.
        assign vcctcoms.contract = p-contract
        vcctcoms.codcomiss = p-comcod
        vcctcoms.datecomiss = g-today
        vcctcoms.crc = aaa.crc
        vcctcoms.aaa = v-comacc
        vcctcoms.jh = s-jh
        vcctcoms.info[1] = v-pakala
        vcctcoms.sum = v-sumcom.
        release vcctcoms.

        v-choice = yes.
        /*message skip " Печатать операционный ордер ?"
        skip(1) view-as alert-box button yes-no title " ВАУЧЕР " update v-choice.*/
        if v-choice then do:
            if v-noord = no then run x-jlvou.
            else run printvouord(2). /*WORD Операционный ордер*/
        end.
    end.
end.


/***************************************************************************/

procedure getacct.
  def input parameter v-cif like cif.cif.
  def input parameter v-pref like aaa.aaa.
  def input parameter v-amt as deci.
  def input parameter v-crc like crc.crc.
  def var v-crcs as int extent 5 init [1,2,3,4,11].
  def var i as int.
  def output parameter v-racct like aaa.aaa init "".
  def output parameter v-ramt as deci init -99999999999999999999999999999999999999999999999.
  def var v-rate as deci init 1.0.
  def output parameter v-debt as deci init 0.
  def var v-comrate as deci.
  def buffer baaa for aaa.
  def buffer bcrc for crc.
  def var v-bal as deci.
  def var v-avail-bal as deci.
  def var v-hold-bal as deci.
  def var v-frozen-bal as deci.
  def var v-cred-line as deci.
  def var v-cred-line-used as deci.
  def var v-oda-accnt /*as deci*/ like aaa.aaa.

  find first bcrc where bcrc.crc = v-crc no-lock.

  if v-pref <> "" and v-pref <> ? then
    find first aaa where aaa.aaa = v-pref no-lock no-error.
  if avail aaa and
    can-find(first lgr where lgr.lgr = aaa.lgr and lgr.led = "DDA" no-lock) and
    not can-find(first sub-cod where sub-cod.acc = v-pref and
                 sub-cod.sub = "cif" and d-cod = "flg90" and ccode = "no" no-lock) then do:
      find first crc where crc.crc = aaa.crc no-lock.
      if (aaa.cbal - aaa.hbal) * crc.rate[1] >= v-amt * bcrc.rate[1] then do:
          v-racct = v-pref.
          v-ramt = v-amt * bcrc.rate[1] / crc.rate[1].
          return.
      end.
  end.

  do i = 1 to 5:
    find first crc where crc.crc = v-crcs[i] no-lock no-error.
    for each aaa where aaa.cif = v-cif
          and aaa.crc = crc.crc and sta <> "C" and aaa.lgr ne "235"
          and can-find(first lgr where lgr.lgr = aaa.lgr
                       and (lgr.led = "DDA" or lgr.led = "SAV") no-lock) no-lock:
      find first sub-cod where sub-cod.acc = aaa.aaa and sub-cod.sub = "cif"
                 and sub-cod.d-cod = "flg90" and sub-cod.ccode = "no" no-lock no-error.
      if not avail sub-cod then do:
        run aaa-bal777(input aaa.aaa,
              output v-bal,
              output v-avail-bal,
              output v-hold-bal,
              output v-frozen-bal,
              output v-cred-line,
              output v-cred-line-used,
              output v-oda-accnt).

        if v-avail-bal * crc.rate[1] >= v-amt * bcrc.rate[1] then do:
          v-racct = aaa.aaa.
          v-ramt = v-amt * bcrc.rate[1] / crc.rate[1].
          return.
        end.

        if v-avail-bal * crc.rate[1] >= v-ramt * v-rate then do:
          v-racct = aaa.aaa.
          v-ramt = v-avail-bal.
          v-rate = crc.rate[1].
        end.
      end.
    end.
  end.

  if v-ramt < 0 then v-ramt = 0.
  v-debt = (v-amt * bcrc.rate[1] - v-ramt * v-rate) / bcrc.rate[1].
end procedure.


Procedure perev0.
  def input parameter v-aaa as char.
  def input parameter komis as char format "x(4)".
  def input parameter tcif like cif.cif .

  def output parameter kod11 like rem.crc1.
  def output parameter konts like gl.gl.
  def output parameter tproc   like tarif2.proc .
  def output parameter tmin1   as dec decimals 10 .
  def output parameter tmax1   as dec decimals 10 .
  def output parameter tost    as dec decimals 10 .
  def output parameter pakal as char.
  def output parameter v-err as log.

  def buffer bcif for cif.
  def var avl_sum as deci.
  def var comis as logi.

  v-err = no.
  find first tarif2 where tarif2.str5 = komis and tarif2.stat = 'r' no-lock no-error.

  if available tarif2 then  do :
    if tcif <> "" then
    /* 05/07/05 saltanat - Если у клиента есть льготы по счету, то берем тариф по счету */
    find first tarifex2 where tarifex2.aaa = v-aaa
                          and tarifex2.cif = tcif
                          and tarifex2.str5 = tarif2.str5
                          and tarifex2.stat = 'r' no-lock no-error.
    if avail tarifex2 then do:
       find bcif where bcif.cif = tcif no-lock no-error.
       comis = yes. /* commission > 0 */
       avl_sum = avail_bal(v-aaa).
       if (avail bcif and bcif.type = 'p') and (tarifex2.str5 = '105' or tarifex2.str5 = '419') and tarifex2.nsost ne 0 then do:
          if konv2usd(avl_sum,tarifex2.crc,g-today) > tarifex2.nsost then comis = no.
       end.

       kod11 = tarifex2.crc.
	   pakal = tarifex2.pakal.
       konts = tarifex2.kont.
	   tproc = if comis then tarifex2.proc else 0.
	   tmin1 = if comis then tarifex2.min1 else 0.
       tmax1 = if comis then tarifex2.max1 else 0.
	   tost  = if comis then tarifex2.ost else 0.
    end.
    else do:
	    find first tarifex where tarifex.str5 = tarif2.str5 and tarifex.cif = tcif and tarifex.stat = 'r' no-lock no-error.
	    if avail tarifex then do :
    	  kod11 = tarifex.crc.
	      pakal = tarifex.pakal.
    	  konts = tarifex.kont.
		  tproc = tarifex.proc.
	      tmin1 = tarifex.min1.
    	  tmax1 = tarifex.max1.
	      tost  = tarifex.ost.
    	end .
	    else do :
    	  kod11 = tarif2.crc.
	      pakal = tarif2.pakal.
    	  konts = tarif2.kont.
	      tproc = tarif2.proc.
    	  tmin1 = tarif2.min1.
	      tmax1 = tarif2.max1.
    	  tost  = tarif2.ost.
	    end .
	end. /* tarifex2 */
  end. /*tarif2*/
  else
    v-err = yes.
end procedure.




