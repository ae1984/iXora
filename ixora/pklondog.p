/* pklondog.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Печать договоров после принятия решения о выдаче кредита
 * RUN

 * CALLER
        jou-aasnew.p
 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        09.02.2003 nadejda
 * CHANGES
        04.03.2003 nadejda - вырезан кусок запроса дополнительных сведений в проги по видам кредитов
        28.05.2003 nadejda - изменено формирование полного имени - теперь вызывается процедура pkdeffio,
                             формирует с учетом казахских букв
        23.07.2003 nadejda - добавила параметр в pksysc - печатать/не печатать договор на открытие счета, а здесь обработку сделала
        03.10.2003 nadejda - добавила проверку на нулевую сумму запроса
        01.02.2004 nadejda - изменен формат вызова pkdefadres для совместимости
        08.09.2004 saltanat - добавила контактные тел. номера банка
        19/11/2004 madiyar - добавил сик
        11.04.05 saltanat - Добавила сохранение истории при закрытии анкеты.
        24/05/2005 madiyar - добавил орган выдачи документа
        03/06/2005 madiyar - орган выдачи документа - значение из справочника
        22/06/2005 madiyar - добавил рабочий телефон, название организации
        24/06/2005 madiyar - подправил определение даты выдачи документа
        29/05/2006 madiyar - добавил в полную сумму кредита ABN-овскую комиссию
        03/10/2006 madiyar - no-undo в нешаренных переменных, мелкие исправления
        24/04/2007 madiyar - веб-анкеты
        22/01/2008 madiyar - изменения в договоре
        24/01/2008 madiyar - расчет комиссии за обслуживание кредита, мелкие исправления
        30.01.08   marinav - убрана карточка подписей клиента
        23.04.2008 alex - добавил параметры для казахского языка.
        04.06.2008 alex - изменения в договоре (валюта кредита)
        23/06/2008 madiyar - ИИК банка из sysc.sysc = "bnkiik2"
        27/05/2009 madiyar - сумма прописью - десятичная часть идет цифрами за суммой после запятой
        01/06/2009 madiyar - сделал нормально суммы прописью
        02/10/2009 galina - выводим созаемщика
        15/10/2009 galina - убрала вывод договора банковского счета, т.к. счета еще не открыты
        04/11/2009 galina - поправила вывод даты выдачи удв.документа
        20/12/2009 galina - выводим график платежей для подписи
        02/04/2010 madiyar - поправил номер телефона созаемщика
*/


{global.i}
{pk.i}
{pk-sysc.i}

/**
s-credtype = "3".
s-pkankln = 8.
**/

if s-pkankln = 0 then return.

find pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and
     pkanketa.ln = s-pkankln no-lock no-error.

if not avail pkanketa then do:
  message skip " Анкета N" s-pkankln "не найдена !" skip(1) view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.

def var v-ans as logical no-undo.
def var v-sts as logical no-undo init true.
def new shared var v-inet as logi init no.
if pkanketa.id_org = "inet" then v-inet = yes.
def new shared var v-toplogo as char.
def new shared var v-stamp as char.
if v-inet then do:
    v-toplogo = "c:\\tmp\\top_logo_bw.jpg".
    /*
    s-dogsign определяется один раз в PKI_ps.p
    */
    v-stamp = "c:\\tmp\\pkstamp.jpg".
end.
else do:
    v-toplogo = "top_logo_bw.jpg".
    /*
    s-dogsign = "<IMG border=""0"" src=""pkdogsgn.jpg"" width=""180"" height=""60"" v:shapes=""_x0000_s1026"">".
    */
    v-stamp = get-pksysc-char ("dcstmp").
end.

if pkanketa.sumq = 0 then do:
  find pksysc where pksysc.sysc = "sumq=0" and pksysc.credtype = s-credtype no-lock no-error.
  if not avail pksysc or not pksysc.loval then do:
    if not v-inet then message skip " Сумма кредита НЕ ЗАДАНА - документы не должны оформляться !" skip(1) view-as alert-box buttons ok title " ОШИБКА ! ".
    return.
  end.
end.


if not v-inet then do:
    if pkanketa.sts >= "20" then do:
      v-ans = false.
      message skip " Документы уже оформлены !~n Распечатать снова?" skip(1) view-as alert-box buttons yes-no title "" update v-ans.
      if not v-ans then return.
      v-sts = false.
    end.
end.

if v-sts then do:

  if v-inet then do: if pkanketa.sts <> "12" then return. end.
  else do:
      if pkanketa.sts <> "10" then do:
        message skip " В выдаче кредита отказано - документы не должны оформляться !" skip(1) view-as alert-box buttons ok title " ОШИБКА ! ".
        return.
      end.
  end.

  /* дополнительные данные */
  {pkduedt.i}
  {pkcifnew.i}

  find current pkanketa exclusive-lock.
  pkanketa.docdt = g-today.
  /* формирование номеров договоров и приложений*/
  run value("pkdoginf-" + s-credtype).

  pkanketa.duedt = pkduedtm(pkanketa.docdt, pkanketa.srok).

  def var v-sumcomabn as deci.
  v-sumcomabn = 0.
  if pkanketa.rescha[3] <> '' then do:
    find first tarif2 where tarif2.str5 = "039" and tarif2.stat = 'r' no-lock no-error.
    if avail tarif2 then v-sumcomabn = tarif2.ost.
    else v-sumcomabn = 350.
  end.

  find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "gcvpsum" no-error.

 /* if not v-inet or entry(1,pkanketh.rescha[3]) = "1" then do:*/
    pkanketa.summa = pk-fullsum(pkanketa.sumq) + v-sumcomabn.
    pkanketa.sumcom = pk-tarif(pkanketa.sumq).
/*  end.*/

  find current pkanketa no-lock.
end.

/* собственно договора */

def new shared var v-ofile as char.

/* сведения о банке */
def new shared var v-bankname as char.
def new shared var v-banknamekz as char.
def new shared var v-bankadres as char.
def new shared var v-bankadreskz as char.
def new shared var v-bankiik as char.
def new shared var v-bankbik as char.
def new shared var v-bankups as char.
def new shared var v-bankrnn as char.
def new shared var v-bankface as char.
def new shared var v-bankfaceKZ as char.
def new shared var v-dol as char.
def new shared var v-dolKZ as char.
def new shared var v-bankkomupos as char.
def new shared var v-bankkomufio as char.
def new shared var v-banksuff as char.
def new shared var v-bankosn as char.
def new shared var v-bankosnKZ as char.
def new shared var v-bankpodp as char.
def new shared var v-bankpodpkz as char.
def new shared var v-city as char.
def new shared var v-citykz as char.
def new shared var v-bankcontact as char.

find first cmp no-lock no-error.
if avail cmp then do:
    v-bankname = cmp.name.
    find sysc where sysc.sysc = "bnkadr" no-lock no-error.
        if avail sysc and num-entries(sysc.chval,"|") > 13 then v-banknamekz = entry(14, sysc.chval,"|").
    v-city = entry(1, cmp.addr[1]).
    find sysc where sysc.sysc = "bnkadr" no-lock no-error.
        if avail sysc and num-entries(sysc.chval,"|") > 12 then v-citykz = entry(12, sysc.chval,"|").
    v-bankadres = cmp.addr[1].
    find sysc where sysc.sysc = "bnkadr" no-lock no-error.
        if avail sysc and num-entries(sysc.chval,"|") > 11 then v-bankadreskz = entry(11, sysc.chval,"|").
    v-bankrnn = cmp.addr[2].
    v-bankcontact = cmp.contact.
end.

{sysc.i}
v-bankiik = get-sysc-cha ("bnkiik2").
v-bankbik = get-sysc-cha ("clecod").
v-bankups = get-sysc-cha ("bnkups").

find bookcod where bookcod.bookcod = "credtype" and bookcod.code = s-credtype no-lock no-error.
v-bankface = entry(1, get-sysc-cha (bookcod.info[1] + "face")).
v-bankfaceKZ = entry(1, get-sysc-cha (bookcod.info[1] + "facekz")).
v-dol = entry(2, get-sysc-cha (bookcod.info[1] + "face")).
v-dolKZ = entry(2, get-sysc-cha (bookcod.info[1] + "facekz")).
v-bankkomupos = entry(1, get-sysc-cha (bookcod.info[1] + "komu")) + " " + v-bankname.
v-bankkomufio = entry(2, get-sysc-cha (bookcod.info[1] + "komu")).
v-banksuff = get-sysc-cha (bookcod.info[1] + "suff").
v-bankosn = get-sysc-cha (bookcod.info[1] + "osn").
v-bankosnKZ = get-sysc-cha (bookcod.info[1] + "osnkz").
v-bankpodp = get-sysc-cha (bookcod.info[1] + "podp").
v-bankpodpkz = get-sysc-cha (bookcod.info[1] + "podpkz").


/* сведения об анкете - общие для всех видов кредитов */
def new shared var v-partner as char.
def new shared var v-partnername as char.
def new shared var v-goal as char.
def new shared var v-dognom as char.
def new shared var v-zaldognom as char.
def new shared var v-datastr as char.
def new shared var v-datastrkz as char.
def new shared var v-datadoc as char.
def new shared var v-billnom as char.
def new shared var v-billsum as char.
def new shared var v-summa as char.
def new shared var v-summawrd as char.
def new shared var v-summawrdKZ as char.
def new shared var v-credval as char. /*валюта кредита*/
/*def new shared var v-credvalKZ as char. валюта кредита*/
def new shared var v-iik as char.
def new shared var v-iikval as char.
def new shared var v-duedt as char.
def new shared var v-prem as char.
def new shared var v-premwrd as char.
def new shared var v-base as char.
def new shared var v-basewrd as char.
def new shared var v-name as char.
def new shared var v-namefull as char.
def new shared var v-nameshort as char.
def new shared var v-rnn as char.
def new shared var v-sik as char.
def new shared var v-srok as char.
def new shared var v-docnum as char.
def new shared var v-docdt as char.
def new shared var v-docvyd as char.
def new shared var v-adres as char extent 2.
def new shared var v-adresfull as char.
def new shared var v-adreslabel as char.
def new shared var v-sumq as char.
def new shared var v-sumqwrd as char.
def new shared var v-predpr as char.
def new shared var v-telefon as char.
def new shared var v-telefonr as char.
def new shared var v-joborg as char.
def var v-adresd as char no-undo extent 2.


/*galina*/
/* сведения об анкете - общие для всех видов кредитов */
def new shared var v-names as char.
def new shared var v-rnns as char.
def new shared var v-docnums as char.
def new shared var v-docdts as char.
def new shared var v-adress as char extent 2.
def new shared var v-telefons as char.
def new shared var v-nameshorts as char.
def var v-adresds as char no-undo extent 2.
/**/


/* расчет эффективной ставки */
def var v-effrate_d as deci no-undo.
def var v-pdat as date no-undo.
def var v-comved as deci no-undo.
def new shared var v-effrate as char.

def var tempc as char no-undo.
def var strTemp as char no-undo.
def var str1 as char no-undo.
def var str2 as char no-undo.

/*валюта кредита*/
find first crc where crc.crc = pkanketa.crc no-lock no-error.
    if avail(crc) then v-credval = crc.code.
    v-iik = pkanketa.aaa.
    v-iikval = pkanketa.aaaval.
/*валюта кредита*/

v-pdat = ?.
find first lnsch where lnsch.lnn = pkanketa.lon and lnsch.f0 > 0 no-lock no-error.
if avail lnsch then v-pdat = lnsch.stdat.
else do:
    update v-pdat format "99/99/9999" validate(v-pdat <> ?,'Некорректное значение') label "Дата 1-го платежа по графику для расчета эфф. ставки"
    with centered overlay row 7 frame dtf.
    hide frame dtf.
    find current pkanketa exclusive-lock no-error.
    if avail pkanketa then pkanketa.resdat[1] = v-pdat.
    find current pkanketa no-lock no-error.
end.

v-comved = 0.
find first tarifex2 where tarifex2.aaa = pkanketa.aaa and tarifex2.cif = pkanketa.cif and tarifex2.str5 = "195" and tarifex2.stat = 'r' no-lock no-error.
if avail tarifex2 then v-comved = tarifex2.ost.
else do:
    find pksysc where pksysc.credtype = s-credtype and pksysc.sysc = "bdacc" no-lock no-error.
    if avail pksysc then v-comved = pkanketa.summa * pksysc.deval / 100.
    else message "Ошибка определения суммы комиссии за обслуживание кредита" view-as alert-box error.
end.
run erl_bdf(pkanketa.summa,pkanketa.srok,pkanketa.rateq,pkanketa.docdt,v-pdat,pkanketa.sumcom,v-comved,0,output v-effrate_d).
v-effrate = string(v-effrate_d,">>9.<<").
if substr(v-effrate,length(v-effrate), 1) = '.' then v-effrate = substr(v-effrate, 1, length(v-effrate) - 1).

def var i as integer no-undo.
def var n as integer no-undo.
def var pk-sts as char no-undo.
def var v-bspr as char no-undo.

v-dognom = entry(1, pkanketa.rescha[1]).
v-zaldognom = entry(2, pkanketa.rescha[1]).

run pkdefdtstr(pkanketa.docdt, output v-datastr, output v-datastrkz).
/*run pkdefdtstr(pkanketa.docdt, output v-datastrkz).*/

v-datadoc = string(pkanketa.docdt, "99/99/9999").
v-summa = replace(string(pkanketa.summa, ">>>,>>>,>>9.99"), ",", " ").
v-billsum = replace(string(pkanketa.billsum, ">>>,>>>,>>9.99"), ",", " ").

tempc = string (pkanketa.summa).
if num-entries(tempc,".") = 2 then do:  /*если равно, то в сумме есть тиыны*/
    tempc = substring(tempc, length(tempc) - 1, 2).
    if num-entries(tempc,".") = 2 then tempc = substring(tempc,2,1) + "0".
end.
else tempc = "00".
strTemp = string(truncate(pkanketa.summa,0)).

run Sm-vrd(input pkanketa.summa, output v-summawrd).
run sm-wrdcrc(input strTemp,input tempc,input pkanketa.crc,output str1,output str2).
v-summawrd = v-summawrd + " " + str1 + " " + tempc + " " + str2.

/*
run Sm-vrd(pkanketa.summa, output v-summawrd).
if pkanketa.summa - trunc(pkanketa.summa,0) > 0 then
    v-summawrd = v-summawrd + ',' + substring(string(pkanketa.summa - trunc(pkanketa.summa,0),">.99"),3,2).
*/

run Sm-vrd-KZ(pkanketa.summa,pkanketa.crc,output v-summawrdKZ).

v-srok = string(pkanketa.srok, ">>9").
v-duedt = string(pkanketa.duedt, "99/99/9999").

v-prem = trim(string(pkanketa.rateq, ">>>9")).
run Sm-vrd(pkanketa.rateq, output v-premwrd).
v-base = trim(string(get-pksysc-int ("pkbase"), ">>9")).
v-basewrd = get-pksysc-char ("pkbase").

v-name = pkanketa.name.
v-rnn = pkanketa.rnn.
v-docnum = pkanketa.docnum.
v-billnom = pkanketa.billnom.
v-goal = pkanketa.goal.
v-sumq = replace(string(pkanketa.sumq, ">>>,>>>,>>9.99"), ",", " ").

tempc = string (pkanketa.sumq).
if num-entries(tempc,".") = 2 then do:  /*если равно, то в сумме есть тиыны*/
    tempc = substring(tempc, length(tempc) - 1, 2).
    if num-entries(tempc,".") = 2 then tempc = substring(tempc,2,1) + "0".
end.
else tempc = "00".
strTemp = string(truncate(pkanketa.sumq,0)).

run Sm-vrd(input pkanketa.sumq, output v-sumqwrd).
run sm-wrdcrc(input strTemp,input tempc,input pkanketa.crc,output str1,output str2).
v-sumqwrd = v-sumqwrd + " " + str1 + " " + tempc + " " + str2.

/*
run Sm-vrd(pkanketa.sumq, output v-sumqwrd).
if pkanketa.sumq - trunc(pkanketa.sumq,0) > 0 then
    v-sumqwrd = v-sumqwrd + ',' + substring(string(pkanketa.sumq - trunc(pkanketa.sumq,0),">.99"),3,2).
*/

v-partner = pkanketa.partner.
find codfr where codfr.codfr = "pkpartn" and codfr.code = pkanketa.partner no-lock no-error.
if avail codfr then v-partnername = codfr.name[1].

find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and
     pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "dtpas" no-lock no-error.
if avail pkanketh then do:
  if index(pkanketh.value1,".") > 0 then v-docdt = replace(pkanketh.value1,'.','/').
  else do:
      if index(pkanketh.value1,"/") > 0 then v-docdt = pkanketh.value1.
      else v-docdt = string(pkanketh.value1, "99/99/9999").
  end.
end.

find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and
     pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "tel" no-lock no-error.
if avail pkanketh then v-telefon = trim(pkanketh.value1).

find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and
     pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "tel2" no-lock no-error.
if avail pkanketh then v-telefonr = trim(pkanketh.value1).

find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and
     pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "joborg" no-lock no-error.
if avail pkanketh then v-joborg = trim(pkanketh.value1).

find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and
     pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "sik" no-lock no-error.
if avail pkanketh then v-sik = pkanketh.value1.

v-docvyd = "МВД РК".
find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and
     pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "pkdvyd" no-lock no-error.
if avail pkanketh and trim(pkanketh.value1) <> '' then do:
  find first pkkrit where pkkrit.kritcod = pkanketh.kritcod no-lock no-error.
  if avail pkkrit then do:
    if num-entries(pkkrit.kritspr) > 1 then v-bspr = entry(integer(s-credtype),pkkrit.kritspr).
    else v-bspr = pkkrit.kritspr.
    find first bookcod where bookcod.bookcod = v-bspr and bookcod.code = pkanketh.value1 no-lock no-error.
    if avail bookcod then v-docvyd = trim(bookcod.name).
  end.
end.

run pkdefsfio (pkanketa.ln, output v-nameshort).

run pkdefadres (pkanketa.ln, no, output v-adres[1], output v-adres[2], output v-adresd[1], output v-adresd[2]).

/*galina*/
def buffer b-pkanketa for pkanketa.
find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and
     pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "subln" no-lock no-error.
if avail pkanketh and trim(pkanketh.value1) <> '' then do:
  find b-pkanketa where b-pkanketa.bank = s-ourbank and b-pkanketa.credtype = s-credtype and
     b-pkanketa.ln = integer(entry(1,pkanketh.value1)) no-lock no-error.
  if avail b-pkanketa then do:
    assign v-names = b-pkanketa.name
    v-rnns = b-pkanketa.rnn
    v-docnums = b-pkanketa.docnum.
    find pkanketh where pkanketh.bank = b-pkanketa.bank and pkanketh.credtype = b-pkanketa.credtype and
         pkanketh.ln = b-pkanketa.ln and pkanketh.kritcod = "dtpas" no-lock no-error.
    if avail pkanketh then do:
      if index(pkanketh.value1,".") > 0 then v-docdts = replace(pkanketh.value1,'.','/').
      else do:
          if index(pkanketh.value1,"/") > 0 then v-docdts = pkanketh.value1.
          else v-docdts = string(pkanketh.value1, "99/99/9999").
      end.
    end.
    run pkdefadres (b-pkanketa.ln, no, output v-adress[1], output v-adress[2], output v-adresds[1], output v-adresds[2]).

    find pkanketh where pkanketh.bank = b-pkanketa.bank and pkanketh.credtype = b-pkanketa.credtype and
         pkanketh.ln = b-pkanketa.ln and pkanketh.kritcod = "tel" no-lock no-error.
    if avail pkanketh then v-telefons = trim(pkanketh.value1).

    run pkdefsfio (b-pkanketa.ln, output v-nameshorts).
  end.
end.
/**/

/**/

/* печать договоров */
run value ("pkdog-" + s-credtype).
/*def new shared var v-graf as logical.
v-graf = no.*/
run pklongrf(no).

/*карточка подписей*/
/*run pksigns (yes).*/

/* договор на открытие счета */
/*find pksysc where pksysc.credtype = s-credtype and pksysc.sysc = "dogacc" no-lock no-error.
if pksysc.loval then run pkdogacc.*/

/* закончили выдачу договоров */

if v-sts then do:
  find current pkanketa exclusive-lock.
  case s-credtype :
    when "4" then do:
                pk-sts = pkanketa.sts.
                pkanketa.sts = "99".
                run pkhis.
             end.
    otherwise pkanketa.sts = "20".
  end.
  find current pkanketa no-lock.
end.

release pkanketa.

if not v-inet then do:
    hide frame f-dop no-pause.
    message skip " Документы открыты в новом окне!" skip(1)
            " Распечатайте нужное количество экземпляров!"
            skip(1) view-as alert-box buttons ok title " ВНИМАНИЕ ! ".
end.

procedure pkhis.
    create pkankhis.
    assign pkankhis.bank = s-ourbank
           pkankhis.credtype = s-credtype
           pkankhis.ln = s-pkankln
           pkankhis.type = 'sts'
           pkankhis.chval = pk-sts
           pkankhis.who = g-ofc
           pkankhis.whn = g-today.
end procedure.
