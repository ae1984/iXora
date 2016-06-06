/* pkankdog.p
 * MODULE
        ПотребКредит
 * DESCRIPTION
        Печать всех документов по анкете
 * RUN
        верхнее меню "Договор"
 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        4-x-3
 * AUTHOR
        07.03.2003 nadejda
 * CHANGES
        01.02.2004 nadejda  - изменен формат вызова pkdefadres для совместимости
        02.09.2004 saltanat - добавила данные по тел.
        20/01/2004 madiyar   - добавил сик
        24/05/2005 madiyar  - добавил орган выдачи документа
        03/06/2005 madiyar  - орган выдачи документа - значение из справочника
        22/06/2005 madiyar  - добавил рабочий телефон, название организации
        24/06/2005 madiyar  - подправил определение даты выдачи документа
        18/05/2006 madiyar  - теперь в pkdocs.info[1] - параметры для запуска процедуры
        15/10/2009 galina - добавила вывод договора банковского счета
        13/03/2010 madiyar  - документы созаемщика
*/


{global.i}
{pk.i}

/*
{pk.i "new"}
s-credtype = "6".
s-pkankln = 65414.
*/

{pk-sysc.i}

if s-pkankln = 0 then return.

find pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and
     pkanketa.ln = s-pkankln no-lock no-error.

if not avail pkanketa then do:
  message skip " Анкета N" s-pkankln "не найдена !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.

/*def var v-datastrkz as char no-undo.*/
def new shared var v-ofile as char.
/*galina*/
def new shared var v-citykz as char.
def new shared var v-iik as char.
def new shared var v-iikval as char.
def new shared var v-credval as char.
def new shared var v-dol as char.
def new shared var v-dolkz as char.
def new shared var v-banknamekz as char.
def new shared var v-bankfacekz as char.
def new shared var v-bankosnkz as char.
def new shared var v-dognom as char.
def new shared var v-datastr as char.
def new shared var v-datastrkz as char.
def new shared var v-name as char.
def new shared var v-bankadreskz as char.
def new shared var v-bankpodpkz as char.
/**/
/* сведения о банке */
def new shared var v-bankname as char.
def new shared var v-bankadres as char.
def new shared var v-bankiik as char.
def new shared var v-bankbik as char.
def new shared var v-bankups as char.
def new shared var v-bankrnn as char.
def new shared var v-bankface as char.
def new shared var v-bankkomupos as char.
def new shared var v-bankkomufio as char.
def new shared var v-banksuff as char.
def new shared var v-bankosn as char.
def new shared var v-bankpodp as char.
def new shared var v-city as char.
def new shared var v-bankcontact as char.

find first cmp no-lock no-error.
if avail cmp then do:
  v-bankname = cmp.name.
  v-city = entry(1, cmp.addr[1]).
  v-bankadres   = cmp.addr[1].
  v-bankrnn     = cmp.addr[2].
  v-bankcontact = cmp.contact.
end.

{sysc.i}
v-bankiik = get-sysc-cha ("bnkiik").
v-bankbik = get-sysc-cha ("clecod").
v-bankups = get-sysc-cha ("bnkups").

find bookcod where bookcod.bookcod = "credtype" and bookcod.code = s-credtype no-lock no-error.
v-bankface = entry(1, get-sysc-cha (bookcod.info[1] + "face")).
v-bankkomupos = entry(1, get-sysc-cha (bookcod.info[1] + "komu")) + " " + v-bankname.
v-bankkomufio = entry(2, get-sysc-cha (bookcod.info[1] + "komu")).
v-banksuff = get-sysc-cha (bookcod.info[1] + "suff").
v-bankosn = get-sysc-cha (bookcod.info[1] + "osn").
v-bankpodp = get-sysc-cha (bookcod.info[1] + "podp").
v-bankfaceKZ = entry(1, get-sysc-cha (bookcod.info[1] + "facekz")).
v-dol = entry(2, get-sysc-cha (bookcod.info[1] + "face")).
v-dolKZ = entry(2, get-sysc-cha (bookcod.info[1] + "facekz")).
v-bankosnKZ = get-sysc-cha (bookcod.info[1] + "osnkz").
v-bankpodpkz = get-sysc-cha (bookcod.info[1] + "podpkz").

/*galina*/

find first crc where crc.crc = pkanketa.crc no-lock no-error.
if avail(crc) then v-credval = crc.code.
v-iik = pkanketa.aaa.
v-iikval = pkanketa.aaaval.
find sysc where sysc.sysc = "bnkadr" no-lock no-error.
if avail sysc and num-entries(sysc.chval,"|") > 12 then v-citykz = entry(12, sysc.chval,"|").
 find sysc where sysc.sysc = "bnkadr" no-lock no-error.
        if avail sysc and num-entries(sysc.chval,"|") > 11 then v-bankadreskz = entry(11, sysc.chval,"|").

/*v-dognom = entry(1, pkanketa.rescha[1]).
v-name = pkanketa.name.
run pkdefdtstr(pkanketa.docdt, output v-datastr, output v-datastrkz).*/
/***********/

/* сведения об анкете - общие для всех видов кредитов */
def new shared var v-partner as char.
def new shared var v-partnername as char.
def new shared var v-goal as char.
/*def new shared var v-dognom as char.*/
def new shared var v-zaldognom as char.
/*def new shared var v-datastr as char.*/
def new shared var v-datadoc as char.
def new shared var v-billnom as char.
def new shared var v-billsum as char.
def new shared var v-summa as char.
def new shared var v-summawrd as char.
def new shared var v-duedt as char.
def new shared var v-prem as char.
def new shared var v-premwrd as char.
def new shared var v-base as char.
def new shared var v-basewrd as char.
/*def new shared var v-name as char.*/
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
def var n as integer.
def var v-adresdel as char extent 2.
def var v-bspr as char.

def var v-sozaem as logi no-undo.
def var v-mainln as integer no-undo.

v-name = pkanketa.name.
v-rnn = pkanketa.rnn.
v-sumq = replace(string(pkanketa.sumq, ">>>,>>>,>>9.99"), ",", " ").
run Sm-vrd(pkanketa.sumq, output v-sumqwrd).

find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and
     pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "dtpas" no-lock no-error.
if avail pkanketh then do:
  if index(pkanketh.value1,"/") > 0 then v-docdt = pkanketh.value1.
  else v-docdt = string(pkanketh.value1, "99/99/9999").
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

v-namefull = "fname,mname".
find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and
     pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "lname" no-lock no-error.
if avail pkanketh then v-nameshort = pkanketh.value1 + " ".
do n = 1 to num-entries(v-namefull):
  find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and
       pkanketh.ln = pkanketa.ln and pkanketh.kritcod = entry(n, v-namefull) no-lock no-error.
  if avail pkanketh and substr(pkanketh.value1, 1, 1) <> "" then
    v-nameshort = v-nameshort + substr(pkanketh.value1, 1, 1) + ".".
end.

run pkdefadres(pkanketa.ln, no, output v-adres[1], output v-adres[2], output v-adresdel[1], output v-adresdel[2]).

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

v-base = trim(string(get-pksysc-int ("pkbase"), ">>9")).
v-basewrd = get-pksysc-char ("pkbase").

v-sozaem = no. v-mainln = 0.
find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "mainln" no-lock no-error.
if avail pkanketh then do:
    if trim(pkanketh.value1) <> "" then do:
        v-sozaem = yes.
        v-mainln = integer(trim(pkanketh.value1)) no-error.
    end.
end.

if v-sozaem and v-mainln = 0 then do:
    message "Анета созаемщика! Произошла ошибка при попытке найти главную анкету!" view-as alert-box error.
    return.
end.

if v-sozaem then do:
    v-billsum = replace(string(pkanketa.billsum, ">>>,>>>,>>9.99"), ",", " ").

    v-docnum = pkanketa.docnum.
    v-billnom = pkanketa.billnom.
    v-goal = pkanketa.goal.

    v-prem = trim(string(pkanketa.rateq, ">>>9")).
    run Sm-vrd(pkanketa.rateq, output v-premwrd).
end.
else do:

    if pkanketa.sts >= "05" then do:
      v-billsum = replace(string(pkanketa.billsum, ">>>,>>>,>>9.99"), ",", " ").

      v-docnum = pkanketa.docnum.
      v-billnom = pkanketa.billnom.
      v-goal = pkanketa.goal.

      v-prem = trim(string(pkanketa.rateq, ">>>9")).
      run Sm-vrd(pkanketa.rateq, output v-premwrd).
    end.

    if pkanketa.sts >= "10" then do:

    if pkanketa.sts > "10" then do:
      v-dognom = entry(1, pkanketa.rescha[1]).
      v-zaldognom = entry(2, pkanketa.rescha[1]).
    end.

      run pkdefdtstr(pkanketa.docdt, output v-datastr, output v-datastrkz).

      v-datadoc = string(pkanketa.docdt, "99/99/9999").

      v-srok = string(pkanketa.srok, ">>9").
      v-duedt = string(pkanketa.duedt, "99/99/9999").

      v-summa = replace(string(pkanketa.summa, ">>>,>>>,>>9.99"), ",", " ").
      run Sm-vrd(pkanketa.summa, output v-summawrd).

      v-partner = pkanketa.partner.
      find codfr where codfr.codfr = "pkpartn" and codfr.code = pkanketa.partner no-lock no-error.
      if avail codfr then v-partnername = codfr.name[1].

    end.

end.

/* выбрать документы для печати  */

{name2sort.i}

def var vans as logical.

def temp-table t-docs like pkdocs
  field sort as char
  field choice as char
  index sort is primary unique sort.

if v-sozaem then do:
    for each pkdocs no-lock:
      if pkdocs.info[5] = "sozaem" then do:
          create t-docs.
          buffer-copy pkdocs to t-docs.
          t-docs.sort = name2sort(t-docs.name).
      end.
    end.
end.
else do:
    for each pkdocs no-lock:
      create t-docs.
      buffer-copy pkdocs to t-docs.
      t-docs.sort = name2sort(t-docs.name).
    end.
end.

def var ss as char.

repeat:
  for each t-docs. t-docs.choice = "". end.

  {jabr.i

    &start     =  " "
    &head      =  "t-docs"
    &headkey   =  "code"
    &index     =  "sort"
    &formname  =  "pkdocs"
    &framename =  "f-docs"
    &where     =  " (t-docs.credtype = '0') or (t-docs.credtype = s-credtype) "
    &addcon    =  "false"
    &deletecon =  "false"
    &prechoose =  " "
    &predisplay = " "
    &display   =  " t-docs.choice t-docs.name "
    &highlight =  " t-docs.choice t-docs.name "
    &postkey   =  " else if keyfunction(lastkey) = 'insert-mode' then do:
                      if t-docs.choice = '' then t-docs.choice = '*'.
                                            else t-docs.choice = ''.
                      leave outer.
                    end.
                    else if keyfunction(lastkey) = 'return' then do:
                        t-docs.choice = '*'.
                        leave upper.
                    end. "
    &end =        " hide frame f-docs. "
  }


  for each t-docs where t-docs.choice = "*":
    if trim(t-docs.info[1]) <> '' then run value(t-docs.proc + if t-docs.separat then "-" + s-credtype else "") (trim(t-docs.info[1])).
    else run value(t-docs.proc + if t-docs.separat then "-" + s-credtype else "").
  end.

  if not can-find(first t-docs where t-docs.choice = "*") then leave.
end.

