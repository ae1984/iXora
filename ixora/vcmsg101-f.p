/* vcmsg101.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Прием и раскидывание по контрактам сообщения МТ101 - список фактических ГТД от таможенных органов
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        15-5-1
 * AUTHOR
        25.12.2002 nadejda
 * CHANGES
        13.06.2003 nadejda - доработано окончательно!
        16.06.2003 nadejda - сделано разделение загрузки по РКО после составления списка клиентов
        29.07.2003 nadejda - сделана загрузка в реальную таблицу, загрузка по РКО пока убрана - просто выдается название департамента
        30.07.2003 nadejda - добавлен выбор загружать/не загружать найденную ГТД
        12.09.2003 nadejda - сделана сортировка просто по названию (поскольку русские буквы теперь нормально сортируются)
        21.01.2004 nadejda - убрано обновление ОКПО, сортировка ПС и ГТД сделана по убывающей,
                             ГТД с совпадающим номером и несовпадающей суммой по умолчанию сразу создаются
        20.04.2004 nadejda - исправлен поиск ОКПО банка
        09/11/2010 madiyar - перекомпиляция
*/


{mainhead.i}
{vc.i}
{sum2strd.i}
{get-dep.i}

def var v-month as integer.
def var v-year as integer.
def var v-filename as char.
def var v-dirc as char.
def var v-res as char.
def var v-ipaddr as char.
def var v-file0 as char init "mt101.uvr".
def var v-file as char init "mt101.txt".
def var v-bankname as char format "x(45)".
def var v-depart as integer.

def var v-select as char.

def var v-str as char.
def var v-ind as integer.
def var v-word as char.
def var v-data as char.
def var v-dtb as date.
def var v-dte as date.
def var v-departname as char.
def var v-impfile as logical.

def var v-ourbank as char.
{comm-txb.i}
v-ourbank = comm-txb().

v-month = month(g-today).
v-year = year(g-today).
if v-month = 1 then do:
  v-month = 12.
  v-year = v-year - 1.
end.
else v-month = v-month - 1.
update v-month label " Месяц" format "99"
       v-year  label "   Год" format "9999"
  with centered row 5 side-label.

find vcparams where vcparams.parcode = "mtext" no-lock no-error.
v-filename = string(v-year, "9999") + string(v-month, "99") + "." + vcparams.valchar.

find vcparams where vcparams.parcode = "mtpth101" no-lock no-error.
v-dirc = vcparams.valchar.

v-ipaddr = "ntmain".
input through value("rcp " + v-ipaddr + ":" + v-dirc + v-filename + " " + v-file0 + ";echo $?").
repeat:
  import v-res.
end.
input close.
pause 0.

if v-res <> "0" then do:
  message skip " Файл " v-dirc + v-filename " не найден!" skip(1) view-as alert-box button ok title " ОШИБКА ! ".
  return.
end.

unix silent value("cat " + v-file0 + "| win2koi > " + v-file).


v-dtb = ?.
v-dte = ?.

v-word = "".
v-data = "".
input from value(v-file).
readdata:
repeat:
  import unformatted v-str.

  v-str = trim(v-str).
  if v-str = "-}" then leave.

  if (substr(v-str, 1, 1) <> "/") and (v-word <> "NOTE") then next readdata.

  if (substr(v-str, 1, 1) = "/") then do:
    chng:
    repeat:
      v-str = substr(v-str, 2).
      if substr(v-str, 1, 1) <> "/" then leave chng.
    end.

    v-ind = index(v-str, "/").
    v-word = substr(v-str, 1, v-ind - 1).
    v-data = substr(v-str, v-ind + 1).
  end.
  else v-data = v-str.

  case v-word:
    when "BEGINREPORTDATE" then v-dtb = date(integer(substr(v-data, 3, 2)),
                                           integer(substr(v-data, 1, 2)),
                                           integer(substr(v-data, 5, 4))).
    when "ENDREPORTDATE" then v-dte = date(integer(substr(v-data, 3, 2)),
                                           integer(substr(v-data, 1, 2)),
                                           integer(substr(v-data, 5, 4))).
  end case.

  if v-dtb <> ? and v-dte <> ? then leave.
end.
input close.

if v-dtb = ? or v-dte = ? then do:
  message skip " Формат файла не соответствует стандарту !"
          skip " Не найдена дата начала или конца периода !"
          skip(1) view-as alert-box button ok title " ОШИБКА ! ".
  return.
end.

if year(v-dtb) <> year(v-dte) or month(v-dtb) <> month(v-dte) then do:
  message skip " Формат файла не соответствует стандарту !"
          skip " Дата начала и конца периода относятся к разным месяцам !"
          skip(1) view-as alert-box button ok title " ОШИБКА ! ".
  return.
end.

if entry(1, v-filename, ".") <> string(year(v-dtb), "9999") + string(month(v-dtb), "99") then do:
  message skip " Название файла" v-filename "не соответствует периоду сообщения :" skip
          " с" v-dtb "по" v-dte
          skip(1) view-as alert-box button ok title " ОШИБКА ! ".
  return.
end.


/*
def temp-table t-gtd
  field mt-year as integer
  field mt-month as integer
  field bank as char format "x(6)"
  field cif like cif.cif
  field depart as integer
  field contract like vccontrs.contract
  field docs like vcdocs.docs
  field rdt as date
  field rwho as date
  field bankokpo as char format "x(12)"
  field psnum as char format "x(30)"
  field psdate as date format "99/99/99"
  field expimp as char format "x"
  field cifokpo as char format "x(12)"
  field cifname as char format "x(70)"
  field cifsign as integer format "99"
  field dnnum as char format "x(30)"
  field dndate as date format "99/99/99"
  field dnrate as deci format "-zzz,zzz,zz9.9999"
  field payret as logical
  field crccode as char format "x(3)"
  field sum as deci format "-zzz,zzz,zzz,zz9.99"
  field partner as char format "x(30)"
  field note as char format "x(30)"
  index main is primary bank bankokpo cifokpo psdate psnum dndate dnnum payret sum.
*/
/*def temp-table t-err like t-gtd.*/

v-impfile = no.

find first vcgtdimp where vcgtdimp.mtnum = v-filename no-lock no-error.

if avail vcgtdimp then do:
  run sel (" Сообщение " + v-filename + " уже было загружено !",
    " 1. Повторить загрузку полностью | 2. Загрузить только неразобранные ГТД | 3. ВЫХОД ").
  v-select = return-value.

  if v-select = "3" then return.

  if v-select = "1" then do:
    for each vcgtdimp where vcgtdimp.mtnum = v-filename :
      delete vcgtdimp.
    end.
    v-impfile = yes.
  end.
end.
else v-impfile = yes.

if v-impfile then do:
  input from value(v-file).
  v-word = "".
  v-data = "".
  readdata:
  repeat:
    import unformatted v-str.

    v-str = trim(v-str).
    if v-str = "-}" then leave.

    if (substr(v-str, 1, 1) <> "/") and (v-word <> "NOTE") then next readdata.

    if (substr(v-str, 1, 1) = "/") then do:
      chng:
      repeat:
        v-str = substr(v-str, 2).
        if substr(v-str, 1, 1) <> "/" then leave chng.
      end.

      v-ind = index(v-str, "/").
      v-word = substr(v-str, 1, v-ind - 1).
      v-data = substr(v-str, v-ind + 1).
    end.
    else v-data = v-str.

    case v-word:
      when "BEGINREPORTDATE" then do: end.
      when "ENDREPORTDATE" then do: end.
      when "BANKOKPO" then do:
          create vcgtdimp.
          assign vcgtdimp.bankokpo = v-data
                 vcgtdimp.mtnum = v-filename
                 vcgtdimp.mtdtb = v-dtb
                 vcgtdimp.mtdte = v-dte
                 vcgtdimp.rdt = g-today
                 vcgtdimp.rwho = g-ofc.
        end.
      when "PS" then vcgtdimp.psnum = v-data.
      when "PSDATE" then vcgtdimp.psdate = date(integer(substr(v-data, 3, 2)),
                                             integer(substr(v-data, 1, 2)),
                                             integer(substr(v-data, 5, 4))).
      when "OKPO" then vcgtdimp.cifokpo = v-data.
      when "NAME" then vcgtdimp.cifname = v-data.
      when "SIGN" then do:
           vcgtdimp.cifsign = integer(v-data).
           if substr(v-data, 1, 1) = "1" then vcgtdimp.expimp = "E". else vcgtdimp.expimp = "I".
         end.
      when "GTD" then vcgtdimp.dnnum = v-data.
      when "GTDDATE" then vcgtdimp.dndate = date(integer(substr(v-data, 3, 2)),
                                              integer(substr(v-data, 1, 2)),
                                              integer(substr(v-data, 5, 4))).
      when "RATE" then vcgtdimp.dnrate = decimal(entry(1, v-data) + "." + entry(2, v-data)).
      when "SIGNCOST" then vcgtdimp.payret = (v-data = "2").
      when "COST" then do:
           vcgtdimp.crccode = substr(v-data, 1, 3).
           v-data = substr(v-data, 4).
           vcgtdimp.sum = decimal(entry(1, v-data) + "." + entry(2, v-data)).
         end.
      when "FPARTNER" then vcgtdimp.partner = v-data.
      when "NOTE" then do:
           if vcgtdimp.note <> "" then vcgtdimp.note = vcgtdimp.note + " ".
           vcgtdimp.note = vcgtdimp.note + v-data.
         end.
      otherwise do: message " no keyword " v-word. pause 100. end.
    end case.
  end.
  input close.
end.

unix silent value("rm -f " + v-file0).
unix silent value("rm -f " + v-file).



def temp-table t-vccontrs like vccontrs.

def var v-bank like txb.bank.
def var v-psnum as char.
def var v-ps like vcps.ps.
def var v-psnum11 as char.
def var v-psnum12 as char.
def var v-psnum4 as char.
def var v-choice as logical.
def var v-exit as logical.
def var v-name as char.
def var v-contract like vccontrs.contract.

def buffer b-vcps for vcps.
def new shared temp-table t-chcontr
  field contract like vccontrs.contract
  field ctdate like vccontrs.ctdate
  field ctnum like vccontrs.ctnum
  field cifname as char
  field psnum like vcps.dnnum
  field expimp like vccontrs.expimp
  field ctsum like vccontrs.ctsum
  field crc like ncrc.crc
  field crccode like ncrc.code
  field sts like vccontrs.sts
  index main is primary ctdate ctnum expimp sts crccode ctsum contract.



/* выбор клиента */
def var v-cif like cif.cif.

def new shared temp-table t-chcif
  field bank like txb.bank
  field cif like cif.cif
  field cifname as char
  field sort as char
  field rnn as char
  field okpo as char
  field valcon as logical
  index main is primary sort cif.

def new shared temp-table t-cif
  field bank like txb.bank
  field depart as integer
  field cif like bank.cif.cif
  field ssn like bank.cif.ssn
  field name as char
  field prefix as char
  field fullname as char
  field jss like bank.cif.jss
  field delother as logical
  field change as logical
  index main is primary cif.

def new shared temp-table t-ps
  field contract like vccontrs.contract
  field ps like vcps.ps
  field dndate like vcps.dndate
  field dnnum like vcps.dnnum
  field sum like vcps.sum
  field ncrccod as char
  field expimp as char
  index main is primary dndate DESC dnnum DESC ps DESC.


form
  " БАНК В ГТД УКАЗАН : " v-bank v-bankname skip
  " ПО ДАННЫМ ГТД КЛИЕНТ НЕ НАЙДЕН - ПОИСК ПО НАИМЕНОВАНИЮ : " skip(1)
  cif.cif cif.name format "x(60)" skip
  "ОКПО " cif.ssn format "x(8)"
  with no-label row 3 width 80 no-box frame f-cifname.

form
  v-name label " Введите часть наименования клиента " format "x(40)"
  validate(length(v-name) >= 3, "Укажите не менее 3 символов наименования !")
  with row 9 width 80 side-label frame f-name.


form
  " БАНК В ГТД УКАЗАН : " v-bank no-label v-bankname no-label skip
  " ПО ДАННЫМ ГТД КОНТРАКТ НЕ НАЙДЕН - ВЫБЕРИТЕ ПАСПОРТ СДЕЛКИ :" skip(1)
  vcgtdimp.cif    label "      Клиент" vcgtdimp.cifname no-label format "x(50)" skip
  v-departname    label " Департамент" format "x(60)" skip
  vcgtdimp.psnum  label "    Номер ПС"   format "x(60)" skip
  vcgtdimp.psdate label "     Дата ПС" format "99/99/9999" skip
  vcgtdimp.expimp label "         E/I"
  with row 3 side-label no-box frame f-ps.

form
  " БАНК В ГТД УКАЗАН : " v-bank no-label v-bankname no-label skip
  " ДАТА ПАСПОРТА СДЕЛКИ НЕ СОВПАДАЕТ С ДАННЫМИ ТАМОЖНИ :" skip(1)
  vcgtdimp.cif    label "      Клиент" vcgtdimp.cifname no-label format "x(50)" skip
  v-departname    label " Департамент" format "x(60)" skip
  vcgtdimp.psnum  label "    Номер ПС"   format "x(60)" skip
  vcgtdimp.psdate label "     Дата ПС" format "99/99/9999" skip
  vcgtdimp.expimp label "         E/I" skip
  vcps.dndate     label "  Дата ТАМОЖ" format "99/99/9999"
  with row 3 side-label no-box frame f-psdt.

for each t-cif. delete t-cif. end.
/* приконнектиться и собрать всех юр. клиентов ВСЕХ филиалов в t-cif */
/**
run vc101allb0.p ("TXB00").
**/
/**/
{r-brancha1.i &proc = "vc101allb (comm.txb.bank)"}
/**/


for each vcgtdimp where vcgtdimp.mtnum = v-filename and vcgtdimp.cif = "" break by vcgtdimp.bankokpo by vcgtdimp.cifokpo:
  if first-of(vcgtdimp.bankokpo) then do:
    v-bank = "".
    for each txb where txb.consolid no-lock:
      if num-entries(txb.params) > 1 and entry(2, txb.params) = vcgtdimp.bankokpo then do:
        v-bank = txb.bank.
        v-bankname = txb.name.
        leave.
      end.
    end.
    if v-bank = "" then do:
      find txb where txb.consolid and (not txb.is_branch) no-lock no-error.
      if num-entries(txb.params) > 1 and substr(entry(2, txb.params), 1, 8) = substr(vcgtdimp.bankokpo, 1, 8) then do:
        v-bank = txb.bank.
        v-bankname = txb.name.
      end.
    end.
    if v-bank = "" then do:
      message " В ГТД указан ОКПО не нашего банка !!! " vcgtdimp.bankokpo.
      pause.
    end.
  end.

  if v-bank = "" then next.

  if first-of(vcgtdimp.cifokpo) then do:
    v-cif = "".
    /* поищем клиента по ОКПО */
    find first t-cif where substr(t-cif.ssn, 1, 8) = substr(vcgtdimp.cifokpo, 1, 8) no-lock no-error.
    if avail t-cif then do:
      v-cif = t-cif.cif.
      find first t-cif where t-cif.cif <> v-cif and
           substr(t-cif.ssn, 1, 8) = substr(vcgtdimp.cifokpo, 1, 8) no-lock no-error.
      if avail t-cif then do:
        /* найдено несколько клиентов с таким ОКПО */
        for each t-chcif. delete t-chcif. end.
        for each t-cif where t-cif.ssn = substr(vcgtdimp.cifokpo, 1, 8) no-lock:
          create t-chcif.
          assign t-chcif.cif = t-cif.cif
                 t-chcif.bank = t-cif.bank
                 t-chcif.cifname = t-cif.fullname
                 t-chcif.rnn = t-cif.jss
                 t-chcif.okpo = t-cif.ssn.
          t-chcif.sort = t-chcif.cifname.
          find first vccontrs where vccontrs.bank = v-bank and vccontrs.cif = t-cif.cif no-lock no-error.
          t-chcif.valcon = (avail vccontrs).
        end.
        v-cif = "".

        displ v-bank v-bankname substr(vcgtdimp.cifname, 1, 70) @ cif.name
              substr(vcgtdimp.cifokpo, 1, 8) @ cif.ssn
          with frame f-cifname.

        message skip
          " По ОКПО, указанному в ГТД, найдено несколько клиентов - выберите правильного клиента !"
          skip(1) view-as alert-box buttons ok title " ВНИМАНИЕ ! ".
        run vc101cif (output v-cif).

        /* не будем менять, пусть поднимают досье
        if v-cif <> "" then do:
          v-choice = no.
          message skip " Очистить совпадающие ОКПО у остальных клиентов из списка ? "
            skip(1) view-as alert-box buttons yes-no title " ВНИМАНИЕ ! " update v-choice.
          if v-choice then do:
            find t-cif where t-cif.cif = v-cif.
            t-cif.delother = true.
          end.
        end.
        */
      end.
    end.
    else do:
      ch:
      repeat:
        /* предложим список клиентов для поиска по известному наименованию */
        displ v-bank v-bankname substr(vcgtdimp.cifname, 1, 70) @ cif.name
              substr(vcgtdimp.cifokpo, 1, 8) @ cif.ssn
          with frame f-cifname.

        update v-name with frame f-name.
        hide frame f-name no-pause.

        v-name = trim(v-name).

        for each t-chcif. delete t-chcif. end.
        for each t-cif where t-cif.name matches "*" + v-name + "*" no-lock:
          create t-chcif.
          assign t-chcif.cif = t-cif.cif
                 t-chcif.bank = t-cif.bank
                 t-chcif.cifname = t-cif.fullname
                 t-chcif.rnn = t-cif.jss
                 t-chcif.okpo = t-cif.ssn.
          t-chcif.sort = t-chcif.cifname.
          find first vccontrs where vccontrs.bank = v-bank and vccontrs.cif = t-cif.cif no-lock no-error.
          t-chcif.valcon = (avail vccontrs).
        end.
        v-cif = "".
        run vc101cif (output v-cif).
        if v-cif = "" then do:
          v-choice = no.
          message skip " Ничего не выбрано !" skip "Повторить поиск ?" skip(1)
              view-as alert-box buttons yes-no title " ВНИМАНИЕ ! " update v-choice.
          v-exit = not v-choice.
        end.
        else v-exit = true.
        if v-exit then leave ch.
        hide frame f-cifname no-pause.
      end.

      /* не будем менять, пусть поднимают досье
      if v-cif <> "" then do:
        find t-cif where t-cif.cif = v-cif.
        v-choice = no.
        message skip " У клиента " + trim(trim(t-cif.name) + " " + trim(t-cif.prefix)) skip
            " указан ОКПО " + substr(t-cif.ssn, 1, 8) skip(1)
            " в ГТД указан ОКПО " + substr(vcgtdimp.cifokpo, 1, 8) skip(1)
            " Заменить ОКПО клиента на указанный в ГТД ?"
            skip(1) view-as alert-box buttons yes-no title " ВНИМАНИЕ ! " update v-choice.
        if v-choice then do:
          t-cif.ssn = substr(vcgtdimp.cifokpo, 1, 8).
          t-cif.change = yes.
        end.
      end.
      */
    end.
  end.

  if v-cif <> "" then do:
    /* клиент известен */
    find t-cif where t-cif.cif = v-cif no-error.
    assign vcgtdimp.bank = t-cif.bank
           vcgtdimp.cif = v-cif
           vcgtdimp.depart = t-cif.depart.
  end.

end.

displ "clients finish".

/* приконнектиться и 1) почистить совпадающие ОКПО 2) поменять ОКПО у выбранных клиентов */
/**
run vc101chngb0.p ("TXB00").
**/
/** не будем менять, пусть поднимают досье
if can-find(first t-cif where t-cif.delother) or can-find(first t-cif where t-cif.change) then do:
  {r-brancha1.i &proc = "vc101chngb (comm.txb.bank)" }
end.
**/

hide frame f-cifname no-pause.
hide frame f-name no-pause.

v-depart = get-dep(g-ofc, g-today).

/* клиент известен - выбираем контракт ТОЛЬКО ПО КЛИЕНТАМ СВОЕГО ДЕПАРТАМЕНТА ? */
for each vcgtdimp where vcgtdimp.mtnum = v-filename and vcgtdimp.contract = 0 and
      vcgtdimp.cif <> "" /*and v-depart = vcgtdimp.depart */
      break by vcgtdimp.bank by vcgtdimp.cif by vcgtdimp.psnum by vcgtdimp.dnnum:

  if first-of (vcgtdimp.bank) then do:
    v-bank = vcgtdimp.bank.
    find txb where txb.consolid and txb.bank = v-bank no-lock no-error.
    v-bankname = txb.name.
  end.

  if first-of(vcgtdimp.cif) then do:
    for each t-vccontrs. delete t-vccontrs. end.
    for each vccontrs where vccontrs.bank = v-bank /*and vccontrs.cttype = "1"*/ and
        vccontrs.cif = vcgtdimp.cif no-lock:
      create t-vccontrs.
      buffer-copy vccontrs to t-vccontrs.
    end.
  end.

  if first-of(vcgtdimp.psnum) then do:
    v-contract = 0.

    /* поиск точного совпадения по НОМЕРУ без даты */
    find vcps where vcps.dntype = "01" and
        can-find(t-vccontrs where vcps.contract = t-vccontrs.contract) and
        vcps.dnnum = vcgtdimp.psnum no-lock no-error.

    if avail vcps then v-contract = vcps.contract.
    else do:
      /* поиск уникального совпадения в списках уже имеющихся вариантов */
      find vcps where vcps.dntype = "01" and
        can-find(t-vccontrs where vcps.contract = t-vccontrs.contract) and
        lookup(vcgtdimp.psnum, vcps.info[5], "|") <> 0 no-lock no-error.

      if avail vcps then v-contract = vcps.contract.
      else do:
        /* поищем варианты */

        /* первые 2 цифры могут быть разделены / * /
        v-psnum11 = substr(vcgtdimp.psnum, 1, 1) + "/" + substr(vcgtdimp.psnum, 2, 1) + "/".
        / * первые 2 цифры могут быть взяты в скобки вместо последнего / * /
        v-psnum12 = "(" + substr(vcgtdimp.psnum, 1, 2) + ")".
        / * в последней части может быть что угодно - слепим все! * /
        v-psnum4 = replace(entry(4, vcgtdimp.psnum, "/"), ".", "").

        v-psnum11 + entry(2, vcgtdimp.psnum, "/") + "/" + entry(3, vcgtdimp.psnum, "/") + "/" + entry(4, vcgtdimp.psnum, "/") +
        "|" + v-psnum12 + entry(2, vcgtdimp.psnum, "/") + "/" + entry(3, vcgtdimp.psnum, "/") + "/" + entry(4, vcgtdimp.psnum, "/") +
        "|" + v-psnum11 + entry(2, vcgtdimp.psnum, "/") + "/" + entry(3, vcgtdimp.psnum, "/") + "/" + v-psnum4 +
        "|" + v-psnum12 + entry(2, vcgtdimp.psnum, "/") + "/" + entry(3, vcgtdimp.psnum, "/") + "/" + v-psnum4 +
        "|" + entry(1, vcgtdimp.psnum, "/") + "/" + entry(2, vcgtdimp.psnum, "/") + "/" + entry(3, vcgtdimp.psnum, "/") + "/" + v-psnum4.
   */

        v-psnum = replace(replace(replace(replace(replace(replace(trim(vcgtdimp.psnum),
                    "/", ""), ".", ""), ",", ""), "(",""), ")", ""), " ", "").

        v-choice = no.
        for each vcps where vcps.dntype = "01" and
            can-find(t-vccontrs where vcps.contract = t-vccontrs.contract) no-lock:

           if replace(replace(replace(replace(replace(replace(trim(vcps.dnnum),
                    "/", ""), ".", ""), ",", ""), "(",""), ")", ""), " ", "") = v-psnum then do:
             v-choice = yes.
             v-ps = vcps.ps.
             v-contract = vcps.contract.
             leave.
           end.
        end.

        if v-choice then do:
          find first vcps where vcps.dntype = "01" and vcps.contract = v-contract and
              vcps.ps <> v-ps and
              replace(replace(replace(replace(replace(replace(trim(vcps.dnnum),
                      "/", ""), ".", ""), ",", ""), "(",""), ")", ""), " ", "") = v-psnum
              no-lock no-error.
          if avail vcps then do:
            v-contract = 0.
            /* найдено несколько совпадений */
            for each t-ps. delete t-ps. end.
            for each vcps where vcps.dntype = "01" and
                can-find(t-vccontrs where vcps.contract = t-vccontrs.contract) and
                replace(replace(replace(replace(replace(replace(trim(vcps.dnnum),
                        "/", ""), ".", ""), ",", ""), "(",""), ")", ""), " ", "") = v-psnum
                no-lock:
              create t-ps.
              buffer-copy vcps to t-ps.
              find t-vccontrs where t-vccontrs.contract = t-ps.contract no-error.
              t-ps.expimp = t-vccontrs.expimp.
              find ncrc where ncrc.crc = vcps.ncrc no-lock no-error.
              t-ps.ncrccod = ncrc.code.
            end.

            /* выбрать один контракт или ничего */
            find ppoint where ppoint.depart = vcgtdimp.depart no-lock no-error.
            if avail ppoint then v-departname = ppoint.name.
                            else v-departname = "".
            find t-cif where t-cif.cif = vcgtdimp.cif no-lock no-error.
            displ v-bank v-bankname vcgtdimp.cif t-cif.fullname @ vcgtdimp.cifname v-departname vcgtdimp.psnum vcgtdimp.psdate vcgtdimp.expimp with frame f-ps.
            run vc101psc (output v-contract).
            hide frame f-ps no-pause.
          end.
        end.
      end.
    end.

    if v-contract = 0 then do:
      /* не найден контракт - дадим возможность выбрать вручную */
      for each t-ps. delete t-ps. end.
      /* собрать все паспорта сделок по контрактам данного клиента */
      for each t-vccontrs where t-vccontrs.expimp = vcgtdimp.expimp no-lock:
        find first vcps where vcps.contract = t-vccontrs.contract and vcps.dntype = "01"
             no-lock no-error.
        if avail vcps then do:
          create t-ps.
          buffer-copy vcps to t-ps.
          t-ps.expimp = t-vccontrs.expimp.
          find ncrc where ncrc.crc = vcps.ncrc no-lock no-error.
          t-ps.ncrccod = ncrc.code.
        end.
      end.

      find first t-ps no-error.
      if avail t-ps then do:
        /* предложить ручной выбор из имеющихся паспортов сделок */
        find ppoint where ppoint.depart = vcgtdimp.depart no-lock no-error.
        if avail ppoint then v-departname = ppoint.name.
                        else v-departname = "".
        find t-cif where t-cif.cif = vcgtdimp.cif no-lock no-error.
        displ v-bank v-bankname vcgtdimp.cif t-cif.fullname @ vcgtdimp.cifname v-departname vcgtdimp.psnum vcgtdimp.psdate vcgtdimp.expimp with frame f-ps.
        run vc101psc (output v-contract).
        hide frame f-ps no-pause.
      end.
    end.

    if v-contract > 0 then do:
      /* даты ПС не совпадают - сообщим об этом пользователю */
      /*
      find first vcps where vcps.contract = v-contract and vcps.dntype = "01" no-lock no-error.
      if vcps.dndate <> vcgtdimp.psdate then do:
        find ppoint where ppoint.depart = vcgtdimp.depart no-lock no-error.
        if avail ppoint then v-departname = ppoint.name.
                        else v-departname = "".
        find t-cif where t-cif.cif = vcgtdimp.cif no-lock no-error.
        displ v-bank v-bankname vcgtdimp.cif t-cif.fullname @ vcgtdimp.cifname v-departname vcgtdimp.psnum vcgtdimp.psdate vcgtdimp.expimp
              vcps.dndate
              with frame f-psdt.
        pause 5.
        hide frame f-psdt no-pause.
      end.
      */

      /* при несовпадении номера ПС в базе и в МТ101 - записать в дополнительную информацию ПС этот вариант номера */
      if vcgtdimp.psnum <> vcps.dnnum and lookup(vcgtdimp.psnum, vcps.info[5], "|") = 0 then do:
        find current vcps exclusive-lock.
        if vcps.info[5] <> "" then vcps.info[5] = vcps.info[5] + "|".
        vcps.info[5] = vcps.info[5] + vcgtdimp.psnum.
        find current vcps no-lock.
      end.
    end.
  end.

  /* контракт найден? */
  if v-contract > 0 then vcgtdimp.contract = v-contract.

end.

displ "ps finish".


/* собственно создание ГТД */
def new shared temp-table t-oldgtd like vcdocs
  index sort contract dntype dndate DESC dnnum DESC docs DESC.

def var v-docs like vcdocs.docs.
def var v-ncrc like ncrc.crc.
def var v-ncrccod as char.
def var v-crcurs like vcdocs.cursdoc-con.

form skip(1)
  vcgtdimp.crccode label "Указан код валюты" skip
  v-ncrc        label "  Выберите валюту"
    help " F2 - справочник"
    validate(can-find(first ncrc where ncrc.crc = v-ncrc no-lock), " Такой валюты нет в справочнике !")
  v-ncrccod format "x(5)" no-label skip(1)
  with overlay centered row 6 side-label frame f-ncrc.

form
  vcgtdimp.bank      label "        Банк" v-bankname no-label skip
  vcgtdimp.cif       label "      Клиент" vcgtdimp.cifname no-label format "x(45)" skip
  v-departname       label " Департамент" format "x(60)" skip
  vccontrs.ctdate label "    Контракт"  format "99/99/9999"
  vccontrs.ctnum label " N" skip(1)
  "ГТД таможни :   Дата    Номер                                 Сумма    Вал  Возв" skip
  vcgtdimp.dndate format "99/99/9999" no-label colon 12
  vcgtdimp.dnnum format "x(25)" no-label
  vcgtdimp.sum format "z,zzz,zzz,zzz,zz9.99" no-label
  vcgtdimp.crccode format "xxx" no-label
  vcgtdimp.payret no-label
  with row 3 side-label no-box frame f-oldgtd.

{vc-crosscurs.i}


for each vcgtdimp where vcgtdimp.mtnum = v-filename and vcgtdimp.docs = 0 and vcgtdimp.contract > 0
    break by vcgtdimp.bank by vcgtdimp.cif by vcgtdimp.psdate by vcgtdimp.dndate:

  /* найти нужный контракт и проверить существование ГТД с таким номером, датой и суммой
     если номер не совпадает - выдать запрос на подтверждение соответствия по дате и сумме
  */
  v-docs = 0.

  find first ncrc where ncrc.code = vcgtdimp.crccode no-lock no-error.
  if avail ncrc then
    v-ncrc = ncrc.crc.
  else do:
    find first crc where crc.code = vcgtdimp.crccode no-lock no-error.
    if avail crc then v-ncrc = crc.crc.
    else do:
      /* блин, код валюты указан кривой - придется искать вручную */
      v-ncrc = 11.
      find first ncrc where ncrc.crc = v-ncrc no-lock no-error.
      v-ncrccod = ncrc.code.
      displ vcgtdimp.crccode v-ncrccod with frame f-ncrc.
      update v-ncrc with frame f-ncrc.
      find ncrc where ncrc.crc = v-ncrc no-lock no-error.
      v-ncrccod = ncrc.code.
      displ v-ncrccod with frame f-ncrc.
      vcgtdimp.crccode = ncrc.code.
      hide frame f-ncrc no-pause.
    end.
  end.

  find first vcdocs where vcdocs.dntype = "14" and
            vcdocs.contract = vcgtdimp.contract and
            vcdocs.dndate = vcgtdimp.dndate and
            vcdocs.payret = vcgtdimp.payret and trim(vcdocs.dnnum) = trim(vcgtdimp.dnnum) and
            vcdocs.pcrc = v-ncrc and vcdocs.sum = vcgtdimp.sum
            no-lock no-error.
  if avail vcdocs then do:
    /* ГТД найдена */
    v-docs = vcdocs.docs.
  end.
  else do:
    /* если не совпадает только сумма - создать вторую ГТД без вопросов */
    find first vcdocs where vcdocs.dntype = "14" and
              vcdocs.contract = vcgtdimp.contract and
              vcdocs.dndate = vcgtdimp.dndate and
              vcdocs.payret = vcgtdimp.payret and trim(vcdocs.dnnum) = trim(vcgtdimp.dnnum) and
              vcdocs.pcrc = v-ncrc
              no-lock no-error.

    if not avail vcdocs then do:
      /* не нашли точное совпадение - выдадим полный список оригинальных ГТД по этому контракту и предложим выбрать */
      for each t-oldgtd. delete t-oldgtd. end.
      for each vcdocs where vcdocs.dntype = "14" and
            vcdocs.contract = vcgtdimp.contract no-lock:
        if vcdocs.origin then do:
          create t-oldgtd.
          buffer-copy vcdocs to t-oldgtd.
        end.
      end.

      v-docs = 0.

      find first t-oldgtd no-error.
      if avail t-oldgtd then do:
        find vccontrs where vccontrs.contract = vcgtdimp.contract no-lock no-error.
        find ppoint where ppoint.depart = vcgtdimp.depart no-lock no-error.
        if avail ppoint then v-departname = ppoint.name.
                        else v-departname = "".
        find t-cif where t-cif.cif = vcgtdimp.cif no-lock no-error.
        find txb where txb.consolid and txb.bank = vcgtdimp.bank no-lock no-error.
        v-bankname = txb.name.
        displ vcgtdimp.bank v-bankname
              vcgtdimp.cif t-cif.fullname @ vcgtdimp.cifname
              v-departname
              vccontrs.ctdate vccontrs.ctnum
              vcgtdimp.dndate vcgtdimp.dnnum vcgtdimp.sum vcgtdimp.crccode vcgtdimp.payret
           with frame f-oldgtd.
    /*
        message skip "Совпадение ГТД не найдено !" skip(1)
          " Выберите нужную ГТД из списка !"
          skip(1) view-as alert-box buttons ok title " ВНИМАНИЕ ! ".
    */
        run vc101chgtd (output v-docs).
      end.
    end.
  end.

  if v-docs > 0 then do transaction:
    /* ГТД найдена */
    find vcdocs where vcdocs.docs = v-docs no-lock no-error.
    if vcdocs.sum <> vcgtdimp.sum then do:
      v-choice = no.
      message "~n Сумма найденного документа  " vcdocs.sum
          "~n~n в обрабатываемой ГТД по данным таможни указана сумма  " vcgtdimp.sum
          "~n~n Заменить СУММУ найденного документа на данные таможни ?~n~n" view-as alert-box buttons yes-no title " ВНИМАНИЕ ! " update v-choice.
      if v-choice then do:
        find current vcdocs exclusive-lock.
        vcdocs.sum = vcgtdimp.sum.
        find current vcdocs no-lock.
      end.
    end.
    if trim(vcdocs.dnnum) <> trim(vcgtdimp.dnnum) then do:
      v-choice = no.
      message "~n Номер найденного документа  " vcdocs.dnnum
          "~n~n в обрабатываемой ГТД по данным таможни указан номер  " vcgtdimp.dnnum
          "~n~n Заменить НОМЕР найденного документа на данные таможни ?~n~n" view-as alert-box buttons yes-no title " ВНИМАНИЕ ! " update v-choice.
      if v-choice then do:
        find current vcdocs exclusive-lock.
        vcdocs.dnnum = vcgtdimp.dnnum.
        find current vcdocs no-lock.
      end.
    end.
    if vcdocs.dndate <> vcgtdimp.dndate then do:
      v-choice = no.
      message "~n Дата найденного документа  " vcdocs.dndate
          "~n~n в обрабатываемой ГТД по данным таможни указана дата " vcgtdimp.dndate
          "~n~n Заменить ДАТУ найденного документа на данные таможни ?~n~n" view-as alert-box buttons yes-no title " ВНИМАНИЕ ! " update v-choice.
      if v-choice then do:
        find current vcdocs exclusive-lock.
        vcdocs.dndate = vcgtdimp.dndate.

        find vccontrs where vccontrs.contract = vcdocs.contract no-lock no-error.
        run crosscurs(vcdocs.pcrc, vccontrs.ncrc, vcdocs.dndate, output vcdocs.cursdoc-con).

        find current vcdocs no-lock.
      end.
    end.

    if vcdocs.pcrc <> v-ncrc then do:
      v-choice = no.
      find ncrc where ncrc.crc = vcdocs.pcrc no-lock no-error.
      message "~n Валюта найденного документа  " ncrc.code
          "~n~n в обрабатываемой ГТД по данным таможни указана валюта " vcgtdimp.crccode
          "~n~n Заменить ВАЛЮТУ найденного документа на данные таможни ?~n~n" view-as alert-box buttons yes-no title " ВНИМАНИЕ ! " update v-choice.
      if v-choice then do:
        find current vcdocs exclusive-lock.
        vcdocs.pcrc = v-ncrc.

        find vccontrs where vccontrs.contract = vcdocs.contract no-lock no-error.
        run crosscurs(vcdocs.pcrc, vccontrs.ncrc, vcdocs.dndate, output vcdocs.cursdoc-con).

        find current vcdocs no-lock.
      end.
    end.

    if vcdocs.payret <> vcgtdimp.payret then do:
      v-choice = no.
      message "~n В найденном документе указан возврат - " vcdocs.payret
          "~n~n в обрабатываемой ГТД по данным таможни указан возврат - " vcgtdimp.payret
          "~n~n Заменить ВОЗВРАТ найденного документа на данные таможни ?~n~n" view-as alert-box buttons yes-no title " ВНИМАНИЕ ! " update v-choice.
      if v-choice then do:
        find current vcdocs exclusive-lock.
        vcdocs.payret = vcgtdimp.payret.
        find current vcdocs no-lock.
      end.
    end.
  end.
  else do transaction:
    /* ГТД не найдена - создать с признаком "электронная": origin = no  */
    /* если это другой офис или другой департамент - запрос на создание ГТД */

    /* 21.01.2004 nadejda - создавать новую без запроса
    v-choice = (vcgtdimp.bank = v-ourbank) and (vcgtdimp.depart = v-depart).
    if not v-choice then do:
      find ppoint where ppoint.depart = vcgtdimp.depart no-lock no-error.
      message skip " Банк ГТД:" vcgtdimp.bank
              skip " Департамент ГТД:" ppoint.name
              skip(1) " ГТД не найдена - создать новую с признаком 'электронная' ?" skip(2)
              view-as alert-box buttons yes-no title " ВНИМАНИЕ ! " update v-choice.
    end.


    if v-choice then do:*/
      create vcdocs.
      vcdocs.docs = next-value(vc-docs).
      v-docs = vcdocs.docs.
      assign vcdocs.rwho = g-ofc
             vcdocs.rdt = g-today
             vcdocs.contract = vcgtdimp.contract
             vcdocs.dntype = "14"
             vcdocs.dndate = vcgtdimp.dndate
             vcdocs.dnnum = vcgtdimp.dnnum
             vcdocs.sum = vcgtdimp.sum
             vcdocs.pcrc = v-ncrc
             vcdocs.payret = vcgtdimp.payret
             vcdocs.info[1] = vcgtdimp.note
             vcdocs.origin = no
             vcdocs.cursdoc-con = 1.

      find vccontrs where vccontrs.contract = vcdocs.contract no-lock no-error.
      if vccontrs.ncrc <> vcdocs.pcrc then
        run crosscurs(vcdocs.pcrc, vccontrs.ncrc, vcdocs.dndate, output vcdocs.cursdoc-con).
/*    end.*/
  end.

  assign vcgtdimp.docs = v-docs
         vcgtdimp.cdt = g-today
         vcgtdimp.cwho = g-ofc.
end.



def stream rep-ok.
output stream rep-ok to ok.htm.

{html-title.i &stream = "stream rep-ok" &size-add = "xx-"}

put stream rep-ok unformatted "<P align=center><B>ОТЧЕТ ОБ УСПЕШНО ЗАГРУЖЕННЫХ/ПРОВЕРЕННЫХ ГТД ПО СПИСКУ<BR>" skip
    "за период с " string(v-dtb, "99/99/9999") " по " string(v-dte, "99/99/9999") "</B></P>" skip
    "<TABLE border=1 valign=top cellpadding=5>" skip
      "<TR valign=top align=center style=""font:bold;font-size:xx-small"">" skip
        "<TD>Код клиента</TD>" skip
        "<TD>ОКПО клиента</TD>" skip
        "<TD>Наименование клиента</TD>" skip
        "<TD>Дата контракта</TD>" skip
        "<TD>Номер контракта</TD>" skip
        "<TD>Эксп/Имп</TD>" skip
        "<TD>Инопартнер</TD>" skip
        "<TD>Номер ПС</TD>" skip
        "<TD>Дата ПС</TD>" skip
        "<TD>Номер ГТД</TD>" skip
        "<TD>Дата ГТД</TD>" skip
        "<TD>Курс</TD>" skip
        "<TD>Возврат?</TD>" skip
        "<TD>Валюта</TD>" skip
        "<TD>Сумма</TD>" skip
        "<TD>Оригинал?</TD>" skip
        "<TD>Примечание</TD>" skip
        "<TD>Загрузил</TD>" skip
        "<TD>Дата загрузки</TD>" skip
        "<TD>Внес документ</TD>" skip
        "<TD>Дата внесения<BR>документа</TD>" skip
      "</TR>" skip.

for each vcgtdimp where vcgtdimp.mtnum = v-filename and vcgtdimp.docs > 0
    break by vcgtdimp.bank by vcgtdimp.depart by vcgtdimp.cif by vcgtdimp.psdate by vcgtdimp.dndate:

  if first-of (vcgtdimp.bank) then do:
    put stream rep-ok unformatted
      "<TR><TD colspan=""21""><B>БАНК : " vcgtdimp.bank ", ОКПО банка : " vcgtdimp.bankokpo "</B></TD></TR>" skip.
  end.

  if first-of (vcgtdimp.depart) then do:
    find ppoint where ppoint.depart = vcgtdimp.depart no-lock no-error.
    if avail ppoint then v-departname = ppoint.name.
                    else v-departname = "".

    put stream rep-ok unformatted
      "<TR><TD colspan=""21""><B>Департамент : " v-departname "</B></TD></TR>" skip.
  end.

  find vccontrs where vccontrs.contract = vcgtdimp.contract no-lock no-error.
  find vcdocs where vcdocs.docs = vcgtdimp.docs no-lock no-error.

  find t-cif where t-cif.cif = vcgtdimp.cif no-lock no-error.

  put stream rep-ok unformatted
    "<TR align=left valign=top>"
      "<TD>" vcgtdimp.cif "</TD>" skip
      "<TD align=center>" substr(vcgtdimp.cifokpo, 1, 8) "</TD>" skip
      "<TD>" t-cif.fullname "</TD>" skip
      "<TD>" string(vccontrs.ctdate, "99/99/9999") "</TD>" skip
      "<TD>" vccontrs.ctnum "</TD>" skip
      "<TD align=center>" vcgtdimp.expimp "</TD>" skip
      "<TD>" vcgtdimp.partner "</TD>" skip
      "<TD>" vcgtdimp.psnum "</TD>" skip
      "<TD align=center>" string(vcgtdimp.psdate, "99/99/9999") "</TD>" skip
      "<TD>" vcgtdimp.dnnum "</TD>" skip
      "<TD align=center>" string(vcgtdimp.dndate, "99/99/9999") "</TD>" skip
      "<TD align=right>" sum2strd(vcgtdimp.dnrate, 4) "</TD>" skip
      "<TD align=center>" string(vcgtdimp.payret) "</TD>" skip
      "<TD align=center>" vcgtdimp.crccode "</TD>" skip
      "<TD align=right>" sum2strd(vcgtdimp.sum, 2) "</TD>" skip
      "<TD>" if vcdocs.origin then "есть" else "НЕТ" "</TD>" skip
      "<TD>" vcgtdimp.note "</TD>" skip
      "<TD>" vcgtdimp.rwho "</TD>" skip
      "<TD>" string(vcgtdimp.rdt, "99/99/9999") "</TD>" skip
      "<TD>" if vcgtdimp.cwho = "" then "&nbsp;" else vcgtdimp.cwho "</TD>" skip
      "<TD>" if vcgtdimp.cdt = ? then "&nbsp;" else string(vcgtdimp.cdt, "99/99/9999") "</TD></TR>" skip.

  if last-of (vcgtdimp.depart) then do:
    put stream rep-ok unformatted
      "<TR><TD colspan=""21"">&nbsp;</TD></TR>" skip.
  end.

end.

{html-end.i "stream rep-ok"}

output stream rep-ok close.

output to errs.htm.
{html-title.i &size-add = "xx-"}

put unformatted "<P align=center><B>ОТЧЕТ ОБ ОШИБКАХ ПРИ ЗАГРУЗКЕ СПИСКА ГТД<BR>" skip
    "за период с " string(v-dtb, "99/99/9999") " по " string(v-dte, "99/99/9999") "</B></P>" skip
    "<TABLE border=1 valign=top cellpadding=5>" skip
      "<TR valign=top align=center style=""font:bold;font-size:xx-small"">" skip
        "<TD>ОКПО банка</TD>" skip
        "<TD>Код клиента</TD>" skip
        "<TD>ОКПО клиента</TD>" skip
        "<TD>Наименование клиента</TD>" skip
        "<TD>Номер ПС</TD>" skip
        "<TD>Дата ПС</TD>" skip
        "<TD>Эксп/Имп</TD>" skip
        "<TD>Инопартнер</TD>" skip
        "<TD>Номер ГТД</TD>" skip
        "<TD>Дата ГТД</TD>" skip
        "<TD>Курс</TD>" skip
        "<TD>Возврат?</TD>" skip
        "<TD>Валюта</TD>" skip
        "<TD>Сумма</TD>" skip
        "<TD>Примечание</TD>" skip
      "</TR>" skip
      "<TR><TD colspan=""15""><B>Не найден КЛИЕНТ для следующих ГТД :</B></TD></TR>" skip.

for each vcgtdimp where vcgtdimp.mtnum = v-filename and vcgtdimp.cif = "" /*and v-depart = vcgtdimp.depart*/ :
  put unformatted "<TR align=left valign=top>"
      "<TD align=center>" vcgtdimp.bankokpo "</TD>" skip
      "<TD>" vcgtdimp.cif "</TD>" skip
      "<TD align=center>" substr(vcgtdimp.cifokpo, 1, 8) "</TD>" skip
      "<TD>" vcgtdimp.cifname "</TD>" skip
      "<TD>" vcgtdimp.psnum "</TD>" skip
      "<TD align=center>" string(vcgtdimp.psdate, "99/99/9999") "</TD>" skip
      "<TD align=center>" vcgtdimp.expimp "</TD>" skip
      "<TD>" vcgtdimp.partner "</TD>" skip
      "<TD>" vcgtdimp.dnnum "</TD>" skip
      "<TD align=center>" string(vcgtdimp.dndate, "99/99/9999") "</TD>" skip
      "<TD align=right>" sum2strd(vcgtdimp.dnrate, 4) "</TD>" skip
      "<TD align=center>" string(vcgtdimp.payret) "</TD>" skip
      "<TD align=center>" vcgtdimp.crccode "</TD>" skip
      "<TD align=right>" sum2strd(vcgtdimp.sum, 2) "</TD>" skip
      "<TD>" vcgtdimp.note "</TD></TR>" skip.
end.

put unformatted
    "<TR><TD colspan=""15"">&nbsp;</TD></TR>" skip
    "<TR><TD colspan=""15""><B>Не найден КОНТРАКТ для следующих ГТД :</B></TD></TR>" skip.

for each vcgtdimp where vcgtdimp.mtnum = v-filename and vcgtdimp.cif <> "" and vcgtdimp.contract = 0 :
  put unformatted "<TR align=left valign=top>"
      "<TD align=center>" vcgtdimp.bankokpo "</TD>" skip
      "<TD>" vcgtdimp.cif "</TD>" skip
      "<TD align=center>" substr(vcgtdimp.cifokpo, 1, 8) "</TD>" skip
      "<TD>" vcgtdimp.cifname "</TD>" skip
      "<TD>" vcgtdimp.psnum "</TD>" skip
      "<TD align=center>" string(vcgtdimp.psdate, "99/99/9999") "</TD>" skip
      "<TD align=center>" vcgtdimp.expimp "</TD>" skip
      "<TD>" vcgtdimp.partner "</TD>" skip
      "<TD>" vcgtdimp.dnnum "</TD>" skip
      "<TD align=center>" string(vcgtdimp.dndate, "99/99/9999") "</TD>" skip
      "<TD align=right>" sum2strd(vcgtdimp.dnrate, 4) "</TD>" skip
      "<TD align=center>" string(vcgtdimp.payret) "</TD>" skip
      "<TD align=center>" vcgtdimp.crccode "</TD>" skip
      "<TD align=right>" sum2strd(vcgtdimp.sum, 2) "</TD>" skip
      "<TD>" vcgtdimp.note "</TD></TR>" skip.
end.

put unformatted "</TABLE>" skip.

{html-end.i " "}
output close.

unix silent cptwin errs.htm iexplore.
unix silent cptwin ok.htm winword.

/***********************************************************************************/


